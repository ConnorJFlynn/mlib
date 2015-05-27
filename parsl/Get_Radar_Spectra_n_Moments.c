/* 	This code, given a stream of radar I and Q data returns the
	radar spectra and the first three moments.
*/

#include "four2_double.c"
#include "estimate_noise_floor.c"
#include "compute_running_mean.c"

double *Get_Radar_Spectra_n_Moments(

	double	I_data[],	
	double	Q_data[],
	int	n_data_points,
	int	n_points_in_fft, 	/* must be a factor or 2 */
	double	Sampling_interval, 		/* time between samples (in seconds) */
	double  wavelength,		/* in meters */

		/* outputs */
	int	*n_spectra_averaged,	/* number of power spectra averaged */
	double  *mean_power,		/* time (!!) averaged power */
	double	*mean_velocity,		/* mean doppler velocity */
	double  *velocity_width		/* width of doppler spectrum */
){

int lcv,i,offset,dummy,window_size;
float  *IQ_data;
double *average_power_spectrum,velocity,sum_of_average_power_spectrum;
double	dummy1,dummy2;
float	mean_noise,std_noise,noise_floor,velocity_cutoff=100;
float	*f_average_power_spectrum;

	/* allocate memory */
//	IQ_data=calloc(2*n_points_in_fft,sizeof(double));
	IQ_data=calloc(2*n_points_in_fft,sizeof(float));
	if(IQ_data==NULL){
		printf("Insufficient Memory for routine Get_Radar_Spectra_n_Moments ! \n");
		exit(-1);
	}

	average_power_spectrum=calloc(n_points_in_fft,sizeof(double));
	f_average_power_spectrum=calloc(n_points_in_fft,sizeof(float));
	if(average_power_spectrum==NULL){
		printf("Insufficient Memory for routine Get_Radar_Spectra_n_Moments ! \n");
		exit(-1);
	}

	/* determine the number of spectra which will be averaged */
	*n_spectra_averaged=floor(n_data_points/n_points_in_fft);


	/* for each spectra */
	for(lcv=0;lcv<*n_spectra_averaged;lcv++){

		/* map & type convert I & Q data into NumRec format */
		offset=lcv*n_points_in_fft;
		for(i=0;i<n_points_in_fft;i++){
			IQ_data[2*i]  =(double) I_data[offset+i];
			IQ_data[2*i+1]=(double) Q_data[offset+i];
		}

		/* decrement address because NumRec assumes 1 is first entry */
		IQ_data--;
		four1(IQ_data,n_points_in_fft,1);  /* Numerical Recipies FFT routine */
		IQ_data++;


		/* add to the average power spectrum */
		for(i=0;i<n_points_in_fft;i++){
			average_power_spectrum[i]+=
				( IQ_data[2*i]*IQ_data[2*i] + 
				  IQ_data[2*i + 1]*IQ_data[2*i + 1] );
		}

	}

	/* Determine the mean/zeroth moment & set sum spectra to average */
	sum_of_average_power_spectrum=0;
	for(i=0;i<n_points_in_fft;i++){
		average_power_spectrum[i]*=1.0/(*n_spectra_averaged);
		f_average_power_spectrum[i]=(float) average_power_spectrum[i];
		sum_of_average_power_spectrum+=average_power_spectrum[i];  
	}
	*mean_power=sum_of_average_power_spectrum/(n_points_in_fft*n_points_in_fft);  

	/* estimate spectra noise floor */
//	estimate_noise_floor(average_power_spectrum, 1, n_points_in_fft, // n_points_in_fft/8, &dummy, &mean_noise, &std_noise);

	window_size=((float) n_points_in_fft)*0.05;

	/* estimate the noise floor */
	estimate_noise_floor(	f_average_power_spectrum, 
					1, 
					n_points_in_fft-1, 
					window_size, 

					&dummy, 
					&mean_noise, 
					&std_noise);
	


	printf(" est = %f %f\n",(float) mean_noise, (float) std_noise);
	noise_floor=mean_noise+3*std_noise;	

	/* get first moment - the mean doppler velocity */
	dummy1=0.5*wavelength/(n_points_in_fft*Sampling_interval);
	sum_of_average_power_spectrum=0;
	*mean_velocity=0;
	for(i=0;i<n_points_in_fft;i++){

		if(average_power_spectrum[i]>noise_floor){

			/* calculated velocity of the i-th point */
			if(i<0.5*n_points_in_fft){
				velocity=i*dummy1;
			}else{
				velocity=(i-n_points_in_fft)*dummy1;
			}
			if(abs(velocity)<=velocity_cutoff){
				*mean_velocity+=velocity*(average_power_spectrum[i]-noise_floor);
				sum_of_average_power_spectrum+=(average_power_spectrum[i]-noise_floor);
				// printf("%f %f \n",velocity,average_power_spectrum[i]-noise_floor);;
			}
		}
	}

	if(sum_of_average_power_spectrum>0){		

		*mean_velocity=*mean_velocity/sum_of_average_power_spectrum; /* weighted by first moment by definition  */
	
		/* get second moment - width of the doppler spectrum */
		*velocity_width=0;
		for(i=0;i<n_points_in_fft;i++){

		   if(average_power_spectrum[i]>noise_floor){

			/* calculated velocity of the i-th point */
			if(i<0.5*n_points_in_fft){
				velocity=i*dummy1;
			}else{
				velocity=(i-n_points_in_fft)*dummy1;
			}
			if(abs(velocity)<velocity_cutoff){
				dummy2=(*mean_velocity-velocity);
				*velocity_width+=dummy2*dummy2*(average_power_spectrum[i]-noise_floor);
			}
		   }
		}		
		*velocity_width=sqrt(*velocity_width/sum_of_average_power_spectrum); /* weighted by first moment by definition  */
	}else{
		*mean_velocity=0;
		*velocity_width=0;
	}

	free(IQ_data);
	return(average_power_spectrum);
}
