% 
% test sunaem against AATS sun codes.
lat = 46.3;
lon = -119.3;
alt = 300;
test_time = datenum('2011-07-27 15:53:00','yyyy-mm-dd HH:MM:SS');

% [jms.zen, jms.az, jms.soldst, jms.ha, jms.dec, jms.el, jms.am] = sunaem(lat, lon, test_time);
%%
locs.latitude = lat;
locs.longitude = lon;
locs.altitude = alt;
this_tv = serial2gm(test_time);
sunp = sun_position(this_tv,locs); 
%%
% time.year = 2003;
% time.month = 10;
% time.day = 17;  
% time.hour = 12;
% time.min = 30;
% time.sec = 30;
% time.UTC = -7;

[azimuth, elevation,r] =sun(lon, lat,this_tv.day, this_tv.month, this_tv.year, serial2Hh(test_time),283,1010);
%%
 jd=julian(this_tv.day, this_tv.month, this_tv.year, -7);
 ecl_long=ecliptic(jd);
 [declination, ra]=equator(jd,ecl_long);
 [azimuth, elevation]=eqhor(this_tv.day,this_tv.month,this_tv.year,0, ra, declination, 0, 0);
 r=refrac(283,1010,elevation);
 elevation=elevation+r;


