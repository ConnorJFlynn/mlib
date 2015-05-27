function clear_cvs(in_dir);
if ~exist('in_dir','var')
   in_dir = getdir;
end
subs = dir(in_dir);
for s = length(subs):-1:1
   if subs(s).isdir && strcmp(subs(s).name,'CVS')
      delete([in_dir,subs(s).name,filesep,'*.*']);
      rmdir([in_dir, subs(s).name]);
   elseif subs(s).isdir && ~strcmp(subs(s).name,'CVS')&& ~strcmp(subs(s).name,'..')...
         && ~strcmp(subs(s).name,'.')
      clear_cvs([in_dir,subs(s).name,filesep]);
   end
end

return
   