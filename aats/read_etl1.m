pathname='d:\Beat\Data\Oklahoma\etl_mwr1\version_980209\';
filelist=str2mat('etl20_31mwr970915.dat');
filelist=str2mat(filelist,...
'etl20_31mwr970916.dat',...
'etl20_31mwr970917.dat',...
'etl20_31mwr970918.dat',...
'etl20_31mwr970919.dat',...
'etl20_31mwr970920.dat',...
'etl20_31mwr970921.dat',...
'etl20_31mwr970922.dat',...
'etl20_31mwr970923.dat',...
'etl20_31mwr970924.dat',...
'etl20_31mwr970925.dat',...
'etl20_31mwr970926.dat',...
'etl20_31mwr970927.dat',...
'etl20_31mwr970928.dat',...
'etl20_31mwr970929.dat',...
'etl20_31mwr970930.dat',...
'etl20_31mwr971001.dat',...
'etl20_31mwr971002.dat',...
'etl20_31mwr971003.dat',...
'etl20_31mwr971004.dat',...
'etl20_31mwr971005.dat');
filename=filelist(ifile,:); 
fid=fopen(deblank([pathname filename]));
data=fscanf(fid,'%f',[5 inf]);
UT_etl1=data(1,:);
IPWV_etl1=data(2,:);
ILW_etl1=data(3,:)/10;

%determine date from filename
day=str2num(filename(16:17))
month=str2num(filename(14:15))
year=str2num(filename(12:13))+1900
DOY_etl1=julian(day,month,year,UT_etl1)-julian(31,12,1996,0);