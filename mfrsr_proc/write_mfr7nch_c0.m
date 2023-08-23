function fname = write_mfr7nch_c0(mfr7, mfr_lbl_ch7)

if ~isavar('mfr7')||~isstruct(mfr7)
   mfr7 = getfullname('*mfrsr7nch*','mfr7');
   mfr7 = anc_load(mfr7);
end

if ~isavar('mfr_lbl_ch7')
   mfr_lbl_path = ['C:\Users\flyn0011\OneDrive - University of Oklahoma\Documents\MATLAB\'];
   if isafile([mfr_lbl_path,'mfr_ch7.mat'])
      mfr_lbl_ch7 = load([mfr_lbl_path,'mfr_ch7.mat']);
      ch4 = mfr_lbl_ch7.ch4;
      co2 = mfr_lbl_ch7.co2;
      h2o = mfr_lbl_ch7.h2o;

   else
      [ch4] = rd_lblrtm_tape12_od; %1860 ppb
      [co2] = rd_lblrtm_tape12_od; %410 ppm
      [h2o_p1] = rd_lblrtm_tape12_od;[h2o_p5] = rd_lblrtm_tape12_od;[h2o_1] = rd_lblrtm_tape12_od;
      [h2o_2] = rd_lblrtm_tape12_od;[h2o_4] = rd_lblrtm_tape12_od;[h2o_6] = rd_lblrtm_tape12_od;
      [h2o_8] = rd_lblrtm_tape12_od;
      h2o.nm = h2o_1.nm;h2o.nu = h2o_1.nu; h2o.pwv = [.1, .5, 1, 2, 4,6, 8];
      h2o.od = [h2o_p1.od, h2o_p5.od, h2o_1.od, h2o_2.od, h2o_4.od, h2o_6.od, h2o_8.od];

      mfr_lbl_ch7.ch4 = ch4; mfr_lbl_ch7.co2 = co2; mfr_lbl_ch7.h2o = h2o;
      save([mfr_lbl_path, 'mfr_ch7.mat'],'-struct','mfr_lbl_ch7');
   end
end
ch4 = mfr_lbl_ch7.ch4;
co2 = mfr_lbl_ch7.co2;
h2o = mfr_lbl_ch7.h2o;

good = mfr7.vdata.wavelength_filter7>0 & mfr7.vdata.normalized_transmittance_filter7>0;
if sum(good)>0 % filter not correctly populated, try last file
   %    mfr7 = anc_load(mfr_files{end}); % Make more robust to handle head changes and DOD changes.
   %    good = mfr7.vdata.wavelength_filter7>0 & mfr7.vdata.normalized_transmittance_filter7>0;
   % end
   ch7.Tr = interp1(mfr7.vdata.wavelength_filter7(good), mfr7.vdata.normalized_transmittance_filter7(good), ch4.nm,'linear');
   bad = isnan(ch7.Tr); ch7.Tr(bad) = 0;
   ch7.Tr = ch7.Tr ./ trapz(ch4.nu, ch7.Tr); % Normalize to area in wavenumber
   ams = [1:.25:6];
   for am = length(ams):-1:1
      OD_ch4(am) = -log(trapz(ch4.nu, ch7.Tr.*exp(-ch4.od.*ams(am))))./ams(am);
      OD_co2(am) = -log(trapz(ch4.nu, ch7.Tr.*exp(-co2.od.*ams(am))))./ams(am);
      for pwv = 1:length(h2o.pwv)
         OD_H2O_pwv(am,pwv) = -log(trapz(h2o.nu, ch7.Tr.*exp(-h2o.od(:,pwv).*ams(am))))./ams(am);
      end
   end

   % figure; plot(h2o.pwv, OD_H2O_pwv./(ones(size(ams'))*h2o.pwv),'-');
   % logy; xlabel('pwv [cm]'); ylabel('OD/pwv');
   % title('This shows we care only about PWV, not airmass-dependence');


   % figure; plot(h2o.pwv, OD_H2O_pwv,'-');
   % logy; xlabel('pwv [cm]'); ylabel('OD');
   % title('This shows we care only about PWV, not airmass-dependence');
   % So, we pick an middling airmass like 2.5 and fit the log(OD_H2O_pwv(7,:))
   P_h2o = polyfit(h2o.pwv,log(OD_H2O_pwv(7,:)),2);

   % hold('on'); plot(h2o.pwv, exp(polyval(P_h2o,h2o.pwv)),'-r*'); logy;
   % xlabel('pwv [cm]'); ylabel('OD')


   P_ch4 = polyfit(ams, OD_ch4,2);
   P_co2 = polyfit(ams, OD_co2,2);

   % figure; plot(ams, OD_ch4,'-o',ams, OD_co2,'-x'); legend('CH_4','CO_2');
   % xlabel('airmass');ylabel('OD');

   %
   dvars = fieldnames(mfr7.vdata); dvars(1:3) = []; dvars(end-2:end) = [];

   mfr7.ncdef.vars.filter7_gas_OD = mfr7.ncdef.vars.hemisp_narrowband_filter7;
   mfr7.ncdef.vars.filter7_gas_OD.id = length(fieldnames(mfr7.vdata))-2;

   mfr7.ncdef.vars.filter7_gas_OD.atts = rmfield(mfr7.ncdef.vars.filter7_gas_OD.atts,fieldnames(mfr7.ncdef.vars.filter7_gas_OD.atts));
   mfr7.ncdef.vars.filter7_gas_OD.atts.long_name.datatype = 2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.units.datatype = 2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.missing_value.datatype=5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.valid_min.datatype=5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.valid_max.datatype=5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.explanation_of_narrowband_channel.datatype=2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.corrections.datatype=2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.comment.datatype=2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.ch4_ppb.datatype = 5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.co2_ppm.datatype = 5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.ln_h2o_poly_vs_pwv.datatype = 5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.ch4_poly_vs_oam.datatype = 5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.co2_poly_vs_oam.datatype = 5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.ray_od_1atm.datatype = 5;
   mfr7.ncdef.vars.filter7_gas_OD.atts.h2o_od_calc.datatype = 2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.ch4_od_calc.datatype = 2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.co2_od_calc.datatype = 2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.ray_od_calc.datatype = 2;
   mfr7.ncdef.vars.filter7_gas_OD.atts.trace_gas_od_calc.datatype = 2;

   mfr7.vatts.filter7_gas_OD.long_name = 'Narrowband filter 7 gas OD subtractions';
   mfr7.vatts.filter7_gas_OD.units = 'unitless';
   mfr7.vatts.filter7_gas_OD.missing_value = -9999;
   mfr7.vatts.filter7_gas_OD.valid_min = .001;
   mfr7.vatts.filter7_gas_OD.valid_max = .03;
   mfr7.vatts.filter7_gas_OD.explanation_of_narrowband_channel = 'InGaAs channel, nominal center wavelength = 1625 nm, nominal FWHM = 15 nm';
   mfr7.vatts.filter7_gas_OD.corrections = 'CH4 and CO2 vs airmass, H2O vs PWV(cm), Rayleigh for 1 atm';
   mfr7.vatts.filter7_gas_OD.comment = 'Gas corrections are 2nd order polyfits to yield vertical OD to be subtracted/accounted for in Langley and AOD VAPs';
   mfr7.vatts.filter7_gas_OD.ch4_ppb = 1860;
   mfr7.vatts.filter7_gas_OD.co2_ppm = 410;
   mfr7.vatts.filter7_gas_OD.ln_h2o_poly_vs_pwv = [P_h2o];
   mfr7.vatts.filter7_gas_OD.ch4_poly_vs_oam = [P_ch4];
   mfr7.vatts.filter7_gas_OD.co2_poly_vs_oam = [P_co2];
   mfr7.vatts.filter7_gas_OD.ray_od_1atm = rayleigh_ht(1.625);
   mfr7.vatts.filter7_gas_OD.h2o_od_calc = 'polyval(h2o.pwv,exp(polyval(P_h2o,h2o.pwv)))';
   mfr7.vatts.filter7_gas_OD.ch4_od_calc = 'polyval(airmass, P_ch4)';
   mfr7.vatts.filter7_gas_OD.co2_od_calc = 'polyval(airmass, P_co2)';
   mfr7.vatts.filter7_gas_OD.ray_od_calc = 'ray_od_1atm * surface_pressure/1013';
   mfr7.vatts.filter7_gas_OD.trace_gas_od_calc = 'ch4_od + co2_od + h2o_od + ray_od';
   mfr7.vdata.filter7_gas_OD = NaN(size(mfr7.time));
   mfr7.vdata = rmfield(mfr7.vdata, dvars);
   mfr7.ncdef.vars = rmfield(mfr7.ncdef.vars, dvars);
   mfr7.vatts = rmfield(mfr7.vatts, dvars);
   mfr7 = anc_sift(mfr7,1);
   mfr7 = anc_check(mfr7);
   [pname, fname, ext] = fileparts(mfr7.fname); fstem = strtok(fname,'.');
   fname = [fstem,'.c0.',datestr(mfr7.time(1),'yyyymmdd.HHMMSS'),ext];
   mfr7.fname = [pname,filesep, fname];
   anc_save(mfr7)
   fname = mfr7.fname;
else
   fname = [];
end
end