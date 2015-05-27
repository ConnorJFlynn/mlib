% Process some files from Summit for Dave T. to look at depol issue

mpl_inarg.tla  = 'sgp';
mpl_inarg.Nsecs = 120;
mpl_inarg.Nrecs = 10000;
mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
%    mpl_inarg.cop_snr = 2.5; %Minimum copol snr threshold for bscat image mask
%    mpl_inarg.ldr_snr = 1.5; %Minimum linear dpr threshold for ldr image mask
%    mpl_inarg.ldr_error_limit = 1; %Max ldr error fraction for ldr image mask
mpl_inarg.vis = 'on';
mpl_inarg.cv_log_bs = [1.5,4.5];
mpl_inarg.cv_dpr = [-1.75,0];
mpl_inarg.plot_ranges = [10,5,2];

batch_fsb1todaily(mpl_inarg)