
function tags = find_mats(it);
% Returns all explicit references to a mat file within the supplied or
% selected file.
if ~exist('it','var')
    it = getfullname('*.m');
end
fid = fopen(it,'r');
tags = textscan(fid,'%s','delimiter',[[filesep filesep], pathsep,' ',')','''' ',']);
fclose(fid);
tags = tags{:};
%%
for a = length(tags):-1:1
    if isempty(strfind(tags{a},'.mat'))||strcmp(tags{a},'*.mat')
        tags(a) = [];
    end
end
%%

return