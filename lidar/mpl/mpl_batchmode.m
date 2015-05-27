function [status,polavg] = mpl_batchmode(in_dir);
% Processes raw mpl pol data in batchmode into AM/PM files and images
% persistent polavg;
status = 0;
if ~exist('in_dir','var')||~exist(in_dir,'dir')
   [in_dir] = getdir([],'mpl_data','Select directory containing MPL raw data');
end
mpl_inarg.Nsamples = 10;
mpl_inarg.fstem = 'isdac_mplpol_1flynn.';
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
for m = 1:(length(in_files)-1)
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
      disp(['processing ',in_files(ind(m)).name]);
      fid_out = fopen([out_dir,in_files(ind(m)).name],'w');
      disp(['Reading ',in_files(ind(m)).name]);
      mplpol = Rd_Sigma([in_dir,in_files(ind(m)).name]);
      fclose(fid_out);
      if ~isempty(mplpol)
         if ~exist('polavg','var')||isempty(polavg)
            polavg = proc_mplpolraw(mplpol,mpl_inarg);
         else
            polavg = catpol(polavg,proc_mplpolraw(mplpol,mpl_inarg));
         end
         if ~isempty(polavg)
            polavg.statics = mplpol.statics;
            %Regardless of the initial starting file, we'd really like the
            %plots and data files to line up with clock-times, so once the file gets large
            %enough we'll go ahead and cut to the oldest half-day within the time.
            %nearest half-day
            mark = floor(polavg.time(1));
            if (serial2Hh(polavg.time(1))<12 && serial2Hh(polavg.time(end))>=12)|| ...
                  (serial2Hh(polavg.time(1))>=12 && serial2Hh(polavg.time(end))<12)
               %We span the AM/PM division, so save the file, cut the first
               %section, and continue.
               if serial2Hh(polavg.time(1))<12
                  HH_str = '000000';
                  mark = floor(polavg.time(1))+.5;
               else
                  HH_str = '120000';
                  mark = floor(polavg.time(end));
               end
               inarg.pngdir = png_dir;
               inarg.matdir = mat_dir;
               inarg.figdir = fig_dir;
               inarg.ldr_snr = .2;
               inarg.fstem = mpl_inarg.fstem;
               plot_AM_PM_pol(polavg,inarg);
               fout_name = [mpl_inarg.fstem,datestr(polavg.time(1),'yyyymmdd_HH'),'.mat'];
               save([mat_dir, fout_name],'polavg', '-mat');
            end
            cut_hours = (polavg.time(end)-mark)*24;
            polavg = cutpol(polavg,cut_hours);
         end
      else
         disp('Skipping bad file')
      end
   end
end
status = status + 1;
disp(['processing ',in_files(ind(end)).name]);
mplpol = Rd_Sigma([in_dir,in_files(ind(end)).name]);

if ~exist('polavg','var')||isempty(polavg)
   polavg = proc_mplpolraw(mplpol);
else
   polavg = catpol(polavg,proc_mplpolraw(mplpol));
end
polavg.statics = mplpol.statics;
               if serial2Hh(polavg.time(1))<12
                  HH_str = '000000';
                  mark = floor(polavg.time(1))+.5;
               else
                  HH_str = '120000';
                  mark = floor(polavg.time(end));
               end
               inarg.pngdir = png_dir;
               inarg.matdir = mat_dir;
               inarg.figdir = fig_dir;
               inarg.ldr_snr = .2;
               inarg.fstem = mpl_inarg.fstem;
               plot_AM_PM_pol(polavg,inarg);
               fout_name = [mpl_inarg.fstem,datestr(polavg.time(1),'yyyymmdd'),HH_str,'.mat'];
               save([mat_dir, fout_name],'polavg', '-mat');
% This code should output the current polavg structure as a mat file
% This file will continually overwrite itself as long as it contains
% any time records matching the datestamp of the output filename, at
% which point the data file name will be incremented.
new_name = [mpl_inarg.fstem,datestr(mark,'yyyymmdd.HH0000'),'.mat'];
if ~exist('fout_name','var') || ~strcmp(fout_name,new_name)
    fout_name = new_name;
end
save([mat_dir, fout_name],'polavg', '-mat');
end

