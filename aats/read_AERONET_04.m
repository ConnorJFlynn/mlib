function [lambda_exact,AOD_err,Time,DOY,AOD,CWV]=read_AERONET_04;
% Reads AERONET all AOD new data format as of August, 2004

%Date(dd-mm-yy)	Time(hh:mm:ss)	Julian_Day	AOT_1020 AOT_870 AOT_670 AOT_500 AOT_440 AOT_380 AOT_340 AOT_532 AOT_535 AOT_1640 Water(cm)
% %TripletVar_1020 %TripletVar_870 %TripletVar_670 %TripletVar_500 %TripletVar_440 %TripletVar_380 %TripletVar_340 %TripletVar_532 %TripletVar_535 %TripletVar_1640
% %WaterError	440-870Angstrom	380-500Angstrom	440-675Angstrom	500-870Angstrom	340-440Angstrom	440-675Angstrom(Polar)
% Last_Processing_Date	Solar_Zenith_Angle	SunphotometerNumber
% AOT_1020-ExactWavelength(nm)	AOT_870-ExactWavelength(nm)	AOT_670-ExactWavelength(nm)	AOT_500-ExactWavelength(nm)	AOT_440-ExactWavelength(nm)	AOT_380-ExactWavelength(nm)	AOT_340-ExactWavelength(nm)	AOT_532-ExactWavelength(nm)	AOT_535-ExactWavelength(nm)	AOT_1640-ExactWavelength(nm)	Water(cm)-ExactWavelength(nm)

AOD_err=[0.020 0.015 0.015 0.015 0.010 0.010 0.010 0.010];
[filename, pathname] = uigetfile('c:\beat\data\aerosol iop\aeronet\*.xls', 'Pick a file');

[A, B]= xlsread([pathname filename]) ;

Time=A(:,1);
DOY=A(:,2);
AOD=A(:,[9,8,7,6,5,4,3,12]); % AOT_1020,AOT_870,AOT_670,AOT_500,AOT_440,AOT_380,AOT_340, AOT 1640
CWV=A(:,13 );
lambda_exact=A(:,[40,39,38,37,36,35,34,43])/1e3;

