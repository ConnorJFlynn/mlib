function [pname] = getdir(start,pathfile,dialog);
% function [pname] = getdir(start,pathfile);
% usage 1: [pname] = getdir(start,pathfile);
% usage 2: [pname] = getdir(start);
% usage 3: [pname] = getdir;
% start is a string indicating a starting directory
% pathfile is a string indicating the filename stem of the mat-file to use
% as a starting path.
% if unsuccessful, pname is empty
%
% getfile uses uigetfile to locate and open a file in read mode.
% keyboard
upath = which ('userpath.m');
if ~isempty(upath)&&exist(upath,'file')&&exist(strtok(userpath,pathsep),'dir')&&...
      exist([strtok(userpath,pathsep),filesep,'datapath'],'dir')
   pathdir = [strtok(userpath,pathsep),filesep,'datapath',filesep];
else %start from scratch.  Identify userpath, create datapath directory
   userpath('reset');
   upath = userpath;
   status = mkdir([strtok(upath,pathsep),filesep,'datapath']);
   if ~status
      disp(['Failure to find or create datapath directory beneath userpath:',userpath]);
   else
      pathdir = [strtok(upath,pathsep),filesep,'datapath',filesep];
   end
end

if ~exist('dialog','var')||isempty(dialog)
   if exist('pathfile','var')&&~isempty(pathfile)
%       inpathfile = pathfile;
      dialog = ['Select a directory for ',pathfile,'.'];
   else
      dialog = ['Select a directory.'];
   end
end
if ~exist('pathfile','var')||isempty(pathfile)
   pathfile = 'lastpath.mat';
end
% This change is an attempt to let the user first load a specified path
% file then replace it with an alternate starting directory if desired.

if ~exist([pathdir,pathfile],'file')&&exist([pathdir,pathfile,'.mat'],'file')
    pathfile = [pathfile,'.mat'];
elseif ~exist([pathdir,pathfile],'file')&&~exist([pathdir,pathfile,'.mat'],'file')
    if ~isempty(strfind(pathfile,'.mat'))
        newpathfile = pathfile;
    else
        newpathfile = [pathfile, '.mat'];
    end
    pathfile = 'lastpath.mat';
end
if exist([pathdir,pathfile],'file')
   load([pathdir,pathfile]);
   if ~exist('pname','var')
      pname = pwd;
   end
   if ~ischar(pname)||~exist(pname,'dir')
      %disp(['The path specified in the indicated pathfile ''',pathfile, [''' does not exist.'];
%       disp('The pathfile will be deleted.');
%       delete([pathdir,pathfile]);
      clear pname
      pname = [pwd,filesep];
   end
else
   pname = [pwd,filesep];
end;
% The above should load an pre-saved path into pname.
if exist('start','var')&&~isempty(start)&&exist(start,'dir')
   pname = start;
end


[pname] = uigetdir(pname,dialog);
   if pname == 0
   pname = [];
   else
      pname = [pname, filesep];
      if exist('newpathfile','var')&&~isempty(newpathfile)
         save([pathdir,newpathfile],'pname');
         pathfile = 'lastpath.mat';
         save([pathdir,pathfile],'pname');
      else
         save([pathdir,pathfile],'pname');
      end
   end
   
