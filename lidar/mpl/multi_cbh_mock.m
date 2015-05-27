mplnor = ancload;
mplbase = read_mplnor_baseline;

%%
BMBLK_MAX_SIG;
MIN_CLOUD_HT;
%/* This threshold is used to keep the maximun noise to signal    */
%/* (and hence the minimum signal to noise) below (above) some    */
%/* threshold.  This helps to identify weak cirrus during the day */
MAX_NOISE_TO_SIGNAL = 5.0;

%/* These values are used when computing the relative random  */
%/* error.  If the signal (backscatter - background) is below */
%/* the THRES, then the error is set to the default.          */
ERROR_BSCAT_THRES = 0.0005;
ERROR_BSCAT_DEFAULT = 555;
bthrsh  = 0.55,
bthrsha = 0.55,
bsmin   = 0.025,
jthrsh  = -0.20;
THICKEST_CLOUD = 4.5;        /* km */
%        /* Used to specify the alts over which to average when determining */
%        /* the beam-blocked condition.  [If avg signal over this range is  */
%        /* less than BMBLK_MAX_SIG and no significant clouds then consider */
%        /* the beam-blocked]  This is also used to determine a "near-field"*/
%        /* height, where we allow one-bin clouds below 1/2 the max height  */
%        /* but not above that...                                           */
bmblk_rng[2] = {4.0, 4.5};   /* km */
    if(ht[i] < 13.200)          /* James uses bins 0:43, which is 0.270-13.170 km */
    {
      ssig = 0.20;
      a = (ssig * otemp*nshots*em /(ht[i]*ht[i])) + (bk*nshots);
      if( a < 0 && ht[i] < MIN_CLOUD_HT )
        a = 1;
/* Kat
      else if( a < 0 && ht[i] > MIN_CLOUD_HT )
        bw_abort(-1, "Negative backscatter above MIN_CLOUD_HT. Aborting...\n");
*/
      nsmin = (sqrt(a) / (ssig*otemp*nshots*em / (ht[i]*ht[i])));
      if(nsmin < 1.0/7.80) nsmin = 1.0/7.80;
    }
    else
    {
      ssig = 0.36;
      ssig = 0.20;
      a = (ssig * otemp*nshots*em /(ht[i]*ht[i])) + (bk*nshots);
      if( a < 0 && ht[i] < MIN_CLOUD_HT )
        a = 1;
/* Kat
      else if( a < 0 && ht[i] > MIN_CLOUD_HT )
        bw_abort(-1, "Negative backscatter above MIN_CLOUD_HT. Aborting...\n");
*/
      nsmin = (sqrt(a) / (ssig*otemp*nshots*em / (ht[i]*ht[i])));
      if(nsmin < 1.0/10.0) nsmin = 1.0/10.0;
    }
    snmin[i] = 1.0/nsmin;
  }

        /* Calculate the threshold for the noise-to-signal ratio */
  for(i = 0; i < nhts; i++)
  {
    nthrsh[i] = (4.222e-1) + (-1.052e-2)/ht[i] + (-5.675e-6)*ht[i]*ht[i] +
                        (-4.565e-4)/(ht[i]*ht[i]*ht[i]);
    nthrsha[i] = nthrsh[i];
  }