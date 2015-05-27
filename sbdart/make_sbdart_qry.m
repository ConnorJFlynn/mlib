function [qry,qry_cell] = make_sbdart_qry(in,paths);
% in.time
% sbdart_in.time
% sbdart_in.wlinf % wl lower limit 0.25 um
% sbdart_in.wlsup %wl upper limit 3 or 5 um for NIP
% sbdart_in.wlinc %wavelength resolution -.01 log spacing starting at 10 nm
% sbdart_in.pbar % pressure in mB
% sbdart_in.uo3 % ozone cm
% sbdart_in.solfac % earth-sun AU
% sbdart_in.CSZA % cosine solar zenith angle
% sbdart_in.uw % water vapor in cm
% sbdart_in.iaer %user-specified boundary layer aerosol
% sbdart_in.abaer % Angstrom exponent, positive normally
% sbdart_in.wlbaer % wavelengths for aod
% sbdart_in.qbaer % aod
% sbdart_in.wbaer % ssa ~.9
% sbdart_in.gbaer % asymmetry parameter g ~0.63
% sbdart_in.idb % zeros([20,1]));
if ~isfield(in,'time')||~isfield(in,'wlbaer')...
      ||~isfield(in,'qbaer')||~isfield(in,'csza')
   error('The fields "time", "wlbaer" (wavelength um), "qbaer" (aot) are all required.')
end
if exist('paths','var')&&~isempty(paths)
   if ~isfield(in,'paths')
      in.paths = paths;
   else
      field = fieldnames(paths);
      for ff = 1:length(field)
         in.paths.(field{ff}) = paths.(field{ff});
      end
   end
end
qry.iout = 10;
qry.idatm = 3;
qry.isat = 0;
qry.nf = 1;
qry.nstr = 4;
% qry.idb= zeros([20,1]);
qry.wlbaer = in.wlbaer;
qry.qbaer = in.qbaer;
qry.solfac = in.solfac;
NaNs = isNaN(in.wlbaer)|isNaN(in.qbaer);
P = polyfit(log(in.wlbaer(~NaNs)), log(in.qbaer(~NaNs)), 1);
qry.abaer = -1*P(1);
if isNaN(qry.abaer)||~isfinite(qry.abaer)||(qry.abaer<-4)
   qry.abaer = 1;
end
qry.csza = in.csza;
% [x.zen, x.az, qry.solfac, x.ha, x.dec, x.el, x.am] = sunae(in.lat, in.lon, in.time);
%  qry.CSZA = cos(x.zen*pi/180);
if isfield(in,'wlinf')
   qry.wlinf = in.wlinf;
else
   qry.wlinf = .25;
end
if isfield(in,'wlsup')
   qry.wlsup = in.wlsup;
else
   qry.wlsup = 3; % or 5
end
if isfield(in,'wlinc')
   qry.wlinc = in.wlinc;
else
   qry.wlinc = -.01; %log scale starting with 10nm space
end
qry.iaer  =5;

%Get surface pressure
if isfield(in,'pbar')
   qry.pbar = in.pbar;
else
   qry.pbar = get_sbdart_aux_data(in.time, in.paths.pbar.path, in.paths.pbar.field);
end
if (qry.pbar<=0)||isNaN(qry.pbar)
   qry.pbar = 1013;
elseif qry.pbar <500
   %convert from kPa to hPa/mBarr
   qry.pbar = qry.pbar * 10;
end

%Get water vapor
if isfield(in,'uw')
   qry.uw = in.uw;
else
   qry.uw = get_sbdart_aux_data(in.time, in.paths.uw.path, in.paths.uw.field);
end

% Get ozone
qry.uo3 = get_sbdart_aux_data(in.time, in.paths.uo3.path, in.paths.uo3.field);
if qry.uo3>10 %probaby in DU so convert to cm
   qry.uo3 = qry.uo3./1000;
end
if (qry.uo3<=0)||isNaN(qry.uo3)
   qry.uo3 = .3;
end
if ~isfield(in,'wbaer')
   qry.wbaer = .89 * ones(size(in.wlbaer));
end
if ~isfield(in,'gbaer')
   qry.gbaer = 0.63 * ones(size(in.wlbaer));
end

% Now pack these fields and values into a single linear array of cells

fields = fieldnames(qry);
for ff = 1:length(fields)
   qry_cell(2*ff -1) = fields(ff);
   qry_cell(2*ff) = {qry.(fields{ff})};
end

% sbdart_in.uo3 % ozone cm
% sbdart_in.solfac % earth-sun AU
% sbdart_in.CSZA % cosine solar zenith angle
% sbdart_in.uw % water vapor in cm