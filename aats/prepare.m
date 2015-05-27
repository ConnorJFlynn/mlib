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

% clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UT_start=0;
UT_end=inf;
Delta_t_Laptop=0/3600; % (seconds)

%instrument='AMES6'
%Com_Feed='Yes' %  feed

%instrument='AMES14#1'      % AATS-14 mainly ACE-2
%instrument='AMES14#1_2000' % AATS-14 MLO ,SAFARI-2000, MLO October 2000
%instrument='AMES14#1_2001' % AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia, CLAMS on CV-580
instrument='AMES14#1_2002';  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron, MLO, Dryden DC-8 testflight, SOLVE-2

% If not flying use Laptop99 CJF 20091228
%source='Laptop_DC8_SOLVE2'
% source='Laptop_Otter'
source='Laptop99';

%source='Laptop'
% Unless files come straight off can, then use below CJF 20091228
%source='Can'

O3_estimate='OFF' ;
% O3_estimate='ON'
diffuse_corr='OFF';

% Result_File='ON' % With AOD etc.

%Result_File='ACE-2'
Result_File= 'OFF';
Result_File='Trans';

archive_GH='OFF'; % archive in Gaines & Hipskind format

xsect_dir='C:\case_studies\AATS\xsect\'; % CJF
data_dir = 'C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\aats14_4star_stability\ames\'; % CJF
data_dir = 'C:\case_studies\4STAR\ftp.science.arc.nasa.gov\Data\MLO_Aug_2008\AATS\mauna loa\'; % CJF
data_dir = 'C:\case_studies\4STAR\Data\2009\2009_12_23\ames\'; % CJF 2009-12-28
data_dir = 'C:\case_studies\4STAR\data\2012\2012_09_07_4STAR_AATS_tints\Ames\';
% data_dir = getdir([],'AATS');

%data_dir='c:\beat\data\Everett\';
%data_dir='c:\beat\data\SAFARI-2000\';
%data_dir='c:\beat\data\ACE-Asia\';
%data_dir='c:\beat\data\Mauna Loa\';
%data_dir='c:\beat\data\Ames\';
%data_dir='c:\beat\data\SOLVE2\';
%data_dir='c:\beat\data\ADAM\';
%data_dir='c:\beat\data\Aerosol IOP\';
%data_dir='c:\beat\data\EVE\';
%data_dir='c:\beat\data\ICARTT\';
% data_dir='c:\beat\data\ALIVE\';
Loschmidt=2.686763e19; %molecules/cm2
H2O_conv=1244.12; %converts cm-atm in pr cm or g/cm2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%reads cross-sections and data
if strcmp(instrument,'AMES14#1_2002')  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron
%     fid=fopen([xsect_dir 'Ames14#1_2002_09262002.asc']);
fid=fopen([xsect_dir 'Ames14#1_2008_05142008.asc']);
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    switch source
        case 'Can',
            [day,month,year,UT,data,Sd_volts,Press_Alt,press,geog_lat,geog_long,...
                Heading,Temperature,Az_err,Az_pos,Elev_err,Elev_pos,Voltref,Status_window_heater,site,pathname,filename,...
                RH,H2O_dens_is,GPS_Alt,T_stat]=AATS14_Can_SOLVE2([data_dir 'e_*.*']);
        case 'Laptop99',
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,r,press,Heading,data,...
                Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                filename]=AATS14_Laptop99_239(filename);
            UT=Time_Laptop+Delta_t_Laptop;
        case 'Laptop_DC8_SOLVE2'
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                filename,RH,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_DC8_SOLVE2([data_dir 'R*.*']);
            UT=Time_Laptop+Delta_t_Laptop;
        case 'Laptop_Otter'
            %for files on CIRPAS Twin Otter
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter([data_dir '?????_R?????0?.*']);
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
            UT=Time_Laptop+Delta_t_Laptop;
    end
    data=data([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
    Sd_volts=Sd_volts([8 1 2 4:7 9:12 3 14 13],:); % Put channels in order of wavelength
    press=press';
end

if strcmp(instrument,'AMES14#1_2001')  %AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia, CLAMS on CV-580
    fid=fopen([xsect_dir 'Ames14#1_2001_09262002.asc']);
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    switch source
        case 'Can',
            [day,month,year,UT,data,Sd_volts,Press_Alt,press,Latitude,Longitude,...
                Heading,Temperature,Az_err,Az_pos,Elev_err,Elev_pos,Voltref,Status_window_heater,site,pathname,filename]=...
                AATS14_Raw99([data_dir 'e_*.*']);
        case 'Laptop99',
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,r,press,Heading,data,...
                Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                filename]=AATS14_Laptop99_239([data_dir 'R???????.*']);
            UT=Time_Laptop+Delta_t_Laptop;
        case 'Laptop_Otter'
            %for files on CIRPAS Twin Otter starting on 2/27/01
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter([data_dir 'CIR??_R?????01.*']);
            if (day==30 & month==3 & year==2001)
                Delta_t_Laptop=3/3600; % (seconds)  ACE_Asia Mar 30, 2001 CIR00
            end
            if (day==31 & month==3 & year==2001)
                Delta_t_Laptop=4/3600; % (seconds)  ACE_Asia Mar 31, 2001 CIR01
            end
            if (day==1 & month==4 & year==2001)
                Delta_t_Laptop=4/3600; % (seconds)  ACE_Asia Apr 1/2, 2001 CIR02
            end
            if (day==3 & month==4 & year==2001)
                Delta_t_Laptop=5/3600; % (seconds)  ACE_Asia Apr 3/4,2001 CIR03
            end
            if (day==5 & month==4 & year==2001)
                Delta_t_Laptop=6/3600; % (seconds) ACE_Asia Apr 5/6,2001 CIR04
            end
            if (day==8 & month==4 & year==2001)
                Delta_t_Laptop=8/3600; % (seconds) ACE_Asia Apr 8,2001 CIR05
            end
            if (day==9 & month==4 & year==2001)
                Delta_t_Laptop=10/3600; % (seconds) ACE_Asia Apr 9,2001 CIR06
            end
            if (day==11 & month==4 & year==2001)
                Delta_t_Laptop=0/3600; % (seconds) ACE_Asia Apr 11/12,2001 CIR07
            end
            if (day==12 & month==4 & year==2001)
                Delta_t_Laptop=1/3600; % (seconds) ACE_Asia Apr 12/13,2001 CIR08
            end
            if (day==14 & month==4 & year==2001)
                Delta_t_Laptop=1/3600; % (seconds) ACE_Asia Apr 14,2001 CIR09
            end
            if (day==15 & month==4 & year==2001)
                Delta_t_Laptop=3/3600; % (seconds) ACE_Asia Apr 15/16,2001 CIR10
            end
            if (day==17 & month==4 & year==2001)
                Delta_t_Laptop=3/3600; % (seconds) ACE_Asia Apr 17,2001 CIR11
            end
            if (day==18 & month==4 & year==2001)
                Delta_t_Laptop=-1/3600; % (seconds) ACE_Asia Apr 18/19,2001 CIR12
            end
            if (day==19 & month==4 & year==2001)
                Delta_t_Laptop=-1/3600; % (seconds) ACE_Asia Apr 19/20,2001 CIR13
            end
            if (day==22 & month==4 & year==2001)
                Delta_t_Laptop=-3/3600; % (seconds) ACE_Asia Apr 22/23,2001 CIR14
            end
            if (day==25 & month==4 & year==2001)
                Delta_t_Laptop=-5/3600; % (seconds) ACE_Asia Apr 25/26,2001 CIR16
            end
            if (day==26 & month==4 & year==2001)
                Delta_t_Laptop=-2/3600; % (seconds) ACE_Asia Apr 26/27, 2001 CIR17
            end
            if (day==28 & month==4 & year==2001)
                Delta_t_Laptop=0/3600; % (seconds) ACE_Asia Apr 28    , 2001 CIR18
            end
            UT=Time_Laptop+Delta_t_Laptop;
    end
    data=data([8 1 2 4:7 9:12 3 13 14],:); % Put channels in order of wavelength
    Sd_volts=Sd_volts([8 1 2 4:7 9:12 3 13 14],:); % Put channels in order of wavelength
    press=press';
end
if strcmp(instrument,'AMES14#1_2000')
    fid=fopen([xsect_dir 'Ames14#1_2000_01312001.asc']);
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    switch source
        case 'Can',
            [day,month,year,UT,data,Sd_volts,press,r,geog_lat,geog_long,...
                Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_raw(data_dir);
        case 'Laptop99',
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,...
                r,press,Heading,data,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
                Voltref,ScanFreq,AvePeriod,RecInterval,site,filename,flight_no]=AATS14_Laptop99_239([data_dir '????_R???????.*']);
            UT=Time_Laptop;
    end
    data=data([8 1:7 9:14],:); % Put channels in order of wavelength
    Sd_volts=Sd_volts([8 1:7 9:14],:); % Put channels in order of wavelength
    press=press';
end
if strcmp(instrument,'AMES14#1')
    fid=fopen([xsect_dir 'Ames14#1.asc']);
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    switch source
        case 'Can',
            [day,month,year,UT,data,Sd_volts,press,r,geog_lat,geog_long,...
                Temperature,Az_err,Az_pos,Elev_err,Elev_pos,site,path,filename]=Ames14_raw(data_dir);
        case 'Laptop',
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,...
                r,press,Heading,data,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
                ScanFreq,AvePeriod,RecInterval,site,path,filename]=Ames14_Laptop(data_dir);,
            UT=Time_Laptop+10;
        case 'Laptop99',
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,...
                r,press,Heading,data,Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,...
                Voltref,ScanFreq,AvePeriod,RecInterval,site]=AATS14_Laptop99_239(data_dir);
            UT=Time_Laptop;
    end
    press=press';
end
if strcmp(instrument,'AMES6')
    fid=fopen([xsect_dir 'AATS6_xsect_09262002.asc']);
    fgetl(fid);
    fgetl(fid);
    xsect=fscanf(fid,'%f',[11,inf]);
    xsect=xsect';
    fclose(fid);
    [day,month,year,UT_PC,UT_GPS,data,Sd_volts,press,Press_Alt,geog_lat,geog_long,...
        Temperature,Temperature_sd,Az_err,Az_pos,Elev_err,Elev_pos,Elev_pos_sd,Az_pos_sd,Elev_err_sd,...
        Az_err_sd,site,Airmass,AvePeriod,ScanFreq,path,filename,Heading,GPS_Alt,AmbientTempC]=Ames6_Raw([data_dir '?????01.*']);
    UT=UT_PC;
    press=press';
end
[m,n]=size(data);

%******************************************************sites*************************************************************
if strcmp(instrument,'AMES14#1_2002')
    NO2_clima=2.0e15/Loschmidt; % atm-cm
    h=21; %altitude of ozone layer in km
    tau_r_err=0.015;       %relative error
    tau_O3_err=0.10;       %relative error
    tau_NO2_err=0.27;      %relative error
    tau_O4_err=0.12;       %relative error
    tau_H2O_err=0.15;      %relative error
    a_H2O_err=0.02;        %relative error
    b_H2O_err=0.02;        %relative error
    H2O_fit_err=0.1*H2O_conv; % absolute error of H2O fit in atm-cm
    tau_CO2_CH4_N2O_abserr=zeros(m,1);
    tau_CO2_CH4_N2O_abserr(14)=1.0e-04;  %absolute error


    %           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
    if (julian(day, month,year,12) >= julian(4,8,2002,12))
        V0=      [10.8781  11.1807 12.6009 8.3342	 11.4304 6.2985	 7.364	 6.9355	  7.7715 5.4293  8.1389	8.1268	9.3967	9.8848]; %MLO up to Aug 16, 2002
        darks=   [0.000     0.002   0.001  0.000    0.002   0.001   0.002   0.000    0.000  -0.001  0.001  0.001  -0.001   0.017 ];% MLO up to Aug 16, 2002
        flag_calib='MLO Aug02 pre 8/17';
    end
    if (julian(day, month,year,12) >= julian(17,8,2002,12))
        darks   =[ 0.000   0.002   0.001  0.000    0.002  0.001   0.002   0.000    0.000  -0.001    0.001   0.001   -0.001   0.105 ]; % MLO  after Aug 16, 2002, except .105 then at 2138
        V0=      [10.8746	9.8877	8.9464	8.3557	8.9335	6.3072	7.3778	6.9694	7.7856	5.4501   8.1420	 8.1355	  9.4100  9.8935]; % MLO after Aug 16, 2002 changed Rf on 380, 453 and 520 nm
        flag_calib='MLO Aug02 post 8/17';
    end
    if (julian(day, month,year,12) >= julian(17,9,2002,12)) & (julian(day, month,year,12) <= julian(19,9,2002,12))
        %V0=       [11.0314  9.9713  8.9559  8.4047  8.9249  6.3243  7.3360  6.9262  7.9043  5.6372  8.1080  8.1763  9.4561  9.8070 ]; %DC-8 Dryden 9/19/02 calc'd 10/24/02 using plot_re4_AATS14_SOLVE2.m
        %flag_calib='airborne V0 19Sep02 calculated from plotre4AATS14SOLVE2';
        darks   =[ 0.000   0.002   0.001  0.000    0.002  0.001   0.002   0.000    0.000  -0.001    0.001   0.001   -0.001   0.065 ]; % adjusted after Dryden
        %V0=       [11.0314  9.9713  8.9559  8.4047  8.9249  6.3243  7.3360  6.9500  7.9043  5.6372  8.1080  8.1763  9.4900  9.8070 ]; %DC-8 Dryden 9/19/02 calc'd 10/24/02 using plot_re4_AATS14_SOLVE2.m; 778 and 1558 V0 adjusted
        %flag_calib='airborne V0 19Sep02 from plotre4AATS14SOLVE2; 778 & 1558 adjusted';
        V0=      [11.0301  9.9613  8.9497  8.4063  8.9262  6.3265  7.3357  6.9500  7.9043  5.6372  8.1075  8.1768   9.4800  9.8100]; %DC-8 Dryden Sep 19,2002 adjusted airborne cal...
        flag_calib='airborne 19Sep02 adj';
        %V0=      [11.0301  9.9613  8.9497  8.4063  8.9262  6.3265  7.3357  6.9100  7.9043  5.6372  8.1075  8.1768   9.4404  9.7627]; %DC-8 Dryden Sep 19,2002 airborne cal
        %flag_calib='airborne 19Sep02';
    end
    if (julian(day, month,year,12) >= julian(5,11,2002,12))
        V0=   [10.8934	9.8193	8.9662	8.4688	8.9179	6.3449	7.3476	6.9764	7.7648	5.7761	8.1144	8.1062	9.3936	9.8935];  %MLO Nov 02 11/6-11/12 except 2138-nm for 11/6-11/7 before gain resistor change
        darks   =[ 0.000   0.002   0.001  0.000    0.002  0.001   0.002   0.000    0.000  -0.001    0.001   0.001   -0.001   0.101 ]; % MLO  after Aug 16, 2002, except .105 then at 2138
        flag_calib='MLO Nov02 pre 11/8';
    end
    if (julian(day, month,year,12) >= julian(8,11,2002,12))
        V0=   [10.8934	9.8193	8.9662	8.4688	   8.9179	6.3449	7.3476	6.9764	7.7648	5.7761	8.1144	8.1062	9.3936	8.4237]; %MLO Nov 02 11/6-11/12 after 2138-nm gain resistor change
        darks=[ 0.000   0.002   0.001  0.000      0.002    0.001   0.002   0.000    0.000  -0.001    0.001   0.001   -0.001   NaN ]; %after 11/08/02 cal w/new gain resistor dark is computed as a function of filter plate temp
        flag_calib='MLO Nov02 post 11/8';
        V0err_stat= [0.23	 0.46	 0.21	 0.31	 0.11	 0.18	 0.14	 0.21	  0.13	  2.84	   0.14	   0.08	    0.10	0.13  ]/100; %MLO stdev Nov 2002

    end
    if (julian(day, month,year,12) >= julian(10,3,2003,12))
        darks=[ 0.000   0.0020   0.0005  0.000    0.002   0.001   0.001   0.000     0.000  0.000    0.001   0.001   0.000   NaN]; % darks MLO Mar03
        V0=   [10.8841	 9.8126	  9.0159  8.6718   8.9465  6.3599  7.2992  6.9636	 7.7612	5.6421	 8.0798	 8.0512	 9.4248	 8.4795]; %MLO Mar03
        flag_calib='MLO Mar03';
    end
    if (julian(day, month,year,12) >= julian(1,4,2003,12)) %ADAM
        darks=[ 0.000   0.0015    0.0005  0.000    0.0005  0.001   0.001   0.000     0.000  0.000    0.001   0.001   0.000     NaN]; % darks ADAM
        V0=   [10.8841	 9.8126	  9.0159  8.6718   8.9465  6.3599  7.2992  6.9636	 7.7612	5.6421	 8.0798	 8.0512	 9.4248	 8.4795]; %MLO Mar03
        V0err_stat=[0.65	0.80	0.21	0.75	0.41	0.09	0.60	0.18	0.73	0.18	0.39	0.81	0.24	0.06]/100; % 50% of change between mar 03 and July 03 Cals
        flag_calib='MLO Mar03';
    end

    %               354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
    if (julian(day, month,year,12) >= julian(29,4,2003,12)) %ARM IOP
        darks=[ 0.000   0.0015    0.0005  0.000    0.0005  0.001   0.001   0.000     0.000  0.000    0.001   0.001   0.000   NaN]; % darks ADAM
        if (day==30 & month==4 & year==2003)
            V0=   [10.884   9.750 9.000   8.730    8.925  6.360  7.250   6.964	 7.770	5.642	  8.050	   8.020   9.425	 8.470];
            flag_calib='ARM IOP CIR01';
        end
        if (day==6 & month==5 & year==2003)
            V0=   [10.884   9.720 9.000   8.750    8.925  6.360  7.250   6.964	 7.710	5.642	  8.050	   8.020   9.425	 8.470];
            flag_calib='ARM IOP CIR02';
        end
        if ((day==7 | day==9) & month==5 & year==2003)
            V0=   [10.884   9.730 9.000   8.750    8.925  6.360  7.250   6.964	 7.740	5.642	  8.050	   7.999   9.425	 8.470];
            flag_calib='ARM IOP CIR04';
        end
        if (day==12 & month==5 & year==2003)
            V0=   [10.884   9.710 8.990   8.740    8.925  6.360  7.250   6.964	 7.761	5.642	  8.050	   7.999   9.425	 8.470];
            flag_calib='ARM IOP CIR05';
        end
        if (day==14 & month==5 & year==2003)
            V0=   [10.884   9.720 8.990   8.750    8.910  6.360  7.250   6.964	 7.740	5.642	  8.050	   8.010   9.410	 8.470];
            flag_calib='ARM IOP CIR06';
        end
        if ((day==15 | day==17 | day==18)  & month==5 & year==2003)
            V0=   [10.884   9.690 8.990   8.750    8.910  6.360  7.250   6.964	 7.740	5.642	  8.050	   7.999    9.410	 8.470];
            flag_calib='ARM IOP CIR10';
        end
        if ((day==20 | day==21 | day==22)  & month==5 & year==2003)
            V0=   [10.884   9.690 8.990   8.770    8.910  6.360  7.250   6.964	 7.740	5.642	  8.050	   7.999    9.410	 8.470];
            flag_calib='ARM IOP CIR13';
        end
        if ((day==25 | day==27) & month==5 & year==2003)
            V0=   [10.884   9.680 8.990   8.790    8.910  6.360  7.250   6.964	 7.740	5.642	  8.050	   7.999    9.410	 8.470];
            flag_calib='ARM IOP CIR15';
        end
        if ((day==28 | day==29) & month==5 & year==2003)
            V0=   [10.884   9.665 8.990   8.790    8.910  6.360  7.250   6.964	 7.740  5.642	  8.050	   7.975    9.410	 8.470];
            flag_calib='ARM IOP CIR16';
        end
        V0err_stat=[0.65	0.80	0.21	0.75	0.41	0.09	0.60	0.18	0.73	0.18	0.39	0.81	0.24	0.06]/100; % 50% of change between mar 03 and July 03 Cals

    end
    %           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
    if (julian(day, month,year,12) >= julian(14,7,2003,12))
        darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03
        V0=   [10.743	9.656	8.978	8.802	8.873	6.371	 7.211	 6.938	  7.647	 5.662	  8.017	  7.921	    9.380	8.470];%MLO July 03
        flag_calib='MLO July03';
    end
    if (julian(day, month,year,12) >= julian(25,3,2004,12))
        darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03
        V0=   [ 10.9563	9.6904	9.0291	8.9908	9.0563	6.4827	7.2369	7.0243	7.7132	5.5697	8.0307	7.7675	9.3913	8.1031];%MLO March 04
        flag_calib='MLO Mar04';
    end
    if (julian(day, month,year,12) >= julian(29,5,2004,12))
        darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03 checks with June 04
        V0=   [10.8189	9.5218	8.9093	8.9207	8.9667	6.4269	7.1479	6.9788	7.5991	5.5573	7.9509	7.6457	9.2934	8.0788];%MLO June 04
        flag_calib='MLO June04 early';
    end
    if (julian(day, month,year,12) >= julian(2,6,2004,12))
        darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03 checks with June 04
        V0=   [10.9151	9.6006	8.9886	8.9729	9.0117	6.4789	7.2122	7.0341	7.6954	5.6525	8.0299	7.6783	9.3885	8.1271];%MLO June 04
        flag_calib='MLO June04 late';
        V0err_stat=[0.19	0.47	0.23	0.10	0.25	0.03	0.17	0.07	0.12	0.73	0.01	0.58	0.01	0.15]/100; % 50% of change between Mar 04 and June 04 (late) Cals
    end
    if (julian(day, month,year,12) >= julian(8,7,2004,12))
        darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03 checks with June 04
        V0=   [10.955	 9.612	 8.987	 8.942	 8.952	 6.482	 7.175	 7.035	  7.738	 5.628	  8.013	  7.577	    9.428	8.105]; %ICARTT airborne
        flag_calib='ICARTT airborne';
        V0err_stat=[0.19	0.47	0.23	0.10	0.25	0.03	0.17	0.07	0.12	0.73	0.01	0.58	0.01	0.15]/100; % 50% of change between Mar 04 and June 04 (late) Cals
    end
    if (julian(day, month,year,12) >= julian(1,8,2005,12)) 
        V0=   [11.0415	9.5442	8.4345	8.7027	9.1494	6.3734	7.1705	7.2154	7.9337	5.4336	8.0501	6.8482	9.1836	8.1383]; %MLO Aug2005mostlikely from AATS14.xls except at 453 nm
        flag_calib='MLO avgAug05 most likely';  %this includes AATS14.xls mean V0 values except at 453-nm, where I have used value from last day
    end
    if (julian(day, month,year,12) >= julian(10,9,2005,12)) 
        V0=   [11.0439	9.5336	8.1500	8.6000	9.1391	6.3840	7.1677	7.2257	7.9600	5.4207	8.0483	6.7600	9.1800	8.1369];
        V0err_stat=[0.19	0.15	3.49	1.18	0.10	0.13	0.12	0.09	1.57	1.82	0.30	0.51	0.68	0.08]/100; %50% off difference between post and pre-mission or stat error whichever is larger
        flag_calib='ALIVE 10-Sep';  %interpolated, 453, 499, 1240, 1580 adjusted
    end
    if (julian(day, month,year,12) >= julian(11,9,2005,12)) 
        V0=   [11.0441	9.5329	8.1300	8.5700	9.1384	6.3847	7.1675	7.2264	8.0000	5.4199	8.0482	6.780	9.2450	8.1369];
        flag_calib='ALIVE 11-Sep';  %interpolated, 453, 499, 1240, 1580 adjusted
    end
    if (julian(day, month,year,12) >= julian(12,9,2005,12)) 
        V0=   [11.0443	9.5322	8.1100	8.5500	9.1378	6.3853	7.1673	7.2270	7.7900	5.4190	8.0481	6.7602	9.1706	8.1368];
        flag_calib='ALIVE 12-Sep';  %interpolated, 453, 499, 1240, 1580 adjusted
    end
    if (julian(day, month,year,12) >= julian(13,9,2005,12)) 
        V0=   [11.0444	9.5316	8.0500	8.5800	9.1371	6.3860	7.1671	7.2277	7.9700	5.4182	8.0479	6.7553	9.1900	8.1367];
        flag_calib='ALIVE 13-Sep';  %interpolated, 453, 499, 1240, 1580 adjusted
    end
    if (julian(day, month,year,12) >= julian(16,9,2005,12)) 
        V0=   [11.0449	9.5296	7.9300	8.5500	9.1352	6.3880	7.1666	7.2296	7.9700	5.4158	8.0476	6.7400	9.2100	8.1364];
        flag_calib='ALIVE 16-Sep';  %interpolated, 453, 499, 1240, 1580 adjusted
    end
    if (julian(day, month,year,12) >= julian(17,9,2005,12)) 
        V0=   [11.0450	9.5289	7.8700	8.5400	9.1345	6.3886	7.1664	7.2303	7.9400	5.4150	8.0475	6.7500	9.2000	8.1363];
        flag_calib='ALIVE 17-Sep';  %interpolated, 453, 499, 1240, 1580 adjusted
    end
    if (julian(day, month,year,12) == julian(19,9,2005,12)) 
        switch flight_no
            case 'JRF06'
            V0=   [10.8500	9.2000	7.7500	8.3400	9.0950	6.2950	7.1400	7.2000	7.9200	5.4134	8.0000	6.7050	9.1600	8.0900];
            flag_calib='ALIVE 19-Sep JRF06';  %interpolated, 453, 499, 1240, 1580 adjusted
            case 'JRF07'
            V0=   [11.0453	9.5276	7.7800	8.5100	9.1333	6.3900	7.1660	7.2316	7.9800	5.4134	8.0472	6.7259	9.2000	8.1362];
            flag_calib='ALIVE 19-Sep JRF07';  %interpolated, 453, 499, 1240, 1580 adjusted
        end
    end
    if (julian(day, month,year,12) == julian(20,9,2005,12))
        switch flight_no
            case 'JRF08'
                V0=   [11.0455	9.5269	7.7300	8.4900	9.1326	6.3906	7.1659	7.2322	7.9300	5.4126	8.0471	6.7211	9.1700	8.1361];
                flag_calib='ALIVE 20-Sep JRF08';  %interpolated, 453, 499, 1240, 1580 adjusted
            case 'JRF09'
                V0=   [11.0455	9.5269	7.7300	8.4300	9.1326	6.3906	7.1659	7.2322	7.9300	5.4126	8.0471	6.7211	9.1700	8.1361];
                flag_calib='ALIVE 20-Sep JRF09';  %interpolated, 453, 499, 1240, 1580 adjusted
        end
    end
    if (julian(day, month,year,12) == julian(21,9,2005,12))
        switch flight_no
            case 'JRF10'
                V0=   [11.0456	9.5262	7.7000	8.4300	9.1320	6.3913	7.1500	7.2328	7.9500	5.4118	8.0470	6.7162	9.1641	8.1360];
                flag_calib='ALIVE 21-Sep JFR10';  %interpolated, 453, 499, 1240, 1580 adjusted
            case 'JRF11'
                V0=   [11.0456	9.5262	7.66000	8.4100	9.1320	6.3913	7.1500	7.2328	7.9800	5.4118	8.0470	6.7162	9.1641	8.1360];
                flag_calib='ALIVE 21-Sep JFR11';  %interpolated, 453, 499, 1240, 1580 adjusted
        end
    end
    if (julian(day, month,year,12) == julian(22,9,2005,12))
        switch flight_no
            case 'JRF12'
                V0=   [11.0458	9.5256	7.6000	8.400	9.1313	6.3919	7.1655	7.2335	7.9200	5.4110	8.0000	6.7113	9.1300	8.1359];
                flag_calib='ALIVE 22-Sep JFR12';  %interpolated, 453, 499, 1240, 1580 adjusted
            case 'JRF0D'
                V0=   [11.0458	9.5256	7.6000	8.400	9.1313	6.3919	7.1655	7.2335	7.9650	5.4110	8.0000	6.7113	9.1300	8.1359];
                flag_calib='ALIVE 22-Sep JFR0D';  %interpolated, 453, 499, 864, 1019, 1580 adjusted man.
        end
    end
    if (julian(day, month,year,12) >= julian(11,10,2005,12)) %MLO early
        V0=   [11.0489	9.5123	7.4128	8.2995	9.1184	6.4051	7.1619	7.2464	7.9342	5.3948	8.0446	6.6135	9.1490	8.1342]; %This is mean except for 453 and 499 nm where it is first day
        flag_calib='MLO Oct 2005 early';  
    end
    if (julian(day, month,year,12) >= julian(11,10,2005,12)) 
        V0=   [11.0489	9.5123	7.3495	8.2255	9.1184	6.4051	7.1619	7.2464	7.9342	5.3948	8.0446	6.6135	9.1490	8.1342]; %MLO October Mean all days
        flag_calib='MLO Oct 2005 mean';  
    end
    if (julian(day, month,year,12) >= julian(20,1,2006,12)) 
        V0=   [11.0090	9.5623	8.9933	9.1908	9.1128	6.7148	7.1068	7.2623	7.7553	5.4433	8.0351	9.5606	9.1835	8.1190]; %MLO 
        flag_calib='MLO Jan 2006 mean';  
    end
    if (julian(day, month,year,12) >= julian(16,5,2006,12))
        V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	6.7435	7.0949	7.0748	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
        flag_calib='MLO May 2006 mean';   
    end
    if (julian(day, month,year,12) >= julian(9,8,2006,12))
        V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	6.7435	7.0949	7.0000	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
        flag_calib='Ames August 2006, 778 adj';   
    end
    if (julian(day, month,year,12) >= julian(11,8,2006,12))
        V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	6.7435	7.0949	6.9300	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
        flag_calib='Ames August 2006, 778 adj';   
    end
    if (julian(day, month,year,12) >= julian(28,8,2006,12))
        V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	6.7435	7.0949	6.8400	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
        flag_calib='Ames August 2006, 778 adj';   
    end
    if (julian(day, month,year,12) >= julian(29,8,2006,12))
        V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	6.7435	7.0949	6.7000	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
        flag_calib='Ames August 2006, 778 adj';   
    end
    if (julian(day, month,year,12) >= julian(6,9,2006,12))
        V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	6.7435	7.0949	6.6500	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
        flag_calib='Ames August 2006, 778 adj';   
    end
    
    if (julian(day, month,year,12) >= julian(13,2,2008,12))
       flag_calib = 'Mauna Loa mean Feb 2008, exclude 2/7';
       V0 = [11.0199	9.5436	7.8145	8.8571	6.2783	6.2651	7.0234	6.2534	7.5686	3.3473	7.8891	8.7591	8.6966	8.2560]; %MLO
    end
    if (julian(day, month,year,12) >= julian(13,8,2008,12))
       flag_calib = 'Mauna Loa mean Aug 2008';
       V0 = [11.0192	9.5881	4.7877	9.1457	10.5281	6.2783	7.0028	6.2938	7.5910	3.3079	7.9003	8.3262	8.6267	6.3739]; %MLO
    end
%     if (julian(day, month,year,12) >= julian(1,1,2007,12))
%        %lambda  0.3535  0.3800   0.4526   0.4994   0.5194  0.6044 0.6751  0.7784 0.8645   0.9406   1.0191   1.2413   1.5578   2.1393
%         V0=   [10.9824	9.4803	8.9601	9.2013	9.0768	5.65	7.0949	3.500	7.7189	5.1779	8.0300	9.5775	9.1134	8.1223]; %MLO
%         flag_calib='CJF Ames March 2007, 604 778 adj';
%         adj = [1        1.005    0.995    1.0075   1.035    1.175 0.985    1.03  1.007    1        1.0      1        1         1];
%         V0 = V0 ./ adj;
%         flag_calib='CJF Ames March 2007, lotso adj';
%     end
    %           354     380     453     499     520     605     675     779      864     940      1019    1240    1558    2138
    V0err_sys= [0.4     0.16    0.16    0.13    0.13    0.18	0.15    0.1      0.05    2.0      0.03    0.10    0.1     0.1   ]/100;%Systematic Error of a Langley
    slope=     [2       0.5     1       0.7     1       0.5     0.9     2        0.5     1        0.5     1       2.5     2     ]/100;%per deg from John's estimate of MLO Nov 2002 FOVs
    dV=        [0.006   0.006   0.006   0.006   0.006   0.006   0.006   0.006    0.006   0.006    0.006   0.006   0.006   0.010 ]; %Uncertainty in Voltage
    wvl_aero=  [1       1       1       1       1       1       1       1        1       0        1       1       1       1     ];
    wvl_chapp= [1       1       1       1       1       1       1       1        0       0        1       1       0       1     ];
    wvl_water= [0       0       0       0       0       0       0       0        0       1        0       0       0       0     ];
    track_err_crit=1; %[DEG, do not make this number inf]
    V0err=(V0err_stat.^2+V0err_sys.^2).^0.5;
    degree=2; %degree of aerosol fit in log-log space

    switch lower(site)
        case 'ames', geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42 ;id_model_atm=2;
            r=ones(1,n)*0.020; temp=ones(n,1)*298.0;press=ones(n,1)*1013.25;
            GPS_Alt=r;
            Press_Alt=r;
            O3_col_start=.320;
            O3_col_start=.283; % cjf for March 15, 2007 from OMI
            O3_col_start=.266; % cjf for Jan 17, 2008 from Ozone3
            m_aero_max=15
            tau_aero_limit=5
            sd_crit_H2O=inf;
            sd_crit_aero=.01;
            alpha_min=-inf;
            gamma_max=inf;
            tau_aero_err_max=inf;
        case 'mauna loa',
            geog_long=ones(1,n)*-155.5763 ; geog_lat=ones(1,n)*19.5365; % coordinates measured outside old kitchen bldg
            id_model_atm=1;
            r=ones(1,n)*3.397;temp=ones(n,1)*278.0;
            m_aero_max=inf;
            tau_aero_limit=0.04;
            alpha_min=-.5;
            tau_aero_err_max=0.05;
            GPS_Alt=r;
            Press_Alt=r;
            sd_crit_H2O=0.1;
            sd_crit_aero=0.1;
            %O3_col_start=read_TOMS_ovp([data_dir 'TOMS\OVP031.ept'],day,month,year)/1e3;
            O3_col_start=.280;
            if (julian(day, month,year,12) == julian(15,7,2003,12))
                press=ones(n,1)*683;
                O3_col_start=.280;
            end
            if (julian(day, month,year,12) == julian(16,7,2003,12))
                press=ones(n,1)*683;
                O3_col_start=.284;
            end
            if (julian(day, month,year,12) == julian(17,7,2003,12))
                press=ones(n,1)*682;
                O3_col_start=.279;
            end
            if (julian(day, month,year,12) == julian(18,7,2003,12))
                press=ones(n,1)*682;
                O3_col_start=.285;
            end
            if (julian(day, month,year,12) == julian(19,7,2003,12))
                press=ones(n,1)*682;
                O3_col_start=.281;
            end
            if (julian(day, month,year,12) == julian(20,7,2003,12))
                press=ones(n,1)*683;
                O3_col_start=.271;
            end
            if (julian(day, month,year,12) == julian(21,7,2003,12))
                press=ones(n,1)*682;
                O3_col_start=.273;
            end
            if (julian(day, month,year,12) == julian(22,7,2003,12))
                press=ones(n,1)*682;
                O3_col_start=.277;
            end

            if (julian(day, month,year,12) == julian(30,5,2004,12))
                press=ones(n,1)*683;
                O3_col_start=.294;
            end
            if (julian(day, month,year,12) == julian(31,5,2004,12))
                press=ones(n,1)*682;
                O3_col_start=.285;
            end
            if (julian(day, month,year,12) == julian(1,6,2004,12))
                press=ones(n,1)*681;
                O3_col_start=.280;
            end
            if (julian(day, month,year,12) == julian(2,6,2004,12))
                press=ones(n,1)*681;
                O3_col_start=.280;
            end
            if (julian(day, month,year,12) == julian(3,6,2004,12))
                press=ones(n,1)*681;
                O3_col_start=.280;
            end
            if (julian(day, month,year,12) == julian(4,6,2004,12))
                press=ones(n,1)*681;
                O3_col_start=.280;
            end
            if (julian(day, month,year,12) == julian(5,6,2004,12))
                press=ones(n,1)*683;
                O3_col_start=.290;
            end
            if (julian(day, month,year,12) == julian(6,6,2004,12))
                press=ones(n,1)*681;
                O3_col_start=.285;
            end
            if (julian(day, month,year,12) == julian(7,6,2004,12))
                press=ones(n,1)*680;
                O3_col_start=.290;
            end
            if (julian(day, month,year,12) == julian(12,10,2005,12))
                press=ones(n,1)*680;
                O3_col_start=.259;
            end
            if (julian(day, month,year,12) == julian(13,10,2005,12))
                press=ones(n,1)*680;
                O3_col_start=.265;
            end
            if (julian(day, month,year,12) == julian(14,10,2005,12))
                press=ones(n,1)*680.5;
                O3_col_start=.270;
            end
            if (julian(day, month,year,12) == julian(15,10,2005,12))
                press=ones(n,1)*680.5;
                O3_col_start=.270;
            end
            if (julian(day, month,year,12) == julian(17,10,2005,12))
                press=ones(n,1)*680.5;
                O3_col_start=.270;
                sd_crit_aero=0.04
            end
            if (julian(day, month,year,12) == julian(18,10,2005,12))
                press=ones(n,1)*680;
                O3_col_start=.260;
                sd_crit_aero=0.04
            end
            if (julian(day, month,year,12) == julian(19,10,2005,12))
                press=ones(n,1)*679;
                O3_col_start=.255;
                sd_crit_aero=0.04
            end
            if (julian(day, month,year,12) == julian(20,10,2005,12))
                press=ones(n,1)*681;
                O3_col_start=.253;
                sd_crit_aero=0.04
            end
            if (julian(day, month,year,12) == julian(20,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.240;
                sd_crit_aero=0.04
            end
            if (julian(day, month,year,12) == julian(21,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.240;
                sd_crit_aero=0.002
            end
            if (julian(day, month,year,12) == julian(25,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.240;
                sd_crit_aero=0.002
            end
            if (julian(day, month,year,12) == julian(27,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.230;
                sd_crit_aero=0.002
            end
            if (julian(day, month,year,12) == julian(28,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.245;
                sd_crit_aero=0.002
            end
            if (julian(day, month,year,12) == julian(29,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.245;
                sd_crit_aero=0.002
            end
            if (julian(day, month,year,12) == julian(30,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.235;
                sd_crit_aero=0.002
            end
            if (julian(day, month,year,12) == julian(31,1,2006,12))
                press=ones(n,1)*681;
                O3_col_start=.235;
                sd_crit_aero=0.002
            end
        case 'solve2'
            id_model_atm=5; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            sd_crit_H2O=.05;
            sd_crit_aero=.02;
            alpha_min=-inf;
            tau_aero_err_max=inf;
            r=GPS_Alt;
            track_err_crit_elev=1; %0.005;
            track_err_crit_azim=1;
            O3_col_start=.320;
            if (month==12 & day==17) | (month==12 & day==18)
                O3_col_start=.290;  %actual really varies during this flight
                %%sd_crit_aero=0.001;
                id_model_atm=3; %3=midlat winter
            end
            if (month==12 & day==19) | (month==12 & day==20)
                O3_col_start=.260;
                sd_crit_aero=0.005;
                id_model_atm=3; %3=midlat winter
            end
            if (month==01 & day==12)
                idxfix=find((UT>8.632&UT<8.686) | (UT>9.867&UT<9.913) | (UT>10.065&UT<10.126) | (UT>11.818&UT<11.876));
                geog_long(idxfix)=-geog_long(idxfix);
            end
            temp=T_stat'+273.15;
            m_aero_max=inf;
            tau_aero_limit=inf;
        case 'adam'
            id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            sd_crit_H2O=.02;
            sd_crit_aero=.005;
            alpha_min=.1;
            tau_aero_err_max=inf;
            r=Press_Alt;
            track_err_crit_elev=1; %0.005;
            track_err_crit_azim=1;
            O3_col_start=.320;
            temp=T_stat'+273.15;
            m_aero_max=inf;
            tau_aero_limit=inf;
            %read in cabin file data
            [CIR_MT,CIR_UT,CIR_Lat,CIR_Long,CIR_GPS_Alt,CIR_Roll,CIR_Pitch,CIR_Heading,CIR_Tamb,CIR_Tdamb,CIR_RHamb,CIR_Pstatic,...
            CIR_Palt,CIR_Wind_dir,CIR_Wind_Speed,CIR_SST,CIR_TAS,CIR_PCASP_CC,CIR_PCASP_Vol_CC,CIR_CASFWD_CC,CIR_CASFWD_Vol_CC,CIR_H2O_dens]=read_Otter_Cabin_ADAM(data_dir,'');  
            %Use AATS-14 data only when cabin file data available
            if UT_start<CIR_UT(1)
                UT_start=CIR_UT(1)
            end
            if UT_end>max(CIR_UT)
                UT_end=max(CIR_UT)
            end
        case 'eve'
            id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            sd_crit_H2O=.05;
            sd_crit_aero=.005;
            alpha_min=0.05;
            tau_aero_err_max=inf;
            r=GPS_Alt;
            track_err_crit_elev=1; %0.005;
            track_err_crit_azim=1;
            O3_col_start=.320;
            temp=T_stat'+273.15;
            m_aero_max=inf;
            tau_aero_limit=.6;
        case 'aerosol iop'
            id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            sd_crit_H2O=.20;
            sd_crit_aero=.01;
            alpha_min=0.4;
            tau_aero_err_max=5;
            r=GPS_Alt;
            track_err_crit_elev=1; %0.005;
            track_err_crit_azim=1;
            O3_col_start=.282;
            temp=T_stat'+273.15;
            m_aero_max=inf;
            tau_aero_limit=10;
            %read in cabin file data
            [CIR_MT,CIR_UT,CIR_Lat,CIR_Long,CIR_GPS_Alt,CIR_Roll,CIR_Pitch,CIR_Heading,CIR_GST,CIR_Tamb,CIR_Tdamb,CIR_RHamb,CIR_Pstatic,...
                CIR_Palt,CIR_Wind_dir,CIR_Wind_Speed,CIR_GST2,CIR_TAS,CIR_Ws,CIR_Rad_Alt,CIR_Theta,CIR_Thetae,CIR_CNC_CC,CIR_PCASP_CC,...
                CIR_PCASP_Vol_CC,CIR_CASFWD_CC,CIR_CASFWD_Vol_CC,CIR_FSSP_CC,CIR_FSSP_Vol_CC,CIR_LWC,CIR_H2O_dens]=read_Otter_Cabin(data_dir,'');
            %Use AATS-14 data only when cabin file data available
            if UT_start<min(CIR_UT)
                UT_start=min(CIR_UT)
            end
            if UT_end>max(CIR_UT)
                UT_end=max(CIR_UT)
            end
        case 'icartt'
            id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            sd_crit_H2O=0.06;
            sd_crit_aero=0.005;
            alpha_min=1.4;
            O3_col_start=.290;
            tau_aero_err_max=inf;
            r=GPS_Alt;
            track_err_crit_elev=1; %0.005;
            track_err_crit_azim=1;
            temp=T_stat'+273.15;
            m_aero_max=inf;
            tau_aero_limit=2;
            if (julian(day, month,year,12) == julian(15,7,2004,12))
                sd_crit_aero=0.005;
            end
            if (julian(day, month,year,12) == julian(16,7,2004,12))
                sd_crit_aero=0.0025;
            end
            if (julian(day, month,year,12) == julian(17,7,2004,12))
                sd_crit_aero=0.002;
                alpha_min=0.1;
            end
            if (julian(day, month,year,12) == julian(23,7,2004,12))
                sd_crit_aero=0.008;
                alpha_min=0.5;
            end
            if (julian(day, month,year,12) == julian(26,7,2004,12))
                sd_crit_aero=0.0025;
                sd_crit_H2O=0.4;
                alpha_min=0.5;
            end
        case 'alive'
            [J31_UT,J31_RH,J31_H2O_dens]=read_J31NavMetdata_ALIVE(day,month,year); % read in Nav Met file
            id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
            r=GPS_Alt;
            track_err_crit_elev=1; %0.005;
            track_err_crit_azim=1;
            temp=T_stat'+273.15;
            sd_crit_H2O=0.5;
            sd_crit_aero=0.02;
            alpha_min=-inf;
            gamma_max=inf;
            O3_col_start=.290;
            tau_aero_err_max=1;
            m_aero_max=inf;
            tau_aero_limit=7;
            if (julian(day, month,year,12) == julian(10,9,2005,12))
                O3_col_start=.300;
                gamma_max=-.26
            end
            if (julian(day, month,year,12) == julian(11,9,2005,12))
                sd_crit_H2O=0.4;
                sd_crit_aero=0.005;
                alpha_min=-inf;
                gamma_max=-.5
                O3_col_start=.280;
                tau_aero_err_max=1;
             end
            if (julian(day, month,year,12) == julian(12,9,2005,12))
                sd_crit_H2O=0.5;
                sd_crit_aero=0.02;
                alpha_min=-inf;
                gamma_max=-.5
                O3_col_start=.295;
                tau_aero_err_max=1;
             end
            if (julian(day, month,year,12) == julian(13,9,2005,12))
                sd_crit_H2O=.5;
                sd_crit_aero=0.005;
                alpha_min=-inf;
                gamma_max=-.58
                O3_col_start=.265;
                tau_aero_err_max=1;
             end
            if (julian(day, month,year,12) == julian(16,9,2005,12))
                sd_crit_H2O=1;
                sd_crit_aero=0.01;
                alpha_min=-inf;
                O3_col_start=.275;
                tau_aero_limit=inf;
                tau_aero_err_max=inf;
             end
            if (julian(day, month,year,12) == julian(17,9,2005,12))
                sd_crit_H2O=.6;
                sd_crit_aero=0.02;
                alpha_min=.27;
                gamma_max=-.49
                O3_col_start=.260;
                tau_aero_err_max=inf;
             end
            if (julian(day, month,year,12) == julian(19,9,2005,12))
                sd_crit_H2O=.9;
                sd_crit_aero=0.01;
                alpha_min=.59;
                gamma_max=inf
                O3_col_start=.255;
                tau_aero_err_max=inf;
            end
            if (julian(day, month,year,12) == julian(20,9,2005,12))
                switch flight_no
                    case 'JRF08'
                        sd_crit_H2O=.9;
                        sd_crit_aero=0.02;
                        alpha_min=0.6;
                        gamma_max=-0.65
                        O3_col_start=.255;
                    case 'JRF09'
                        sd_crit_H2O=.9;
                        sd_crit_aero=0.0058;
                        alpha_min=0.5;
                        gamma_max=inf
                        O3_col_start=.255;
                end
            end
            if (julian(day, month,year,12) == julian(21,9,2005,12))
                switch flight_no
                    case 'JRF10'
                        sd_crit_H2O=.9;
                        sd_crit_aero=0.004;
                        alpha_min=.35;
                        gamma_max=inf
                        O3_col_start=.240;
                        tau_aero_err_max=inf;
                        tau_aero_limit=2;
                    case 'JRF11'
                        sd_crit_H2O=.9;
                        sd_crit_aero=0.009;
                        alpha_min=.31;
                        gamma_max=inf
                        O3_col_start=.240;
                        tau_aero_err_max=inf;
                        tau_aero_limit=2;
                end
            end
            if (julian(day, month,year,12) == julian(22,9,2005,12))
                switch flight_no
                    case 'JRF12'
                        sd_crit_H2O=inf;
                        sd_crit_aero=0.003;
                        alpha_min=0.3;
                        gamma_max=-0.55
                        O3_col_start=.260;
                        tau_aero_err_max=inf;
                        tau_aero_limit=2;
                    case 'JRF0D'
                        sd_crit_H2O=1.5;
                        sd_crit_aero=0.006;
                        alpha_min=0.3;
                        gamma_max=-0.50
                        O3_col_start=.260;
                        tau_aero_err_max=inf;
                        tau_aero_limit=2;
                end
            end
        otherwise, disp('Unknown site')
    end

    %Adjust for Electronic darks
    darks=ones(n,1)*darks;
    %this takes into account that the dark at 2138 nm depend on filter temperature 2
    if (julian(day, month,year,12) >= julian(8,11,2002,12))
        darks (:,14)=polyval([1.9652e-6,-8.702e-5,0.0019297,0.022228],Temperature(10,:)');
    end
    if (julian(day, month,year,12) >= julian(10,3,2004,12)) %Argus board was changed on that date
        darks (:,14)=polyval([1.3429e-6,-1.8142e-5,8.7526e-5,0.01303],Temperature(10,:)');
    end
    data=(data'-darks)';

    %Filter #1, Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
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
    [m,n]=size(data);
    if strcmp(source,'Laptop_Otter')
        RH=RH(L);
        H2O_dens_is=H2O_dens_is(L);
    end

    %  replace water vapor density calculated from feed (which is incorrect because we were fed Ttot instead of Tstat)
    if strcmp(site,'Aerosol IOP')
        ii= interp1(CIR_UT,1:length(CIR_UT),UT,'nearest');
        H2O_dens_is=CIR_H2O_dens(ii);
    end
    %  replace variables due to bad feed
    if strcmp(site,'ADAM')
        ii= interp1(CIR_UT,1:length(CIR_UT),UT,'nearest');
        press=CIR_Pstatic(ii);
        temp=CIR_Tamb+273.15;
        r=CIR_Palt(ii)';
        Press_Alt=CIR_Palt(ii)';
        GPS_Alt=CIR_GPS_Alt(ii)';
        H2O_dens_is=CIR_H2O_dens(ii);
    end
    %  replace RH and H2O due to incorrect RH feed
    if strcmp(site,'ALIVE')
        ii= interp1(J31_UT,1:length(J31_UT),UT,'nearest','extrap');
        H2O_dens_is=J31_H2O_dens(ii);
        RH=J31_RH(ii);
    end

    [azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    SZA=90-altitude;
    clear altitude
    clear azimuth
end
%******************************************************sites*************************************************************
if strcmp(instrument,'AMES14#1_2001')
    NO2_clima=2.0e15/Loschmidt; % atm-cm
    h=21; %altitude of ozone layer in km
    tau_r_err=0.015;       %relative error
    tau_O3_err=0.10;       %relative error
    tau_NO2_err=0.27;      %relative error
    tau_O4_err=0.12;       %relative error
    tau_H2O_err=0.15;      %relative error
    a_H2O_err=0.02;        %relative error
    b_H2O_err=0.02;        %relative error
    H2O_fit_err=0.1*H2O_conv; % absolute error of H2O fit in atm-cm

    %           354     380     448     499     525     605     675     779      864     940      1019    1060    1240     1558

    if (julian(day, month,year,12) >= julian(2,2,2001,12))
        V0=        [7.5960	 6.7736	 6.4248	 5.6838	 3.9065	 6.7909	 7.4360	 7.0631	  7.5890  7.1455   7.8224  4.1263  6.5686	8.6365];     %MLO mean Feb 3- 7, 2001
        V0err_stat=[0.46	 0.51	 0.39 	 0.42	 0.53	 0.33	 0.31	 0.25	  0.33	  2.35	   0.25	   0.23	   0.38	    0.22  ]/100; %MLO Feb 2001%
    end

    if (strcmp(lower(site),'ace-asia'))
        V0=        [7.5105	 6.6755	 6.4248	 5.6838	 3.8862	 6.75	 7.4360	 7.0631	  7.5890  7.0464   7.8080  4.1194  6.5559	8.6217]; %Ace-Asia 3/30-5/1/2001 interpol Feb June 2001 Langleys
        V0err_stat=[0.95	 1.23	 0.45 	 0.06	 0.44	 1.58	 0.26	 0.02	  0.25	  1.18	   0.16	   0.14	   0.16	    0.15  ]/100; %for ACE-Asia half of the difference pre-post mission cal.
    end

    if (strcmp(lower(site),'ace-asia') & julian(day, month,year,12) >= julian(15,4,2001,12))
        V0=        [7.5105	 6.6755	 6.4248	 5.6838	 3.8862	 6.68	 7.4360	 7.0631	  7.5890  7.0464   7.8080  4.1194  6.5559	8.6217]; %Ace-Asia interpol and 605nm adjusted manually
        V0err_stat=[0.95	 1.23	 0.45 	 0.06	 0.44	 1.58	 0.26	 0.02	  0.25	  1.18	   0.16	   0.14	   0.16	    0.15  ]/100; %for ACE-Asia half of the difference pre-post mission cal.
    end

    if (julian(day, month,year,12) >= julian(30,5,2001,12))
        V0=        [7.4510	 6.6073	 6.3671	 5.6902	 3.8721	 6.5768	 7.3974	 7.0652	  7.5517  6.9775   7.7981  4.1146  6.5470	8.6114];%MLO mean June 2001
        V0err_stat=[0.22    0.16  	 0.07	 0.17 	 0.04	 0.14	 0.25	 0.17	  0.01	  0.68 	   0.05	   0.12    0.05	    0.14  ]/100;%MLO June2002
    end

    if strcmp(lower(site),'clams')
        V0=        [7.3962  6.5337  6.2726  5.6831  3.8403  6.4802  7.3750  7.0461   7.5378  7.1387   7.7727  4.0793  6.5483    8.6241];%avg. of 2001 June and Sept. MLO, omit 9/5 + 9/7
        V0err_stat=[0.74    1.13    1.51    0.12    0.83    1.49    0.30    0.27     0.18    2.26     0.33    0.86    0.02      0.15  ]/100; %Half the range between June and Sept. MLO, omit 9/5+7
    end

    if (julian(day, month,year,12) >= julian(4,9,2001,12))
        V0=        [7.3413	 6.4600	 6.1782	 5.6760	 3.8085	 6.3836	 7.3526	 7.0270	  7.5239  7.3000   7.7473  4.0441  6.5496	8.6368]; %MLO Sep 2001 omit 9/5 + 9/7
        V0err_stat=[0.36	 0.32 	 0.27	 0.22 	 0.17	 0.12	 0.24	 0.10	  0.20	  1.02	   0.22	   0.11	   0.14	    0.15  ]/100; %MLO Sep 2001 omit 9/5 + 9/7 stdev
    end

    darks     =[0.0012  0.0014	 0.0008	 0.0001	 0.0011	 0.0006	 0.0015	-0.0002	  0.0002 -0.0005   0.0012  0.0004  0.0003  -0.0007];% MLO Feb 3, 2001
    V0err_sys= [0.4     0.16     0.16    0.13    0.13    0.18	 0.15    0.1      0.05    2.0      0.03    0.10    0.1      0.1   ]/100;%Sytematic Error of a Langley

    %           354     380     448     499     525     605     675     779      864     940      1019    1060    1240     1558
    slope=     [2       2       2       2       2       2       2       2        2       2        2       2       2        2     ]/100;  % per deg
    dV=        [0.006   0.006   0.006   0.006   0.006   0.006   0.006   0.006    0.006   0.006    0.006   0.006   0.006    0.006 ]; %Uncertainty in Voltage
    wvl_aero=  [1       1       1       1       1       1       1       1        1       0        1       1       1        1     ];
    wvl_chapp= [1       1       1       1       1       1       1       1        1       0        1       0       1        1     ];
    wvl_water= [0       0       0       0       0       0       0       0        0       1        0       0       0        0     ];
    track_err_crit=1; %[DEG, do not make this number inf]
    V0err=(V0err_stat.^2+V0err_sys.^2).^0.5;
    degree=2; %degree of aerosol fit in log-log space

    switch lower(site)
        case 'ames', geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42 ;id_model_atm=2;
            r=ones(1,n)*0.020; temp=ones(n,1)*298.0;press=ones(n,1)*1013.25;
            GPS_Alt=r;
            Press_Alt=r;
            O3_col_start=.320;
            m_aero_max=15
            tau_aero_limit=5
            sd_crit_H2O=inf;
            sd_crit_aero=inf;
            alpha_min=-inf;
            tau_aero_err_max=inf
        case 'mauna loa',
            press=ones(n,1)*680.5;
            geog_long=ones(1,n)*-155.578 ; geog_lat=ones(1,n)*19.539; id_model_atm=1;
            r=ones(1,n)*3.397;temp=ones(n,1)*278.0;
            %O3_col_start=read_TOMS_ovp([data_dir 'TOMS\OVP031.ept'],day,month,year)/1e3;
            O3_col_start=.250;
            m_aero_max=inf;
            tau_aero_limit=inf;
            alpha_min=-inf;
            tau_aero_err_max=0.05;
            GPS_Alt=r;
            Press_Alt=r;
            sd_crit_H2O=0.4;
            sd_crit_aero=0.3
        case 'ace-asia'
            r=GPS_Alt;
            %r=Press_Alt;
            temp=T_stat'+273.15;
            id_model_atm=6;
            O3_col_start=.337;
            sd_crit_aero=0.008;
            sd_crit_H2O=0.06;
            m_aero_max=inf;
            tau_aero_limit=inf;
            tau_aero_err_max=0.05;
            alpha_min=-inf;
        case 'everett',
            id_model_atm=6;
            temp=ones(n,1)*278.0;
            O3_col_start=.380;
            m_aero_max=inf;
            tau_aero_limit=inf;
            alpha_min=1;
            tau_aero_err_max=0.07;
            GPS_Alt=r;
            Press_Alt=r;
            sd_crit_H2O=0.2;
            sd_crit_aero=0.4
        otherwise, disp('Unknown site')
    end

    %Adjust for Electronic darks
    data=data';
    data=(data-ones(n,1)*darks)';

    %Filter #1, Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
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
    if strcmp(source,'Laptop_Otter')
        RH=RH(L);
        H2O_dens_is=H2O_dens_is(L);
    end
    [m,n]=size(data);

    [azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    SZA=90-altitude;
    clear altitude
    clear azimuth
end
%******************************************************sites*************************************************************
if strcmp(instrument,'AMES14#1_2000')
    NO2_clima=2.0e15/Loschmidt; % atm-cm
    h=21; %altitude of ozone layer in km

    tau_r_err=0.015;       %relative error
    tau_O3_err=0.10;       %relative error
    tau_NO2_err=0.27;      %relative error
    tau_O4_err=0.12;       %relative error
    tau_H2O_err=0.15;      %relative error
    a_H2O_err=0.02;        %relative error
    b_H2O_err=0.02;        %relative error
    H2O_fit_err=0.1*H2O_conv; % absolute error of H2O fit in atm-cm

    %            354    380    449    454    499    525    606    675    778    864    940    1019   1241   1557
    %V0=        [7.3536 6.9617 6.6532 9.2545 5.9008 6.4033 7.1567 7.4363 7.0357 7.5809 7.1524 7.7521 6.5878 8.5679]; % MLO May 2000 Langleys
    V0=        [7.4000 6.9400 6.58800 8.6700 5.7034 6.2000 7.0600 7.4363 7.0166 7.5809 7.1316 7.7315 6.5680 8.4950]; % SAFARI-2000 Aug/Sep 2000
    %V0=        [7.3353 6.7928 6.4658 8.2338 5.7034 6.0321 6.8867 7.4002 7.0166 7.5517 7.1151 7.7315 6.5630 8.4636]; % MLO Oct 2000 Langleys
    V0err_stat=[0.87	2.43   2.84   11.77	  3.46	 5.99	3.82   0.49	  0.27	 0.39	0.52   0.27	  0.38	 1.23]/100;
    V0err_sys= [0.4    0.16   0.16    0.13   0.13   0.18   0.15   0.1    0.05   0.03   2.0    0.10   0.1    0.1   ]/100;%Sytematic Error of a Langley
    slope=     [2      1      3       9      2      3      1      1      1      1      1      1      1      1     ]/100; % % per deg
    dV=        [0.006  0.006  0.006   0.006  0.006  0.006  0.006  0.006  0.006  0.006  0.006  0.006  0.006  0.006 ]; %Uncertainty in Voltage
    wvl_aero=  [1      1      1       0      1      1      1      1      1      1      0      1      1      1     ];
    wvl_chapp= [1      1      1       0      1      1      1      1      1      1      0      1      1      1     ];
    wvl_water= [0      0      0       0      0      0      0      0      0      0      1      0      0      0     ];
    wvl_o3=    [0      0      0       0      0      0      0      0      0      0      0      0      0      0     ];
    darks=     [0.00163 0.00106 0.00067 0.00035	0.00132 0.00077 0.00169	0.00102 -0.00022 0.00008 -0.00057 0.00110 0.00039 -0.00077]; %MLO May 2000

    track_err_crit=1 %[DEG] affects AATS-14 only
    V0err=(V0err_stat.^2+V0err_sys.^2).^0.5;
    degree=2; %degree of aerosol fit in log-log space

    switch lower(site)
        case 'ames',     geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42; temp=ones(n,1)*293.0;press=ones(n,1)*1013.25;
        case 'mauna loa',
            press=ones(n,1)*680;
            geog_long=ones(1,n)*-155.578 ; geog_lat=ones(1,n)*19.539; id_model_atm=1;
            r=ones(1,n)*3.397;temp=ones(n,1)*278.0;
            O3_col_start=read_TOMS_ovp([data_dir 'TOMS\OVP031.ept'],day,month,year)/1e3;
            O3_col_start=.256;
            m_aero_max=inf;
            tau_aero_limit=inf;
            sd_crit=0.01;
            alpha_min=-inf;
            tau_aero_err_max=inf;
        case 'safari-2000',
            temp=ones(n,1)*283.0; id_model_atm=2;
            m_aero_max=inf;
            tau_aero_limit=inf;
            alpha_min=-1;
            tau_aero_err_max=inf;
            GPS_Alt=ones(n,1)*0;
            Press_Alt=r;
            sd_crit_H2O=.1;
            sd_crit_aero=1;

            if (day==14 & month==8 & year==2000)
                O3_col_start=.290;
                Delta_t_start_CV580=59/3600; %SAFARI Aug 14 , 2000 (seconds)
                Delta_t_end_CV580=62/3600;   %SAFARI Aug 14 , 2000 (seconds)
            end
            if strcmp(flight_no,'1812')
                O3_col_start=.290;
                Delta_t_start_CV580=62.5/3600; %SAFARI Aug 14 , 2000 (seconds)
                Delta_t_end_CV580=66/3600;   %SAFARI Aug 14 , 2000 (seconds)
            end
            if strcmp(flight_no,'1814')
                O3_col_start=.320;
                Delta_t_start_CV580=60.5/3600;%SAFARI Aug 15 , 2000 (seconds)
                Delta_t_end_CV580=66/3600;   %SAFARI Aug 15 , 2000 (seconds)
            end
            if (day==17 & month==8 & year==2000)
                O3_col_start=.304;
                Delta_t_start_CV580=61/3600;  %SAFARI Aug 17 , 2000 (seconds)
                Delta_t_end_CV580=67/3600;   %SAFARI Aug 17 , 2000 (seconds)
            end
            if (day==18 & month==8 & year==2000)
                O3_col_start=.301;
                Delta_t_start_CV580=-2/3600; %SAFARI Aug 18 , 2000 (seconds)
                Delta_t_end_CV580=4/3600;   %SAFARI Aug 18 , 2000 (seconds)
            end
            if strcmp(flight_no,'1818')
                O3_col_start=.295;
                Delta_t_start_CV580=-1/3600;  %SAFARI Aug 20 , 2000 (seconds)
                Delta_t_end_CV580=-1/3600;     %SAFARI Aug 20 , 2000 (seconds)
            end
            if (day==20 & month==8 & year==2000)
                O3_col_start=.295;
                Delta_t_start_CV580=-2/3600;  %SAFARI Aug 20 , 2000 (seconds)
                Delta_t_end_CV580=3/3600;     %SAFARI Aug 20 , 2000 (seconds)
            end
            if (day==22 & month==8 & year==2000)
                O3_col_start=.306;
                Delta_t_start_CV580=7/3600;  %SAFARI Aug 22 , 2000 (seconds)
                Delta_t_end_CV580=14/3600;   %SAFARI Aug 22 , 2000 (seconds)
            end
            if (day==23 & month==8 & year==2000)
                O3_col_start=.285;
                Delta_t_start_CV580=4/3600;  %SAFARI Aug 23 , 2000 (seconds)
                Delta_t_end_CV580=9/3600;   %SAFARI Aug 23 , 2000 (seconds)
            end
            if (day==24 & month==8 & year==2000)
                O3_col_start=.302;
                Delta_t_start_CV580=5/3600; %SAFARI Aug 24 , 2000 (seconds)
                Delta_t_end_CV580=11/3600;  %SAFARI Aug 24, 2000 (seconds)
            end
            if strcmp(flight_no,'1823')
                O3_col_start=.291;
                Delta_t_start_CV580=1/3600;  %SAFARI Aug 29 , 2000, UW1823 (seconds)
                Delta_t_end_CV580=5/3600;    %SAFARI Aug 29, 2000, UW 1823(seconds)
            end
            if strcmp(flight_no,'1824')
                O3_col_start=.291;
                Delta_t_start_CV580=1/3600;  %SAFARI Aug 29 , 2000, UW1824 (seconds)
                Delta_t_end_CV580=5/3600;    %SAFARI Aug 29, 2000, UW 1824(seconds)
            end
            if (day==31 & month==8 & year==2000)
                O3_col_start=.298;
                Delta_t_start_CV580=4/3600; %SAFARI Aug 31 , 2000, UW1825 (seconds)
                Delta_t_end_CV580=7/3600;  %SAFARI  Aug 31, 2000, UW 1825(seconds)
            end
            if (day==1 & month==9 & year==2000)
                O3_col_start=.295;
                Delta_t_start_CV580=4/3600; %SAFARI Sep 1 , 2000, UW1826 (seconds)
                Delta_t_end_CV580=9/3600;  %SAFARI Sep 1, 2000, UW 1826(seconds)
            end
            if (day==2 & month==9 & year==2000)
                O3_col_start=.285;
                Delta_t_start_CV580=4/3600; %SAFARI Sep 2 , 2000 (seconds)
                Delta_t_end_CV580=11/3600;  %SAFARI Sep 2, 2000 (seconds)
            end
            if (day==3 & month==9 & year==2000)
                O3_col_start=.265;
                Delta_t_start_CV580=4/3600; %SAFARI Sep 3, 2000 (seconds)
                Delta_t_end_CV580=9/3600;  %SAFARI Sep 3, 2000 (seconds)
            end
            if (day==5 & month==9 & year==2000)
                O3_col_start=.270;
                Delta_t_start_CV580=4.5/3600; %SAFARI Sep 5, 2000 (seconds)
                Delta_t_end_CV580=11.5/3600;  %SAFARI Sep 5, 2000 (seconds)
            end
            if strcmp(flight_no,'1832')
                O3_col_start=.271;
                Delta_t_start_CV580=8/3600; %SAFARI Sep 6, 2000 (seconds)
                Delta_t_end_CV580=13/3600;  %SAFARI Sep 6, 2000 (seconds)
            end
            if strcmp(flight_no,'1833')
                O3_col_start=.271;
                Delta_t_start_CV580=12/3600; %SAFARI Sep 6, 2000 (seconds)
                Delta_t_end_CV580=15/3600;  %SAFARI Sep 6, 2000 (seconds)
            end
            if (day==7 & month==9 & year==2000)
                O3_col_start=.288;
                Delta_t_start_CV580=13/3600; %SAFARI Sep 7, 2000 (seconds)
                Delta_t_end_CV580=18/3600;  %SAFARI Sep 7, 2000 (seconds)
            end
            if (day==11 & month==9 & year==2000)
                O3_col_start=.291;
                Delta_t_start_CV580=12/3600; %SAFARI Sep 11, 2000 (seconds)
                Delta_t_end_CV580=18/3600;  %SAFARI Sep 11, 2000 (seconds)
            end
            if (day==13 & month==9 & year==2000)
                O3_col_start=.278;
                Delta_t_start_CV580=19/3600; %SAFARI Sep 13, 2000 (seconds)
                Delta_t_end_CV580=25/3600;  %SAFARI Sep 13, 2000 (seconds)
            end
            if (day==14 & month==9 & year==2000)
                O3_col_start=.320;
                Delta_t_start_CV580=17/3600; %SAFARI Sep 14, 2000 (seconds)
                Delta_t_end_CV580=22/3600;  %SAFARI Sep 14, 2000 (seconds)
            end
            if (day==16 & month==9 & year==2000)
                O3_col_start=.296;
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
        otherwise, disp('Unknown site')
    end

    %Adjust for Electronic darks
    data=data';
    data=(data-ones(n,1)*darks)';

    %Filter #1, Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
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
    [m,n]=size(data);

    if strcmp(site,'SAFARI-2000')
        ii= INTERP1(UT_CV580,1:size(UT_CV580'),UT,'nearest');
        GPS_Alt=tans_alt(ii);
        %geog_lat=tans_lat(ii); %if data feed was working comment out these 5 lines
        %geog_long=tans_lon(ii);
        %press=pstat(ii)';
        %Press_Alt=p_alt(ii);
        %r=Press_Alt;
    end

    [azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    SZA=90-altitude;
    clear altitude
    clear azimuth
end
%*******************************************************************************************
if strcmp(instrument,'AMES14#1')
    %DGPS='Y'
    NO2_clima=2.0e15/Loschmidt; % atm-cm
    h=21; %altitude of ozone layer in km

    tau_r_err=0.015;       %relative error
    tau_O3_err=0.10;       %relative error
    tau_NO2_err=0.27;      %relative error
    tau_O4_err=0.12;       %relative error
    tau_H2O_err=0.15;      %relative error
    a_H2O_err=0.02;        %relative error
    b_H2O_err=0.02;        %relative error
    H2O_fit_err=0.1*H2O_conv; % absolute error of H2O fit in atm-cm

    %           380.3   448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5
    %V0=       [7.8179 6.2522 7.4869 7.4778 7.4908 7.8189 7.2279 7.4686 7.1904 7.3073 6.3003 7.2219 7.1815 6.758]; %Mauna Loa April 1997
    %V0err=    [0.25	  0.38	0.17 	 0.30   0.23   0.44	 0.27	  0.09   0.12	 0.15	  1.66   0.14	 0.22	  0.21 ]; %Mauna Loa April 1997
    %V0=       [8.0037 6.2682 7.5035 7.4987 7.5388 7.7915 7.1618 7.4808 7.1667 7.3400 6.3003 7.17   7.2307 6.7714];%ACE-2 6/21/97 862 1020 and 1060 and 1557.5 changed manually
    %V0=       [8.0037 6.2682 7.5035 7.4987 7.5388 7.7915 7.1618 7.4808 7.1667 7.3921 6.3003 7.1578 7.3347 6.8330];%ACE-2 6/27/97 Langley new
    %V0=       [8.0037 6.2682 7.5035 7.4987 7.5388 7.7915 7.1618 7.4808 7.1667 7.3697 6.3003 7.1578 7.2700 6.8000];%ACE-2 6/30/97 862 1020 and 1060 and 1557.5 changed manually
    %V0=       [7.8959 6.1998	7.4437 7.4165 7.4748	7.7221 7.0745 7.4354	7.1258 7.3697 6.3003	7.1393 7.2307 6.7714];%ACE-2 7/6/97 Langley new
    V0=       [7.8959 6.1998	7.4437 7.4537 7.4748	7.7221 7.0745 7.4354	7.1258 7.3697 6.3003	7.1393 7.2307 6.7714];%ACE-2 7/8/97
    %V0=       [7.8658 6.1914	7.381	 7.3691 7.4665	7.6571 6.9723 7.3058	6.9600 7.23   6.3003	7.1363 7.1352 6.6500];%ACE-2 7/10/97 Langley
    %V0=       [7.8895 6.2127	7.4563 7.4537 7.4957	7.7561 7.1057 7.4366	7.1264 7.3603 6.3003	7.1192 7.2404 6.7891];%ACE-2 7/14/97 Langley new
    %V0=       [7.8895 6.2127	7.4563 7.4537 7.4957	7.7561 7.1057 7.4366	7.1264 7.3603 6.3003	7.1192 7.2404 6.6740];%ACE-2 7/17/97 1557.5 changed manually

    darks=     [34.15  21.24	18.34	 21.42  23.54	24.61	 22.90  25.67	25.20	 25.35  28.16	28.75	 11.98  12.50]/1e3; % Dark Signals in mV
    V0err_stat=[0.96	  0.53	0.37	 0.47	  0.37	0.54	 0.95	  0.31	0.45	 0.49	  1.73	0.62	 0.86	  0.48]/100; %ACE-2 and MLO
    V0err_sys= [0.4    0.16   0.16   0.13   0.13   0.18	 0.15   0.1    0.05   0.03   2.0    0.10   0.1    0.1   ]/100;%Sytematic Error
    dV=        [0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010  0.010 ];
    wvl_aero=  [1      1      1      1      1      1      1      1      1      1      0      1      1      1     ];
    wvl_chapp= [1      0      1      1      1      1      1      0      1      1      0      0      0      0     ];
    wvl_water= [0      0      0      0      0      0      0      0      0      0      1      0      0      0     ];
    wvl_o3=    [0      0      0      0      0      0      0      0      0      0      0      0      0      0     ];
    wvl_filter=1;
    V0err=(V0err_stat.^2+V0err_sys.^2).^0.5;
    tau_limit=1; % at 380nm
    temp=ones(n,1)*282.0;
    degree=2; %degree of aerosol fit in log-log space

    %Adjust for Electronic darks
    data=data';
    data=(data-ones(n,1)*darks)';

    %Filter #1, Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
    press=press(L);
    temp=temp(L);
    r=r(L);
    geog_long=geog_long(L);
    geog_lat =geog_lat (L);
    Elev_err=Elev_err(L);
    Az_err=Az_err(L);
    Elev_pos=Elev_pos(L);
    Az_pos=Az_pos(L);
    Temperature=Temperature(:,L);
    [m,n]=size(data);

    %replace navigation data by normal NOVA GPS data
    %read_Nova_or_tv;
    %geog_long=Nova_long;
    %geog_lat=Nova_lat;
    %r=Nova_alt/1000;

    %This was for the cases when the Pelican pressure failed then we relied on UW pressure.
    %UW_read_new
    %press=UW_press1'+14;
    %r=288.15/6.5*(1-((press')/1013.25).^(1/5.255876114));%Pressure Altitude according to J. Livingston as long as Press_Alt <=11km

    %reads met.txt file and replaces pressure(pressure is less noisy), temperature
    read_met
    press=Met_press';
    temp=Met_temp'+273.15;

    %reads differential GPS data and replaces Lat, Long and Pressure Altitude
    if DGPS=='Y'
        read_diff_GPS;
        geog_long=Nova_long;
        geog_lat=Nova_lat;
        r=Nova_alt/1000;
    end

    [azimuth, altitude]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    SZA=90-altitude;
    clear altitude
    clear azimuth
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(instrument,'AMES6') % Ames 6 channel SPM
    %            380.1  450.7  525.3  863.9   941.5   1020.7
    %V0=         [5.325	5.217  7.397  6.507	 8.86 	6.973]; % Average from August 97 MLO Langleys
    %V0err_stat= [0.35	0.10 	 0.38	  0.16 	 2.13    0.41 ]; % Standard Deviation from August 97 MLO Langleys
    %V0=         [5.3162 5.2433 7.3686 6.4881  8.86    6.9549];% Oklahoma 29. Sept 1997 Evening Langley, but Vo at 946 from MLO
    %V0=         [5.3245 5.2174 4.9216	4.8746 4.8640 4.8672] ; %with new resistors ratios: 1	1	1.503006012	1.334801762	1.821493625	1.432664756
    %V0=         [5.3086 5.2479 4.8905 5.0682 5.0880 4.9000];%based on Langley Dec 10
    %V0=         [4.9645 4.7350 4.6255	4.6098 4.8397 4.6195];        %May 2000 MLO Langleys
    %V0=         [4.8239 4.7042 4.5364	4.6194 4.7995	4.6195]; %Oct 2000 MLO Langley
    V0=          [4.8819 4.6897 4.5160 4.5968 4.8218   4.5958]; %avg of 2/28,3/2,3/3/01 MLO
    %V0err_stat= [0.34     0.19   0.48    0.23     1.3     0.08 ]/100; % Standard Deviation from May 2000 MLO Langleys
    %V0err_stat=  [0.18    0.28   0.24    0.38     1.5   0.23 ]/100; % Standard Deviation from Oct 2000 MLO Langleys
    V0err_stat=  [0.18    0.06   0.18    0.16     1.6  0.18 ]/100;% Standard Deviation from June 2001 MLO Langleys
    V0err_sys=   [0.5     0.3    0.2     0.1      1.0     0.10 ]/100; % Systematic Error
    V0err_degrad=[0.5     0.5    0.5     0.5      0.5     0.5  ]/100; % Degradation Unc.
    if (strcmp(lower(site),'ace-asia') & julian(day, month,year,12) >= julian(12,4,2001,0))
        %V0=          [6.3810     5.1950  5.2530  4.870   4.8220  4.785];%forced to AATS14 4/19 06.32-06.34 UT, JR with post-mission AATS-14 Beat's best guess
        %V0=          [6.104       5.085   4.764   4.639   4.8220  4.683]; %forced to AATS14 4/26 5.51-5.526 UT, JR with post-mission AATS-14 Beat's best guess, post-flight Apr. 26
        %V0=          [6.2250      5.1650  4.890   4.865   4.8220  4.65]; %forced to AATS14 4/19 06.32-06.34 UT, JR with post-mission AATS-14 Beat's best guess
        V0=          [6.0207 4.9333 4.6485 4.4361  4.6299 4.5561]; %June 2001 MLO Langleys
        %V0=          [6.018       4.999   4.669   4.704   4.8220  4.656]; %forced to AATS14 4/12 23.10-23.12 UT, JR with post-mission AATS-14 Beat's best guess, preflight Apr.20
        %V0=          [5.974       4.9610  4.641   4.520   4.8220  4.602]; %forced to AATS14 4/19 23.02-23.04 UT, JR with post-mission AATS-14 Beat's best guess, preflight Apr.20
    end

    if strcmp(lower(site),'ace-asia')
        V0err_stat=  [3.0   2.3    2.7     4.3      4.1     2.6 ]/100;% Standard Deviation from June 2001 MLO Langleys
        V0err_sys=   [0.5   0.3    0.2        0.1   1.0     0.10 ]/100; % Systematic Error
    end

    V0err=(V0err_stat.^2+V0err_sys.^2+V0err_degrad.^2).^0.5;


    %darks=     [-0.005    -0.005      -0.005      -0.005      -0.005      -0.005];% DAqBook 100
    %darks=     [-0.00044	-0.00126	-0.00084	-0.00106	-0.00096	-0.00084]; % DAqBook 200 May 2000
    %darks=     [-0.00075	-0.00200	-0.00180	-0.00190	-0.00190	-0.00016]; % DAqBook 200 Sep/Oct 2000 Oklahoma
    % darks=   [-0.0009   -0.0018     -0.0015     -0.0017     -0.0016     -0.0012]; %from MLO 3/1/01 VB file 01Mar01.AM
    darks  =     [-0.0016   -0.0026     -0.0020     -0.0021     -0.0024     -0.0018]; %from MLO 6/2/01 VB file 02Jun01.AA
    dV=        [ 0.003  0.003  0.003  0.003   0.003   0.003];
    wvl_aero=  [ 1      1      1      1       0       1    ];
    wvl_chapp= [ 1      1      1      0       0       1    ];
    wvl_water= [ 0      0      0      0       1       0    ];
    wvl_o3=    [ 0      0      0      0       0       0    ];
    NO2_clima=5.0e15/Loschmidt; % atm-cm
    h=21;     %altitude of ozone layer
    degree=1; %degree of aerosol fit in log-log space

    tau_r_err=0.015;       %relative error
    tau_O3_err=0.10;       %relative error
    tau_NO2_err=0.27;      %relative error
    tau_O4_err=0.12;       %relative error
    tau_H2O_err=0.15;      %relative error
    a_H2O_err=0.02;        %relative error
    b_H2O_err=0.02;        %relative error
    H2O_fit_err=0.1*H2O_conv; % absolute error of H2O fit in atm-cm

    switch lower(site)
        case 'oklahoma', geog_long=ones(1,n)* -97.485 ; geog_lat=ones(1,n)*36.605; id_model_atm=2;
            r=ones(1,n)*0.3173; temp=ones(n,1)*298.0;
            O3_col_start=read_TOMS_ovp([data_dir 'TOMS\OVP767.ept'],day,month,year)/1e3;
            m_aero_max=15
            tau_aero_limit=1
            sd_crit=0.002
            alpha_min=1
            tau_aero_err_max=0.05
        case 'ames',     geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42 ;id_model_atm=2;
            r=ones(1,n)*0.020; temp=ones(n,1)*298.0;
            O3_col_start=.290;
            m_aero_max=15
            tau_aero_limit=2
            sd_crit=0.01
            alpha_min=-inf
            tau_aero_err_max=inf
        case 'mauna loa',geog_long=ones(1,n)*-155.578 ; geog_lat=ones(1,n)*19.539; id_model_atm=1;
            r=ones(1,n)*3.397;temp=ones(n,1)*278.0;
            O3_col_start=0.275 %atm-cm = DU/1000
            m_aero_max=inf;
            tau_aero_limit=inf;
            sd_crit_H2O=1;
            sd_crit_aero=0.1;
            alpha_min=-inf;
            tau_aero_err_max=0.05;
        case 'ace-asia'
            r=GPS_Alt;
            %r=Press_Alt;
            temp=ones(n,1)*273.0;
            id_model_atm=6;
            O3_col_start=.319;
            m_aero_max=inf;
            tau_aero_limit=3;
            sd_crit_H2O=0.06;
            sd_crit_aero=0.008;
            alpha_min=-0.03;
            tau_aero_err_max=inf;
            %reads RAF file and replaces pressure, temperature, latitude,longitude and altitude
            if strcmp(Com_Feed,'No')
                [UT_RAF,GLON,GLAT,GALT,PSFDC,ATX,PALT]=read_C130_nav_Asia;
                ii= INTERP1(UT_RAF,1:size(UT_RAF),UT,'nearest','extrap');
                press=PSFDC(ii);
                temp=ATX(ii)+273.15;
                geog_long=GLON(ii)';
                geog_lat=GLAT(ii)';
                r=GALT(ii)'/1000;
                GPS_Alt=GALT(ii)'/1000;
                Press_Alt=PALT(ii)'/1000;
                r=GPS_Alt;
            end
        otherwise, disp('Unknown site')
    end

    [azimuth, altitude,refr]=sun(geog_long, geog_lat,day, month, year, UT,temp',press');
    SZA=90-altitude;
    clear altitude
    clear azimuth

    %Adjust for Electronic darks
    data=data';
    data=(data-ones(n,1)*darks)';

    %Filter #1, Apply time boundaries
    L=(UT>=UT_start & UT<=UT_end);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
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
    [m,n]=size(data);
end
%+++++++++++++++++++++++++++++++++++++++++++

NO2_col_start=NO2_clima;

% filter #2 discard measurement cycles with bad tracking
if strcmp(instrument,'AMES14#1') | strcmp(instrument,'AMES14#1_2000') | strcmp(instrument,'AMES14#1_2001')
    L=find(abs(Elev_err)<track_err_crit & abs(Az_err)<track_err_crit);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
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
    if strcmp(source,'Laptop_Otter') | strcmp(source,'Can')
        RH=RH(L);
        H2O_dens_is=H2O_dens_is(L);
    end
end

% filter #3 discard measurement cycles with darks or negative voltages
L=all(data(:,:)>0.0);
data=data(:,L~=0);
SZA=SZA(L~=0);
UT=UT(L~=0);
press=press(L~=0);
temp=temp(L~=0);
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
if strcmp(source,'Laptop_Otter') | strcmp(source,'Can')
    RH=RH(L~=0);
    H2O_dens_is=H2O_dens_is(L~=0);
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

if strcmp(instrument,'AMES6')
    if strcmpi(site,'mauna loa')
        a_H2O(wvl_water==1)=0.005653; % overwrite with 3.4 km (Mauna Loa) all 6 atmospheres
        b_H2O(wvl_water==1)=0.6130;   % range 0.08-6.59 cm
    end
    %a_H2O(wvl_water==1)=0.005926;  % overwrite with subarctic winter sea level
    %b_H2O(wvl_water==1)=0.6292;    % range  0.42-4.61 cm

    %a_H2O(wvl_water==1)=0.005649; % overwrite with midlatitude winter sea level
    %b_H2O(wvl_water==1)=0.6358;   % range 0.85-9.44 cm

    %a_H2O(wvl_water==1)=0.005268; % overwrite with US standard sea level
    %b_H2O(wvl_water==1)=0.6428;   % range 1.41-15.63 cm

    %a_H2O(wvl_water==1)=0.004957; % overwrite with subarctic summer sea level
    %b_H2O(wvl_water==1)=0.6504;   % range  2.07-22.92 cm

    %a_H2O(wvl_water==1)=0.004613; % overwrite with midlatitude summer sea level
    %b_H2O(wvl_water==1)=0.6595;   % range 2.89-32.14 cm

    %a_H2O(wvl_water==1)=0.004233; % overwrite with tropical sea level
    %b_H2O(wvl_water==1)=0.6697;   % range 4.04-45.02 cm
    tau_O4=(ones(n(2),1)*a0_O4')'+(ones(n(2),1)*a1_O4')'.*(ones(n(1),1)*r)+(ones(n(2),1)*a2_O4')'.*(ones(n(1),1)*r.^2);
end

if strcmp(instrument,'AMES14#1') %this would need to be revisited if ACE-2 data shall be re-processed
    if strcmp(lower(site),'mauna loa')
        a_H2O(wvl_water==1)=0.005816;% overwrite with 3.4 km (Mauna Loa) all 6 atmospheres LBLRTM 5.21 ESA Database
        b_H2O(wvl_water==1)=0.6181;  % range 0.08-6.59 cm
    end
    tau_O4=(ones(n(2),1)*a0_O4')'+(ones(n(2),1)*a1_O4')'.*(ones(n(1),1)*r)+(ones(n(2),1)*a2_O4')'.*(ones(n(1),1)*r.^2);
end

if strcmp(instrument,'AMES14#1_2000')
    if strcmp(lower(site),'mauna loa')
        a_H2O(wvl_water==1)=0.005816;% overwrite with 3.4 km (Mauna Loa) all 6 atmospheres LBLRTM 5.21 ESA Database
        b_H2O(wvl_water==1)=0.6181;  % range 0.08-6.59 cm
    end
    tau_O4=(ones(n(2),1)*a0_O4')'+(ones(n(2),1)*a1_O4')'.*(ones(n(1),1)*r)+(ones(n(2),1)*a2_O4')'.*(ones(n(1),1)*r.^2);
end

if strcmp(instrument,'AMES14#1_2001')
    if strcmp(lower(site),'mauna loa')
        a_H2O(wvl_water==1)=0.005416;% overwrite with 3.4 km (Mauna Loa) all 6 atmospheres LBLRTM 6.01
        b_H2O(wvl_water==1)=0.6235;  % range 0.08-6.59 cm
    end
    tau_O4=(ones(n(2),1)*a0_O4')'+(ones(n(2),1)*a1_O4')'.*(ones(n(1),1)*r)+(ones(n(2),1)*a2_O4')'.*(ones(n(1),1)*r.^2);
end

if  strcmp(instrument,'AMES14#1_2002')
    if strcmp(lower(site),'mauna loa')
        a_H2O(wvl_water==1)=0.005254;% overwrite with 3.4 km (Mauna Loa) all 6 atmospheres LBLRTM 6.01
        b_H2O(wvl_water==1)=0.6221;  % range 0.08-6.59 cm
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