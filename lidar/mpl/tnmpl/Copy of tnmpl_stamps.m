function mpl = tnmpl_stamps
% This processing code stamps the MPL data with the corresponding mirror
% angle, trims the range data and then outputs two 4-hour MPL structures:
% mpl_out contains all the input records bundled into a 4-hour file
% mplz averages adjacent records having the same zenith angle
mirror = tnmpl_mir;
base = 'C:\case_studies\tnmpl\mpl\processing\';
if ~exist('C:\case_studies\tnmpl\mpl','dir')
   mkdir(['C:\case_studies\tnmpl\mpl'],'four');
end
bundle = ['C:\case_studies\tnmpl\mpl\four\'];
proc_dirs = dir([base,'2006*']);
for d = 1:length(proc_dirs)
   if proc_dirs(d).isdir
      tn_dir = [base, proc_dirs(d).name,'\'];
      tn_files = dir([tn_dir,'*.??W']);
      disp(['Reading directory ',tn_dir]);
      for f = 1:length(tn_files)
%          disp(['Reading ',tn_files(f).name, ' #', num2str(f),' of ',num2str(length(tn_files))]);
         mpl_in = read_tnmpl([tn_dir, tn_files(f).name]);
         if ~isempty(mpl_in)
            mpl_in = tnmpl_restamp(mpl_in, mirror);
            mpl_in = tnmpl_zcut(mpl_in);
            if ~exist('mpl', 'var')
               mpl = mpl_in;
            else
               mpl = tnmpl_tcat(mpl, mpl_in);
            end
            if ((mpl.time(end)-mpl.time(1))>=(1/6))
               end_time = 1/6 + floor(6*mpl.time(1))/6;
               these = (mpl.time<end_time);
               mpl_out = tnmpl_tcut(mpl,these);
               disp(['Computing mirror averages, saving bundle: ',datestr(end_time-1/6,'yyyy-mm-dd HH:MM')]);
               mplz = tnmpl_mplz(mpl_out);
               mpl = tnmpl_tcut(mpl,~these);
               save([bundle,'tnmpl.',datestr(mpl_out.time(1),'yyyy_mm_dd.HH'),'.mat'],'mpl_out', '-mat');
               save([bundle,'tnmplzen.',datestr(mplz.time(1),'yyyy_mm_dd.HH'),'.mat'],'mplz', '-mat');
               clear mpl_out mplz
            end
         end
      end
      end_time = 1/6 + floor(6*mpl.time(1))/6;
      these = (mpl.time<end_time);
      mpl_out = tnmpl_tcut(mpl,these);
      mpl = tnmpl_tcut(mpl,~these);
      disp(['Computing mirror averages, saving bundle starting: ',datestr(end_time-1/6,'yyyy-mm-dd HH:MM')]);
      mplz = tnmpl_mplz(mpl_out);
      save([bundle,'tnmpl.',datestr(mpl_out.time(1),'yyyy_mm_dd.HH'),'.mat'],'mpl_out', '-mat');
      save([bundle,'tnmplzen.',datestr(mplz.time(1),'yyyy_mm_dd.HH'),'.mat'],'mplz', '-mat');
      if ~isempty(mpl)
         end_time = 1/6 + floor(6*mpl.time(1))/6;
         mpl_out = mpl;
         mplz = tnmpl_mplz(mpl_out);
         save([bundle,'tnmpl.',datestr(mpl_out.time(1),'yyyy_mm_dd.HH'),'.mat'],'mpl_out', '-mat');
         save([bundle,'tnmplzen.',datestr(mplz.time(1),'yyyy_mm_dd.HH'),'.mat'],'mplz', '-mat');
      else
         clear mpl
      end
      clear mpl_out mplz
   end; % End of if isdir
end % end of prod_dirs loop

function mirror = tnmpl_mir;
fid = fopen('C:\case_studies\tnmpl\mpl\archive\mir_pos.20060831_20060929.100129.dat', 'r');
in_txt = char(fread(fid, 'char'));
fclose(fid);
[A,pos] = textscan(in_txt,'%s%s%s',1,'delimiter',',.');
[B] = textscan(in_txt(pos:end),'%4f %2f %2f .%2f %2f %2f ,%f');
mirror.time = datenum(B{1},B{2},B{3},B{4},B{5},B{6});
mirror.pos = B{7};
return

function mpl = tnmpl_restamp(mpl, mirror);
mpl.hk.zenith = NaN(size(mpl.time));
start_ind = find(mirror.time<mpl.time(1),1,'last');
if isempty(start_ind)
   start_ind = 1;
end
end_ind = find(mirror.time>mpl.time(end),1,'first');
if isempty(end_ind)
   end_ind = length(mirror.pos);
end
if end_ind <= start_ind
   end_ind = start_ind;
end
for n = start_ind:(end_ind-1)
   these = find((mpl.time>=(mirror.time(n)+5/(24*60*60)))&(mpl.time<(mirror.time(n+1)-15/(24*60*60))));
   if ~isempty(these)
      mpl.hk.zenith(these) = mirror.pos(n);
   end
end