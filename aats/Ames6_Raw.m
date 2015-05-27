function [day,month,year,UT_Laptop,UT_GPS,Mean_volts,Sd_volts,Pressure,Paltkm,Latitude,Longitude,...
      Temperature,Temperature_sd,Az_err,Az_pos,Elev_err,Elev_pos,Elev_pos_sd,Az_pos_sd,Elev_err_sd,...
      Az_err_sd,site,Airmass,AvePeriod,ScanFreq,path,filename,Heading,GPS_Altkm,AmbientTempC]=Ames6_Raw(name);
    
% Reads 6 channel Ames SPM data file
% Created by Beat Schmid August 28, 1997
% changed 6/30/2000 to remove records with bad time
% modified 3/14/2001 by John Livingston to handle NCAR C-130 VB AATS-6 data acquisition setup
% modified 4/21/2001 by JML
% modified 9/20/2001 by Beat Schmid to allow to change p0 and T0 for Pressure Alt computation

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

EldegperV_in = -23.0661504; %updated 2/22/01 B
Volt_offset_in=7.0296071; %updated 2/22/01 B
%EldegperV_DACout = -22.9382851; %updated 2/22/01 B
%Volt_offset_DACout = 7.0672857; %updated 2/22/01 B
%pos_deg_out = (pos_volt_out - Volt_offset_DACout) * EldegperV_DACout;  %updated 2/22/01 B
%pos_deg_in = (pos_volt_in - Volt_offset_in) * EldegperV_in;  %updated 2/22/01 B

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
[i j]=find(Time([1:6],:)<48 | Time([1:6],:)>57); %only ascii 48 thru 57 produce numbers 0 thru 9
SciData(:,j)=[];
IngData(:,j)=[];
Time   (:,j)=[];

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
elseif julian(day, month,year,12) >= julian(14,3,2001,0)& julian(day, month,year,12) < julian(15,5,2001,0)
 Heading=sd(8,:)/conversion;  %=Heading for ACE-Asia on NCAR C-130
else
 Heading=sd(8,:)*0;  % Zero else
end

Temperature(3,:)=(ave(11,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
Temperature_sd(3,:)=sd(11,:)/0.0301;%See function Volt2Temp in Basic Software
Temperature(4,:)=(ave(12,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
Temperature(5,:)=(ave(13,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
Temperature_sd(5,:)=sd(13,:)/0.0301;%See function Volt2Temp in Basic Software

Temperature_sd(4,:)=sd(12,:)/0.0301;%See function Volt2Temp in Basic Software
if julian(day, month,year,12) >= julian(14,3,2001,0)& julian(day, month,year,12) < julian(15,5,2001,0)
    AmbientTempC = sd(12,:)/conversion; %ambient air temp in deg C from NCAR C-130 serial data feed
else
    AmbientTempC = sd(12,:)*0;
end

Temperature(6,:)=(ave(14,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
%After 31.5.97 this position has been filled with raw pressure of the Honeywell mounted in AATS-6 gold box in bits
if julian(day, month,year,12) > julian(31,5,1997,12)
 Pressure_Honeywell=ave(14,:)*15*1013.25*.068046/5;  %Honeywell press transducer
else
 Pressure_Honeywell=ave(14,:)*0;
end

if julian(day, month,year,12) >= julian(14,3,2001,0)& julian(day, month,year,12) < julian(15,5,2001,0)
 Pressure=sd(11,:)/conversion;  %static pressure from NCAR C-130 data feed during ACE-Asia   
elseif julian(day, month,year,12) > julian(31,5,1997,12)
 Pressure = Pressure_Honeywell;
end   

Temperature_sd(6,:)=(sd(14,:)-8.22211)/0.0301;%See function Volt2Temp in Basic Software
%Starting July 3 2000 in PRIDE this position has GPS altitude in feet from Trimble. But this has been reversed after PRIDE
if julian(day, month,year,12) >= julian(3,7,2000,0)& julian(day, month,year,12) < julian(1,9,2000,0)
    GPS_Altkm=sd(14,:)/conversion*.3048e-03;  %GPSalt_feet in Pride starting 7/3/00
elseif julian(day, month,year,12) >= julian(14,3,2001,0)& julian(day, month,year,12) < julian(15,5,2001,0)
    GPS_Altkm=sd(14,:)/conversion;  %GPS altitude in km converted from NCAR C-130 data feed   
else
    GPS_Altkm=sd(14,:)*0;   
end

Az_err=ave(9,:);
Elev_err=ave(10,:);
Az_err_sd=sd(9,:);
Elev_err_sd=sd(10,:);
Az_pos=ave(16,:)*357/9.012;         %See function Bits2Degrees in Basic Software
Az_pos_sd=sd(16,:)*357/9.012;
if julian(day, month,year,12) >= julian(3,7,2000,0)& julian(day, month,year,12) < julian(1,9,2000,0)
    Elev_pos=(ave(15,:)-7.01)*-90/3.91; %See function Bits2Degrees in Basic Software
    Elev_pos_sd = sd(15,:)*-90/3.91;
elseif julian(day, month,year,12) >= julian(14,3,2001,0)
    Elev_pos = (ave(15,:) - Volt_offset_in) * EldegperV_in;  %updated 2/22/01 B
    Elev_pos_sd = sd(15,:) * -EldegperV_in;  %updated 2/22/01 B;
else  %same as time period 7/3/2000-9/1/2000
    Elev_pos=(ave(15,:)-7.01)*-90/3.91; %See function Bits2Degrees in Basic Software
    Elev_pos_sd = sd(15,:)*-90/3.91;
end

%Pressure Altitude according to J. Livingston
%Pressure > 226.32 & Pressure<1100   

%p0=1013.25; % Standard Atmosphere
%T0=288.15

p0=1018;  %ACE-Asia April 23, 2001
T0=294;

%p0=1016;  %ACE-Asia April 17, 2001
%T0=293;

%p0=1018;  %ACE-Asia April 12/13, 2001
%T0=288;

%p0=1021.5;  %ACE-Asia April 5/6, 2001
%T0=291; 

%p0=1022;  %ACE-Asia April 3/4, 2001
%T0=284; 

Press_Alt = T0/6.5*(1-(Pressure/p0).^(1/5.255876114));
ii= find(Pressure >100 & Pressure <= 226.32);
Press_Alt(ii) = 11 - 6.34162008 * log(Pressure(ii) / 226.32);

Paltkm=Press_Alt; %This will overwrite the Paltkm in the file.