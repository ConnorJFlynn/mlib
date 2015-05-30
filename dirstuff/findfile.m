function [list]= findfile(startpath,mask,mode)
% Find a file or list of files on disk (for systems with ls)
%-------------------------------------------------------------------------------
% SYNTAX:
%	[list]= findfile(startpath,file,mode)
%
% INPUTS:
%	startpath:	The path to the directory to start looking in.
%
%	mask:		The file name to look for.  Can contain wild cards.
%
%	mode:		0 - search start directory only.
%			1 - search subdirectories also.
%
%			NOTE: If no mode is specified 0 is assumed.
%
% OUTPUTS:
%	list{i}.fpath:		Path name(s) of the file(s) found.
%
%	list{i}.fname:		File name(s) of the file(s) found.
%
% NOTE:	Only works for systems with dir.  Can be modified for other platforms.
%-------------------------------------------------------------------------------
%

%Define Output Variables
fnames = [];
fpaths = [];

%Check Inputs
if nargin < 2
   disp('Not Enough Input Arguments')
   disp(' ')
   return
end

%Define Mode String
if nargin < 3
   %mode = ' /b /a-d ';
   mode = 0;
elseif mode < 0 | mode > 1
   disp('Invalid Mode Was Defined')
   disp(' ')
   return
end

% Remember where we started.
startdir = pwd;

cd(startpath);
d = pwd;
cd(startdir);

list = idir(d, mask, mode);

return


function [files] = idir(dirpath, mask, mode)

files = struct([]);

maskfiles = dir(fullfile(dirpath, mask));
maskfiles = maskfiles([maskfiles.isdir] == false);
for f = 1:length(maskfiles)
    files(f).fname = maskfiles(f).name;
    files(f).fpath = dirpath;
end

% Check for recursive directory listing mode.
if (mode == 1)
    allfiles = dir(dirpath);
    dirs = allfiles([allfiles.isdir]);
    for d = 1:length(dirs)
        if (~strcmp(dirs(d).name, '.') & ~strcmp(dirs(d).name, '..'))
            flist = idir(fullfile(dirpath, dirs(d).name), mask, mode);
            files = [files flist];
        end
    end
end

return


%function [path] = tounix(path)
%path = strrep(path, '\', '/');
%return


%function [files] = lsdir(dirpath, mask, mode)

%files = struct([]);

%[status,result] = system(['ls -1 ',tounix(fullfile(dirpath,mask))]);
%disp(result);
%[row,rest] = strtok(result);

%f = 1;
%while ~isempty(rest)
%    if (exist(row,'file') == true & isdir(row) == false)
%        files(f).fname = row;
%        files(f).fpath = dirpath;
%        f = f+1;
%    end
%    [row,rest] = strtok(rest);
%end

% Check for recursive directory listing mode.
%if (mode == 1)
%    [status,result] = system(['ls -1 ',tounix(dirpath)]);
%    [row,rest] = strtok(result);
%    while ~isempty(rest)
%        if (isdir(row) == true)
%            flist = lsdir(fullfile(dirpath, row), mask, mode);
%            files = [files flist];
%        end
%        [row,rest] = strtok(result);
%    end
%end

% return

