[dirlist,pname] = dir_list('*.nc');
for i = 1:length(dirlist);
    disp(['Processing data file: ', dirlist(i).name]);
    rerange(pname, dirlist(i).name);
end;