function [day,month,year,UT_Can,Mean_volts,Sd_volts,Press_Alt,Pressure,Latitude,Longitude,...
      Heading,Temperature,Az_err,Az_pos,Elev_err,Elev_pos,Volt_ref,Status_window_heater,...
      site,pathname,filename]=Ames14_Raw99(pathname,filename);
    
% Reads ACE-2 OS-9000 computer data file that consists of 225-byte records (1999)
% June 6, 1997 created by Beat Schmid as Ames14_Raw.m
% August 29, 1997 determines site from path
% modified June 1, 1999 JML 
% modified 11/13/2000 Beat Schmid to get info from original filename

%Type new_array    '225-byte OS-9000 computer data file as of 5/99
%    Header As String * 2
%    Serial As String * 1
%    hot_det_plate1 As Single        'hot detector plate #1
%    hot_det_plate2 As Single        'hot detector plate #2
%    filter_plate1 As Single         'filter plate #1
%    elex_can As Single
%    cold_det1 As Single             'cold detector #1
%    cold_det2 As Single
%    argus As Single
%    Latitude As Single
%    Longitude As Single
%    Pressmb As Single               'pressure from Pelican
%    Heading As Single
%    hr As String * 1
%    min As String * 1
%    sec As String * 1
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
%    CRC As String * 2
%End Type
    
Interpolate='OFF'
Skipping='OFF'

%opens data file
[filename,pathname]=uigetfile(pathname,'Choose a File', 0, 0);
fid=fopen(deblank([pathname filename]));

% determines site from path
backslash_pos=findstr(pathname,'\');
[value,pos]=max(backslash_pos);
site=pathname([backslash_pos(pos-1)+1:backslash_pos(pos)-1]);
disp(site);

%determine date from filename
day=str2num(filename(7:8));
month=str2num(filename(5:6));
year=str2num(filename(3:4));

if year <80             %Fixes Y2K Bug
   year=year+2000;
else
   year=year+1900;
end

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

%find out how many complete 225 records there are.
[Dummy,count]=fread(fid,[1 inf],'1*uchar');
nrec=fix(count/225)
status=fseek(fid,0,'bof');

%start actual reading
Header=fread(fid,[3 inf],'3*uchar',222);
status=fseek(fid,(start_rec-1)*225+3,'bof');
[IngData,count1]=fread(fid,[11 nrec],'11*float',181);
status=fseek(fid,(start_rec-1)*225+47,'bof');
[Time,count2]=fread(fid,[3 nrec],'3*uchar',222);
status=fseek(fid,(start_rec-1)*225+50,'bof');
[SciData,count3]=fread(fid,[32 nrec],'32*float',97);
status=fseek(fid,(start_rec-1)*225+178,'bof');
[IngData2,count4]=fread(fid,[11 nrec],'11*float',181);
status=fseek(fid,(start_rec-1)*225+222,'bof');
[Status_window_heater,count5]=fread(fid,[1 nrec],'1*uchar',224);
fclose(fid);

IngData(:,skip)=[];
IngData2(:,skip)=[];
SciData(:,skip)=[];
Time(:,skip)=[];

Temperature1=IngData([1:7],:);
Latitude=IngData(8,:);
Longitude=IngData(9,:);
Pressure=IngData(10,:);
Heading=IngData(11,:);
UT_Can=Time(1,:)+Time(2,:)/60+Time(3,:)/3600;
Mean_volts=SciData([1:14],:);
Sd_volts=SciData([15:28],:);
Az_err=SciData(29,:);
Elev_err=SciData(30,:);
Az_pos=SciData(31,:);
Elev_pos=SciData(32,:);
Temperature2=IngData2([1:8],:);
Temperature=[Temperature1' Temperature2']';
Volt_ref(1:3,:)=IngData2(9:11,:);
% Instrument was mounted 'backwards'on Pelican and DC-8 ??
%Az_pos=mod((Az_pos+180),360);

%interpolate GPS Lat/Long drop outs
if strcmp(Interpolate,'ON')
 i=find((Latitude~=-99999) & (Longitude~=-99999));
 Latitude=interp1(UT(i),Latitude(i),UT);
 Longitude=interp1(UT(i),Longitude(i),UT);
 disp(sprintf('%i Lat/Long pairs have been linearly interpolated',size(Latitude,2)-size(i,2)))
end

%corrects for time delay in Can PC
%delay=-4;
%UT=UT+delay/3600;

%Pressure Altitude according to J. Livingston
%Pressure > 226.32 & Pressure<1100   
Press_Alt = 288.15/6.5*(1-(Pressure/1013.25).^(1/5.255876114));
ii= find(Pressure >100 & Pressure <= 226.32);
Press_Alt(ii) = 11 - 6.34162008 * log(Pressure(ii) / 226.32);

