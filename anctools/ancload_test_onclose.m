%%
clear('all')
in_dir = 'H:\case_studies\AMF_AOD\grwmfrsrM1.b1\badlang\';
fs = dir([in_dir,'*.cdf']);
infile = [in_dir, fs(1).name];
ncid = netcdf.open(infile,'nowrite');
netcdf.close(ncid);
%%
tmp = ancload(infile);

%%
for f = length(fs):-1:1
   infile = [in_dir, fs(f).name];
   tmp = ancload(infile);

% ncid = netcdf.open(infile,'nowrite');
% netcdf.close(ncid);
disp(num2str(f))
end
tmp = ancload(infile);
   