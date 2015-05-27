function [avg_prof, avg_time] = mpl_downsample(prof, sample_time, intervals);
% [avg_profs, avg_times] = mpl_downsample(prof, sample_time, intervals);
% Returns averages of equal time intervals, irrespective of the number of samples per interval

time_span = max(sample_time) - min(sample_time);
first_time = min(sample_time);

for t = 1:intervals
    span = find((sample_time>=(first_time+(t-1)*time_span/intervals))&(sample_time<(first_time+(t*time_span/intervals))));
    avg_prof(:,t) = mean(prof(:,span)')';
    avg_time(t) = mean(sample_time(span));
end