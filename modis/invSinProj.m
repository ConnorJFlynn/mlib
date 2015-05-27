function [lat, long] = invSinProj(x,y) 
% Accepts MODIS world coordinates and returns lat and lon.
% x is longitude in meters relative to 0-deg lon.
% y is latitude in meters relative to equator
  R = 6371007.18100; %Earth's radius
 long_0 = 0;
 lat = y./R;
 long = long_0 + x./(R*cos(lat));
 lat = lat.*180./pi; %degree
 long = long.*180/pi;
end 
 

