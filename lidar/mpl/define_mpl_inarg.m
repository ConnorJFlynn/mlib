function mpl_inarg = define_mpl_inarg
in_file = getfullname('*mpl*.nc;*mpl*.cdf;','mpl_data','Select an MPL netcdf file in th directory to process...');
if iscell(in_file)
   in_file = in_file{1};
end
[in_dir, fname, ext] = fileparts(in_file); in_dir = [in_dir, filesep]; fname = [fname ext];
anc_ = anc_link(in_file);

 mpl_inarg.in_dir = in_dir;
%    mpl_inarg.in_dir = getdir('mpl_data','Select directory containing mplpol b1 data');
%    rid_ni = fliplr(mpl_inarg.in_dir(1:end-1));
%    tok = strtok(rid_ni,filesep);
%    kot = fliplr(tok);
%    mpl_inarg.tla = kot(1:3); % Typically 3-letter site designation, but also IOP names
%    mpl_inarg.tla = 'ufo'
fac = strtok(fname, '.'); sss = fac(1:3); fac(1:3) = [];
while ~isempty(fac) &&(~strcmp(fac(1),upper(fac(1))))
   fac(1) = [];
end
   mpl_inarg.tla = [sss fac];
   mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];
   mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];
   
   mpl_inarg.Nsecs = 90;
   mpl_inarg.Nrecs = 10000;
   mpl_inarg.manual_limits = true;
   if isfield(anc_.vatts,'afterpulse_correction_height')
      mpl_inarg.ap_in_file = true;
   end
   mpl_inarg.assess_ap = false;
   mpl_inarg.replace_ap = false;
   
   if isfield(anc_.vatts,'deadtime_correction')
      mpl_inarg.dtc_in_file = true;
   end
      if isfield(anc_.vatts, 'overlap_correction')
      mpl_inarg.ol_corr_in_file = true;
   end
   mpl_inarg.replace_ol = false;
   mpl_inarg.assess_ray = true;
   mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
   
   mpl_inarg.cop_snr = 2.5;% larger numbers eliminate data
   mpl_inarg.ldr_snr = 2.5;% larger numbers eliminate data
   mpl_inarg.ldr_error_limit = .5; %smaller numbers eliminate data
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [0,4];
   mpl_inarg.cv_dpr = [-1.5,0];
   mpl_inarg.plot_ranges = [15,10,5,2];
return