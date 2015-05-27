function sunday(lat, lon, day);
% sun_day = sunday(lat, lon, day);
% sun.time, zen, sun.az, sun.soldst, sun.ha, sun.dec, sun.el, sun.am
%%
if ~exist('day','var')
    day = (now+(-1:.001:.1));
    day = (datenum(2013,02,11)+(-.5:.001:.5));
end
day = (datenum(2013,02,11)+(-.5:.001:.5));
if ~exist('lat','var')
    lat = 46.285833; % PSC
    lat = 41.6701; % Cape Cod, PVC
end
if ~exist('lon','var')
    lon = -119.283333; %PSC
    lon = -70.2898; % Cape Cod, PVC
end

Hh= -floor(lon/15);
Hh= 0; % when providing time in UTC
[zen, az, soldst, ha, dec, el, am] = sunae(lat,lon , day+Hh/24);
am_gt0 = am>0;
am_gt_ii = find(am_gt0);
[min_am, noon_ii] = min(am(am_gt0))
if Hh==0
time_str = 'time UTC';
else 
    time_str = 'time Local';
end
figure;
s(1) = subplot(2,1,1); plot(serial2Hh(day), az,'.',serial2Hh(day(am_gt_ii(noon_ii))),  az(am_gt_ii(noon_ii)),'ro');
title({['Solar azimuth for ',datestr(floor((day(1)+day(end))./2),'yyyy-mm-dd')];[ ' lat=',sprintf('%3.3f',lat), ', lon=',sprintf('%3.3f',lon)]},'interp','none')
xlabel(time_str);ylabel('az angle')
s(2) = subplot(2,1,2); plot(serial2Hh(day), am,'.', serial2Hh(day(am_gt_ii(noon_ii))),  am(am_gt_ii(noon_ii)),'ro');
xlabel(time_str);ylabel('airmass')
linkaxes(s,'x')
%%
return
