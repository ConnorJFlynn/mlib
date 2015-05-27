function [fname, pname] = file_path(fspec,pathfile);
% Returns the filename and path of a selected file matching the mask in fspec.
% The search path defaults to the path specified in the file 'pathfile'.
% function [fname, pname] = file_path(fspec,pathfile)
% usage 1: [fname, pname] = file_path(fspec,pathfile)
% usage 2: [fname, pname] = file_path(fspec)
% usage 3: [fname, pname] = file_path
% fspec is a string indicating the file mask to be used with uigetfile
% pathfile is a string indicating the filename stem of the mat-file to use
% containing the "filepath" desired.
% If the user cancels without a valid selection, pname and fname are returned empty

if nargin>=2
  pathfile = [pathfile,'.mat'];
end
if nargin<2 
  pathfile = 'lastpath.mat';
end;
if nargin<1
  fspec = '*.*';
end
filepath=[];

homedir = pwd;
gotomats;

if exist(pathfile,'file') 
  load(pathfile);
  if ~exist(filepath,'dir')
     %disp(['The path specified in the indicated pathfile ''',pathfile, [''' does not exist.'];
     disp('The pathfile will be deleted.');
     delete(pathfile);
     clear filepath
  else
    cd(filepath);
  end;
end;

[fname,pname] = uigetfile(fspec);
if fname == 0 
  fname = [];
  pname = [];
  filepath = [];
else 
  filepath = pname;
end;
gotomats;
save(pathfile, 'filepath');
gotohome;
