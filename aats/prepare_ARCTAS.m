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

flag_adj_V0='no';%'yes'; %added 2/28/06 jml
flag_use_deltaV0_fieldvalues='no';  %use for Ames January 2008
flag_guess='no';
flag_fitPvsGPSalt='no'; %use for 3/10/06 flights
flag_relsd_timedep='no'; %set='yes' for a particular day below
sd_crit_aero_smoke=inf; %reset for a particular day below
UT_smoke=[];
flag_LH2O_equal_Lcloud='no';
flag_filterH2O_byAOD865='no';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UT_start=0;%16;
UT_end=inf;
%UT_start=14;
%UT_end=17;
%UT_start=22.2;
%UT_start=20.466;   %for 7/29 airborne langley
%UT_end=23.676; %for  7/29 airborne langley
%UT_start=15.19;  %0;   %16.05;  %18.7;  %for 7/17 MODIS case     
%UT_end=15.25;    %16.15; %18.9;  
%UT_start=17.4 %7/21
%UT_end=17.63
%UT_start=16.05 %7/20
%UT_start=16.05 %7/20
%UT_start=14.49
%UT_end=14.51
%UT_start=16.05; %7/22
%UT_end=16.12;%7/22
%UT_start=14.5;%7/22
%UT_end=14.9;%7/22
%UT_start=21 %8/7 Langley
%UT_end=21.5 %8/7 Langley
%UT_start=18.18; %17.26
%UT_end=18.28; %17.36
%UT_start=17.923; %2/7/08 file *.AE
%UT_end=19.85;%2/7/08 file *.AE

%%%%%%%%%  Following for ARCTAS summer   %%%%%%%%%%%%%%%%
%UT_start=15.48;  UT_end=20.44; %for 6/26/08 archival
%UT_start=18.5; UT_end=23.5;  %for 6/30/08 air
%UT_end=16.0; %for 7/12/08 air
%%%%%%%%%%%%%%%

Delta_t_Laptop=0/3600; % (seconds)

%instrument='AMES6'
%Com_Feed='Yes' %  feed

%instrument='AMES14#1'      % AATS-14 mainly ACE-2
%instrument='AMES14#1_2000' % AATS-14 MLO ,SAFARI-2000, MLO October 2000
%instrument='AMES14#1_2001' % AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia, CLAMS on CV-580
instrument='AMES14#1_2002'  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron, MLO, Dryden DC-8 testflight, SOLVE-2

source='NASA_P3';
%source='Jetstream31'
%source='Laptop_Otter'
%source='Laptop_DC8_SOLVE2' %--->use this for MLO or Ames?<---
%source='Laptop99'  
%source='Laptop'
%source='Can'

O3_estimate='OFF'; %'ON'; %
diffuse_corr='OFF';

Result_File='OFF'
%Result_File='ACE-2'
%Result_File='Box'
archive_GH='OFF'; % archive in Gaines & Hipskind format
frost_filter='no'; %for ARCATSspring, this is reset below for each day
dirt_filter = 'no'; %for ARCATSspring, this is reset below for April 19 version 0 of data archival

xsect_dir='c:\johnmatlab\AATS14_data_2008\';
%xsect_dir='c:\johnmatlab\AATS14_data_2003\';
%%%xsect_dir='c:\beat\data\xsect\';
%data_dir='c:\beat\data\Everett\';
%data_dir='c:\beat\data\SAFARI-2000\';
%data_dir='c:\beat\data\ACE-Asia\';
%data_dir='c:\johnmatlab\AATS14_data_2004\ICARTT\'
%data_dir='c:\johnmatlab\AATS14_data_2006\INTEXB\'
%data_dir='c:\johnmatlab\AATS14_data_2008\Mauna Loa\'
%data_dir='c:\johnmatlab\AATS14_data_2008\ARCTASspring\';
%data_dir='c:\johnmatlab\AATS14_data_2008\Ames\';
data_dir='c:\johnmatlab\AATS14_data_2008\ARCTASsummer\';
Loschmidt=2.686763e19; %molecules/cm2
H2O_conv=1244.12; %converts cm-atm in pr cm or g/cm2.  This has units of [cm^3/g].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%reads cross-sections and data
if strcmp(instrument,'AMES14#1_2002')  % AATS-14 after August 1, 2002, when we upgraded to 2.1 micron 
    fid=fopen([xsect_dir 'Ames14#1_2008_05142008.asc']);
    %fid=fopen([xsect_dir 'Ames14#1_2008_02272008.asc']);
    %fid=fopen([xsect_dir 'Ames14#1_2002_09262002.asc']);
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
        case 'Laptop_Otter'
            %for files on CIRPAS Twin Otter    
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Laptop_Otter([data_dir '?????_R?????0?.*']);
        case {'Jetstream31','NASA_P3'}
            %for files on Jetstream31...essentially the same as AATS14_Laptop_Otter    
            [day,month,year,Time_Laptop,Time_Can,airmass,Temperature,geog_lat,geog_long,Press_Alt,press,Heading,data,...
                    Sd_volts,Az_err,Elev_err,Az_pos,Elev_pos,Voltref,ScanFreq,AvePeriod,RecInterval,site,...
                    filename,RH,H2O_dens_is,GPS_Alt,T_stat,flight_no]=AATS14_Jetstream31([data_dir 'R?????0?.*']);
        if (day==30 & month==4 & year==2003)
            Delta_t_Laptop=-3/3600; % (seconds) Aerosol IOP Apr 30 , 2003 CIR1
        end
        UT=Time_Laptop+Delta_t_Laptop;
        UTCan=Time_Can;
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
 %%%%%%%%%%%%%%%%%%%%%% USE THE FOLLOWING FOR ARCTAS   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if (julian(day,month,year,12)>=julian(10,1,2008,12) & julian(day,month,year,12)<=julian(11,5,2008,12))
     V0=[11.0199   9.5436   7.8145   8.8571   6.2783   6.2651   7.0234   6.2534   7.5686   3.3473   7.8891   8.7591   8.6966   8.2616]; %mean MLO Feb2008, exclude 02/07
     %V0err_stat= [0.12 	0.16 	0.79 	0.15 	0.22 	0.17     0.12 	0.09 	0.34 	0.53     0.14 	0.21 	0.21 	0.11]/100; %std MLO Feb2008, exclude 02/07...maybe replace 50% MLO V0 diff(May08-Feb08) after May08 cal
     V0err_stat= [0.12 	0.16  2.00 	0.15 	2.00 	0.17     0.12 	0.09 	1.00 	0.53     0.14 	0.21 	0.6 	0.11]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO Feb2008'; %used for ARCTAS spring initial archive
     V0=[10.9393   9.5229   6.7885   8.9240   5.9288   6.2575   7.0091   6.2648   7.5806   3.3538   7.9034   8.5793   8.6603   8.2740];%MLO May 2008 through 5/10 omit 5/8
     V0err_stat=[0.42	0.57	0.25	0.35	0.16	0.23	0.10	0.07	0.05	2.24	0.12	0.01	0.09	0.09]/100; %MLO May 2008 through 5/10 omit 5/8
     flag_calib='MLO May2008a';%MLO May 2008 through 5/10 omit 5/8  use for ARCTAS spring for some wvl
 end
 if (julian(day,month,year,12)>=julian(7,5,2008,12) & julian(day,month,year,12)<=julian(8,5,2008,12))
     V0=[10.9174   9.4796	6.8059   8.9199   5.9334   6.2483   7.0113   6.2669   7.5778   3.2695	7.9001   8.5796   8.668	   8.2782]; %07May2008 only
     V0err_stat= [0.12 	0.16  2.00 	0.15 	2.00 	0.17     0.12 	0.09 	1.00 	0.53     0.14 	0.21 	0.6 	0.11]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 07May2008';
 end
 if (julian(day,month,year,12)==julian(9,5,2008,12))
     V0=[10.9084   9.5056   6.7722   8.8948   5.9179   6.2504   7.0012   6.2597   7.5791   3.2695   7.8960   8.5797   8.6608   8.2787]; %09May2008
     V0err_stat= [0.29 	0.41  0.33 	0.21 	0.20 	0.17     0.07 	0.10 	0.10 	4.0    0.10  0.09  0.18 0.11 ]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 09May2008';
 end
 if(julian(day,month,year,12)==julian(10,5,2008,12))
     V0=[10.9922   9.5834	6.7875   8.9573   5.9351   6.2739	7.0149	 6.2678	  7.585	   3.3778	7.9141	 8.5786	  8.652	   8.2652]; %10May2008 std=3.0
     V0err_stat= [0.29 	0.41  0.33 	0.21 	0.20 	0.17     0.07 	0.10 	0.10 	4.0    0.10  0.09  0.18 0.11 ]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 10May2008';
 end
 if(julian(day,month,year,12)==julian(14,5,2008,12) | julian(day,month,year,12)==julian(15,5,2008,12)) %453,520,2139-nm filters changed 5/13/08
     V0=[10.9393	9.5229	4.9329	8.9240	11.7475	6.2575	7.0091	6.2648	7.5806	3.3538	7.9034	8.5793	8.6603	6.4268]; %MLO mean May 7,9,10, except for new channels
     V0err_stat= [0.29 	0.41  0.33 	0.21 	0.20 	0.17     0.07 	0.10 	0.10 	4.0    0.10  0.09  0.18 0.11 ]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 7910May/14May08';
 end
 if(julian(day,month,year,12)==julian(16,5,2008,12)) %453,520,2139-nm filters changed 5/13/08
     V0=[10.9250	9.4973	4.9455	8.9462	11.7864	6.2629	7.0056	6.2599	7.5706	3.2336	7.8943	8.5265	8.6483	6.4482]; %MLO 16Mayonly
     V0err_stat= [0.29 	0.41  0.33 	0.21 	0.20 	0.17     0.07 	0.10 	0.10 	4.0    0.10  0.09  0.18 0.11 ]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 16May08 only';
 end
 if(julian(day,month,year,12)==julian(17,5,2008,12)) %453,520,2139-nm filters changed 5/13/08
     V0=[10.9358	9.5165	4.9455	8.9296	11.7864	6.2589	7.0083	6.2636	7.5781	3.3238	7.9011	8.5661	8.6573	6.4482]; %MLO mean 791016May
     V0err_stat= [0.29 	0.41  0.33 	0.21 	0.20 	0.17     0.07 	0.10 	0.10 	4.0    0.10  0.09  0.18 0.11 ]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 791016May/16May08';
 end
 if(julian(day,month,year,12)>=julian(17,5,2008,12) & julian(day,month,year,12)<=julian(18,5,2008,12)) %453,520,2139-nm filters changed 5/13/08 
     V0=[10.9651	9.5164	4.9282	8.9738	11.7919	6.2697	7.0041	6.2560	7.5529	3.3238	7.8947	8.5169	8.6411	6.4393]; %MLO mean 18May08
     V0err_stat= [0.29 	0.41  0.33 	0.21 	0.20 	0.17     0.07 	0.10 	0.10 	4.0    0.10  0.09  0.18 0.11 ]/100; %JML 04/04 increased unc. in 452, 519, 864, 1558 channels from stdev MLO Feb2008, exclude 02/07...
     flag_calib='MLO 18May08';
 end
 if(julian(day,month,year,12)>=julian(19,5,2008,12) & julian(day,month,year,12)<julian(22,6,2008,12)) % & julian(day,month,year,12)<=julian(19,6,2008,12)) 
     V0=[10.9392   9.5113   4.9343   8.9393  11.7808   6.2606   7.0055   6.2604   7.5713   3.3423   7.8985   8.5507   8.6525   6.4441];%mean May08 all except 5/8 and for new 451,520, 2139 filters
     V0err_stat=[0.30 	0.40 	0.20 	0.31 	0.13 	0.16 	0.10 	0.10 	0.16 	2.47 	0.10 	0.37 	0.12 	0.07]/100;%mean May08 all except 5/8 and for new 451,520, 2139 filters
     flag_calib='MLO May2008d';%mean May08 all except 5/8 and for new 451,520, 2139 filters
 end
 if(julian(day,month,year,12)>=julian(22,6,2008,12)) % & julian(day,month,year,12)<=julian(19,6,2008,12)) 
    V0=[10.9392   9.5113   4.8356   8.9393  10.4401   6.2606   7.0055   6.2604   7.6417   3.3423   7.8985   8.4481   8.7061   6.4441]; %mean May08 adj 6/26 high alt
    V0err_stat=[0.30 	0.40 	0.20 	0.31 	0.13 	0.16 	0.10 	0.10 	0.16 	2.47 	0.10 	0.37 	0.12 	0.07]/100;%mean May08 all except 5/8 and for new 451,520, 2139 filters
    flag_calib='MLO May2008d, adj using 6/26 7.3-km fit';%%mean May08 adj 6/26 high alt
 end
 %if(julian(day,month,year,12)>=julian(18,6,2008,12))
  %   V0=[10.9392   9.5113   4.9343   8.9393  11.7808   6.2606   7.0055   6.2604   7.5713   3.3423   7.8985   8.5507   8.6525   6.4441];%mean May08 all except 5/8 and for new 451,520, 2139 filters
  %   V0err_stat=[0.30 	0.40 	0.20 	0.31 	0.13 	0.16 	0.10 	0.10 	0.16 	2.47 	0.10 	0.37 	0.12 	0.07]/100;%mean May08 all except 5/8 and for new 451,520, 2139 filters
  %   flag_calib='MLO May2008 adj';%mean May08 all except 5/8 and for new 451,520, 2139 filters; also guess for 520 and 1240 after Roy's changes 6/18
 %end
%%%%%%%%%%%%%%%%%%%%% following lines were used in creating the original archive data set for INTEX-B %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% 8/30/06:  want to bypass these and use new deltaV0 values  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(flag_use_deltaV0_fieldvalues,'yes')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if julian(day, month,year,12) >= julian(18,6,2008,12)
        %deltaV0 = [0 0 -0.015 0 -0.12 0 0 0 0 0 0 -.012 0 0]; 
        deltaV0 = [0 0 -0.02 0 -0.1138 0 0 0 0.0093 0 0 -.012 0.0062 0]; %.015
 end
 if (julian(day, month,year,12) == julian(24,2,2006,12))
        %deltaV0 = [0 0 0 0 0 0 0   -0.0086    0.0135  0   0.00019    0.0025    0.0052   0];
        deltaV0 = [0 0 0 0 0 0 0   -0.0086    0.005  0   0.0019    0.0025    0.0052   0]; %2/24
 end
 %if (julian(day, month,year,12) == julian(3,3,2006,12))
 %           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
      %deltaV0 = [0 0 0 0 0 0 0   -0.01    0.005  0   0.00    0.00    0.00  0]; %from 3/3 high alt
 %     V0=   [11.009  9.562  8.993  9.191  9.113  6.715  7.107  7.192  7.795  5.438  8.038  9.556  9.183  8.087]; %Jens MLO mean Jan06 adj
 %     flag_calib='MLO mean Jan06, adj. using high alt. spectrum'; %this is what is in 3/3/06 RA archived file by Jens
 %end
 if (julian(day, month,year,12) == julian(5,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.002 0   -0.01    0.003  0   0.00    0.00    0.00  0]; %from 3/6 high alt
 end
 if (julian(day, month,year,12) == julian(6,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.002 0   -0.012    0.007  0   0.00    0.00    0.0012  0]; %from 3/6 high alt
        %deltaV0 = [0 0 0 0 0 0.002 0   -0.012    0.007  0   0.00    0.00    0.0018  0]; %from 3/6 high alt
 end
 if (julian(day, month,year,12) == julian(10,3,2006,12))
        if UT(1)<18.9
            deltaV0 = [0 0 0 0 0 0.006 0   -0.013    0.000  0   0.00    0.00    0.0  0]; %from 3/10 high alt
        elseif UT(1)>=18.9
            deltaV0 = [0 0 0 0 0 0.006 0   -0.013    0.000  0   0.00    0.00    0.0  0]; %from 3/10 high alt            
        end
 end
 if (julian(day, month,year,12) == julian(11,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.003 0   -0.018    0.003  0   0.00    0.00    0.00  0]; %from 3/6 high alt
 end
 if (julian(day, month,year,12) == julian(12,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.002 0   -0.012    0.000  0   0.00    0.00    0.00  0]; %from 3/6 high alt
 end
 if (julian(day, month,year,12) == julian(13,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.005 0   -0.016    0.000  0   0.00    0.00    0.00  0]; %from 3/13 high alt 16-16.15
 end
 if (julian(day, month,year,12) == julian(15,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.002 0   -0.012    0.000  0   0.00    0.00    0.00  0]; %from 3/6 high alt
 end
 if (julian(day, month,year,12) == julian(17,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.003 0   -0.022    0.000  0   0.00    0.00    -0.004  0]; %from 3/17 high alt
 end
 if (julian(day, month,year,12) == julian(18,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.005 0   -0.021    0.000  0   0.00    0.00    0.0  0]; %from 3/18 high alt
 end
 if (julian(day, month,year,12) == julian(19,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.005 0   -0.022    0.000  0   0.00    0.00    -0.00  0]; %from 3/19 high alt
 end
 if (julian(day, month,year,12) == julian(20,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.005 0   -0.021    0.000  0   0.00    0.00    -0.00  0]; %from 3/17 high alt
 end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
 if (julian(day, month,year,12) == julian(3,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.002 0   -0.01    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(5,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.002 0   -0.01    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(6,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.002 0   -0.01    0.000  0   0.00    0.00    0.000  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(10,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.004 0   -0.014    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(11,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.004 0   -0.014    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(12,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.004 0   -0.014    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(13,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.004 0   -0.018    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06        %deltaV0 = [0 0 0 0 0 0.005 0   -0.016    0.000  0   0.00    0.00    0.00  0]; %from 3/13 high alt 16-16.15
 end
 if (julian(day, month,year,12) == julian(15,3,2006,12))
      deltaV0 = [0 0 0 0 0 0.004 0   -0.018    0.000  0   0.00    0.00    0.00  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(17,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.004 0   -0.02    0.000  0   0.00    0.00    -0.007  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) == julian(18,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.004 0   -0.02    0.000  0   0.00    0.00    -0.00  0]; %JML best guess 8/30/06        %deltaV0 = [0 0 0 0 0 0.005 0   -0.021    0.000  0   0.00    0.00    0.0  0]; %from 3/18 high alt
 end
 if (julian(day, month,year,12) == julian(19,3,2006,12)) | (julian(day, month,year,12) == julian(20,3,2006,12))
        deltaV0 = [0 0 0 0 0 0.004 0   -0.022    0.000  0   0.00    0.00    -0.007  0]; %JML best guess 8/30/06
 end
 if (julian(day, month,year,12) >= julian(13,1,2008,12))
        deltaV0 = [-0.0526 -0.0256 -0.0966 -0.0657 -0.314 -0.099 -0.03 -0.134 0.0 -0.028 -0.029 -0.088 -0.0575 0.018] %JML 1/17/08 Ames afternoon Langley
 end
 if (julian(day, month,year,12) >= julian(25,3,2008,12))
        deltaV0 = [0.0 0.0 -0.08 0.0 -0.032 0.0 0.0 0.0 0.0125 0.0 0.0 0.0 0.006 0.0] %JML 4/4/2008 from Wallops 3/27 and Yellow-->Fairbanks 4/1 flights
 end
 if (julian(day, month,year,12) >= julian(13,4,2008,12))
        deltaV0 = [0.0 0.0 -0.11 0.0 -0.044 0.0 0.0 0.0 0.013 0.0 0.0 0.0 0.006 0.0] %JR based on John's high alt. spectra for this day
 end
 if (julian(day, month,year,12) >= julian(15,4,2008,12))
        deltaV0 = [0.0 0.0 -0.12 0.0 -0.051 0.0 0.0 0.0 0.026 0.0 0.0 0.0 0.0010 0.0] %JR based on John's high alt. spectra for this day
 end
 if (julian(day, month,year,12) >= julian(19,4,2008,12))
        deltaV0 = [0.0 0.0 -0.125 0.0 -0.052 0.0 0.0 0.0 0.022 0.0 0.0 0.0 0.006 0.0] %JR based on John's high alt. spectra for this day, no idea what to do about 1558
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

if strcmp(flag_use_timeinterp_and_Jan06combo,'yes');
    V0(6)=V0_MLO_Jan06(6)*(1 + deltaV0(6));  %605 nm
    V0(8)=V0_MLO_Jan06(8)*(1 + deltaV0(8));  %779 nm
end

 if strcmp(flag_adj_V0,'yes') & strcmp(flag_use_deltaV0_fieldvalues,'yes') & (julian(day, month,year,12) ~= julian(3,3,2006,12))
        V0=V0.*(1+deltaV0);
        %flag_calib=strcat(flag_calib,', adj. using high alt. spectrum');
        if (julian(day, month,year,12) >= julian(18,6,2008,12))
         %flag_calib=strcat(flag_calib,', 521,1240-nm adj using fit');
         flag_calib=strcat(flag_calib,', adj using 6/26 7.3-km fit');
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
 
 darks=[ 0.00386  0.00046  0.00043  0.00051  0.00048  0.00055  0.00067  0.00057  0.00043  0.00048  0.00056   0.00057  -0.00051  NaN  ]; %darks MLO Feb 2008
% darks=[ 0.000   0.002   0.0005  0.000   0.002   0.0005  0.0015  0.000    0.000  0.000    0.001   0.0015   -0.0005  NaN  ]; %darks MLO July 03 checks with June 04...used for INTEXB
%           354     380     453     499     520     605     675     779      864     940      1019    1240     1558    2138
 V0err_sys=  [0.4     0.16    0.16    0.13    0.13    0.18	 0.15    0.1      0.05    2.0      0.03    0.10     0.1     0.1   ]/100;%Sytematic Error of a Langley	
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
     case 'coldlake',
         geog_long=ones(1,n)*-110.2794 ; geog_lat=ones(1,n)*54.405 ;id_model_atm=2;
         r=ones(1,n)*0.020; temp=ones(n,1)*298.0;press=ones(n,1)*949.9; 
         GPS_Alt=r;
         Press_Alt=r;
         O3_col_start=.310;
         m_aero_max=15;
         tau_aero_limit=5;
         sd_crit_H2O=0.1;
         sd_crit_aero=0.05;
         sd_crit_aero_highalt=inf;%0.001;
         zGPS_highalt_crit=3.9;
         alpha_min=.5;
         tau_aero_err_max=inf
         tempfudge=T_stat';
         zGPS_highalt_crit=12;
         alpha_min_lowalt=-inf;
         flag_OMI_substitute='no';
         if (julian(day, month,year,12) == julian(27,6,2008,12))
           press=ones(n,1)*950.4;
           O3_col_start=.310;
         end         
         if (julian(day, month,year,12) == julian(29,6,2008,12))
           press=ones(n,1)*950.4;
           O3_col_start=.310;
         end         
     case 'ames', 
         geog_long=ones(1,n)*-122.057 ; geog_lat=ones(1,n)*37.42 ;id_model_atm=2;
         r=ones(1,n)*0.020; temp=ones(n,1)*298.0;press=ones(n,1)*1013.25; 
         GPS_Alt=r;
         Press_Alt=r;
         O3_col_start=.287;
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
         if (julian(day, month,year,12) == julian(13,1,2008,12))
           press=ones(n,1)*1025.4; 
           O3_col_start=.290;
         end
         if (julian(day, month,year,12) == julian(25,4,2008,12))
           alpha_min=-inf;
           O3_col_start=.313; %from OMI
         end
         if (julian(day, month,year,12) == julian(5,6,2008,12))
           alpha_min=-inf;
           temp=ones(n,1)*295.0;
           press=ones(n,1)*1014.3;
           O3_col_start=.303; %from OMI for 6/4/2008
         end
         if (julian(day, month,year,12) == julian(9,6,2008,12))
           alpha_min=-inf;
           temp=ones(n,1)*308.0;
           press=ones(n,1)*1011.3;
           O3_col_start=.305; %guess.  OMI for 6/7/2008: 325
         end
         if (julian(day, month,year,12) == julian(18,6,2008,12))
           alpha_min=-inf;
           temp=ones(n,1)*303.0;
           press=ones(n,1)*1016;
           O3_col_start=.311; %OMI for 6/16/2008:
         end
         if (julian(day, month,year,12) == julian(19,6,2008,12))
           alpha_min=-inf;
           temp=ones(n,1)*300.0;
           press=ones(n,1)*1013;
           O3_col_start=.310; %OMI for 6/17/2008:
         end
         if (julian(day, month,year,12) == julian(25,6,2008,12))
           alpha_min=-inf;
           temp=ones(n,1)*310.0;  %guess
           press=ones(n,1)*1013;  %from P-3 data system after landing and also San Jose airport for 18:53 PDT
           O3_col_start=.310; %OMI for 6/17/2008:
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
         sd_crit_aero=0.1
         zGPS_highalt_crit=4;
         alpha_min_lowalt=-inf;
         press=ones(n,1)*678.5; 
         O3_col_start=.282;
         %O3_col_start=read_TOMS_ovp([data_dir 'TOMS\OVP031.ept'],day,month,year)/1e3;
         if (julian(day, month,year,12) == julian(7,2,2008,12))
           press=ones(n,1)*678; 
           O3_col_start=.237;
         elseif (julian(day, month,year,12) == julian(8,2,2008,12))
           press=ones(n,1)*678; 
           O3_col_start=.237;
         elseif (julian(day, month,year,12) == julian(10,2,2008,12))
           press=ones(n,1)*678; 
           O3_col_start=.237;
         elseif (julian(day, month,year,12) == julian(11,2,2008,12))
           press=ones(n,1)*678; 
           O3_col_start=.234;  %updated 2/12 actually
         elseif (julian(day, month,year,12) == julian(12,2,2008,12))
           press=ones(n,1)*679.5; 
           O3_col_start=.246;
         elseif (julian(day, month,year,12) == julian(13,2,2008,12))
           press=ones(n,1)*679.5; 
           O3_col_start=.244;
         elseif (julian(day, month,year,12) == julian(14,2,2008,12))
           press=ones(n,1)*678; 
           O3_col_start=.246;
         elseif (julian(day, month,year,12) == julian(7,5,2008,12))
           press=ones(n,1)*678.5; 
           O3_col_start=.282;
         elseif (julian(day, month,year,12) == julian(8,5,2008,12))
           press=ones(n,1)*678.5; 
           O3_col_start=.276;
         elseif (julian(day, month,year,12) == julian(9,5,2008,12) | julian(day, month,year,12) == julian(10,5,2008,12))
           press=ones(n,1)*678.5; 
           O3_col_start=.282;
         elseif (julian(day, month,year,12) == julian(14,5,2008,12))
           press=ones(n,1)*678.5; 
           O3_col_start=.2625;
         elseif (julian(day, month,year,12) == julian(15,5,2008,12))
           press=ones(n,1)*678.5; 
           O3_col_start=.2661;
         elseif (julian(day, month,year,12) >= julian(15,5,2008,12))
           press=ones(n,1)*681; 
           O3_col_start=.2661;
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
         sd_crit_H2O=.05;
         sd_crit_aero=.005;
         alpha_min=-1;
         tau_aero_err_max=inf;
         r=GPS_Alt;
         track_err_crit_elev=1; %0.005;
         track_err_crit_azim=1;
         O3_col_start=.320;
         temp=T_stat'+273.15; 
         m_aero_max=inf;
         tau_aero_limit=inf; 
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
      case 'icartt'
         id_model_atm=2; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
         sd_crit_H2O=0.06;  %Jens
         sd_crit_aero=0.0025; %jens
         alpha_min=0.0;
         tau_aero_err_max=inf;
         r=GPS_Alt;
         track_err_crit_elev=1; %0.005;
         track_err_crit_azim=1;
         O3_col_start=.290;
         temp=T_stat'+273.15; 
         tempfudge=Tstat_new'+273.15;
         m_aero_max=inf;
         tau_aero_limit=inf; 
         if (month==7 & day==12)  
            alpha_min=0.95; %1.5;
            sd_crit_aero=0.005;
            O3_col_start=.305;
         end
         if (month==7 & day==15)  
            alpha_min=0.1;
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.005; 
            O3_col_start=.343;
         end
         if (month==7 & day==16)  
            alpha_min=0.1; %-inf; %0.1; 
            sd_crit_H2O=inf;  
            sd_crit_aero=0.003; %inf; %0.003; 
            O3_col_start=.317;
         end
         if (month==7 & day==17)  
            alpha_min=0.1;
            sd_crit_aero=0.002; 
            O3_col_start=.328;
         end
         if (month==7 & day==20)  
            alpha_min=-inf;
            sd_crit_aero=0.1; %0.003; 
            O3_col_start=.338;
         end
         if (month==7 & day==21)  
            alpha_min=-inf;
            sd_crit_aero=0.003; 
            O3_col_start=.331;
         end
         if (month==7 & day==22)  
            alpha_min=-inf;
            sd_crit_aero=0.003; 
            O3_col_start=.324;
         end
         if (month==7 & day==23)  
            alpha_min=0.5;
            sd_crit_aero=0.008; 
            O3_col_start=.338;
         end
         if (month==7 & day==26)  
            alpha_min=-inf; %0.5;
            sd_crit_H2O=0.4; 
            sd_crit_aero=0.01; %0.003; 
            O3_col_start=.298;
         end
         if (month==7 & day==29)  
            alpha_min=-inf; %0.5;
            sd_crit_H2O=0.10; %use for flight 16 
            sd_crit_aero=0.003; %0.03 for F16;  use .003 for F17
            O3_col_start=.322;
         end
         if (month==7 & day==31)  
            alpha_min=-inf; % 0.05;
            sd_crit_H2O=0.10; %inf; %0.10; 
            sd_crit_aero=0.002;%inf; %0.03;  %0.002; 
            O3_col_start=.304;
         end
         if (month==8 & day==2)  
            alpha_min=-inf; %0.1; %alpha_min=0.5; use for F19
            sd_crit_H2O=0.10; 
            sd_crit_aero=0.003; 
            O3_col_start=.314;
         end
         if (month==8 & day==3)  
            alpha_min=-inf; %0.1; %alpha_min=0.5; use for F21
            sd_crit_H2O=inf; %0.10; 
            sd_crit_aero=0.012;%inf; %0.003; 
            O3_col_start=.316;
         end
         if (month==8 & day==7)  
            alpha_min=-inf; %0.1; %alpha_min=0.5; use for F22 & F23
            sd_crit_H2O=0.10; 
            sd_crit_aero=0.003; 
            O3_col_start=.330;  %324 for Langley flight
         end
         if (month==8 & day==8)  
            alpha_min=-inf; %0.5; %0.1; %alpha_min=0.5; use for F24; use alpha_min=0.4 for F26
            sd_crit_H2O=0.10; 
            sd_crit_aero=0.003; 
            O3_col_start=.353;  %356 for Langley flight
         end
       case 'intexb'
         id_model_atm=1; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
         tau_aero_err_max=inf;
         r=GPS_Alt;
         track_err_crit_elev=1; %0.005;
         track_err_crit_azim=1;
         O3_col_start=.290;
         temp=T_stat'+273.15; 
         %tempfudge=Tstat_new'+273.15;
         m_aero_max=inf;
         tau_aero_limit=inf;
         alpha_min_lowalt=-inf;
         if (month==2 & day==24)  
            alpha_min=-inf;
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.005; 
            O3_col_start=.290;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==3)  
            alpha_min=-inf;
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.005; 
            O3_col_start=.250;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==5)  
            alpha_min=-inf;
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.005; 
            O3_col_start=.250;
             sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==6)  
            alpha_min=0;
            sd_crit_H2O=0.5;  
            sd_crit_aero=inf;%0.02; 
            O3_col_start=.245;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==10)  
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.02; %0.002;
            alpha_min=0;%-inf; %0;
            O3_col_start=.245;
            tau_aero_err_max=1;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==11)  
            alpha_min=0;
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.02; 
            O3_col_start=.245;  %OMI
            tau_aero_err_max=inf;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==12)  
            alpha_min=0.15;
            sd_crit_H2O=0.5;  
            sd_crit_aero=0.02; 
            O3_col_start=.245;  %OMI data missing
            tau_aero_err_max=inf;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==13)  
            alpha_min=0;
            sd_crit_H2O=0.5; inf; 
            sd_crit_aero=0.005; inf;%
            O3_col_start=.260;  %from OMI file
            tau_aero_err_max=inf;%1;
            sd_crit_aero_highalt=0.005;%inf;%0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==15)  %Mexico City
            alpha_min=0.1;
            sd_crit_H2O=0.05;%inf;  
            sd_crit_aero=0.005;%inf; 
            O3_col_start=.245;
            tau_aero_err_max=inf;
            sd_crit_aero_highalt=inf;%0.001;
            zGPS_highalt_crit=4.5;
            alpha_min_lowalt=0.5;
         end
         if (month==3 & day==17)  
            alpha_min=0;
            sd_crit_H2O=0.05;  
            sd_crit_aero=0.01;%0.005; 
            O3_col_start=.270; %240=no basis; 270=from OMI
            tau_aero_err_max=inf;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==18)  
            alpha_min=0;
            sd_crit_H2O=0.05;  
            sd_crit_aero=0.005; 
            O3_col_start=.270; %from OMI
            tau_aero_err_max=inf;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==19)    %Mexico City
            alpha_min=-inf;
            sd_crit_H2O=inf;%0.005;  
            sd_crit_aero=inf;%0.005; 
            O3_col_start=.270;
            tau_aero_err_max=inf;
            sd_crit_aero_highalt=0.005;
            zGPS_highalt_crit=3.9;
         end
         if (month==3 & day==20)  
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.005;%0.005; 
            O3_col_start=.260; %from OMI
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=3.9;
         end
       case 'arctasspring'
         id_model_atm=5; %1=tropical,2=midlat summer,3=midlat winter,5=subarc winter
         tau_aero_err_max=inf;
         r=GPS_Alt;
         track_err_crit_elev=1; %0.005;
         track_err_crit_azim=1;
         O3_col_start=.290;
         temp=T_stat'+273.15; 
         m_aero_max=inf;
         tau_aero_limit=inf;
         alpha_min_lowalt=-inf;
         if (julian(day, month,year,12) >= julian(1,3,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.005;%0.005; 
            %O3_col_start=.260; %from OMI
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
         end
          if (julian(day, month,year,12) == julian(25,3,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.004;%0.005; 
            O3_col_start=.370; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
         end
         if (julian(day, month,year,12) == julian(27,3,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.004;%0.005; 
            O3_col_start=.335; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
         end
         if (julian(day, month,year,12) >= julian(31,3,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.005;%0.005; 
            %O3_col_start=.260; %from OMI
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
         end
         if (julian(day, month,year,12) == julian(1,4,2008,12))
            alpha_min=0.5;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.002;%0.005; 
            O3_col_start=.400; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
         end
         if (julian(day, month,year,12) == julian(6,4,2008,12))
            alpha_min=0.;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.0015;%0.005; 
            O3_col_start=.400; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
         end
         if (julian(day, month,year,12) == julian(8,4,2008,12))
            alpha_min=0.35;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.003;%0.005; 
            O3_col_start=.400; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'yes'
         end
         if (julian(day, month,year,12) == julian(9,4,2008,12))
            alpha_min=0.3;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.0012;%0.005; 
            O3_col_start=.400; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'yes'
         end
         if (julian(day, month,year,12) == julian(13,4,2008,12))
            alpha_min=0.21;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.002;%0.005; 
            O3_col_start=.400; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
         end
         if (julian(day, month,year,12) == julian(15,4,2008,12))
            alpha_min=0.2;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.003;%0.005; 
            O3_col_start=.440; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'yes'
         end
         if (julian(day, month,year,12) == julian(19,4,2008,12))
            alpha_min=-inf; %0.2;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.003;%0.005; 
            O3_col_start=.370; %from running John's OMI interpolation first
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
            frost_filter = 'no'
            dirt_filter = 'yes'
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
         if (julian(day, month,year,12) == julian(22,6,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.004;%0.005; 
            O3_col_start=.310; %guess
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
         end
          if (julian(day, month,year,12) == julian(23,6,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.05;%0.005; 
            O3_col_start=.310; %guess
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
         end
          if (julian(day, month,year,12) == julian(24,6,2008,12))
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.05;%0.005; 
            O3_col_start=.310; %guess
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
         end
          if (julian(day, month,year,12) == julian(26,6,2008,12))
            alpha_min=0.1;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=6;
         end
          if (julian(day, month,year,12) == julian(27,6,2008,12)) %ground data
            alpha_min=0;
            sd_crit_H2O=.05;%0.005;  
            sd_crit_aero=.05;%0.005; 
            O3_col_start=.310; %guess
            tau_aero_err_max=1;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=10;
         end
         if (julian(day, month,year,12) == julian(29,6,2008,12))
            alpha_min=0.2;
            sd_crit_H2O=inf;%0.005;  
            sd_crit_aero=inf;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=6;
         end
         if (julian(day, month,year,12) == julian(30,6,2008,12))
            alpha_min=0.2;
            sd_crit_H2O=inf;%.05;%0.005;  
            sd_crit_aero=inf; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=6;
        end
        if (julian(day, month,year,12) == julian(2,7,2008,12))
            alpha_min=0.4;%inf;%0.4;
            %alpha_min_lowalt=0.0;%-inf;
            sd_crit_H2O=inf;%0.05;%inf;%.05;%.05;%0.005;  
            sd_crit_aero=inf; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=5;
            flag_LH2O_equal_Lcloud='yes';
        end
        if (julian(day, month,year,12) == julian(3,7,2008,12))
            alpha_min=0.4;
            sd_crit_H2O=inf;%.05;%0.005;  
            sd_crit_aero=0.02; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=6;
            flag_OMI_substitute='yes';
            imoda_OMI_substitute=0701;
            flag_relsd_timedep='yes';
            UT_smoke=[21.8 23.5];
            sd_crit_aero_smoke=inf;
        end
        if (julian(day, month,year,12) == julian(6,7,2008,12))
            alpha_min=0.4;
            sd_crit_H2O=inf;%.05;%0.005;  
            sd_crit_aero=inf; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=5;
            flag_LH2O_equal_Lcloud='yes';
        end
        if (julian(day, month,year,12) == julian(7,7,2008,12))
            alpha_min=0.01;%0.024;
            alpha_min_lowalt=0.07;
            sd_crit_H2O=.02;%inf;%0.005;  
            sd_crit_aero=.02%inf; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=4.6;
        end
        if (julian(day, month,year,12) == julian(9,7,2008,12))
            alpha_min=0.0;%0.024;
            alpha_min_lowalt=0.5;
            sd_crit_H2O=inf;%.005;%inf;%0.005;  
            sd_crit_aero=0.01; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.01;
            zGPS_highalt_crit=4;
            flag_relsd_timedep='yes';
            UT_smoke=[18.4 20.1];
            sd_crit_aero_smoke=inf;
            flag_filterH2O_byAOD865='yes';
            tau865crit=3;
        end
        if (julian(day, month,year,12) == julian(10,7,2008,12))
            alpha_min=0.0;%0.024;
            %alpha_min_lowalt=0;%0.5;%0.5;
            sd_crit_H2O=.005;%inf;%0.005;  
            sd_crit_aero=0.01;%0.05; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.001;
            zGPS_highalt_crit=5;
            flag_relsd_timedep='yes';
            UT_smoke=[21.0 21.53];
            sd_crit_aero_smoke=inf;
        end
        if (julian(day, month,year,12) == julian(12,7,2008,12))
            alpha_min=0.0;%0.024;
            alpha_min_lowalt=-0.5;
            sd_crit_H2O=.005;%inf;%0.005;  
            sd_crit_aero=0.01;%0.05; %.05;%0.005; 
            O3_col_start=.290; %guess
            tau_aero_err_max=5;
            sd_crit_aero_highalt=0.002;
            zGPS_highalt_crit=6.5;
        end
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
 AvePeriod=AvePeriod(L);
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



NO2_col_start=NO2_clima; 

% filter #2 discard measurement cycles with bad tracking
if strcmp(instrument,'AMES14#1') | strcmp(instrument,'AMES14#1_2000') | strcmp(instrument,'AMES14#1_2001')
    L=find(abs(Elev_err)<track_err_crit & abs(Az_err)<track_err_crit);
    data=data(:,L);
    Sd_volts=Sd_volts(:,L);
    UT=UT(L);
    UTCan=UTCan(L);
    AvePeriod=AvePeriod(L);
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
 AvePeriod=AvePeriod(L~=0);
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
 AvePeriod=AvePeriod(L);
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

if (julian(day, month,year,12) == julian(10,3,2006,12))  %set flag for 10 March 2006...2 flights
    flag_fitPvsGPSalt='yes';
end

if strcmp(flag_fitPvsGPSalt,'yes')
  fitPvsGPSalt
end

tau_ray=rayleigh(lambda,press,id_model_atm);