function [status,polavg] = batch_fastmpl2mat_X(in_dir, hour_chunk);
% Processes raw mpl pol data into mat files
   % The binary files for this MPL version use pre-triggered darks.
   % This requires some changes to be made in subsequent processing.
   % Using this to assess MARCUS data for replacement MPL sn 4212

status = 0;
if ~exist('in_dir','var')||~exist(in_dir,'dir')
   [in_dir] = getnamedpath('mpl_data','Select directory containing MPL raw data');
end
if ~exist('hour_chunk','var')
   hour_chunk = 24;
end
mpl_inarg.fstem = 'fastpol_1flynn.';
mpl_inarg.Nsecs = 60;
out_dir = [in_dir, 'out',filesep];
bad_dir = [in_dir, 'bad',filesep];
mat_dir = [in_dir, 'mat',filesep];
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

in_files = dir([in_dir,'*.mpl']);
for d = length(in_files):-1:1
   tmp = fliplr(in_files(d).name);
   [dmp,tmp] = strtok(tmp,'.');
   [tmp,dmp] = strtok(tmp,'.');
   tmp = fliplr(tmp);
      dates(d) = datenum(tmp,'yyyymmddHHMM');
%    dates(d) = datenum(tmp,'yyyymmddHHMM_s');
end
[ds, ind] = sort(dates);

out_files = dir([out_dir,'*.mpl']);
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
   done = false;
   if ~done
      status = status + 1;
%       disp(['processing ',in_files(ind(m)).name]);
      fid_out = fopen([out_dir,in_files(ind(m)).name],'w');
      disp(['Reading ',in_files(ind(m)).name]);
      mplpol = rd_sigma_fsxx([in_dir,in_files(ind(m)).name]);
      fclose(fid_out);
      if ~isempty(mplpol)
         if ~exist('polavg','var')||isempty(polavg)
%              polavg = proc_mplpolfsraw_5(mplpol,mpl_inarg);
            polavg = proc_fastpolraw_(mplpol,mpl_inarg);
         else
            polavg = catpol(polavg,proc_fastpolraw_(mplpol,mpl_inarg));
         end
         if ~isempty(polavg)
            polavg.statics = mplpol.statics;
            V1 = datevec(polavg.time(1));
            start_hour = floor(V1(4)/hour_chunk)*hour_chunk;
            V1(4) = start_hour;V1(5) = 0;V1(6) = 0;
            end_time = datenum(V1)+hour_chunk/24;
            end_time = polavg.time(1) + hour_chunk./24;
            if polavg.time(end)>=end_time
               [outpol, polavg] = splitpol(polavg, polavg.time>=end_time);
               fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd_HH'),'UT.mat'];
               save([mat_dir, fout_name],'outpol', '-mat');
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
      fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd_HH'),'UT.mat'];
      save([mat_dir, fout_name],'-struct','outpol', '-mat');
end
return

