function [fixed_tim fixed_var] = fixed_time_grid(time,variable,pref)

%First get the date and spacing of the data
date = unique(floor(time));
if max(size(date)) > 1
    fprintf('Data exists over more than one day \n');
end

if strmatch(pref.spacing.units,'sec')
    spacing = pref.spacing.val/3600/24;
else
    error
end

fixed_tim = date:spacing:date+1;
fixed_tim = fixed_tim(1:end-1);
fixed_tim = fixed_tim';

fixed_var = interp1(time,variable,fixed_tim,'nearest');

% plot(time,variable,'r.');
% hold on
% plot(fixed_tim,fixed_var,'k.');




return