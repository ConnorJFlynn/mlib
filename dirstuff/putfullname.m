function [fullname] = putfullname(fspec,pathfile,dialog);
% function [fname, pname] = putfile(fspec,pathfile)
% usage1: [fname, pname] = putfile(fspec,pathfile);
% usage2: [fname, pname] = putfile(fspec);
% usage3: [fname, pname] = putfile;
% fspec is a string indicating the file mask to be used with uiputfile
% pathfile is a string indicating the filename stem of the mat-file to use
% if successful, fname is the name of the saved file and pname is the path
% if unsuccessful, fname=0 and pname=0
%
% putfile uses uiputfile to place and name the mat file to be saved.
upath = which ('userpath.m');
if ~isempty(upath)&&exist(upath,'file')&&isadir(strtok(userpath,pathsep))&&...
      isadir([strtok(userpath,pathsep),filesep,'datapath'])
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


if isempty(who('dialog'))||isempty(dialog)
   if ~isempty(who('pathfile'))&&~isempty(pathfile)
      dialog = ['Select a file for ',pathfile,'.'];
   else
      dialog = ['Select a file.'];
   end
end
if isempty(who('pathfile'))||isempty(pathfile)
   pathfile = 'lastpath.mat';
end
if isempty(who('fspec'))||isempty(fspec)
   fspec = '*.*';
end
if isempty(fspec)
   fspec = '*.*';
end

if isempty(dir([pathdir,pathfile]))&&~isempty(dir([pathdir,pathfile,'.mat']))
   pathfile = [pathfile,'.mat'];
elseif isempty(dir([pathdir,pathfile]))&&isempty(dir([pathdir,pathfile,'.mat']))
   if ~isempty(strfind(pathfile,'.mat'))
      newpathfile = pathfile;
   else
      newpathfile = [pathfile, '.mat'];
   end
   pathfile = 'lastpath.mat';
end

if ~isempty(dir([pathdir,pathfile]))
   load([pathdir,pathfile]);
   if isempty(who('pname'))
      pname = pwd;
   end
  if ~ischar(pname)||~isadir(pname)
     %disp(['The path specified in the indicated pathfile ''',pathfile, [''' does not exist.'];
     disp('The pathfile will be deleted.');
      delete([pathdir,pathfile]);
      clear pname
      pname = [pwd,filesep];
  end
else
   pname = [pwd,filesep];
end;
% 
% 
% if nargin <3
%    dialog = 'Select location and filename.';
% end
% if nargin>=2
%   pathfile = [pathfile,'.mat'];
% end
% if nargin<2 
%   pathfile = 'lastpath.mat';
% end;
% if nargin<1
%   fspec = '*.*';
% end

% filepath=[];
% homedir = pwd;
% gotomats;
% 
% if exist([pathfile],'file') 
%     load(pathfile);
%   if ~exist([filepath],'dir')
%      delete(pathfile);
%      clear filepath
%   else
%      cd(filepath);
%   end;
% end;
%%
if ~isempty(dir(fspec))&&~isadir(fspec)
   [pname, fname, ext] = fileparts(fspec);
   fname = [fname ext];
else
   [pth,fstem,ext] = fileparts(fspec);
   fspec = [fstem,ext];
   if isadir(pth)
      [fname,pname] = uiputfile([pth,filesep,fspec],dialog);
   elseif isadir(pname)
      [fname,pname] = uiputfile([pname,filesep,fspec],dialog);
   else
      [fname,pname] = uiputfile(fspec,dialog);
   end
end

if ~isempty(pname)
   fullname = fullfile(pname,filesep, fname);
   if ~isempty(who('newpathfile'))
      save([pathdir,newpathfile], 'pname');
   else
      save([pathdir,pathfile], 'pname');
   end
else
   fullname = [];
end
%%


% [fname,pname] = uiputfile(fspec,dialog);
% if pname ~= 0 
%   filepath = pname;
% end; 
% gotomats;
% save(pathfile, 'filepath');
% gotohome;
