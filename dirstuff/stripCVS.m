% This script reads existing path string and removes all CVS directories
% that are invariably added recursively but not desired.
%%

P = path;
%%

while ~isempty(P)
   [tok,P] = strtok(P,pathsep);
   if strfind(upper(tok),[filesep,'CVS']) > 0
      rmpath(tok);
   end
end
%%
pathdef_file = which('pathdef.m');
while ~isempty(dir(pathdef_file))
   [pname, fname, ext] = fileparts(pathdef_file);
   outfname = [pname, filesep,fname,'.',datestr(now,'yyyymmdd'),ext];
   %    outfname = [matlabroot,filesep,'toolbox',filesep,'local',filesep,'pathdef.',datestr(now,'yyyymmdd'),'.m'];
   success = copyfile(pathdef_file,outfname,'f');
   if success
      delete(pathdef_file);
   end
   if ~isempty(dir(pathdef_file))
      disp({'Probable savepath failure due to protected file or directory for ';...
         pathdef_file});
      disp(['Try manually deleting this file while Matlab is still running.']);
      ok = menu('Select OK when done','OK','Cancel');
      if ok==2
         break
      end
   end
%    pathdef_file = which('pathdef.m');
end
fail = savepath([pathdef_file]);
if fail
   disp(['Savepath failed to save the new version at:',pathdef_file]);
end
%%
