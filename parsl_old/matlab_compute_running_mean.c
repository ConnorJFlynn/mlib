
/*
To make matlab executable
mex -I/usr/local/include -L/usr/local/lib -lm matlab_compute_running_mean.c
*/

/* Matlab Wrapper */
#include <mex.h>

/* C - source routine we are mapping into matlab */
#include "compute_running_mean.c"

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
double	*d_data,*d_Half_Window;

float	*f_data;
int	 n,half_window_size,i=1;

float	*f_smoothed_data;
int	min_index;

double  *d_smoothed_data, *d_min_index;


	if(nrhs < 2) 
           	mexErrMsgTxt("Must have at two input arguments: \n matlab_compute_running_mean(data,half_window_size)");

	/* get inputs */
	d_data=mxGetPr(prhs[0]);
	d_Half_Window=mxGetPr(prhs[1]);
	n=mxGetM(prhs[0]) * mxGetN(prhs[0]);

	if( n < (2*(*d_Half_Window)+1) )
		mexErrMsgTxt("Window size too large or Data array too small!");

	/* convert to need types compute_running_mean for */
	f_data=(float *)malloc(n*sizeof(float));
	half_window_size = (int) *d_Half_Window	;

	/* get outputs array space */
	plhs[0]=mxCreateNumericArray(1.0,&n,mxDOUBLE_CLASS,mxREAL);
	d_smoothed_data=mxGetData(plhs[0]);
	plhs[1]=mxCreateNumericArray(1.0,&i,mxDOUBLE_CLASS,mxREAL);
	d_min_index=mxGetData(plhs[1]);
	
	for(i=0;i<n;i++)
		f_data[i]= (float) d_data[i];

	f_smoothed_data=compute_running_mean(f_data,n,half_window_size,&min_index);

	for(i=0;i<n;i++)
		d_smoothed_data[i]= (double) f_smoothed_data[i];

	*d_min_index=(double) min_index;

	free(f_data);
	free(f_smoothed_data);
}
