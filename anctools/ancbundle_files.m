function nc = ancbundle_files(filelist)
% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then
% loops over the user specified actions for each file.
if ~exist('filelist','var')||isempty(filelist)
disp('Please select one or more files having the same DOD.');
[filelist] = getfullname_('*.cdf;*.nc');
end
if ~iscell(filelist)&&exist(filelist,'file')
    nc = ancload(filelist);
else
    nc = ancload(filelist{1});
    for i = 2:length(filelist);
        [pname, fname, ext] = fileparts(filelist{i});
        disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
        %    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
        nc = anccat(nc,ancload(filelist{i}));
        disp(['Done processing ', fname,ext]);
        
    end;
    disp(' ')
    disp(['Finished processing selected files in ' pname])
    disp(' ')
end
return