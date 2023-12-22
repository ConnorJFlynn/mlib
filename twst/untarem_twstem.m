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

pname = getdir('twst_mats');
mats = dirlist_to_filelist( dir([pname,'*twst*.mat']), pname);
twst = load(mats{1});
wl_ = interp1(twst.wl_A,[1:length(twst.wl_A)],[415,440,500,615,673,870],'nearest')';
wl_415_ = twst.wl_A>412 & twst.wl_A<418;
clear tws tws_
tws.time = twst.time; 
tws.zrad = twst.zenrad_A(wl_,:);
tws.zrad_415avg = mean(twst.zenrad_A(wl_415_,:));

for m = 2:length(mats)
   twst = load(mats{m});
   tws_.time = twst.time;
   tws_.zrad = twst.zenrad_A(wl_,:);
   tws_.zrad_415avg = mean(twst.zenrad_A(wl_415_,:));
   [tws.time, ij] = unique([tws.time, tws_.time]);
   tmp = [tws.zrad,tws_.zrad]; tws.zrad = tmp(:,ij);
   tmp = [tws.zrad_415avg,tws_.zrad_415avg]; tws.zrad_415avg = tmp(ij);
   disp(length(tws.time))
end
save('D:\AGU_prep\tws_wls.mat','-struct','tws')

% Modify for SASZe 
pname = getdir('SASZE');
mats = dirlist_to_filelist( dir([pname,'*twst*.mat']), pname);
twst = load(mats{1});
wl_ = interp1(twst.wl_A,[1:length(twst.wl_A)],[415,440],'nearest')';
wl_415_ = twst.wl_A>412 & twst.wl_A<418;
clear tws tws_
tws.time = twst.time; 
tws.zrad = twst.zenrad_A(wl_,:);
tws.zrad_415avg = mean(twst.zenrad_A(wl_415_,:));

for m = 2:length(mats)
   twst = load(mats{m});
   tws_.time = twst.time;
   tws_.zrad = twst.zenrad_A(wl_,:);
   tws_.zrad_415avg = mean(twst.zenrad_A(wl_415_,:));
   [tws.time, ij] = unique([tws.time, tws_.time]);
   tmp = [tws.zrad,tws_.zrad]; tws.zrad = tmp(:,ij);
   tmp = [tws.zrad_415avg,tws_.zrad_415avg]; tws.zrad_415avg = tmp(ij);
   disp(length(tws.time))
end
