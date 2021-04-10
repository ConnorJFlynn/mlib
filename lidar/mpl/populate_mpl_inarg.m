function mpl_inarg = populate_mpl_inarg(mpl_inarg);
   if ~isfield(mpl_inarg,'in_dir')
      mpl_inarg.in_dir = getdir('mpl_data','Select directory containing mplpol b1 data');
   end
   if ~isfield(mpl_inarg,'tla')
      mpl_inarg.tla = 'ufo';
   end
   if ~isfield(mpl_inarg,'fstem')
      mpl_inarg.fstem = [mpl_inarg.tla, '_mplpol_3flynn'];
   end
   if ~isfield(mpl_inarg,'out_dir')
      mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   end
   if ~isfield(mpl_inarg,'bad_dir')
      mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   end
   if ~isfield(mpl_inarg,'mat_dir')
      mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   end
   if ~isfield(mpl_inarg,'fig_dir')
      mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   end
   if ~isfield(mpl_inarg,'png_dir')
      mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];
   end
   if ~isfield(mpl_inarg,'dtc');
      mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   end
   if ~isfield(mpl_inarg,'ap');
      mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   end
   if ~isfield(mpl_inarg,'ol_corr');
      eval(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
   end   
   if ~isfield(mpl_inarg,'Nsecs');
      mpl_inarg.Nsecs = 150; % This is the number of seconds to average over
   end   
   if ~isfield(mpl_inarg,'Nrecs');
      mpl_inarg.Nrecs = 2500; % This is the number of netcdf records to read at a time.
   end   
   if ~isfield(mpl_inarg,'cop_snr');
      mpl_inarg.cop_snr = 2.5;
   end
   if ~isfield(mpl_inarg,'ldr_snr');
      mpl_inarg.ldr_snr = 2.5;
   end
   if ~isfield(mpl_inarg,'ldr_error_limit');
      mpl_inarg.ldr_error_limit = 0.5;
   end
   if ~isfield(mpl_inarg,'vis');
      mpl_inarg.vis = 'on';
   end
   if ~isfield(mpl_inarg,'cv_log_bs');
      mpl_inarg.cv_log_bs = [0,4];
   end   

return