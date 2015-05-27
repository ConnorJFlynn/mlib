function save_m300(m300)
% save_m300(m300)
% saves M300 file as .mat file in like-named directory at same level as
% m300 file.

[pname, fname, ext] = fileparts(m300.fullname);
outpath = [pname,fname];
if ~exist(outpath,'dir')
   mkdir(outpath);
end

disp(['Saving "',fname,'.mat".']);
save([outpath,filesep, fname,'.mat'],'m300', '-mat');

