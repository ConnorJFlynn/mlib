function nc = anc_bundle_files(filelist)
% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then
% loops over the user specified actions for each file.
pause(.1);
if ~exist('filelist','var')||isempty(filelist)
disp('Please select one or more files having the same DOD.');
[filelist] = getfullname__('*.cdf;*.nc');
end
if ~iscell(filelist)&&exist(filelist,'file')
   [pname, fname, ext] = fileparts(filelist);
    nc = anc_load(filelist);
else
    nc = anc_load(filelist{1});
    [pname, fname, ext] = fileparts(filelist{1});
    for i = 2:length(filelist);
        [pname, fname, ext] = fileparts(filelist{i});
        disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
        %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
        nc = anc_cat(nc,anc_load(filelist{i}));
        disp(['Done processing ', fname,ext]);
        
    end;
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end
return