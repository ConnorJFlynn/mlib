function nc = anc_catfiles
% nc = anc_catfiles
% Interactively select files from a file selection dialog and concatenate to a single struct. 


disp('Please select files to concatenate along the time dimension.');
[filelist] = getfullname('*.cdf;*.nc');
if ~iscell(filelist)
    filelist = {filelist};
end
[pname, fname, ext] = fileparts(filelist{1});
nc = anc_load(filelist{1});
for i = 2:length(filelist);
[pname, fname, ext] = fileparts(filelist{i});
    disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
    nc = anc_cat(nc,anc_load(filelist{i}));
    disp(['Done processing ', fname,ext]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')

return