function ray_test(time, range, profs);
%[mpl] = mpl_acid_test;
%This function puts mpl data to the acid test of comparison with Rayleigh.
% The user is first prompted to select a time-range of interest. 
% Then, permitted to manually "sift" profiles.
% Next, averages are constructed.
% Then, the calibration region is selected.
% Finally, the profiles are pinned to a sonde-derived Rayleigh profiles.
% And finally, a polynomial fit is constructed over a selected range region
% and far-R correction determined.
[sonde.atten_prof,sonde.tau] = std_ray_atten(range);
r.lte_20 = find((range>=0)&(range<=20));
acid = figure; imagesc(serial2Hh(time),range(r.lte_20), profs(r.lte_20,:)); 
axis('xy'); axis([axis, 0, 15, 0, 15]); colormap('jet');  zoom
title(['Zoom into the desired time period for Rayleigh comparison.  Hit any key when finished...']);
xlabel('Time (Hh)');
ylabel('range (km)');

pause
v = axis;
clean = find((serial2Hh(time)>=v(1))&(serial2Hh(time)<=v(2)));
[pileA, pileB] = trimsift_nolog(range(r.lte_20), profs(r.lte_20,clean));
%[pileA, pileB] = sift_nolog(range, profs(:,clean));

clean = clean(pileA);

%Do averages...
[avg] = timeavg3(time, profs,60,clean);
% Averaged: time, profs, rawcts,hk.bg, hk.detectorTemp, hk.energyMonitor;


figure; semilogy(range(r.lte_20),avg.profs(r.lte_20,avg.clean==1), '.');  
v = axis; zoom
ylabel('range (km)');
xlabel('normalized attenuated backscatter');
title(['Select an aerosol-free region for calibration.  Hit enter when done.']);
disp(['Select an aerosol-free region for calibration.  Hit enter when done.']);
pause;

zoom off;
cal_v = axis;
axis(v);
title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(3),cal_v(4))]);
r.cal = find((range>=cal_v(1))&(range<=cal_v(2)));
r.lte_cal = find((range>.1)&(range<range(max(r.cal))));
cal.atten_ray = mean(sonde.atten_prof(r.cal));
cal.mean_prof = mean(profs(r.cal,:));
cal.lowess_mean_prof(clean) = lowess(serial2doy(time(clean))-floor(serial2doy(time((clean(1))))), cal.mean_prof(clean), .02)';
%cal.C(non_missing) = cal.lowess_mean_prof(non_missing) ./ (cal.atten_ray .* exp(-2*mfr.aod_523(non_missing))); 

cal.invC = mean(avg.profs(r.cal,:)) / mean(sonde.atten_prof(r.cal));
cal.invC = 1./cal.invC;
for t = (find(avg.clean==1))
  avg.profs(:,t) = avg.profs(:,t) * cal.invC(t);
end;
avg = avg;
semilogy(range(r.lte_20),avg.profs(r.lte_20,avg.clean==1), '.',  range(r.lte_20),sonde.atten_prof(r.lte_20),'r');  
zoom
ylabel('range (km)');
xlabel('normalized attenuated backscatter');
title([sprintf('Using selected region from %2.1f - %2.1f for calibration.', cal_v(1),cal_v(2))]);


function [avg] = timeavg3(time, profs, time_int, filter);
% [avg] = mpl_timeavg3(mpl, time_int);
% Returns averages of time intervals in minutes, irrespective of the number of samples per interval
% The output is always of fixed size with exactly mins_in_day/time_interval records
% Empty intervals have valid time stamps but are filled with -9999.
% This procedure is only intended for files within a single day UTC.
% Averaged: time, profs, rawcts,hk.bg, hk.detector_temp, hk.energy_monitor;

if nargin<4
    filter = [1:length(time)];
end
mins_in_day = 24*60;
sum = 0;
t = 0;
serial_day = floor(time(1));
%    sum = t*time_int;
% fig_avg = figure; 
for t = ceil(mins_in_day/time_int):-1:1
%      pause(.05);
    span = find((time>=(serial_day + time_int*(t-1)/mins_in_day))&((time<(serial_day + time_int*(t)/mins_in_day))));    
    if length(span)>1
        avg.clean(t) = 1;
        avg.time(t) = mean(time(span));
        avg.profs(:,t) = mean(profs(:,span)')';
%           figure(fig_avg); plot(range, profs(:,span), 'r', range, avg.profs(:,t), '.b')
%           title(['t = ', num2str(t), '  ',serial2Hh(avg.time(t)),'  span = ', num2str(length(span))]);
    elseif length(span)==1
        avg.clean(t) = 1;
        avg.time(t) = (time(span));
        avg.profs(:,t) = (profs(:,span));
  else  
        avg.clean(t) = 0;
        avg.time(t) = serial_day + ((time_int/mins_in_day)*(2*t-1)./2);
        avg.profs(:,t) = -9999*ones(size(profs(:,1)));
    end
end

if nargin==4 % Then a filter was passed in, so recalculate averages for filter values to avoid contamination with non-filter values. 
            % Note that time slots with no filter values are left "as is",
            % but empty time slots are still filled with missings.   
    mins_in_day = 24*60;
    sum = 0;
    t = 0;
    serial_day = floor(time(filter(1)));
    for t = ceil(mins_in_day/time_int):-1:1
        span = find((time(filter)>=(serial_day + time_int*(t-1)/mins_in_day))&((time(filter)<(serial_day + time_int*(t)/mins_in_day))));
         pause(.05);
        if length(span)>1
            avg.clean(t) = 1;
            avg.time(t) = mean(time(filter(span)));
            avg.profs(:,t) = mean(profs(:,filter(span))')';
         elseif length(span)==1
             avg.clean(t) = 1;
            avg.time(t) = (time(filter(span)));
            avg.profs(:,t) = (profs(:,filter(span)));
         else
             avg.clean(t) = 0;
%               plot(0,0);
%               title(['No clean profiles for t = ', num2str(t)]);
         end;
         %pause
    end
end;
avg.time = avg.time';
