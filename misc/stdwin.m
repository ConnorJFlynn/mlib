function [out,rstd,avg,mid] = stdwin(in,HW)
% [out,rstd,avg,mid]= stdwin(in,HW)
% returns the minimum stddev of points within three windows of equal halfwidth HW but with bounds; one centered
% and the other two at their left and right bounds.
% [t]-2*HW,t],[t-HW:t+HW], [t:t+2*HW]
% rstd is the relative std corresponding to out/avg.  
% mid is the "normal" std over the sliding window [t-HW:t+HW]
vmin = min(min(in)); in = in + vmin; % Adds this minimum value before computing STD. Shouldn't matter but ...
mid = zeros(size(in));
avg = mid;
left = mid; right = mid;
len_in = length(in);
for n = (1+HW):(len_in-HW)
   mid(n) = std(in((n-HW):(n+HW)));
   avg(n) = mean(in((n-HW):(n+HW))-vmin);
end
left(1:end-2*HW) = mid((1+HW):(end-HW));
right((2*HW):(end-1)) = mid((1+HW):(end-HW));
if size(in,2)==1
   out = (min([left'; mid'; right']))';
else
   out = min([left; mid; right]);
end
rstd = out./avg;
return
   