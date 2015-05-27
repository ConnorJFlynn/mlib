% This procedure attempts to move to the "path_mat" directory beneath 
% the main Matlab directory.  If it doesn't exist, it is created.

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
cd(pathdir);
% 
% 
% matlab_work_dir = fullfile(matlabroot,'work','');
% path_mat_dir = fullfile(matlabroot,'work','path_mats','');
% 
% if ~exist(path_mat_dir,'dir')
%    disp('Creating path_mats directory...');
%    mkdir(matlab_work_dir,'path_mats');
% end
% 
% if ~exist(path_mat_dir,'dir')
%    disp('Could not create the path_mats directory!');
%    pause
% end

% cd(path_mat_dir);

