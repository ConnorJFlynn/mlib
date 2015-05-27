mpl_inarg.in_dir = 'F:\case_studies\ISDAC\MPL\cdf_in\test_a_few\some_days\';
mpl_inarg.tla = 'isdac';
mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];

   mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];

   mpl_inarg.Nsecs = 150;
   mpl_inarg.Nrecs = 2500;
   mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range,
 
%    mpl_inarg.dtc = @dtc_sgp_; %accept and return MHz
%    mpl_inarg.ap = @ap_fkb_; %accept range, return .cop, .crs
%    mpl_inarg.ol_corr = @ol_fkb_; % accept range, return ol_corr

   mpl_inarg.cop_snr = 2;
   mpl_inarg.ldr_snr = 1.5;
   mpl_inarg.ldr_error_limit = .25;
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [2,5];
   mpl_inarg.cv_dpr = [-3,0];
   mpl_inarg.plot_ranges = [15,8,4,2];
   
   %%
   close('all');
   [status,polavg] = batch_b1todaily(mpl_inarg);
   %%
