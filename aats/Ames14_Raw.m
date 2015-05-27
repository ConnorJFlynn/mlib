function [day,month,year,UT,Mean_volts,Sd_volts,Pressure,Press_Alt,Latitude,Longitude,Heading,...
          Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,pathname,filename]=Ames14_Raw(pathname,filename);
    
% Reads ACE-2 OS-9000 computer data file
% June 6, 1997 created by Beat Schmid
% August 29, 1997 determines site from path
% November 17, 1997 allows correct conversion of hot detector T for measurements before 15.5.97
% May 11, 1998 corrects for time drift

%Type raw_data180   'ACE-2 OS-9000 computer data file
%  Header As String * 2
%  Serial As String * 1
%  Temperature(1 To 7) As Single
%  Latitude As Single
%  Longitude As Single
%  Pressmb As Single
%  Heading As Single
%  Hr As String * 1
%  Min As String * 1
%  Sec As String * 1
%  Mean_volts(1 To 14) As Single
%  Sd_volts(1 To 14) As Single
%  Az_err As Single
%  Elev_err As Single
%  Az_pos As Single
%  Elev_pos As Single
%  CRC As String * 2
%End Type

Interpolate='ON'
Skipping='ON'

%opens data file
[filename,pathname]=uigetfile([pathname '*.*'],'Choose a File');
fid=fopen(deblank([pathname filename]));

% determines site from path
backslash_pos=findstr(pathname,'\');
[value,pos]=max(backslash_pos);
site=pathname([backslash_pos(pos-1)+1:backslash_pos(pos)-1]);
disp(site);

%determine date from filename
months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
day=str2num(filename(2:3));
month=ceil(findstr(months,lower(filename(4:6)))/3);
year=str2num(filename(7:8))+1900;
disp(sprintf('day=%d month=%d year=%d', day,month,year))

%opens skip file
SkipFile=[filename '.skp'];
fid2=fopen([pathname SkipFile]);
if (fid2~=-1 & strcmp(Skipping,'ON'))
   skip=fscanf(fid2,'%i',[1,inf]);
   fclose(fid2);
   start_rec=skip(1);
   last_rec=skip(2);
   if last_rec==0;
      last_rec=inf;
   end   
   skip=skip(3:end);
else
   start_rec=1;
   last_rec=inf;
   skip=[];
end
nrec=last_rec-start_rec+1;

%Header=fread(fid,[3 inf],'3*uchar',177);
status=fseek(fid,(start_rec-1)*180+3,'bof');
IngData=fread(fid,[11 nrec],'11*float',136);
status=fseek(fid,(start_rec-1)*180+47,'bof');
Time=fread(fid,[3 nrec],'3*uchar',177);
status=fseek(fid,(start_rec-1)*180+50,'bof');
SciData=fread(fid,[32 nrec],'32*float',52);
fclose(fid);

IngData(:,skip)=[];
SciData(:,skip)=[];
Time(:,skip)=[];
if julian(day,month,year,0) > julian(15,5,1997,0)
  Temperature(1,:)=IngData(1,:)*1.95169-326.114; % Conversion after May 1997
else
  Temperature(1,:)=IngData(1,:)*1.953  -333.782; % Conversion before May 1997
end
Temperature(2,:)=(2.5-(IngData(2,:)-37.65)/19.178)/0.05;
Temperature(3,:)=(2.5-(IngData(3,:)-37.65)/19.178)/0.05;
Latitude=IngData(8,:);
Longitude=IngData(9,:);
Pressure=IngData(10,:);

if julian(day,month,year,0) == julian(18,6,1997,0)
   Pressure=100.04/100*(Pressure-600)+577.3; %Going from factory Cal to Final Cal of Pressure sensor 
elseif julian(day,month,year,0) == julian(27,6,1997,0)
   Pressure=Pressure+14;    % Pressure data from UW are matched into data file needs to be corrected
elseif julian(day,month,year,0) >= julian(19,6,1997,0) & julian(day,month,year,0) <= julian(20,7,1997,0)
   Pressure=100.04/100*(Pressure+37-600)+577.3; %Going from ACE-2 Cal to Final Cal of Pressure sensor 
end

Heading=IngData(11,:);
UT=Time(1,:)+Time(2,:)/60+Time(3,:)/3600;
Mean_volts=SciData([1:14],:);
Sd_volts=SciData([15:28],:);
Az_err=SciData(29,:);
Elev_err=SciData(30,:);
Az_pos=SciData(31,:);
Elev_pos=SciData(32,:);

% Instrument was mounted 'backwards'on Pelican 
Az_pos=mod((Az_pos+180),360);

%interpolate GPS Lat/Long drop outs
if strcmp(Interpolate,'ON')
 i=find((Latitude~=-99999) & (Longitude~=-99999));
 Latitude=interp1(UT(i),Latitude(i),UT);
 Longitude=interp1(UT(i),Longitude(i),UT);
 disp(sprintf('%i Lat/Long pairs have been linearly interpolated',size(Latitude,2)-size(i,2)))
end

%Pressure Altitude according to J. Livingston as long as Press_Alt <=11km
Press_Alt=288.15/6.5*(1-((Pressure)/1013.25).^(1/5.255876114));

%opens time drift file and corrects
DriftFile=[filename '.clock'];
fid2=fopen([pathname DriftFile]);
if fid2~=-1 
   data=fscanf(fid2,'%g',[2,inf]);
   fclose(fid2);
   UT_drift=data(1,:);
   Delta_t=data(2,:);
   Delta_t=interp1(UT_drift,Delta_t,UT);
   UT=UT-Delta_t/3600;
   disp(sprintf('Time correction ranges from %g to %g sec',min(Delta_t),max(Delta_t)))
end

%corrects for time delay in Can PC
delay=-4;
UT=UT+delay/3600;
