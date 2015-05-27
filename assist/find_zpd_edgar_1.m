function [zpd_loc,zpd_mag] = find_zpd_edgar(ch)
% Usage: [zpd_loc,zpd_mag] = find_zpd_edgar(ch)
% Accept assist igram struct with x and y fields and returns zpd location
% and magnitude.  Implements logic from LRTech to identify the zpd position 
% by examining the extrema in the igram and deciding between the maxima and 
% minima with a symmetry condition that the adjacent relative extrema be most 
% similar in magnitude.  This may be preferable to simply finding the
% max(abs(ch.y)) value for ABB or cloudy scenes where the raw igram
% amplitude may become small and the phase may oscillate.

%%
y = ch.y;
y_ = [(y(:,1:end-1)+y(:,2:end))./2];
y_ = [y(:,1),y_];
[imax,imax_i] = max(y_,[],2);
[imin,imin_i] = min(y_,[],2);
shift_i = imax_i - length(ch.x)./2;
% disp(shift_i(1));
% figure
%%

for s = size(ch.y,1):-1:1

   %%
%    plot([1:size(y,2)]- 32768/2,ch.y(s,:),'x-', [1:size(y,2)]- 32768/2,y(s,:),'o-')
   %%
   % positive symmetry test
   imax_i(s) = imax_i(s) -  double(ch.y(s,imax_i(s))<imax(s)) ;
   ii = imax_i(s);
   left_valley = ch.y(s,ii);
   while left_valley >= ch.y(s,ii-1)
      ii = ii -1;
      left_valley = ch.y(s,ii);
   end
   ii = imax_i(s);
      right_valley = ch.y(s,ii);
   while right_valley >= ch.y(s,ii+1)
      ii = ii +1;
      right_valley = ch.y(s,ii);
   end
dpos = abs(right_valley - left_valley);
 %%
 % negative symmetry test
   imin_i(s) = imin_i(s) - double(ch.y(s,imin_i(s)) >= imin(s));

   ii = imin_i(s);
   left_peak = ch.y(s,ii);
   while left_peak <= ch.y(s,ii-1)
      ii = ii -1;
      left_peak = ch.y(s,ii);
   end
   ii = imin_i(s);
      right_peak = ch.y(s,ii);
   while right_peak <= ch.y(s,ii+1)
      ii = ii +1;
      right_peak = ch.y(s,ii);
   end
dneg = abs(right_peak - left_peak);
 

zpd_loc(s) = imin_i(s)*double(dneg<dpos) + imax_i(s)*(double(dpos<=dneg));
%    zpd_loc(s) = ri_max(1)*(del_max<del_min) + ri_min(1)*(del_min<del_max)+.5;
   zpd_mag(s) = ch.y(s,zpd_loc(s));

end

return

