function [outpath] = getpath(infile,pathfile,dialog);
% function [pname] = getpath(infile,pathfile,dialog);
% infile is a string indicating the filename of an existing file or dir. If
% provided getpath will return the path where the file
% is found.
% If infile is empty or is not found in the path then getpath returns
% the path stored in 'pathfile', if it exists.
% If 'pathfile' is empty getpath returns the path in 'lastpath'.
% If 'lastpath' doesn't exist or the path in lastpath doesn't exist then
% the user will be prompted to select a directory which will be stored in
% 'pathfile' (if supplied) or in 'lastpath' if pathfile was not provided.
% 2016-07-28, CJF:

% Create 'filepaths' directory within userpath.
pname = strrep(userpath,';',filesep);
pathdir = [pname, 'filepaths'];
if ~exist(pathdir,'dir')
    mkdir(pname, 'filepaths');
end
clear pname
pathdir = [pathdir,filesep];
if ~exist('dialog','var')
    dialog = 'Select a directory';
end
if ~exist('pathfile','var')||isempty(pathfile)
    pathfile = 'lastpath.mat';
end
[~,pathfile,ext] = fileparts(pathfile);
if isempty(ext)
    pathfile = [pathfile,'.mat'];
end

if exist('infile','var')&&~isempty(infile)
    if isadir(infile)
        if strcmp(infile(end),filesep)
            outpath = infile;
        else
            outpath = [infile,filesep];
        end
    else
        [pname, infile_,ext] = fileparts(infile);
        % If the supplied filename actually exists then save this path else get
        % a new path.
        if ~isempty(pname)&&exist(pname, 'dir')
            outpath = [pname, filesep];
        else
            disp(['Supplied filename "',infile,'" does not exist on the path.  Select target directory.'])
            outpath = getnamedpath(pathfile,dialog);
        end
    end
else %no 'infile' supplied so go check pathfile
    if ~exist([pathdir,pathfile],'file') % this is really 'lastpath.mat' since line 25 caught other case
        disp(['Pathfile "',pathfile,'" does not exist. Select new target directory.'])
        outpath = getnamedpath(pathfile,dialog);
        if isfield(outpath,'pname')
            outpath = outpath.pname;
        end
    end
    if ~exist('outpath','var')
        outpath = load([pathdir,pathfile]);
        if isfield(outpath,'pname')
            outpath = outpath.pname;
        end
        if ~exist(outpath,'dir')
            disp('Previous directory in pathfile is invalid.  Select new target directory.')
            outpath = getnamedpath(pathfile,dialog);
            if isfield(outpath,'pname')
                outpath = outpath.pname;
            end
        end
    end
end
pname.pname = outpath;
save([pathdir,pathfile,'.mat'],'-struct','pname','-mat');

return