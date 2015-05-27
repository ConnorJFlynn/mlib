function status = fixemall

pname = uigetdir('Select the directory with GRUVLI files to fix.');

file_list = dir([pname, '\*.nc']);

if length(file_list)>0
   for f =1:length(file_list)
      disp(['Fixing ',file_list(f).name, ' , file ',num2str(f), ' of ', num2str(length(file_list))])
      status = fix_gruvli_time([pname, '/',file_list(f).name]);
   end
end