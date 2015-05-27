% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.

disp('Please select a file from a directory.');
[dirlist,pname] = dir_list('*.nc');

for i = 1:length(dirlist);
   cdfid = ncmex('open', [pname dirlist(i).name]);
   disp([dirlist(i).name, ' has PRF = ', num2str(laser_PRF(cdfid)) ]);
   ncmex('close', cdfid);
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')