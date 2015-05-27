% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.

disp('Please select a file from a directory.');
[dirlist,pname] = dir_list('*.cdf', 'mplnet');

for i = 1:length(dirlist);
   
   disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
   [ncid] = ncmex('open', [pname dirlist(i).name], 'write');
   if ncid > 0
      [status] = mplnet2arm(ncid);
   else 
      status=-1;
   end;
   ncmex('close', ncid);
   if status==-1
      disp('... Whoa!!  Problem!')
   elseif status==0
      disp(['... Cool, the file was already in ARM-time.']);
   end;
   disp(['Done processing ', dirlist(i).name]);
   disp(' ');
   
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')