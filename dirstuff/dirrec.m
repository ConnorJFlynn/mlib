function [dd,fnames] = dirrec(mask)
% returns a recursive list of files matching the supplied mask.
if ~isavar('mask')
   mask = [getdir([],'Select a folder or diretory.'),'*.*'];
end
[pname, fmask,ext] = fileparts(mask); 
if isempty(pname)||~isadir(pname)
   [fid,errmsg] = fopen(pname, 'w'); 
   if fid>0 
      fclose(fid);
   end
   if ~isempty(errmsg)&&strcmp(errmsg,'Permission denied')
      fprintf('Permission denied! Skipping: [%s] \n',pname);
   else
      pname = getdir([],'Select a folder or diretory.');
   end
end
pname = [pname, filesep]; pname = strrep(pname, [filesep filesep],filesep);
fmask = [fmask,ext]; mask = [pname, fmask];
dd = dir(mask);
% Eliminate '.' and '..'
dots = {dd(:).name}; dots_ = strcmp(dots,'.'); dd(dots_) = [];
dots = {dd(:).name}; dots_ = strcmp(dots,'..'); dd(dots_) = [];

sub_dd = dir([pname,'*.*']); %Used to find sub-directories
% Eliminate '.' and '..'
dots = {sub_dd(:).name}; dots_ = strcmp(dots,'.'); sub_dd(dots_) = [];
dots = {sub_dd(:).name}; dots_ = strcmp(dots,'..'); sub_dd(dots_) = [];
% dirs = true([length(sub_dd),1]);
dirs = true(size(sub_dd));
for di = length(sub_dd):-1:1
   dirs(di) = sub_dd(di).isdir && ~(strcmp(sub_dd(di).name,'.') || strcmp(sub_dd(di).name,'..'));   
end
sub_dd = sub_dd(dirs);

% Get listing from all sub-directories
for di = length(sub_dd):-1:1
   dd_ = dirrec([pname, sub_dd(di).name, filesep,fmask]);
   dd = [dd;dd_];   
end
if ~isempty(dd)
for fn = length(dd):-1:1
   fnames(fn) = {dd(fn).name};
end
[~,fi]= sort(fnames); 
fnames = fnames(fi)'; 
dd = dd(fi);
end

return


