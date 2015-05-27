function [avg] = mpl_timeavg2(mpl, time_int, filter);
% [avg] = mpl_timeavg2(mpl, time_int);
% Returns averages of time intervals in minutes, irrespective of the number of samples per interval
% The output is always of fixed size with exactly mins_in_day/time_interval records
% Empty intervals have valid time stamps but are filled with -9999.
% This procedure is only intended for files within a single day UTC.
% 
% Fields averaged: time, prof, rawcts, nor, hk.bg, hk.detectorTemp, hk.energyMonitor;
if nargin<3
    filter = [1:length(mpl.time)];
end
mins_in_day = 24*60;
sum = 0;
t = 0;
serial_day = floor(mpl.time(1));
%    sum = t*time_int;
while sum < mins_in_day
    t = t+1;
    span = find((mpl.time>=(serial_day + time_int*(t-1)/mins_in_day))&((mpl.time<(serial_day + time_int*(t)/mins_in_day))));    
    if length(span)>1
        avg.time(t) = mean(mpl.time(span));
        avg.prof(:,t) = mean(mpl.prof(:,span));
        avg.rawcts(:,t) = mean(mpl.rawcts(:,span));
        avg.nor(:,t) = mean(mpl.nor(:,span));
        avg.hk.bg(t) = mean(mpl.hk.bg(span));
        avg.hk.detectorTemp(t) = mean(mpl.hk.detectorTemp(span));
        avg.hk.energyMonitor(t) = mean(mpl.hk.energyMonitor(span));           
    elseif length(span)==1
        avg.time(t) = (mpl.time(span));
        avg.prof(:,t) = (mpl.prof(:,span)')';
        avg.rawcts(:,t) = (mpl.rawcts(:,span)')';
        avg.nor(:,t) = (mpl.nor(:,span)')';
        avg.hk.bg(t) = (mpl.hk.bg(span));
        avg.hk.detectorTemp(t) = (mpl.hk.detectorTemp(span));
        avg.hk.energyMonitor(t) = (mpl.hk.energyMonitor(span));        
    else  
        avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
        avg.prof(:,t) = -9999*ones(size(mpl.rawcts(:,1)));
        avg.rawcts(:,t) = -9999*ones(size(mpl.rawcts(:,1)));
        avg.nor(:,t) = -9999*ones(size(mpl.rawcts(:,1)));
        avg.hk.bg(t) = -9999;
        avg.hk.detectorTemp(t) = -9999;
        avg.hk.energyMonitor(t) = -9999; 
    end
    sum = t*time_int;
    [sum,span]'
end
if nargin==3 % Then a filter was passed in, so recalculate averages for filter values to avoid contamination with non-filter values. 
            % Note that time slots with no filter values are left "as is", but empty time slots are still filled with missings.   
    
    mins_in_day = 24*60;
    sum = 0;
    t = 0;
    serial_day = floor(mpl.time(filter(1)));
    while sum < mins_in_day
        t = t+1;
        span = find((mpl.time(filter)>=(serial_day + time_int*(t-1)/mins_in_day))&((mpl.time(filter)<(serial_day + time_int*(t)/mins_in_day))));
        if length(span)>1
            avg.time(t) = mean(mpl.time(filter(span)));
            avg.prof(:,t) = mean(mpl.prof(:,filter(span))')';
            avg.rawcts(:,t) = mean(mpl.rawcts(:,filter(span))')';
            avg.nor(:,t) = mean(mpl.nor(:,filter(span))')';
            avg.hk.bg(t) = mean(mpl.hk.bg(filter(span)));
            avg.hk.detectorTemp(t) = mean(mpl.hk.detectorTemp(filter(span)));
            avg.hk.energyMonitor(t) = mean(mpl.hk.energyMonitor(filter(span)));
        elseif length(span)==1
            avg.time(t) = (mpl.time(filter(span)));
            avg.prof(:,t) = (mpl.prof(:,filter(span)));
            avg.rawcts(:,t) = (mpl.rawcts(:,filter(span)));
            avg.nor(:,t) = (mpl.nor(:,filter(span)));
            avg.hk.bg(t) = (mpl.hk.bg(filter(span)));
            avg.hk.detectorTemp(t) = (mpl.hk.detectorTemp(filter(span)));
            avg.hk.energyMonitor(t) = (mpl.hk.energyMonitor(filter(span)));
        end
            
        sum = t*time_int;
    end
end;
avg.time = avg.time';
avg.hk.bg = avg.hk.bg';
avg.hk.detectorTemp = avg.hk.detectorTemp';
avg.hk.energyMonitor = avg.hk.energyMonitor';
