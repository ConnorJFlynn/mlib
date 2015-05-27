% Reads AATS-14 Laptop data aboard the CIRPAS Twin Otter for COAST October 2011

function [day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,Heading,...
      Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,...
      RH,H2O_Dens,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter_COAST2011(pathname,filename);

global deltaT Tstat_new RH_new

Skipping='OFF'
Interpolate='OFF';%'ON'
correct_Tstat_SSFR='OFF'; %set 'ON' for ICARTT
flag_read_substitute_TwinOtterCabinfiledata='yes';
flag_correct_UTCantime='yes';

%opens data file
[filename,pathname]=uigetfile(pathname,'Choose a File', 0, 0);
fid=fopen(deblank([pathname filename]));

% determines site from path
backslash_pos=findstr(pathname,'\');
[value,pos]=max(backslash_pos);
site=pathname([backslash_pos(pos-1)+1:backslash_pos(pos)-1])

%determine date and flight number from filename
pos=findstr(filename,'R');
if length(pos)>1  pos=pos(2); end
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

%following added for COAST
%correct UT_Can time for COAST
if strcmp(flag_correct_UTCantime,'yes')
    if (julian(day, month,year,12) == julian(28,10,2011,12))
        UT_Can=UT_Can-1-3/3600;  %accounts for one-hour, 3 sec offset for 10/28
        %through trial and error, I determined that for 10/28 the UT_Can is 1 hour, 3 sec ahead of true UTC on Haf's file
    elseif (julian(day, month,year,12) == julian(26,10,2011,12))
        %use AATS Can time...assume that it remains on correct UTC
        %UT_Can=UT_Laptop; %Laptop time   don't do this
    elseif (julian(day, month,year,12) == julian(27,10,2011,12))
        UT_Can=UT_Can + 7; %serial time was set to local time
    end
end

%check and fix day rollover
ii=find(diff(UT_Can)<-1);

%following added by JML 2/8/06
if hour(ii)==23  %careful...time will not get adjusted unless hour(ii)==23
    UT_Can(ii+1:end)=UT_Can(ii+1:end)+24;
end

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
GPS_Alt=Temperature(12,:)/1000; %[m to km]
T_stat=Temperature(11,:);

%interpolate within CAN values received via serial feed to handle drop outs
%skip for COAST
if strcmp(Interpolate,'ON')
    i=find(Latitude>0) ;
    Latitude=interp1(UT_Laptop(i),Latitude(i),UT_Laptop,'nearest');
    disp(sprintf('%i Latitudes have been interpolated to their nearest neighbor',size(Latitude,2)-size(i,2)))
    
    i=find(Longitude<=0);  %use for ACE-Asia
    %i=find(Longitude<-60);  %use for SOLVE2
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
    
    i=find(T_stat~=0 & T_stat<80);
    T_stat=interp1(UT_Laptop(i),T_stat(i),UT_Laptop,'nearest');
    disp(sprintf('%i T_stat readings have been interpolated to their nearest neighbor',size(T_stat,2)-size(i,2)))
    
    %i=find(RH<99.99);
    %RH=interp1(UT_Laptop(i),RH(i),UT_Laptop,'nearest');
    %disp(sprintf('%i RH readings have been interpolated to their nearest neighbor',size(RH,2)-size(i,2)))
end

%following added for COAST
%read Twin Otter Cabin data file provided by Haf Jonsson and substitute those values via interpolation
if strcmp(flag_read_substitute_TwinOtterCabinfiledata,'yes')
    if (julian(day, month,year,12) == julian(26,10,2011,12))
        filename_TwinOtter_cabin='CABIN_10hz_11102601_noheader.txt';
    elseif (julian(day, month,year,12) == julian(27,10,2011,12))
        filename_TwinOtter_cabin='CABIN_10hz_11102704_noheader.txt';
    elseif (julian(day, month,year,12) == julian(28,10,2011,12))
        filename_TwinOtter_cabin='CABIN_10hz_11102801_noheader.txt';
    end
    
    read_TwinOtter_cabindatafile_V02;
     %UT_hr_Otter,Lat_deg_Otter,Lon_deg_Otter,Alt_m_Otter,Roll_deg_Otter,Pitch_deg_Otter,Heading_deg_Otter,
     %Tamb_C_Otter,TdC_Otter,RHamb_pct_Otter,Pstat_mb_Otter,Palt_m_Otter,Alt_radar_m_Otter,TAS_mps_Otter,SpecHum_gkg_Otter
    
     %must handle each day separately
     if (julian(day, month,year,12) == julian(26,10,2011,12))
         %use AATS Can time...assume that it remains on correct UTC
         %Note that Haf's file times totally encompass the AATS Can times
         %interpolate
         Lat_interp=interp1(UT_hr_Otter,Lat_deg_Otter,UT_Can);
         Lon_interp=interp1(UT_hr_Otter,Lon_deg_Otter,UT_Can);
         GPS_alt_m_interp=interp1(UT_hr_Otter,Alt_m_Otter,UT_Can); %will need to convert to km
         Pmb_interp=interp1(UT_hr_Otter,Pstat_mb_Otter,UT_Can);
         RHpct_interp=interp1(UT_hr_Otter,RHamb_pct_Otter,UT_Can);
         Palt_m_interp=interp1(UT_hr_Otter,Palt_m_Otter,UT_Can);
         Tstat_C_interp=interp1(UT_hr_Otter,Tamb_C_Otter,UT_Can);
         SpecHum_gkg_interp=interp1(UT_hr_Otter,SpecHum_gkg_Otter,UT_Can);
         
         %now overplot to check
         figure(501)
         subplot(5,1,1)
         plot(UT_hr_Otter,Lat_deg_Otter,'r.')
         hold on
         plot(UT_Can,Lat_interp,'bx')
         plot(UT_Can,Latitude,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Latitude (deg)','fontsize',14)
         %title(strfilename,'fontsize',14)
         subplot(5,1,2)
         plot(UT_hr_Otter,Lon_deg_Otter,'r.')
         hold on
         plot(UT_Can,Lon_interp,'bx')
         plot(UT_Can,Longitude,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Longitude (deg)','fontsize',14)
         subplot(5,1,3)
         plot(UT_hr_Otter,Alt_m_Otter,'r.')
         hold on
         plot(UT_Can,GPS_alt_m_interp,'bx')
         plot(UT_Can,GPS_Alt*1000,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'ylim',[0 2000])
         set(gca,'fontsize',14)
         ylabel('Altitude (m)','fontsize',14)
         subplot(5,1,4)
         plot(UT_hr_Otter,Pstat_mb_Otter,'r.-')
         hold on
         plot(UT_Can,Pmb_interp,'bx')
         plot(UT_Can,Pressure,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Pressure (mb)','fontsize',14)
         set(hleg2,'fontsize',12)
         xlabel('UT (hr)','fontsize',14)
         subplot(5,1,5)
         plot(UT_hr_Otter,Tamb_C_Otter,'r.-')
         hold on
         plot(UT_Can,Tstat_C_interp,'bx')
         plot(UT_Can,T_stat,'go')

        %substitute Haf's values
         Latitude=Lat_interp;
         Longitude=Lon_interp;
         GPS_Alt=GPS_alt_m_interp/1000; %convert to km
         Pressure=Pmb_interp;
         T_stat=Tstat_C_interp;
         RH=RHpct_interp;
         Press_Alt=Palt_m_interp/1000;
         
     elseif (julian(day, month,year,12) == julian(27,10,2011,12))
         %use AATS Can time...assume that it remains on correct UTC
         %Note that Haf's file times totally encompass the AATS Can times
         %interpolate
         Lat_interp=interp1(UT_hr_Otter,Lat_deg_Otter,UT_Can);
         Lon_interp=interp1(UT_hr_Otter,Lon_deg_Otter,UT_Can);
         GPS_alt_m_interp=interp1(UT_hr_Otter,Alt_m_Otter,UT_Can); %will need to convert to km
         Pmb_interp=interp1(UT_hr_Otter,Pstat_mb_Otter,UT_Can);
         RHpct_interp=interp1(UT_hr_Otter,RHamb_pct_Otter,UT_Can);
         Palt_m_interp=interp1(UT_hr_Otter,Palt_m_Otter,UT_Can);
         Tstat_C_interp=interp1(UT_hr_Otter,Tamb_C_Otter,UT_Can);
         SpecHum_gkg_interp=interp1(UT_hr_Otter,SpecHum_gkg_Otter,UT_Can);
         
         itim_pre=find(UT_Can<UT_hr_Otter(1));
         Tstat_C_interp(itim_pre)=T_stat(itim_pre);
         RHpct_interp(itim_pre)=RH(itim_pre);
         ifirst=itim_pre(end)+1;
         delta_GPS_m_first=GPS_alt_m_interp(ifirst)-GPS_Alt(ifirst)*1000; %correction for GPS alt
         GPS_alt_m_interp(itim_pre)=GPS_Alt(itim_pre)*1000 + delta_GPS_m_first;
         idxgood=find(Pmb_interp>900,1,'first');
         delta_pmb_firstgood=Pmb_interp(idxgood)-Pressure(idxgood);
         Pmb_interp(itim_pre)=Pressure(itim_pre)+delta_pmb_firstgood;
         itim_bad=find(Pmb_interp<700);
         if ~isempty(itim_bad)
             Pmb_interp(itim_bad)=Pressure(itim_bad)+delta_pmb_firstgood;
         end
         
         ifinal=find(UT_Can>21.509);
         delta_pmb_final=Pmb_interp(ifinal(1)-1)-Pressure(ifinal(1)-1);
         Pmb_interp(ifinal)=Pressure(ifinal)+delta_pmb_final;
         
         %now overplot to check
         figure(501)
         subplot(5,1,1)
         plot(UT_hr_Otter,Lat_deg_Otter,'r.')
         hold on
         plot(UT_Can,Lat_interp,'bx')
         plot(UT_Can,Latitude,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Latitude (deg)','fontsize',14)
         %title(strfilename,'fontsize',14)
         subplot(5,1,2)
         plot(UT_hr_Otter,Lon_deg_Otter,'r.')
         hold on
         plot(UT_Can,Lon_interp,'bx')
         plot(UT_Can,Longitude,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Longitude (deg)','fontsize',14)
         subplot(5,1,3)
         plot(UT_hr_Otter,Alt_m_Otter,'r.')
         hold on
         plot(UT_Can,GPS_alt_m_interp,'bx')
         plot(UT_Can,GPS_Alt*1000,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'ylim',[0 2000])
         set(gca,'fontsize',14)
         ylabel('Altitude (m)','fontsize',14)
         subplot(5,1,4)
         plot(UT_hr_Otter,Pstat_mb_Otter,'r.-')
         hold on
         plot(UT_Can,Pmb_interp,'bx')
         plot(UT_Can,Pressure,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Pressure (mb)','fontsize',14)
         set(hleg2,'fontsize',12)
         xlabel('UT (hr)','fontsize',14)
         subplot(5,1,5)
         plot(UT_hr_Otter,Tamb_C_Otter,'r.-')
         hold on
         plot(UT_Can,Tstat_C_interp,'bx')
         plot(UT_Can,T_stat,'go')
 
        %substitute Haf's values
         Latitude=Lat_interp;
         Longitude=Lon_interp;
         GPS_Alt=GPS_alt_m_interp/1000; %convert to km
         Pressure=Pmb_interp;
         T_stat=Tstat_C_interp;
         RH=RHpct_interp;
         Press_Alt=Palt_m_interp/1000;
         
     elseif (julian(day, month,year,12) == julian(28,10,2011,12))
         %interpolate
         Lat_interp=interp1(UT_hr_Otter,Lat_deg_Otter,UT_Can);
         Lon_interp=interp1(UT_hr_Otter,Lon_deg_Otter,UT_Can);
         GPS_alt_m_interp=interp1(UT_hr_Otter,Alt_m_Otter,UT_Can); %will need to convert to km
         Pmb_interp=interp1(UT_hr_Otter,Pstat_mb_Otter,UT_Can,'linear');
         RHpct_interp=interp1(UT_hr_Otter,RHamb_pct_Otter,UT_Can);
         Palt_m_interp=interp1(UT_hr_Otter,Palt_m_Otter,UT_Can);
         Tstat_C_interp=interp1(UT_hr_Otter,Tamb_C_Otter,UT_Can);
         SpecHum_gkg_interp=interp1(UT_hr_Otter,SpecHum_gkg_Otter,UT_Can);
         
         itim_pre=find(UT_Can<UT_hr_Otter(1));
         Tstat_C_interp(itim_pre)=T_stat(itim_pre);
         RHpct_interp(itim_pre)=RH(itim_pre);
         ifirst=itim_pre(end)+1;
         delta_GPS_m_first=GPS_alt_m_interp(ifirst)-GPS_Alt(ifirst)*1000; %correction for GPS alt
         GPS_alt_m_interp(itim_pre)=GPS_Alt(itim_pre)*1000 + delta_GPS_m_first;
         idxgood=find(Pmb_interp>900,1,'first');
         delta_pmb_firstgood=Pmb_interp(idxgood)-Pressure(idxgood);
         Pmb_interp(itim_pre)=Pressure(itim_pre)+delta_pmb_firstgood;
         itim_bad=find(Pmb_interp<700);
         if ~isempty(itim_bad)
             Pmb_interp(itim_bad)=Pressure(itim_bad)+delta_pmb_firstgood;
         end
         
         %remove bad Palt_m_interp points
         p0=1013;
         T0=288;
         Press_Altkm_calc = T0/6.5*(1-(Pmb_interp/p0).^(1/5.255876114));
         ii= find(Pmb_interp>100 & Pmb_interp<= 226.32);
         Press_Altkm_calc(ii) = 11 - 6.34162008 * log(Pmb_interp(ii) / 226.32);
         
         jdxgood_Palt=find(UT_Can>17.632);
         deltam_Palt = mean(Palt_m_interp(jdxgood_Palt(1:4))-1000*Press_Altkm_calc(jdxgood_Palt(1:4)));
         jtim_pre=find(UT_Can<17.632);
         Palt_m_interp(jtim_pre)=1000*Press_Altkm_calc(jtim_pre)+deltam_Palt;
         
         UTsubs=[17.6845 17.685; 19.245 19.2455; 19.2724 19.2726; 19.276 19.2765; 19.5235 19.5242; 19.5582 19.5584; 20.521 20.5216; 21.521 21.5215];
         for ij=1:size(UTsubs,1),
             idxt=find(UT_Can>UTsubs(ij,1) & UT_Can<UTsubs(ij,2));
             Palt_m_interp(idxt)=interp1([UT_Can(idxt-1) UT_Can(idxt+1)],[Palt_m_interp(idxt-1) Palt_m_interp(idxt+1)],UT_Can(idxt));
         end
         
         %now overplot to check
         figure(501)
         subplot(5,1,1)
         plot(UT_hr_Otter,Lat_deg_Otter,'r.')
         hold on
         plot(UT_Can,Lat_interp,'bx')
         plot(UT_Can,Latitude,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Latitude (deg)','fontsize',14)
         %title(strfilename,'fontsize',14)
         subplot(5,1,2)
         plot(UT_hr_Otter,Lon_deg_Otter,'r.')
         hold on
         plot(UT_Can,Lon_interp,'bx')
         plot(UT_Can,Longitude,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Longitude (deg)','fontsize',14)
         subplot(5,1,3)
         plot(UT_hr_Otter,Alt_m_Otter,'r.')
         hold on
         plot(UT_Can,GPS_alt_m_interp,'bx')
         plot(UT_Can,GPS_Alt*1000,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'ylim',[0 2000])
         set(gca,'fontsize',14)
         ylabel('Altitude (m)','fontsize',14)
         subplot(5,1,4)
         plot(UT_hr_Otter,Pstat_mb_Otter,'r.-')
         hold on
         plot(UT_Can,Pmb_interp,'bx')
         plot(UT_Can,Pressure,'go')
         %set(gca,'xlim',UTlim)
         set(gca,'fontsize',14)
         ylabel('Pressure (mb)','fontsize',14)
         set(hleg2,'fontsize',12)
         xlabel('UT (hr)','fontsize',14)
         subplot(5,1,5)
         plot(UT_hr_Otter,Tamb_C_Otter,'r.-')
         hold on
         plot(UT_Can,Tstat_C_interp,'bx')
         plot(UT_Can,T_stat,'go')
         
         %substitute Haf's values
         GPS_Alt=GPS_alt_m_interp/1000; %convert to km
         Pressure=Pmb_interp;
         T_stat=Tstat_C_interp;
         RH=RHpct_interp;
         Press_Alt=Palt_m_interp/1000;
     end
end

%This computes water vapor density according to Boegel, 1977, p.108
b=(8.082-T_stat/556).*T_stat./(256.1+T_stat);
a=13.233*(1+1e-8.*Pressure.*(570-T_stat))./(T_stat+273.15);
H2O_Dens=RH.*a.*10.^b; %g/m^3

