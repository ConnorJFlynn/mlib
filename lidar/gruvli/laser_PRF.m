function [prf] = laser_PRF(cdfid);
% [prf] = laser_PRF(cdfid)
% This function accepts an open lidar file and returns the PRF as determined from the 
% spacing of measurement times, the number of accumulates, and the average number of samples.

time = nc_getvar(cdfid, 'time')';
accumulates = nc_getvar(cdfid,'accumulates');
samples = nc_getvar(cdfid, 'samples')';

if (length(time)<2)
   time = 0;
else  
   time = round(mean(diff(time)));
end;

samples = round(mean(samples));

if (time <= 0)
   prf = -1;
else
   prf = accumulates * samples / time;
end;