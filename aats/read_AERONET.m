function [lambda,AOD_err,Time,DOY,AOD,CWV]=read_AERONET;
% Reads AERONET all AOD data format as of November, 2003
lambda=       [0.340 0.380 0.440 0.500 0.670 0.870 1.020 1.604];
AOD_err=[0.020 0.015 0.015 0.015 0.010 0.010 0.010 0.010];
[filename, pathname] = uigetfile('c:\beat\data\aerosol iop\aeronet\*.xls', 'Pick a file');

[A, B]= xlsread([pathname filename]) ;

Time=A(:,1);
DOY=A(:,2);
AOD=A(:,[9,8,7,6,5,4,3,12]); % AOT_1020,AOT_870,AOT_670,AOT_500,AOT_440,AOT_380,AOT_340, AOT 1640
CWV=A(:,13);

