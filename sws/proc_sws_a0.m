function sws = proc_sws_a0(sws,resp)

if ~isavar('sws')
   sws = anc_bundle_files;
end
sat_val = 32767;
      resp.lambda_nm = sws.vdata.wavelength; 
      resp.resp = ones(size(resp.lambda_nm));
rate = sws.vdata.spectra ./ (ones(size(sws.vdata.wavelength)) * sws.vdata.integration_time );
dark_out = sws_dark_rate(sws);
dark_rates = interp1(dark_out.time, dark_out.dark_rate, sws.time,'pchip','extrap')';

sig = rate - dark_rates;

% darks = sws.vdata.spectra(:,sws.vdata.shutter_state==0);
% 
% for pix = length(sws.vdata.wavelength):-1:1
%    darks(pix,:) = smooth(darks(pix,:),40);
%    dark(pix,:) = interp1(sws.time(sws.vdata.shutter_state==0),...
%       darks(pix,:),sws.time,'nearest','extrap');
% 
% %    dark(pix,:) = interp1(sws.time(sws.vdata.shutter_state==0),...
% %       sws.vdata.spectra(pix,sws.vdata.shutter_state==0),sws.time,'nearest','extrap');
% 
% end
% 
% % Mask out saturated value, set to NaN
% rate = (sws.vdata.spectra - dark)./(ones(size(sws.vdata.wavelength))*sws.vdata.integration_time);
sat = double(sws.vdata.spectra == sat_val);
sat(sat==1) = NaN;
if mean(sws.vdata.wavelength)<1000
   vis = true;
else
   vis = false;
end

if ~isavar('resp')
if mean(sws.vdata.wavelength)<1000
   vis = true;
   resp_fname = (getfullname('*sws*resp_func*.si.*.dat', 'sws_resp'));
   try
      resp = load(resp_fname); lambda_nm = resp(:,1); resp_ = resp(:,2); clear resp
      resp.lambda_nm = lambda_nm; clear lambda_nm
      resp.resp = resp_; clear resp_
   catch
      resp = rd_sasze_resp_file(resp_fname);
   end
else
   vis = false;
   resp_fname = (getfullname('*sws*resp_func*.ir.*.dat', 'sws_resp'));
   try
      resp = load(resp_fname); lambda_nm = resp(:,1); resp_ = resp(:,2); clear resp
      resp.lambda_nm = lambda_nm; clear lambda_nm
      resp.resp = resp_; clear resp_
   catch
      resp = rd_sasze_resp_file(resp_fname);
   end
end
end

if vis 
   spectrometer = 'Si';
else
   spectrometer = 'InGaAs';
end

sws.ncdef.vars.responsivity = sws.ncdef.vars.wavelength;
sws.vdata.responsivity = sws.vdata.wavelength; sws.vdata.responsivity = single(resp.resp);
sws.vatts.responsivity = sws.vatts.wavelength; 
sws.vatts.responsivity.long_name = [spectrometer, ' spectral responsivity'];
sws.vatts.responsivity.units = ['counts / [mW/m^2/sr/nm]'];

sws.ncdef.vars.zen_rad = sws.ncdef.vars.spectra;
sws.vdata.zen_rad = sat + sig ./ (resp.resp*ones([1,length(sws.time)]));
sws.vatts.zen_rad = sws.vatts.spectra;
sws.vatts.zen_rad.long_name = 'zenith radiance';
sws.vatts.zen_rad.units = 'mW/m^2/sr/nm';

% Mask out zenith radiance when shutter is closed
shut = sws.vdata.shutter_state==0; mask = zeros(size(shut)); mask(shut) = NaN;
sws.vdata.zen_rad = sws.vdata.zen_rad + ones(size(sws.vdata.wavelength)) * mask;
not_shut_ii = find(~shut);

guey = load('guey.mat'); guey = guey.guey; 
sws.ncdef.vars.esr_gueymard = sws.ncdef.vars.wavelength;
sws.vdata.esr_gueymard = 1000.*interp1(guey(:,1), guey(:,3), sws.vdata.wavelength,'linear');
sws.vatts.esr_gueymard = sws.vatts.zen_rad; 
sws.vatts.esr_gueymard.long_name = 'Gueymard Extra-Terrestrial Solar Irradiance';
sws.vatts.esr_gueymard.units = 'mW/m^2/nm';

[sza, ~, soldst] = sunae(sws.vdata.lat.*ones(size(sws.time)), sws.vdata.lon.*ones(size(sws.time)), sws.time);
soldst = mean(soldst);
sws.ncdef.vars.zen_Tr = sws.ncdef.vars.zen_rad;
sws.ncdef.vars.zen_Tr.atts.comment = sws.ncdef.vars.zen_Tr.atts.units;
sws.ncdef.vars.zen_Tr.atts.calculation = sws.ncdef.vars.zen_Tr.atts.units;
sws.ncdef.vars.zen_Tr.atts = init_ids(sws.ncdef.vars.zen_Tr.atts);
sza_ = ones(size(sza)); sza_(sza>=89) = NaN;
sws.vdata.zen_Tr = (pi.*sws.vdata.zen_rad.*soldst.^2) ./ (sws.vdata.esr_gueymard * cosd(sza.*sza_));
sws.vatts.zen_Tr = sws.vatts.zen_rad; 
sws.vatts.zen_Tr.long_name = 'Zenith transmittance';
sws.vatts.zen_Tr.units = 'unitless';
sws.vatts.zen_Tr.comment = 'Assumes isotropic scattering';
sws.vatts.zen_Tr.calculation = '(zen_rad*soldst^2*pi) / (esr_gueymard * cos(sza));';

figure_(10); plot(sws.vdata.wavelength,  sws.vdata.zen_rad(:,not_shut_ii(1:round(length(not_shut_ii)./20):end)), '-')
if mean(sws.vdata.wavelength)<1000
   wl = round(interp1(sws.vdata.wavelength, [1:length(sws.vdata.wavelength)],[440, 500,670,870,1020],'nearest'));
   figure_(20); plot(sws.time(not_shut_ii), sws.vdata.zen_rad(wl,not_shut_ii),'-'); dynamicDateTicks;
   title('SWS zen rad'); legend('440','500','670','870','1020');
   figure_(21); plot(sws.time(not_shut_ii), sws.vdata.zen_Tr(wl,not_shut_ii),'-'); dynamicDateTicks;
   title('SWS zen Tr'); legend('440','500','670','870','1020');
   for ns = length(not_shut_ii):-1:1
      ns_ii = not_shut_ii(ns);
      P(ns,:) = polyfit(log(sws.vdata.wavelength(wl(1:end-1))), log(sws.vdata.zen_Tr(wl(1:end-1),ns_ii)),2);
      dP(ns,:) = real([2.*P(ns,1), P(ns,2)]);
      ddP(ns) = dP(ns,1);
      sws_ang(ns,:) = -polyval(dP(ns,:),log(sws.vdata.wavelength(wl(1:end-1))))';           
   end
   figure_(22); plot(sws.time(not_shut_ii), ddP,'k-',sws.time(not_shut_ii), sws_ang,'-'); dynamicDateTicks;
   title('SWS zen Ang'); legend('440','500','670','870','1020', 'curve');  
   
else
   wl = round(interp1(sws.vdata.wavelength, [1:length(sws.vdata.wavelength)],[1020,1640],'nearest'));
   figure_(30); ax = gca; ax.ColorOrderIndex = 5; hold('on'); 
   plot(sws.time(not_shut_ii), sws.vdata.zen_rad(wl,not_shut_ii),'-'); dynamicDateTicks;
   title('SWS zen rad'); legend('1020','1640'); hold('off')
  figure_(31); ax = gca; ax.ColorOrderIndex = 5; hold('on'); 
   plot(sws.time(not_shut_ii), sws.vdata.zen_Tr(wl,not_shut_ii),'-'); dynamicDateTicks;
   title('SWS zen Tr'); legend('1020','1640'); hold('off');  
end
sws = anc_sift(sws, sws.vdata.shutter_state==1);
sws.ncdef.vars = rmfield(sws.ncdef.vars, 'spectra');
sws.vdata = rmfield(sws.vdata, 'spectra');
sws.vatts = rmfield(sws.vatts, 'spectra');

sws.ncdef.vars = rmfield(sws.ncdef.vars, 'shutter_state');
sws.vdata = rmfield(sws.vdata, 'shutter_state');
sws.vatts = rmfield(sws.vatts, 'shutter_state');

sws.ncdef.vars = rmfield(sws.ncdef.vars, 'integration_time');
sws.vdata = rmfield(sws.vdata, 'integration_time');
sws.vatts = rmfield(sws.vatts, 'integration_time');

sws = anc_check(sws);
if foundstr(sws.fname, 'swsvisC1.a0.')
   sws.fname = strrep(sws.fname,'swsvisC1.a0.','swsvisradC1.a1.');
elseif foundstr(sws.fname, 'swsnirC1.a0.')
   sws.fname = strrep(sws.fname,'swsnirC1.a0.','swsnirradC1.a1.');
else
   error('Problem with sws filename, not vis or nir...')
end
sws.clobber = true;
anc_save(sws);
return