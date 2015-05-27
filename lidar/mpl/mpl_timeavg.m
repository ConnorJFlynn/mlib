function [avg] = mpl_timeavg(mpl, time_int, filter);
% [avg] = mpl_timeavg(mpl, time_int);
% Returns averages of time intervals in minutes, irrespective of the number of samples per interval
% The output is always of fixed size with exactly mins_in_day/time_interval records
% Empty intervals have valid time stamps but are filled with -9999.
% This procedure is only intended for files within a single day UTC.
if nargin<3
   filter = [1:length(mpl.time)];
end
mins_in_day = 24*60;
sum = 0;
t = 0;
serial_day = floor(mpl.time(filter(1)));
while sum < mins_in_day
   t = t+1;
   span = find((mpl.time(filter)>=(serial_day + time_int*(t-1)/mins_in_day))&((mpl.time(filter)<(serial_day + time_int*(t)/mins_in_day))));
   if length(span>0)
      avg.time(t) = mean(mpl.time(filter(span)));
      avg.prof(:,t) = mean(mpl.prof(:,filter(span))')';
      avg.rawcts(:,t) = mean(mpl.rawcts(:,filter(span))')';
      avg.hk.bg(t) = mean(mpl.hk.bg(filter(span)));
      avg.hk.detectorTemp(t) = mean(mpl.hk.detectorTemp(filter(span)));
      avg.hk.energyMonitor(t) = mean(mpl.hk.energyMonitor(filter(span)));
   else
      avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
      avg.prof(:,t) = -9999*ones(size(mpl.rawcts(:,1)));
      avg.rawcts(:,t) = -9999*ones(size(mpl.rawcts(:,1)));
      avg.hk.bg(t) = -9999;
      avg.hk.detectorTemp(t) = -9999;
      avg.hk.energyMonitor(t) = -9999;      
   end
   sum = t*time_int;
end
avg.time = avg.time';
avg.hk.bg = avg.hk.bg';
avg.hk.detectorTemp = avg.hk.detectorTemp';
avg.hk.energyMonitor = avg.hk.energyMonitor';
