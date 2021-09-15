 function in = sassat_dqr_days 

in_file = getfullname('*sat*.mat','satmat');
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
   sats = load(in_file{in},'-mat','time');
   start_time = sats.time(1); 
   end_time = sats.time(end); 
%    sprintf('%s, %s',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'))
   fprintf(fid0,'%s , %s \n',datestr(start_time, 'yyyy-mm-dd HH:MM:SS'),datestr(end_time, 'yyyy-mm-dd HH:MM:SS'));
end
fclose(fid0);

end