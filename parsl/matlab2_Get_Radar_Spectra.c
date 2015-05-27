/* 	This code, given a stream of radar I and Q data returns the
	radar spectra and the first three moments.
*/

/* Matlab Wrapper */ 
#include "mex.h"
#include "math.h"
#include "four2_double.c"
#include "compute_running_mean.c"
#include "estimate_noise_floor.c"
#include "Get2_Radar_Spectra_n_Moments.c"

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
int16  *I_data16, *Q_data16;

double 	*I_data,*Q_data,*n_fft_pts;

double	*Sampling_interval,*Wavelength;		/* inputs */
float	f_Sampling_interval, f_Wavelength;

double	*Spectra,*n_spectra_averaged,				/* outputs */
	*mean_power,*mean_velocity,*velocity_width;
	
float	f_mean_power,f_mean_velocity,f_velocity_width,value;

float	*dummy, *work_space, *fft_velocity;

	

int	i,n,mi,ni,dims[2],number_of_fft_pts,n_spectra;


	if(1==1){

      	   	mi = mxGetM(prhs[0]); /* get the dimensions of the input array */
               	ni = mxGetN(prhs[0]);
		if (mi>1 & ni>1) 
  	              	mexErrMsgTxt("data must be a vector");

		/* Get value of input values ... */
		I_data = mxGetPr(prhs[0]);
		Q_data = mxGetPr(prhs[1]);
		n=mi*ni;

		I_data16=(int16 *) calloc( (int) n , sizeof(int16));
		Q_data16=(int16 *) calloc( (int) n , sizeof(int16));
		
		for(i=0;i<n;i++){
			I_data16[i]=(int16) I_data[i];
			Q_data16[i]=(int16) Q_data[i];
		}
			
		n_fft_pts = mxGetPr(prhs[2]);
		number_of_fft_pts=(int) *n_fft_pts; /* type cast to value to integer */
		
		work_space   = (float *) malloc(2*number_of_fft_pts * sizeof(float));
		fft_velocity = (float *) malloc(number_of_fft_pts * sizeof(float));
		dummy= (float *) calloc( (int) number_of_fft_pts, sizeof(float));

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

		f_Sampling_interval=(float ) *Sampling_interval;
		f_Wavelength=(float ) *Wavelength;

		/* Calculate velocities in fft ... do it here once instead of many times, later */
		value=(0.5*f_Wavelength)/(number_of_fft_pts*f_Sampling_interval);

		for(i=0;i<number_of_fft_pts;i++)
		{
			/* calculated velocity of the i-th point */
			if(i<0.5*number_of_fft_pts)
				fft_velocity[i]=i*value;
			else
				fft_velocity[i]=(i-number_of_fft_pts)*value;
			
		}


		Get_Radar_Spectra_n_Moments(
							I_data16,  
							Q_data16,
							n,
							1,
							number_of_fft_pts,
							f_Sampling_interval, 	
							f_Wavelength,

							dummy,
							fft_velocity,
							&n_spectra,
							&(f_mean_power),
							&(f_mean_velocity),
							&(f_velocity_width),
							work_space );
		

		/* copy/convert data for matlab */
		for(i=0;i<number_of_fft_pts;i++){
			Spectra[i]=dummy[i];
		}
		free(dummy); 

		*n_spectra_averaged= (double) n_spectra;
		*mean_power=(double) f_mean_power;
		*mean_velocity=(double) f_mean_velocity;
		*velocity_width=(double) f_velocity_width;
	}
}

