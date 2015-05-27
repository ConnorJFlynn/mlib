function flist = dirlist_to_filelist(dlist,pname);
% Converts a directory list and pathname (returned by dir_) to a file list
% array of char with full path spec.

if length(dlist)==1
   flist(1) = {[pname, char(dlist.name)]};
else
for d = 1:length(dlist)
   flist(d) = {[pname, char(dlist{d}.name)]};
end
end
return
  