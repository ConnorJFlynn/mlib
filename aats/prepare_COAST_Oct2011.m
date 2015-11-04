%prepares data for retrievals

%Filter #1, Apply time boundaries UT_start, UT_end
%Filter #2 discard measurement cycles with high standard deviations
%Filter #3 discard measurement cycles with bad tracking (for AATS-14 only) 
%Filter #4 discard measurement cycles with darks or negative voltagesfop
%Changed 11/15/2000 to correct AATS-6 for H2O and O2-O2 (but cross-sections are actually for AATS-14)
%Changed  11/22/2000
% - Filter #2 is disabled
% - allow input of Delta_t
% - read TOMS_overpass data for Oklahoma
% Changed 3/21/2001 for ACE-Asia Data of AATS-14 on Twin Otter
% Changed 4/14/2001 for ACE-Asia Data of AATS-6 on C-130
% Changed Oct 2002 to handle 2002 AATS-14 data

%clear all
%close all

global deltaT Tstat_new RH_new

flag_adj_V0='no';  %yes for 4/13,4/15  'no';%'yes';%'yes'; %yes for spring ARCTAS 'no';%'yes'; %added 2/28/06 jml
flag_use_deltaV0_fieldvalues='no';  %use for Ames January 2008
flag_guess='no';
flag_include_V0errsysaddon='no';%'yes';%'no';  %added option 2/8/2011
flag_fitPvsGPSalt='no'; %use for 3/10/06 flights
flag_relsd_timedep='no'; %set='yes' for a particular day below
sd_crit_aero_smoke=inf; %reset for a particular day below
UT_smoke=[];
flag_LH2O_equal_Lcloud='yes';  %use this for COAST
flag_filterH2O_byAOD865='no';
flag_use_V0meanMayAug08='no'; %set='no' for ARCTAS data
flag_override_relV0errsys='no';%'yes';  %set if want to use values of relV0errsys calculated by JML Feb.2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UT_start=0;%16;
UT_end=inf;
%UT_start=16.;  %use for MLO 
%UT_end=21; %use for MLO

Delta_t_Laptop=0/3600; % (seconds)
%Delta_t_Laptop=-1; % (hours?)


%instrument='AMES14#1_2001' % AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia, CLAMS on CV-580
instrument='AMES14#1_2002'  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron, MLO, Dryden DC-8 testflight, SOLVE-2

%source='NASA_P3'; %use this for ARCTAS field runs
%source='Jetstream31'
%source='Laptop_Otter'  %may/may not work for COAST
source='Laptop_Otter_COAST2011'  %use for COAST October 2011
source='Laptop_DC8_SOLVE2' %--->use this for MLO or Ames?<---
%source='Laptop99'  
%source='Laptop'
%source='Can'

O3_estimate='OFF';%'ON';%'OFF'; %set to OFF for ARCTAS runs
diffuse_corr='OFF';

Result_File='OFF'
archive_GH='ON';%'OFF'; % archive in Gaines & Hipskind format
frost_filter='no'; %for ARCATSspring, this is reset below for each day
dirt_filter = 'no'; %for ARCATSspring, this is reset below for April 19 version 0 of data archival
daystr = '20150908';
% xsect_dir='c:\johnmatlab\AATS14_data_2011\';
% %%data_dir='c:\johnmatlab\AATS14_data_2011\Mauna Loa\'
% data_dir='c:\johnmatlab\AATS14_data_2011\COAST\';  %use for COAST
% data_dir='c:\johnmatlab\AATS14_data_2012\Ames\';   %use for Ames rooftop measurements 2012
xsect_dir='D:\case_studies\AATS\xsect\'; % CJF
data_dir = ['D:\data\4STAR\yohei\4star_data\NASA_Ames_roof\',daystr,'\Ames\'];
Loschmidt=2.686763e19; %molecules/cm2
H2O_conv=1244.12; %converts cm-atm in pr cm or g/cm2.  This has units of [cm^3/g].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%reads cross-sections and data
if strcmp(instrument,'AMES14#1_2002')  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron 
    fid=fopen([xsect_dir 'Ames14#1_2012_05182012.asc']);   %use for MLO May 2012
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    switch source
        case 'Can', 
            [day,month,year,UT,data,Sd_volts,Press_Alt,press,geog_lat,geog_long,...
                    Heading,Temperature,Az_err,Az_pos,Elev_err,Elev_pos,Voltref,Status_window_heater,site,pathname,filename,...
                    RH,H2O_dens_is,GPS_Alt,T_stat]=AATS14_Can_INTEX([data_dir 'e_*.*']);
            UTCan=UT;
        case 'Laptop99',
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,r,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename]=AATS14_Laptop99_239([data_dir 'R?????04.*']);
            UT=Time_Laptop+Delta_t_Laptop;
        case 'Laptop_DC8_SOLVE2'
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename,RH,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_DC8_SOLVE2([data_dir 'R*.*']);
            UT=Time_Laptop+Delta_t_Laptop;
            UTCan=Time_Can;
            if (julian(day, month,year,12) == julian(5,1,2012,12))  %special for Ames 1/5/2012
                UT=UTCan;  
            end
        case 'Laptop_Otter'
            %for files on CIRPAS Twin Otter    
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter([data_dir 'R*.*']);
            UT=Time_Laptop+Delta_t_Laptop;
            UTCan=Time_Can;     
        case 'Laptop_Otter_COAST2011'
            %for files on CIRPAS Twin Otter during COAST October 2011    
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter_COAST2011([data_dir 'R*.*']);
            %UT=Time_Laptop+Delta_t_Laptop;
            UT=Time_Can; %use this for all COAST flights
            UTCan=Time_Can;     
        case {'Jetstream31','NASA_P3'}
            %for files on Jetstream31...essentially the same as AATS14_Laptop_Otter    
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Jetstream31([data_dir 'R?????0?.*']);
            UT=Time_Laptop+Delta_t_Laptop;
            UTCan=Time_Can;  %uncommented 6/19/09 JML
    end

    data=data([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
    Sd_volts=Sd_volts([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
    press=press';
end    

[m,n]=size(data);

%******************************************************sites*************************************************************
if strcmp(instrument,'AMES14#1_2002') 
 NO2_clima=2.0e15/Loschmidt; % atm-cm 
 h=21; %altitude of ozone layer in km
 tau_r_err=0.015;       %relative error
 tau_O3_err=0.05;       %relative error
 tau_NO2_err=0.27;      %relative error
 tau_O4_err=0.12;       %relative error
 tau_H2O_err=0.15;      %relative error  
 a_H2O_err=0.02;        %relative error  
 b_H2O_err=0.02;        %relative error  
 H2O_fit_err=0.1*H2O_conv; % absolute error of H2O fit in atm-cm
 tau_CO2_CH4_N2O_abserr=zeros(m,1);
 tau_CO2_CH4_N2O_abserr(14)=1.0e-04;  %absolute error
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 %================ BEGIN MLO calibration Sept. 2011 =========================
 if julian(day,month,year,12)==julian(23,9,2011,12)
    %wvl_filter=    [353.5    380.0   451.2   499.4   520.4    605.8   675.1   779.1   864.5   940.6   1019.1  1241.3  1558.5  2139.1]
    V0=[ 16.3133	9.6722	8.1825	10.1656	10.5473	6.4014	6.9335	6.3639	7.5375	5.4863	7.7864	7.6139	3.5653	6.2349]; %from 9/23/11 MLO
    V0err_stat=     [ 0.0036  0.0040  0.0151  0.0114   0.0021  0.0039  0.0009  0.0027  0.0013  0.0282  0.0008  0.0025  0.0027  0.0055]; %max(deltamean,relstdev_MA08)
    flag_calib='MLO23Sept-3sd'; 
 end
   
 if julian(day,month,year,12)==julian(24,9,2011,12)
    %wvl_filter=    [353.5    380.0   451.2   499.4   520.4    605.8   675.1   779.1   864.5   940.6   1019.1  1241.3  1558.5  2139.1]
    V0=[16.3408	9.6680	8.1804	10.1560	10.5504	6.4040	6.9348	6.3653	7.5279	5.4794	7.7851	7.6115	3.5632	6.2297]; %from 9/24/11 MLO
    V0err_stat=     [ 0.0036  0.0040  0.0151  0.0114   0.0021  0.0039  0.0009  0.0027  0.0013  0.0282  0.0008  0.0025  0.0027  0.0055]; %max(deltamean,relstdev_MA08)
    flag_calib='MLO24Sept-3sd'; 
 end
 
 if julian(day,month,year,12)==julian(25,9,2011,12)
    %wvl_filter=    [353.5    380.0   451.2   499.4   520.4    605.8   675.1   779.1   864.5   940.6   1019.1  1241.3  1558.5  2139.1]
    V0=[16.4097	9.6636	8.1742	10.1381	10.5411	6.4003	6.9033	6.3655	7.5300	5.4033	7.7926	7.6123	3.5601	6.2313]; %from 9/25/11 MLO
    V0err_stat=     [ 0.0036  0.0040  0.0151  0.0114   0.0021  0.0039  0.0009  0.0027  0.0013  0.0282  0.0008  0.0025  0.0027  0.0055]; %max(deltamean,relstdev_MA08)
    flag_calib='MLO25Sept-3sd'; 
 end
  
 if julian(day,month,year,12)>=julian(26,9,2011,12)
    V0=[16.5210	9.6914	8.1995	10.1580	10.5699	6.4170	6.9437	6.3760	7.5460	5.4823	7.8032	7.6179	3.5485	6.2338]; %from 9/26/11 MLO
    V0err_stat=     [ 0.0036  0.0040  0.0151  0.0114   0.0021  0.0039  0.0009  0.0027  0.0013  0.0282  0.0008  0.0025  0.0027  0.0055]; %max(deltamean,relstdev_MA08)
    flag_calib='MLO26Sept-3sd'; 
 end
 %================ END MLO calibration Sept. 2011 =============================
 
 %%%%%%%%%%%%%%%%%%%%%%%  USE FOLLOWING FOR COAST October 2011   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if julian(day,month,year,12)>=julian(27,9,2011,12)
    V0=[16.396	9.674	8.184	10.154	10.552	6.406	6.929	6.368	7.535	5.470	7.792	7.614	3.559	6.232]; %mean Sept. 2011 MLO
    V0err_stat=     [ 0.0036  0.0040  0.0151  0.0114   0.0021  0.0039  0.0009  0.0027  0.0013  0.0282  0.0008  0.0025  0.0027  0.0055]; %max(deltamean,relstdev_MA08)
    flag_calib='MLOSept2011mean'; 
 end
 
%%%%%%%%%%%%%%%%%%%%%%%% abbreviated 10/18/2011  don't use %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%% following lines were used in creating the original archive data set for INTEX-B %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% 8/30/06:  want to bypass these and use new deltaV0 values  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(flag_use_deltaV0_fieldvalues,'yes')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if (julian(day, month,year,12) == julian(20,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.005 0   -0.021    0.000  0   0.00    0.00    -0.00  0]; %from 3/17 high alt
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
  %           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
 if (julian(day, month,year,12) >= julian(19,4,2008,12))
        deltaV0 = [0.0 0.0 -0.125 0.0 -0.052 0.0 0.0 0.0 0.022 0.0 0.0 0.0 0.006 0.0] %JR based on John's high alt. spectra for this day, no idea what to do about 1558
 end
end

% if strcmp(flag_use_timeinterp_and_Jan06combo,'yes');
%     V0(6)=V0_MLO_Jan06(6)*(1 + deltaV0(6));  %605 nm
%     V0(8)=V0_MLO_Jan06(8)*(1 + deltaV0(8));  %779 nm
% end

 if strcmp(flag_adj_V0,'yes') & strcmp(flag_use_deltaV0_fieldvalues,'yes') & (julian(day, month,year,12) ~= julian(3,3,2006,12))
        V0=V0.*(1+deltaV0);
        %flag_calib=strcat(flag_calib,', adj. using high alt. spectrum');
        if (julian(day, month,year,12) >= julian(18,6,2008,12))
         %flag_calib=strcat(flag_calib,', 521,1240-nm adj using fit');
         flag_calib=strcat(flag_calib,', adj using 6/26 7.3-km fit');
         if strcmp(flag_include_V0errsysaddon,'yes')
             flag_calib=strcat(flag_calib,'; plus V0errsysadj');
         end
        end
 end

 if strcmp(flag_adj_V0,'yes') & strcmp(flag_use_deltaV0_fieldvalues,'no') & strcmp(flag_guess,'no') 
        V0=V0.*(1+deltaV0);
        %flag_calib=strcat(flag_calib,', adj using 8/30/06 deltaV0 factors'); %use for INTEX-B
        if (julian(day, month,year,12) >= julian(13,4,2008,12))
            flag_calib=strcat(flag_calib,', adj. using high alt. spectrum');
        else
            flag_calib=strcat(flag_calib,', adj using 3/27 & 4/1/08 delV0 factors');  %use for ARCTAS spring
        end    
 end

 if strcmp(flag_adj_V0,'yes') & strcmp(flag_guess,'yes') 
        V0=V0.*(1+deltaV0);
        flag_calib=strcat(flag_calib,', adj MLO2006 using guess');
 end

 %set V0err_stat for INTEX-B
 if (julian(day, month,year,12) >= julian(3,3,2006,12)) & (julian(day, month,year,12) <= julian(20,3,2006,12))
   %V0err_stat= [0.5 	0.5 	0.5 	0.5 	0.5 	0.5     0.5 	0.5 	0.5 	2.5     0.5 	0.5 	0.5 	0.5]/100; %pure fiction...%0.5% all wvl except 2.5% for 940 nm
   V0err_stat= [0.12 	0.43 	0.19 	0.06 	0.20 	0.21     0.08 	0.20 	0.24 	2.5     0.03 	0.09 	0.38 	0.02]/100; %50% of Jan-May diff except not at 605 and 778 nm
 end
 
 if strcmp(flag_include_V0errsysaddon,'yes')
     %set V0err_sys addon factors; code added 2/8/2011
     V0err_sys_addon = zeros(1,14);
     if (julian(day, month,year,12) >= julian(12,7,2008,12)) & (julian(day, month,year,12) < julian(13,7,2008,12))
         V0err_sys_addon = [0 0 -0.84 0 0 0 -0.62 0 0.30 0 0 0 0 0]/100;
     end
 end
 
 if strcmp(flag_override_relV0errsys,'yes')
     if (julian(day, month,year,12) == julian(22,6,2008,12))
         relV0errsys_max=[ 0.0199  0.0116  0.0016  0.0113  0.0075  0.0048  0.0073  0.0021  0.0036  0.0200  0.0035  0.0010  0.0032  0.0014]; %06\22\2008  run date:15-Feb-2011 22:32:07
     end
     if (julian(day, month,year,12) == julian(12,7,2008,12))
         relV0errsys_max=[ 0.0154  0.0016  0.0135  0.0097  0.0053  0.0018  0.0061  0.0022  0.0026  0.0200  0.0036  0.0067  0.0019  0.0020]; %07\12\2008  run date:15-Feb-2011 22:35:13
     end
 else
       relV0errsys_max=[];  %will handle other days for which there is no input...just in case one forgets to set flag to 'no'
 end
 
 darks=[ 0.00406 0.00064 0.00007 0.00010 0.00003 0.00014 0.00024 0.00016 0.00007 0.00007 0.00010 0.00017 -0.00014 NaN ]; %darks MLO Sept. 2011
 %darks=[ 0.00386  0.00046  0.00043  0.00051  0.00048  0.00055  0.00067  0.00057  0.00043  0.00048  0.00056   0.00057  -0.00051  NaN  ]; %darks MLO Feb 2008
% old wvls   354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
 V0err_sys=  [0.4     0.16    0.16    0.13    0.13    0.18	 0.15    0.1      0.05    2.0      0.03    0.10     0.1     0.1   ]/100;%Sytematic Error of a Langley	
 if strcmp(flag_include_V0errsysaddon,'yes')
     V0err_sys = V0err_sys + abs(V0err_sys_addon);  %line added 2/8/2011
 end
 if strcmp(flag_override_relV0errsys,'yes') & ~isempty(relV0errsys_max)
     V0err_sys = relV0errsys_max;
 end
 %NOTE: 10/18/2011 need to calculate new slopes
 slope=     [2       0.5     1       0.7     1       0.5     0.9     2        0.5     1        0.5     1       2.5      2]/100;  % per deg from John's estimate of MLO Nov 2002 FOVs
 dV=        [0.006   0.006   0.006   0.006   0.006   0.006   0.006   0.006    0.006   0.006    0.006   0.006   0.006    0.010 ]; %Uncertainty in Voltage
 wvl_aero=  [1       1       1       1       1       1       1       1        1       0        1       1       0        1     ]; %don't use 1558 for COAST
 wvl_aero=  [1       1       1       1       1       1       1       1        1       0        1       1       1        1     ]; %use 1558 for Ames Jan 2012
 wvl_chapp= [1       1       1       1       1       1       1       1        1       0        1       1       1        1     ]; 
 wvl_water= [0       0       0       0       0       0       0       0        0       1        0       0       0        0     ];
 track_err_crit=1; %[DEG, do not make this number inf] 
 V0err=(V0err_stat.^2+V0err_sys.^2).^0.5;
 degree=2; %degree of aerosol fit in log-log space
 
alpha_min_lowalt=-inf;
flag_OMI_substitute='no';
switch lower(site)
    case 'ames',
        geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42 ;id_model_atm=2;
        r=ones(1,n)*0.020; temp=ones(n,1)*298.0;press=ones(n,1)*1013.25;
        GPS_Alt=r;
        Press_Alt=r;
        O3_col_start=0.287;
        m_aero_max=15
        tau_aero_limit=5
        sd_crit_H2O=0.1;
        sd_crit_aero=0.05;
        sd_crit_aero_highalt=inf;%0.001;
        zGPS_highalt_crit=3.9;
        alpha_min=.5;
        tau_aero_err_max=inf
        tempfudge=T_stat';
        zGPS_highalt_crit=12;
        alpha_min_lowalt=-inf;
        if (julian(day, month,year,12) == julian(24,9,2010,12))
            %alpha_min=0.5;
            sd_crit_H2O=0.0032;
            sd_crit_aero=0.0032;
            temp=ones(n,1)*300;  %guess
            press=ones(n,1)*1017;
            O3_col_start=.279; %mean of OMI for 9/23 (283) and 9/25 (274) :
        end
        
    case 'mauna loa',
        geog_long=ones(1,n)*-155.5763 ; geog_lat=ones(1,n)*19.5365; % coordinates measured outside old kitchen bldg
        id_model_atm=1;
        r=ones(1,n)*3.397;temp=ones(n,1)*278.0;
        m_aero_max=inf;
        tau_aero_limit=inf
        alpha_min=-.2;
        tau_aero_err_max=0.05;
        GPS_Alt=r;
        Press_Alt=r;
        tempfudge=T_stat';
        sd_crit_H2O=0.1;
        sd_crit_aero=0.1;
        %sd_crit_aero=0.0026;
        zGPS_highalt_crit=4;
        alpha_min_lowalt=-inf;
        press=ones(n,1)*678.5;
        O3_col_start=.258;
        %O3_col_start=read_TOMS_ovp([data_dir 'TOMS\OVP031.ept'],day,month,year)/1e3;
        if (julian(day, month,year,12) == julian(7,2,2008,12))
            press=ones(n,1)*678;
            O3_col_start=.237;
        elseif julian(day,month,year,12)==julian(23,9,2011,12) | julian(day,month,year,12)==julian(24,9,2011,12)
            press=ones(n,1)*681;
            O3_col_start=.258; %from MLO Dobson 23Sep11
        elseif julian(day,month,year,12)>=julian(25,9,2011,12)
            press=ones(n,1)*681;
            O3_col_start=.262; %from MLO Dobson 25Sep11, 261-263
        end
    case 'arctassummer'
        id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
        tau_aero_err_max=inf;
        r=GPS_Alt;
        track_err_crit_elev=1; %0.005;
        track_err_crit_azim=1;
        O3_col_start=.290;
        temp=T_stat'+273.15;
        m_aero_max=inf;
        tau_aero_limit=inf;
        alpha_min_lowalt=-inf;
        flag_OMI_substitute='no';
        frost_filter='no';
        if (julian(day, month,year,12) == julian(30,6,2008,12))
            alpha_min=0.2;
            sd_crit_H2O=inf;%.05;%0.005;
            sd_crit_aero=inf; %.05;%0.005;
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            %zGPS_highalt_crit=6;
            zGPS_highalt_crit=4; %changed to 4 km 2/16/11
        end
    case 'coast'
        id_model_atm=6; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter,6=U.S. standard atmos.
        tau_aero_err_max=inf;
        r=GPS_Alt;
        track_err_crit_elev=1; %0.005;
        track_err_crit_azim=1;
        O3_col_start=.254; %OMI ozone for 10/17/11 for Marina
        temp=T_stat'+273.15;
        m_aero_max=inf;
        tau_aero_limit=inf;
        alpha_min_lowalt=-inf;
        flag_OMI_substitute='no';
        frost_filter='no';
        alpha_min=0.2;
        sd_crit_H2O=inf;%.05;%0.005;
        sd_crit_aero=inf; %.05;%0.005;
        sd_crit_aero_highalt=0.001;
        zGPS_highalt_crit=4; %changed to 4 km 2/16/11
        if (julian(day, month,year,12) == julian(17,10,2011,12))
            O3_col_start=.254; %OMI ozone for 10/17/11 for Marina
        elseif (julian(day, month,year,12) == julian(22,10,2011,12))
            O3_col_start=.256; %OMI ozone for 10/23/11 for Marina
        elseif (julian(day, month,year,12) == julian(26,10,2011,12))
            O3_col_start=.273; %OMI ozone for 10/26/11 for Marina
            sd_crit_aero=0.0045;
            flag_call_wingglintremoval='yes';
        elseif (julian(day, month,year,12) == julian(27,10,2011,12))
            O3_col_start=.273; %OMI ozone for 10/26/11 for Marina
            sd_crit_aero=0.003;
            zGPS_highalt_crit=1.6; 
            sd_crit_aero_highalt=0.001;
            flag_call_wingglintremoval='no';
        elseif (julian(day, month,year,12) == julian(28,10,2011,12))
            O3_col_start=.273; %OMI ozone for 10/26/11 for Marina
            sd_crit_aero=0.003;
            flag_call_wingglintremoval='yes';
        end
    otherwise, disp('Unknown site')
end

%Adjust for Electronic darks
darks=ones(n,1)*darks;
%this takes into account that the dark at 2138 nm depend on filter temperature 2
%if (julian(day, month,year,12) >= julian(10,1,2008,12)) %
%    darks(:,14)=polyval([0.0001148,-0.0042799,0.0583520],Temperature(10,:)'); %MLO Feb 2008 2nd order fit
%end
if (julian(day, month,year,12) >= julian(23,9,2011,12)) %
    darks(:,14)=polyval([5.2293e-06,-4.8026e-04,1.7506e-02,-1.9378e-01],Temperature(10,:)'); %MLO Sept. 2011 3rd orderfit
end
data=(data'-darks)';
 
 %Filter #1, Apply time boundaries
 L=(UT>=UT_start & UT<=UT_end);
 data=data(:,L);
 Sd_volts=Sd_volts(:,L);
 UT=UT(L);
 UTCan=UTCan(L);
 if ~strcmp(source,'Can') 
     AvePeriod=AvePeriod(L);  
 end
 press=press(L);
 temp=temp(L);
 %tempfudge=tempfudge(L);
 Heading=Heading(L);
 r=r(L);
 GPS_Alt=GPS_Alt(L);
 Press_Alt=Press_Alt(L);
 geog_long=geog_long(L);
 geog_lat =geog_lat (L);
 Elev_err=Elev_err(L);
 Az_err=Az_err(L);
 Elev_pos=Elev_pos(L);
 Az_pos=Az_pos(L);
 Temperature=Temperature(:,L);
 [m,n]=size(data);
 if strcmp(source,'Laptop_Otter') | strcmp(source,'Jetstream31')
     RH=RH(L);
     H2O_dens_is=H2O_dens_is(L);
     %RH_new=RH_new(L);
     %Tstat_new=Tstat_new(L);
 end

 
 %[azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
 [azimuth, altitude, refract]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
 SZA=90-altitude;
 SZA_unrefrac=SZA+refract;  %note that "altitude=altitude+r;" (where r=refract) in routine sun
 clear altitude
 clear azimuth
 end

NO2_col_start=NO2_clima; 

% filter #2 discard measurement cycles with bad tracking
if strcmp(instrument,'AMES14#1') | strcmp(instrument,'AMES14#1_2000') | strcmp(instrument,'AMES14#1_2001')
    L=find(abs(Elev_err)<track_err_crit & abs(Az_err)<track_err_crit);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
    UTCan=UTCan(L);
    if ~strcmp(source,'Can') 
      AvePeriod=AvePeriod(L);  
    end
    SZA=SZA(L);
    press=press(L);
    temp=temp(L);
    r=r(L);
    GPS_Alt=GPS_Alt(L);
    Press_Alt=Press_Alt(L);
    geog_long=geog_long(L);
    geog_lat =geog_lat (L);
    Elev_err=Elev_err(L);
    Az_err=Az_err(L);
    Elev_pos=Elev_pos(L);
    Az_pos=Az_pos(L);
    Temperature=Temperature(:,L);
    if strcmp(source,'Laptop_Otter') | strcmp(source,'Can') | strcmp(source,'Jetstream31')
        RH=RH(L);
        H2O_dens_is=H2O_dens_is(L);
    end
end

% filter #3 discard measurement cycles with darks or negative voltages
 L=all(data(:,:)>0.0);
 data=data(:,L~=0);
 SZA=SZA(L~=0);
 UT=UT(L~=0);
 UTCan=UTCan(L~=0);
 if ~strcmp(source,'Can') 
     AvePeriod=AvePeriod(L);  
 end
 press=press(L~=0);
 temp=temp(L~=0);
 %tempfudge=tempfudge(L~=0);
 Heading=Heading(L);
 Sd_volts=Sd_volts(:,L~=0);
 geog_long=geog_long(L~=0);
 geog_lat =geog_lat (L~=0);
 r=r(L~=0);
 GPS_Alt=GPS_Alt(L~=0);
 Press_Alt=Press_Alt(L~=0);
 Elev_err=Elev_err(L~=0);
 Az_err=Az_err(L~=0);
 Elev_pos=Elev_pos(L~=0);
 Az_pos=Az_pos(L~=0);
 Temperature=Temperature(:,L~=0);
 if strcmp(source,'Laptop_Otter') | strcmp(source,'Can') | strcmp(source,'Jetstream31') 
     RH=RH(L~=0);
     H2O_dens_is=H2O_dens_is(L~=0);
     %RH_new=RH_new(L~=0);
     %Tstat_new=Tstat_new(L~=0);
end
  
% filter #4 discard measurement cycles for which GPS_Alt==NaN for source=='NASA_P3'
if strcmp(source,'NASA_P3')  %added 1 Jul 2008 JML 
 L=~isnan(GPS_Alt);
 data=data(:,L~=0);
 SZA=SZA(L~=0);
 UT=UT(L~=0);
 UTCan=UTCan(L~=0);
 if ~strcmp(source,'Can') 
     AvePeriod=AvePeriod(L);  
 end
 press=press(L~=0);
 temp=temp(L~=0);
 %tempfudge=tempfudge(L~=0);
 Heading=Heading(L);
 Sd_volts=Sd_volts(:,L~=0);
 geog_long=geog_long(L~=0);
 geog_lat =geog_lat (L~=0);
 r=r(L~=0);
 GPS_Alt=GPS_Alt(L~=0);
 Press_Alt=Press_Alt(L~=0);
 Elev_err=Elev_err(L~=0);
 Az_err=Az_err(L~=0);
 Elev_pos=Elev_pos(L~=0);
 Az_pos=Az_pos(L~=0);
 Temperature=Temperature(:,L~=0);
 if strcmp(source,'Laptop_Otter') | strcmp(source,'Can') | strcmp(source,'Jetstream31') | strcmp(source,'NASA_P3') 
     RH=RH(L~=0);
     H2O_dens_is=H2O_dens_is(L~=0);
     %RH_new=RH_new(L~=0);
     %Tstat_new=Tstat_new(L~=0);
 end
end

% Airmasses
m_ray=1./(cos(SZA*pi/180)+0.50572*(96.07995-SZA).^(-1.6364)); %Kasten and Young (1989)
R=6371.229;
m_O3=(R+h)./((R+h)^2-(R+r).^2.*(sin(SZA*pi/180)).^2).^0.5;   %Komhyr (1989)
m_NO2=m_O3;
m_H2O=1./(cos(SZA*pi/180)+0.0548*(92.65-SZA).^(-1.452));   %Kasten (1965)
m_aero=m_H2O;

% compute Sun distance 
f=sundist(day,month,year) ;

% cross sections
n=size(data);
a_SO2=0;
lambda=xsect(:,1)/1000;
a_O3 =xsect(:,3);
a_NO2=xsect(:,4);
a_H2O=xsect(:,5);  % sea level 6 atmospheres retrievals
b_H2O=xsect(:,6);  % sea level 6 atmospheres retrievals
a0_O4=xsect(:,7);
a1_O4=xsect(:,8);
a2_O4=xsect(:,9);
a1_H2O=xsect(:,10);
a2_H2O=xsect(:,11);

if  strcmp(instrument,'AMES14#1_2002')  
   if strcmp(lower(site),'mauna loa')
    a_H2O(wvl_water==1)=0.00499;% overwrite with 3.4 km (Mauna Loa) all tropical atmosphere LBLRTM 12.0  Sept. 2011
    b_H2O(wvl_water==1)=0.6249;  % Sept. 2011
    %a_H2O(wvl_water==1)=0.005254;% overwrite with 3.4 km (Mauna Loa) all 6 atmospheres LBLRTM 6.01 used for ARCTAS
    %b_H2O(wvl_water==1)=0.6221;  % range 0.08-6.59 cm   used for ARCTAS
   end 
    tau_O4=(ones(n(2),1)*a0_O4')'.*exp((ones(n(2),1)*a1_O4')'.*(ones(n(1),1)*r)+(ones(n(2),1)*a2_O4')'.*(ones(n(1),1)*r.^2));
    %correct for absorption by carbon dioxide, methane, and nitrous oxide in 2139-nm channel
    tau_CO2_CH4_N2O=zeros(n(1),n(2));
    %acoeff_CO2_CH4_N2O=[2.070e-03 -2.595e-04 1.411e-05 -5.636e-07 2.166e-08 -4.486e-10]; %from 5th order fit to Livingston LBLRTM runs Oct 2004
    acoeff_CO2_CH4_N2O=[1.770e-03 -2.218e-04 1.205e-05 -4.794e-07 1.834e-08 -3.791e-10]; %from 5th order fit to Livingston LBLRTM12.0 runs Oct. 2011
    for ideg=1:6,
        tau_CO2_CH4_N2O(14,:) = tau_CO2_CH4_N2O(14,:) + acoeff_CO2_CH4_N2O(ideg)*r.^(ideg-1);
    end
end

tau_ray=rayleigh(lambda,press,id_model_atm);
save(['C:\Users\d3k014\Documents\GitHub\4STAR_codes\data_folder\',daystr,'AATS.mat']);