function [DOY_MFRSR,IPWV_MFRSR,m_H2O_MFRSR]=read_MFRSR_h2o;
% Reads Jim Barnards MFRSR water vapor data
pathname='d:\Beat\Data\Oklahoma\MFRSR\version_991025\';
filelist=str2mat('mfrsr_09_15_97.h2o');
filelist=str2mat(filelist,...
'mfrsr_09_16_97.h2o',...
'mfrsr_09_17_97.h2o',...
'mfrsr_09_18_97.h2o',...
'mfrsr_09_25_97.h2o',...
'mfrsr_09_26_97.h2o',...
'mfrsr_09_27_97.h2o',...
'mfrsr_09_28_97.h2o',...
'mfrsr_09_29_97.h2o',...
'mfrsr_09_30_97.h2o',...
'mfrsr_10_01_97.h2o',...
'mfrsr_10_02_97.h2o',...
'mfrsr_10_03_97.h2o',...
'mfrsr_10_04_97.h2o',...
'mfrsr_10_05_97.h2o');

IPWV_MFRSR_all=[];
DOY_MFRSR_all=[];
m_H2O_all=[];
for ifile=1:15
 filename=filelist(ifile,:) 
 fid=fopen(deblank([pathname filename]));
 data=fscanf(fid,'%f',[2 inf]);
 UT=data(1,:)+6;
 IPWV_MFRSR=data(2,:);
 fclose(fid);
 %determine date from filename
 day=str2num(filename(10:11)); 
 month=str2num(filename(7:8));
 year=str2num(filename(13:14))+1900;
 
 %compute airmass
 n=length(UT);
 geog_long=ones(1,n)* -97.485;
 geog_lat=ones(1,n)*36.605;
 temp=ones(1,n)*300;
 pressure=ones(1,n)*975;
 [azimuth, altitude,r]=sun(geog_long, geog_lat,day, month, year, UT,temp,pressure);
 SZA=90-altitude;
 m_H2O=1./(cos(SZA*pi/180)+0.0548*(92.65-SZA).^(-1.452));   %Kasten (1965)
 
 %compose arrray
 DOY_MFRSR=julian(day,month,year,UT)-julian(31,12,1996,0);
 IPWV_MFRSR_all=[IPWV_MFRSR_all IPWV_MFRSR];
 DOY_MFRSR_all=[DOY_MFRSR_all DOY_MFRSR];
 m_H2O_all=[m_H2O_all m_H2O];
end 

IPWV_MFRSR=IPWV_MFRSR_all;
DOY_MFRSR=DOY_MFRSR_all;
m_H2O_MFRSR=m_H2O_all;

%remove values with large slant path water vapor amounts because data become noisy 
ii=find(m_H2O_MFRSR.*IPWV_MFRSR<=23);
IPWV_MFRSR=IPWV_MFRSR(ii);
DOY_MFRSR=DOY_MFRSR(ii);
m_H2O_MFRSR=m_H2O_MFRSR(ii);