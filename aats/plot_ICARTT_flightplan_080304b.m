%plot_ICARTT_flightplan.m
clear all
close all

flag_plot_track='no';


lat_Pease=43.0926;
lon_Pease=-70.8329;

lat_ship=[43.633]; %depends on day; set = [] to omit
lon_ship=[-69.917]; %depends on day

rng=nm2deg(50);
[latout,lonout] = reckon(43.5,-69.5,rng,45)

title_str = 'J-31 flight plan, August 3, 2004 2nd flight. Take-off time: 16:00 EDT'


latlon=[lat_Pease lon_Pease; 43.2183 -70.5;43.2183 -69.9167;43.5, -70.3; 43.2183 -69.9167; 43.2183 -70.5;lat_ship lon_ship;43 -70;lat_Pease lon_Pease]

lat_track=latlon(:,1);
lon_track=latlon(:,2);

latlon_MISR=[45.1 -71;43.7 -67;41.2 -67.8; 42.4 -71.7;45.1 -71]

lat_track_MISR=latlon_MISR(:,1);
lon_track_MISR=latlon_MISR(:,2);


msize=4;
colorlevels=[0 1 1; 0 0 1; 0 1 0; 1 1 0; 1 .65 .4; 1 0 1;1 0 0;0.8 0.2 0.2;0.5 0.5 0.5;0 0 0]; % cyan,blue,green,yellow,orange,magenta,red,brown,gray
zcrit=[0.25 0.5:0.5:4];

figure(31)
worldmap([42,44],[-72,-69],'patch')

%plot AERONET points
  plotm(43.733,-66.117,'rs','MarkerSize',8,'MarkerFaceColor','b') 
  textm(43.633,-66.217, sprintf('%s','Chebogue'))

%   plotm(45.2,-68.7167,'rs','MarkerSize',8,'MarkerFaceColor','b')  
%   textm(45.1,-68.8167, sprintf('%s','Howland'))
%   
%   plotm(45.3667,-71.9167,'rs','MarkerSize',8,'MarkerFaceColor','b') 
%   textm(45.2667,-72.0167, sprintf('%s','CARTEL'))
%   
%   plotm(42.4667,-71.2883,'rs','MarkerSize',8,'MarkerFaceColor','b') 
%   textm(42.3667,-71.3883, sprintf('%s','Hanscom')) % near Biller
  
  
%plot grid points
  plotm(44,-69,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. A
  textm(43.9,-69.1, sprintf('%s','A'))
  plotm(44,-68,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. B
  textm(43.9,-68.1, sprintf('%s','B'))
  plotm(44,-67,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. C
  textm(43.9,-67.1, sprintf('%s','C'))
  plotm(43,-70,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. D
  textm(42.9,-70.1, sprintf('%s','D'))
  plotm(43,-69,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. E
  textm(42.9,-69.1, sprintf('%s','E'))
  plotm(43,-68,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. F
  textm(42.9,-68.1, sprintf('%s','F'))
  plotm(43,-67,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. G
  textm(42.9,-67.1, sprintf('%s','G'))
  plotm(43,-66,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. H
  textm(42.9,-66.1, sprintf('%s','H'))
  plotm(43,-65,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. I
  textm(42.9,-65.1, sprintf('%s','I'))
  plotm(42,-69,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. J
  textm(41.9,-69.1, sprintf('%s','J'))
  plotm(42,-68,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. K
  textm(41.9,-68.1, sprintf('%s','K'))
  plotm(42,-67,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. L
  textm(41.9,-67.1, sprintf('%s','L'))
  plotm(42,-66,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. M
  textm(41.9,-66.1, sprintf('%s','M'))
  plotm(42,-65,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. N
  textm(41.9,-65.1, sprintf('%s','N'))



set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
setm(gca,'fontsize',14,'fontweight','bold')
setm(gca,'glinestyle','--','glinewidth',1)
setm(gca,'plabellocation',1,'plinelocation',1)


hidem(gca)
hold on

%plot Pease and ship points
plotm(lat_Pease,lon_Pease,'k*','color','k','MarkerSize',8,'MarkerFaceColor','k')
ht1=textm(lat_Pease+0.1,lon_Pease-0.1,'Pease');
set(ht1,'FontSize',10,'fontweight','bold')
if ~isempty(lat_ship)
   plotm(lat_ship,lon_ship,'k*','MarkerSize',9,'MarkerFaceColor','r')
   ht2=textm(lat_ship-0.1,lon_ship-0.4,'Ron Brown');
   set(ht2,'FontSize',10,'fontweight','bold')
end

xlimits=get(gca,'xlim');
ylimits=get(gca,'ylim');
ht2=text(xlimits(1)+0.07*(xlimits(2)-xlimits(1)),ylimits(2)+0.02*(ylimits(2)-ylimits(1)),title_str);
set(ht2,'fontsize',16,'fontweight','bold')
%scaleruler on
%hsc=handlem('scaleruler');
%setm(hsc,'Xloc',0.0035,'Yloc',0.7459,'linewidth',2,'fontweight','bold','fontsize',11)

plotm(lat_track,lon_track,'k-','linewidth',2)
%plotm(lat_track_MISR,lon_track_MISR,'m-','linewidth',1)

if strcmp(flag_plot_track,'yes')
    cm=colormap(colorlevels);
    jp=find(GPS_Alt<=zcrit(1));
    plotm(Latitude(jp),Longitude(jp),'o','color',cm(1,:),'markersize',msize,'markerfacecolor',cm(1,:))
    hold on
    for i=2:length(zcrit),
        jp=find(GPS_Alt>zcrit(i-1) & GPS_Alt<=zcrit(i));
        plotm(Latitude(jp),Longitude(jp),'o','color',cm(i,:),'markersize',msize,'markerfacecolor',cm(i,:))
    end
    jp=find(GPS_Alt>zcrit(end));
    plotm(Latitude(jp),Longitude(jp),'o','color',cm(length(zcrit)+1,:),'markersize',msize,'markerfacecolor',cm(length(zcrit)+1,:))

    
    ylims=get(gca,'ylim');
    ntim=length(Latitude);
    dely=0.02*(ylims(2)-ylims(1));
    for i=1:floor(ntim/10):ntim-ntim/10,
        plotm(Latitude(i),Longitude(i),'+','color','k','markersize',8,'MarkerFacecolor','k')
        ht=textm(Latitude(i)-.02,Longitude(i),sprintf('%5.2f',UT(i)));
        set(ht,'fontsize',12)
    end
    i=floor(i+(ntim-i)/2);
    plotm(Latitude(i),Longitude(i),'+','color','k','markersize',8,'MarkerFacecolor','k')
    ht=textm(Latitude(i)-.02,Longitude(i),sprintf('%5.2f',UT(i)));
    set(ht,'fontsize',12)

    cb=colorbar;
    set(cb,'yticklabel',[0 zcrit inf],'fontsize',14,'fontweight','bold')
    cbpossav=get(cb,'Position');
    cbpos=cbpossav;
    cbpos(2)=0.23;
    cbpos(3)=0.03;
    cbpos(4)=0.6;
    set(cb,'Position',cbpos)
    xlimits=get(gca,'xlim');
    ylimits=get(gca,'ylim');
    ht2=text(xlimits(2)+0.05*(xlimits(2)-xlimits(1)),ylimits(1)+0.01*(ylimits(2)-ylimits(1)),'Altitude [km]');
    set(ht2,'fontsize',13,'fontweight','bold')
end

