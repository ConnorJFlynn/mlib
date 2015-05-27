function [P, lower_point,upper_point ] = ol_corr_vertA(range, prof);
%[P, lower_point,upper_point ] = ol_corr_vertA(range, prof);
%This function accepts a range and profile and permits the user to 
%iteratively select a region of the graph to fit with a straight line.
%It returns the polynomial coefficients and the upper and lower points over
%which the polynomial regression was fit.
%It does NOT return overlap correction values, it only returns the
%best fit to the upper region which may be extrapolated to near range

% ol = exp(polyval(P,mpl.range(mpl.r.lte_10)))./((mean(mpl.prof(mpl.r.lte_10,:)')'));

%take the log of prof
prof = real(log(prof));

%Initialize the width and position of the fit interval
fig = figure;
plot(range, prof, '.c');
title('Zoom in as desired, hit any key to continue')
zoom on;
pause;
v = axis;
lower_limit = max(find(range<=v(1)));
if isempty(lower_limit)
   lower_limit = 1;
end
upper_limit = min(find(range>=v(2)));
if isempty(upper_limit)
   upper_limit = length(range);
end;

width = max(floor(length(lower_limit:upper_limit)/8),2);
current = lower_limit + floor(length(lower_limit:upper_limit)/2);
current_high = min([(current + width),upper_limit]);


button = 0;
while (button~=88 & button ~= 120)
   [P] = polyfit(range(current:current_high), prof(current:current_high), 1);
   plot(range, prof, '.c', range, polyval(P,range), 'r');
   title(['Interval [',num2str(range(current)),',',num2str(range(current_high)),']  Use arrows to move or change.  (Press "x" or "X" to exit.)']);
   axis(v);
   [x,y,button] = ginput(1);
   if button==28
      current = current - 1;
   elseif button == 29, current = current + 1;
   elseif button == 30, width = width +1;
   elseif button == 31, width = width -1;
   end;
   current = max([current, lower_limit]);
   current_high = min([current+width, upper_limit]);
   width = max([2,width]);
   width = min([width, upper_limit-current]);
     
end

upper_point = current_high;
lower_point = current;




