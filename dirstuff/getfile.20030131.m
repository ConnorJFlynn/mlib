function [fid, fname, pname] = getfile(fspec,pathfile);
% function [fid, fname, pname] = getfile(fspec,pathfile)
% usage 1: [fid, fname, pname] = getfile(fspec,pathfile)
% usage 2: [fid, fname, pname] = getfile(fspec)
% usage 3: [fid, fname, pname] = getfile
% fspec is a string indicating the file mask to be used with uigetfile
% pathfile is a string indicating the filename stem of the mat-file to use
% containing the "filepath" desired.
% if successful, fid is a positive integer indicating the file identifier
% if unsuccessful, fid is -1
%
% getfile uses uigetfile to locate and open a file in read mode.
% keyboard
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
  fid = -1;
else 
  filepath = pname;
  fid = fopen([pname fname],'r+');
end;
gotomats;
save(pathfile, 'filepath');
gotohome;
