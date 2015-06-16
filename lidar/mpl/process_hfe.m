% mpl_inarg.in_dir = 'E:\case_studies\fkb\fkbmplolM1.b1\';
mpl_inarg.in_dir = ['/data/dmf/datastream/hfe/hfemplpolM1.b1/']
mpl_inarg.tla = 'hfe';
mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];

   mpl_inarg.out_dir = ['/data/home/cflynn/hfemplpol.b1/out/'];
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
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [.5,4.5];
   mpl_inarg.plot_ranges = [15,5,2];
   
   
   %%
   %%
   % Process directory containing ARM b1-level data into Matlab mat files 
   % Apply corrections to get attenuated backscatter and linear depol ratio
   [status,polavg] = batch_b1todaily(mpl_inarg);
   % Read a directory containing mplpol Matlab mat files and generate
   % plots for each mat file.
   [status,polavg] = batch_plot_mplpol_mat(mpl_inarg)
   
   % Or alternately, comment out the above lines and uncomment the lines below to 
   % manually load a processed mat file and generate plots.
   % polavg = loadinto(getfullname('*.mat','hfe_data','Select hfe mpl mat file.'));
   % plot_pol_log_bs(polavg,mpl_inarg);

   %%
   
