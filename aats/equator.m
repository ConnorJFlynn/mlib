function [declination, ra]=equator(jd,ecl_long);

% This procedure converts ecliptical sun coordinates in equatorial
% coordinates 
% Written 14.7.1995 by B. Schmid

  e=obliquity(jd);
  declination= asin(sin(e/180*pi).*sin(ecl_long/180*pi))*180/pi;
  x= cos(ecl_long/180*pi);
  y= sin(ecl_long/180*pi).*cos(e/180*pi);
  ra=(atan2beat(x,y))/15;
