#include <stdio.h>
#include "spa.h"
#include "mex.h"

void printUsage(const char *progName);

/*
 * mexFunction() - interface between Matlab and C functions.
 *
 *   nlhs - number of left-hand side arguments (outputs).
 *   plhs - array holding pointers to return values.
 *   nrhs - number of right-hand side arguments (inputs).
 *   prhs - array holding pointers to input values.
 *
 ********************************************************************************/
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    spa_data spa;   // SPA data structure.
    int result;     // Result from calculation.

    // Check input parameters.
    if (nrhs < 16) {
        printUsage(mexFunctionName());
        mexErrMsgIdAndTxt(
            "SPA:ArgumentError",
            "Too few input arguments to %s: %d",
            mexFunctionName(), nrhs);
    }

    // Check output parameters.
    if (nlhs < 14) {
        printUsage(mexFunctionName());
        mexErrMsgIdAndTxt(
            "SPA:ArgumentError",
            "Too few output arguments to %s: %d",
            mexFunctionName(), nlhs);
    }

    /*
     * PROCESS INPUT
     *********************/

    // Get required input values and populate structure.
    spa.year          = (int)(mxGetScalar(prhs[0]));
    spa.month         = (int)(mxGetScalar(prhs[1]));
    spa.day           = (int)(mxGetScalar(prhs[2]));
    spa.hour          = (int)(mxGetScalar(prhs[3]));
    spa.minute        = (int)(mxGetScalar(prhs[4]));
    spa.second        = (double)(mxGetScalar(prhs[5]));
    spa.timezone      = (float)(mxGetScalar(prhs[6]));
    spa.delta_t       = (float)(mxGetScalar(prhs[7]));
    spa.longitude     = (float)(mxGetScalar(prhs[8]));
    spa.latitude      = (float)(mxGetScalar(prhs[9]));
    spa.elevation     = (float)(mxGetScalar(prhs[10]));
    spa.pressure      = (float)(mxGetScalar(prhs[11]));
    spa.temperature   = (float)(mxGetScalar(prhs[12]));
    spa.slope         = (float)(mxGetScalar(prhs[13]));
    spa.azm_rotation  = (float)(mxGetScalar(prhs[14]));
    spa.atmos_refract = (float)(mxGetScalar(prhs[15]));

    // Default to all for now...
    spa.function      = SPA_ALL;

    /*
     * CALL C INTERFACE
     *********************/

    // Call the SPA calculate function.
    result = spa_calculate(&spa);

    // Check for error.
    if (result != 0) {
        mexErrMsgIdAndTxt("SPA:FunctionError","Error Code: %d", result);
    }

    /*
     * PROCESS OUTPUT
     *********************/

    // Set output values.
    plhs[0]     = mxCreateDoubleScalar(spa.jd);
    plhs[1]     = mxCreateDoubleScalar(spa.l);
    plhs[2]     = mxCreateDoubleScalar(spa.b);
    plhs[3]     = mxCreateDoubleScalar(spa.r);
    plhs[4]     = mxCreateDoubleScalar(spa.del_psi);
    plhs[5]     = mxCreateDoubleScalar(spa.del_epsilon);
    plhs[6]     = mxCreateDoubleScalar(spa.epsilon);
    plhs[7]     = mxCreateDoubleScalar(spa.h);
    plhs[8]     = mxCreateDoubleScalar(spa.zenith);
    plhs[9]     = mxCreateDoubleScalar(spa.azimuth);
    plhs[10]    = mxCreateDoubleScalar(spa.incidence);
    plhs[11]    = mxCreateDoubleScalar(spa.sunrise);
    plhs[12]    = mxCreateDoubleScalar(spa.suntransit);
    plhs[13]    = mxCreateDoubleScalar(spa.sunset);


    // Done.
    return;
}

void printUsage(const char *progName)
{
    printf("%s INPUT:", progName);
    printf("\n");
    printf("  1 >> 4-digit year,    valid range: -2000 to 6000, error code: 1\n");
    printf("  2 >> 2-digit month,         valid range: 1 to 12, error code: 2\n");
    printf("  3 >> 2-digit day,           valid range: 1 to 31, error code: 3\n");
    printf("  4 >> Observer local hour,   valid range: 0 to 24, error code: 4\n");
    printf("  5 >> Observer local minute, valid range: 0 to 59, error code: 5\n");
    printf("  6 >> Observer local second, valid range: 0 to 59, error code: 6\n");
    printf("\n");
    printf("  7 >> Observer time zone (negative west of Greenwich)\n");
    printf("       valid range: -12   to   12 hours,   error code: 8\n");
    printf("\n");
    printf("  8 >> Difference between earth rotation time and terrestrial time\n");
	printf("            (from observation)\n");
	printf("       valid range: -8000 to 8000 seconds, error code: 7\n");
	printf("\n");
    printf("  9 >> Observer longitude (negative west of Greenwich)\n");
    printf("       valid range: -180  to  180 degrees, error code: 9\n");
    printf("\n");
    printf(" 10 >> Observer latitude (negative south of equator)\n");
    printf("       valid range: -90   to   90 degrees, error code: 10\n");
    printf("\n");
    printf(" 11 >> Observer elevation [meters]\n");
    printf("       valid range: -6500000 or higher meters,    error code: 11\n");
    printf("\n");
    printf(" 12 >> Annual average local pressure [millibars]\n");
    printf("       valid range:    0 to 5000 millibars,       error code: 12\n");
    printf("\n");
    printf(" 13 >> Annual average local temperature [degrees Celsius]\n");
    printf("       valid range: -273 to 6000 degrees Celsius, error code; 13\n");
    printf("\n");
    printf(" 14 >> Surface slope (measured from the horizontal plane)\n");
    printf("       valid range: -360 to 360 degrees, error code: 14\n");
    printf("\n");
    printf(" 15 >> Surface azimuth rotation (measured from south to projection of\n");
    printf("            surface normal on horizontal plane, negative west)\n");
    printf("       valid range: -360 to 360 degrees, error code: 15\n");
    printf("\n");
    printf(" 16 >> Atmospheric refraction at sunrise and sunset (0.5667 deg is typical)\n");
    printf("       valid range: -10  to  10 degrees, error code: 16\n");
    printf("\n\n");
    printf("%s OUTPUT:", progName);
    printf("\n");
    printf("  1 >> Julian day\n");
    //printf("  2 >> Julian century\n");
    //printf("\n");
    //printf("  3 >> Julian ephemeris day\n");
    //printf("  4 >> Julian ephemeris century\n");
    //printf("  5 >> Julian ephemeris millennium\n");
    //printf("\n");
    printf("  2 >> earth heliocentric longitude [degrees]\n");
    printf("  3 >> earth heliocentric latitude [degrees]\n");
    printf("  4 >> earth radius vector [Astronomical Units, AU]\n");
    //printf("\n");
    //printf("  9 >> geocentric longitude [degrees]\n");
    //printf(" 10 >> geocentric latitude [degrees]\n");
    //printf("\n");
    //printf(" 11 >> mean elongation (moon-sun) [degrees]\n");
    //printf(" 12 >> mean anomaly (sun) [degrees]\n");
    //printf(" 13 >> mean anomaly (moon) [degrees]\n");
    //printf(" 14 >> argument latitude (moon) [degrees]\n");
    //printf(" 15 >> ascending longitude (moon) [degrees]\n");
    //printf("\n");
    printf("  5 >> nutation longitude [degrees]\n");
    printf("  6 >> nutation obliquity [degrees]\n");
    //printf(" 18 >> ecliptic mean obliquity [arc seconds]\n");
    printf("  7 >> ecliptic true obliquity  [degrees]\n");
    //printf("\n");
    //printf(" 20 >> aberration correction [degrees]\n");
    //printf(" 21 >> apparent sun longitude [degrees]\n");
    //printf(" 22 >> Greenwich mean sidereal time [degrees]\n");
    //printf(" 23 >> Greenwich sidereal time [degrees]\n");
    //printf("\n");
    //printf(" 24 >> geocentric sun right ascension [degrees]\n");
    //printf(" 25 >> geocentric sun declination [degrees]\n");
    //printf("\n");
    //printf(" 26 >> observer hour angle [degrees]\n");
    //printf(" 27 >> sun equatorial horizontal parallax [degrees]\n");
    //printf(" 28 >> sun right ascension parallax [degrees]\n");
    //printf(" 29 >> topocentric sun declination [degrees]\n");
    //printf(" 30 >> topocentric sun right ascension [degrees]\n");
    //printf(" 31 >> topocentric local hour angle [degrees]\n");
    //printf("\n");
    //printf(" 32 >> topocentric elevation angle (uncorrected) [degrees]\n");
    //printf(" 33 >> atmospheric refraction correction [degrees]\n");
    //printf(" 34 >> topocentric elevation angle (corrected) [degrees]\n");
    //printf("\n");
    //printf(" 35 >> equation of time [minutes]\n");
    //printf(" 36 >> sunrise hour angle [degrees]\n");
    //printf(" 37 >> sunset hour angle [degrees]\n");
    //printf(" 38 >> sun transit altitude [degrees]\n");
    //printf("\n");
    printf("  8 >> topocentric zenith angle [degrees]\n");
    //printf(" 40 >> topocentric azimuth angle (westward from south) [-180 to 180 degrees]\n");
    printf("  9 >> topocentric azimuth angle (eastward from north) [   0 to 360 degrees]\n");
    printf(" 10 >> surface incidence angle [degrees]\n");
    //printf("\n");
    //printf(" 43 >> local sun transit time (or solar noon) [fractional hour]\n");
    printf(" 11 >> local sunrise time (+/- 30 seconds) [fractional hour]\n");
    printf(" 12 >> local sun transit time (or solar noon) [fractional hour]\n");
    printf(" 13 >> local sunset time (+/- 30 seconds) [fractional hour]\n");
    printf("\n\n");
    printf("%s EXAMPLE:", progName);
    printf("\n");
    printf("  [jd,");
    printf("   l,");
    printf("   b,");
    printf("   r,");
    printf("   del_psi,");
    printf("   del_epsilon,");
    printf("   epsilon,");
    printf("   h,");
    printf("   zenith,");
    printf("   azimuth,");
    printf("   incidence,");
    printf("   sunrise,");
    printf("   suntransit,");
    printf("   sunset] = %s(", progName);
    printf("            2003,");
    printf("            10,");
    printf("            17,");
    printf("            12,");
    printf("            30,");
    printf("            30,");
    printf("            -7.0,");
    printf("            67,");
    printf("            -105.1786,");
    printf("            39.742476,");
    printf("            1830.14,");
    printf("            820,");
    printf("            11,");
    printf("            30,");
    printf("            -10,");
    printf("            -17,");
    printf("            0.5667)");
    printf("\n");
}
