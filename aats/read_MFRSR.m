function [DOY_MFRSR,IPWV_MFRSR]=read_MFRSR;
% Reads Jim Barnards MFRSR data
pathname='d:\Beat\Data\Oklahoma\MFRSR\version_971004\';
filelist=str2mat('aerosol_vapor_970910.txt');
filelist=str2mat(filelist,...
'aerosol_vapor_970911.txt',...
'aerosol_vapor_970914.txt',...
'aerosol_vapor_970915.txt',...
'aerosol_vapor_970916.txt',...
'aerosol_vapor_970917.txt',...
'aerosol_vapor_970918.txt',...
'aerosol_vapor_970919.txt',...
'aerosol_vapor_970920.txt',...
'aerosol_vapor_970921.txt',...
'aerosol_vapor_970922.txt',...
'aerosol_vapor_970924.txt',...
'aerosol_vapor_970925.txt',...
'aerosol_vapor_970926.txt',...
'aerosol_vapor_970927.txt',...
'aerosol_vapor_970928.txt',...
'aerosol_vapor_970929.txt',...
'aerosol_vapor_970930.txt',...
'aerosol_vapor_971001.txt',...
'aerosol_vapor_971002.txt',...
'aerosol_vapor_971003.txt');

IPWV_MFRSR_all=[];
DOY_MFRSR_all=[];
for ifile=1:21
 filename=filelist(ifile,:) 
 fid=fopen(deblank([pathname filename]));
 data=fscanf(fid,'%f',[6 inf]);
 LST=data(1,:);
 UT=data(2,:);
 Tau_aero550_MFRSR=data(3,:);
 Alpha_MFRSR=data(4,:);
 Vis_MFRSR=data(5,:);
 IPWV_MFRSR=data(6,:);

 %determine date from filename
 day=str2num(filename(19:20)); 
 month=str2num(filename(17:18));
 year=str2num(filename(15:16))+1900;
 DOY_MFRSR=julian(day,month,year,UT)-julian(31,12,1996,0);
 IPWV_MFRSR_all=[IPWV_MFRSR_all IPWV_MFRSR];
 DOY_MFRSR_all=[DOY_MFRSR_all DOY_MFRSR];
end 

IPWV_MFRSR=IPWV_MFRSR_all;
DOY_MFRSR=DOY_MFRSR_all;
clear IPWV_MFRSR_all;
clear DOY_MFRSR_all;
DOY_MFRSR=DOY_MFRSR(IPWV_MFRSR~=-999.9);
IPWV_MFRSR=IPWV_MFRSR(IPWV_MFRSR~=-999.9);
