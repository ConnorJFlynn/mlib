% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.

disp('Please select a file from a directory.');
[dirlist,pname] = dir_list('*.cdf');

for i = 1:length(dirlist);

    disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
    [mpl, status] = mpl_con_nor([pname dirlist(i).name]);
    clear mpl status
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')