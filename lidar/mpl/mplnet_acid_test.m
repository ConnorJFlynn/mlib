function [lidar] = mplnor_acid_test;
%This function puts mplnor data to the acid test of comparison with Rayleigh.
[cdfid, fname, pname] = get_ncid;
mplnet.fname = fname;
%mplnet.time = nc_time(cdfid);
%mplnet.jd0 = serial2jd0(mplnet.time);
mplnet.jd0 = nc_getvar(cdfid, 'julian_day');
mplnet.backscatter = nc_getvar(cdfid, 'backscatter');
%mplnet.range = nc_getvar(cdfid, 'height');
mplnet.range = nc_getvar(cdfid, 'range');
mplnet.plotrange = find((mplnet.range>.075)&(mplnet.range<16));
figure; image(mplnet.jd0,mplnet.range(mplnet.plotrange), 25*mplnet.backscatter(mplnet.plotrange,:)); axis('xy'); colormap('jet'); zoom
title(['MPLnet nrb data for ' mplnet.fname(1:8)]);
xlabel('Julian day (Jan 1 = 0)');
ylabel('range (km)');
[mplnet.avg_prof, mplnet.avg_time] = mpl_downsample(mplnet.backscatter, mplnet.jd0, 24);
[mplnet.atten_prof, tau, altitude, temperature, pressure] = get_sonde_ray_atten(mplnet.range);
cal_point = find((mplnet.range>14)&(mplnet.range<16));
mplnet.cals = mean(mplnet.atten_prof(cal_point))./mean(mplnet.avg_prof(cal_point,:));
for t = 1:length(mplnet.avg_time)
  mplnet.newavg_prof(:,t) = mplnet.avg_prof(:,t) * mplnet.cals(t);
end;
[mplnet.PileA, mplnet.PileB] = sift(mplnet.range(mplnet.plotrange), mplnet.newavg_prof(mplnet.plotrange,:));
figure; semilogy(mplnet.range(mplnet.plotrange), mplnet.newavg_prof(mplnet.plotrange,mplnet.PileA),'.', mplnet.range(mplnet.plotrange), mplnet.atten_prof(mplnet.plotrange), 'r');  zoom
Title(['MPLnet-nrb hourly averages and Rayleigh for ' mplnet.fname(1:8)]);
xlabel('range (km)');
ylabel('normalized attenuated backscatter');
ncmex('close', cdfid);
lidar = mplnet;