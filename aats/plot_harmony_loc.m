figure(100)
orient landscape
subplot(1,2,1)
%plot3(geog_long,geog_lat,Press_Alt, '.k', 'MarkerSize',1,'MarkerFaceColor','k')
%hold on
plot3(geog_long(UT>25.5 & UT<25.7),geog_lat(UT>25.5 & UT<25.7),Press_Alt(UT>25.5 & UT<25.7), 'ob', 'MarkerSize',3,'MarkerFaceColor','b')
hold on
plot3(geog_long(UT>=25.7 & UT<25.9),geog_lat(UT>=25.7 & UT<25.9),Press_Alt(UT>=25.7 & UT<25.9), 'or', 'MarkerSize',3,'MarkerFaceColor','r')
hold on
plot3(geog_long(UT>=25.9 & UT<26.1),geog_lat(UT>=25.9 & UT<26.1),Press_Alt(UT>=25.9 & UT<26.1), 'oc', 'MarkerSize',3,'MarkerFaceColor','c')
hold on
plot3(geog_long(UT>=26.1 & UT<26.3),geog_lat(UT>=26.1 & UT<26.3),Press_Alt(UT>=26.1 & UT<26.3), 'og', 'MarkerSize',3,'MarkerFaceColor','g')
hold on
plot3(geog_long(UT>=26.3 & UT<26.4),geog_lat(UT>=26.3 & UT<26.4),Press_Alt(UT>=26.3 & UT<26.4), 'om', 'MarkerSize',3,'MarkerFaceColor','m')
hold on
plot3(geog_long(UT>=25.66 & UT<25.67),geog_lat(UT>=25.66 & UT<25.67), Press_Alt(UT>=25.66 & UT<25.67), 'ok', 'MarkerSize',3,'MarkerFaceColor','k')
hold on
plot3(geog_long(UT>=25.90 & UT<25.91),geog_lat(UT>=25.90 & UT<25.91), Press_Alt(UT>=25.90 & UT<25.91), 'ok', 'MarkerSize',3,'MarkerFaceColor','k')
xlabel('Longitude')
ylabel('Latitude')
zlabel('Altitude (km)')
grid on
axis([-inf inf -inf inf -inf inf])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
hold on

subplot(1,2,2)

worldmap([min(geog_lat)-.2,max(geog_lat)+.2],[min(geog_long)-.2,max(geog_long)+.2],'patch')
plotm(geog_lat(UT>25.5 & UT<25.7),geog_long(UT>25.5 & UT<25.7), 'ob', 'MarkerSize',3,'MarkerFaceColor','b')
plotm(geog_lat(UT>=25.7 & UT<25.9),geog_long(UT>=25.7 & UT<25.9), 'or', 'MarkerSize',3,'MarkerFaceColor','r')
plotm(geog_lat(UT>=25.9 & UT<26.1),geog_long(UT>=25.9 & UT<26.1), 'oc', 'MarkerSize',3,'MarkerFaceColor','c')
plotm(geog_lat(UT>=26.1 & UT<26.3),geog_long(UT>=26.1 & UT<26.3), 'og', 'MarkerSize',3,'MarkerFaceColor','g')
plotm(geog_lat(UT>=26.3 & UT<26.4),geog_long(UT>=26.3 & UT<26.4), 'om', 'MarkerSize',3,'MarkerFaceColor','m')
plotm(geog_lat(UT>=25.66 & UT<25.67),geog_long(UT>=25.66 & UT<25.67), 'ok', 'MarkerSize',3,'MarkerFaceColor','k')
plotm(geog_lat(UT>=25.90 & UT<25.91),geog_long(UT>=25.90 & UT<25.91), 'ok', 'MarkerSize',3,'MarkerFaceColor','k')

scaleruler on
set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
hidem(gca)
hold on