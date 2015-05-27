/* 	This code, given a stream of radar I and Q data returns the
*	radar spectra and the first three moments.
*/

#include <Windows.h>  // to enable use of quaint far pascal 
#include "whichdrv.h" // define int16 and similar types
#include <stdio.h>
#include <math.h> // for floor
#include "four1_double.h"
#include "estimate_noise_floor.h"

float * Get_Radar_Spectra_n_Moments(

   int16  I_data[],	
   int16  Q_data[],
   int	  n_data_points,
   int	  n_range_gates,
   int	  n_points_in_fft, 	/* must be a factor or 2 */
   float  Sampling_interval, 	/* time between samples (in seconds) */
   float  wavelength,		/* in meters */

   /* outputs */
   float  * average_power_spectrum, /* array to store spectra...must be allocd*/
   float  * velocity,
   int 	  * n_spectra_averaged,	/* number of power spectra averaged */
   float  * mean_power,		/* time (!!) averaged power */
   float  * mean_velocity,		/* mean doppler velocity */
   float  * velocity_width,		/* width of doppler spectrum */
   float  * IQ_data			/* work space ... used */
){

int lcv,i,offset;
// float		*IQ_data;
float		sum_of_average_power_spectrum;
// float		dummy1;
float		dummy2;

int	min_gate,
	window_size; 
float	noise_threshold,
	mean_noise=0, 
	std_noise;


	/* allocate memory 
	IQ_data=malloc(2*n_points_in_fft*sizeof(float));
	if(IQ_data==NULL){
		printf("Insufficient Memory for routine Get_Radar_Spectra_n_Moments ! \n");
		exit(-1);
	}
	*/

	/* determine the number of spectra which will be averaged */
	*n_spectra_averaged=floor(n_data_points/n_points_in_fft);

	/* for each spectra */
	for(lcv=0;lcv<*n_spectra_averaged;lcv++){

		/* map & type convert I & Q data into NumRec format */
		offset=lcv*n_points_in_fft;
		for(i=0;i<n_points_in_fft;i++){
			IQ_data[2*i]  =(float) - I_data[(offset+i)*n_range_gates];	 // value in I array has opposite sign .. GAGE convention
			IQ_data[2*i+1]=(float) Q_data[(offset+i)*n_range_gates];     // value in Q array already negative !
		}

		/* decrement address because NumRec assumes 1 is first entry */
		IQ_data--;
		four1(IQ_data,n_points_in_fft,1);  /* Numerical Recipies FFT routine */
		IQ_data++;

		/* add to the average power spectrum */
		if(lcv==0){
			for(i=0;i<n_points_in_fft;i++){
				average_power_spectrum[i]=
					( IQ_data[2*i]*IQ_data[2*i] + 
					  IQ_data[2*i + 1]*IQ_data[2*i + 1] );
			}
		}else{
			for(i=0;i<n_points_in_fft;i++){
				average_power_spectrum[i]+=
					( IQ_data[2*i]*IQ_data[2*i] + 
					  IQ_data[2*i + 1]*IQ_data[2*i + 1] );
			}
		}
	}


	/* Determine the mean/zeroth moment & set sum spectra to average */
	for(i=0;i<n_points_in_fft;i++){
		average_power_spectrum[i]*=1.0/(*n_spectra_averaged);
	}

//	calculated in main routine, now.
//	*mean_power=sum_of_average_power_spectrum/(n_points_in_fft*n_points_in_fft);  

	window_size=((float) n_points_in_fft)*0.05;

	/* estimate the noise floor */
	estimate_noise_floor(	average_power_spectrum, 
					1, 
					n_points_in_fft-1, 
					window_size, 

					&min_gate, 
					&mean_noise, 
					&std_noise);
	

	/* ABS is next statement is to cover possible small negative number do to numerical 
	   error/noise in the running average process used above */
	// printf(" est = %f %f\n",mean_noise,std_noise);
	noise_threshold = mean_noise + 3*std_noise;

	/* get first moment - the mean doppler velocity */
	// velocity also calculated in calling program, now
	// dummy1=0.5*wavelength/(n_points_in_fft*Sampling_interval);
	*mean_velocity=0;
	sum_of_average_power_spectrum=0;
	// start at 1 to ignore DC term
	for(i=1;i<n_points_in_fft;i++){

		/* calculated velocity of the i-th point 
		if(i<0.5*n_points_in_fft){
			velocity[i]=i*dummy1;
		}else{
			velocity[i]=(i-n_points_in_fft)*dummy1;
		}
		*/

		if(average_power_spectrum[i]>noise_threshold){
			dummy2=(average_power_spectrum[i]-noise_threshold); 
			sum_of_average_power_spectrum+=dummy2;
			*mean_velocity+=velocity[i]*dummy2;
		}
	}		
	*mean_velocity=*mean_velocity/sum_of_average_power_spectrum; /* weighted by first moment by definition  */

	/* get second moment - width of the doppler spectrum */
	*velocity_width=0;
	// start at 1 to ignore DC term
	for(i=1;i<n_points_in_fft;i++){

		if(average_power_spectrum[i]>noise_threshold){
			dummy2=(*mean_velocity-velocity[i]);
			*velocity_width+=dummy2*dummy2*(average_power_spectrum[i]-noise_threshold);
		}
	}		
	*velocity_width=sqrt(*velocity_width/sum_of_average_power_spectrum); /* weighted by first moment by definition  */

	// free(IQ_data); Don't use this ... using input workspace !!
	return(average_power_spectrum);
}
