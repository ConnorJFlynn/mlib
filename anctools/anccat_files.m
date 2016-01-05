function nc = anccat_files
% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.

disp('Please select files to concatenate along the time dimension.');
[filelist] = getfullname_('*.cdf;*.nc');
nc = ancload(filelist{1});
for i = 2:length(filelist);
[pname, fname, ext] = fileparts(filelist{i});
    disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
    nc = anccat(nc,ancload(filelist{i}));
    disp(['Done processing ', fname,ext]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')

return