% AATS14_Laptop_DC8_SOLVE2.m
% Reads AATS-14 Laptop data from DC-8 after DOY 252 in 2002
%  same as AATS14_Laptop_Otter except that GPS alt is input in feet instead of m
% changed 5/9/2000 to fix date rollover
% changed 6/30/2000 to remove records with bad Laptop time
% changed 8/31/2000 fix to remove records with bad Laptop time improved
% changed 9/3/2000 removes records with bad or no nav data
% changed 5/2/2002 to handle filenames with flight number

function [day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,Heading,...
      Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
      pathname_in,filename_in,RH,H2O_Dens,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_DC8_SOLVE2(pathname_in,filename_in,iconf)

Skipping='ON'
Interpolate='OFF'

%opens data file
if iconf==1
[filename_in,pathname_in]=uigetfile(pathname_in,'Choose a File', 0, 0);
end
fid=fopen(deblank([pathname_in filename_in]));

% determines site from path
backslash_pos=findstr(pathname_in,'\'); %use this for PC...John
%backslash_pos=findstr(pathname_in,'/');  %use this for MAC...Meloe
[value,pos]=max(backslash_pos);
site=pathname_in([backslash_pos(pos-1)+1:backslash_pos(pos)-1])

%determine date and flight number from filename
pos=findstr(filename_in,'R');
%%%%pos=pos(2);
if pos~=1
 flight_no=filename_in(1:pos-2);  
else
 flight_no='NaN';    
end
day=str2num(filename_in(pos+1:pos+2));

months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
month=ceil(findstr(months,lower(filename_in(pos+3:pos+5)))/3);
year=str2num(filename_in(pos+6:pos+7));
if year <80             %Fixes Y2K Bug
   year=year+2000;
else
   year=year+1900;
end

disp(sprintf('day=%d month=%d year=%d', day,month,year))

%opens skip file
SkipFile=[filename_in '.skp'];
fid2=fopen([pathname_in SkipFile]);
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

%    Type data_save
%		'note changes by JML 6/6/99
%		'total 239 bytes after 6/6/99;  220 bytes before 6/6/99
%   laptop_hhmmss As String * 6     'added 6/6/99
%   AATS14_hhmmss As String * 6     'added 6/6/99
%   Airmass As Single               'added 6/6/99
%   scanfreq As Integer              'added 6/6/99
%   aveperiod As Integer             'added 6/6/99
%   recinterval As Integer           'added 6/6/99
%   hot_det_plate1 As Single        'hot detector plate #1
%   hot_det_plate2 As Single        'hot detector plate #2
%   filter_plate1 As Single         'filter plate #1
%   elex_can As Single
%   cold_det1 As Single             'cold detector #1
%   cold_det2 As Single             'cold detector #2
%   argus As Single
%   Latitude As Single
%   Longitude As Single
%   Pressmb As Single               'pressure from Pelican
%   Heading As Single
%   'hr As String * 1               'removed 6/6/99
%   'min As String * 1              'removed 6/6/99
%   'sec As String * 1              'removed 6/6/99
%    mean_chan_volts(1 To 14) As Single
%    Sd_chan_volts(1 To 14) As Single
%    Az_err As Single
%    Elev_err As Single
%    Az_pos As Single
%    Elev_pos As Single
%    hot_PCA As Single
%    cold_PCA As Single
%    filter_plate2 As Single
%    cool_in As Single              'static Temp. on Otter
%    cool_out As Single             'GPS altitude on Otter
%    data_CPU As Single
%    trk_CPU As Single
%    pwr_supply As Single            'RH on Otter
%    adc_vref As Single
%    det1_adc_vref As Single
%    det2_adc_vref As Single
%    window_heater_status As String * 1
%End Type

Time=fread(fid,[12 nrec],'12*uchar',239-12);
status=fseek(fid,(start_rec-1)*239+12,'bof');
Airmass=fread(fid,[1 nrec],'1*float32',239-4);
status=fseek(fid,(start_rec-1)*239+16,'bof');
Acqparam=fread(fid,[3 nrec],'3*int16',239-6);
status=fseek(fid,(start_rec-1)*239+22,'bof');
IngData=fread(fid,[11 nrec],'11*float32',239-44);
status=fseek(fid,(start_rec-1)*239+66,'bof');
SciData=fread(fid,[43 nrec],'43*float32',239-172);
status=fseek(fid,(start_rec-1)*220+238,'bof');
window_heater_status=fread(fid,[1 nrec],'1*uchar',238);
fclose(fid);

%remove skipped records
Time(:,skip)=[];
Airmass(:,skip)=[];
Acqparam(:,skip)=[];
IngData(:,skip)=[];
SciData(:,skip)=[];
window_heater_status(:,skip)=[];

%remove records with bad time
[i j]=find(Time<48 | Time>57); %only ascii 48 thru 57 produce numbers 0 thru 9
Time(: ,j)=[];
Airmass(: ,j)=[];
Acqparam(: ,j)=[];
IngData(: ,j)=[];
SciData(: ,j)=[];
window_heater_status(: ,j)=[];

hour=str2num(char(Time([1:2],:))')';
minute=str2num(char(Time([3:4],:))')';
second=str2num(char(Time([5:6],:))')';
UT_Laptop=hour+minute/60+second/3600;

%check and fix day rollover
ii=find(diff(UT_Laptop)<-1);
UT_Laptop(ii+1:end)=UT_Laptop(ii+1:end)+24;

hour=str2num(char(Time([7:8],:))')';
minute=str2num(char(Time([9:10],:))')';
second=str2num(char(Time([11:12],:))')';
UT_Can=hour+minute/60+second/3600;

%check and fix day rollover
ii=find(diff(UT_Can)<-1);
UT_Can(ii+1:end)=UT_Can(ii+1:end)+24;

%read out variables
Temperature=IngData([1:7],:);
Latitude=IngData(8,:);
Longitude=IngData(9,:);
Pressure=IngData(10,:);
Heading=IngData(11,:);
Mean_volts=SciData([1:14],:);
Sd_volts=SciData([15:28],:);
Az_err=SciData(29,:);
Elev_err=SciData(30,:);
Az_pos=SciData(31,:);
Elev_pos=SciData(32,:);
Temperature(8:15,:)=SciData([33:40],:);
Voltref=SciData([41:43],:);
ScanFreq   = Acqparam(1,:);
AvePeriod  = Acqparam(2,:);
RecInterval= Acqparam(3,:);
RH=Temperature(15,:);
%GPS_Alt=Temperature(12,:)/1000; %[m to km]
GPS_Alt=Temperature(12,:)/(3.2808*1000); %[feet to km]
T_stat=Temperature(11,:);


%interpolate drop outs
if strcmp(Interpolate,'ON')
 i=find(Latitude>20) ;
 Latitude=interp1(UT_Laptop(i),Latitude(i),UT_Laptop,'nearest');
 disp(sprintf('%i Latitudes have been interpolated to their nearest neighbor',size(Latitude,2)-size(i,2)))
 
 i=find(Longitude>100);
 Longitude=interp1(UT_Laptop(i),Longitude(i),UT_Laptop,'nearest');
 disp(sprintf('%i Longitudes have been interpolated to their nearest neighbor',size(Latitude,2)-size(i,2)))
 
 i=find(Heading~=0);
 if ~isempty(i)
  Heading=interp1(UT_Laptop(i),Heading(i),UT_Laptop,'nearest');
  disp(sprintf('%i Heading readings have been interpolated to their nearest neighbor',size(Heading,2)-size(i,2)))
 else
  disp(sprintf('All Headings are 0'))
 end
    
 i=find(Pressure~=0);
 Pressure=interp1(UT_Laptop(i),Pressure(i),UT_Laptop,'nearest');
 disp(sprintf('%i Pressure readings have been interpolated to their nearest neighbor',size(Pressure,2)-size(i,2)))
 
 i=find(GPS_Alt~=0);
 GPS_Alt=interp1(UT_Laptop(i),GPS_Alt(i),UT_Laptop,'nearest');
 disp(sprintf('%i GPS_Alt readings have been interpolated to their nearest neighbor',size(GPS_Alt,2)-size(i,2)))

 i=find(T_stat~=0);
 T_stat=interp1(UT_Laptop(i),T_stat(i),UT_Laptop,'nearest');
 disp(sprintf('%i T_stat readings have been interpolated to their nearest neighbor',size(T_stat,2)-size(i,2)))
end

%Pressure Altitude according to J. Livingston
%Pressure > 226.32 & Pressure<1100   

p0=1013.25; % Standard Atmosphere
T0=288.15

if (day==30 & month==3 & year==2001)
 p0=1016;  %ACE-Asia March 30, 2001 CIR00
 T0=282;
end
if (day==31 & month==3 & year==2001)
 p0=1020;  %ACE-Asia March 31, 2001 CIR01
 T0=278;
end
if (day==1 & month==4 & year==2001)
 p0=1018;  %ACE-Asia April 1/2, 2001 CIR02
 T0=290;
end
if (day==3 & month==4 & year==2001)
 p0=1022;  %ACE-Asia April 3/4, 2001 CIR03
 T0=284; 
end
if (day==5 & month==4 & year==2001)
 p0=1021.5;  %ACE-Asia April 5/6, 2001 CIR04
 T0=291; 
end
if (day==8 & month==4 & year==2001)
 p0=1017;   %ACE-Asia April 8,    2001 CIR05
 T0=292.5;
end
if (day==9 & month==4 & year==2001)
 p0=1017;  %ACE-Asia April 9, 2001 CIR06
 T0=292.5;
end
if (day==11 & month==4 & year==2001)
 p0=1009;  %ACE-Asia April 11/12, 2001 CIR07
 T0=284;
end
if (day==12 & month==4 & year==2001)
 p0=1018;  %ACE-Asia April 12/13, 2001 CIR08
 T0=288;
end
if (day==14 & month==4 & year==2001)
 p0=1018;  %ACE-Asia April 14, 2001 CIR09
 T0=288;
end
if (day==15 & month==4 & year==2001)
 p0=1021;  %ACE-Asia April 15/16, 2001 CIR10
 T0=291;
end
if (day==17 & month==4 & year==2001)
 p0=1016;  %ACE-Asia April 17, 2001 CIR11
 T0=293;
end
if (day==18 & month==4 & year==2001)
 p0=1009;  %ACE-Asia April 18/19, 2001 CIR12
 T0=295;
end
if (day==19 & month==4 & year==2001)
 p0=1013;  %ACE-Asia April 19/20, 2001 CIR13
 T0=295;
end
if (day==22 & month==4 & year==2001)
 p0=1019;  %ACE-Asia April 22/23, 2001 CIR14
 T0=293;
end
if (day==25 & month==4 & year==2001)
 p0=1019;  %ACE-Asia April 25/26, 2001 CIR16
 T0=290;
end
if (day==26 & month==4 & year==2001)
 p0=1021;  %ACE-Asia April 26/27, 2001 CIR17
 T0=290;
end
if (day==28 & month==4 & year==2001)
 p0=1021;  %ACE-Asia April 28,    2001 CIR18
 T0=292;
end

Press_Alt = T0/6.5*(1-(Pressure/p0).^(1/5.255876114));
ii= find(Pressure >100 & Pressure <= 226.32);
Press_Alt(ii) = 11 - 6.34162008 * log(Pressure(ii) / 226.32);

%This computes water vapor density according to Boegel, 1977, p.108
b=(8.082-T_stat/556).*T_stat./(256.1+T_stat);
a=13.233*(1+1e-8.*Pressure.*(570-T_stat))./(T_stat+273.15);
H2O_Dens=RH.*a.*10.^b;
