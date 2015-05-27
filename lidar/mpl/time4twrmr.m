function [twrmr] = time4twrmr(time_in,filename);
%function [twrmr] = time4twrmr(time_in,filename);

ncid = ncmex('open', filename, 'write');

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);
Jd0 = serial2doy0(time);

% temp_02m = nc_getvar(ncid, 'temp_02m');
% twrmr.temp_02m = local_val(time_in, Jd0, temp_02m,.01);
% 
% temp_25m = nc_getvar(ncid, 'temp_25m');
% twrmr.temp_25m = local_val(time_in, Jd0, temp_25m,.01);

temp_60m = nc_getvar(ncid, 'temp_60m');
twrmr.temp_60m = local_val(time_in, Jd0, temp_60m,.01);

% pres_02m = nc_getvar(ncid, 'pres_02m');
% twrmr.pres_02m = local_val(time_in, Jd0, pres_02m,.01);
% 
% pres_25m = nc_getvar(ncid, 'pres_25m');
% twrmr.pres_25m = local_val(time_in, Jd0, pres_25m,.01);

pres_60m = nc_getvar(ncid, 'pres_60m');
twrmr.pres_60m = local_val(time_in, Jd0, pres_60m,.01);

% [twrmr.alpha_R_02m, twrmr.beta_R_02m] = ray_a_b(twrmr.temp_02m, twrmr.pres_02m);
% [twrmr.alpha_R_25m, twrmr.beta_R_25m] = ray_a_b(twrmr.temp_25m, twrmr.pres_25m);
[twrmr.alpha_R_60m, twrmr.beta_R_60m] = ray_a_b(twrmr.temp_60m, twrmr.pres_60m);

% rh_02m = nc_getvar(ncid, 'rh_02m');
% twrmr.rh_02m = local_val(time_in, Jd0, rh_02m,.01);
% 
% rh_25m = nc_getvar(ncid, 'rh_25m');
% twrmr.rh_25m = local_val(time_in, Jd0, rh_25m,.01);
% 
% rh_60m = nc_getvar(ncid, 'rh_60m');
% twrmr.rh_60m = local_val(time_in, Jd0, rh_60m,.01);

ncmex('close', ncid);