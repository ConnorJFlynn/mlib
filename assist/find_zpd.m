function [zpd_loc,zpd_mag] = find_zpd(ch)
% Usage: [zpd_loc,zpd_mag] = find_zpd(ch)
% Accept assist igram struct with x and y fields and returns zpd location
% and magnitude.  Implements logic from LRTech to identify the zpd position 
% by examining the extrema in the igram and deciding between the maxima and 
% minima with a symmetry condition that the adjacent relative extrema be most 
% similar in magnitude.  This may be preferable to simply finding the
% max(abs(ch.y)) value for ABB or cloudy scenes where the raw igram
% amplitude may become small and the phase may oscillate.

%%
%This logic has trouble when either the main or adjacent peaks have
%relative extrema with plateau points
% % windowSize = 2;
% % y = filter(ones(1,windowSize)/windowSize,1,ch.y')';
y = ch.y;
y(:,2:end-1) = (y(:,2:end-1)+y(:,3:end))/2;
%%
% figure(gcf);
% plot([1:length(ch.x)],ch.y(28:30,:),'-',[1:length(ch.x)],y(28:30,:),'.'); zoom('on')
% legend('28','29','30')

%%

for s = size(y,1):-1:1
   ri_max = relmax(y(s,:));
   ri_min = relmin(y(s,:));
   %%
%    [[ri_max(1:3),abs(ri_max(3)-ri_max(2))]',[ri_min(1:3),abs(ri_min(3)-ri_min(2))]']
%%
   del_max = abs(y(s,ri_max(3))-y(s,ri_max(2)));
   del_min = abs(y(s,ri_min(3))-y(s,ri_min(2)));
   zpd_loc(s) = ri_max(1)*(del_max<del_min) + ri_min(1)*(del_min<del_max);
%    zpd_loc(s) = ri_max(1)*(del_max<del_min) + ri_min(1)*(del_min<del_max)+.5;
   zpd_mag(s) = ch.y(s,zpd_loc(s));
%%   
%     figure(gcf); plot([1:length(ch.x)],y(s,:),'b-',ri_max,y(s,ri_max),'ro',ri_min,y(s,ri_min),'bo',[1:length(ch.x)],ch.y(s,:),'kx');
%     title(['zpd_loc: ',num2str(zpd_loc(s))]);
%%
end

return

