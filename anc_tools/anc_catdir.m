function nc = anc_catdir
% nc = anc_catdir
% Interatively select a netcdf file within a directory and then bundle all
% *.cdf files in the directory together.  Returned as "nc" and saved in "catdir" subdirectory.

disp('Please select a file within the directory that you want to create a bundle for.');
[filelist] = getfullname('*.cdf;*.nc','bundle_dir','Select a file in the directory to bundle.');
[pname, fname, ext] = fileparts(filelist); 
pname = [pname, filesep];
catdir = [pname, 'catdir',filesep];
if ~exist(catdir,'dir')
    mkdir(catdir);
end
flist = dir([pname,'*.cdf']);
flist = [flist;dir([pname,'*.nc'])];
disp(['Loading ', flist(1).name]);
nc = anc_load([pname, flist(1).name]);
% filelist = dir_list([pname, '*.cdf'],'bundle_dir');
% nc = anc_load(filelist{1});

for i = 2:length(flist);
%     [~,fname, ext]= fileparts(flist(i).name);
    disp(['Processing ', flist(i).name,' : ', num2str(i), ' of ', num2str(length(flist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
    nc = anc_cat(nc,anc_load([pname,flist(i).name]));
%     disp(['Done processing ', fname,ext]);
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' pname])
disp(' ')
nc.quiet = true; nc.clobber = true;
nc.fname = [catdir,fname, '.nc'];
anc_check(nc);
anc_save(nc);
    
return