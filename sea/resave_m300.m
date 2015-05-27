function resave_m300(m300);

[pname, fname, ext] = fileparts(m300.fullname);
outpath = [pname,fname];
if ~exist(outpath,'dir')
   mkdir(outpath);
end

disp(['Saving "',fname,'.mat".']);
save([outpath,filesep, fname,'.mat'],'m300', '-mat');