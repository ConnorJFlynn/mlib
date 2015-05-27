% Reads AATS-14 Laptop data after DOY 239 in 1999 (that is during Dryden DC-8 testflights)
% changed 5/9/2000 to fix date rollover
% changed 6/30/2000 to remove records with bad Laptop time
% changed 8/31/2000 fix to remove records with bad Laptop time improved
% changed 9/3/2000 removes records with bad or no nav data

function [day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,Heading,...
      Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,flight_no]=AATS14_Laptop99_239(pathname);

Skipping='ON';

%opens data file
if exist('pathname','var')
   if exist(pathname,'dir')
      [pathname]=getfullname_(pathname,'aats','Choose a File');
   elseif ~exist(pathname, 'file')
      [pathname]=getfullname_('R*.*','aats','Choose a File');
   end
else
   [pathname]=getfullname_('R*.*','aats','Choose a File');
end
[pathname, filename, ext] = fileparts(pathname);
pathname = [pathname filesep];
filename = [filename, ext];

% [filename,pathname]=uigetfile(pathname,'Choose a File');
% CJF: added filesep to pathname
fid=fopen(deblank([pathname filesep filename]));


% determines site from path
backslash_pos=findstr(pathname,'\');
[value,pos]=max(backslash_pos);
site=pathname([backslash_pos(pos-1)+1:backslash_pos(pos)-1]);

%determine date and flight number from filename
pos=findstr(filename,'R');
pos=pos(1);
if pos~=1
 flight_no=filename(1:pos-2);  
else
 flight_no='NaN';    
end

day=str2num(filename(pos+1:pos+2));
months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
month=ceil(findstr(months,lower(filename(pos+3:pos+5)))/3);
year=str2num(filename(pos+6:pos+7));
if year <80             %Fixes Y2K Bug
   year=year+2000;
else
   year=year+1900;
end

disp(sprintf('day=%d month=%d year=%d', day,month,year));

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
%   cold_det2 As Single
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
%    cool_in As Single
%    cool_out As Single
%    data_CPU As Single
%    trk_CPU As Single
%    pwr_supply As Single
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
ii=find(diff(UT_Laptop)<0);
UT_Laptop(ii+1:end)=UT_Laptop(ii+1:end)+24;

hour=str2num(char(Time([7:8],:))')';
minute=str2num(char(Time([9:10],:))')';
second=str2num(char(Time([11:12],:))')';
UT_Can=hour+minute/60+second/3600;

%check and fix day rollover
ii=find(diff(UT_Can)<0);
UT_Can(ii+1:end)=UT_Can(ii+1:end)+24;

%check if nav data present and remove records
%Latitude=IngData(8,:);
%Longitude=IngData(9,:);
%ii=find(Latitude>90 | (Latitude==0 & Longitude==0));
%UT_Can(ii)=[];
%UT_Laptop(ii)=[];
%Airmass(:,ii)=[];
%Acqparam(:,ii)=[];
%IngData(:,ii)=[];
%SciData(:,ii)=[];
%window_heater_status(:,ii)=[];

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

%Pressure Altitude according to J. Livingston
%Pressure > 226.32 & Pressure<1100   
 p0=1013.25; % Standard Atmosphere
 T0=288.15;


if (day==14 & month==8 & year==2000)
    p0=1027;  %SAFARI Aug 14, 2000
    T0=298;   %SAFARI Aug 14, 2000
end
if strcmp(flight_no,'1812')
    p0=1027;  %SAFARI Aug 14, 2000
    T0=300;   %SAFARI Aug 14, 2000
end
if strcmp(flight_no,'1814')
    p0=1030;  %SAFARI Aug 15, 2000
    T0=298;   %SAFARI Aug 15, 2000
end
if (day==17 & month==8 & year==2000)
    p0=1020;  %SAFARI Aug 17, 2000
    T0=302;   %SAFARI Aug 17, 2000
end
if (day==18 & month==8 & year==2000)
    p0=1020;  %SAFARI Aug 18, 2000
    T0=302;   %SAFARI Aug 18, 2000
end
if strcmp(flight_no,'1818')
    p0=1022;  %SAFARI Aug 20, 2000
    T0=300;   %SAFARI Aug 20, 2000
end
if (day==20 & month==8 & year==2000)
    p0=1022;  %SAFARI Aug 20, 2000
    T0=300;   %SAFARI Aug 20, 2000
end
if (day==22 & month==8 & year==2000)
    p0=1018;  %SAFARI Aug 22, 2000
    T0=302;   %SAFARI Aug 22, 2000
end
if (day==23 & month==8 & year==2000)
    p0=1020;  %SAFARI Aug 23, 2000
    T0=302;   %SAFARI Aug 23, 2000
end
if (day==24 & month==8 & year==2000)
    p0=1025;  %SAFARI Aug 24, 2000
    T0=299;   %SAFARI Aug 24, 2000
end
if strcmp(flight_no,'1823')
    p0=1017;  %SAFARI Aug 29, 2000
    T0=304;   %SAFARI Aug 29, 2000
end
if strcmp(flight_no,'1824')
    p0=1017;  %SAFARI Aug 29, 2000
    T0=304;   %SAFARI Aug 29, 2000
end
if (day==31 & month==8 & year==2000)
    p0=1013;  %SAFARI Aug 31, 2000
    T0=303;   %SAFARI Aug 31, 2000
end
if (day==1 & month==9 & year==2000)
    p0=1015;  %SAFARI Sep 1, 2000
    T0=305;   %SAFARI Sep 1, 2000
end
if (day==2 & month==9 & year==2000)
    p0=1013;  %SAFARI Sep 2, 2000
    T0=306;   %SAFARI Sep 2, 2000
end
if (day==3 & month==9 & year==2000)
    p0=1010;  %SAFARI Sep 3, 2000
    T0=306;   %SAFARI Sep 3, 2000
end
if (day==5 & month==9 & year==2000)
    p0=1009;  %SAFARI Sep 5, 2000
    T0=308;   %SAFARI Sep 5, 2000
end
if (day==6 & month==9 & year==2000)
    p0=1010;  %SAFARI Sep 6, 2000
    T0=308;   %SAFARI Sep 6, 2000
end
if (day==7 & month==9 & year==2000)
    p0=1014;  %SAFARI Sep 7, 2000
    T0=301;   %SAFARI Sep 7, 2000
end
if (day==11 & month==9 & year==2000)
    p0=1015;  %SAFARI Sep 11, 2000
    T0=307;   %SAFARI Sep 11, 2000
end
if (day==13 & month==9 & year==2000)
    p0=1017;  %SAFARI Sep 13, 2000
    T0=302;   %SAFARI Sep 13, 2000
end
if (day==14 & month==9 & year==2000)
    p0=1025;  %SAFARI Sep 14, 2000
    T0=287;   %SAFARI Sep 14, 2000
end
if (day==16 & month==9 & year==2000)
    p0=1016;  %SAFARI Sep 16, 2000
    T0=302;   %SAFARI Sep 16, 2000
end

Press_Alt = T0/6.5*(1-(Pressure/p0).^(1/5.255876114));
ii= find(Pressure >100 & Pressure <= 226.32);
Press_Alt(ii) = 11 - 6.34162008 * log(Pressure(ii) / 226.32);