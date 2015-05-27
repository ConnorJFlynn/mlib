function [day,month,year,UT_Laptop,UT_Can,airmass,Temperature,Latitude,Longitude,...
      Press_Alt,Pressure,Heading,Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
      ScanFreq,AvePeriod,RecInterval,site,path,filename]=Ames14_Laptop(name);

% Reads AATS-14 Data files generated on NEC Laptop by John Livingstons Software
% Created by Beat Schmid November 10, 1997
% November 17, 1997 allows correct conversion of hot detector T for measurements before 15.5.97

%Type raw_data178              '178 bytes  8/29/96
%  Nectimehms As String * 6
%  RPAtimehms As String * 6
%  airmass As Single
%  Temperature(1 To 3) As Single
%  Latitude As Single
%  Longitude As Single
%  Paltkm As Single
%  Heading As Single
%  Mean_volts(1 To 14) As Single
%  Sd_volts(1 To 14) As Single
%  Az_err As Single
%  Elev_err As Single
%  Az_pos As Single
%  Elev_pos As Single
%  ScanFreq As Integer
%  AvePeriod As Integer
%  RecInterval As Integer
%End Type

%opens data file
[filename,path]=uigetfile(name,'Choose a File', 0, 0);
fid=fopen([path filename]);

% determines site from path
backslash_pos=findstr(path,'\');
[value,pos]=max(backslash_pos);
site=path([backslash_pos(pos-1)+1:backslash_pos(pos)-1])

%determine date from filename
months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
day=str2num(filename(2:3))
month=ceil(findstr(months,lower(filename(4:6)))/3)
year=str2num(filename(7:8))+1900

%opens skip file
skipfile=[filename '.skp'];
fid2=fopen([path skipfile]);
if fid2~=-1 
   skip=fscanf(fid2,'%i',[1,inf]);
   fclose(fid2)
   start_rec=skip(1)
   last_rec=skip(2)
   if last_rec==0
      last_rec=inf
   end   
   skip=skip(3:end);
else
   start_rec=1
   last_rec=inf
   skip=[]
end
nrec=last_rec-start_rec+1;

Time=fread(fid,[12 nrec],'12*uchar',178-12);
status=fseek(fid,(start_rec-1)*178+12,'bof');
SciData=fread(fid,[40 nrec],'40*float32',6+12);
status=fseek(fid,(start_rec-1)*178+12+160,'bof');
IngData=fread(fid,[3 nrec],'3*int16',12+160);
fclose(fid);

IngData(:,skip)=[];
SciData(:,skip)=[];
Time(:,skip)=[];

hour=str2num(char(Time([1:2],:))')';
minute=str2num(char(Time([3:4],:))')';
second=str2num(char(Time([5:6],:))')';
UT_Laptop=hour+minute/60+second/3600;

hour=str2num(char(Time([7:8],:))')';
minute=str2num(char(Time([9:10],:))')';
second=str2num(char(Time([11:12],:))')';
UT_Can=hour+minute/60+second/3600;

airmass=SciData(1,:);
if julian(day,month,year,0) > julian(15,5,1997,0)
  Temperature(1,:)=SciData(2,:)*1.95169-326.114; % Conversion after May 1997
else
  Temperature(1,:)=SciData(2,:)*1.953  -333.782; % Conversion before May 1997
end
Temperature(2,:)=(2.5-(SciData(3,:)-37.65)/19.178)/0.05;
Temperature(3,:)=(2.5-(SciData(4,:)-37.65)/19.178)/0.05;
Latitude=SciData(5,:);
Longitude=SciData(6,:);
Press_Alt=SciData(7,:);
Heading=SciData(8,:);
Mean_volts=SciData([9:22],:);
Sd_volts=SciData([23:36],:);
Az_err=SciData(37,:);
Elev_err=SciData(38,:);
Az_pos=SciData(39,:);
Elev_pos=SciData(40,:);

ScanFreq   = IngData(1,:);
AvePeriod  = IngData(2,:);
RecInterval= IngData(3,:);

%Pressure according to J. Livingston as long as Press_Alt <=11km
Pressure=1013.25*(1-(6.5*Press_Alt/288.15)).^5.255876114;