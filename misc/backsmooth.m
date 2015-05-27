function trace = backsmooth(trace,span,start);%
% trace = backsmooth(trace,span,start);
% This applies a box-car filter with initial width of 1 bin and a final width of "span". 
% If span<1, span represents a fraction of the total length
if ~exist('span','var')|(span>(length(trace)./2))
   span = floor(length(trace)./10);
end
if span>0&&span<1 % span represents a fraction of the total length
   span = floor(length(trace).*span);
end
if (~exist('start','var'))|(start>=span)
   start = 1;
end
full = size(trace,1);
for i = start:full;
   frac = i/full;
   back = floor(span*frac);
   if back > 0
      trace(i) = mean(trace((i-back):i));
   end
end