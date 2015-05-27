function [status, data, fname, pname] = loadfile(fspec,pathfile);
% function [status,data, fname, pname] = loadfile(fspec,pathfile)
% usage 1: [status,data, fname, pname] = loadfile(fspec,pathfile)
% usage 2: [status,data, fname, pname] = loadfile(fspec)
% usage 3: [status,data, fname, pname] = loadfile
% fspec is a string indicating the file mask to be used with uigetfile
% pathfile is a string indicating the filename stem of the mat-file to use
% containing the "filepath" desired.
% The selected file will be treated with the default behavior of load.  
% Files without extension or ending in .mat are loaded as matlab mat-files
% All other extensions are loaded as ascii.
% if successful, status is a positive integer 
% if unsuccessful, status is -1

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
if pname == 0 
  status = 0;
else 
  status = 1;
  filepath = pname;
  data = load([pname fname]);
end;
gotomats;
save(pathfile, 'filepath');
gotohome;
