%If the variable homedir exists in the workspace, this procedure simply returns there.
%else, the homedir is assumed to be the matlab bin directory.

if exist('homedir')
  if ~exist(homedir,'dir') 
    clear homedir;
  end;
end;

if ~exist('homedir')
  homedir = fullfile(matlabroot,'work','');
  homedir = [strtok(userpath,pathsep),filesep];
end;

if exist(homedir,'dir')  
  eval(['cd ''',homedir,'''']);
else disp(['ERROR!! Could not locate home directory!'])
end;