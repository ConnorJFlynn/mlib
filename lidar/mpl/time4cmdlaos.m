function [cmdlaos] = cmdlaos(time_in,filename);
%function [cmdlaos] = cmdlaos(time_in,filename);

ncid = ncmex('open', filename, 'write');

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);
Jd0 = serial2doy0(time);

Bbsp_G_1um_RefRH = nc_getvar(ncid, 'Bbsp_G_1um_RefRH');
goods = find(Bbsp_G_1um_RefRH > 0);
cmdlaos.Bbsp_G_1um_RefRH = local_val(time_in, Jd0(goods), Bbsp_G_1um_RefRH(goods),.01);

% Bbsp_G_10um_RefRH = nc_getvar(ncid, 'Bbsp_G_10um_RefRH');
% cmdlaos.Bbsp_G_10um_RefRH = local_val(time_in, Jd0, Bbsp_G_10um_RefRH,.01);
% 
% Bbsp_G_1um_WetRH = nc_getvar(ncid, 'Bbsp_G_1um_WetRH');
% cmdlaos.Bbsp_G_1um_WetRH = local_val(time_in, Jd0, Bbsp_G_1um_WetRH,.01);
% 
% Bbsp_G_10um_WetRH = nc_getvar(ncid, 'Bbsp_G_10um_WetRH');
% cmdlaos.Bbsp_G_10um_WetRH = local_val(time_in, Jd0, Bbsp_G_10um_WetRH,.01);
% 
% Bbsp_B_1um_RefRH = nc_getvar(ncid, 'Bbsp_B_1um_RefRH');
% cmdlaos.Bbsp_B_1um_RefRH = local_val(time_in, Jd0, Bbsp_B_1um_RefRH,.01);
% 
% % Bbsp_B_10um_RefRH = nc_getvar(ncid, 'Bbsp_B_10um_RefRH');
% % cmdlaos.Bbsp_B_10um_RefRH = local_val(time_in, Jd0, Bbsp_B_10um_RefRH,.01);
% 
% Bbsp_B_1um_WetRH = nc_getvar(ncid, 'Bbsp_B_1um_WetRH');
% cmdlaos.Bbsp_B_1um_WetRH = local_val(time_in, Jd0, Bbsp_B_1um_WetRH,.01);

% Bbsp_B_10um_WetRH = nc_getvar(ncid, 'Bbsp_B_10um_WetRH');
% cmdlaos.Bbsp_B_10um_WetRH = local_val(time_in, Jd0, Bbsp_B_10um_WetRH,.01);

ncmex('close', ncid);