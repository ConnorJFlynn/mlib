function status = plot_all;

pname = [];
while length(pname)==0
  [fname, pname] = uigetfile('*.cdf', 'Select a netcdf file');
end

file_list = dir([pname, '*.cdf']);
for i = 1:length(file_list)
   %open each file, load the dimensional data, the variable date, etc.
   %ncid = mexnc('open', ['anypath/',file_list(i).name]);
  
   cdf = ancload([pname,file_list(i).name]);
   cdf.image_path = pname;
   status = radarplots(cdf);
end

function status = radarplots(cdf);

figure; imagesc(serial2Hh(cdf.time), cdf.vars.Heights.data, cdf.vars.SpectralWidth.data); 
axis('xy'); colorbar
v = axis
cv = caxis



[PATHSTR,NAME,EXT] = fileparts(cdf.fname) 
print('-dpng',[cdf.imagepath, NAME, '.SpectralWidth.png'])
end