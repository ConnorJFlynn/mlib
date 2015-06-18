function out = stdwin(in,HW)
% out = stdwin(in,HW)
% returns the minimum stddev of points within three windows of equal halfwidth HW but with bounds; one centered
% and the other two at their left and right bounds.
% [t]-2*HW,t],[t-HW:t+HW], [t:t+2*HW]
mid = zeros(size(in));
left = mid; right = mid;
len_in = length(in);
for n = (1+HW):(len_in-HW)
mid(n) = std(in((n-HW):(n+HW)));
end
left(1:end-2*HW) = mid((1+HW):(end-HW));
right((1+2*HW):end) = mid((1+HW):(end-HW));


out = min([left; mid; right]);


return
   