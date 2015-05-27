%AATS14_plt_SOLVE2.m
%plots raw AATS-14 data for Dryden June 1999 or later deployment
% changed 5/9/2000 to fix date rollover
% changed 8/20/2000 to allow start and end time
clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%
iwrite_eilers_binary=0; % optionally writes a file that can be read by Jim Eilers
UT_start=21; 
UT_end=23;  

Map_plt='OFF';

%Delta_t_Laptop=0/3600; % (seconds)
disp(sprintf('%g-%g UT',UT_start,UT_end))

%instrument='AMES14#1'      % AATS-14 mainly ACE-2 and Dryden
%instrument='AMES14#1_2000' % AATS-14 MLO ,SAFARI-2000, MLO October 2000
%instrument='AMES14#1_2001'  % AATS-14 after December 8, 2000, for MLO February 2001, ACE-Asia, CLAMS
instrument='AMES14#1_2002'  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron 
%source='Laptop_Otter'
%source='Laptop99';
%source='Can'
source='Laptop_DC8_SOLVE2';
disp(source)

switch instrument
case 'AMES14#1'
    lambda_AATS14=[380.3   448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5	]
case 'AMES14#1_2000'
    lambda_AATS14=[ 380   448 453 499  525  605  675  354  779  864  940  1019 1240   1558]; %After March 28, 1999
    data_dir='c:\beat\data\SAFARI-2000\';
case 'AMES14#1_2001'
    lambda_AATS14=[ 380   448 1060 499  525  605  675  354  779  864  940  1019 1240   1558]; %After Dec 8, 2000
    data_dir='c:\beat\data\Ames\';
    %data_dir='c:\beat\data\ACE-Asia\';
    %data_dir='c:\beat\data\Mauna Loa\';
    %data_dir='c:\beat\data\Everett\';
case 'AMES14#1_2002'
    lambda_AATS14=[ 380   453 1240 499  520  605  675  354  779  864  940  1019 2138   1558]; %After Dec 8, 2000
    %data_dir='c:\beat\data\Ames\';
    data_dir='c:\johnmatlab\AATS14_data_2002\SOLVE2\';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%

switch source
case 'Can', 
    [day,month,year,UT_Can,Mean_volts,Sd_volts,Press_Alt,Pressure,Latitude,Longitude,...
            Heading,Temperature,Az_err,Az_pos,Elev_err,Elev_pos,Voltref,Status_window_heater,site,pathname,filename]=...
        AATS14_Raw99([data_dir 'e_*.*'],'none');
    UT=UT_Can;	%Set UT=AATS14 can computer time
    
    %Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);,
    UT=UT(L);,
    Mean_volts=Mean_volts(:,L);,
    Sd_volts=Sd_volts(:,L);,
    Pressure=Pressure(:,L);,
    Press_Alt=Press_Alt(L);,
    Latitude=Latitude(L);,
    Longitude=Longitude(L);,
    Temperature=Temperature(:,L);,
    Az_err=Az_err(L);,
    Az_pos=Az_pos(L);,
    Elev_err=Elev_err(L);,
    Elev_pos=Elev_pos(L);,
    Heading=Heading(L);,
    Voltref=Voltref(:,L);
    Altitude=Press_Alt;
    
case 'Laptop99',
    %for Dryden 1999 files before 6/6/99  
    %[day,month,year,Temperature,Latitude,Longitude,Press_Alt,Pressure,Heading,Mean_volts,Sd_volts,...
    %      Az_err,Elev_err,Az_pos,Elev_pos,Voltref]=AATS14_Laptop99_220('d:\beat\data\Dryden\*.*');
    
    %for files after 6/6/99
    [day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,...
            Heading,Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
            Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,flight_no]=AATS14_Laptop99_239([data_dir 'R???????.*']);
    
    if strcmp(site,'SAFARI-2000')
        if (day==14 & month==8 & year==2000)
            Delta_t_start_CV580=59/3600; %SAFARI Aug 14 , 2000 (seconds)
            Delta_t_end_CV580=62/3600;   %SAFARI Aug 14 , 2000 (seconds)
        end
        if strcmp(flight_no,'1812')
            Delta_t_start_CV580=62.5/3600;%SAFARI Aug 14 , 2000 (seconds)
            Delta_t_end_CV580=66/3600;   %SAFARI Aug 14 , 2000 (seconds)
        end
        if strcmp(flight_no,'1814')
            Delta_t_start_CV580=60.5/3600;%SAFARI Aug 15 , 2000 (seconds)
            Delta_t_end_CV580=66/3600;   %SAFARI Aug 15 , 2000 (seconds)
        end
        if (day==17 & month==8 & year==2000)
            Delta_t_start_CV580=61/3600; %SAFARI Aug 17 , 2000 (seconds)
            Delta_t_end_CV580=67/3600;   %SAFARI Aug 17 , 2000 (seconds)
        end
        if (day==18 & month==8 & year==2000)
            Delta_t_start_CV580=-2/3600; %SAFARI Aug 18 , 2000 (seconds)
            Delta_t_end_CV580=4/3600;   %SAFARI Aug 18 , 2000 (seconds)
        end
        if strcmp(flight_no,'1818')
            Delta_t_start_CV580=-1/3600;  %SAFARI Aug 20 , 2000 (seconds)
            Delta_t_end_CV580=-1/3600;     %SAFARI Aug 20 , 2000 (seconds)
        end
        if strcmp(flight_no,'1819')
            Delta_t_start_CV580=-2/3600;  %SAFARI Aug 20 , 2000 (seconds)
            Delta_t_end_CV580=3/3600;     %SAFARI Aug 20 , 2000 (seconds)
        end
        if (day==22 & month==8 & year==2000)
            Delta_t_start_CV580=7/3600;  %SAFARI Aug 22 , 2000 (seconds)
            Delta_t_end_CV580=14/3600;   %SAFARI Aug 22 , 2000 (seconds)
        end 
        if (day==23 & month==8 & year==2000)
            Delta_t_start_CV580=4/3600;  %SAFARI Aug 23 , 2000 (seconds)
            Delta_t_end_CV580=9/3600;   %SAFARI Aug 23 , 2000 (seconds)
        end 
        if (day==24 & month==8 & year==2000)
            Delta_t_start_CV580=5/3600;  %SAFARI Aug 24 , 2000 (seconds)
            Delta_t_end_CV580=11/3600;   %SAFARI Aug 24, 2000 (seconds)
        end
        if strcmp(flight_no,'1823')
            Delta_t_start_CV580=1/3600;  %SAFARI Aug 29 , 2000, UW1823 (seconds)
            Delta_t_end_CV580=5/3600;    %SAFARI Aug 29, 2000, UW 1823(seconds)
        end
        if strcmp(flight_no,'1824')
            Delta_t_start_CV580=1/3600;  %SAFARI Aug 29 , 2000, UW1824 (seconds)
            Delta_t_end_CV580=5/3600;    %SAFARI Aug 29, 2000, UW 1824(seconds)
        end
        if (day==31 & month==8 & year==2000)
            Delta_t_start_CV580=4/3600;  %SAFARI Aug 31 , 2000, UW1825 (seconds)
            Delta_t_end_CV580=7/3600;    %SAFARI  Aug 31, 2000, UW 1825(seconds)
        end
        if (day==1 & month==9 & year==2000)
            Delta_t_start_CV580=4/3600;  %SAFARI Sep 1 , 2000, UW1826 (seconds)
            Delta_t_end_CV580=9/3600;    %SAFARI Sep 1, 2000, UW 1826(seconds)
        end
        if (day==2 & month==9 & year==2000)
            Delta_t_start_CV580=4/3600;  %SAFARI Sep 2 , 2000 (seconds)
            Delta_t_end_CV580=11/3600;   %SAFARI Sep 2, 2000 (seconds)
        end
        if (day==3 & month==9 & year==2000)
            Delta_t_start_CV580=4/3600; %SAFARI Sep 3, 2000 (seconds)
            Delta_t_end_CV580=9/3600;  %SAFARI Sep 3, 2000 (seconds)
        end
        if (day==5 & month==9 & year==2000)
            Delta_t_start_CV580=4.5/3600; %SAFARI Sep 5, 2000 (seconds)
            Delta_t_end_CV580=11.5/3600;  %SAFARI Sep 5, 2000 (seconds)
        end
        if strcmp(flight_no,'1832')
            Delta_t_start_CV580=8/3600; %SAFARI Sep 6, 2000 (seconds)
            Delta_t_end_CV580=13/3600;  %SAFARI Sep 6, 2000 (seconds)
        end
         if strcmp(flight_no,'1833')
            Delta_t_start_CV580=12/3600; %SAFARI Sep 6, 2000 (seconds)
            Delta_t_end_CV580=15/3600;  %SAFARI Sep 6, 2000 (seconds)
        end
        if (day==7 & month==9 & year==2000)
            Delta_t_start_CV580=13/3600; %SAFARI Sep 7, 2000 (seconds)
            Delta_t_end_CV580=18/3600;  %SAFARI Sep 7, 2000 (seconds)
        end
        if (day==11 & month==9 & year==2000)
            Delta_t_start_CV580=12/3600; %SAFARI Sep 11, 2000 (seconds)
            Delta_t_end_CV580=18/3600;  %SAFARI Sep 11, 2000 (seconds)
        end
        if (day==13 & month==9 & year==2000)
            Delta_t_start_CV580=19/3600; %SAFARI Sep 13, 2000 (seconds)
            Delta_t_end_CV580=25/3600;  %SAFARI Sep 13, 2000 (seconds)
        end
        if (day==14 & month==9 & year==2000)
            Delta_t_start_CV580=17/3600; %SAFARI Sep 14, 2000 (seconds)
            Delta_t_end_CV580=22/3600;  %SAFARI Sep 14, 2000 (seconds)
        end 
        if (day==16 & month==9 & year==2000)
            Delta_t_start_CV580=17/3600; %SAFARI Sep 16, 2000 (seconds)
            Delta_t_end_CV580=23/3600;  %SAFARI Sep 16, 2000 (seconds)
        end     
        
        [UT_CV580,tans_lat,tans_lon,tans_alt,pstat,p_alt]=read_CV580(flight_no);
        Delta_t=interp1([UT_CV580(1) UT_CV580(end)],[Delta_t_start_CV580 Delta_t_end_CV580],UT_CV580);
        UT_CV580=UT_CV580+Delta_t;
        p_alt=p_alt/1000;
        tans_alt=tans_alt/1000;
        
        if UT_start<min(UT_CV580)
            UT_start=min(UT_CV580)
        end
        if UT_end>max(UT_CV580)
            UT_end=max(UT_CV580)
        end
    end  
    
    %Set UT=Laptop time
    Delta_t_Laptop=0;   
    UT=UT_Laptop+Delta_t_Laptop;
    
    %Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);,
    UT=UT(L);,
    UT_Can=UT_Can(L);
    Airmass=Airmass(L);
    Mean_volts=Mean_volts(:,L);,
    Sd_volts=Sd_volts(:,L);,
    Pressure=Pressure(:,L);,
    Press_Alt=Press_Alt(L);,
    Latitude=Latitude(L);,
    Longitude=Longitude(L);,
    Temperature=Temperature(:,L);,
    Az_err=Az_err(L);,
    Az_pos=Az_pos(L);,
    Elev_err=Elev_err(L);,
    Elev_pos=Elev_pos(L);,
    Heading=Heading(L);,
    ScanFreq=ScanFreq(L);,
    AvePeriod=AvePeriod(L);
    RecInterval=RecInterval(L);,
    Voltref=Voltref(:,L);
    Altitude=Press_Alt;
    
    
    if strcmp(site,'SAFARI-2000')
        ii= INTERP1(UT_CV580,1:size(UT_CV580'),UT,'nearest');
        
        figure(14)
        subplot(8,1,1)
        plot(UT,Latitude,'.-',UT_CV580,tans_lat,'.-') 
        title(sprintf('%s %s %4d-%02d-%02d', 'UW Flight', flight_no,year,month,day))
        ylabel('Lat')
        xx=get(gca,'xlim');
        legend('AATS-14','UW')
        set(gca,'ylim',[-30 -10])
        set(gca,'xlim',xx)
        subplot(8,1,2)
        plot(UT,Latitude-tans_lat(ii)) 
        set(gca,'xlim',xx)
        set(gca,'ylim',[-0.02 0.02])
        ylabel('AATS14-UW')
        grid on
        
        subplot(8,1,3)
        plot(UT,Longitude,'.-',UT_CV580,tans_lon,'.-') 
        ylabel('Lon')
        set(gca,'ylim',[10 35])
        set(gca,'xlim',xx)
        subplot(8,1,4)
        plot(UT,Longitude-tans_lon(ii)) 
        set(gca,'xlim',xx)
        set(gca,'ylim',[-0.02 0.02])
        ylabel('AATS14-UW')
        grid on
        
        subplot(8,1,5)
        plot(UT,Pressure,'.-',UT_CV580,pstat,'.-') 
        ylabel('p[mb]')
        set(gca,'xlim',xx)
        set(gca,'ylim',[500 1050])
        subplot(8,1,6)
        plot(UT,Pressure-pstat(ii)) 
        ylabel('AATS14-UW')
        xlabel('UT')
        set(gca,'xlim',xx)
        set(gca,'ylim',[-2 2])
        grid on
        
        subplot(8,1,7)
        plot(UT,Press_Alt,'.-',UT_CV580,p_alt,'.-',UT_CV580,tans_alt,'.-') 
        legend('palt feed','palt UW','GPS alt')
        ylabel('p_alt[km]')
        set(gca,'xlim',xx)
        set(gca,'ylim',[0 5.5])
        subplot(8,1,8)
        plot(UT,Press_Alt-p_alt(ii)) 
        ylabel('AATS14-UW')
        xlabel('UT')
        set(gca,'xlim',xx)
        set(gca,'ylim',[-0.0150 0.015])
        grid on
        
        %Latitude=tans_lat(ii);
        %Longitude=tans_lon(ii);
        %Pressure=pstat(ii);
        %Press_Alt=p_alt(ii);
        %Altitude=p_alt(ii);
    end
    
case 'Laptop_Otter'
    %for files on CIRPAS Twin Otter starting on 2/27/01   
    [day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,...
            Heading,Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
            Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,RH,GPS_Alt,T_stat]=AATS14_Laptop_Otter([data_dir 'CIR??_R?????01.*']);
    
    if (day==30 & month==3 & year==2001)
        Delta_t_Laptop=3/3600; % (seconds)  ACE_Asia Mar 30,    2001 CIR00
    end
    if (day==31 & month==3 & year==2001)
        Delta_t_Laptop=4/3600; % (seconds)  ACE_Asia Mar 31,    2001 CIR01
    end
    if (day==1 & month==4 & year==2001)
        Delta_t_Laptop=4/3600; % (seconds)  ACE_Asia Apr 1/2,   2001 CIR02
    end
    if (day==3 & month==4 & year==2001)
        Delta_t_Laptop=5/3600; % (seconds)  ACE_Asia Apr 3/4,   2001 CIR03
    end
    if (day==5 & month==4 & year==2001)
        Delta_t_Laptop=6/3600; % (seconds)  ACE_Asia Apr 5/6,   2001 CIR04
    end
    if (day==8 & month==4 & year==2001)
        Delta_t_Laptop=8/3600; % (seconds)  ACE_Asia Apr 8,     2001 CIR05
    end
    if (day==9 & month==4 & year==2001)
        Delta_t_Laptop=10/3600; % (seconds) ACE_Asia Apr 9,     2001 CIR06
    end
    if (day==11 & month==4 & year==2001)
        Delta_t_Laptop=0/3600; % (seconds) ACE_Asia Apr 11/12,  2001 CIR07
    end
    if (day==12 & month==4 & year==2001)
        Delta_t_Laptop=1/3600; % (seconds) ACE_Asia Apr 12/13,  2001 CIR08
    end
    if (day==14 & month==4 & year==2001)
        Delta_t_Laptop=1/3600; % (seconds) ACE_Asia Apr 14,     2001 CIR09
    end
    if (day==15 & month==4 & year==2001)
        Delta_t_Laptop=3/3600; % (seconds) ACE_Asia Apr 15/16,  2001 CIR10
    end
    if (day==17 & month==4 & year==2001)
        Delta_t_Laptop=3/3600; % (seconds) ACE_Asia Apr 17,     2001 CIR11
    end
    if (day==18 & month==4 & year==2001)
        Delta_t_Laptop=-1/3600; % (seconds) ACE_Asia Apr 18/19, 2001 CIR12
    end
    if (day==19 & month==4 & year==2001)
        Delta_t_Laptop=-1/3600; % (seconds) ACE_Asia Apr 19/20, 2001 CIR13
    end
    if (day==22 & month==4 & year==2001)
        Delta_t_Laptop=-3/3600; % (seconds) ACE_Asia Apr 22/23, 2001 CIR14
    end
    if (day==25 & month==4 & year==2001)
        Delta_t_Laptop=-5/3600; % (seconds) ACE_Asia Apr 25/26, 2001 CIR16
    end
    if (day==26 & month==4 & year==2001)
        Delta_t_Laptop=-2/3600; % (seconds) ACE_Asia Apr 26/27, 2001 CIR17
    end
    if (day==28 & month==4 & year==2001)
        Delta_t_Laptop=1/3600; % (seconds) ACE_Asia Apr 28    , 2001 CIR18
    end
    
    
    %Set UT=Laptop time
    UT=UT_Laptop+Delta_t_Laptop;
    %Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);,
    UT=UT(L);,
    UT_Can=UT_Can(L);
    Airmass=Airmass(L);
    Mean_volts=Mean_volts(:,L);,
    Sd_volts=Sd_volts(:,L);,
    Pressure=Pressure(:,L);,
    Press_Alt=Press_Alt(L);,
    Latitude=Latitude(L);,
    Longitude=Longitude(L);,
    Temperature=Temperature(:,L);,
    Az_err=Az_err(L);,
    Az_pos=Az_pos(L);,
    Elev_err=Elev_err(L);,
    Elev_pos=Elev_pos(L);,
    Heading=Heading(L);,
    ScanFreq=ScanFreq(L);,
    AvePeriod=AvePeriod(L);
    RecInterval=RecInterval(L);,
    Voltref=Voltref(:,L);
    RH=RH(:,L);
    GPS_Alt=GPS_Alt(:,L);
    T_stat=T_stat(:,L);
    Altitude=GPS_Alt;
    
case 'Laptop_DC8_SOLVE2'
    %for files on CIRPAS Twin Otter starting on 2/27/01   
    [day,month,year,UT_Laptop,UT_Can,Airmass,Temperature,Latitude,Longitude,Press_Alt,Pressure,...
            Heading,Mean_volts,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
            Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,RH,GPS_Alt,T_stat]=AATS14_Laptop_DC8_SOLVE2([data_dir 'R*.*']);
    Delta_t_Laptop=0;
    %Set UT=Laptop time
    UT=UT_Laptop+Delta_t_Laptop;
    %Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);,
    UT=UT(L);,
    UT_Can=UT_Can(L);
    Airmass=Airmass(L);
    Mean_volts=Mean_volts(:,L);,
    Sd_volts=Sd_volts(:,L);,
    Pressure=Pressure(:,L);,
    Press_Alt=Press_Alt(L);,
    Latitude=Latitude(L);,
    Longitude=Longitude(L);,
    Temperature=Temperature(:,L);,
    Az_err=Az_err(L);,
    Az_pos=Az_pos(L);,
    Elev_err=Elev_err(L);,
    Elev_pos=Elev_pos(L);,
    Heading=Heading(L);,
    ScanFreq=ScanFreq(L);,
    AvePeriod=AvePeriod(L);
    RecInterval=RecInterval(L);,
    Voltref=Voltref(:,L);
    RH=RH(:,L);
    GPS_Alt=GPS_Alt(:,L);
    T_stat=T_stat(:,L);
    Altitude=GPS_Alt;
    
end


if iwrite_eilers_binary==1
    fid=fopen('c:\johnmatlab\AATS14-1999\JimPC_be.bin','wb','ieee-be')
    count=fwrite(fid,UT_Laptop,'single');
    count=fwrite(fid,UT_Can,'single');
    count=fwrite(fid,Latitude,'single');
    count=fwrite(fid,Longitude,'single');
    count=fwrite(fid,Heading,'single');
    count=fwrite(fid,Pressure,'single');
    count=fwrite(fid,Press_Alt,'single');
    count=fwrite(fid,Temperature,'single');
    count=fwrite(fid,Mean_volts,'single');
    count=fwrite(fid,Sd_volts,'single');
    count=fwrite(fid,Az_pos,'single');
    count=fwrite(fid,Az_err,'single');
    count=fwrite(fid,Elev_pos,'single');
    count=fwrite(fid,Elev_err,'single');
    count=fwrite(fid,Voltref,'single');
    fclose(fid)
end

% compute the solar position is optional here
[m,n]=size(Latitude);
sample=[1:1:n];
temp=ones(n,1)*282.0;

%Use for Ames if not in file
%Longitude=ones(1,n)*-122.057 ; Latitude=ones(1,n)*37.42 ;
%Pressure=ones(1,n)*1016.5;

[Az_Sun, Elev_Sun]=sun(Longitude,Latitude,day, month, year, UT,temp',Pressure);

%abscissa = sample;	%use for flight on 6/5/99 because no time in that file
abscissa = UT;  
UTlim=[-inf inf];
UTlim=[23.5 inf];

figure(1)
set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
orient landscape
subplot(5,1,1)
plot(abscissa,Mean_volts)
ylabel('Signals(V)')
%set(gca,'ylim',[0 10])
axis([UTlim 0 10])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(5,1,2)
plot(abscissa,Sd_volts./Mean_volts*100)
%set(gca,'ylim',[0 5])
axis([UTlim 0 5])
ylabel('Stdev(%)')

subplot(5,1,3)
plot(abscissa,Altitude,'k')
%set(gca,'ylim',[0 5])
axis([UTlim 0 13])
ylabel('Altitude(km)')
grid on

subplot(5,1,4)
plot(abscissa,Latitude,'k')
%set(gca,'ylim',[35 40])
axis([UTlim -inf inf])
ylabel('Latitude (°)')
grid on

subplot(5,1,5)
plot(abscissa,Longitude,'k')
%set(gca,'ylim',[120 140])
axis([UTlim -inf inf])
ylabel('Longitude(°)')
xlabel('UTC')
grid on

figure(2)
%temperatures not connected
orient landscape
subplot(4,1,1)
plot(abscissa,Temperature(7:9,:))
set(gca,'xlim',[-inf inf])
%axis([-inf inf -274 -270])
ylabel('T [°C]')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend('argus','hot PCA','cold PCA')
grid on

subplot(4,1,2)
plot(abscissa,Temperature(11,:))
axis([-inf inf -80 30])
xlabel('UTC [hrs]')
ylabel('T [°C]')
legend('T stat / cool in')
grid on

subplot(4,1,3)
plot(abscissa,Temperature(12,:)/3.2808)  %on DC-8 for SOLVE2, need to convert from feet to m
set(gca,'xlim',[-inf inf])
%axis([-inf inf 0 5000])
xlabel('UTC [hrs]')
ylabel('GPS Altitude [m]')
legend('GPS alt./cool out')
grid on

subplot(4,1,4)
plot(abscissa,Temperature(15,:))
set(gca,'xlim',[-inf inf])
%axis([-inf inf 0 100])
xlabel('UTC [hrs]')
ylabel('RH[%]')
legend('RH / pwr supply')
grid on

figure(3)
%temperatures sorted
orient landscape
subplot(4,1,1)
plot(abscissa,Temperature([1,2],:))
axis([-inf inf 43 46])
grid on
ylabel('T [°C]')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend('hot detector plate #1','hot detector plate #2')

subplot(4,1,2)
plot(abscissa,Temperature([5,6],:))
axis([-inf inf -1 1])
set(gca,'ylim',[-1.5 0.5])
grid on
ylabel('T [°C]')
legend('cold detector #1','cold detector #2')

subplot(4,1,3)
plot(abscissa,Temperature([3,10],:))
axis([-inf inf 20 45])
grid on
ylabel('T [°C]')
legend('filter plate #1','filter plate #2')

subplot(4,1,4)
plot(abscissa,Temperature([4,13,14],:))
axis([-inf inf -10 60])
grid on
ylabel('T [°C]')
legend('electronics can','data CPU','trk CPU')

figure(4)
%flight track
orient landscape
%jascent=find(UT<=20.584);
%jdescent=find(UT>20.584);
%jascent=find(UT<=24);
%jascent=find(UT>=14.0&UT<=17.5);
jascent=find(UT>0);
jdescent=[];
subplot(1,2,1)
plot3(Longitude(jascent),Latitude(jascent),Altitude(jascent),'b.-')
if ~isempty(jdescent)
    hold on
    plot3(Longitude(jdescent),Latitude(jdescent),Altitude(jdescent),'r.-')
end
if strcmp(site,'SAFARI-2000')
    %plot3(29.4568,-23.8643,1.214,'ro','MarkerSize',7,'MarkerFaceColor','r') % Pietersburg Cimel RSA Holben Spreadsheet
    plot3(31.5927,-24.9700,0.150,'ro','MarkerSize',7,'MarkerFaceColor','r') % Skukuza Airport RSA  Cimel Helmlinger GPS
    %plot3(31.5850,-24.9720,0.150,'mo','MarkerSize',7,'MarkerFaceColor','m') % Skukuza Airport RSA MPL-net 
    plot3(31.3697,-25.0198,0.150,'go','MarkerSize',7,'MarkerFaceColor','g') % Skukuza Tower , RSA Helmlinger GPS
    plot3(31.5833,-24.9833,0.150,'yo','MarkerSize',7,'MarkerFaceColor','y') % Skukuza, RSA  Cimel Holben Spreadsheet
    %plot3(28.3167,-28.2333,1.709,'ko','MarkerSize',7)                       % Betlehem, RSA  Cimel Holben Spreadsheet
    %plot3(32.9050,-26.041,0.073,'ko','MarkerSize',7,'MarkerFaceColor','k') % Inhaca Island, Mocambique, Cimel Aeronet
    %plot3(24.7948,-14.7926,1.179,'go','MarkerSize',7,'MarkerFaceColor','g') % Kaoma, Zambia Cimel Holben Spreadsheet
    %plot3(28.6585,-12.9937,1.291,'bo','MarkerSize',7,'MarkerFaceColor','b') % Ndola, Zambia Cimel Holben Spreadsheetg
    %plot3(26.8208,-12.2812,1.417,'yo','MarkerSize',7,'MarkerFaceColor','y') % Solwezi, Zambia Cimel Holben Spreadsheet
    %plot3(24.4307,-11.7400,1.426,'co','MarkerSize',7,'MarkerFaceColor','c') % Mwinilunga, Zambia Cimel Holben Spreadsheet
    %plot3(23.1078,-13.5336,1.098,'mo','MarkerSize',7,'MarkerFaceColor','m') % Zambezi, Zambia Cimel Holben Spreadsheet
    %plot3(23.1500,-15.2500,1.107,'rs','MarkerSize',7,'MarkerFaceColor','r') % Mongu Cimel and Lidar, Zambia  Holben Spreadsheet
    %plot3(23.2500,-15.4333,1.090,'gs','MarkerSize',7,'MarkerFaceColor','g') % Mongu Tower Cimel, Zambia  Holben Spreadsheet
    %plot3(23.2977,-16.1115,1.053,'bs','MarkerSize',7,'MarkerFaceColor','b') % Senanga Cimel, Zambia  Holben Spreadsheet
    %plot3(25.1500,-17.8167,1.000,'ks','MarkerSize',7,'MarkerFaceColor','k') % Kasane, Zambia WMO Station
    %plot3(23.5500,-19.8833,0.940,'ys','MarkerSize',7,'MarkerFaceColor','y') % Maun Tower Cimel, Botswana  Holben Spreadsheet
    %plot3(26.0667,-20.5167,0.900,'cs','MarkerSize',7,'MarkerFaceColor','c') % Sua Pan Cimel, Botswana  Holben Spreadsheet
    %plot3(14.5000,-23.0000,0.015,'ms','MarkerSize',7,'MarkerFaceColor','m') % Walvis Bay, Namibia Holben Spreadsheet
    %plot3(15.914,-19.175,1.131,'rs','MarkerSize',7,'MarkerFaceColor','r') % Etosha Pan, Namibia Holben Spreadsheet
end
hold off
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
zlabel('Altitude (km)','FontSize',14)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename),'FontSize',14);
grid on
set(gca,'FontSize',14)
set(gca,'zlim',[0 inf])
lon=get(gca,'xlim');
lat=get(gca,'ylim');
lon_rng = deg2km(DISTANCE(lat(1),lon(1),lat(1),lon(2)))
lat_rng = deg2km(DISTANCE(lat(1),lon(1),lat(2),lon(1)))

subplot(1,2,2)
plot(Longitude(jascent),Latitude(jascent),'b.-')
if ~isempty(jdescent)
    hold on
    plot(Longitude(jdescent),Latitude(jdescent),'r.-')
end
if strcmp(site,'SAFARI-2000')
     %plot(29.4568,-23.8643,'ro','MarkerSize',7,'MarkerFaceColor','r') % Pietersburg Cimel Holben Spreadsheet
    plot(31.5927,-24.97,'ro','MarkerSize',7,'MarkerFaceColor','r') %  Skukuza Airport RSA  Cimel Helmlinger GPS
     %plot(31.5850,-24.9720,'mo','MarkerSize',7,'MarkerFaceColor','m') % Skukuza Airport RSA MPL-net
    plot(31.3697,-25.0198,'go','MarkerSize',7,'MarkerFaceColor','g') % Skukuza Tower , RSA Helmlinger GPS
    plot(31.5833,-24.9833,'yo','MarkerSize',7,'MarkerFaceColor','y') % Skukuza, RSA  Cimel Holben Spreadsheet
    %plot(28.3167,-28.2333,'ko','MarkerSize',7)                       % Betlehem Cimel Holben Spreadsheet
    % plot(32.9050,-26.041,'ko','MarkerSize',7,'MarkerFaceColor','k') % Inhaca Island Cimel Aeronet
    % plot(24.7948,-14.7926,'go','MarkerSize',7,'MarkerFaceColor','g') % Kaoma, Zambia Cimel Holben Spreadsheet
    %plot(28.6585,-12.9937,'bo','MarkerSize',7,'MarkerFaceColor','b') % Ndola, Zambia Cimel Holben Spreadsheet
    %plot(26.8208,-12.2812,'yo','MarkerSize',7,'MarkerFaceColor','y') % Solwezi, Zambia Cimel Holben Spreadsheet
    %plot(24.4307,-11.7400,'co','MarkerSize',7,'MarkerFaceColor','c') % Mwinilunga, Zambia Cimel Holben Spreadsheet
    %plot(23.1078,-13.5336,'mo','MarkerSize',7,'MarkerFaceColor','m') % Zambezi, Zambia Cimel Holben Spreadsheet
    %plot(23.1500,-15.2500,'rs','MarkerSize',7,'MarkerFaceColor','r')   % Mongu Cimel and Lidar, Zambia  Holben Spreadsheet
    %plot(23.2500,-15.4333,'gs','MarkerSize',7,'MarkerFaceColor','g') % Mongu Tower Cimel, Zambia  Holben Spreadsheet
    %plot(23.2977,-16.1115,'bs','MarkerSize',7,'MarkerFaceColor','b') % Senanga Cimel, Zambia  Holben Spreadsheet
    %plot(25.1500,-17.8167,'ks','MarkerSize',7,'MarkerFaceColor','k') % Kasane, Zambia WMO Station
    %plot(23.5500,-19.8833,'ys','MarkerSize',7,'MarkerFaceColor','y') % Maun Tower Cimel, Botswana  Holben Spreadsheet
    %plot(26.0667,-20.5167,'cs','MarkerSize',7,'MarkerFaceColor','c') % Sua Pan Cimel, Botswana  Holben Spreadsheet
    %plot(14.5000,-23.0000,'ms','MarkerSize',7,'MarkerFaceColor','m') % Walvis Bay, Namibia Holben Spreadsheet
     %plot(15.914,-19.175,'rs','MarkerSize',7,'MarkerFaceColor','r') % Etosha Pan, Namibia Holben Spreadsheet
end

hold off
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
grid on
%axis([31.5 31.75 -25.1 -24.875])
lon=get(gca,'xlim');
lat=get(gca,'ylim');
lon_rng = deg2km(DISTANCE(lat(1),lon(1),lat(1),lon(2)))
lat_rng = deg2km(DISTANCE(lat(1),lon(1),lat(2),lon(1)))

axis square
if ~isempty(jdescent)
    legend('ascent','descent')
end
set(gca,'FontSize',14)
if strcmp(site,'SAFARI-2000')
    %legend('CV-580 track','Skukuza Lidar','Skukuza Cimel')
     legend('CV-580 track','Skukuza Lidar','Skukuza Tower','Skukuza Cimel')
    %legend('CV-580 track','Pietersburg Cimel','Skukuza Lidar','Skukuza Tower','Skukuza Cimel')
    %legend('CV-580 track','Pietersburg Cimel','Skukuza Lidar','Skukuza Tower','Skukuza Cimel','Inhaca Island')
    %legend('CV-580 track','Inhaca Island')
    %legend('CV-580 track','Pietersburg Cimel','Kaoma Cimel', 'Ndola Cimel', 'Solwezi Cimel', 'Mwinilunga Cimel','Zambezi Cimel','Mongu Cimel&Lidar','Mongu Tower Cimel','Senanga Cimel','Maun Tower Cimel','Sua Pan Cimel')
    %legend('CV-580 track','Pietersburg Cimel','Kaoma Cimel', 'Mongu Cimel&Lidar','Mongu Tower Cimel','Senanga Cimel','Maun Tower Cimel','Sua Pan Cimel')
    %legend('CV-580 track','Mongu Airport Cimel&Lidar','Mongu Tower','Senanga Cimel','Kasane')
    %legend('CV-580 track','Mongu Airport Cimel&Lidar','Mongu Tower')
    %legend('CV-580 track','Pietersburg Cimel','Maun Tower Cimel','Sua Pan Cimel')
    %legend('CV-580 track','Maun Tower Cimel')
    %legend('CV-580 track','Kaoma Cimel')
    %legend('CV-580 track','Pietersburg Cimel','Sua Pan Cimel')
    %legend('CV-580 track','Walvis Bay Cimel','Etosha Pan Cimel')
    %legend('CV-580 track','Etosha Pan Cimel')
end

if strcmp(Map_plt,'ON')
    figure(41)
    worldmap([min(Latitude)-1,max(Latitude)+1],[min(Longitude)-3 max(Longitude)+3],'patch')
    plotm(Latitude,Longitude)
    scaleruler on
    set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
    setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
    hidem(gca)
end


figure(5)
orient landscape
plot(abscissa,Voltref)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
xlabel('UTC (hrs)')
ylabel('V_r_e_f (V)')
legend('Temperature A/D Vref', 'Detector A/D #1 Vref','Detector A/D #2 Vref')
grid on
%axis([-inf inf -inf inf])
axis([-inf inf 2.5 2.51])

figure(6) %signals
orient landscape
set(6,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(6,1,1)
plot(abscissa,Mean_volts(1:7,:))
set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
subplot(6,1,2)
plot(abscissa,Mean_volts(8:14,:))
set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));

subplot(6,1,3)
plot(abscissa,Sd_volts(1:7,:)./Mean_volts(1:7,:)*100)
set(gca,'ylim',[0 2])
ylabel('Stdev(%)')
grid on
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));

subplot(6,1,4)
plot(abscissa,Sd_volts(8:14,:)./Mean_volts(8:14,:)*100)
set(gca,'ylim',[0 2])
ylabel('Stdev(%)')
grid on
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));

subplot(6,1,5)
plot(abscissa,Elev_err,abscissa,Az_err)
grid on
ylabel('Track Err (\circ)')
set(gca,'ylim',[-inf inf])
legend('Elev','Azi')
xlabel('UTC(hrs)')

subplot(6,1,6)
plot(abscissa,Elev_pos,abscissa,Az_pos)
grid on
set(gca,'ylim',[-360 360])
ylabel('Position (\circ)')
legend('Elev','Azi')
xlabel('UTC(hrs)')


UTlim=[-inf inf];
%UTlim=[23.8 25];
figure(7) % signals
orient landscape
set(7,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(2,1,1)
plot(abscissa,Mean_volts(1:7,:))
%set(gca,'ylim',[-0.003 0.003])
set(gca,'ylim',[0 10])
set(gca,'xlim',UTlim)
grid on
ylabel('Signals(V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
subplot(2,1,2)
plot(abscissa,Mean_volts(8:14,:))
%set(gca,'ylim',[-0.003 0.100])
set(gca,'ylim',[0 10])
set(gca,'xlim',UTlim)
grid on
ylabel('Signals(V)')
xlabel('UTC(hrs)')
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));


figure(8) % dark signals
orient landscape
set(8,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
xlimfig8=[-inf inf]; %[20.35 20.55]; %[20.1 20.4];
%xlimfig8=[-inf inf];
ylimfig8=[-.002 .01]; %[-.002 .03];
subplot(3,1,1)
plot(abscissa,Mean_volts(1:7,:))
set(gca,'ylim',ylimfig8)
set(gca,'xlim',xlimfig8)
%set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
subplot(3,1,2)
plot(abscissa,Mean_volts(8:14,:))
set(gca,'ylim',ylimfig8)
%xlimits=get(gca,'xlim');
set(gca,'xlim',xlimfig8)
%set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));
subplot(3,1,3)
set(8,'DefaultAxesColorOrder',[0.8 0.2 0.2])
plot(abscissa,Mean_volts(13,:))
set(gca,'ylim',[0 0.1]); %[0.08 0.15])
set(gca,'xlim',xlimfig8)
grid on
xlabel('UTC(hrs)')
ylabel('Signals(V)')
legend(num2str(lambda_AATS14(13)))

%calculate mean background Voltage
UTbk=[20.3 21];%for R07Nov02.AB; %[15.8 17.1] %for Dryden???;
jbk=find(UT>=UTbk(1)&UT<=UTbk(2));
Vdarkmean=mean(Mean_volts(:,jbk),2);
Vdarksd=std(Mean_volts(:,jbk),1,2);
Vdarkmean=Vdarkmean([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
Vdarksd=Vdarksd([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
wvlnm=lambda_AATS14([8 1 2 4:7 9:12 3 14 13]);
fprintf('%7.0f ',wvlnm)
fprintf('\n')
fprintf('%7.4f ',Vdarkmean)
fprintf('\n')
fprintf('%7.4f ',Vdarksd)

UTlim=[-inf inf]; %14.5 17.5];
%UTlim=[-inf 24.7];
figure(9)
orient landscape
subplot(6,1,1)
plot(abscissa,Elev_err,'go-','MarkerSize',4)
axis([UTlim -.04 0.04])
grid on
ylabel('Elev Err (\circ)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(6,1,2)
plot(abscissa,Az_err,'bo-','MarkerSize',4)
axis([UTlim -.1 .1])
grid on
ylabel('Azi Err (\circ)')

subplot(6,1,3)
plot(abscissa,Heading,'ko-','MarkerSize',4)
axis([UTlim 0 360])
grid on
ylabel('Aircraft Heading (\circ)')

subplot(6,1,4)
Data_Rate=diff(UT*3600);
Turn_Rate=diff(Heading)./Data_Rate;
ii=find(Turn_Rate>20);
jj=find(Turn_Rate<-20);
Turn_Rate(ii)=Turn_Rate(ii)-(360./Data_Rate(ii)); %There is one measurement every 4 sec and Turnrate could be 360 deg when Heading goes over
Turn_Rate(jj)=Turn_Rate(jj)+(360./Data_Rate(jj)); %There is one measurement every 4 sec and Turnrate could be 360 deg when Heading goes over
plot(UT(1:end-1),Turn_Rate,'k-o','MarkerSize',4)
axis([UTlim -8 8])
grid on
ylabel('Turning Rate \circ/sec')

subplot(6,1,5)
Elev_Rate=diff(Elev_pos)./Data_Rate;
plot(UT(1:end-1),Elev_Rate,'k-o','MarkerSize',4)
axis([UTlim -8 8])
grid on
ylabel('Elev. Change \circ/sec')
xlabel('UTC(hrs)')

subplot(6,1,6)
Az_Rate=diff(Az_pos)./Data_Rate;
ii=find(Az_Rate>20);
jj=find(Az_Rate<-20);
Az_Rate(ii)=Az_Rate(ii)-(360./Data_Rate(ii)); %There is one measurement every 4 sec and Turnrate could be 360 deg when Heading goes over
Az_Rate(jj)=Az_Rate(jj)+(360./Data_Rate(jj)); %There is one measurement every 4 sec and Turnrate could be 360 deg when Heading goes over

plot(UT(1:end-1),Az_Rate,'k-o','MarkerSize',4)
axis([UTlim -20 20])
grid on
ylabel('Az. Change \circ/sec')
xlabel('UTC(hrs)')


figure(12)
% show rate of change in Lat,Long and Press
orient landscape
subplot(4,1,1)
plot(UT(1:end-1),diff(UT*3600),'.')
set(gca,'ylim',[-inf inf])
set(gca,'xlim',[-inf inf])
grid on
xlabel('UT')
ylabel('Data rate (sec)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(4,1,2)
plot(UT(1:end-1),diff(Latitude)./diff(UT))
set(gca,'ylim',[-20 20])
set(gca,'xlim',[-inf inf])
grid on
xlabel('UT')
ylabel('Rate of change (deg/h)')
legend('Latitude')
subplot(4,1,3)
plot(UT(1:end-1),diff(Longitude)./diff(UT))
set(gca,'ylim',[-20 20])
set(gca,'xlim',[-inf inf])
grid on
xlabel('UT')
ylabel('Rate of change (deg/h)')
legend('Longitude')
subplot(4,1,4)
plot(UT(1:end-1),diff(Press_Alt)./diff(UT))
set(gca,'ylim',[-50 50])
set(gca,'xlim',[-inf inf])
xlabel('UT')
ylabel('Rate of change (km/h)')
legend ('Altitude')
grid on

switch source
case 'Laptop_Otter'
    figure(13)
    subplot(4,1,1)
    plot(UT,RH)
    ylabel('RH(%)')
    subplot(4,1,2)
    plot(UT,T_stat)
    ylabel('T stat(\circC)')
    xlabel('UT')
    subplot(4,1,3)
    plot(UT,GPS_Alt,UT,Press_Alt)
    ylabel('z(km)')
    legend('GPS','Pressure')
    subplot(4,1,4)
    plot(UT,GPS_Alt-Press_Alt)
    ylabel('GPS-P_a_l_t(km)')
    set(gca,'ylim',[-0.1 0.1])
    grid on
end

UTlim=[-inf inf];
Vlim=[0 10];
figure(20)
set(20,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
orient landscape
subplot(2,1,1)
plot(abscissa,Mean_volts)
grid on
ylabel('Signals(V)')
%set(gca,'ylim',[0 10])
axis([UTlim Vlim])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(2,1,2)
plot(abscissa,Sd_volts./Mean_volts*100)
%set(gca,'ylim',[0 5])
axis([UTlim 0 0.1])
ylabel('Stdev(%)')
grid on
xlabel('UT (hrs)')
AxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(5,1,1)
plot(abscissa,Mean_volts(1:7,:))
%set(gca,'ylim',[-0.003 0.003])
set(gca,'ylim',[0 10])
set(gca,'xlim',UTlim)
grid on
ylabel('Signals(V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
subplot(5,1,2)
plot(abscissa,Mean_volts(8:14,:))
%set(gca,'ylim',[-0.003 0.100])
set(gca,'ylim',[0 10])
set(gca,'xlim',UTlim)
grid on
ylabel('Signals(V)')
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));
subplot(5,1,3)
plot(abscissa,Elev_err,'go-','MarkerSize',4)
axis([UTlim eleverr_lim])
grid on
ylabel('Elev Err (\circ)')
subplot(5,1,4)
plot(abscissa,Az_err,'bo-','MarkerSize',4)
axis([UTlim azimerr_lim])
grid on
ylabel('Azi Err (\circ)')
subplot(5,1,5)
plot(abscissa,GPS_Alt,'r.-','MarkerSize',4)
axis([UTlim altkm_lim])
grid on
ylabel('GPS Alt (km)')
xlabel('UTC(hrs)')

UTlim=[18.5 18.85];
UTlim=[-inf inf];
deltaT_sec=diff(abscissa)*3600;
figure(80) % scan freq,ave period,rec intvl
orient portrait
set(80,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(4,1,1)
plot(abscissa,ScanFreq,'b.')
grid on
set(gca,'ylim',[0 12])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('ScanFreq (Hz)','fontsize',16)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(4,1,2)
plot(abscissa,AvePeriod,'g.')
grid on
set(gca,'ylim',[0 4],'ytick',[0:1:4])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('AvePeriod (sec)','fontsize',16)
subplot(4,1,3)
plot(abscissa,RecInterval,'r.')
grid on
set(gca,'ylim',[0 6],'ytick',[0:2:6])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('RecInterval (sec)','fontsize',16)
subplot(4,1,4)
plot(abscissa(2:end),deltaT_sec,'k.')
grid on
set(gca,'ylim',[0 6],'ytick',[0:2:6])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('Delta T (sec)','fontsize',16)
xlabel('Laptop Time (hr)','fontsize',16)

UTlim=[18.5 18.85];
UTlim=[-inf inf];
abscissa_can=UT_Can;
deltaT_sec=diff(abscissa_can)*3600;
figure(801) % scan freq,ave period,rec intvl
orient portrait
set(80,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(4,1,1)
plot(abscissa_can,ScanFreq,'b.')
grid on
set(gca,'ylim',[0 12])
set(gca,'ylim',[0 12])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('ScanFreq (Hz)','fontsize',16)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(4,1,2)
plot(abscissa_can,AvePeriod,'g.')
grid on
set(gca,'ylim',[0 4],'ytick',[0:1:4])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('AvePeriod (sec)','fontsize',16)
subplot(4,1,3)
plot(abscissa_can,RecInterval,'r.')
grid on
set(gca,'ylim',[0 6],'ytick',[0:2:6])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('RecInterval (sec)','fontsize',16)
subplot(4,1,4)
plot(abscissa_can(2:end),deltaT_sec,'k.')
grid on
set(gca,'ylim',[0 6],'ytick',[0:2:6])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
ylabel('Delta TCan(sec)','fontsize',16)
xlabel('Can Time (hr)','fontsize',16)

figure(180)
orient landscape
subplot(2,1,1)
plot(abscissa,Mean_volts(5,:),'g.')
set(gca,'ylim',[8.1 8.4])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
grid on
ylabel('Det. Voltage (520 nm)','fontsize',16)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(2,1,2)
plot(abscissa,Sd_volts(5,:),'k.')
set(gca,'ylim',[0 0.1])
set(gca,'xlim',UTlim)
set(gca,'fontsize',16)
grid on
ylabel('Stdev Det. Voltage(520 nm)','fontsize',16)
xlabel('Laptop Time (hr)','fontsize',16)


figure(179)
altkm_lim179=[0 4];
RHlim=[0 80];
altkm_lim179=[0 5];
RHlim=[0 100];
subplot(2,1,1)
[ax,h1,h2] = plotyy(abscissa,GPS_Alt,abscissa,RH) %,'bo','markersize',4)
set(ax(1),'xlim',UTlim,'ylim',altkm_lim179,'ytick',[altkm_lim179(1):1:altkm_lim179(2)],'fontsize',14,'ycolor','b')
set(h1,'marker','o','color','b')
set(ax(2),'xlim',UTlim','ylim',RHlim,'ytick',[RHlim(1):20:RHlim(2)],'fontsize',14,'ycolor','r')
set(h2,'marker','o','color','r')
grid on
ylabel(ax(1),'GPS Alt (km)','fontsize',16)
ylabel(ax(2),'RH (%)','fontsize',16)
title(sprintf('ACE-Asia Twin Otter    AATS-14 file:%s',filename),'fontsize',14)
subplot(2,1,2)
dGPS_ft=diff(GPS_Alt)*1000*3.2808399;
dZdT_ftpermin=dGPS_ft./Data_Rate*60;
plot(abscissa(1:end-1),dZdT_ftpermin,'bo-','Markersize',4)
axis([UTlim -1000 2000]);
set(gca,'fontsize',14)
grid on
xlabel('UT(hrs)','fontsize',16)
ylabel('Ascent/descent rate (ft/min)','fontsize',16)

stopherenow

figure(12)
% show rate of change in Lat,Long and Press
orient landscape
subplot(4,1,1)
plot(UT(1:end-1),diff(UT*3600),'.')
set(gca,'ylim',[-inf inf])
set(gca,'xlim',[-inf inf])
grid on
xlabel('UT')
ylabel('Data rate (sec)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(4,1,2)
plot(UT(1:end-1),diff(Latitude)./diff(UT))
set(gca,'ylim',[-20 20])
set(gca,'xlim',[-inf inf])
grid on
xlabel('UT')
ylabel('Rate of change (deg/h)')
legend('Latitude')
subplot(4,1,3)
plot(UT(1:end-1),diff(Longitude)./diff(UT))
set(gca,'ylim',[-20 20])
set(gca,'xlim',[-inf inf])
grid on
xlabel('UT')
ylabel('Rate of change (deg/h)')
legend('Longitude')
subplot(4,1,4)
plot(UT(1:end-1),diff(Press_Alt)./diff(UT))
set(gca,'ylim',[-50 50])
set(gca,'xlim',[-inf inf])
xlabel('UT')
ylabel('Rate of change (km/h)')
legend ('Altitude')
grid on

switch source
case 'Laptop_Otter'
    figure(13)
    subplot(4,1,1)
    plot(UT,RH)
    ylabel('RH(%)')
    subplot(4,1,2)
    plot(UT,T_stat)
    ylabel('T stat(\circC)')
    xlabel('UT')
    subplot(4,1,3)
    plot(UT,GPS_Alt,UT,Press_Alt)
    ylabel('z(km)')
    legend('GPS','Pressure')
    subplot(4,1,4)
    plot(UT,GPS_Alt-Press_Alt)
    ylabel('GPS-P_a_l_t(km)')
    set(gca,'ylim',[-0.1 0.1])
    grid on
end

legstr=[];
for i=1:14,
    legstr=[legstr;sprintf('%4d',lambda_AATS14(i))];
end
UTlim=[-inf inf];
Vlim=[0 10];
figure(20)
set(20,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
orient landscape
subplot(2,1,1)
plot(abscissa,Mean_volts)
grid on
ylabel('Signals(V)')
%set(gca,'ylim',[0 10])
axis([UTlim Vlim])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
hleg=legend(legstr)
set(hleg,'FontSize',10)

subplot(2,1,2)
plot(abscissa,Sd_volts./Mean_volts*100)
%set(gca,'ylim',[0 5])
axis([UTlim 0 10])
ylabel('Stdev(%)')
grid on
xlabel('UT (hrs)')
