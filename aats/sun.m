function [azimuth, altitude,r]=sun(geog_long, geog_lat,day, month, year, ut,temp,press);
%  This procedure calculates topocentric coordinates of the Sun. Calculations
%  are based on " Practical Astronomy with your calculator ", Peter Duffett-
%  Smith. Validity has been checked in comparison with a BASIC-Library writ-
%  ten by the same author.
%  Input:  geog. longitude (deg +E) and latitude, day, month, year (YYYY), 
%          UT (dec. hours), temperature (Kelvin) and pressure (hPa)
%  Output: azimuth (N = 0, E = 90, S = 180 degrees) and altitude
%  Uses: julian.m, utgst.m, gstlst.m, ecliptic.m, obliquit.m, equator.m,
%        eqhor.m, refrac.m, atan2bea.m        
%  Written 14.7.1995 by B. Schmid

 jd=julian(day, month, year, ut);
 ecl_long=ecliptic(jd);
 [declination, ra]=equator(jd,ecl_long);
 [azimuth, altitude]=eqhor(day,month,year,ut, ra, declination, geog_long, geog_lat);
 r=refrac(temp,press,altitude);
 altitude=altitude+r;
 