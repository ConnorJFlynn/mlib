function he_dual = proc_sashe_dual_a0(he,nir);
% he_dual = proc_he_1s(he, nir);
% Combine sashe vis and nir a0 by appending nir to vis
% Process shadowband cycle to produce direct and diffuse components
% Implements two approaches (mean_sb - blocked) vs (max_sb - min_sb)
% And a combination based on whether difference between side bands is small
% v 0.9 2022-02-23, Connor Clean up var names for consistency
% tbd v1.0 Augment output for comprehensive and consistent output for both
% a0 and .00 input files. Default to a0, not raw 
if ~isavar('he') he = anc_bundle_files(getfullname('*sashevis*','sashevis')); end

% nir = anc_bundle_files(getfullname('*sashenir*','sashenir'));
if isavar('nir')&&isfield(nir,'vdata')&&isfield(nir.vdata,'wavelength')
    wl = he.vdata.wavelength;
    wl = [wl; nir.vdata.wavelength];
    [vinn, ninv] = nearest(he.time, nir.time);
    he = anc_sift(he, vinn); nir = anc_sift(nir,ninv);
    rate = he.vdata.spectra./(ones(size(he.vdata.wavelength))*he.vdata.integration_time); rate = rate';
    rate = [rate ,(nir.vdata.spectra./(ones(size(nir.vdata.wavelength))*nir.vdata.integration_time))'];
else
    wl = he.vdata.wavelength;
    rate = he.vdata.spectra./(ones(size(he.vdata.wavelength))*he.vdata.integration_time); rate = rate';
end
darks_ii = find(he.vdata.tag==3); len = length(darks_ii);
hemisp_ii = find(he.vdata.tag==4);len = min([len, length(hemisp_ii)]);
sideA_ii = find(he.vdata.tag==6); len = min([len, length(sideA_ii)]);
blocked_ii = find(he.vdata.tag==8);len = min([len, length(blocked_ii)]);
sideB_ii = find(he.vdata.tag==10); len = min([len, length(sideB_ii)]);
%trim to shortest len
darks_ii(len+1:end) = []; hemisp_ii(len+1:end) = []; sideA_ii(len+1:end) = [];
blocked_ii(len+1:end)=[];  sideB_ii(len+1:end) = [];

% good_blk = sideA_(blocked_ii-1) & sideB_(blocked_ii+1);
% blocked_(blocked_ii(~good_blk)) = false;
% blocked_ii = find(blocked_);
%     sbz = rate(blocked_,:);
%     sba = rate(blocked_ii-1,:); sbb = rate(blocked_ii+1,:);
%     dark = he.vdata.spectra(blocked_ii-3,:);
%     toth_raw = he.vdata.spectra(blocked_ii-2,:);

    sbz = rate(blocked_ii,:);
    sba = rate(sideA_ii,:); 
    sbb = rate(sideB_ii,:);
    dark = rate(darks_ii,:);
    toth_raw = rate(hemisp_ii,:)-dark;
    pix = interp1(wl(1:1000), [1:1000],555,'nearest');
%  %this pixel is near the maximum solar brightness
for b = len:-1:1
    abz = [sba(b,pix),sbb(b,pix),sbz(b,pix)];
    [max_b,max_i] = sort(abz);
%     good_band(b) = abs(abz(1)-abz(2))<2.*sqrt(abz(1));% as tho photon counts, possion distr.  Not really true.
    abz = [sba(b,:);sbb(b,:);sbz(b,:)];    
    sb_avg(b,:) = mean([sba(b,:);sbb(b,:)]); 
    sb_min(b,:) = abz(max_i(1),:);
    sb_max(b,:) = abz(max_i(3),:);
end
% if size(sb_avg,1)>size(sbz,1)
%     sb_avg(size(sbz,1)+1:end,:)=[];
% elseif size(sbz,1)>size(sb_avg,1)
%     sbz(size(sb_avg,1)+1:end,:) = [];
% end

dirh_raw_old = sb_avg-sbz;
dirh_raw_new = sb_max-sb_min;
% dirh_raw_comb =  dirh_raw_old .* (double(good_band')*ones(size(wl))) + ...
%     dirh_raw_new .* (double(~good_band')*ones(size(wl)));
difh_raw_new = toth_raw - dirh_raw_new;
difh_raw_old = toth_raw - dirh_raw_old;
% difh_raw_comb = toth_raw - dirh_raw_comb;

he_dual = anc_sift(he, blocked_ii);
he_dual.ncdef.vars.time_LST=he_dual.ncdef.vars.time;
he_dual.vdata.time_LST =he_dual.vdata.time + double(he_dual.vdata.lon./15)./24;
LST = sprintf(' %1.2f',double(he_dual.vdata.lon./15));
he_dual.vatts.time_LST.long_name = [he_dual.vatts.time.long_name, ' LST'];
he_dual.vatts.time_LST.units = strrep(he_dual.vatts.time.units, ' 0:00', LST);

he_dual.ncdef.dims.wavelength.length = length(wl);
he_dual.vdata.wavelength = wl;
he_dual.vatts.wavelength.long_name = strrep(he_dual.vatts.wavelength.long_name, 'VIS ', '');

he_dual.ncdef.vars.integration_time_spectrometer_A = he_dual.ncdef.vars.integration_time;
he_dual.vdata.integration_time_spectrometer_A = he_dual.vdata.integration_time;
he_dual.vatts.integration_time_spectrometer_A = he_dual.vatts.integration_time; 
he_dual.vatts.integration_time_spectrometer_A.long_name = 'Integration time per scan for spectrometer A'; 
he_dual.vatts.integration_time_spectrometer_A.units = '1/ms'; 

he_dual.ncdef.vars.integration_time_spectrometer_B = he_dual.ncdef.vars.integration_time_spectrometer_A;
he_dual.vdata.integration_time_spectrometer_B = nir.vdata.integration_time(blocked_ii);
he_dual.vatts.integration_time_spectrometer_B = he_dual.vatts.integration_time_spectrometer_A; 
he_dual.vatts.integration_time_spectrometer_B.long_name = 'Integration time per scan for spectrometer B'; 
he_dual.vatts.integration_time_spectrometer_B.units = '1/ms'; 

he_dual.ncdef.vars.dark = he_dual.ncdef.vars.spectra;
he_dual.vdata.dark = dark';
he_dual.vatts.dark = he_dual.vatts.spectra; 
he_dual.vatts.dark.long_name = 'Spectrum of dark count rate'; 
he_dual.vatts.dark.units = '1/ms'; 

he_dual.ncdef.vars.th_raw = he_dual.ncdef.vars.spectra;
he_dual.vdata.th_raw = toth_raw';
he_dual.vatts.th_raw = he_dual.vatts.spectra; 
he_dual.vatts.th_raw.long_name = 'total hemisp. raw (no coscorr)'; 
he_dual.vatts.th_raw.units = '1/ms'; 

he_dual.ncdef.vars.sba = he_dual.ncdef.vars.spectra;
he_dual.vdata.sba = sba';
he_dual.vatts.sba = he_dual.vatts.spectra; 
he_dual.vatts.sba.long_name = 'shadowband A'; 
he_dual.vatts.sba.units = '1/ms'; 

he_dual.ncdef.vars.sbb = he_dual.ncdef.vars.spectra;
he_dual.vdata.sbb = sbb';
he_dual.vatts.sbb = he_dual.vatts.spectra; 
he_dual.vatts.sbb.long_name = 'shadowband B'; 
he_dual.vatts.sbb.units = '1/ms'; 

he_dual.ncdef.vars.sbz = he_dual.ncdef.vars.spectra;
he_dual.vdata.sbz = sbz';
he_dual.vatts.sbz = he_dual.vatts.spectra; 
he_dual.vatts.sbz.long_name = 'shadowband Zenith'; 
he_dual.vatts.sbz.units = '1/ms'; 

he_dual.ncdef.vars.sb_avg = he_dual.ncdef.vars.dark;
he_dual.vdata.sb_avg = sb_avg';
he_dual.vatts.sb_avg = he_dual.vatts.dark; 
he_dual.vatts.sb_avg.long_name = 'Average of shadowband A & B'; 
he_dual.vatts.sb_avg.units = '1/ms'; 

he_dual.ncdef.vars.sb_min = he_dual.ncdef.vars.spectra;
he_dual.vdata.sb_min = sb_min';
he_dual.vatts.sb_min = he_dual.vatts.spectra; 
he_dual.vatts.sb_min.long_name = 'Min shadowband measurement (blocked)'; 
he_dual.vatts.sb_min.units = '1/ms'; 

he_dual.ncdef.vars.sb_max = he_dual.ncdef.vars.spectra;
he_dual.vdata.sb_max = sb_max';
he_dual.vatts.sb_max = he_dual.vatts.spectra; 
he_dual.vatts.sb_max.long_name = 'Max shadowband measurement (exposed)'; 
he_dual.vatts.sb_max.units = '1/ms'; 

he_dual.ncdef.vars.dirh_raw_mfr = he_dual.ncdef.vars.spectra;
he_dual.vdata.dirh_raw_mfr = dirh_raw_old';
he_dual.vatts.dirh_raw_mfr = he_dual.vatts.spectra; 
he_dual.vatts.dirh_raw_mfr.long_name = 'direct horiz., raw, MFRSR method'; 
he_dual.vatts.dirh_raw_mfr.units = '1/ms'; 

he_dual.ncdef.vars.dirh_raw_fsb = he_dual.ncdef.vars.spectra;
he_dual.vdata.dirh_raw_fsb = dirh_raw_new';
he_dual.vatts.dirh_raw_fsb = he_dual.vatts.spectra; 
he_dual.vatts.dirh_raw_fsb.long_name = 'Direct horiz., raw, FSB max-min method'; 
he_dual.vatts.dirh_raw_fsb.units = '1/ms'; 

he_dual.ncdef.vars.difh_raw_mfr = he_dual.ncdef.vars.spectra;
he_dual.vdata.difh_raw_mfr = difh_raw_old';
he_dual.vatts.difh_raw_mfr = he_dual.vatts.spectra; 
he_dual.vatts.difh_raw_mfr.long_name = 'Diffuse hemisp., raw: th_raw - dirh_raw_mfr'; 
he_dual.vatts.difh_raw_mfr.units = '1/ms'; 

he_dual.ncdef.vars.difh_raw_fsb = he_dual.ncdef.vars.spectra;
he_dual.vdata.difh_raw_fsb = difh_raw_new';
he_dual.vatts.difh_raw_fsb = he_dual.vatts.spectra; 
he_dual.vatts.difh_raw_fsb.long_name = 'Diffuse hemisp., raw: th_raw - dirh_raw_fsb'; 
he_dual.vatts.difh_raw_fsb.units = '1/ms'; 

rfields = {'spectra','tag','band_az_raw','band_azimuth', 'inner_band_angle','inner_band_angle_raw', 'inner_band_scattering_angle'};
he_dual.ncdef.vars = rmfield(he_dual.ncdef.vars, rfields );
he_dual.vdata = rmfield(he_dual.vdata, rfields);
he_dual.vatts = rmfield(he_dual.vatts, rfields);

rfields = {'outer_band_angle_raw', 'outer_band_scattering_angle','integration_time', 'shutter_state','number_of_scans'};
he_dual.ncdef.vars = rmfield(he_dual.ncdef.vars, rfields );
he_dual.vdata = rmfield(he_dual.vdata, rfields);
he_dual.vatts = rmfield(he_dual.vatts, rfields);

rfields = {'outer_band_angle', 'clock_ticks','bench_temperature'};
he_dual.ncdef.vars = rmfield(he_dual.ncdef.vars, rfields );
he_dual.vdata = rmfield(he_dual.vdata, rfields);
he_dual.vatts = rmfield(he_dual.vatts, rfields);

he_dual = anc_check(he_dual);
% he_dual.difh_raw_comb = difh_raw_comb;
% pixel = interp1(he.vdata.wavelength, [1:length(he.vdata.wavelength)],[415,500,615,673,870],'nearest');
% figure; plot(he_dual.time,[ he_dual.dirh_raw_old(:,pixel(2)),he_dual.dirh_raw_new(:,pixel(2))],'-')
% legend('old','new') 
return
