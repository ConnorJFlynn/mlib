function [avg] = downsample_mpl(mpl, intervals);
% [avg] = downsample_mpl(mpl, intervals);
% Returns averages of equal time intervals, irrespective of the number of samples per interval
% This function should be replaced or augmented with one that would output intervals of fixed unit in time


%intervals = 24;
first_time = min(mpl.time);
last_time = max(mpl.time);
time_span = last_time - first_time;

for t = intervals:-1:1
%   disp(t)
    span = find((mpl.time>=(first_time+(t-1)*time_span/intervals))&(mpl.time<(first_time+(t*time_span/intervals))));
    avg.time(t) = mean(mpl.time(span));
    avg.prof(:,t) = mean(mpl.prof(:,span)')';
    avg.rawcts(:,t) = mean(mpl.rawcts(:,span)')';
    avg.nor(:,t) = mean(mpl.nor(:,span)')';
    avg.hk.bg(t) = mean(mpl.hk.bg(span));
    avg.hk.detectorTemp(t) = mean(mpl.hk.detectorTemp(span));
    avg.hk.energyMonitor(t) = mean(mpl.hk.energyMonitor(span));
 end
    avg.time = avg.time';
    avg.hk.bg = avg.hk.bg';
    avg.hk.detectorTemp = avg.hk.detectorTemp';
    avg.hk.energyMonitor = avg.hk.energyMonitor';
 
% [avg_profs, avg_times] = mpl_downsample(prof, sample_time, intervals);
% Returns averages of equal time intervals, irrespective of the number of samples per interval

% time_span = max(sample_time) - min(sample_time);
% first_time = min(sample_time);
% 
% for t = 1:intervals
%     span = find((sample_time>=(first_time+(t-1)*time_span/intervals))&(sample_time<(first_time+(t*time_span/intervals))));
%     avg_prof(:,t) = mean(prof(:,span)')';
%     avg_time(t) = mean(sample_time(span));
% end