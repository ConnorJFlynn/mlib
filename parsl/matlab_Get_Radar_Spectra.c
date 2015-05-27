/* 	This code, given a stream of radar I and Q data returns the
	radar spectra and the first three moments.
*/

/* Matlab Wrapper */ 
#include "mex.h"
#include "math.h"
#include "Get_Radar_Spectra_n_Moments.c"

void mexFunction(
    int           nlhs,           /* number of expected outputs */
    mxArray       *plhs[],        /* array of pointers to output arguments */
    int           nrhs,           /* number of inputs */
#if !defined(V4_COMPAT)
    const mxArray *prhs[]         /* array of pointers to input arguments */
#else
    mxArray *prhs[]         	  /* array of pointers to input arguments */
#endif
)
{
double 	*I_data,*Q_data,*n_fft_pts,*Sampling_interval,*Wavelength,	/* inputs */

	*Spectra,*n_spectra_averaged,				/* outputs */
	*mean_power,*mean_velocity,
	*velocity_width,
	
	*dummy;

int	i,n,mi,ni,dims[2],number_of_fft_pts,n_spectra;

/*
 	if (nrhs != 8) 
           	mexErrMsgTxt("Must have eight input arguments: [Kp] =  Get_Callibration_Coefficient(I_norm,Q_norm,I_cal,Q_cal,pulse_width, Allen_Variance_Length, range, RCS) ");

	if ( mxIsChar(prhs[5]) || mxIsComplex(prhs[5]) || mxIsSparse(prhs[5])){
                mexErrMsgTxt("fifth arguement must be real and nonstring");
	}else{
*/
	if(1==1){
      	   	mi = mxGetM(prhs[0]); /* get the dimensions of the input array */
               	ni = mxGetN(prhs[0]);
		if (mi>1 & ni>1) 
  	              	mexErrMsgTxt("data must be a vector");

		/* Get value of input values ... */
		I_data = mxGetPr(prhs[0]);
		Q_data = mxGetPr(prhs[1]);
		n=mi*ni;

		n_fft_pts = mxGetPr(prhs[2]);
		number_of_fft_pts=(int) *n_fft_pts; /* type cast to value to integer */
		
		Sampling_interval = mxGetPr(prhs[3]);
		Wavelength = mxGetPr(prhs[4]);
		
		/* allocate memory for output variables */
		dims[0]=number_of_fft_pts;
		dims[1]=1;
                plhs[0]=mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
		Spectra=mxGetData(plhs[0]);
	
		dims[0]=1;
		dims[1]=1;
                plhs[1]=mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
		n_spectra_averaged=mxGetData(plhs[1]);

                plhs[2]=mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
		mean_power=mxGetData(plhs[2]);

		plhs[3]=mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
		mean_velocity=mxGetData(plhs[3]);

		plhs[4]=mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
		velocity_width=mxGetData(plhs[4]);

		/* call C subroutine to get Calibration Coefficient */
		dummy=Get_Radar_Spectra_n_Moments(
			I_data,Q_data,n,
			number_of_fft_pts,
			*Sampling_interval, 	
			*Wavelength,

			&n_spectra,		/* outputs */
			mean_power,			
			mean_velocity,		/* mean doppler velocity */
			velocity_width);

		/* copy/convert data for matlab */
		for(i=0;i<number_of_fft_pts;i++){
			Spectra[i]=dummy[i];
		}
		free(dummy); 

		*n_spectra_averaged= (double) n_spectra;
	}
}

