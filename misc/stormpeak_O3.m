function all_oz = stormpeak_O3;
%% Read in all of TOMS data, creating lat/lon subset
%% cat the subsets all together
% 
% From Ian:
% Lat:     40 27' 18.55021" = 40.45515;
% Lon:  -106 44' 40.03441" = -106.74445
% 3203 m = 10508.5 ft (via Google-Earth altitude...)

lat = 40.45515;
lon= -106.74445;
oz_path = 'C:\case_studies\ozone\toms\';

oz_file = dir([oz_path,'gectomsX1.*.cdf'])
   all_oz = get_oz(lat,lon,ancload([oz_path,oz_file(1).name]));
for f = length(oz_file):-1:2
   oz = get_oz(lat,lon,ancload([oz_path,oz_file(f).name]));
   all_oz = anccat(all_oz,oz);
   disp(f)
end
   
oz_path = 'C:\case_studies\ozone\omi\';

oz_file = dir([oz_path,'gecomiX1.*.cdf'])
for f = length(oz_file):-1:1
   oz = get_oz(lat,lon,ancload([oz_path,oz_file(f).name]));
   all_oz = anccat(all_oz,oz);
   disp(f)
end

out_path = 'C:\case_studies\ozone\'
fname = 'stormpeak_ozone.cdf';
all_oz.fname = [out_path, fname];
% omi path = C:\case_studies\ozone\omi
