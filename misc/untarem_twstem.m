%Untar the TWST tar-files into separate directories

tars = getfullname('*.tar','tarfiles');

for t = length(tars):-1:1
   [pname, fname, ext] = fileparts(tars{t});
   outdir = [pname, filesep,fname];
   files = untar(tars{t},outdir);
   sprintf('file %d,  %s: %d',t, fname, length(files))
end

% Get list of these directories 
pname = getdir('tarfiles');
dirs = dir([pname,filesep,'*twst*.nc']);

for d = 5:length(dirs)
   files = dirlist_to_filelist( dir([dirs(d).folder,filesep,dirs(d).name, filesep,'*.nc']),[dirs(d).folder,filesep,dirs(d).name, filesep]);
   twst = rd_twst_nc4(files);
   if iscell(files)
      [pname, fname, ext] = fileparts(files{1});
   else
      [pname, fname, ext] = fileparts(files);
   end
   pname = fileparts(pname); % pname = fileparts(pname);
   pname = [pname, filesep]; pname = strrep(pname, [filesep filesep], filesep);
   fname = ['sgptwstC1.TWST-EN0011.',datestr(min(twst.time),'yyyymmdd_hh')];
   n_str = []; n = 1;
   while isafile([pname, fname, n_str,'.mat'])
      n = n+1;
      n_str = ['_',num2str(n)];
   end

   figure_(9); plot(twst.time, twst.zenrad_A(203,:),'co'); dynamicDateTicks
   title(fname)
   save([pname, fname, n_str,'.mat'],'-struct','twst');
end

pname = getdir('tarfiles');
dirs = dir(['E:\Instruments\TWST\TWST-EN0011',filesep,'*twst*.mat']);