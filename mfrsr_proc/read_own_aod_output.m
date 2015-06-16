function all = read_own_aod_output;
% all = read_own_aod_output;
% reads the AOD files I provided to Evgueni
aod_file = getfullname('*.txt');

% 1997 5 1 0 0 0 121.000000 0.0000 0.125 0.087 0.070 0.062 0.040 1.593 
% yyyy m d H M S doy.ff UTC.hh aod415, aod500, aod615, aod676, aod870, ang
fid = fopen(aod_file);
if fid>0
   format_str = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f';
   txt = textscan(fid,format_str);
end
fclose(fid);
%%
all.time = datenum([txt{1},txt{2},txt{3},txt{4},txt{5},txt{6}]);
%%
all.doy = txt{7};
all.Hh = txt{8};
all.aod_415 = txt{9};
all.aod_500 = txt{10};
all.aod_615 = txt{11};
all.aod_673 = txt{12};
all.aod_870 = txt{13};
all.ang     = txt{14};
%%


fields = fieldnames(all);
for fl = length(fields):-1:1
   nans = all.(fields{fl})<-0.9;
   all.(fields{fl})(nans) = NaN;
end
all.fname = aod_file;
[dmp,fstem,ext] = fileparts(aod_file)
year = 1997 + (all.time - datenum(1997,1,1))./365;
%%
figure; plot(all.time, all.aod_500, '.'); datetick
title([fstem,ext],'interpreter','none');
ylabel('aod 500 nm')
xlabel('time')


