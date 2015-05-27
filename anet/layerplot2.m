function [hAxes,hLine] = layerplot2(x1,y1,x2,y2,Labels,Range,Legends)
%hLine(1) = plot(x1,y1,'b');
hLine(1) = plot(x1,y1,'-b*');
% DO NOT USE FUNCTION 'LINE' HERE
hAxes(1) = gca;
%set(hAxes(1),'YColor','b','Box','on');
%set(hAxes(1),'YColor','b','Box','off');
hAxes(2) = axes('Parent',get(hAxes(1),'Parent'),'Position',get(hAxes(1),'Position'),'YColor','r');
hLine(2) = plot(x2,y2,'-r*');
set(hAxes(2),'Xlim',get(hAxes(1),'Xlim'),'YAxisLocation','right','Color','none','XTickLabel',[],'Layer','top');
%set(hAxes(2),'YColor','r','Box','off');
if nargin >= 5
xlabel(hAxes(1),Labels{1},'Color','k');
ylabel(hAxes(1),Labels{2},'Color','b');
ylabel(hAxes(2),Labels{3},'Color','r');
end
if nargin >= 6
if(length(Range(:))==2)
set(hAxes,'Xlim',Range);
else
set(hAxes,'Xlim',Range(1,:));
set(hAxes(1),'Ylim',Range(2,:));
set(hAxes(2),'Ylim',Range(3,:));
end
end
% if nargin ==7, legend(hLine,Legends{:},'Location','NorthWest'); end;
if nargin ==7, legend(hLine,Legends{:},'Location','West'); end;