function nc = anccat_dir
% This procedure is just an empty shell.
% It interactively requests a raw data file directory and then 
% loops over the user specified actions for each file.

disp('Please select a file within the directory that you want to create a bundle for.');
[filelist] = getfullname_('*.cdf;*.nc','bundle_dir','Select a file in the directory to bundle.');
[pname, fname, ext] = fileparts(filelist); 
pname = [pname, filesep];
catdir = [pname, 'catdir',filesep];
if ~exist(catdir,'dir')
    mkdir(catdir);
end
filelist = dir_list([pname, '*.cdf']);
nc = ancload(filelist{1});
[~,fname, ext]= fileparts(nc.fname);
for i = 2:length(filelist);
    disp(['Processing ', fname, ext,' : ', num2str(i), ' of ', num2str(length(filelist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
    nc = anccat(nc,ancload(filelist{i}));
    disp(['Done processing ', fname,ext]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')
nc.quiet = true; nc.clobber = true;
nc.fname = [catdir,fname, '.nc'];
anccheck(nc);
ancsave(nc);
    
return