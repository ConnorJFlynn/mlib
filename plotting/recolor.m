function lines = recolor(lines, z,cv);
% lines = recolor(lines, z)
% lines are handles to existing plot
% z is of length(lines) and represents the value to color against
% re-colors the lines (in an existing plot) according to the supplied z
% field. For example, lines may be colored according to time
   colors = get(lines,'color');
   map = colormap;
   if ~exist('cv','var')
      cv = [min(z),max(z)];
   end
   [P,S,mu] = polyfit(cv,[1,length(map)],1);
   map_color = ceil(polyval(P,z,[],mu));
   if size(map_color,1)==1
       mc = max([1.*ones(size(map_color));map_color]);
       map_color = mc;
       mc = min([length(map).*ones(size(map_color));map_color]);
       map_color = mc;
   else
       mc = max([1.*ones(size(map_color)),map_color],[],2);
       map_color = mc;
       mc = min([length(map).*ones(size(map_color)),map_color],[],2);
       map_color = mc;
   end
   for c = 1:length(colors)
      set(lines(c),'color',map(map_color(c),:));
   end
      caxis(cv);
