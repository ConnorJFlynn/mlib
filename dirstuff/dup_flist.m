function [dup_names] = dup_flist(dd_);
% dup_names is a list of files in dd_1 with identical file name
disp('In dup_flist, add return of substrings in later version')
if ~isavar('dd_')||isempty(dd_)
   dd_ = dirrec(getdir);
end
% if ~isavar('dd_2')||isempty(dd_2)
%    dd_ = dd_1;
% else
%    dd_ = [dd_1;dd_2];
% end
% dd_ is an array of structs
% rearrange dd_ as struct of arrays dd 
dd = arraystruct_to_structarray(dd_);
dd_(dd.isdir)=[]; 
dd = arraystruct_to_structarray(dd_);
[names,ij,ji] = unique(dd.name,'stable'); 
xnames = dd.name; xnames(ij) = [];% duplicated names
[nondup, si] = setxor(dd.name, xnames); % Supposed to be only names of singleton files.
dup_names_ = dd_; 
dup_names_(si) = []; %This should leave only elements with duplicated filename
if isempty(dup_names_)
   dup_names = [];
else
   dup_names = arraystruct_to_structarray(dup_names_);
end

return