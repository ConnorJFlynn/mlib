function [zen, az, soldst, ha, dec, el, am] = sunae(lat, lon, time);
%[zen, az, soldst, ha, dec, el, am] = sunae(lat, lon, time);
% Requires lat (pos N) and lon (pos E).  If no time is supplied, now is assumed.
% Returns zenith angle, azimuth angle, solar distance in AU, hour
% angle, declination angle, elevation angle, and airmass
% All angles in degrees, airmass = NaN for el < 0
if nargin <2
   disp('sunae requires at least the lat and lon')
   return
end
if nargin<3
   time = now;
end
if max(size(lat))==1
   lat = ones(size(time))*lat;
end
if max(size(lon))==1
   lon = ones(size(time))*lon;
end
[Y,MO,D,H,MI,S] = datevec(time);
doy1 = (serial2doy1(time));
hour = rem(doy1,1)*24;
%hour = H + MI/60 + S/(60*60);

for t =length(time):-1:1
[az(t), el(t), ha(t), dec(t), zen(t), soldst(t), am(t)] = sunae_mex(floor(Y(t)), floor(doy1(t)), hour(t),  lat(t), lon(t));
end
az = 180*az/pi;
el = 180*el/pi;
ha = 180*ha/pi;
dec = 180*dec/pi;
zen = 180*zen/pi;
neg = find(am<0);
am(neg) = NaN;