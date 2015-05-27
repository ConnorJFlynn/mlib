function [H]=corneranno(pos,str);
%
% handle = corneranno(pos,string)
%
%  pos = 1 - top left
%        2 - top right
%        3 - bottom right
%        4 - bottom left
%
%  positive = outside
%  negative = inside
%

s=(pos>0);
p=abs(pos);
if p==1 | p==2
  y=1;
else
  y=0;
end
if p==1 | p==4
  x=0;
else
  x=1;
end

if s*(y-.5) < 0
  va='top';
else
  va='bottom';
end
if s*(x-.5) < 0
  ha='left';
else
  ha='right';
end



H=text(x,y,str,'FontName','Fixed','FontSize',6, ...
       'HorizontalAlignment',ha,'VerticalAlignment',va, ...
       'Units','normalized','Margin',2);

