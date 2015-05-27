function scatr = recolor_scatr(scatr, z);
% re-colors the symbols  (in an existing scatter plot) according to the supplied z
% field. For example, scatter may be colored according to time
   colors = zeros(size(get(scatr,'xdata')));
   map = colormap;
   [P,S,mu] = polyfit([min(z),max(z)],[1,length(map)],1);
   map_color = floor(polyval(P,z,[],mu));
   set(scatr,'cdata',map_color);
%    for c = 1:length(colors)
%       set(scatr(c),'cdata',map(map_color(c),:));
%    end
%    caxis([min(z),max(z)]);
   caxis([min(map_color),max(map_color)]);