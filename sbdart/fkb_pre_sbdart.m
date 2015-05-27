% Get mfrC1 mat file
%%

mwr_path = ['F:\case_studies\fkb\fkb_mwr_various\'];
beflux_path  = ['F:\case_studies\fkb\fkbqcrad1longM1.s1\'];
sbdart_path = ['F:\case_studies\fkb\sbdart\'];
% Define time subset
disp(['Load the mfr file.'])
mfr_all = ancload(['F:\case_studies\fkb\fkbmfrsraod1flynnM1.c0\screened\all_screened\fkbmfrsraod1michM1.c1.20070421.055540.nc'])
% [fname, pname] = uigetfile(['C:\case_studies\Alive\data\*.mat'])
% load([pname, fname])
anet2 = read_cimel_aod;
%%
figure; plot(serial2doy(mfr_all.time), [mfr_all.vars.aerosol_optical_depth_filter2.data],'k.', serial2doy(anet2.time), anet2.AOT_500,'r.');
zoom('on');
%%
xl = xlim;
subx = serial2doy(mfr_all.time)>xl(1) & serial2doy(mfr_all.time)<xl(2);
dayx = mean(mfr_all.time(subx));
date_string = datestr(dayx,'yyyymmdd');
%%
mwr_list = dir([mwr_path, 'fkbmwrp*', date_string, '*.cdf']);
%%
if length(mwr_list)>=0
    mwr = ancload([mwr_path, mwr_list(1).name]);
else
    disp('No MWR file found!');
    return
end
mwrx = serial2doy(mwr.time)>xl(1) & serial2doy(mwr.time)<xl(2);
%%
flux_list = dir([beflux_path, '*', date_string, '*.cdf']);
if length(flux_list)>=0
    beflux = ancload([beflux_path, flux_list(1).name]);
else
    disp('No BE_flux file found!');
    return
end
%%
swx = serial2doy(beflux.time)>xl(1) & serial2doy(beflux.time)<xl(2);
%%
solfac = .9866;
pres = 96;
o3 = 275;
cos_sol_zen = 1./mean(mfr_all.vars.airmass.data(subx));
water_vap = mean(mwr.vars.totalPrecipitableWater.data(mwrx));
mean_ang = -1*mean(mfr_all.vars.angstrom_exponent.data(subx));
taus = [mfr_all.vars.aerosol_optical_depth_filter1.data(subx);...
   mfr_all.vars.aerosol_optical_depth_filter2.data(subx);...
   mfr_all.vars.aerosol_optical_depth_filter3.data(subx);...
   mfr_all.vars.aerosol_optical_depth_filter4.data(subx);...
   mfr_all.vars.aerosol_optical_depth_filter5.data(subx)];
mean_taus = mean(taus,2);
down_sw_direct = mean(beflux.vars.short_direct_normal.data(swx).* cos(pi*beflux.vars.zenith.data(swx)/180));
down_sw_dirnorm = mean(beflux.vars.short_direct_normal.data(swx));
%%

fid = fopen([sbdart_path, 'INPUT'],'wt');
y = (['$INPUT']);
fprintf(fid,'%s \n',y);
y = (['IDATM = 2']);
fprintf(fid,'%s \n',y);
y = (['ISAT = 0']);
fprintf(fid,'%s \n',y);
y = (['NSTR = 4']);
fprintf(fid,'%s \n',y);
y = (['WLINF = 0.3']);
fprintf(fid,'%s \n',y);
fprintf(fid,'%s \n',y);
y = (['WLSUP = 3.3']);
fprintf(fid,'%s \n',y);
y = (['WLINC = 0.025']);
fprintf(fid,'%s \n',y);

y = (['PBAR = ',num2str(pres)]);
fprintf(fid,'%s \n',y);
y = (['UO3 = ',num2str(o3/1000)]);
fprintf(fid,'%s \n',y);
y = (['SOLFAC = ',num2str(solfac)]);
fprintf(fid,'%s \n',y);
y = (['CSZA = ',num2str(cos_sol_zen)]);
fprintf(fid,'%s \n',y);
y = (['UW = ',num2str(water_vap)]);
fprintf(fid,'%s \n',y);
y = (['IAER = 5']);
fprintf(fid,'%s \n',y);
y = (['ABAER = ',num2str(mean_ang)]);
fprintf(fid,'%s \n',y);
y = (['WLBAER = ',num2str([415,500,615,673,870]./1000)]);
fprintf(fid,'%s \n',y);
y = (['QBAER = ',num2str(mean_taus')]);
fprintf(fid,'%s \n',y);
y = (['WBAER = 0.89, 0.89, 0.89, 0.89, 0.89']);
fprintf(fid,'%s \n',y);
y = (['GBAER = 0.63, 0.63, 0.63, 0.63, 0.63']);
fprintf(fid,'%s \n',y);
y = (['IDB = 20*0']);
fprintf(fid,'%s \n',y);
y = (['IOUT = 10']);
fprintf(fid,'%s \n',y);
y = (['$END']);
fprintf(fid,'%s \n',y);
fclose(fid);
%%
[WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR] = ...
sbdart('iout',10,'idatm',3,'isat', 0, 'nf',1,'nstr' ,  4 ,'wlinf' ,  0.25 , ...
'wlsup' ,  20 , 'wlinc' ,  -0.01 ,'pbar' , 960 , 'uo3' ,  0.275,...
'solfac' ,  0.9866 , 'CSZA' ,  0.34405 ,'uw' ,  0.95053 , ...
'iaer' ,  5 , 'ABAER' , 1,...
'wlbaer' ,  [0.5 ],...
'qbaer' ,  [0.0075] ,...
'wbaer' ,  [0.89] ,...
'gbaer' ,  [0.63],...
'idb', zeros([20,1]));
disp(['SW direct from NIP:' num2str(down_sw_direct)])
disp(['SW Direct from SBDART: ',num2str(BOTDIR)]);
disp(['Model - measured = ', num2str(BOTDIR-down_sw_direct)]);
%%
% Assess AOD:

% Step through good Langley days...
% For each passing day, load the langplot and see how it looks.
% Show Langplots and time series of AOD over the day.
% Select a short time range (~1 hr or less) from which to generate an
% angstrom spectra plotting log(wl) vs log(mean(aod)), should be nearly
% straight line. 

% For same time, get WV and NIP, take average of Non-missing in this time.
% If empty, then interpolate to get value for this time.

ang_fit = -1*P(1);
wlbaer = [415, 500, 615,673,870]./1000;
qbaer = mean(aot(:,tsub));
pres_mB =0;
uo3_db_by_1000 = 0;
soldst =  mfr.vars.sun_to_earth_distance.data;
csza = mean(mfr.vars.cosine_solar_zenith_angle.data);
uw_cm = pwv;

[WLINF,WLSUP,FFEW,TOPDN,TOPUP,TOPDIR,BOTDN,BOTUP,BOTDIR] = ...
sbdart('iout',10,'idatm',3,'isat', 0, 'nf',1,'nstr' ,  4 ,'wlinf' ,  0.3 , ...
'wlsup' ,  5 , 'wlinc' ,  0.025 ,'pbar' , pres_mB , 'uo3' ,  uo3_db_by_1000,...
'solfac' , soldst , 'CSZA' ,  csza ,'uw' ,  uw_cm , ...
'iaer' ,  5 , 'ABAER' ,ang_fit  ,...
'wlbaer' ,  [0.5 ],...
'qbaer' ,  [0.0075] ,...
'wbaer' ,  [0.89] ,...
'gbaer' ,  [0.63],...
'idb', zeros([20,1]));
disp(['SW direct from NIP:' num2str(down_sw_direct)])
disp(['SW Direct from SBDART: ',num2str(BOTDIR)]);
disp(['Model - measured = ', num2str(BOTDIR-down_sw_direct)]);