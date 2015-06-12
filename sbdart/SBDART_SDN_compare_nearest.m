function matched = SBDART_SDN_compare_nearest(paths);
% SBDART_SDN_compare_nearest(paths);
% This function loads collocated MFRSR (or NIMFR) and AERONET AOD sets
% identifies nearest matching points, draws together supporting atmospheric
% data (atmos pressure, water vapor, ozone, cosine solar zenith angle) computes
% the SW direct flux and compares to NIP (as short_direct_norm * csza)

% We'll need:
% sbdart_in.time
% sbdart_in.wlinf % wl lower limit 0.25 um
% sbdart_in.wlsup %wl upper limit 3 or 5 um for NIP
% sbdart_in.wlinc %wavelength resolution -.01 log spacing starting at 10 nm
% sbdart_in.pbar % pressure in mB
% sbdart_in.uo3 % ozone cm
% sbdart_in.solfac % earth-sun AU
% sbdart_in.CSZA % cosine solar zenith angle
% sbdart_in.uw % water vapor in cm
% sbdart_in.iaer %specified boundary layer aerosol
% sbdart_in.abaer % Angstrom exponent, positive normally
% sbdart_in.wlbaer % wavelengths for aod
% sbdart_in.qbaer % aod
% sbdart_in.wbaer % ssa ~.9
% sbdart_in.gbaer % asymmetry parameter g ~0.63
% sbdart_in.idb % zeros([20,1]));

% Steps for comparisons...
% Plot time series of screened/corrected MFRSR AOD and Aeronet AOD
% Zoom into desired times
% For a selected time region, compute mean values of time, MFRSR AOD and
% Cimel AOD
% Collect ancilliary data:
% Get dirlist of available files for pressure, watervap, SW dirnor
% For available files, use anccat to get them all.
% Then fill in NaNs for the specified field.
% Then compute temporal average or if empty average interpolate or flag as
% error

%Then call SBDART for MFRSR and for Cimel reporting residual with NIP
% Instead of the default below it might be better to query for the
% directory paths for each component. 
if ~exist('paths','var')||isempty(paths)
   paths.pbar.path = ['F:\case_studies\fkb\fkbmetM1.b1\initial\'];
   paths.pbar.field = ['atmos_pressure'];
   paths.uw.path = ['F:\case_studies\fkb\fkb_mwr_various\mwr\'];
   paths.uw.field = ['vap'];
   paths.uo3.path = ['F:\case_studies\fkb\fbkomiX1.a1\final\'];
   paths.uo3.field = ['ozone'];
   paths.rad.path = ['F:\case_studies\fkb\fkbqcrad1longM1.s1\initial\'];
   paths.rad.field = ['short_direct_normal'];
   paths.match.path = ['F:\case_studies\fkb\'];
   paths.match.fname = ['mfr_anet_match.mat'];
   
else
   if ~isfield(paths,'pbar')
      paths.pbar.path = ['F:\case_studies\fkb\fkbmetM1.b1\initial\'];
      paths.pbar.field = ['atmos_pressure'];
   end
   if ~isfield(paths,'uw')
      paths.uw.path = ['F:\case_studies\fkb\fkb_mwr_various\mwr\'];
      paths.uw.field = ['vap'];
   end
   if ~isfield(paths,'uo3')
      paths.uo3.path = ['F:\case_studies\fkb\fbkomiX1.a1\final\'];
      paths.uo3.field = ['ozone'];
   end   
   if ~isfield(paths,'rad')
      paths.rad.path = ['F:\case_studies\fkb\fkbqcrad1longM1.s1\initial\'];
      paths.rad.field = ['short_direct_normal'];
   end
   if ~isfield(paths,'match')
         paths.match.path = ['F:\case_studies\fkb\'];
         paths.match.fname = ['mfr_anet_match.mat'];
   end
end

if ~exist(paths.pbar.path,'dir')
   paths.pbar.path =  getdir('pbar',['Select a directory containing netcdf files with ',paths.pbar.field]);
end
if ~exist(paths.uw.path,'dir')
   paths.uw.path = getdir('uw',['Select a directory containing netcdf files with ',paths.uw.field]);
end
if ~exist(paths.uo3.path,'dir')
   paths.uo3.path = getdir('uo3',['Select a directory containing netcdf files with ',paths.uo3.field]);
end
if ~exist(paths.rad.path,'dir')
   paths.rad.path = getdir('rad',['Select a directory containing netcdf files with ',paths.rad.field]);
end
if ~exist(paths.match.path,'dir')
   paths.match.path = getdir('match',['Select a directory to save the comparisons.']);
end

%%
% mfr = ancload;
mfr = loadinto; %Load cloud-screened corrected aod file.
anet = read_cimel_aod; %Read Cimel AOD file.
nearby = (1./(24*4));
[ainb, bina] = nearest(mfr.time, anet.time,nearby); % find nearest within 15 minutes

for ii = length(ainb):-1:1
   mean_time = mean(mfr.time(ainb(ii)));
   mfr_avg.time = [mean_time-nearby, mean_time+nearby];
   mfr_t = find((mfr.time>=mfr_avg.time(1))&(mfr.time<=mfr_avg.time(2)));
   mean_time = mean(anet.time(bina(ii)));
   anet_avg.time = mean_time + (nearby.*[-1, 1]);
   anet_t = find((anet.time>=anet_avg.time(1))&(anet.time<=anet_avg.time(2)));
   %%
   
   mfr_avg.lat = mfr.vars.lat.data;
   mfr_avg.lon = mfr.vars.lon.data;
   if exist('x','var')
      clear('x')
   end
   [x.sza, x.az, x.solfac, x.ha, x.dec, x.el, x.airmass] = sunae(mfr_avg.lat, mfr_avg.lon, mean(mfr_avg.time));
   mfr_avg.sza=x.sza;
   mfr_avg.az=x.az;
   mfr_avg.solfac=x.solfac;
   mfr_avg.airmass=x.airmass;
   mfr_avg.csza = cos(mfr_avg.sza*pi/180);
   mfr_avg.wlbaer = [415,500,615,676,870]./1000;
   mfr_avg.qbaer = [(mfr.vars.aerosol_optical_depth_filter1.data(mfr_t))', ...
      (mfr.vars.aerosol_optical_depth_filter2.data(mfr_t))', ...
      (mfr.vars.aerosol_optical_depth_filter3.data(mfr_t))', ...
      (mfr.vars.aerosol_optical_depth_filter4.data(mfr_t))', ...
      (mfr.vars.aerosol_optical_depth_filter5.data(mfr_t))'];
   NaNs = isNaN(mfr_avg.qbaer)|~isfinite(mfr_avg.qbaer)|(mfr_avg.qbaer<0);
   mfr_avg.qbaer(NaNs) = NaN;
   mfr_avg.qbaer = downsample(mfr_avg.qbaer,length(mfr_t),1);
   
   NaNs = isNaN(mfr.vars.angstrom_exponent.data(mfr_t))...
      |~isfinite(mfr.vars.angstrom_exponent.data(mfr_t))...
      |(mfr.vars.angstrom_exponent.data(mfr_t)<-1);
   mfr_avg.abaer = mean(mfr.vars.angstrom_exponent.data(~NaNs));
   P = polyfit(log(mfr_avg.wlbaer),log(mfr_avg.qbaer),1);
   mfr_avg.abaer = -1*P(1);
   %
   mfr_avg.uo3 = mfr.vars.Ozone_column_amount.data/1000;
   mfr_avg.uo3 = get_sbdart_aux_data(mfr_avg.time, paths.uo3.path, paths.uo3.field);
   if mfr_avg.uo3<=0
      mfr_avg.uo3 = .3;
   end
   mfr_avg.solfac = mfr.vars.sun_to_earth_distance.data;
   mfr_avg.solfac = x.solfac;
   mfr_avg.uw = get_sbdart_aux_data(mfr_avg.time, paths.uw.path, paths.uw.field);
   mfr_avg.pbar = mfr.vars.surface_pressure.data;
   mfr_avg.pbar = get_sbdart_aux_data(mfr_avg.time, paths.pbar.path, paths.pbar.field);
   if (mfr_avg.pbar>0)&&(mfr_avg.pbar<500) %then probably in kPa, convert to hPa==mBarr
      mfr_avg.pbar = mfr_avg.pbar * 10;
   end
   %%
   anet_avg.lat = anet.lat;
   anet_avg.lon = anet.lon;
   if exist('x','var')
      clear('x')
   end
   [x.sza, x.az, x.solfac, x.ha, x.dec, x.el, x.airmass] = sunae(anet.lat, anet.lon, mean(anet_avg.time));
   anet_avg.sza=x.sza;
   anet_avg.az=x.az;
   anet_avg.solfac=x.solfac;
   anet_avg.airmass=x.airmass;
   
   anet_avg.csza = cos(anet_avg.sza*pi/180);
   anet_avg.wlbaer = [1640,1020,870,675,500,440,380,340]./1000;
   anet_avg.wlbaer = fliplr(anet_avg.wlbaer);
   anet_avg.qbaer = [(anet.AOT_1640(anet_t)), ...
      (anet.AOT_1020(anet_t)), ...
      (anet.AOT_870(anet_t)), ...
      (anet.AOT_675(anet_t)), ...
      (anet.AOT_500(anet_t)), ...
      (anet.AOT_440(anet_t)), ...
      (anet.AOT_380(anet_t)), ...
      (anet.AOT_340(anet_t))];
   
   NaNs = isNaN(anet_avg.qbaer)|~isfinite(anet_avg.qbaer)|(anet_avg.qbaer<0);
   anet_avg.qbaer(NaNs) = NaN;
   anet_avg.qbaer = downsample(anet_avg.qbaer,length(anet_t),1);
   anet_avg.qbaer = fliplr(anet_avg.qbaer);
   
   NaNs = isNaN(anet.Angstrom_500_870(anet_t))|~isfinite(anet.Angstrom_500_870(anet_t))...
      |(anet.Angstrom_500_870(anet_t)<-1);
   anet_avg.abaer = mean(anet.Angstrom_500_870(~NaNs));
   P = polyfit(log(anet_avg.wlbaer), log(anet_avg.qbaer),1);
   anet_avg.abaer = -1.*P(1);
   anet_avg.uw = mean(anet.Water_cm_(anet_t));
   anet_avg.uw = get_sbdart_aux_data(anet_avg.time, paths.uw.path, paths.uw.field);
   
   % %%
   % figure; plot(serial2doy(anet.time(anet_avg.t)), [anet.AOT_1640(anet_avg.t), ...
   %    anet.AOT_1020(anet_avg.t), anet.AOT_870(anet_avg.t), anet.AOT_675(anet_avg.t), ...
   %    anet.AOT_500(anet_avg.t), anet.AOT_440(anet_avg.t), anet.AOT_380(anet_avg.t), ...
   %    anet.AOT_340(anet_avg.t)],'o');
   % legend('1640'1020','870','675','500','440','380','340')
   % %%
   % figure; scatter(log10(anet_avg.wlbaer),log10(mean([anet.AOT_1640(anet_avg.t), ...
   %    anet.AOT_1020(anet_avg.t), anet.AOT_870(anet_avg.t), anet.AOT_675(anet_avg.t), ...
   %    anet.AOT_500(anet_avg.t), anet.AOT_440(anet_avg.t), anet.AOT_380(anet_avg.t), ...
   %    anet.AOT_340(anet_avg.t)])),25,log10(anet_avg.wlbaer),'filled')
   
   
   down_sw_dirnorm = get_sbdart_aux_data(mfr_avg.time, paths.rad.path, paths.rad.field);
   down_sw_direct =  down_sw_dirnorm .* mfr_avg.csza;
   matched.mfr_avg(ii) = mfr_avg;
   matched.anet_avg(ii) = anet_avg;
   matched.down_sw_dirnorm(ii) = down_sw_dirnorm;
   matched.csza(ii) = mfr_avg.csza;
   matched.down_sw_direct(ii) = down_sw_direct;
   %%
   
   %%
   mfr_qry = make_sbdart_qry(mfr_avg, paths);
   anet_qry = make_sbdart_qry(anet_avg,paths);
   
   matched.mfr_qry(ii) = mfr_qry ;
   matched.anet_qry(ii) = anet_qry;
   
   %The send_sbdart_qry calls could be replaced with a call to a local
   %SBDART executable by parsing the query to generate an input file and
   %then parsing the resulting output.  
   try
      mfr_reply = send_sbdart_qry(mfr_qry);
   catch
      mfr_qry;
   end
   %%
   try
      anet_reply = send_sbdart_qry(anet_qry);
   catch
      anet_qry;
   end
   matched.mfr_reply(ii) = mfr_reply;
   matched.anet_reply(ii) = anet_reply;
   matched.mfr_minus_nip(ii) = mfr_reply.botdir-down_sw_direct;
   matched.anet_minus_nip(ii) = anet_reply.botdir-down_sw_direct;
   matched.mfr_minus_anet(ii) = mfr_reply.botdir - anet_reply.botdir;
   
   
   disp(['Comparison for match point #',num2str(ii),datestr(mean(mfr_avg.time),', mmm dd yyyy HH:MM')]);
   disp([sprintf('Solar zenith angle = %2.1f deg, ',mfr_avg.sza)])
   disp([sprintf('cos(sza) = %02.2f ',mfr_avg.csza)])
   disp(['SW direct from NIP:' num2str(down_sw_direct)])
   disp(['SW Direct from SBDART with MFRSR AODs: ',num2str(mfr_reply.botdir)]);
   disp(['SW Direct from SBDART with AERONET: ',num2str(anet_reply.botdir)]);
   disp(['MFRSR_SBDART - AERONET_SBDART = ', num2str(mfr_reply.botdir-anet_reply.botdir)]);
   disp(['MFRSR_SBDART - NIP = ', num2str(mfr_reply.botdir-down_sw_direct)]);
   disp(['AERONET_SBDART - NIP = ', num2str(anet_reply.botdir-down_sw_direct)]);

   disp(['Saving intermediate results in ',paths.match.path,paths.match.fname]);
   save([paths.match.path,paths.match.fname],'matched');
end
disp('All done!')
return

