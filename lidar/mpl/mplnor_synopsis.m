% MPLnor synopsis
% Apply corrections
% Use cld_chk to see if clear enough to generate a baseline.

 % Load baseline which includes standard deviation
 
mplnor_main ComputeNewData (DATA *D)
  Apply corrections
  degrade_resolution(newD, obs, &averaging_int, ndhi);
  calc_cbh(newD, obs, nsamples, nbins, height, overlap_correction, emonflag, max_cbh_height_allowed, ...
    averaging_int, bckgnd_cbh_rng, clear_thres, bmblk_max_sig, ht_res, min_cloud_ht, algo_string);
      % get baseline including cld_chk
         cld_chk looks at derivative (slope) of log after a 3-point filter.  This is entirely relative.  Good.
      % multi_cbh_hires looks at baseline
%       or
      % multi_cbh_lores
      
      % Would be good to check profiles
  set_mask(newD, obs, nsamples, nbins, height, mask1);
  smooth_mask(mask1, mask2, nsamples, nbins, height);

