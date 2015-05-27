function [MT,UT,Lat,Long,GPS_Alt,Roll,Pitch,Heading,GST,Tamb,Tdamb,RHamb,Pstatic,Palt,Wind_dir,Wind_Speed,GST2,TAS,Ws,Rad_Alt,Theta,Thetae,CNC_CC,PCASP_CC,...
          PCASP_Vol_CC,CASFWD_CC,CASFWD_Vol_CC,FSSP_CC,FSSP_Vol_CC,LWC,H2O_dens]=read_Otter_Cabin(pathname,filename);    

%opens CIRPAS Twin Otter Cabin data file  
Interpolate='ON'

[filename,pathname]=uigetfile([pathname 'CIRPAS\*.*'],'Choose a File');
M = csvread(deblank([pathname filename]),1,0);
ii=find(M(:,1)~=-9999);
M=M(ii,:);

for ivar=2:29    
        ii=find(M(:,ivar)~=-9999);
        M(:,ivar)=interp1(M(ii,1),M(ii,ivar),M(:,1),'nearest');
        disp(sprintf('%i values of variable %i have been interpolated to their nearest neighbor',size(M,1)-size(ii,1),ivar))
end


%Mission Time (s), UTC time (s), Lat, Long, GPS Alt (m), Roll (deg), Pitch (deg), Heading (deg), GST (C), Tamb (C), Tdamb (C), RHamb (%), Pstatic (mb), Palt (m), Wind dir(Deg), 
%Wind Speed (m/s), GST (C), TAS (m/s), Ws (g/Kg), Rad. Alt (m), Theta (K), Thetae (K), CNC (#/CC), PCASP (#/CC), PCASP (Vol/CC), CASFWD (#/CC), CASFWD (Vol/CC), FSSP (#/CC), FSSP (Vol/CC), LWC g/m^3
MT=M(:,1);
hour=floor(M(:,2)/1e4);
min=floor((M(:,2)-hour*1e4)/1e2);
sec=M(:,2)-hour*1e4-min*1e2;
UT=hour+min/60+sec/60/60;
Lat=M(:,3);
Long=-M(:,4); %sign needs to be changed to go with my convention
GPS_Alt=M(:,5)/1e3;
Roll=M(:,6);
Pitch=M(:,7);
Heading=M(:,8);
Heading(Heading<0)=Heading(Heading<0)+360; %want heading to be 0 to 360 not -180 to +180
GST=M(:,9);
Tamb=M(:,10);
Tdamb=M(:,11);
RHamb=M(:,12);
Pstatic=M(:,13);
Palt=M(:,14)/1e3;
Wind_dir=M(:,15);
Wind_Speed=M(:,16);
GST2=M(:,17);
TAS=M(:,18);
Ws=M(:,19);
Rad_Alt=M(:,20)/1e3;
Theta=M(:,21);
Thetae=M(:,22);
CNC_CC=M(:,23);
PCASP_CC=M(:,24);
PCASP_Vol_CC=M(:,25);
CASFWD_CC=M(:,26);
CASFWD_Vol_CC=M(:,27);
FSSP_CC=M(:,28);
FSSP_Vol_CC=M(:,29);
LWC=M(:,30);

ii=find(diff(UT)~=0);
UT=interp1(MT(ii),UT(ii),MT,'linear','extrap');
disp(sprintf('%i UT times are on the same second and have been interpolated linearly',size(UT,1)-size(ii,1)))

%calculate water vapor density
[H2O_dens]=rho_from_Td(Tdamb,Tamb,Pstatic);

return
    