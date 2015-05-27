function [lidar] = mplnor_acid_test;
%This function puts mplnor data to the acid test of comparison with Rayleigh.
%[lidar] = mplnor_acid_test;
[cdfid, fname, pname] = get_ncid;
mplnor.fname = fname;
mplnor.time = nc_time(cdfid);
mplnor.jd0 = serial2doy(mplnor.time);
%mplnor.jd0 = nc_getvar(cdfid, 'julian_day');
mplnor.backscatter = nc_getvar(cdfid, 'backscatter');
mplnor.range = nc_getvar(cdfid, 'height');
%mplnor.range = nc_getvar(cdfid, 'range');
mplnor.plotrange = find((mplnor.range>.075)&(mplnor.range<16));
figure; image(mplnor.jd0,mplnor.range(mplnor.plotrange), 200*mplnor.backscatter(mplnor.plotrange,:)); axis('xy'); colormap('jet');  zoom
title(['MPLnor data for ' mplnor.fname(1:8)]);
xlabel('Julian day (Jan 1 = 0)');
ylabel('range (km)');
[mplnor.avg_prof, mplnor.avg_time] = mpl_downsample(mplnor.backscatter, mplnor.jd0, 24);
% [mplnor.atten_prof, tau, altitude, temperature, pressure] = get_sonde_ray_atten(mplnor.range);
[mplnor.atten_prof,tau] = std_ray_atten(mplnor.range(mplnor.range>0&mplnor.range<25));
cal_point = find((mplnor.range>14)&(mplnor.range<16));
mplnor.cals = mean(mplnor.atten_prof(cal_point))./mean(mplnor.avg_prof(cal_point,:));
for t = 1:length(mplnor.avg_time)
  mplnor.newavg_prof(:,t) = mplnor.avg_prof(:,t) * mplnor.cals(t);
end;
[mplnor.PileA, mplnor.PileB] = sift(mplnor.range(mplnor.plotrange), mplnor.newavg_prof(mplnor.plotrange,:));
figure; semilogy(mplnor.range(mplnor.plotrange), mplnor.newavg_prof(mplnor.plotrange,mplnor.PileA),'.', mplnor.range(mplnor.plotrange), mplnor.atten_prof(mplnor.plotrange), 'r');  zoom
Title(['MPLnor hourly averages and Rayleigh for ' mplnor.fname(1:8)]);
xlabel('range (km)');
ylabel('normalized attenuated backscatter');
ncmex('close', cdfid);
lidar = mplnor;