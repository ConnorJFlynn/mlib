function [status,polavg] = mpl_batch_mat(mat_dir,mpl_inarg);
% Processes mplpol averaged mat files into AM/PM files and images
% persistent polavg;
status = 0;
if ~exist('mat_dir','var')||~exist(mat_dir,'dir')
   [mat_dir] = getdir('mpl_data','Select directory containing processed/averaged MPLpol mat files');
end
if ~exist('mpl_inarg','var')
   % mpl_inarg.Nsamples = 10;
   mpl_inarg.fstem = 'ISDAC_mplpol_1flynn.';
   mpl_inarg.fstem = 'sgp_mplpol_3flynn.';
   mpl_inarg.cop_snr = 2;
   mpl_inarg.ldr_snr = 1.5;
   mpl_inarg.ldr_error_limit = .25;
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [1.5,4.5];
else
   if ~isfield(mpl_inarg,'fstem')
      mpl_inarg.fstem = 'ufo_mplpol_3flynn';
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
end
% mpl_inarg.fstem = 'fastpol_3flynn.';
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
%                plot_pol_lin_bs(polavg,mpl_inarg)
%                plot_AM_PM_pol(polavg,inarg);
               disp(['Finished plots for ',num2str(m), ' : ',mat_files(m).name]);
               toc
end
