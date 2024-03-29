function [interval,nums] = intervals(x);
%[intervals,nums] = interval(x);
%returns the intervals present in x sorted from most common to least common
% Modified to remove use of 'last' and 'first' in unique command for back
% compatibility
%   x = sscanf(sprintf('%0.7g',x),'%g');
   xx = sort(diff(sort(x)));
   xx = xx(xx>0);
   xx = xx(1)*sscanf(sprintf('%0.2e ',xx/xx(1)),'%g'); %Truncate at 2 decimal places
%    xx = sscanf(sprintf('%0.1g',xx),'%g');
%    xx = max(xx)*floor(500*xx/max(xx))/500;%this an attempt remove minor discrepancies in the interval
%    [spacing, first] = unique(xx,'first');
   [spacing, last] = unique(xx,'first');
   if length(last)>1
       nums = diff2(last);% 
   [nums,place] = sort(nums, 'descend');
  
   interval = spacing(place);
   else
       interval = spacing;
   end

 