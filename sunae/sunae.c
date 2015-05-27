#include <math.h>

#include "sunae.h"

/* HISTORY
 *
 * 2/20/2000	js
 *		Fixed 2000 leap year bug.  Code was assuming 2000 was *not* a leap year
 */

#ifdef SUNAETEST
#include <stdio.h>
#endif

double sunae(ae_pack *aep)
{
    double	delta, leap, jd, tm, mnlong, mnanom, eclong, oblqec,
		num, den, ra, lat, sd, cd, sl, cl, gmst, lmst, refrac,
		el_deg, tst,
		airmass(double el);
    int		year;

    year = aep->year < 200 ? aep->year+1900 : aep->year;

#ifdef SUNAETEST
fprintf(stderr, "yr=%d doy=%d lat=%.3f lon=%.3f hour=%.3f\n", year, aep->doy,
	aep->lat, aep->lon, aep->hour);
#endif

    delta = year - 1949.0;
    leap = (int) (0.25 * delta);
    jd = 32916.5 + delta*365.0 + leap + aep->doy + aep->hour/24.0;

    /*
    ** "the last year of a century is not a leap year therefore"
    **
    ** Actually, it is sometimes.  --js
    */
    if (year % 100 == 0 && year % 400 != 0)
	jd -= 1.0;

    tm = jd - 51545.0;
#ifdef SUNAETEST
fprintf(stderr, "delta=%f leap=%f jd=%f tm=%f\n", delta, leap, jd, tm);
#endif
    mnlong = fmod(280.460 + 0.9856474*tm, 360.0);
    if (mnlong < 0.0)
	mnlong += 360.0;

    mnanom = fmod(357.528 + 0.9856003*tm, 360.0);
    mnanom *= M_DTOR;

    eclong = fmod(mnlong + 1.915*sin(mnanom) + 0.020*sin(2.0*mnanom), 360.0);
    eclong *= M_DTOR;

    oblqec = 23.439 - 0.0000004*tm;
    oblqec *= M_DTOR;

    num = cos(oblqec)*sin(eclong);
    den = cos(eclong);
    ra = atan(num/den);

    /* force ra between 0 and 2*pi */
    if (den < 0.0)
	ra += M_PI;
    else if (num < 0.0)
	ra += M_2PI;
#ifdef SUNAETEST
fprintf(stderr, "mnlong=%f mnanom=%f eclong=%f oblqec=%f ra=%f\n",
		mnlong, mnanom, eclong, oblqec, ra);
#endif
    /* dec in radians */
    aep->dec = asin(sin(oblqec)*sin(eclong));

    /* calculate Greenwich mean sidereal time in hours */
    gmst = fmod(6.697375 + 0.0657098242*tm + aep->hour, 24.0);

    /* calculate local mean sidereal time in radians  */
    lmst = fmod(gmst + aep->lon*M_DTOH, 24.0);
    lmst = lmst*M_HTOR;

    /* calculate hour angle in radians between -pi and pi */
    aep->ha = lmst - ra;
    if (aep->ha < -M_PI)
	aep->ha += M_2PI;
    if (aep->ha > M_PI)
	aep->ha -= M_2PI;
#ifdef SUNAETEST
fprintf(stderr, "dec=%f gmst=%f lmst=%f ha=%f\n", aep->dec, gmst, lmst, aep->ha);
#endif
    /* change latitude to radians */
    lat = aep->lat*M_DTOR;
    sd = sin(aep->dec);
    cd = cos(aep->dec);
    sl = sin(lat);
    cl = cos(lat);

    /* calculate azimuth and elevation */
    aep->el = asin(sd*sl + cd*cl*cos(aep->ha));
    aep->az = asin(-cd*sin(aep->ha)/cos(aep->el));

    /* this puts azimuth between 0 and 2*pi radians */
    if (sd - sin(aep->el)*sl >= 0.0) {
	if(sin(aep->az) < 0.0)
	    aep->az += M_2PI;
    } else
	aep->az = M_PI - aep->az;


    /* calculate refraction correction for US stan. atmosphere */

    /* Refraction correction and airmass updated on 11/19/93 */
 
    /* need to have el in degs before calculating correction */
    el_deg = aep->el * M_RTOD;
    
    if (el_deg >= 19.225)
        refrac = 0.00452 * 3.51823/tan(aep->el);

    else if (el_deg > -0.766 && el_deg < 19.225)
        refrac = 3.51823*(0.1594 + 0.0196*el_deg + 0.00002 * el_deg*el_deg) /
                         (1.0 + 0.505 * el_deg + 0.0845 * el_deg*el_deg);
    else
        refrac = 0.0;

    el_deg += refrac;
    aep->el = el_deg * M_DTOR;

    /* 
     * old refraction equations
     *
     * if (aep->el > -0.762)
     *   refrac = 3.51561*(0.1594 + 0.0196*aep->el + 0.00002*aep->el*aep->el) /
     *     (1.0 + 0.505*aep->el + 0.0845*aep->el*aep->el);
     * else
     *	 refrac = 0.762;
     */

    /* note that 3.51561=1013.2 mb/288.2 C */

    /* calculate distance to sun in A.U. & diameter in degs */
    aep->soldst = 1.00014 - 0.01671*cos(mnanom) - 0.00014*cos(mnanom + mnanom);

    aep->am = airmass(el_deg);


    /* convert back to radians - return EVERYTHING in radians */

    /* do zenith angle */

    aep->zen = M_PI/2.0 - aep->el;

    tst = 12.0 + aep->ha*M_RTOH;
    if (tst < 0.0)
	tst += 24.0;
    if (tst >= 24.0)
	tst -= 24.0;

#ifdef SUNAETEST
fprintf(stderr, "az=%.2f el=%.2f ha=%.2f dec=%.2f soldst=%.2f am=%.3f\n",
	M_RTOD*aep->az, M_RTOD*aep->el, M_RTOD*aep->ha,
	M_RTOD*aep->dec, aep->soldst, aep->am);
#endif

    return tst;
}



double airmass(double el)    /* elevation given in degrees */
{
    double	zr;

    if(el < 0.0)  /* sun below the horizon */
	return(-1.0);

    zr = M_DTOR * (90.0 - el);
    return 1.0/(cos(zr) + 0.50572*pow(6.07995 + el, -1.6364));
}
