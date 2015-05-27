function [mpl] = mplnor_timefill(mpl);
% [avg] = mplnor_timefill(mpl, time_int);
% Returns averages of time intervals in minutes, irrespective of the number of samples per interval
% The output is always of fixed size with exactly mins_in_day/time_interval records
% Empty intervals have valid time stamps but are filled with -9999.
% This procedure is only intended for files within a single day UTC.
% 
% Fields averaged: time, prof, cloud_mask_2
time_int = 1;
mins_in_day = 24*60;
sum = 0;
t = 0;
serial_day = floor(mpl.time(1));
%    sum = t*time_int;
for t = ceil(mins_in_day/time_int):(-1*time_int):1
    span = find((mpl.time>=(serial_day + time_int*(t-1)/mins_in_day))&((mpl.time<(serial_day + time_int*(t)/mins_in_day))));    
    if length(span)>1
        avg.time(t) = mean(mpl.time(span));
        avg.prof(:,t) = mean(mpl.prof(:,span));
        avg.mpl.cloud_mask_2(:,t) = max(mpl.cloud_mask_2(:,span));
    elseif length(span)==1
        avg.time(t) = (mpl.time(span));
        avg.prof(:,t) = (mpl.prof(:,span)')';
        avg.cloud_mask_2(:,t) = (mpl.cloud_mask_2(:,span)')';
    else  
        avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
        avg.prof(:,t) = -9999*ones(size(mpl.prof(:,1)));
        avg.cloud_mask_2(:,t) = -9999*ones(size(mpl.cloud_mask_2(:,1)));
    end
end
range = mpl.range;
mpl = avg;
mpl.range = range;