function [list,pname] = dir_(masks,pathfile)
% function [list] = dir(mask,pathfile);
% usage 1: [list] = dir(mask,pathfile);
% usage 2: [list] = dir(mask);
% usage 3: [list] = dir;
% start is a string indicating a starting directory
% pathfile is a string indicating the filename stem of the mat-file to use
% as a starting path.
% if unsuccessful, pname is empty
%
% getfile uses uigetfile to locate and open a file in read mode.
% keyboard
if ~exist('masks','var')
    masks = '*';
end
% upath = which ('userpath.m');
% 
% if ~isempty(upath)&&exist(upath,'file')&&exist(strtok(userpath,pathsep),'dir')&&...
%         exist([strtok(userpath,pathsep),filesep,'filepaths'],'dir')
%     pathdir = [strtok(userpath,pathsep),filesep,'filepaths',filesep];
%%%
pname = strrep(userpath,';',filesep);
pathdir = [pname,filesep, 'filepaths',filesep];
if ~exist(pathdir,'dir')
    mkdir(pname, 'filepaths');
end

%%%
% % % if exist([prefdir,filesep,'filepaths'],'dir')
% % %     pathdir = [strtok(userpath,pathsep),filesep,'filepaths',filesep];
% % % 
% % % else %start from scratch.  Identify userpath, create datapath directory
% % % %     userpath('reset');
% % % %     upath = userpath;
% % % %     status = mkdir([strtok(upath,pathsep),filesep,'filepaths']);
% % % status = mkdir([prefdir,filesep,'filepaths']);
% % %     if ~status
% % %         disp(['Failure to find or create datapath directory beneath userpath:',userpath]);
% % %     else
% % % %         pathdir = [strtok(upath,pathsep),filesep,'filepaths',filesep];
% % %         pathdir = [prefdir,filesep,'filepaths',filesep];
% % %     end
% % % end

%
% if ~exist([matlabroot,filesep,'path_mats'],'dir')
%    mkdir(matlabroot,'path_mats');
% end
% pathdir = [matlabroot,filesep,'path_mats',filesep];
%
%    if exist('pathfile','var')&&~isempty(pathfile)
%       inpathfile = pathfile;
%       dialog = ['Select a directory for ',inpathfile,'.'];
%    else
%       dialog = ['Select a directory.'];
%    end

if ~exist('pathfile','var')||isempty(pathfile)
    pathfile = 'lastpath.mat';
end
% This change is an attempt to let the user first load a specified path
% file then replace it with an alternate starting directory if desired.

if ~exist([pathdir,pathfile],'file')&&exist([pathdir,pathfile,'.mat'],'file')
    pathfile = [pathfile,'.mat'];
elseif ~exist([pathdir,pathfile],'file')&&~exist([pathdir,pathfile,'.mat'],'file')
    pathfile = 'lastpath.mat';
end
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
if exist('start','var')&&~isempty(start)&&exist(start,'dir')
    pname = start;
end

mask = textscan(masks,'%s','delimiter',';,');
mask = mask{:};
list = [];
for i = 1:length(mask)
   mask_i = mask{i};
   if isempty(strfind(mask_i,pname))
      list = [list;dir([pname, mask_i])];
   else
      list = [list;dir([mask_i])];
   end
end

if isempty(pname) || isempty(list)
    pname = [];
else
    while(strcmp(pname(end),filesep))
        pname(end) = [];
    end
    pname = [pname, filesep];
    save([pathdir,pathfile],'pname');
    pathfile = 'lastpath.mat';
    save([pathdir,pathfile],'pname');
end

return
