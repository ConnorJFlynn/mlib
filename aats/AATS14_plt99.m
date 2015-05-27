%file AATS14_plt99.m
%plots raw AATS-14 data for Dryden June 1999 or later deployment
% changed 5/9/2000 to fix date rollover
% changed 8/20/2000 to allow start and end time
clear
close all

UT_start=0
UT_end=inf

Map_plt='ON';
Map_plt_ICARTT='OFF';
%Delta_t_Laptop=0/3600; % (seconds)
disp(sprintf('%g-%g UT',UT_start,UT_end))

%instrument='AMES14#1'      % AATS-14 mainly ACE-2 and Dryden
%instrument='AMES14#1_2000' % AATS-14 MLO ,SAFARI-2000, MLO October 2000
%instrument='AMES14#1_2001'  % AATS-14 after December 8, 2000, for MLO February 2001, ACE-Asia, CLAMS
instrument='AMES14#1_2002'  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron 
source='Laptop_Otter';
source='Laptop99';
%source='Can'
%source='Laptop_DC8_SOLVE2';

disp(source)

switch instrument
    case 'AMES14#1'
        lambda_AATS14=[380.3   448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5	]
    case 'AMES14#1_2000'
        lambda_AATS14=[ 380   448 453 499  525  605  675  354  779  864  940  1019 1240   1558]; %After March 28, 1999
        data_dir='c:\beat\data\SAFARI-2000\';
    case 'AMES14#1_2001'
        lambda_AATS14=[ 380   448 1060 499  525  605  675  354  779  864  940  1019 1240   1558]; %After Dec 8, 2000
        %data_dir='c:\beat\data\Ames\';
        data_dir='c:\beat\data\ACE-Asia\';
        %data_dir='c:\beat\data\Mauna Loa\';
        %data_dir='c:\beat\data\Everett\';
    case 'AMES14#1_2002'
        lambda_AATS14=[ 380   453 1240 499  520  605  675  354  779  864  940  1019 2138   1558]; %After Dec 8, 2000
        %data_dir='c:\beat\data\Ames\';
        %data_dir='c:\beat\data\Mauna Loa\';
        %data_dir='c:\beat\data\SOLVE2\';
        %data_dir='c:\beat\data\ADAM\';
        %data_dir='c:\beat\data\Aerosol IOP\';
        %data_dir='c:\beat\data\EVE\';
        %data_dir='c:\beat\data\ICARTT\';
        data_dir='c:\beat\data\ALIVE\';
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
                Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,flight_no]=AATS14_Laptop99_239([data_dir 'R??????6.*']);
        
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
                Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,RH,H2O_Dens,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter([data_dir '?????_R???????.*']);
        Delta_t_Laptop=0;
        %ACE-Asia  
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
        
        %ARM Aerosol IOP
        if (day==30 & month==4 & year==2003)
            Delta_t_Laptop=-3/3600; % (seconds) Aerosol IOP Apr 30 , 2003 CIR1
        end
        if (day==6 & month==5 & year==2003)
            Delta_t_Laptop=-1/3600; % (seconds) Aerosol IOP May 6  , 2003 CIR2
        end
        if (day==7 & month==5 & year==2003)
            Delta_t_Laptop=-2/3600; % (seconds) Aerosol IOP May 7 , 2003  CIR3
        end
        if (day==9 & month==5 & year==2003)
            Delta_t_Laptop=-2/3600; % (seconds) Aerosol IOP May 9 , 2003  CIR4
        end
        if (day==12 & month==5 & year==2003)
            Delta_t_Laptop=0/3600; % (seconds) Aerosol IOP May 12 , 2003  CIR5
        end
        if (day==14 & month==5 & year==2003 & flight_no=='CIR06')
            Delta_t_Laptop=-1/3600; % (seconds) Aerosol IOP May 14 , 2003  CIR6
        end
        if (day==14 & month==5 & year==2003 & flight_no=='CIR07')
            Delta_t_Laptop=-1/3600; % (seconds) Aerosol IOP May 14 , 2003  CIR7
        end
        if (day==15 & month==5 & year==2003)
            Delta_t_Laptop=-2/3600; % (seconds) Aerosol IOP May 15 , 2003  CIR8
        end
        if (day==17 & month==5 & year==2003)
            Delta_t_Laptop=0/3600; % (seconds) Aerosol IOP May 17 , 2003  CIR9
        end
        if (day==18 & month==5 & year==2003)
            Delta_t_Laptop=0/3600; % (seconds) Aerosol IOP May 18 , 2003  CIR10
        end
        if (day==20 & month==5 & year==2003)
            Delta_t_Laptop=-1/3600; % (seconds) Aerosol IOP May 20 , 2003  CIR11
        end
        if (day==21 & month==5 & year==2003)
            Delta_t_Laptop=-2/3600; % (seconds) Aerosol IOP May 21 , 2003  CIR12
        end
        if (day==22 & month==5 & year==2003)
            Delta_t_Laptop=-3/3600; % (seconds) Aerosol IOP May 22 , 2003  CIR13
        end
        if (day==25 & month==5 & year==2003)
            Delta_t_Laptop=-5/3600; % (seconds) Aerosol IOP May 25 , 2003  CIR14
        end
        if (day==27 & month==5 & year==2003)
            Delta_t_Laptop=-5/3600; % (seconds) Aerosol IOP May 27 , 2003  CIR15
        end
        if (day==28 & month==5 & year==2003)
            Delta_t_Laptop=-3/3600; % (seconds) Aerosol IOP May 28 , 2003  CIR16
        end
        if (day==29 & month==5 & year==2003)
            Delta_t_Laptop=-3/3600; % (seconds) Aerosol IOP May 29 , 2003  CIR17
        end
        
        % ICARTT 
        if (day==13 & month==5 & year==2004 & flight_no=='JRF01')
            Delta_t_Laptop=7; % Laptop was set to local CA time instead of UT
        end
        %Set UT=Laptop time
        UT=UT_Laptop+Delta_t_Laptop;
     
        
        %This reads in the Twin Otter CABIN files for ADAM
        if strcmp(site,'ADAM')
        [CIR_MT,CIR_UT,CIR_Lat,CIR_Long,CIR_GPS_Alt,CIR_Roll,CIR_Pitch,CIR_Heading,CIR_Tamb,CIR_Tdamb,CIR_RHamb,CIR_Pstatic,...
         CIR_Palt,CIR_Wind_dir,CIR_Wind_Speed,CIR_SST,CIR_TAS,CIR_PCASP_CC,CIR_PCASP_Vol_CC,CIR_CASFWD_CC,CIR_CASFWD_Vol_CC,CIR_H2O_dens]=read_Otter_Cabin_ADAM(data_dir,'');  
                    
          
            figure(15)
            plot(CIR_UT,CIR_Palt,CIR_UT,CIR_GPS_Alt,UT,GPS_Alt)
            legend ('cabfile Palt','cabfile GPS','feed GPS')
            
            figure(16)
            subplot(3,1,1)
            plot(CIR_UT,CIR_Pstatic,UT,Pressure)
            legend ('cabfile Pstat','feed Pstat')
            subplot(3,1,2)
            plot(CIR_UT,CIR_RHamb,UT,RH)
            legend ('cabfile RH','feed RH')
            subplot(3,1,3)
            plot(CIR_UT,CIR_Tamb,UT,T_stat,CIR_UT,CIR_Tdamb)
            legend ('cabfile Tamb','feed T','cabfile Tdamb')
            subplot(4,1,4)
            plot(CIR_UT,CIR_H2O_dens)
            legend('H2O dens')
            
            figure(17)
            subplot(3,1,1)
            plot(CIR_UT,CIR_Lat,UT,Latitude)
            legend ('cabfile lat','feed lat')
            subplot(3,1,2)
            plot(CIR_UT,CIR_Long,UT,Longitude)
            legend ('cabfile lat','feed lat')
            subplot(3,1,3)
            plot(CIR_UT,CIR_Heading,UT,Heading)
            legend ('cabfile Heading','feed Heading')                  
        end

        %This reads in the Twin Otter CABIN files for Aerosol IOP
        if strcmp(site,'Aerosol IOP')
            [CIR_MT,CIR_UT,CIR_Lat,CIR_Long,CIR_GPS_Alt,CIR_Roll,CIR_Pitch,CIR_Heading,CIR_GST,CIR_Tamb,CIR_Tdamb,CIR_RHamb,CIR_Pstatic,...
                    CIR_Palt,CIR_Wind_dir,CIR_Wind_Speed,CIR_GST2,CIR_TAS,CIR_Ws,CIR_Rad_Alt,CIR_Theta,CIR_Thetae,CIR_CNC_CC,CIR_PCASP_CC,...
                    CIR_PCASP_Vol_CC,CIR_CASFWD_CC,CIR_CASFWD_Vol_CC,CIR_FSSP_CC,CIR_FSSP_Vol_CC,CIR_LWC,CIR_H2O_dens]=read_Otter_Cabin(data_dir,''); 
            
            figure(15)
            plot(CIR_UT,CIR_Palt,CIR_UT,CIR_GPS_Alt,CIR_UT,CIR_Rad_Alt,UT,GPS_Alt)
            legend ('cabfile Palt','cabfile GPS','cabfile Rad alt','feed GPS')
            
            figure(16)
            subplot(3,1,1)
            plot(CIR_UT,CIR_Pstatic,UT,Pressure)
            legend ('cabfile Pstat','feed Pstat')
            subplot(3,1,2)
            plot(CIR_UT,CIR_RHamb,UT,RH)
            legend ('cabfile RH','feed RH')
            subplot(3,1,3)
            plot(CIR_UT,CIR_Tamb,UT,T_stat,CIR_UT,CIR_Tdamb)
            legend ('cabfile Tamb','feed T','cabfile Tdamb')
            subplot(4,1,4)
            plot(CIR_UT,CIR_H2O_dens)
            legend('H2O dens')
            
            figure(17)
            subplot(3,1,1)
            plot(CIR_UT,CIR_Lat,UT,Latitude)
            legend ('cabfile lat','feed lat')
            subplot(3,1,2)
            plot(CIR_UT,CIR_Long,UT,Longitude)
            legend ('cabfile lat','feed lat')
            subplot(3,1,3)
            plot(CIR_UT,CIR_Heading,UT,Heading)
            legend ('cabfile Heading','feed Heading')                  
        end  
        
        
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
        H2O_Dens=H2O_Dens(:,L);
        Altitude=GPS_Alt;
        
        
    case 'Laptop_DC8_SOLVE2'
        %for files on DC-8    
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

figure(1)
set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
orient landscape
subplot(5,1,1)
plot(abscissa,Mean_volts)
ylabel('Signals(V)')
%set(gca,'ylim',[0 10])
axis([-inf inf 0 10])
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(5,1,2)
plot(abscissa,Sd_volts./Mean_volts*100)
%set(gca,'ylim',[0 5])
axis([-inf inf 0 5])
ylabel('Stdev(%)')

subplot(5,1,3)
plot(abscissa,Altitude,'k')
%set(gca,'ylim',[0 5])
axis([-inf inf -.1 8])
ylabel('Altitude(km)')

subplot(5,1,4)
plot(abscissa,Latitude,'k')
%set(gca,'ylim',[35 40])
axis([-inf inf -inf inf])
ylabel('Latitude (°)')

subplot(5,1,5)
plot(abscissa,Longitude,'k')
%set(gca,'ylim',[120 140])
axis([-inf inf -inf inf])
ylabel('Longitude(°)')
xlabel('UTC')


figure(2)
%temperatures not connected
orient landscape
subplot(4,1,1)
plot(abscissa,Temperature(7:9,:))
%axis([-inf inf -274 -270])
ylabel('T [°C]')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend('argus','hot PCA','cold PCA')
grid on

subplot(4,1,2)
plot(abscissa,Temperature(11,:))
%axis([-inf inf -60 60])
xlabel('UTC [hrs]')
ylabel('T [°C]')
legend('T stat / cool in')
grid on

subplot(4,1,3)
plot(abscissa,Temperature(12,:))
%axis([-inf inf 0 5000])
xlabel('UTC [hrs]')
ylabel('[m]')
legend('GPS alt./cool out')
grid on

subplot(4,1,4)
plot(abscissa,Temperature(15,:))
%axis([-inf inf 0 100])
xlabel('UTC [hrs]')
ylabel('RH[%]')
legend('RH / pwr supply')
grid on

figure(3)
%temperatures sorted
orient landscape
subplot(5,1,1)
plot(abscissa,Temperature([1,2],:))
%axis([-inf inf 43 46])
grid on
ylabel('T [°C]')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend('hot detector plate #1','hot detector plate #2')

subplot(5,1,2)
plot(abscissa,Temperature([5,6],:))
%axis([-inf inf -1 1])
set(gca,'ylim',[-1.5 0.5])
grid on
ylabel('T [°C]')
legend('cold detector #1','cold detector #2')

subplot(5,1,3)
plot(abscissa,Temperature([3,10],:))
%axis([-inf inf 30 45])
grid on
ylabel('T [°C]')
legend('filter plate #1','filter plate #2')

subplot(5,1,4)
plot(abscissa,Temperature([4,13,14],:))
%axis([-inf inf 0 60])
grid on
ylabel('T [°C]')
legend('electronics can','data CPU','trk CPU')

subplot(5,1,5)
plot(abscissa,Pressure)
set(gca,'ylim',[400 1050])
grid on
ylabel('p')

figure(4)
%flight track
orient landscape
subplot(1,2,1)
plot3(Longitude,Latitude,Altitude)
hold on
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
lon_rng = deg2km(distance(lat(1),lon(1),lat(1),lon(2)))
lat_rng = deg2km(distance(lat(1),lon(1),lat(2),lon(1)))

subplot(1,2,2)
plot(Longitude,Latitude)
hold on
if strcmp(site,'SAFARI-2000')
    %plot(29.4568,-23.8643,'ro','MarkerSize',7,'MarkerFaceColor','r') % Pietersburg Cimel Holben Spreadsheet
    %plot(31.5927,-24.97,'ro','MarkerSize',7,'MarkerFaceColor','r') %  Skukuza Airport RSA  Cimel Helmlinger GPS
    %plot(31.5850,-24.9720,'mo','MarkerSize',7,'MarkerFaceColor','m') % Skukuza Airport RSA MPL-net
    %plot(31.3697,-25.0198,'go','MarkerSize',7,'MarkerFaceColor','g') % Skukuza Tower , RSA Helmlinger GPS
    %plot(31.5833,-24.9833,'yo','MarkerSize',7,'MarkerFaceColor','y') % Skukuza, RSA  Cimel Holben Spreadsheet
    %plot(28.3167,-28.2333,'ko','MarkerSize',7)                       % Betlehem Cimel Holben Spreadsheet
    %plot(32.9050,-26.041,'ko','MarkerSize',7,'MarkerFaceColor','k') % Inhaca Island Cimel Aeronet
    %plot(24.7948,-14.7926,'go','MarkerSize',7,'MarkerFaceColor','g') % Kaoma, Zambia Cimel Holben Spreadsheet
    %plot(28.6585,-12.9937,'bo','MarkerSize',7,'MarkerFaceColor','b') % Ndola, Zambia Cimel Holben Spreadsheet
    %plot(26.8208,-12.2812,'yo','MarkerSize',7,'MarkerFaceColor','y') % Solwezi, Zambia Cimel Holben Spreadsheet
    %plot(24.4307,-11.7400,'co','MarkerSize',7,'MarkerFaceColor','c') % Mwinilunga, Zambia Cimel Holben Spreadsheet
    %plot(23.1078,-13.5336,'mo','MarkerSize',7,'MarkerFaceColor','m') % Zambezi, Zambia Cimel Holben Spreadsheet
    %plot(23.1500,-15.2500,'rs','MarkerSize',7,'MarkerFaceColor','r') % Mongu Cimel and Lidar, Zambia  Holben Spreadsheet
    %plot(23.2500,-15.4333,'gs','MarkerSize',7,'MarkerFaceColor','g') % Mongu Tower Cimel, Zambia  Holben Spreadsheet
    %plot(23.2977,-16.1115,'bs','MarkerSize',7,'MarkerFaceColor','b') % Senanga Cimel, Zambia  Holben Spreadsheet
    %plot(25.1500,-17.8167,'ks','MarkerSize',7,'MarkerFaceColor','k') % Kasane, Zambia WMO Station
    %plot(23.5500,-19.8833,'ys','MarkerSize',7,'MarkerFaceColor','y') % Maun Tower Cimel, Botswana  Holben Spreadsheet
    %plot(26.0667,-20.5167,'cs','MarkerSize',7,'MarkerFaceColor','c') % Sua Pan Cimel, Botswana  Holben Spreadsheet
    %plot(14.5000,-23.0000,'ms','MarkerSize',7,'MarkerFaceColor','m') % Walvis Bay, Namibia Holben Spreadsheet
    %plot(15.914,-19.175,'rs','MarkerSize',7,'MarkerFaceColor','r') % Etosha Pan, Namibia Holben Spreadsheet
end
if strcmp(site,'Aerosol IOP') | strcmp(site,'ALIVE')
     plot(-97.48,36.60,'ro','MarkerSize',7,'MarkerFaceColor','r') % ARM SGP CF www.arm.gov
end
hold off
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
grid on
%axis([31.5 31.75 -25.1 -24.875])
lon=get(gca,'xlim');
lat=get(gca,'ylim');
lon_rng = deg2km(distance(lat(1),lon(1),lat(1),lon(2)))
lat_rng = deg2km(distance(lat(1),lon(1),lat(2),lon(1)))

axis square
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
    figure(40)
    worldmap([min(Latitude)-.1,max(Latitude)+.1],[min(Longitude)-.1 max(Longitude)+.1],'patch')
    plotm(Latitude,Longitude)
    scaleruler on
    set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
    setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
    hidem(gca)
end

 if strcmp(Map_plt_ICARTT,'ON')
    figure(41)
    lat_Pease=43.0926;
    lon_Pease=-70.8329;
    if julian(day, month,year,0) == julian(12,7,2004,0) 
       lat_ship=[]; %depends on day; set = [] to omit
       lon_ship=[]; %depends on day
    end
    if julian(day, month,year,0) == julian(15,7,2004,0) 
       lat_ship=42.88; %depends on day; set = [] to omit
       lon_ship=-70.6; %depends on day
    end
    if julian(day, month,year,0) == julian(16,7,2004,0) 
       lat_ship=43.05; %depends on day; set = [] to omit
       lon_ship=-70.4; %depends on day
    end
    if julian(day, month,year,0) == julian(17,7,2004,0) 
       lat_ship=43.15; %depends on day; set = [] to omit
       lon_ship=-69.3; %depends on day
    end
    if julian(day, month,year,0) == julian(20,7,2004,0) 
       lat_ship=43.4; %depends on day; set = [] to omit
       lon_ship=-69.4; %depends on day
    end
    if julian(day, month,year,0) == julian(21,7,2004,0) 
       lat_ship=43.4; %depends on day; set = [] to omit
       lon_ship=-69.4; %depends on day
    end
    if julian(day, month,year,0) == julian(23,7,2004,0) 
       lat_ship=[]; %depends on day; set = [] to omit
       lon_ship=[]; %depends on day
    end
    if julian(day, month,year,0) == julian(26,7,2004,0) 
       lat_ship=[43.015]; %depends on day; set = [] to omit
       lon_ship=[-70.57]; %depends on day
    end
    if julian(day, month,year,0) == julian(29,7,2004,0) 
       lat_ship=[42.67]; %depends on day; set = [] to omit
       lon_ship=[-69.75]; %depends on day
    end
    msize=4;
    colorlevels=[0 1 1; 0 0 1; 0 1 0; 1 1 0; 1 .65 .4; 1 0 1;1 0 0;0.8 0.2 0.2;0.5 0.5 0.5;0 0 0]; % cyan,blue,green,yellow,orange,magenta,red,brown,gray
    zcrit=[0.25 0.5:0.5:4];
    worldmap([min(Latitude)-.1,max(Latitude)+.1],[min(Longitude)-.1 max(Longitude)+.2],'patch')
    cm=colormap(colorlevels);
    jp=find(GPS_Alt<=zcrit(1));
    plotm(Latitude(jp),Longitude(jp),'o','color',cm(1,:),'markersize',msize,'markerfacecolor',cm(1,:))
    hold on
    for i=2:length(zcrit),
      jp=find(GPS_Alt>zcrit(i-1) & GPS_Alt<=zcrit(i));
      plotm(Latitude(jp),Longitude(jp),'o','color',cm(i,:),'markersize',msize,'markerfacecolor',cm(i,:))
    end
    jp=find(GPS_Alt>zcrit(end));
    plotm(Latitude(jp),Longitude(jp),'o','color',cm(length(zcrit)+1,:),'markersize',msize,'markerfacecolor',cm(length(zcrit)+1,:))
    set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
    setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
    setm(gca,'fontsize',14,'fontweight','bold')
    setm(gca,'glinestyle','--','glinewidth',1)
    setm(gca,'plabellocation',0.2,'plinelocation',0.2)
    hidem(gca)
    hold on
    plotm(lat_Pease,lon_Pease,'k*','color','k','MarkerSize',8,'MarkerFaceColor','k')
    ht1=textm(lat_Pease,lon_Pease-0.11,'Pease');
    set(ht1,'FontSize',12,'fontweight','bold')
    if ~isempty(lat_ship)
        plotm(lat_ship,lon_ship,'k*','MarkerSize',8,'MarkerFaceColor','k')
        ht2=textm(lat_ship+0.02,lon_ship-0.15,'Ron Brown');
        set(ht2,'FontSize',12,'fontweight','bold')
    end
    xlabel('Longitude (deg W)','fontsize',14)
    scaleruler on
    hsc=handlem('scaleruler');
    %setm(hsc,'Xloc',0.0035,'Yloc',0.7459,'linewidth',2,'fontweight','bold','fontsize',11)

    ylims=get(gca,'ylim');
    ntim=length(Latitude);
    dely=0.02*(ylims(2)-ylims(1));
    for i=1:floor(ntim/10):ntim-ntim/10,
        plotm(Latitude(i),Longitude(i),'+','color','k','markersize',8,'MarkerFacecolor','k')
        ht=textm(Latitude(i)-.02,Longitude(i),sprintf('%5.2f',UT(i)));
        set(ht,'fontsize',12)
    end
    i=floor(i+(ntim-i)/2);
    plotm(Latitude(i),Longitude(i),'+','color','k','markersize',8,'MarkerFacecolor','k')
    ht=textm(Latitude(i)-.02,Longitude(i),sprintf('%5.2f',UT(i)));
    set(ht,'fontsize',12)

    cb=colorbar;
    set(cb,'yticklabel',[zcrit inf],'fontsize',14,'fontweight','bold')
    cbpossav=get(cb,'Position');
    cbpos=cbpossav;
    cbpos(2)=0.23;
    cbpos(3)=0.03;
    cbpos(4)=0.6;
    set(cb,'Position',cbpos)
    xlimits=get(gca,'xlim');
    ylimits=get(gca,'ylim');
    ht2=text(xlimits(2)+0.02*(xlimits(2)-xlimits(1)),ylimits(1)+0.01*(ylimits(2)-ylimits(1)),'Altitude [km]');
    set(ht2,'fontsize',13,'fontweight','bold')
    
    if strcmp(lower(site),'icartt')
        plotm(44,-69,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. A
        textm(43.9,-69.1, sprintf('%s','A'))
        plotm(44,-68,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. B
        textm(43.9,-68.1, sprintf('%s','B'))
        plotm(44,-67,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. C
        textm(43.9,-67.1, sprintf('%s','C'))
        plotm(43,-70,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. D
        textm(42.97,-69.97, sprintf('%s','D'))
        plotm(43,-69,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. E
        textm(42.97,-68.97, sprintf('%s','E'))
        plotm(43,-68,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. F
        textm(42.97,-67.97, sprintf('%s','F'))
        plotm(43,-67,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. G
        textm(42.9,-67.1, sprintf('%s','G'))
        plotm(43,-66,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. H
        textm(42.9,-66.1, sprintf('%s','H'))
        plotm(43,-65,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. I
        textm(42.9,-65.1, sprintf('%s','I'))
        plotm(42,-69,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. J
        textm(41.9,-69.1, sprintf('%s','J'))
        plotm(42,-68,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. K
        textm(41.9,-68.1, sprintf('%s','K'))
        plotm(42,-67,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. L
        textm(41.9,-67.1, sprintf('%s','L'))
        plotm(42,-66,'rs','MarkerSize',8,'MarkerFaceColor','g')   %pt. M
        textm(41.9,-66.1, sprintf('%s','M'))
        plotm(42,-65,'rs','MarkerSize',8,'MarkerFaceColor','r')   %pt. N
        textm(41.9,-65.1, sprintf('%s','N'))
    end
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


figure(7) % signals
orient landscape
set(7,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(2,1,1)
plot(abscissa,Mean_volts(1:7,:))
%set(gca,'ylim',[-0.003 0.003])
%set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
subplot(2,1,2)
plot(abscissa,Mean_volts(8:14,:))
%set(gca,'ylim',[-0.003 0.100])
%set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
xlabel('UTC(hrs)')
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));


figure(8) % dark signals
orient landscape
set(8,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
subplot(3,1,1)
plot(abscissa,Mean_volts(1:7,:))
set(gca,'ylim',[-0.001 0.006])
%set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
legend(num2str(lambda_AATS14(1)),num2str(lambda_AATS14(2)),num2str(lambda_AATS14(3)),num2str(lambda_AATS14(4)),num2str(lambda_AATS14(5)),num2str(lambda_AATS14(6)),num2str(lambda_AATS14(7)));
subplot(3,1,2)
plot(abscissa,Mean_volts(8:14,:))
set(gca,'ylim',[-0.001 0.008])
%set(gca,'ylim',[0 9])
grid on
ylabel('Signals(V)')
xlabel('UTC(hrs)')
legend(num2str(lambda_AATS14(8)),num2str(lambda_AATS14(9)),num2str(lambda_AATS14(10)),num2str(lambda_AATS14(11)),num2str(lambda_AATS14(12)),num2str(lambda_AATS14(13)),num2str(lambda_AATS14(14)));
subplot(3,1,3)
plot(abscissa,Mean_volts(13,:))
set(gca,'ylim',[0.05 0.11])
grid on
ylabel('Signals(V)')
xlabel('UTC(hrs)')
legend(num2str(lambda_AATS14(13)));




figure(9)
orient landscape
subplot(6,1,1)
plot(abscissa,Elev_err,'go-','MarkerSize',4)
axis([-inf inf -1 1])
grid on
ylabel('Elev Err (\circ)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));

subplot(6,1,2)
plot(abscissa,Az_err,'bo-','MarkerSize',4)
axis([-inf inf -1 1])
grid on
ylabel('Azi Err (\circ)')

subplot(6,1,3)
plot(abscissa,Heading,'ko-','MarkerSize',4)
axis([-inf inf 0 360])
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
axis([-inf inf -8 8])
grid on
ylabel('Turning Rate \circ/sec')

subplot(6,1,5)
Elev_Rate=diff(Elev_pos)./Data_Rate;
plot(UT(1:end-1),Elev_Rate,'k-o','MarkerSize',4)
axis([-inf inf -8 8])
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
axis([-inf inf -10 10])
grid on
ylabel('Az. Change \circ/sec')
xlabel('UTC(hrs)')

figure(10)
orient landscape
subplot(4,1,1)
Az_pos(Az_pos==999)=NaN;
Elev_pos(Elev_pos==999)=NaN;
plot(abscissa,mod(Az_pos+Heading,360),'k-',UT,Az_Sun,'r')
set(gca,'ylim',[0 360])
grid on
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
ylabel('Azimuth(\circ)')
legend('AATS-14','Sun')

subplot(4,1,2)
plot(abscissa,mod(Az_pos+Heading,360)-Az_Sun,'-')
grid on
set(gca,'ylim',[-5 5])
ylabel('Difference(°)')

subplot(4,1,3)
plot(abscissa,Elev_pos,'k-',abscissa,Elev_Sun,'r')
set(gca,'ylim',[-5 90])
grid on
ylabel('Elevation (\circ)')
legend('AATS-14','Sun')
subplot(4,1,4)
plot(abscissa,Elev_pos-Elev_Sun,'-')
grid on
ylabel('Difference (°)')
set(gca,'ylim',[-5 5])

switch source
    case {'Laptop_Otter','Laptop99','Laptop_DC8_SOLVE2'}
        figure(11)
        orient landscape
        plot(UT,3600*(UT_Can-UT))
        xlabel('UT from Laptop')
        ylabel('Delta T (sec)')
        title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
end

figure(12)
% show rate of change in Lat,Long and Press
orient landscape
subplot(4,1,1)
plot(UT(1:end-1),diff(UT*3600),'.')
set(gca,'ylim',[-inf inf])
grid on
xlabel('UT')
ylabel('Data rate (sec)')
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(4,1,2)
plot(UT(1:end-1),diff(Latitude)./diff(UT))
set(gca,'ylim',[-20 20])
grid on
xlabel('UT')
ylabel('Rate of change (deg/h)')
legend('Latitude')
subplot(4,1,3)
plot(UT(1:end-1),diff(Longitude)./diff(UT))
set(gca,'ylim',[-20 20])
grid on
xlabel('UT')
ylabel('Rate of change (deg/h)')
legend('Longitude')
subplot(4,1,4)
plot(UT(1:end-1),diff(Altitude)./diff(UT)/60/.3048*1e3)
set(gca,'ylim',[-4000 3000])
xlabel('UT')
ylabel('vertical speed (ft/min)')
legend ('Altitude')
grid on

switch source
    case 'Laptop_Otter'
        figure(13)
        subplot(5,1,1)
        plot(UT,RH)
        ylabel('RH(%)')
        subplot(5,1,2)
        plot(UT,H2O_Dens)
        ylabel('\rho(gcm^-^3)')
        subplot(5,1,3)
        plot(UT,T_stat)
        ylabel('T stat(\circC)')
        xlabel('UT')
        subplot(5,1,4)
        plot(UT,GPS_Alt,UT,Press_Alt)
        xx=get(gca,'xlim');
        ylabel('z(km)')
        legend('GPS','Pressure')
        subplot(5,1,5)
        plot(UT,GPS_Alt-Press_Alt)
        ylabel('GPS-P_a_l_t(km)')
        %set(gca,'xlim',xx)
        set(gca,'ylim',[-0.1 0.1])
        grid on
end
% 
% % find correlation of dark voltage at 2.1 micron and filter block temp
% switch instrument
%     case 'AMES14#1_2002'
%         ii=find(Mean_volts(1,:)<=0.003 & Mean_volts(13,:)<=0.150);
%         figure(14)
%         plot(Temperature(10,ii),Mean_volts(13,ii),'b.')    
%         hold on
%         plot(Temperature(3,ii),Mean_volts(13,ii),'g.')    
%         hold off
%         name = input('Save?','s');
%         %write to file
%         if name=='y'
%             fid=fopen('c:\beat\matlab\dark2138.txt','a');
%             fprintf(fid,'%6.4f %6.4f %6.5f\n', [Temperature(10,ii)',Temperature(3,ii)',Mean_volts(13,ii)']');
%             fclose(fid);
%         end
% end