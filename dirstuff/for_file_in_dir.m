% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.
outdir = ['F:\datastream\nsa\nsamplpsC1.c1\cdf\'];
disp('Please select a file from a directory.');
[dirlist,pname] = dir_list('*.cdf');

for i = 1:length(dirlist);

    disp(['Processing ', dirlist(i).name, ' : ', num2str(i), ' of ', num2str(length(dirlist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
    [mplps, status] = mpl_con_ps(pname, dirlist(i).name, outdir);
    clear mplps
    disp(['Done processing ', dirlist(i).name]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')