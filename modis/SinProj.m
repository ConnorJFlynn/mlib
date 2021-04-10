function [x,y] = SinProj(latd, lond) 
% Accepts lat and lon and returns MODIS "World Coordinates" x and y in m
% x is for Lon, y is for Lat
  R = 6371007.18100; %Earth's radius
 lon = lond.*pi./180;
 lat = latd.*pi./180; %degree 
 x = lon .*R.*cosd(latd);
 y = lat.*R;
 
end 