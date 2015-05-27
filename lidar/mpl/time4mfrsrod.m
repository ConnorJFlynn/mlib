function [mfrsrod] = time4mfrsrod(time_in,filename);
%function [mfrsrod] = time4mfrsrod(time_in,filename);

ncid = ncmex('open', filename, 'write');

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);
Jd0 = serial2doy0(time);

tod_500 = nc_getvar(ncid, 'total_optical_depth_filter2');
mfrsrod.tod_500 = local_val(time_in, Jd0, tod_500,.01);

aod_500 = nc_getvar(ncid, 'aerosol_optical_depth_filter2');
mfrsrod.aod_500 = local_val(time_in, Jd0, aod_500,.01);

angstrom = nc_getvar(ncid, 'angstrom_exponent');
mfrsrod.angstrom = local_val(time_in, Jd0, angstrom,.01);

mfrsrod.aod_523 = mfrsrod.aod_500 .* ((500/532).^(mfrsrod.angstrom));

ncmex('close', ncid);