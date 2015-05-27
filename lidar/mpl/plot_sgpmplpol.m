mpl_inarg.mat_dir = 'E:\case_studies\hfe\hfemplpol.b1\mat\';
mpl_inarg.tla = 'hfe';
mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];

mpl_inarg.fig_dir = [mpl_inarg.mat_dir,'..',filesep, 'fig',filesep];
mpl_inarg.png_dir = [mpl_inarg.mat_dir,'..',filesep, 'png',filesep];

   mpl_inarg.cop_snr = 1.5;
   mpl_inarg.ldr_snr = 1.25;
   mpl_inarg.ldr_error_limit = .3;
   mpl_inarg.fig = 1;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [.5,4.5];
   mpl_inarg.plot_ranges = [15,5,2];
   mpl_inarg.cv_dpr = [-2.25,0];
   mpl_inarg.plot_ranges = [15,5,2];

%%
[status,polavg] = batch_plot_mplpol_mat(mpl_inarg);
%%
