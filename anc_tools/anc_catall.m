function nc = anc_catall;
% This function is just an empty shell.
% Interatively select a directory and then bundle all *.cdf and *.nc files in the
% directory together. Returned as "nc"

disp('Please select a directory.');
directoryname = getdir('nc_files','Select directory containing files to concatenate.');

flist = dir([directoryname,'*.cdf']);
flist = [flist;dir([directoryname,'*.nc'])]
nc = anc_load([directoryname, flist(1).name]);
for i = 2:length(flist);

    disp(['Processing ', flist(i).name, ' : ', num2str(i), ' of ', num2str(length(flist))]);
%    do_somethin_to_it([pname dirlist(i).name], [outdir dirlist(i).name]);
if ~exist([directoryname,flist(i).name],'dir')
    nc = anc_cat(nc,anc_load([directoryname, flist(i).name]));
%nomcal = gen_nomcal_file(fullfile(flist(i).fpath,flist(i).fname));
%status = apply_dtc([pname dirlist(i).name]);    
%ncid = get_ncid([pname dirlist(i).name])
%[mplps, status] = mpl_con_ps(pname, dirlist(i).name, outdir);
    %clear mplps
    disp(['Done processing ', flist(i).name]);
end
    
end;
disp(' ')
disp(['Finished with processing all files in directory ' directoryname])
disp(' ')
end

