function cimel = read_cimel_2p0(filename);
%%
% this works reading ARM Highlands AOD v2 level 2
if ~exist('filename', 'var')
   filename = getfullname('*.txt;*.dat','aeronet_aip','Select Aeronet AIP file');
   [pname, fname, ext] = fileparts(filename);
   fname = [fname ext];
%     [fname, pname] = uigetfile('C:\case_studies\Alive\data\flynn-cimel\*.txt');
%     filename = [pname, fname];
end

fid = fopen(filename);
%%
% Date(dd-mm-yy),Time(hh:mm:ss),Julian_Day,AOT_1640,AOT_1020,AOT_870,AOT_675,AOT_667,AOT_555,AOT_551,AOT_532,AOT_531,AOT_500,AOT_490,AOT_443,AOT_440,AOT_412,AOT_380,AOT_340,Water(cm),%TripletVar_1640,%TripletVar_1020,%TripletVar_870,%TripletVar_675,%TripletVar_667,%TripletVar_555,%TripletVar_551,%TripletVar_532,%TripletVar_531,%TripletVar_500,%TripletVar_490,%TripletVar_443,%TripletVar_440,%TripletVar_412,%TripletVar_380,%TripletVar_340,%WaterError,440-870Angstrom,380-500Angstrom,440-675Angstrom,500-870Angstrom,340-440Angstrom,440-675Angstrom(Polar),Last_Processing_Date,Solar_Zenith_Angle
% txt = textscan(fid,'%*s %*s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*s %f ','headerlines',5,'delimiter',',','treatAsEmpty','N/A');
txt = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*s %f ','headerlines',5,'delimiter',',','treatAsEmpty','N/A');
this = txt{1};
that = txt{2};
for d = 1:length(this)
dates{d} = [this{d},' ',that{d}];
end
cimel.time = datenum(dates,'dd:mm:yyyy HH:MM:SS');
cimel.aod_1640 = txt{4};
cimel.aod_1020 = txt{5};
cimel.aod_870 = txt{6};
cimel.aod_675 = txt{7};
cimel.aod_500 = txt{13};
cimel.aod_440 = txt{16};
cimel.aod_380 = txt{18};
cimel.aod_340 = txt{19};
cimel.ang_440_870 = txt{38};
cimel.ang_380_500 = txt{39};
cimel.ang_440_675 = txt{40};
cimel.ang_500_870 = txt{41};
cimel.ang_340_440 = txt{42};
cimel.zenith_angle = txt{44};
cimel.aod_415 = cimel.aod_440 .* ((440/415) .^cimel.ang_340_440);
cimel.aod_615 = cimel.aod_500 .* ((500/615) .^cimel.ang_500_870);
cimel.aod_523 = cimel.aod_500 .* ((500/523) .^cimel.ang_500_870);
return;