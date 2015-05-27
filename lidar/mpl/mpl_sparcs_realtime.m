function [status,polavg] = mpl_sparcs_realtime(in_dir);
% Processes raw mpl pol data for Sparticus images
% persistent polavg;
% Still may need improvement in splitting hourly/daily files
status = 0;
if ~exist('in_dir','var')||~exist(id_dir,'dir')
   [in_dir] = getdir([],'mpl_data','Select directory containing MPL raw data');
end
mpl_inarg.Nsamples = 10;
   mpl_inarg.dtc = str2func(['dtc_sgp_']);
   mpl_inarg.ap = str2func(['ap_sgp_']); %accept range, return .cop, .crs
   mpl_inarg.ol_corr = str2func(['ol_sgp_']); % accept range,

out_dir = [in_dir, 'out',filesep];
png_dir = [in_dir, 'png',filesep];
fig_dir = [in_dir, 'fig',filesep];
mat_dir = [in_dir, 'mat',filesep];
% in_dir = ['C:\case_studies\ISDAC\MPL\MPL_raw\'];
if ~exist(out_dir, 'dir')
   mkdir(in_dir, 'out');
end
if ~exist(png_dir, 'dir')
   mkdir(in_dir, 'png');
end
if ~exist(fig_dir, 'dir')
   mkdir(in_dir, 'fig');
end
if ~exist(mat_dir, 'dir')
   mkdir(in_dir, 'mat');
end


hours = 12.5;

in_files = dir([in_dir,'*.mpl']);
for d = length(in_files):-1:1
   tmp = fliplr(in_files(d).name);
   [dmp,tmp] = strtok(tmp,'.');
   [tmp,dmp] = strtok(tmp,'.');
   tmp = fliplr(tmp);
   dates(d) = datenum(tmp,'yyyymmddHHMM_s');
end
[ds, ind] = sort(dates);

out_files = dir([out_dir,'*.mpl']);
old_fout = [];
for m = 1:(length(in_files)-1)
   done = false;
   for n = 1:length(out_files)
      done = done|strcmp(in_files(ind(m)).name,out_files(n).name);
   end
   if ~done
      status = status + 1;
      disp(['processing ',in_files(ind(m)).name]);
      fid_out = fopen([out_dir,in_files(ind(m)).name],'w');
      disp(['Reading ',in_files(ind(m)).name]);
      mplpol = Rd_Sigma([in_dir,in_files(ind(m)).name]);
      fclose(fid_out);

      if ~exist('polavg','var')|isempty(polavg)
         polavg = proc_mplpolraw_4(mplpol,mpl_inarg);
      else
         polavg = catpol(polavg,proc_mplpolraw_4(mplpol,mpl_inarg));
      end
      if ~isempty(polavg)
      polavg.statics = mplpol.statics;
      polavg = cutpol(polavg,hours);
      inarg.pngdir = png_dir;
      inarg.matdir = mat_dir;
      inarg.figdir = fig_dir;
      inarg.ldr_snr = .2;
      
      % This code should output the current polavg structure as a mat file
      % This file will continually overwrite itself as long as it contains
      % any time records matching the datestamp of the output filename, at
      % which point the data file name will be incremented.
      if ~exist('fout_time','var') || ~any(polavg.time==fout_time)
         fout_time = polavg.time(find(polavg.time>=mplpol.time(1),1,'first'));
         fout_name = ['mplpolavg_flynn.',datestr(fout_time,'yyyymmdd.HHMMSS'),'.mat'];               
      end
%       if ~strcmp(fout_name,old_fout);
         quicklook_pol(polavg,inarg);
         save([mat_dir, fout_name],'polavg', '-mat');
         old_fout = fout_name;
%       end
      end
   end
end
status = status + 1;
disp(['processing ',in_files(ind(end)).name]);
mplpol = Rd_Sigma([in_dir,in_files(ind(end)).name]);

if ~exist('polavg','var')|isempty(polavg)
   polavg = proc_mplpolraw_4(mplpol,mpl_inarg);
else
   polavg = catpol(polavg,proc_mplpolraw_4(mplpol,mpl_inarg));
end
polavg.statics = mplpol.statics;
%         hours = 10;
polavg = cutpol(polavg,hours);
inarg.pngdir = png_dir;
inarg.matdir = mat_dir;
inarg.figdir = fig_dir;
inarg.ldr_snr = .2;
quicklook_pol(polavg,inarg);
% This code should output the current polavg structure as a mat file
% This file will continually overwrite itself as long as it contains
% any time records matching the datestamp of the output filename, at
% which point the data file name will be incremented.
if ~exist('fout_time','var') || ~any(polavg.time==fout_time)
   fout_time = polavg.time(find(polavg.time>=mplpol.time(1),1,'first'));
   fout_name = ['mplpolavg_flynn.',datestr(fout_time,'yyyymmdd.HHMMSS'),'.mat'];
end
save([mat_dir, fout_name],'polavg', '-mat');
end

