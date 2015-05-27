mpl pol work:

Trying to sort out SNR computational issues with MPL pol data.
Specifically, looking to see why SNR doesn't drop to very low levels.  Seems to be related 
to the fact that the far range signal is a residual of a background subtraction which is also 
computed at far range and is generally small, so the noise is always a significant fraction of 
the background level.  Thus, there is a significant fraction of "noisy" points remaining such that 
spurious high signals (SNR > 2 or 3) are unavoidable.  Possibly a back smooth would help.

Scripts in editor:
plot_AM_PM_pol (SNR is a mask input)
proc_mplpolb1_2.m: most current pol processing of b1 level
mpl_bat_mat.m : processes mat files generated from b1 or raw
proc_mplpolraw_2.m: used to process raw and b1-level (after exgest of b1 to raw format)
batch_b1tomat2: converts b1 to mat files via proc_mplpolb1_2.m
