function [pname] = lastdir
% function [pname] = lastdir

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

pathfile = 'lastpath.mat';

% This change is an attempt to let the user first load a specified path
% file then replace it with an alternate starting directory if desired.


if exist([pathdir,pathfile],'file')
    load([pathdir,pathfile]);
    if ~exist('pname','var')
        pname = pwd;
    end
    if ~ischar(pname)||~exist(pname,'dir')
        %disp(['The path specified in the indicated pathfile ''',pathfile, [''' does not exist.'];
        disp('The pathfile will be deleted.');
        delete([pathdir,pathfile]);
        clear pname
        pname = [pwd,filesep];
    end
else
    pname = [pwd,filesep];
end;
% The above should load an pre-saved path into pname.

if ~exist(pname,'dir')
    [pname] = getdir;
end
return