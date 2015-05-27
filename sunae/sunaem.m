function [zen, az, soldst, ha, dec, el, am] = sunaem(lat, lon, time);
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

M_DTOR = pi./180; %0.0174532925199433;
M_RTOD = 1./M_DTOR; %57.2957795130823230;
M_2PI =	2.*pi; %6.2831853071795862320E0;
M_HTOD = 15.0;
M_DTOH = 1./M_HTOD; %0.0666666666666667;
M_HTOR = M_HTOD.*M_DTOR; %0.2617993877991494;
M_RTOH = 1./M_HTOR; %3.8197186342054881;

[year,MO,D,H,MI,S] = datevec(time);
doy1 = (serial2doy1(time));
% hour = rem(doy1,1)*24;
%hour = H + MI/60 + S/(60*60);

delta = year - 1949.0;
leap = double(mod(delta,4)==0);
jd = 32916.5 + delta*365.0 + leap + doy1;
%
%  "the last year of a century is not a leap year therefore"
%  Actually, it is sometimes.  --js
%
if mod(year,100) == 0 && mod(year, 400) ~= 0
    jd = jd - 1.0;
end
tm = jd - 51545.0;

mnlong = mod(280.460 + 0.9856474.*tm, 360.0);
mnlong(mnlong < 0.0) = mnlong(mnlong < 0.0)+ 360.0;

mnanom = mod(357.528 + 0.9856003.*tm, 360.0);
mnanom = mnanom .* M_DTOR;

eclong = mod(mnlong + 1.915.*sin(mnanom) + 0.020.*sin(2.0.*mnanom), 360.0);
eclong  = eclong .* M_DTOR;

oblqec = 23.439 - 0.0000004.*tm;
oblqec = oblqec .* M_DTOR;

num = cos(oblqec).*sin(eclong);
den = cos(eclong);

ra = atan(num./den) + double(den<0).*pi + double(((den >= 0.0)&(num<0))).*M_2PI  ;
 
%         /* dec in radians */
dec = asin(sin(oblqec).*sin(eclong));

%     /* calculate Greenwich mean sidereal time in hours */
gmst = mod(6.697375 + 0.0657098242.*tm + serial2Hh(time), 24.0);

%     /* calculate local mean sidereal time in radians  */
lmst = mod(gmst + lon.*M_DTOH, 24.0);
lmst = lmst.*M_HTOR;

%     /* calculate hour angle in radians between -pi and pi */
ha = lmst - ra;
ha(ha < -pi) =  ha(ha < -pi) + M_2PI;
ha(ha > pi) =  ha(ha > pi) - M_2PI;

lat = lat.*M_DTOR;
sd = sin(dec);
cd = cos(dec);
sl = sin(lat);
cl = cos(lat);

%     /* calculate azimuth and elevation */
el = asin(sd.*sl + cd.*cl.*cos(ha));
az = asin(-cd.*sin(ha)./cos(el));

%     /* this puts azimuth between 0 and 2*pi radians */
neg = sin(az)<0;
az((sd - sin(el)*sl >= 0.0)&neg) = az((sd - sin(el)*sl >= 0.0)&neg) + M_2PI;
az((sd - sin(el)*sl >= 0.0)&~neg) = pi - az((sd - sin(el)*sl >= 0.0)&~neg) ;

% if (sd - sin(el)*sl >= 0.0)
%     if(sin(az) < 0.0)
%         az += M_2PI;
%     else
%         az = M_PI - az;
%     end
% end    
%     /* calculate refraction correction for US stan. atmosphere */

%     /* Refraction correction and airmass updated on 11/19/93 */

%     /* need to have el in degs before calculating correction */
el_deg = el .* M_RTOD;
refrac = zeros(size(time));
refrac((el_deg >= 19.225)) = 0.00452 .* 3.51823./tan(el(el_deg >= 19.225));
mid = (el_deg > -0.766 && el_deg < 19.225);
refrac(mid) = 3.51823 .* ...
    (0.1594 + 0.0196.*el_deg(mid) + 0.00002 .* el_deg(mid).^2) ./ ...
        (1.0 + 0.505 .* el_deg(mid) + 0.0845 .* el_deg(mid).^2);
el_deg = el_deg + refrac;
el = el_deg .* M_DTOR;

%     /*
%      * old refraction equations
%      *
%      * if (el > -0.762)
%      *   refrac = 3.51561*(0.1594 + 0.0196*el + 0.00002*el*el) /
%      *     (1.0 + 0.505*el + 0.0845*el*el);
%      * else
%      *	 refrac = 0.762;
%      */
%     /* note that 3.51561=1013.2 mb/288.2 C */
%     /* calculate distance to sun in A.U. & diameter in degs */
soldst = 1.00014 - 0.01671.*cos(mnanom) - 0.00014.*cos(mnanom + mnanom);

am = airmass_mol(el_deg);


%     /* convert back to radians - return EVERYTHING in radians */

%     /* do zenith angle */

zen = pi./2.0 - el;

tst = 12.0 + ha*M_RTOH;
tst(tst<0) = tst(tst<0)+24;
tst(tst>24) = tst(tst>24)-24;

az = 180*az/pi;
el = 180*el/pi;
ha = 180*ha/pi;
dec = 180*dec/pi;
zen = 180*zen/pi;
neg = find(am<0);
am(neg) = NaN;

return

    function am = airmass_mol(el)
        % am = airmass_mol(el)
        %  elevation given in degrees */
        zr = (pi./180) .* (90.0 - el);
        am =  1.0./(cos(zr) + 0.50572.*(6.07995 + el).^-1.6364);
        am(el<0) = -1;
        return
        