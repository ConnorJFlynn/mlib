function lidar_out = sub_interval(lidar, interval, lidar_out);
%lidar_out = sub_interval(lidar, interval, lidar_out);
% This function accepts a lidar structure, a specified interval of elements
% from the input lidar structure, and a (possibly empty) lidar_output
% structure.  
% It outputs and altered lidar_output structure by adding the averaged of
% the input interval as one temporal record to lidar_output
rawcts = mean(lidar.rawcts(:,interval)')';
if length(interval)>1
   sample_std = std(lidar.rawcts(:,interval)')';
else
   sample_std = ones(size(rawcts));
end
time = mean(lidar.time(interval)')';
hk = lidar.hk;
hk.cbh = mean(hk.cbh(interval)')';
hk.energyMonitor = mean(hk.energyMonitor(interval)')';
hk.instrumentTemp = mean(hk.instrumentTemp(interval)')';
hk.laserTemp = mean(hk.laserTemp(interval)')';
hk.detectorTemp = mean(hk.detectorTemp(interval)')';
hk.bg = mean(hk.bg(interval)')';
hk.PRF = mean(hk.PRF(interval)')';
hk.shotsSummed = mean(hk.shotsSummed(interval)')';
hk.averagingInterval = 24*60*60*(max(lidar.time(interval))-min(lidar.time(interval)));
prof = mean(lidar.prof(:,interval)')';
if isempty(lidar_out)
   lidar_out.rawcts = rawcts;
   lidar_out.sample_std = sample_std;
   lidar_out.time = time;
   lidar_out.hk.cbh = hk.cbh;
   lidar_out.hk.energyMonitor = hk.energyMonitor ;
   lidar_out.hk.instrumentTemp =hk.instrumentTemp;
   lidar_out.hk.laserTemp = hk.laserTemp;
   lidar_out.hk.detectorTemp = hk.detectorTemp;
   lidar_out.hk.bg = hk.bg;
   lidar_out.hk.PRF =hk.PRF;
   lidar_out.hk.shotsSummed = hk.shotsSummed;
   lidar_out.hk.averagingInterval = hk.averagingInterval;
   lidar_out.prof = prof;
   lidar_out.samples = length(interval);
else
   lidar_out.rawcts = [lidar_out.rawcts, rawcts];
   lidar_out.sample_std = [lidar_out.sample_std, sample_std];
   lidar_out.time = [lidar_out.time, time];
   lidar_out.hk.cbh = [lidar_out.hk.cbh hk.cbh];
   lidar_out.hk.energyMonitor = [lidar_out.hk.energyMonitor hk.energyMonitor];
   lidar_out.hk.instrumentTemp = [lidar_out.hk.instrumentTemp hk.instrumentTemp];
   lidar_out.hk.laserTemp = [lidar_out.hk.laserTemp hk.laserTemp];
   lidar_out.hk.detectorTemp = [lidar_out.hk.detectorTemp hk.detectorTemp];
   lidar_out.hk.bg = [lidar_out.hk.bg hk.bg];
   lidar_out.hk.PRF = [lidar_out.hk.PRF hk.PRF];
   lidar_out.hk.shotsSummed = [lidar_out.hk.shotsSummed hk.shotsSummed];
   lidar_out.hk.averagingInterval = [lidar_out.hk.averagingInterval hk.averagingInterval];
   lidar_out.prof = [lidar_out.prof, prof];
   lidar_out.samples = [lidar_out.samples, length(interval)];
end;
lidar_out.statics = lidar.statics;
lidar_out.range = lidar.range;
lidar_out.r = lidar.r;

