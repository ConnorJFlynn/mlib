function [avg] = mpl_timeavg4(mpl, time_int, filter);
% [avg] = mpl_timeavg4(mpl, time_int);
% Returns averages of time intervals in minutes, irrespective of the number of samples per interval
% The output is always of fixed size with exactly mins_in_day/time_interval records
% Empty intervals have valid time stamps but are filled with -9999.
% This procedure is only intended for files within a single day UTC.
% Averaged: time, prof, rawcts,hk.bg, hk.detector_temp, hk.energy_monitor;

if nargin<3
    filter = [1:length(mpl.time)];
end
mins_in_day = 24*60;
sum = 0;
t = 0;
serial_day = floor(mpl.time(1));
%    sum = t*time_int;
% fig_avg = figure; 
for t = ceil(mins_in_day/time_int):-1:1
%      pause(.05);
    span = find((mpl.time>=(serial_day + time_int*(t-1)/mins_in_day))&((mpl.time<(serial_day + time_int*(t)/mins_in_day))));    
    if length(span)>1
        avg.clean(t) = 1;
%         avg.time(t) = mean(mpl.time(span));
        avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
        avg.attn_bscat(:,t) = mean(mpl.attn_bscat(:,span)')';
%         avg.rawcts(:,t) = mean(mpl.rawcts(:,span)')';
%         avg.nor(:,t) = mean(mpl.prof(:,span)')';
        avg.hk.bg(t) = mean(mpl.hk.cop_bg(span));
        avg.hk.detector_temp(t) = mean(mpl.hk.detector_temp(span));
        avg.hk.energy_monitor(t) = mean(mpl.hk.energy_monitor(span)); 
%           figure(fig_avg); plot(mpl.range, mpl.prof(:,span), 'r', mpl.range, avg.prof(:,t), '.b')
%           title(['t = ', num2str(t), '  ',serial2Hh(avg.time(t)),'  span = ', num2str(length(span))]);
    elseif length(span)==1
        avg.clean(t) = 1;
%         avg.time(t) = (mpl.time(span));
        avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
        avg.attn_bscat(:,t) = (mpl.attn_bscat(:,span));
%         avg.rawcts(:,t) = (mpl.rawcts(:,span));
%         avg.nor(:,t) = (mpl.prof(:,span));
        avg.hk.bg(t) = (mpl.hk.cop_bg(span));
        avg.hk.detector_temp(t) = (mpl.hk.detector_temp(span));
        avg.hk.energy_monitor(t) = (mpl.hk.energy_monitor(span));        
%            figure(fig_avg); plot(mpl.range, avg.prof(:,t), 'r')
%          title(['t = ', num2str(t)]);
  else  
        avg.clean(t) = 0;
        avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
        avg.attn_bscat(:,t) = NaN(size(mpl.rawcts(:,1)));
%         avg.rawcts(:,t) = NaN(size(mpl.rawcts(:,1)));
%         avg.nor(:,t) = -9999*ones(size(mpl.rawcts(:,1)));
        avg.hk.bg(t) = NaN;
        avg.hk.detector_temp(t) = NaN;
        avg.hk.energy_monitor(t) = NaN; 
%           title(['No clean profiles for t = ', num2str(t)]);

    end
end

if nargin==3 % Then a filter was passed in, so recalculate averages for filter values to avoid contamination with non-filter values. 
            % Note that time slots with no filter values are left "as is",
            % but empty time slots are still filled with missings.   
    mins_in_day = 24*60;
    sum = 0;
    t = 0;
    serial_day = floor(mpl.time(filter(1)));
    for t = ceil(mins_in_day/time_int):-1:1
        span = find((mpl.time(filter)>=(serial_day + time_int*(t-1)/mins_in_day))&((mpl.time(filter)<(serial_day + time_int*(t)/mins_in_day))));
         pause(.05);
        if length(span)>1
            avg.clean(t) = 1;
%             avg.time(t) = mean(mpl.time(filter(span)));
            avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
            avg.attn_bscat(:,t) = mean(mpl.attn_bscat(:,filter(span))')';
%             avg.rawcts(:,t) = mean(mpl.rawcts(:,filter(span))')';
            avg.hk.bg(t) = mean(mpl.hk.cop_bg(filter(span)));
            avg.hk.detector_temp(t) = mean(mpl.hk.detector_temp(filter(span)));
            avg.hk.energy_monitor(t) = mean(mpl.hk.energy_monitor(filter(span)));
%               figure(fig_avg); plot(mpl.range(mpl.r.lte_20), mpl.prof(mpl.r.lte_20,filter(span)), 'r',mpl.range(mpl.r.lte_20), avg.prof(mpl.r.lte_20,t), 'b.');
%               title([num2str(serial2Hh(avg.time(t))),'  t = ', num2str(t), '  span = ', num2str(length(span))]);
         elseif length(span)==1
             avg.clean(t) = 1;
%             avg.time(t) = (mpl.time(filter(span)));
            avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
            avg.attn_bscat(:,t) = (mpl.attn_bscat(:,filter(span)));
%             avg.rawcts(:,t) = (mpl.rawcts(:,filter(span)));
            avg.hk.bg(t) = (mpl.hk.cop_bg(filter(span)));
            avg.hk.detector_temp(t) = (mpl.hk.detector_temp(filter(span)));
            avg.hk.energy_monitor(t) = (mpl.hk.energy_monitor(filter(span)));
%               figure(fig_avg); plot(mpl.range(mpl.r.lte_20), mpl.prof(mpl.r.lte_20,filter(span)), 'r',mpl.range(mpl.r.lte_20), avg.prof(mpl.r.lte_20,t), 'b.');
%               title([num2str(serial2Hh(avg.time(t))),'  t = ', num2str(t)]);
         else
             avg.clean(t) = 0;
%               plot(0,0);
%               title(['No clean profiles for t = ', num2str(t)]);
         end;
         %pause
    end
end;
% avg.time = avg.time;
% avg.hk.bg = avg.hk.bg;
% avg.hk.detector_temp = avg.hk.detector_temp;
% avg.hk.energy_monitor = avg.hk.energy_monitor;
%close(fig_avg);
