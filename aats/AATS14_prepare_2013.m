%prepares data for retrievals

%Filter #1, Apply time boundaries UT_start, UT_end
%Filter #2 discard measurement cycles with high standard deviations
%Filter #3 discard measurement cycles with bad tracking (for AATS-14 only)
%Filter #4 discard measurement cycles with darks or negative voltages
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

%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%xsect_dir='/Users/meloe/Programs.dir/ReadAATS/ForMLO/InputDataAATS/CrossSectionFile_ForProcess.dir/';
%data_dir='/Users/meloe/Programs.dir/ReadAATS/ForMLO/InputDataAATS/AMES_May2012_05_05/ames/';
xsect_dir='C:\Users\d3k014\Documents\MATLAB\mlib\local\aats\xsect\';
CrossSec_name='Ames14#1_2012_05182012.asc';%'Ames14#1_2008_05142008.asc'(ARCATS-summer),'Ames14#1_2011_09222011.asc'(MLO-Sept2011),'Ames14#1_2012_05182012.asc' (MLO-May2012)
%xsect_dir='c:/johnmatlab/AATS14_data_2011/';
%CrossSec_name='Ames14#1_2011_10182011_final.asc';%'Ames14#1_2008_05142008.asc'(ARCATS-summer),'Ames14#1_2011_09222011.asc'(MLO-Sept2011),'Ames14#1_2012_05182012.asc' (MLO-May2012)
%data_dir='c:/johnmatlab/AATS14_data_2012/Mauna Loa/';
%data_dir='c:/johnmatlab/AATS14_data_2012/Ames/';
%data_dir='c:/johnmatlab/AATS14_data_2013/TCAPS/';
%data_dir='c:/johnmatlab/AATS14_data_2013/Ames/';
%data_dir='c:/johnmatlab/AATS14_data_2013/Palmdale/';
data_dir='D:\data\4STAR\yohei\aats_data\Mauna Loa\';
%Also modify DefineV0Input_MK and DefineO3AndPress_MLO_MK 
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flag_adj_V0='no';  %yes for 4/13,4/15  'no';%'yes';%'yes'; %yes for spring ARCTAS 'no';%'yes'; %added 2/28/06 jml
flag_use_deltaV0_fieldvalues='no';  %use for Ames January 2008
flag_guess='no';
flag_include_V0errsysaddon='no';%'yes';%'no';  %added option 2/8/2011
flag_fitPvsGPSalt='no'; %use for 3/10/06 flights
flag_relsd_timedep='no'; %set='yes' for a particular day below
sd_crit_aero_smoke=inf; %reset for a particular day below
UT_smoke=[];
flag_LH2O_equal_Lcloud='no';
flag_filterH2O_byAOD865='no';
flag_use_V0meanMayAug08='no'; %set='no' for ARCTAS data
flag_override_relV0errsys='no';%'yes';  %set if want to use values of relV0errsys calculated by JML Feb.2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UT_start=0;%16;
UT_end=inf;

NO2_col=[];
Delta_t_Laptop=0/3600; % (seconds)
instrument='AMES14#1_2002'  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron, MLO, Dryden DC-8 testflight, SOLVE-2

% source='NASA_P3';
%source='Laptop_Otter'
source='Laptop_DC8_SOLVE2' %--->use this for MLO or Ames?<---
%source='Can'

O3_estimate='OFF'; %'ON'; %
diffuse_corr='OFF';

Result_File='OFF'
archive_GH='OFF';%'OFF'; % archive in Gaines & Hipskind format
frost_filter='no'; %for ARCATSspring, this is reset below for each day
dirt_filter = 'no'; %for ARCATSspring, this is reset below for April 19 version 0 of data archival

Loschmidt=2.686763e19; %molecules/cm3
H2O_conv=1244.12; %converts cm-atm in pr cm or g/cm2.  This has units of [cm^3/g].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%reads cross-sections and data
if strcmp(instrument,'AMES14#1_2002')  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron
    %     fid=fopen([xsect_dir 'Ames14#1_2008_05142008.asc']);   %use for summer ARCTAS
    fid=fopen([xsect_dir CrossSec_name]);
    
    %MK-Cross section file for absorption coefficients for gases
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    switch source
        %         case 'Can',
        %             [day,month,year,UT,data,Sd_volts,Press_Alt,press,geog_lat,geog_long,...
        %                 Heading,Temperature,Az_err,Az_pos,Elev_err,Elev_pos,Voltref,Status_window_heater,site,pathname,filename,...
        %                 RH,H2O_dens_is,GPS_Alt,T_stat]=AATS14_Can_INTEX([data_dir 'e_*.*']);
        %             UTCan=UT;
        %         case 'Laptop99',
        %             [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,r,press,Heading,data,...
        %                 Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
        %                 filename]=AATS14_Laptop99_239([data_dir 'R?????04.*']);
        %             UT=Time_Laptop+Delta_t_Laptop;
        case 'Laptop_DC8_SOLVE2'
            if (iconf==1)
                filename_in=[];
                pathname_in=[data_dir 'R*.*'];
            end
            
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                pathname_in,filename_in,RH,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_DC8_SOLVE2_MK(pathname_in,filename_in,iconf);
            UT=Time_Laptop+Delta_t_Laptop;
            UTCan=Time_Can;
            %         case 'Laptop_Otter'
            %             %for files on CIRPAS Twin Otter
            %             [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
            %                 Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
            %                 filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter([data_dir '?????_R?????0?.*']);
            %         case {'Jetstream31','NASA_P3'}
            %             %for files on Jetstream31...essentially the same as AATS14_Laptop_Otter
            %             [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
            %                 Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
            %                 filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Jetstream31([data_dir 'R?????0?.*']);
            %             UT=Time_Laptop+Delta_t_Laptop;
            %             UTCan=Time_Can;  %uncommented 6/19/09 JML
    end
    if (day==30 & month==4 & year==2003)
        Delta_t_Laptop=-3/3600; % (seconds) Aerosol IOP Apr 30 , 2003 CIR1
    end
    
    data=data([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
    Sd_volts=Sd_volts([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
    press=press';
end

[m,n]=size(data);

%******************************************************sites*************************************************************
if strcmp(instrument,'AMES14#1_2002')
    %NO2_clima=2.0e15/Loschmidt; % atm-cm
    NO2_col_default=2.0e15; %molec/cm2   
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
    
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
DefineV0Input_MK
    
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    relV0errsys_max=[];  %will handle other days for which there is no input...just in case one forgets to set flag to 'no'
    
    darks=[ 0.00386  0.00046  0.00043  0.00051  0.00048  0.00055  0.00067  0.00057  0.00043  0.00048  0.00056   0.00057  -0.00051  NaN  ]; %darks MLO Feb 2008
    % darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03 checks with June 04...used for INTEXB
    %           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
    V0err_sys=  [0.4     0.16    0.16    0.13    0.13    0.18	 0.15    0.1      0.05    2.0      0.03    0.10     0.1     0.1   ]/100;%Sytematic Error of a Langley
    if strcmp(flag_include_V0errsysaddon,'yes')
        V0err_sys = V0err_sys + abs(V0err_sys_addon);  %line added 2/8/2011
    end
    if strcmp(flag_override_relV0errsys,'yes') & ~isempty(relV0errsys_max)
        V0err_sys = relV0errsys_max;
    end
    slope=     [2       0.5     1       0.7     1       0.5     0.9     2        0.5     1        0.5     1       2.5      2]/100;  % per deg from John's estimate of MLO Nov 2002 FOVs
    dV=        [0.006   0.006   0.006   0.006   0.006   0.006   0.006   0.006    0.006   0.006    0.006   0.006   0.006    0.010 ]; %Uncertainty in Voltage
    wvl_aero=  [1       1       1       1       1       1       1       1        1       0        1       1       1        1     ];
    wvl_chapp= [1       1       1       1       1       1       1       1        1       0        1       1       1        1     ];
    wvl_water= [0       0       0       0       0       0       0       0        0       1        0       0       0        0     ];
    track_err_crit=1; %[DEG, do not make this number inf]
    V0err=(V0err_stat.^2+V0err_sys.^2).^0.5;
    degree=2; %degree of aerosol fit in log-log space
    
    alpha_min_lowalt=-inf;
    flag_OMI_substitute='no';
    switch lower(site)
        case 'palmdale'
            geog_long=ones(1,n)*-118.0729;  %from DC-8 4STAR file
            geog_lat=ones(1,n)*34.6119;   %from DC-8 4STAR file
            r=ones(1,n)*0.7625;
            temp=ones(n,1)*303.0;
            press=ones(n,1)*924.94; %standard pressure in mb for 762.5 m
            id_model_atm=2;
            m_aero_max=inf;
            tau_aero_limit=inf
            alpha_min=-.2;
            tau_aero_err_max=0.05;
            GPS_Alt=r;
            Press_Alt=r;
            tempfudge=T_stat';
            sd_crit_H2O=0.1;
            sd_crit_aero=0.006;%inf; %0.006; %for 12/14/2012
            zGPS_highalt_crit=4;
            alpha_min_lowalt=-inf;

            DefineO3AndPress_SEAC4RS
        case 'houston'
            geog_long=ones(1,n)*-95.1589;
            geog_lat=ones(1,n)*29.6072;         
            r=ones(1,n)*0.009;
            temp=ones(n,1)*303.0;
            press=ones(n,1)*1013; %standard pressure in mb for Houston altitude
            id_model_atm=2;
            m_aero_max=inf;
            tau_aero_limit=inf
            alpha_min=-.2;
            tau_aero_err_max=0.05;
            GPS_Alt=r;
            Press_Alt=r;
            tempfudge=T_stat';
            sd_crit_H2O=0.1;
            sd_crit_aero=inf; %0.006; %for 12/14/2012
            zGPS_highalt_crit=4;
            alpha_min_lowalt=-inf;

            DefineO3AndPress_SEAC4RS
        case 'tcaps'
            %geog_long=ones(1,n)*-70.28;
            %geog_lat=ones(1,n)*41.6694;
            id_model_atm=3; %MidLat Winter atmosphere
            r=Press_Alt;
            GPS_Alt=r;
            temp=ones(n,1)*278;
            m_aero_max=inf;
            tau_aero_limit=inf
            alpha_min=-.2;
            tau_aero_err_max=0.05;
            GPS_Alt=r;
            Press_Alt=r;
            tempfudge=T_stat';
            sd_crit_H2O=0.1;
            sd_crit_aero=.002;%inf;%.002;  %inf to accept all 
            zGPS_highalt_crit=4;
            alpha_min_lowalt=0.4;%-inf;
            O3_col_start=.243;          %DEFAULT VALUE JML Dec 2012 MLO
            
            DefineO3AndPress_TCAPS
            
        case 'ames',
            geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42 ;id_model_atm=2;
            r=ones(1,n)*0.020; temp=ones(n,1)*298.0;press=ones(n,1)*1013.25;
            GPS_Alt=r;
            Press_Alt=r;
            O3_col_start=0.287;
            m_aero_max=15;
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
            
            %-------------------------------------------------------------------------%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Following routine does not exist yet. It is not necessary, but one might wish to create it.
            % If so, it should be analogous to the routine "DefineO3AndPress_MLO_MK.m".  Alternatively, just
            % modify "DefineO3AndPress_MLO_MK.m" and call it.
            
            DefineO3AndPress_Ames    
            
            %-------------------------------------------------------------------------%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
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
            sd_crit_aero=inf;%0.008; %0.006; %for 12/14/2012
            zGPS_highalt_crit=4;
            alpha_min_lowalt=-inf;
            
            
            %-------------------------------------------------------------------------%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            press=ones(n,1)*678.5;      %DEFAULT VALUE -MK
            %O3_col_start=.282;          %DEFAULT VALUE -MK
            O3_col_start=.243;          %DEFAULT VALUE JML Dec 2012 MLO
            
            DefineO3AndPress_MLO_MK
            
%-------------------------------------------------------------------------%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            %         case 'arctassummer'
            %             id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            %             tau_aero_err_max=inf;
            %             r=GPS_Alt;
            %             track_err_crit_elev=1; %0.005;
            %             track_err_crit_azim=1;
            %             O3_col_start=.290;
            %             temp=T_stat'+273.15;
            %             m_aero_max=inf;
            %             tau_aero_limit=inf;
            %             alpha_min_lowalt=-inf;
            %             flag_OMI_substitute='no';
            %             frost_filter='no';
            %             if (julian(day, month,year,12) == julian(22,6,2008,12))
            %                 alpha_min=0;
            %                 sd_crit_H2O=.05;%0.005;
            %                 sd_crit_aero=.004;%0.005;
            %                 O3_col_start=.310; %guess
            %                 tau_aero_err_max=1;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=10;
            %             end
            %             if (julian(day, month,year,12) == julian(23,6,2008,12))
            %                 alpha_min=0;
            %                 sd_crit_H2O=.05;%0.005;
            %                 sd_crit_aero=.05;%0.005;
            %                 O3_col_start=.310; %guess
            %                 tau_aero_err_max=1;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=10;
            %             end
            %             if (julian(day, month,year,12) == julian(24,6,2008,12))
            %                 alpha_min=0;
            %                 sd_crit_H2O=.05;%0.005;
            %                 sd_crit_aero=.05;%0.005;
            %                 O3_col_start=.310; %guess
            %                 tau_aero_err_max=1;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=10;
            %             end
            %             if (julian(day, month,year,12) == julian(25,6,2008,12))
            %                 alpha_min=0;
            %                 sd_crit_H2O=.05;%0.005;
            %                 sd_crit_aero=.05;%0.005;
            %                 O3_col_start=.310; %guess
            %                 tau_aero_err_max=1;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=10;
            %             end
            %             if (julian(day, month,year,12) == julian(26,6,2008,12))
            %                 alpha_min=0.1;
            %                 sd_crit_H2O=.05;%0.005;
            %                 sd_crit_aero=.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=1;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=6;
            %             end
            %             if (julian(day, month,year,12) == julian(27,6,2008,12)) %ground data
            %                 alpha_min=0;
            %                 sd_crit_H2O=.05;%0.005;
            %                 sd_crit_aero=.05;%0.005;
            %                 O3_col_start=.310; %guess
            %                 tau_aero_err_max=1;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=10;
            %             end
            %             if (julian(day, month,year,12) == julian(29,6,2008,12))
            %                 alpha_min=0.2;
            %                 sd_crit_H2O=inf;%0.005;
            %                 sd_crit_aero=inf;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=6;
            %             end
            %             if (julian(day, month,year,12) == julian(30,6,2008,12))
            %                 alpha_min=0.2;
            %                 sd_crit_H2O=inf;%.05;%0.005;
            %                 sd_crit_aero=inf; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 %zGPS_highalt_crit=6;
            %                 zGPS_highalt_crit=4; %changed to 4 km 2/16/11
            %             end
            %             if (julian(day, month,year,12) == julian(2,7,2008,12))
            %                 alpha_min=0.4;%inf;%0.4;
            %                 %alpha_min_lowalt=0.0;%-inf;
            %                 sd_crit_H2O=inf;%0.05;%inf;%.05;%.05;%0.005;
            %                 sd_crit_aero=inf; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=5;
            %                 flag_LH2O_equal_Lcloud='yes';
            %             end
            %             if (julian(day, month,year,12) == julian(3,7,2008,12))
            %                 alpha_min=0.4;
            %                 alpha_min_lowalt=0.4;  %added 2/15/11
            %                 sd_crit_H2O=inf;%.05;%0.005;
            %                 sd_crit_aero=0.02; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=6;
            %                 flag_OMI_substitute='yes';
            %                 imoda_OMI_substitute=0701;
            %                 flag_relsd_timedep='yes';
            %                 UT_smoke=[21.8 23.5];
            %                 sd_crit_aero_smoke=inf;
            %             end
            %             if (julian(day, month,year,12) == julian(6,7,2008,12))
            %                 alpha_min=0.4;
            %                 sd_crit_H2O=inf;%.05;%0.005;
            %                 sd_crit_aero=inf; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=5;
            %                 flag_LH2O_equal_Lcloud='yes';
            %             end
            %             if (julian(day, month,year,12) == julian(7,7,2008,12))
            %                 alpha_min=0.01;%0.024;
            %                 alpha_min_lowalt=0.07;
            %                 sd_crit_H2O=.02;%inf;%0.005;
            %                 sd_crit_aero=.02%inf; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=4.6;
            %             end
            %             if (julian(day, month,year,12) == julian(9,7,2008,12))
            %                 alpha_min=0.0;%0.024;
            %                 alpha_min_lowalt=0.5;
            %                 sd_crit_H2O=inf;%.005;%inf;%0.005;
            %                 sd_crit_aero=0.01; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.01;
            %                 zGPS_highalt_crit=4;
            %                 flag_relsd_timedep='yes';
            %                 UT_smoke=[18.4 20.1];
            %                 sd_crit_aero_smoke=inf;
            %                 flag_filterH2O_byAOD865='yes';
            %                 tau865crit=3;
            %             end
            %             if (julian(day, month,year,12) == julian(10,7,2008,12))
            %                 alpha_min=0.0;%0.024;
            %                 alpha_min_lowalt=-0.1; %uncommented and changed this value to -0.1 on 2/11/2011
            %                 sd_crit_H2O=.005;%inf;%0.005;
            %                 sd_crit_aero=0.01;%0.05; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.001;
            %                 zGPS_highalt_crit=5;
            %                 flag_relsd_timedep='yes';
            %                 UT_smoke=[21.0 21.53];
            %                 sd_crit_aero_smoke=inf;
            %             end
            %             if (julian(day, month,year,12) == julian(12,7,2008,12))
            %                 alpha_min=0.0;%0.024;
            %                 alpha_min_lowalt=-0.5;
            %                 sd_crit_H2O=.005;%inf;%0.005;
            %                 sd_crit_aero=0.01;%0.05; %.05;%0.005;
            %                 O3_col_start=.290; %guess
            %                 tau_aero_err_max=5;
            %                 sd_crit_aero_highalt=0.002;
            %                 zGPS_highalt_crit=6.5;
            %             end
        otherwise, disp('Unknown site')
    end
    
    %Adjust for Electronic darks
    darks=ones(n,1)*darks;
    %this takes into account that the dark at 2138 nm depend on filter temperature 2
    if (julian(day, month,year,12) >= julian(8,11,2002,12))
        darks(:,14)=polyval([1.9652e-6,-8.702e-5,0.0019297,0.022228],Temperature(10,:)');  %3rd order fit
    end
    if (julian(day, month,year,12) >= julian(10,3,2004,12)) %Argus board was changed on that date
        darks(:,14)=polyval([1.3429e-6,-1.8142e-5,8.7526e-5,0.01303],Temperature(10,:)');  %3rd order fit
    end
    if (julian(day, month,year,12) >= julian(10,1,2008,12)) %
        darks(:,14)=polyval([0.0001148,-0.0042799,0.0583520],Temperature(10,:)'); %MLO Feb 2008 2nd order fit
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
    
    %  replace water vapor density calculated from feed (which is incorrect because we were fed Ttot instead of Tstat)
    if strcmp(site,'Aerosol IOP')
        ii= INTERP1(CIR_UT,1:length(CIR_UT),UT,'nearest');
        H2O_dens_is=CIR_H2O_dens(ii);
    end
    
    %[azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    [azimuth, altitude, refract]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    SZA=90-altitude;
    SZA_unrefrac=SZA+refract;  %note that "altitude=altitude+r;" (where r=refract) in routine sun
    clear altitude
    clear azimuth
end

%added by JML 7/25/13
if ~isempty(NO2_col)
    NO2_clima=NO2_col/Loschmidt;
else
    NO2_clima=NO2_col_default/Loschmidt;
end

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
a_O3 =xsect(:,3); %Cross sections will be changed!!! MK-
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
        a_H2O(wvl_water==1)=0.00499;    % before Sept 25 2011: 0.005254
        b_H2O(wvl_water==1)=0.6249;     % before Sept 25 2011: 0.6221 (range 0.08-6.59 cm)
    end
    tau_O4=(ones(n(2),1)*a0_O4')'.*exp((ones(n(2),1)*a1_O4')'.*(ones(n(1),1)*r)+(ones(n(2),1)*a2_O4')'.*(ones(n(1),1)*r.^2));
    %correct for absorption by carbon dioxide, methane, and nitrous oxide in 2139-nm channel
    tau_CO2_CH4_N2O=zeros(n(1),n(2));
    acoeff_CO2_CH4_N2O=[2.070e-03 -2.595e-04 1.411e-05 -5.636e-07 2.166e-08 -4.486e-10]; %from 5th order fit to Livingston LBLRTM runs Oct 2004
    for ideg=1:6,
        tau_CO2_CH4_N2O(14,:) = tau_CO2_CH4_N2O(14,:) + acoeff_CO2_CH4_N2O(ideg)*r.^(ideg-1);
    end
end

tau_ray=rayleigh(lambda,press,id_model_atm);