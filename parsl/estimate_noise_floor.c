/*****************************************************************
*
*   This function estimates the mean noise level and 1 standard
*   deviation of the noise.  
*
*   The algorithm works by sliding a window of size "window_size" over
*   the range (firstgate,lastgate) to find the region in the ARRAY raw_power
*   with the minimum mean value.  The routine also returns the variance
*   of the signal in this region and the index which correspondes to the
*   first point in the region (start_gate).
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>


#include <math.h>


#include "estimate_noise_floor.h"
#include "compute_running_mean.h"

void estimate_noise_floor(float * raw_power, int firstgate, int lastgate, int window_size,
                          int * min_gate, float * mean_noise, float * std_noise)
{
  int   j;
  int   new_first_gate=0;
  int   new_last_gate=0;
    
  float	 * running_mean;
  double   dummy,dummy2;
 
  	/* get running mean of power profile */
 	running_mean=compute_running_mean(
			&raw_power[firstgate],
			lastgate-firstgate,
			window_size,
			min_gate);

  	*mean_noise = running_mean[*min_gate];  /* the actual mean */
	free(running_mean);
	
  	/* calculate the std for the window position with minimum power */
	*min_gate=*min_gate+firstgate;
  	dummy = 0.0;
  	for (j=*min_gate-window_size; j<=*min_gate+window_size; j++) {	
		dummy2 = (double) (raw_power[j] - *mean_noise);
 		dummy += dummy2*dummy2;	
	}
  	*std_noise = pow(dummy  / (double) (2*window_size), 0.5) ;     	   
}

