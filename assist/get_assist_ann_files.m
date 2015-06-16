function [raw_files, pname]  = get_assist_ann_files;

pick = menu('Process all files or just selected files?','All','Selected');
pause(.01);
if pick==1
    raw_files = getfullname('*_ann_*.*','assist_dir','Select a file in the directory to bundle.');
    if ~iscell(raw_files)
        raw_files = {raw_files};
    end
    [pname, fname, ext] = fileparts(raw_files{1});
    pname = [pname, filesep];
    catdir = [pname, 'catdir',filesep];
    if ~exist(catdir,'dir')
        mkdir(catdir);
    end
    raw_files = dir([pname,'*_ann_*.*']);
    raw_files = [raw_files;dir([pname,'*.nc'])];
else
    rawfiles = getfullname('*_ann_*.csv','assist_dir');
    if ~iscell(rawfiles)
        rawfiles = {rawfiles};
    end
    for L = length(rawfiles):-1:1
        raw_files(L).name = rawfiles{L};
    end
    [pname, ~, ~] = fileparts(raw_files(1).name); pname = [pname, filesep];
end




return