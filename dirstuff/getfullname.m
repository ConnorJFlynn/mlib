function [fullname] = getfullname(fspec,pathfile,dialog);
% function [fullname] = getfullname(fspec,pathfile,dialog);
% fspec is a string indicating the file mask to be used with uigetfile
% pathfile is a string indicating the filename stem of the mat-file to use
% containing the "filepath" desired.
% 2009-01-08, CJF: Uploading to 4STAR matlab_files repository
% 2011-04-07, CJF: modifying with userpath to hopefully get around needing
% access to the protected matlabroot directory


pname = strrep(userpath,';',filesep);
pathdir = [pname, 'filepaths',filesep];
if ~exist(pathdir,'dir')
    mkdir(pname, 'filepaths');
end
pathdir = [pathdir,filesep];
% 
% upath = which ('userpath.m');
% if ~isempty(upath)&&exist(upath,'file')&&exist(strtok(userpath,pathsep),'dir')&&...
%       exist([strtok(userpath,pathsep),filesep,'datapath'],'dir')
%    pathdir = [strtok(userpath,pathsep),filesep,'datapath',filesep];
% else %start from scratch.  Identify userpath, create datapath directory
%    userpath('reset');
%    upath = userpath;
%    status = mkdir([strtok(upath,pathsep),filesep,'datapath']);
%    if ~status
%       disp(['Failure to find or create datapath directory beneath userpath:',userpath]);
%    else
%       pathdir = [strtok(upath,pathsep),filesep,'datapath',filesep];
%    end
% end


if ~exist('dialog','var')||isempty(dialog)
   if exist('pathfile','var')&&~isempty(pathfile)
      dialog = ['Select a file for ',pathfile,'.'];
   else
      dialog = ['Select a file.'];
   end
end
if ~exist('pathfile','var')||isempty(pathfile)
   pathfile = 'lastpath.mat';
end
if ~exist('fspec','var')||isempty(fspec)
   fspec = '*.*';
end
if isempty(fspec)
   fspec = '*.*';
end

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
   if ~exist('pname','var')||isempty(pname)
      pname = pwd;
   end
  if ~ischar(pname)||~exist(pname,'dir')
     %disp(['The path specified in the indicated pathfile ''',pathfile, [''' does not exist.'];
%      disp('The pathfile will be deleted.');
%       delete([pathdir,pathfile]);
      clear pname
      pname = [pwd,filesep];
  end
else
   pname = [pwd,filesep];
end;

if exist(fspec,'file')&&~exist(fspec,'dir')
    this = which(fspec,'-all');
   [pname, fname, ext] = fileparts(this{:});
   fname = [fname ext];
else
   [pth,fstem,ext] = fileparts(fspec);
   fspec = [fstem,ext];
   if exist(pth,'dir')
      [fname,pname] = uigetfile([pth,filesep,fspec],dialog,'multiselect','on');
   elseif exist(pname,'dir')
      [fname,pname] = uigetfile([pname,filesep,fspec],dialog,'multiselect','on');
   else
      [fname,pname] = uigetfile(fspec,dialog,'multiselect','on');
   end
end
if ~isequal(pname,0)
% if ~isempty(pname)
    if ~iscell(fname)
   fullname = fullfile(pname,filesep, fname);
    else
        for l = length(fname):-1:1
            fullname(l) = {fullfile(pname, fname{l})};
        end
    end
   if exist('newpathfile','var')
      save([pathdir,newpathfile], 'pname');
               pathfile = 'lastpath.mat';
         save([pathdir,pathfile],'pname');
   else
      save([pathdir,pathfile], 'pname');
   end
else
   fullname = [];
end

return