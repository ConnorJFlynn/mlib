function [status,polavg] = batch_b1tomat2(in_dir, hour_chunk);
% [status,polavg] = batch_b1tomat2(in_dir, hour_chunk);
% Processes MPL b1 file into mat files.
% Uses ancload_coords and ancloadpart to break the a1 file into pieces

status = 0;
if ~exist('in_dir','var')||~exist(in_dir,'dir')
   [in_dir] = getdir([],'mpl_data','Select directory containing mplpol b1 data');
end
if ~exist('hour_chunk','var')
   hour_chunk = 12;
end
len = 5000; % This is the number of netcdf records to read at a time.

mpl_inarg.fstem = 'sgp_mplpol_3flynn.';
mpl_inarg.Nsecs = 150;
mpl_inarg.dtc = @prescale_generic_dtc; %accept and return MHz
mpl_inarg.ap = @ap_taihu; %accept range, return .cop, .crs
mpl_inarg.ol_corr = @hsrl_ol_corr; % accept range, return ol_corr
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
      fid_out = fopen([out_dir,in_files(ind(m)).name,'.out'],'w');
      fclose(fid_out);
      disp(['Reading ',in_files(ind(m)).name]);
      anc_mplpol_ = ancload_coords([in_dir,in_files(ind(m)).name]);
      status = status + 1;
      for m = 1:len:length(anc_mplpol_.time)
         disp(['netcdf record: ',num2str(m),' of ',num2str(length(anc_mplpol_.time))]);
         anc_mplpol = ancloadpart(anc_mplpol_,m,len);
         if exist('anc_mplpol_tail','var')
            anc_mplpol = anccat(anc_mplpol_tail,anc_mplpol);
         end
         if ~isempty(anc_mplpol)
            [polavg_new,tail_ind] = proc_mplpolb1_2(anc_mplpol,mpl_inarg);
            anc_mplpol_tail = ancsift(anc_mplpol,anc_mplpol.dims.time,[tail_ind:length(anc_mplpol.time)]);
            if exist('polavg','var')
               polavg = catpol(polavg,polavg_new);
            else
               polavg = polavg_new;
            end
            clear polavg_new;
            if ~isempty(polavg)
%                polavg.statics = anc_mplpol.statics;
               V1 = datevec(polavg.time(1));
               start_hour = floor(V1(4)/hour_chunk)*hour_chunk;
               V1(4) = start_hour;V1(5) = 0;V1(6) = 0;
               end_time = datenum(V1)+hour_chunk/24;
               if polavg.time(end)>=end_time
                  [outpol, polavg] = splitpol(polavg, polavg.time>=end_time);
                  fout_name = [mpl_inarg.fstem,datestr(datenum(V1),'yyyymmdd_HH'),'UT.mat'];
                  save([mat_dir, fout_name],'outpol', '-mat');
               end
            end
         else
            disp('Skipping bad file')
         end
      end % of 'for m' loop
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
   save([mat_dir, fout_name],'outpol', '-mat');
end
return

