function [colors, map_ii] = get_colors(z,cv);
% colors = get_colors(z,cv)
% Get colors drawn from the current colormap mapped against cv for points z
   map = colormap;
   if ~exist('cv','var')
      cv = [min(z),max(z)];
   end
   [P,~,mu] = polyfit(cv,[1,length(map)],1);
   % This line finds the row of the colormap
   map_ii = ceil(polyval(P,z,[],mu));
   if size(map_ii,1)==1
       mc = max([1.*ones(size(map_ii));map_ii]);
       map_ii = mc;
       mc = min([length(map).*ones(size(map_ii));map_ii]);
       map_ii = mc;
   else
       mc = max([1.*ones(size(map_ii)),map_ii],[],2);
       map_ii = mc;
       mc = min([length(map).*ones(size(map_ii)),map_ii],[],2);
       map_ii = mc;
   end

   colors = map(map_ii,:);
