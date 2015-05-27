function [azimuth, altitude]=eqhor(day,month,year, ut, ra, declination, geog_long, geog_lat);
% this procedure converts equatorial sun coordinates in horizontal
%  coordinates (Duffet chap. 25)}
% Written 14.7.1995 by B. Schmid
gst=utgst (day, month, year, ut);
lst=gstlst(gst, ut, geog_long);
hour_angle= lst - ra;
i=find(hour_angle<0);
hour_angle(i)=hour_angle(i)+24;
hour_angle=hour_angle*15;
altitude=asin (sin(declination/180*pi).*sin(geog_lat/180*pi)+cos(declination/180*pi)...
           .*cos(geog_lat/180*pi).*cos(hour_angle/180*pi))*180/pi;
x= sin(declination/180*pi)-sin(geog_lat/180*pi).*sin(altitude/180*pi);
y=-cos(declination/180*pi).*cos(geog_lat/180*pi).*sin(hour_angle/180*pi);
azimuth= atan2beat(x,y);

