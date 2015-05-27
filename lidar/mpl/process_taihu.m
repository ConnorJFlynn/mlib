  mpl_inarg.in_dir = 'D:\case_studies\hfe\China_Taihu\mpl\raw\';
  mpl_inarg.tla = 'taihu';
  mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];

   mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];

   mpl_inarg.Nsecs = 150;
   mpl_inarg.Nrecs = 2500;
    mpl_inarg.dtc = str2func(['dtc_',mpl_inarg.tla,'_']);
   mpl_inarg.ap = str2func(['ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   mpl_inarg.ol_corr = str2func(['ol_',mpl_inarg.tla,'_']); % accept range,

   mpl_inarg.cop_snr = 1.75;
   mpl_inarg.ldr_snr = 1.5;
   mpl_inarg.ldr_error_limit = .25;
   mpl_inarg.fig = 1;
   mpl_inarg.vis = 'off';
   mpl_inarg.cv_log_bs = [2.5,6.5];
   mpl_inarg.plot_ranges = [15,5,2];
   
   %%
   [status,polavg] = batch_mpl2mat(mpl_inarg);
   %%
   files = dir([mpl_inarg.mat_dir,'*.mat']);
   for ff = 1:length(files)
      
   polavg = loadinto([mpl_inarg.mat_dir,files(ff).name]);
   %%
   plot_pol_log_bs(polavg,mpl_inarg);
   end