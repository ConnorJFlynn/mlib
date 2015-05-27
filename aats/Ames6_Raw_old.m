function [day,month,year,UT_Laptop,UT_GPS,Mean_volts,Sd_volts,Pressure,Paltkm,Latitude,Longitude,...
      Temperature,Temperature_sd,Az_err,Az_pos,Elev_err,Elev_pos,site,Airmass,AvePeriod,ScanFreq,...
      path,filename,Heading,GPS_Altkm]=Ames6_Raw(name);
    
% Reads 6 channel Ames SPM data file
% Created by Beat Schmid August 28, 1997
% changed 6/30/2000 to remove records with bad time

%Type raw_data 160 Bytes per record
%  CompTimehms As String * 6
%  SerialTimehms As String * 6
%  Latitude As Single = float32
%  Longitude As Single
%  Paltkm As Single
%  Airmass As Single
%  AvePeriod As Integer =int16
%  ScanFreq As Integer
%  ave(1 to 16) As Single
%  sd(1 to 16) as Single
%End Type

%opens data file
[filename,path]=uigetfile([name '*.*'],'Choose a File',0, 0);
fid=fopen([path filename]);

% determines site from path
backslash_pos=findstr(path,'\');
[value,pos]=max(backslash_pos);
site=path([backslash_pos(pos-1)+1:backslash_pos(pos)-1])

%determine date from filename
months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
day=str2num(filename(1:2))
month=ceil(findstr(months,lower(filename(3:5)))/3)
year=str2num(filename(6:7))
if year < 80
   year=year+2000;
else
   year=year+1900;
end   

%determine if old 12-bit or new 16-bit version of DaqBook
if julian(day, month,year,12) < julian(1,11,1999,12)
   DAQ=12;
   conversion=10/(2^12-1);
else
   DAQ=16;
   conversion=10/(2^16-1);
end   

%opens skip file
skipfile=[filename '.skp'];
fid2=fopen([path skipfile]);
if fid2~=-1 
   skip=fscanf(fid2,'%i',[1,inf]);
   fclose(fid2);
   start_rec=skip(1);
   last_rec=skip(2);
   if last_rec==0
      last_rec=inf;
   end   
   skip=skip(3:end);
else
   start_rec=1;
   last_rec=inf;
   skip=[]
end
nrec=last_rec-start_rec+1;

Time=fread(fid,[12 nrec],'12*uchar',160-12);
status=fseek(fid,(start_rec-1)*160+12,'bof');
SciData=fread(fid,[37 nrec],'37*float32',12);
status=fseek(fid,(start_rec-1)*160+12+16,'bof');
IngData=fread(fid,[2 nrec],'2*int16',128+12+16);
fclose(fid);

%remove skipped records
SciData(:,skip)=[];
IngData(:,skip)=[];
Time(:,skip)=[];

%remove records with bad time
ii=find(Time(1,:)<48 | Time(1,:)>57); %only ascii 48 thru 57 produce numbers 0 thru 9
SciData(:,ii)=[];
IngData(:,ii)=[];
Time(:,ii)=[];

hour=str2num(char(Time([1:2],:))')';
minute=str2num(char(Time([3:4],:))')';
second=str2num(char(Time([5:6],:))')';
UT_Laptop=hour+minute/60+second/3600;
%check and fix day rollover
ii=find(diff(UT_Laptop)<0);
UT_Laptop(ii+1:end)=UT_Laptop(ii+1:end)+24;

hour=str2num(char(Time([7:8],:))')';
minute=str2num(char(Time([9:10],:))')';
second=str2num(char(Time([11:12],:))')';
UT_GPS=hour+minute/60+second/3600;
%check and fix day rollover
ii=find(diff(UT_GPS)<0);
UT_GPS(ii+1:end)=UT_GPS(ii+1:end)+24;

Latitude =SciData(1,:);
Longitude=SciData(2,:);
Paltkm   =SciData(3,:);
Airmass  =SciData(4,:);
AvePeriod=IngData(1,:);
ScanFreq =IngData(2,:);

ave      =SciData([6:21],:)*conversion;
sd       =SciData([22:37],:)*conversion;

if DAQ==12 
 Mean_volts=ave([1:4 6 5],:);
 Sd_volts  =sd ([1:4 6 5],:);
end;

if DAQ==16
 Mean_volts=ave([1:4 6 5],:)-5;
 Sd_volts  =sd ([1:4 6 5],:);
end;

Temperature(1,:)=(ave(7,:)-2.318)/0.1; %See function Volt2Temp_det in Basic Software
Temperature_sd(1,:)=sd(7,:)/0.1; %See function Volt2Temp_det in Basic Software

Temperature(2,:)=(ave(8,:)-8.22211)/0.0301; %See function Volt2Temp in Basic Software
Temperature_sd(2,:)=sd(8,:)/0.0301;%See function Volt2Temp in Basic Software

%Starting July 1, 2000 in PRIDE this position has been filled with Heading. But this has been reversed after PRIDE 
if julian(day, month,year,12) > julian(1,7,2000,0) & julian(day, month,year,12) < julian(1,9,2000,0)
 Heading=sd(8,:)/conversion;  %=Heading for PRIDE
else
 Heading=sd(8,:)*0;  % Zero else
end

Temperature(3,:)=(ave(11,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
Temperature_sd(3,:)=sd(11,:)/0.0301;%See function Volt2Temp in Basic Software
Temperature(4,:)=(ave(12,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
Temperature_sd(4,:)=sd(12,:)/0.0301;%See function Volt2Temp in Basic Software
Temperature(5,:)=(ave(13,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
Temperature_sd(5,:)=sd(13,:)/0.0301;%See function Volt2Temp in Basic Software

Temperature(6,:)=(ave(14,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
%After 31.5.97 this position has been filled with raw pressure of the Trimble in bits
if julian(day, month,year,12) > julian(31,5,1997,12)
 Pressure=ave(14,:)*15*1013.25*.068046/5;
else
 Pressure=ave(14,:)*0;
end   

Temperature_sd(6,:)=(sd(14,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
%Starting July 3 2000 in PRIDE this position has GPS altitude in feet. But this has been reversed after PRIDE
if julian(day, month,year,12) >= julian(3,7,2000,0)& julian(day, month,year,12) < julian(1,9,2000,0)
GPS_Altkm=sd(14,:)/conversion*.3048e-03;;  %GPSalt_feet in Pride starting 7/3/00
else
GPS_Altkm=sd(14,:)*0;   
end

Az_err=ave(9,:);
Elev_err=ave(10,:);
Az_err_sd=sd(9,:);
Elev_err_sd=sd(10,:);
Az_pos=ave(16,:)*357/9.012;         %See function Bits2Degrees in Basic Software
Elev_pos=(ave(15,:)-7.01)*-90/3.91; %See function Bits2Degrees in Basic Software
Az_pos_sd=ave(16,:);
Elev_pos_sd=ave(15,:);