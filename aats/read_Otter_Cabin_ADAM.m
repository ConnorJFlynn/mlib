function [MT,UT,Lat,Long,GPS_Alt,Roll,Pitch,Heading,Tamb,Tdamb,RHamb,Pstatic,Palt,Wind_dir,Wind_Speed,SST,TAS,PCASP_CC,...
          PCASP_Vol_CC,CASFWD_CC,CASFWD_Vol_CC,H2O_dens]=read_Otter_Cabin_ADAM(pathname,filename);    

%opens CIRPAS Twin Otter Cabin data file  
Interpolate='ON'

[filename,pathname]=uigetfile([pathname 'CIRPAS\*.*'],'Choose a File');
M = csvread(deblank([pathname filename]),1,0);
ii=find(M(:,1)~=-9999);
M=M(ii,:);

% for ivar=2:46    
%         ii=find(M(:,ivar)~=-9999);
%         M(:,ivar)=interp1(M(ii,1),M(ii,ivar),M(:,1),'nearest');
%         disp(sprintf('%i values of variable %i have been interpolated to their nearest neighbor',size(M,1)-size(ii,1),ivar))
% end

%Mission Time (s), UTC time (s), Lat, Long, Alt (m), East Vel (m/s), North Vel (m/s), Up Vel (m/s), Roll (deg), Pitch (deg), Heading (deg), 
%Tm NE (s), Blue Scatter, Green Scatter, Red Scatter, Blue Backscatter, Green Backscatter, Red Backscatter, Sensitivity, P (mb), Ts (C), Ti (C), RH (%), Lamp V, Lamp I, BNC Input, Status,
%Tm CPC (s), CPC1 Count period, CPC1 Buffer, CPC1 (#/CC), CPC1 dTsc (C), Tamb (C), Tdamb (C), RHamb (%), Ps (mb), Palt (feet), 
%Wind dir(Deg), Wind Speed (m/s), Vert. Wind (m/s), SST (C), TAS (m/s), PCASP (#/CC), PCASP (Vol/CC), CASFWD (#/CC), CASFWD (Vol/CC)

MT=M(:,1);
hour=floor(M(:,2)/1e4);
min=floor((M(:,2)-hour*1e4)/1e2);
sec=M(:,2)-hour*1e4-min*1e2;
UT=hour+min/60+sec/60/60;
ii=find(UT<=3);
UT(ii)=UT(ii)+24;
Lat=M(:,3);
Long=-M(:,4); %sign needs to be changed to go with my convention
GPS_Alt=M(:,5)/1e3;
%6
%7
%8
Roll=M(:,9);
Pitch=M(:,10);
Heading=M(:,11);
Heading(Heading<0)=Heading(Heading<0)+360; %want heading to be 0 to 360 not -180 to +180
%12-27
%28-32
Tamb=M(:,33);
Tdamb=M(:,34);
RHamb=M(:,35);
Pstatic=M(:,36);
Palt=M(:,37)/1000;
Wind_dir=M(:,38);
Wind_Speed=M(:,39);
%40
SST=M(:,41);
TAS=M(:,42);
PCASP_CC=M(:,43);
PCASP_Vol_CC=M(:,44);
CASFWD_CC=M(:,45);
CASFWD_Vol_CC=M(:,46);

ii=find(diff(UT)~=0);
UT=interp1(MT(ii),UT(ii),MT,'linear','extrap');
disp(sprintf('%i UT times are on the same second and have been interpolated linearly',size(UT,1)-size(ii,1)))

%calculate water vapor density
[H2O_dens]=rho_from_Td(Tdamb,Tamb,Pstatic);

return
    