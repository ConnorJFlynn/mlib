function pme = saveasp(me,pfnt);
% pme = saveasp(me,pfnt);
% This function creates an m-file out of a supplied variable and then the
% corresponding p-code file from this m-file.  This should permit the
% bundlefnt routine to properly identify these as dependent and include
% them.
if ~exist('me','var')
   disp('Input variable is required');
   pme = [];
   return
end
if ~exist('pfnt','var')
   [pfnt,pname] = putfile('*.m','pcode','Select a location and filename for the function');
   pfnt = [pname, pfnt];
end
[pname, fname, ext] = fileparts(pfnt);
if isempty(pname)
   [pname] = getdir('*.m','p_files');
end
fid = fopen([pname,filesep,fname,'.m'],'w+');
fprintf(fid, '%s \n',['function A = ',fname]);
fprintf(fid,'A = NaN([%d, %d]); \n',size(me));
fprintf(fid,'A(:) = [');
fprintf(fid,'%d ',me);
fprintf(fid,'%s \n','];');
fprintf(fid,'%s \n','return;');
fclose(fid);
pcode([pname,filesep,fname,ext],'-inplace');
pme = [pname,filesep,fname,ext];
return