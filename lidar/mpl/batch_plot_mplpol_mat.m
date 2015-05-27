function [status,polavg] = batch_plot_mplpol_mat(mpl_inarg);
% Processes mplpol averaged mat files into AM/PM files and images
% Takes an input argument with the following fields:
%    mpl_inarg.in_dir
%    mpl_inarg.tla  Typically 3-letter site designation, but also IOP names
%    mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];
%    mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
%    mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
%    mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
%    mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
%    mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];
%    mpl_inarg.Nsecs = 150; Number of seconds to average over
%    mpl_inarg.Nrecs = 2500; Number of netcdf records to read at a time
%    mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
%    mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
%    mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
%    mpl_inarg.cop_snr = 2; Minimum copol snr threshold for bscat image mask
%    mpl_inarg.ldr_snr = 1.5; Minimum linear dpr threshold for ldr image mask
%    mpl_inarg.ldr_error_limit = .25; Max ldr error fraction for ldr image mask
%    mpl_inarg.fig = gcf;
%    mpl_inarg.vis = 'on';
%    mpl_inarg.cv_log_bs = [1.5,4.5];
%    mpl_inarg.plot_ranges = [15,5,2];

% Uses ancload_coords and ancloadpart to break the incoming netcdf file into pieces

status = 0;

if ~exist('mpl_inarg','var')
   mpl_inarg.in_dir = getdir([],'mpl_data','Select directory containing mplpol b1 data');
   rid_ni = fliplr(mpl_inarg.in_dir(1:end-1));
   tok = strtok(rid_ni,filesep);
   kot = fliplr(tok);
   mpl_inarg.tla = kot(1:3); % Typically 3-letter site designation, but also IOP names
%    mpl_inarg.tla = 'ufo'
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
   mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
   
   mpl_inarg.cop_snr = 2;
   mpl_inarg.ldr_snr = 1.5;
   mpl_inarg.ldr_error_limit = .25;
   
   mpl_inarg.cop_snr = 1.5;
   mpl_inarg.ldr_snr = 1.25;
   mpl_inarg.ldr_error_limit = .25;
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'off';
   mpl_inarg.cv_log_bs = [1.5,4.5];
   mpl_inarg.cv_dpr = [-2,0];
   mpl_inarg.plot_ranges = [12,6,3];
else
   if ~isfield(mpl_inarg,'tla')
      mpl_inarg.tla = 'ufo';
   end
   if ~isfield(mpl_inarg,'fstem')
      mpl_inarg.fstem = [mpl_inarg.tla, '_mplpol_3flynn'];
   end
   if ~isfield(mpl_inarg,'mat_dir')
      mpl_inarg.mat_dir = getdir(['*,mat'],'mpl_data','Select directory containing mplpol mat files.');
   end
   if ~isfield(mpl_inarg,'fig_dir')
      mpl_inarg.fig_dir = [mpl_inarg.mat_dir,'..',filesep, 'fig',filesep];
   end
   if ~isfield(mpl_inarg,'png_dir')
      mpl_inarg.png_dir = [mpl_inarg.mat_dir,'..',filesep, 'png',filesep];
   end
   if ~isfield(mpl_inarg,'cop_snr');
      mpl_inarg.cop_snr = 2;
   end
   if ~isfield(mpl_inarg,'ldr_snr');
      mpl_inarg.ldr_snr = 1.5;
   end
   if ~isfield(mpl_inarg,'ldr_error_limit');
      mpl_inarg.ldr_error_limit = 0.25;
   end
   if ~isfield(mpl_inarg,'vis');
      mpl_inarg.vis = 'on';
   end
   if ~isfield(mpl_inarg,'cv_log_bs');
      mpl_inarg.cv_log_bs = [1.5,4.5];
   end
   if ~isfield(mpl_inarg,'cv_dpr')
      mpl_inarg.cv_dpr = [-2.25,0];
   end
end
mat_dir = mpl_inarg.mat_dir;
% out_dir = [in_dir, 'out',filesep];
png_dir = [mat_dir, '..',filesep,'png',filesep];
fig_dir = [mat_dir, '..',filesep,'fig',filesep];
if ~exist(png_dir, 'dir')
   mkdir(png_dir);
end
if ~exist(fig_dir, 'dir')
   mkdir(fig_dir);
end
mat_files = dir([mat_dir,'*.mat']);
for m = length(mat_files):-1:1
   polavg = loadinto([mat_dir mat_files(m).name]);
   if ~exist(polavg.statics.fname, 'file')
      polavg.statics.fname = [mat_dir, mat_files(m).name];
   end
   tic
   disp(['Starting plots for ',num2str(m), ' : ',mat_files(m).name]);
   mpl_inarg.pngdir = png_dir;
   mpl_inarg.figdir = fig_dir;
   mpl_inarg.fig = 1;
   %                inarg.vis = 'off';
    plot_pol_log_bs(polavg,mpl_inarg)
%%
%    plot_pol_log_bs_lst(polavg,mpl_inarg);
   %%
   %                plot_pol_lin_bs(polavg,mpl_inarg)
   %                plot_AM_PM_pol(polavg,inarg);
   disp(['Finished plots for ',num2str(m), ' : ',mat_files(m).name]);
   toc
end
