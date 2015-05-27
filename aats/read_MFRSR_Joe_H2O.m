function [DOY_mfrsr_Joe,IPWV_mfrsr_Joe,m_H2O_mfrsr_Joe]=read_MFRSR_Joe_H2O;
%read mfrsr h2o as produced by Joe Michalsky's relative method
IPWV_mfrsr_all=[];
DOY_mfrsr_all=[];
m_H2O_all=[];

for ifile=1:12
 %pathname='D:\Beat\Data\Oklahoma\mfrsr\version_991122\'; % These are the MOD 3.7 results
 pathname='D:\Beat\Data\Oklahoma\mfrsr\version_20000302\'; % These are the LBLRTM 5.10 results

 filelist=str2mat('h2o970918');
 filelist=str2mat(filelist,...
 'h2o970925',...
 'h2o970926',...
 'h2o970927',...
 'h2o970928',...
 'h2o970929',...
 'h2o970930',...
 'h2o971001',...
 'h2o971002',...
 'h2o971003',...
 'h2o971004',...
 'h2o971005');
 filename=filelist(ifile,:) 
 fid=fopen(deblank([pathname filename]));
 data=fscanf(fid,'%f',[2 inf]);
 DOY_mfrsr_Joe=data(1,:);
 IPWV_mfrsr_Joe=data(2,:);
 fclose(fid);
 
 %determine date from filename
 day=str2num(filename(8:9)) ;
 month=str2num(filename(6:7));
 year=str2num(filename(4:5))+1900;
 
 %determine UT from DOY
 UT=24*(DOY_mfrsr_Joe-floor(DOY_mfrsr_Joe)); 
 
 %compute airmass
 n=length(UT);
 geog_long=ones(1,n)* -97.485;
 geog_lat=ones(1,n)*36.605;
 temp=ones(1,n)*300;
 pressure=ones(1,n)*975;
 [azimuth, altitude,r]=sun(geog_long, geog_lat,day, month, year, UT,temp,pressure);
 SZA=90-altitude;
 m_H2O=1./(cos(SZA*pi/180)+0.0548*(92.65-SZA).^(-1.452));   %Kasten (1965)
 
 %compose array
 IPWV_mfrsr_all=[IPWV_mfrsr_all IPWV_mfrsr_Joe];
 DOY_mfrsr_all=[DOY_mfrsr_all DOY_mfrsr_Joe];
 m_H2O_all=[m_H2O_all m_H2O];

end 

IPWV_mfrsr_Joe=IPWV_mfrsr_all;
DOY_mfrsr_Joe=DOY_mfrsr_all;
m_H2O_mfrsr_Joe=m_H2O_all;

%remove values with large slant path water vapor amounts because data become noisy 
ii=find(m_H2O_mfrsr_Joe.*IPWV_mfrsr_Joe<=23);
IPWV_mfrsr_Joe=IPWV_mfrsr_Joe(ii);
DOY_mfrsr_Joe=DOY_mfrsr_Joe(ii);
m_H2O_mfrsr_Joe=m_H2O_mfrsr_Joe(ii);



