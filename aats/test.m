figure(31)
x=geog_long(L_cloud==1);
y=geog_lat(L_cloud==1);
z=real(U(L_cloud==1))/1244;
xi=[-0.03+min(x):0.001:max(x)+0.03];
yi=[-0.03+min(y):0.001:max(y)+0.03];
[XI,YI]=meshgrid(xi,yi);
ZI = griddata(x,y,z,XI,YI,'linear');
[c,h] = contour(XI,YI,ZI,'k-'); clabel(c,h)
hold on
title(sprintf('%s %2i/%2i/%2i %s %3.1f %s' ,site,month,day,year,' CWV(cm) @',mean(r),' km asl'),'FontSize',14)
imagesc([min(min(XI)) max(max(XI))],[min(min(YI)) max(max(YI))],ZI)
[c,h] = contour(XI,YI,ZI,'k-'); clabel(c,h)
plot(geog_long,geog_lat,'w.-')
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
set(gca,'FontSize',14)
plot(31.5850,-24.9720,'mo','MarkerSize',7,'MarkerFaceColor','m') % Skukuza Airport RSA MPL-net
%plot(31.3697,-25.0198,'go','MarkerSize',7,'MarkerFaceColor','g') % Skukuza Tower , RSA Helmlinger GPS
plot(31.5833,-24.9833,'ko','MarkerSize',7,'MarkerFaceColor','k') % Skukuza, RSA  Cimel Holben Spreadsheet
axis square
hold off
axis([31.52 31.718 -25.1 -24.92])
lon=get(gca,'xlim');
lat=get(gca,'ylim');

lon_rng = deg2km(DISTANCE(lat(1),lon(1),lat(1),lon(2)))
lat_rng = deg2km(DISTANCE(lat(1),lon(1),lat(2),lon(1)))

figure(32)
x=geog_long(L_cloud==1);
y=geog_lat(L_cloud==1);
z=tau_aero(5,L_cloud==1);
xi=[-0.03+min(x):0.001:max(x)+0.03];
yi=[-0.03+min(y):0.001:max(y)+0.03];
[XI,YI]=meshgrid(xi,yi);
ZI = griddata(x,y,z,XI,YI,'linear');
[c,h] = contour(XI,YI,ZI,'k-'); clabel(c,h)
hold on
title(sprintf('%s %2i/%2i/%2i %s %3.1f %s' ,site,month,day,year,' AOD @',mean(r),' km asl'),'FontSize',14)

imagesc([min(min(XI)) max(max(XI))],[ min(min(YI)) max(max(YI))],ZI)
[c,h] = contour(XI,YI,ZI,'k-'); clabel(c,h)
plot(geog_long,geog_lat,'w.-')
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
set(gca,'FontSize',14)
plot(31.5850,-24.9720,'mo','MarkerSize',7,'MarkerFaceColor','m') % Skukuza Airport RSA MPL-net
%plot(31.3697,-25.0198,'go','MarkerSize',7,'MarkerFaceColor','g') % Skukuza Tower , RSA Helmlinger GPS
plot(31.5833,-24.9833,'ko','MarkerSize',7,'MarkerFaceColor','k') % Skukuza, RSA  Cimel Holben Spreadsheet
hold off
axis square
axis([31.52 31.718 -25.1 -24.92])
lon=get(gca,'xlim');
lat=get(gca,'ylim');

lon_rng = deg2km(DISTANCE(lat(1),lon(1),lat(1),lon(2)))
lat_rng = deg2km(DISTANCE(lat(1),lon(1),lat(2),lon(1)))