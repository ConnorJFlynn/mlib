function cimel = read_cimel_2p1(filename);
%Seems like a different format than other cimel 2.0 files having more filters.

if ~exist('filename', 'var')
   filename = getfullname('*.txt;*.dat','aeronet_aip','Select Aeronet AIP file');
   [pname, fname, ext] = fileparts(filename);
   fname = [fname ext];
%     [fname, pname] = uigetfile('C:\case_studies\Alive\data\flynn-cimel\*.txt');
%     filename = [pname, fname];
end

fid = fopen(filename);
%%
% Date(dd-mm-yy),Time(hh:mm:ss),Julian_Day,AOT_1020,AOT_870,AOT_670,AOT_500,AOT_440,AOT_380,AOT_340,AOT_532,AOT_535,AOT_1640,Water(cm),%TripletVar_1020,%TripletVar_870,%TripletVar_670,%TripletVar_500,%TripletVar_440,%TripletVar_380,%TripletVar_340,%TripletVar_532,%TripletVar_535,%TripletVar_1640,%WaterError,440-870Angstrom,380-500Angstrom,440-675Angstrom,500-870Angstrom,340-440Angstrom,440-675Angstrom(Polar),Last_Processing_Date,Solar_Zenith_Angle,SunphotometerNumber,AOT_1020-ExactWavelength(nm),AOT_870-ExactWavelength(nm),AOT_670-ExactWavelength(nm),AOT_500-ExactWavelength(nm),AOT_440-ExactWavelength(nm),AOT_380-ExactWavelength(nm),AOT_340-ExactWavelength(nm),AOT_532-ExactWavelength(nm),AOT_535-ExactWavelength(nm),AOT_1640-ExactWavelength(nm),Water(cm)-ExactWavelength(nm)
% 45 fields
% txt = textscan(fid,'%*s %*s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*s %f ','headerlines',5,'delimiter',',','treatAsEmpty','N/A');
% There is a %s way down at field #43
txt = textscan(fid,'%s %s %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %s %f  %f %f %f %f %f %f %f %f %f %f %f %f ','headerlines',4,'delimiter',',','treatAsEmpty','N/A');
this = txt{1};
that = txt{2};
for d = 1:length(this)
dates{d} = [this{d},' ',that{d}];
end
cimel.time = datenum(dates,'dd:mm:yyyy HH:MM:SS');
% cimel.aod_1640 = txt{4};
c = 4;
cimel.aod_1020 = txt{c};c = c+1;
cimel.aod_870 = txt{c};c = c+1;
cimel.aod_670 = txt{c};c = c+1;
cimel.aod_500 = txt{c};c = c+1;
cimel.aod_440 = txt{c};c = c+1;
cimel.aod_380 = txt{c};c = c+1;
cimel.aod_340 = txt{c};c = 26;
cimel.ang_440_870 = txt{6};c = c+1;
cimel.ang_380_500 = txt{c};c = c+1;
cimel.ang_440_675 = txt{c};c = c+1;
cimel.ang_500_870 = txt{c};c = c+1;
cimel.ang_340_440 = txt{c};c = 33;
cimel.zenith_angle = txt{c};
cimel.aod_415 = cimel.aod_440 .* ((440/415) .^cimel.ang_340_440);
cimel.aod_615 = cimel.aod_500 .* ((500/615) .^cimel.ang_500_870);
cimel.aod_523 = cimel.aod_500 .* ((500/523) .^cimel.ang_500_870);
return;