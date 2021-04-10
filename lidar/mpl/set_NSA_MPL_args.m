% Use these for NSA after 2017
close('all'); clear;
mpl_inarg.Nsecs = 90;
mpl_inarg.Nrecs = 10000;
mpl_inarg.cop_snr = 1.5;% larger numbers eliminate data
mpl_inarg.ldr_snr = 1.5;% larger numbers eliminate data
mpl_inarg.ldr_error_limit = .4; %smaller numbers eliminate data
mpl_inarg.cv_log_bs = [0,4];
mpl_inarg.cv_dpr = [-1.5,0];

[status,polavg] = batch_fsb1todaily(mpl_inarg);