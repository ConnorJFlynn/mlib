/*****************************************************************
*
*   This function returns the running mean of the input array using
*   and window of the specified size.  The routine also returns the
*   index to the minimum in the smoothed data.
*
*   Note: the window size is ASSUMED to be less the the length of
*   the input data.
*
*****************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "compute_running_mean.h"

#define LARGE_LIMIT 1E12 

// compute_running_mean 
//
// Inputs have_
//
float *compute_running_mean(float * data,int n,int half_window_size,int * min_index)
{
int 	i,flag,n_pts;

float	*smoothed_data;
double	factor;
double  	mean,
    		minmean;

	/* allocated memory to temporarily store smoothed data */
	smoothed_data = (float *)malloc(n*sizeof(float));

  	/* get initiale values for mean ... i.e. first window position */
  	mean = 0;
	flag = 0;
	n_pts= 0;
	minmean=LARGE_LIMIT;
  	for (i=0; i<(2*half_window_size+1); i++) {

			if(fabs(data[i])<LARGE_LIMIT){
		    		mean += data[i];	
				n_pts++;
			}	
  	}
	if(n_pts>=2*half_window_size+1){
		factor = 1.0 / (double) (n_pts);
  		smoothed_data[0]=mean*factor; 
	
		if (mean < minmean)
	  		minmean = mean;  	
	}else
		smoothed_data[0]=LARGE_LIMIT;
 
  	*min_index=half_window_size;

  	/* slide the window */
  	for (i=half_window_size+1;i<n-half_window_size; i++) {

		if(fabs(data[i-half_window_size-1])<LARGE_LIMIT){
			mean -= data[i-half_window_size-1];
			n_pts--;
		}

		if(fabs(data[i+half_window_size])<LARGE_LIMIT){
			n_pts++;
    			mean += data[i+half_window_size];
		}

		if(n_pts>=2*half_window_size+1){
			factor = 1.0 / (double) (n_pts);
    			smoothed_data[i]=mean*factor;  /* the actual mean */ ;

	    		/* check for to see if current window position has lower total power */
    			if (mean < minmean) {
    				minmean = mean;
      			*min_index=i;
    			}
		}else
			smoothed_data[0]=LARGE_LIMIT;
  	}

   	/* fill in the first half window with the initial value ...
      	   and the same for the last half window */
  	for(i=1;i<=half_window_size;i++){
	
		smoothed_data[i]=smoothed_data[0];
		smoothed_data[n-i]=smoothed_data[n-half_window_size-1];
  	}

  	return(smoothed_data);
}
