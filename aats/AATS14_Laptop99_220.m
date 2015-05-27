function [day,month,year,Temperature,Latitude,Longitude,Press_Alt,Pressure,Heading,Mean_volts,Sd_volts,...
      Az_err,Elev_err,Az_pos,Elev_pos,Voltref]=Ames14_Laptop99_220(pathname,filename);

%opens data file
[filename,pathname]=uigetfile(pathname,'Choose a File', 0, 0);
fid=fopen(deblank([pathname filename]));

%determine date from filename
months=['jan' 'feb' 'mar' 'apr' 'may' 'jun' 'jul' 'aug' 'sep' 'oct' 'nov' 'dec'];
day=str2num(filename(2:3));
month=ceil(findstr(months,lower(filename(4:6)))/3);
year=str2num(filename(7:8))+1900;
disp(sprintf('day=%d month=%d year=%d', day,month,year))

  start_rec=1
   last_rec=inf
   nrec=last_rec-start_rec+1;


%    Type data_save
%'total 220 bytes  6/99
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
%End Type

IngData=fread(fid,[11 nrec],'11*float32',176);
status=fseek(fid,(start_rec-1)*220+44,'bof');
Time=fread(fid,[3 nrec],'3*uchar',217);
status=fseek(fid,(start_rec-1)*220+47,'bof');
SciData=fread(fid,[43 nrec],'43*float32',48);
status=fseek(fid,(start_rec-1)*220+219,'bof');
window_heater_status=fread(fid,[1 nrec],'1*uchar',219);
fclose(fid);


%hour=str2num(char(Time([1:2],:))')';
%minute=str2num(char(Time([3:4],:))')';
%second=str2num(char(Time([5:6],:))')';
%UT_Laptop=hour+minute/60+second/3600;

%hour=str2num(char(Time([7:8],:))')';
%minute=str2num(char(Time([9:10],:))')';
%second=str2num(char(Time([11:12],:))')';
%UT_Can=hour+minute/60+second/3600;

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

%ScanFreq   = IngData(1,:);
%AvePeriod  = IngData(2,:);
%RecInterval= IngData(3,:);

%Pressure Altitude according to J. Livingston
%Pressure > 226.32 & Pressure<1100   
Press_Alt = 288.15/6.5*(1-(Pressure/1013.25).^(1/5.255876114));
ii= find(Pressure >100 & Pressure <= 226.32);
Press_Alt(ii) = 11 - 6.34162008 * log(Pressure(ii) / 226.32);

