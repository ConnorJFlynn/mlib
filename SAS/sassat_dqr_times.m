 function in =sassat_dqr_times 

in_file = getfullname('*sat*.mat','satmat');
bloop = 
if ~iscell(in_file)
   in_file = {in_file};
end
[pname, fname] = fileparts(in_file{1}); 
[~,fname] = fileparts(fname); [~,fname] = fileparts(fname); [~,fname] = fileparts(fname);
out_all = [pname, filesep,fname, '.sat_all.dat'];
fid0 = fopen(out_all, 'w');

for in = 1:length(in_file)
   [pname, fname] = fileparts(in_file{in}); [~,fname] = fileparts(fname)
   out_file = [pname, filesep,fname, '.sat.dat'];
   fid = fopen(out_file, 'w');
   sats = load(in_file{in});
   dsec = 1.5./(24*60*60);
   start_time = sats.time(1); 
   end_time = sats.time(1); 
   for ts = 2:length(sats.time)
      if (sats.time(ts)-sats.time(ts-1))>dsec
         end_time = sats.time(ts-1); 
%          sprintf('%s, %s',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'))
         fprintf(fid,'%s , %s \n',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'));
         fprintf(fid0,'%s , %s \n',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'));
         start_time = sats.time(ts);
      end
   end
   end_time = sats.time(end);
%    sprintf('%s, %s',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'))
   fprintf(fid,'%s , %s \n',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'));
   fprintf(fid0,'%s , %s \n',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'));
   fclose(fid);
   disp(sprintf('%s',['Closing ',fname,'.sat.dat']))
end
fclose(fid0);

end