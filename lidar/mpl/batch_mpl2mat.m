function [status,polavg] = batch_mpl2mat(mpl_inarg, hour_chunk);
% Processes raw mpl pol data into mat files
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
%    mpl_inarg.dtc = str2func(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
%    mpl_inarg.ap = str2func(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
%    mpl_inarg.ol_corr = str2func(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
%    mpl_inarg.cop_snr = 2; Minimum copol snr threshold for bscat image mask
%    mpl_inarg.ldr_snr = 1.5; Minimum linear dpr threshold for ldr image mask
%    mpl_inarg.ldr_error_limit = .25; Max ldr error fraction for ldr image mask
%    mpl_inarg.fig = gcf;
%    mpl_inarg.vis = 'on';
%    mpl_inarg.cv_log_bs = [1.5,4.5];
%    mpl_inarg.plot_ranges = [15,5,2];


status = 0;
if ~exist('mpl_inarg','var')
   mpl_inarg = define_mpl_inarg;
else
   mpl_inarg = populate_mpl_inarg(mpl_inarg);
end

if ~exist('hour_chunk','var')
   hour_chunk = 24;
end

% mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
% mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
% mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
if ~exist(mpl_inarg.out_dir, 'dir')
   mkdir(mpl_inarg.out_dir);
end
if ~exist(mpl_inarg.mat_dir, 'dir')
   mkdir(mpl_inarg.mat_dir);
end
if ~exist(mpl_inarg.bad_dir, 'dir')
   mkdir(mpl_inarg.bad_dir);
end

in_files = dir([mpl_inarg.in_dir,'*.mpl']);
for d = length(in_files):-1:1
   tmp = fliplr(in_files(d).name);
   [dmp,tmp] = strtok(tmp,'.');
   [tmp,dmp] = strtok(tmp,'.');
   tmp = fliplr(tmp);
%       dates(d) = datenum(tmp,'yyyymmddHHMM');
   dates(d) = datenum(tmp,'yyyymmddHHMM');
end
[ds, ind] = sort(dates);

out_files = dir([mpl_inarg.out_dir,'*.mpl']);
for m = 1:length(in_files)
   done = false;
%    for n = 1:length(out_files);
      n = 1;
   while ~done&&n<=length(out_files)
      done = strcmp(in_files(ind(m)).name,out_files(n).name);
      if ~done
         n = n+1;
      else
         out_files(n) = [];
      end
   end
   if ~done
      status = status + 1;
%       disp(['processing ',in_files(ind(m)).name]);
      fid_out = fopen([mpl_inarg.out_dir,in_files(ind(m)).name],'w');
      disp(['Reading ',in_files(ind(m)).name]);
      try
      mplpol = rd_Sigma([mpl_inarg.in_dir,in_files(ind(m)).name]);
      catch
         mplpol = [];
         disp('bad file')
      end
      fclose(fid_out);
      if ~isempty(mplpol)
         if ~exist('polavg','var')||isempty(polavg)
            polavg = proc_mplpolraw_4(mplpol,mpl_inarg);
         else
            polavg = catpol(polavg,proc_mplpolraw_4(mplpol,mpl_inarg));
         end
         if ~isempty(polavg)
            polavg.statics = mplpol.statics;
            V1 = datevec(polavg.time(1));
            start_hour = floor(V1(4)/hour_chunk)*hour_chunk;
            V1(4) = start_hour;V1(5) = 0;V1(6) = 0;
            end_time = datenum(V1)+hour_chunk/24;
            if polavg.time(end)>=end_time
               [outpol, polavg] = splitpol(polavg, polavg.time>=end_time);
%                fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd_HH'),'UT.mat'];
% hfe_mplpol_3flynn.20080604.doy156
               fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd.HHMM'),'UT.doy',num2str(serial2doy(polavg.time(1))),'.mat'];
               save([mpl_inarg.mat_dir, fout_name],'outpol', '-mat');
            end
         end
      else
         disp('Skipping bad file')
      end
   end
end
status = status + 1;

while length(polavg.time>0)
   V1 = datevec(polavg.time(1));
   start_hour = floor(V1(4)/hour_chunk)*hour_chunk;
   V1(4) = start_hour;V1(5) = 0;V1(6) = 0;
   end_time = datenum(V1)+hour_chunk/24;
      [outpol, polavg] = splitpol(polavg, polavg.time>=end_time);
%       fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd_HH'),'UT.mat'];
               fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd.HHMM'),'UT.doy',num2str(serial2doy(outpol.time(1))),'.mat'];
%       fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd.HHMM'),'UT.mat'];
      save([mpl_inarg.mat_dir, fout_name],'outpol', '-mat');
end
return

function mpl_inarg = define_mpl_inarg
mpl_inarg.in_dir = 'E:\case_studies\hfe\China_Taihu\mpl\raw\';
   rid_ni = fliplr(mpl_inarg.in_dir(1:end-1));
   mpl_inarg.tla = 'taihu'; % Typically 3-letter site designation, but also IOP names    mpl_inarg.tla = 'ufo'
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

   mpl_inarg.cop_snr = 2;
   mpl_inarg.ldr_snr = 1.5;
   mpl_inarg.ldr_error_limit = .25;
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [1.5,4.5];
   mpl_inarg.cv_dpr = [-2.25,0];
   mpl_inarg.plot_ranges = [15,5,2];
return
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
   mpl_inarg.fstem = 'taihu_mplpol_3flynn.';
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
      mpl_inarg.dtc = str2func(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   end
   if ~isfield(mpl_inarg,'ap');
      mpl_inarg.ap = str2func(['@ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   end
   if ~isfield(mpl_inarg,'ol_corr');
      str2func(['@ol_',mpl_inarg.tla,'_']); % accept range, return ol_corr
   end   
   if ~isfield(mpl_inarg,'Nsecs');
      mpl_inarg.Nsecs = 150; % This is the number of seconds to average over
   end   
   if ~isfield(mpl_inarg,'Nrecs');
      mpl_inarg.Nrecs = 2500; % This is the number of netcdf records to read at a time.
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

return