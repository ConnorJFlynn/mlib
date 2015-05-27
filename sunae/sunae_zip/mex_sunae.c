#include <stdio.h>
#include "sunae.h"
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
    ae_pack sunae_struct;  // Data structure.
    double result;  // Result from calculation.

    // Check input parameters.
    if (nrhs < 5) {
        printUsage(mexFunctionName());
        mexErrMsgIdAndTxt(
            "SUNAE:ArgumentError",
            "Too few input arguments to %s: %d",
            mexFunctionName(), nrhs);
    }

    // Check output parameters.
    if (nlhs < 7) {
        printUsage(mexFunctionName());
        mexErrMsgIdAndTxt(
            "SUNAE:ArgumentError",
            "Too few output arguments to %s: %d",
            mexFunctionName(), nlhs);
    }

    /*
     * PROCESS INPUT
     *********************/

    // Get required input values and populate structure.
    sunae_struct.year  = (int)(mxGetScalar(prhs[0]));
    sunae_struct.doy   = (int)(mxGetScalar(prhs[1]));
    sunae_struct.hour  = (double)(mxGetScalar(prhs[2]));
    sunae_struct.lat   = (double)(mxGetScalar(prhs[3]));
    sunae_struct.lon   = (double)(mxGetScalar(prhs[4]));
    
    /*
     * CALL C INTERFACE
     *********************/

    // Call the SUNAE calculate function.
    result = sunae(&sunae_struct);

    /*
     * PROCESS OUTPUT
     *********************/

    // Set output values.
    plhs[0] = mxCreateDoubleScalar(sunae_struct.az);
    plhs[1] = mxCreateDoubleScalar(sunae_struct.el);
    plhs[2] = mxCreateDoubleScalar(sunae_struct.ha);
    plhs[3] = mxCreateDoubleScalar(sunae_struct.dec);
    plhs[4] = mxCreateDoubleScalar(sunae_struct.zen);
    plhs[5] = mxCreateDoubleScalar(sunae_struct.soldst);
    plhs[6] = mxCreateDoubleScalar(sunae_struct.am);

    // Done.
    return;
}

void printUsage(const char *progName)
{
    printf("%s INPUT:", progName);
    printf("\n");
    printf("  1 >> year\n");
    printf("  2 >> julian day\n");
    printf("  3 >> hour\n");
    printf("  4 >> latitude\n");
    printf("  5 >> longitude\n");
    printf("\n\n");
    printf("%s OUTPUT:", progName);
    printf("\n");
    printf("  1 >> azimuth\n");
    printf("  2 >> elevation\n");
    printf("  3 >> hour angle\n");
    printf("  4 >> declination\n");
    printf("  5 >> solar distance\n");
    printf("  6 >> zenith\n");
    printf("  7 >> air mass\n");
    printf("\n\n");
    printf("%s EXAMPLE:", progName);
    printf("\n");
    printf("  [az,\n");
    printf("   el,\n");
    printf("   ha,\n");
    printf("   dec,\n");
    printf("   zen,\n");
    printf("   soldst,\n");
    printf("   am] = %s(\n", progName);
    printf("            2003,\n");
    printf("            128,\n");
    printf("            10,\n");
    printf("            39.742476,\n");
    printf("            -105.1786)\n");
    printf("\n");
}
