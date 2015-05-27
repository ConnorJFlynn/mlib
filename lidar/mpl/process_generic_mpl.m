close('all');
clear
pause(.1)
mpl_inarg.in_dir = 'E:\case_studies\twpC2\twpmplpolC2.b1\';
mpl_inarg.tla = 'abc';
mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];

   mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];

   % 4 9 16 25 36 49 64
   mpl_inarg.Nsecs = 15*64;% 64 min
   mpl_inarg.Nrecs = 3000;
   mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
      mpl_inarg.ap = @ap_twpC2_;
   mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range,
 
%    mpl_inarg.dtc = @dtc_fkb_; %accept and return MHz
%    mpl_inarg.ap = @ap_fkb_; %accept range, return .cop, .crs
%    mpl_inarg.ol_corr = @ol_fkb_; % accept range, return ol_corr

   mpl_inarg.cop_snr = 1.25;
   mpl_inarg.ldr_snr = .750;
   mpl_inarg.ldr_error_limit = .06125;
   mpl_inarg.fig = 1;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [1.5,4.5];
     mpl_inarg.cv_dpr = [-2.25,0];
   mpl_inarg.plot_ranges = [20,7,4,2];
   
   %%
      [status,polavg] = batch_b1todaily(mpl_inarg);
      files = dir([mpl_inarg.in_dir,'*.cdf']);
%       files = dir([mpl_inarg.mat_dir,'*.mat']);

%    for ff = 1:length(files)
% %%
%    polavg = loadinto([mpl_inarg.mat_dir,files(ff).name]);
% %%
%    plot_pol_log_bs(polavg,mpl_inarg);
% %%
%    end