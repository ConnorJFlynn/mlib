function [status,mpl] = batch_mplb1todaily(mpl_inarg);
% [status,mplavg] = batch_mplb1todaily(mpl_inarg);
% Processes "mpl.a1" file into daily mat files.
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
%    mpl_inarg.fig = gcf;
%    mpl_inarg.vis = 'on';
%    mpl_inarg.cv_log_bs = [1.5,4.5];
%    mpl_inarg.plot_ranges = [15,5,2];

% Uses ancload_coords and ancloadpart to break the incoming netcdf file into pieces

%Not for polarized MPL data
status = 0;

if ~exist('mpl_inarg','var')
   mpl_inarg.in_dir = getdir('mpl_data','Select directory containing (unpolarized) mpl b1 data');
   rid_ni = fliplr(mpl_inarg.in_dir(1:end-1));
   tok = strtok(rid_ni,filesep);
   kot = fliplr(tok);
   mpl_inarg.tla = kot(1:3); % Typically 3-letter site designation, but also IOP names
%    mpl_inarg.tla = 'ufo'
   mpl_inarg.fstem = [mpl_inarg.tla,'_mpl_3flynn.'];
   mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];
   
   mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   mpl_inarg.ap = eval(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   mpl_inarg.ol_corr = eval(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
   
   mpl_inarg.cop_snr = 2;
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [1.5,4.5];
   mpl_inarg.plot_ranges = [15,5,2];
else
   if ~isfield(mpl_inarg,'in_dir')
      mpl_inarg.in_dir = getdir('mpl_data','Select directory containing mpl a1  or b1 data');
   end
   if ~isfield(mpl_inarg,'tla')
      mpl_inarg.tla = 'ufo';
   end
   if ~isfield(mpl_inarg,'fstem')
      mpl_inarg.fstem = [mpl_inarg.tla, '_mpl_3flynn'];
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
   if ~isfield(mpl_inarg,'cop_snr');
      mpl_inarg.cop_snr = 2;
   end
   if ~isfield(mpl_inarg,'vis');
      mpl_inarg.vis = 'on';
   end
   if ~isfield(mpl_inarg,'cv_log_bs');
      mpl_inarg.cv_log_bs = [1.5,4.5];
   end   
end
in_dir = mpl_inarg.in_dir;
out_dir = mpl_inarg.out_dir;
mat_dir = mpl_inarg.mat_dir;
bad_dir = mpl_inarg.bad_dir;
% in_dir = ['C:\case_studies\ISDAC\MPL\MPL_raw\'];

if ~exist(out_dir, 'dir')
   mkdir(out_dir);
end
if ~exist(mat_dir, 'dir')
   mkdir(mat_dir);
end
if ~exist(bad_dir, 'dir')
   mkdir(bad_dir);
end

in_files = dir([in_dir,'*.cdf']);
for d = length(in_files):-1:1
   tmp = fliplr(in_files(d).name);
   [dmp,tmp] = strtok(tmp,'.');
   [tmp1,tmp] = strtok(tmp,'.');
   [tmp2,dmp] = strtok(tmp,'.');
   tmp = fliplr([tmp1,'.',tmp2]);   
   dates(d) = datenum(tmp,'yyyymmdd.HHMMSS');
end
[ds, ind] = sort(dates);

out_files = dir([out_dir,'*.cdf.out']);
for m = 1:length(in_files)
   done = false;
   %    for n = 1:length(out_files);
   n = 1;
   while ~done&&n<=length(out_files)
      done = strcmp([in_files(ind(m)).name,'.out'],out_files(n).name);
      if ~done
         n = n+1;
      else
         out_files(n) = [];
      end
   end
   if ~done
      tic
%Try to read next netcdf file, if there is an error copy it to the bad
%directory and move on.
      fid_out = fopen([out_dir,in_files(ind(m)).name,'.out'],'w');
      fclose(fid_out);
      disp(['Reading ',in_files(ind(m)).name]);
      mpl = read_mpl([in_dir,in_files(ind(m)).name]);
      status = status + 1;
         if ~isempty(mpl)
            mplavg = proc_mpl_a1(mpl,mpl_inarg);
            date_m = min([floor(ds(m)),floor(mplavg.time(1))]);
            fout_name = [mpl_inarg.fstem,datestr(date_m,'yyyymmdd'),'.doy',num2str(serial2doy(date_m)),'.mat'];
            save([mat_dir, fout_name],'mplavg', '-mat');
         else
            disp('Skipping empty file')
         end
      toc
   end
   
end
status = status + 1;
%%

% while length(mplavg.time>0)
%    date_m = floor(mplavg.time(1));
%    [mplavg, nextavg] = splitpol(mplavg, mplavg.time>(1+date_m));
%    if ~isempty(mplavg.time)
%       fout_name = [mpl_inarg.fstem,datestr(date_m,'yyyymmdd'),'.doy',num2str(serial2doy(date_m)),'.mat'];
%       save([mat_dir, fout_name],'mplavg', '-mat');
% %       plot_pol_log_bs(mplavg,mpl_inarg);
%       mplavg = nextavg;
%       nextavg = [];
%    end
% end
disp('done!')
%%

return

