% compares extinction vertical profiles, one profile at a time
%flags
close all
clear all

AATS14='yes'

%load AATS-14 data
if strcmp(AATS14,'yes')
    read_aats14
elseif strcmp(AATS14,'no')
    title1='May 17'
end
jprof=1;
AATS14='yes'
MPLNET='no'
MPLNET2='no'
MPLARM='no'
Neph='yes'
Cadenza='yes'
CARL='no'

% if strcmp(title1,'May 6')
%     UT_start_Neph=15.875  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'Aerosol IOP  5/ 7/2003')
%     UT_start_Neph=15.92  %TSI and PSAP valve only opened then
%     Delta_t=0;
% end
% if strcmp(title1,'Aerosol IOP  5/ 9/2003')
%     UT_start_Neph=15.507  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 12')
%     UT_start_Neph=14.91  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 1401')
%     UT_start_Neph=15.857  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 1402')
%     UT_start_Neph=21.45  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 15')
%     UT_start_Neph=16.585  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'Aerosol IOP  5/17/2003; 1020 nm channel dirty, do not use.')
%     UT_start_Neph=18.91  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 18')
%     UT_start_Neph=15.11  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 20')
%     UT_start_Neph=14.84  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 21')
%     UT_start_Neph=15.925  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 2201')
%     UT_start_Neph=13.495  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 2202')
%     UT_start_Neph=17.04  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 25')
%     UT_start_Neph=20.55  %removed 1 micron cut-off then
% end
% if strcmp(title1,'Aerosol IOP  5/27/2003')
%     UT_start_Neph=14.39  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 28')
%     UT_start_Neph=18.43  %TSI and PSAP valve only opened then
% end
% if strcmp(title1,'May 29')
%     UT_start_Neph=14.24  %TSI and PSAP valve only opened then
% end


%************************************************
if strcmp(AATS14,'yes')
    UT_start_AATS=min(UT);
    UT_end_AATS=max(UT);
end
if strcmp(MPLARM,'yes')
    %load MPLNET data
    [MPLARM_z,MPLARM_UT,MPLARM_aot,MPLARM_ext]=read_MPLARM('c:\beat\data\aerosol iop\',0.319);
    ii=interp1(MPLARM_UT,[1:length(MPLARM_UT)],UT_start_AATS,'nearest');
    jj=interp1(MPLARM_UT,[1:length(MPLARM_UT)],UT_end_AATS+1/60,'nearest','extrap');

    kk=find(MPLARM_ext(ii,:)~=-9999);

    MPLARM_ext=mean(MPLARM_ext([ii:jj],kk),1);
    MPLARM_z=MPLARM_z(kk);
    MPLARM_aot=mean(MPLARM_aot(ii:jj));

    %delete first point as it is always 0
    MPLARM_z(1)=[];
    MPLARM_ext(1)=[];

    MPLARM_AOD=cumtrapz(MPLARM_z,MPLARM_ext);
    MPLARM_AOD=-MPLARM_AOD+MPLARM_AOD(end);

    figure(3)
    orient landscape
    subplot(2,2,1)
    plot(AOD(5,:), GPS_Altitude,'-bo')
    hold on
    plot(MPLARM_AOD,MPLARM_z,'-ro')
    plot(MPLARM_aot,0.319,'go','MarkerFaceColor','g')
    axis([0 0.4, 0,14])
    xlabel('AOD')
    ylabel ('Altitude (km, asl)')
    grid on
    subplot(2,2,2)
    plot(Extinction(5,:), GPS_Altitude,'-bo')
    hold on
    plot(MPLARM_ext, MPLARM_z,'-ro')
    hold off
    axis([0 0.2, 0,14])
    xlabel('Extinction (1/km)')
    ylabel ('Altitude (km, asl)')
    title(title1)
    legend(sprintf('AATS-14 519 nm %5.2f-%5.2f UT',min(UT),max(UT)),sprintf('MPLARM 523 nm %5.2f-%5.2f UT',MPLARM_UT(ii),MPLARM_UT(jj)))
    grid on

    %write MPLARM profile to file
    %create a record of the times used
    MPLARM_UT_write=repmat(MPLARM_UT(ii),[1 length(MPLARM_z)]);
    MPLARM_UT_write(2)=MPLARM_UT(jj);
    file_mplarm=regexprep(filename,'_p','_mplarm');
    fid=fopen(['c:\beat\data\Aerosol IOP\MPLARM\Nov29_2004\',file_mplarm],'w');
    fprintf(fid,'%7.4f %5.3f %8.5f %8.5f\r\n',[MPLARM_UT_write',MPLARM_z,MPLARM_ext',MPLARM_AOD']');
    fclose(fid)
end

if strcmp(MPLNET,'yes')
    %read MPLNET level 2 or 3 data
    jj_mplnet=[1,51,55,111,112,1,117 ,1,1,1,119,136,138,141,1,1,1,1,1,1,152,157,1,163,170]; % Lev2, 5deg, 25 figures test data set July 20
    mplnet=load('C:\Beat\Data\Aerosol IOP\MPLNET\5degTest_ext.txt');% Level 2
    %mplnet=load('C:\Beat\Data\Aerosol IOP\MPLNET\IOP_Level3_Ext_5deg.txt'); %Level 3
    MPLNET_z=mplnet(1,2:end);
    mplnet(1,:)=[];
    mplnet_DOY=mplnet(:,1);
    mplnet(:,1)=[];
    if strcmp(MPLNET2,'yes')
        MPLNET_z(1)=[];
        ii=find(mplnet(:,1)==0);
        mplnet(ii,:)=[];
        mplnet(:,1)=[];
        mplnet_DOY(ii)=[];
        mplnet(1,:)=-999;
    end

    aats_DOY=DayOfYear(day,month,year)+(UT_start+UT_end)/2/24;
    delta_min=(mplnet_DOY(jj_mplnet(jprof))-aats_DOY)*24*60;
    UT_mplnet=(mplnet_DOY(jj_mplnet(jprof))-floor(mplnet_DOY(jj_mplnet(jprof))))*24;

    ii_mplnet=find(mplnet(jj_mplnet(jprof),:)~=-999);
    
    if isempty(ii_mplnet)
        MPLNET_ext=NaN.*MPLNET_z;
        MPLNET_AOD=NaN.*MPLNET_z;
        UT_mplnet=inf;
    else    
        MPLNET_ext=mplnet(jj_mplnet(jprof),ii_mplnet);
        MPLNET_AOD=cumtrapz(MPLNET_z(ii_mplnet),MPLNET_ext);
        MPLNET_AOD=-MPLNET_AOD+MPLNET_AOD(end);
    end
    %plot MPLNET and AATS-14 data
    figure(3)
    subplot(2,2,3)
    plot(AOD(5,:), GPS_Altitude,'-bo')
    hold on
    plot(MPLNET_AOD,MPLNET_z,'-ro')
    axis([0 0.4, 0,14])
    xlabel('AOD')
    ylabel ('Altitude (km, asl)')
    grid on
    subplot(2,2,4)
    plot(Extinction(5,:), GPS_Altitude,'-bo')
    hold on
    plot(MPLNET_ext, MPLNET_z,'-ro')
    hold off
    axis([0 0.2, 0, 14])
    xlabel('Extinction (1/km)')
    ylabel ('Altitude (km, asl)')
    title(title1)
    legend(sprintf('AATS-14 519 nm %5.2f-%5.2f UT',min(UT),max(UT)),sprintf('MPLNET 523 nm %5.2f UT',UT_mplnet))
    grid on
end

if strcmp(CARL,'yes')
    [CARL_Alt,CARL_ext,CARL_aod,CARL_ext_unc,CARL_time_start,CARL_time_end]=read_CARL('c:\beat\data\aerosol iop\',CARL_first,CARL_last,0.315);
    ii=find(CARL_ext~=-999);
    CARL_Alt=CARL_Alt(ii);
    CARL_ext=CARL_ext(ii);
    CARL_aod=CARL_aod(ii);
    CARL_ext_unc=CARL_ext_unc(ii);
    
    figure(3)
    hold on
    subplot(1,2,1)
    plot(AOD(1,:), GPS_Altitude,'-bo')
    hold on
    plot(-CARL_aod+max(CARL_aod),CARL_Alt,'-ro')
    axis([0 0.6, 0,7])
    subplot(1,2,2)
    plot(Extinction(1,:), GPS_Altitude,'-bo')
    hold on
    plot(CARL_ext, CARL_Alt,'-ro')
    hold off
    legend(sprintf('AATS-14 519 nm %5.2f-%5.2f UT',min(UT),max(UT)),sprintf('MPLNET 523 nm %5.2f-%5.2f UT',MPLNET_UT_start,MPLNET_UT_end))
    hold off
 
end

if strcmp(Neph,'yes')
    [MT_TSI,Alt_TSI,scat_467,scat_530,scat_660,bscat_467,bscat_530,bscat_660,abs_467,abs_530,abs_660,...
          scat_467_STP,scat_530_STP,scat_660_STP,bscat_467_STP,bscat_530_STP,bscat_660_STP,abs_467_STP,abs_530_STP,abs_660_STP,...
          gamma,f_RH,T_TSI,p_TSI,RH_TSI,T_ambient,p_ambient,RH_ambient,lowRH,midRH,highRH,humid_flag,alpha_scat,alpha_abs]=read_Neph_ambient;
    
    %fix gamma
    gamma(gamma==-999)=0;
    
    %read Otter cabin file
    [MT,UT_cab,Lat,Long,GPS_Alt,Roll,Pitch,Heading,GST,Tamb,Tdamb,RHamb,Pstatic,Palt,Wind_dir,Wind_Speed,GST2,TAS,Ws,Rad_Alt,Theta,Thetae,CNC_CC,PCASP_CC,...
            PCASP_Vol_CC,CASFWD_CC,CASFWD_Vol_CC,FSSP_CC,FSSP_Vol_CC,LWC,H2O_dens]=read_Otter_Cabin('c:\beat\data\aerosol iop\');  
    
    %fix RH amb
    RHamb(RHamb>=100)=99.999;
    
    % go from Mission Time to UT 
    UT_TSI=interp1(MT,UT_cab,MT_TSI); 
    
    scat_675=scat_660.*(660/675).^alpha_scat;   %for Cadenza and AATS-14 comparisons
    abs_675= abs_660 .*(660/675).^alpha_abs;   %for Cadenza and AATS-14 comparisons
    
    scat_519=scat_530.*(530/519).^alpha_scat;   %for Cadenza and AATS-14 comparisons
    abs_519= abs_530 .*(530/519).^alpha_abs;   %for Cadenza and AATS-14 comparisons
    
    scat_453=scat_467.*(467/453).^alpha_scat; %for AATS-14 comparisons
    abs_453=abs_467.*(467/453).^alpha_abs;   %for AATS-14 comparisons
    
    
    figure(6)
    subplot(3,1,1)
    plot(UT_TSI,scat_467,UT_TSI,scat_530,UT_TSI,scat_660);
    ylabel('TSI scat (1/km)')
    legend('467 nm','530 nm', '660 nm')
    grid on
    title(title1)
   
    subplot(3,1,2)
    plot(UT_cab,RHamb,UT_TSI,RH_TSI,UT_TSI,RH_ambient) 
    legend('RH amb Cab','RH TSI','RH amb Elleman file')
    set(gca,'ylim',[0 100])
    ylabel('RH (%)')
    xlabel('UT')
    grid on
    
    subplot(3,1,3)
    plot(UT_TSI,gamma) %,UT_TSI,log(f_RH)/log(4)
    ylabel('\gamma')
    xlabel('UT')
    grid on
    
    figure(7) 
    subplot(4,1,1)
    plot(UT_TSI,abs_467,UT_TSI,abs_530,UT_TSI,abs_660);
    ylabel('Absorption (1/km)')
    legend('467 nm','530 nm','660 nm')
    grid on
    title(title1)
    subplot(4,1,2)
    plot(UT_TSI,scat_467./(abs_467+scat_467),UT_TSI,scat_530./(abs_530+scat_530),UT_TSI,scat_660./(abs_660+scat_660));
    ylabel('\omega')
    legend('467 nm','530 nm','660 nm')
    grid on
    subplot(4,1,3)
    plot(UT_TSI,alpha_scat);
    ylabel('\alpha scat')
    grid on
    subplot(4,1,4)
    plot(UT_TSI,alpha_abs);
     ylabel('\alpha abs')
    xlabel('UT')
    grid on
   
    if strcmp(Cadenza,'yes')
    
       [Cad_date,UT_Cadenza,Cad_time,Cad_Ext_675,Cad_Ext_1550,Cad_Sca_675,RH_Cadenza,Cad_press,Cad_temp,Cad_Ext_675_amb,Cad_Sca_675_amb,Cad_Abs_675_amb,Cad_SSA_675_amb,Cad_Ext_1550_amb,...
        Cad_RH_amb,Cad_Prs_amb,Cad_Temp_amb]=read_cadenza_IOP_ver4;

        Alt_Cadenza=interp1(UT_cab,GPS_Alt,UT_Cadenza);      
        Cad_gamma=interp1(UT_TSI,gamma,UT_Cadenza);
        
        figure(4)
        subplot(3,1,1)
        plot(UT_TSI,scat_675,UT_Cadenza,Cad_Ext_675_amb) 
        legend('TSI','Cadenza')
        xlabel('UT')
        ylabel('ext (1/km)')
        grid on  
        subplot(3,1,2)
        Cad_k=Cad_Prs_amb./Cad_press.*(Cad_temp+273.15)./(Cad_Temp_amb+273.15);
        plot(UT_TSI,p_ambient./p_TSI.*(T_TSI+273.15)./(T_ambient+273.15),...
             UT_Cadenza,Cad_k) 
        legend('TSI','Cadenza')
        xlabel('UT')
        ylabel('p,T corr')
        grid on  
        subplot(3,1,3)
        f_RH_Cad=((100-RH_Cadenza)./(100-Cad_RH_amb)).^Cad_gamma;
        plot(UT_Cadenza,Cad_Sca_675_amb./Cad_Sca_675,UT_Cadenza,Cad_Ext_1550_amb./Cad_Ext_1550,UT_Cadenza,f_RH_Cad.*Cad_k) 
        legend('675','1550','Theory')
        xlabel('UT')
        ylabel('Amb/Inst')
        grid on

        figure(5)
        subplot(3,1,1)
        plot(UT_cab,Pstatic,UT_TSI,p_ambient,UT_Cadenza,Cad_Prs_amb,UT_TSI,p_TSI,UT_Cadenza,Cad_press) 
        grid on
        xlabel('UT')
        ylabel('Pressure (hPa)')
        legend('Amb Cabfile','Amb Elleman file','Amb Cadenza File','TSI inside','Cadenza inside')
        title(title1)
                
        subplot(3,1,2)
        plot(UT_cab,RHamb,UT_TSI,RH_ambient,UT_Cadenza,Cad_RH_amb,UT_TSI,RH_TSI,UT_Cadenza,RH_Cadenza) 
        legend('RH amb Cabfile','RH amb Elleman file','RH amb Cadenza file','RH TSI','RH Cadenza')
        set(gca,'ylim',[0 100])
        xlabel('UT')
        ylabel('RH (%)')
        grid on
        
        subplot(3,1,3)
        plot(UT_cab,Tamb,UT_TSI,T_ambient,UT_Cadenza,Cad_Temp_amb,UT_TSI,T_TSI,UT_Cadenza,Cad_temp) 
        legend('T amb Cabfile','T amb Elleman file','T amb Cadenza file','T TSI','T Cadenza')
        set(gca,'ylim',[-20 50])
        xlabel('UT')
        ylabel('T')
        grid on  
        
     end 
    
    if strcmp(Neph,'yes') & strcmp(AATS14,'yes')
        if strcmp(title1,'Aerosol IOP  5/ 7/2003')
            UT_start_Neph=15.92  %TSI and PSAP valve only opened then
            UT_end_Neph=16.2
            UT_start_Cadenza=15.904 
            UT_end_Cadenza=16.2
        end
        if strcmp(title1,'Aerosol IOP  5/ 9/2003')
%             %1st profile
            UT_start_Neph=15.655
            UT_end_Neph=16.28
            UT_start_Cadenza=15.655
            UT_end_Cadenza=16.28
            %2nd profile
            UT_start_Neph=16.45
            UT_end_Neph=17.06
            UT_start_Cadenza=16.45
            UT_end_Cadenza=17.06
        end
        if strcmp(title1,'Aerosol IOP  5/12/2003')
            %1st profile
            UT_start_Neph=15.135
            UT_end_Neph=15.7065
            UT_start_Cadenza=15.135
            UT_end_Cadenza=15.7065   
            %2nd profile
            UT_start_Neph=16.19
            UT_end_Neph=16.778
            UT_start_Cadenza=16.19
            UT_end_Cadenza=16.778   
        end
        if strcmp(title1,'Aerosol IOP  5/14/2003')
         %  1st profile
            UT_start_Neph=19.2
            UT_end_Neph=19.736
            UT_start_Cadenza=19.2
            UT_end_Cadenza=19.736   
%             %2nd profile
            UT_start_Neph=19.7355
            UT_end_Neph=20.3
            UT_start_Cadenza=19.7355
            UT_end_Cadenza=20.3   
        end
        if strcmp(title1,'Aerosol IOP  5/17/2003; 1020 nm channel dirty, do not use.')
            %1st profile
            UT_start_Neph=19.04
            UT_end_Neph=19.645
            UT_start_Cadenza=19.04
            UT_end_Cadenza=19.645
%             %2nd profile
            UT_start_Neph=19.727
            UT_end_Neph=20.500
            UT_start_Cadenza=19.727
            UT_end_Cadenza=20.500
%             %3rd profile
            UT_start_Neph=20.62
            UT_end_Neph=21.049
            UT_start_Cadenza=20.62
            UT_end_Cadenza=21.049 
%            %4th profile
            UT_start_Neph=21.049
            UT_end_Neph=21.94
            UT_start_Cadenza=21.049
            UT_end_Cadenza=21.94
        end
        if strcmp(title1,'Aerosol IOP  5/18/2003')
            UT_start_Neph=15.214
            UT_end_Neph=15.852
            UT_start_Cadenza=15.214
            UT_end_Cadenza=15.852
        end
        if strcmp(title1,'Aerosol IOP  5/21/2003')
            %1st profile
            UT_start_Neph=16.046
            UT_end_Neph=16.635
            UT_start_Cadenza=16.046
            UT_end_Cadenza=16.635
            %2nd profile
            UT_start_Neph=16.81
            UT_end_Neph=17.652
            UT_start_Cadenza=16.81
            UT_end_Cadenza=17.652
        end
        if strcmp(title1,'Aerosol IOP  5/22/2003')
%             %1st profile
%             UT_start_Neph=13.6095
%             UT_end_Neph=14.215
%             UT_start_Cadenza=13.6095
%             UT_end_Cadenza=14.215
%             %2nd profile
%             UT_start_Neph=14.284
%             UT_end_Neph=14.851
%             UT_start_Cadenza=14.284
%             UT_end_Cadenza=14.851
%             %3rd profile
%             UT_start_Neph=14.916
%             UT_end_Neph=15.3034
%             UT_start_Cadenza=14.916
%             UT_end_Cadenza=15.3034
            %4th profile
            UT_start_Neph=16.829
            UT_end_Neph=17.1612
            UT_start_Cadenza=16.829
            UT_end_Cadenza=17.1612
            %5th profile%             
            UT_start_Neph=17.215
            UT_end_Neph=17.857
            UT_start_Cadenza=17.215
            UT_end_Cadenza=17.857
%             %6th profile
            UT_start_Neph=17.8563
            UT_end_Neph=18.23
            UT_start_Cadenza=17.8563
            UT_end_Cadenza=18.23

        end     
        if strcmp(title1,'Aerosol IOP  5/25/2003')
             UT_start_Neph=20.685
             UT_end_Neph=21.2295
             UT_start_Cadenza=20.685
             UT_end_Cadenza=21.2295
        end  
        if strcmp(title1,'Aerosol IOP  5/27/2003')
            %1st profile
            UT_start_Neph=15.552  
            UT_end_Neph=16.207
            UT_start_Cadenza=15.552
            UT_end_Cadenza=16.207
            %2nd profile
            UT_start_Neph=16.207  
            UT_end_Neph=18.191
            UT_start_Cadenza=16.207
            UT_end_Cadenza=18.191
% %             %3rd profile
            UT_start_Neph=18.562  
            UT_end_Neph=18.8616
            UT_start_Cadenza=18.562
            UT_end_Cadenza=18.8616
        end
        if strcmp(title1,'Aerosol IOP  5/28/2003')
             UT_start_Neph=18.57
             UT_end_Neph=20.184
             UT_start_Cadenza=18.57
             UT_end_Cadenza=20.184
        end 
        if strcmp(title1,'Aerosol IOP  5/29/2003')
             UT_start_Neph=16.305
             UT_end_Neph=16.889
             UT_start_Cadenza=16.305
             UT_end_Cadenza=16.889
        end 
        
        %plot AOD and Extinction profile with error bars
        figure(10)
        title(title1);
        %xerrorbar('linlin',-inf, inf, -inf, inf, Extinction', (ones(13,1)*Altitude)', Extinction_Error','.')
        
        if strcmp(CARL,'yes')
            plot(Extinction(1,:),Altitude,'-b.',Extinction(5,:),Altitude,'-g.', Extinction(7,:),Altitude,'-r.',Extinction(12,:),Altitude,'-k.')
        end
        
        if strcmp(CARL,'no') 
            plot(Extinction(5,:),Altitude,'-g.')
        end
               
        %overplot with neph
        ii=find (UT_TSI>=UT_start_Neph & UT_TSI <=UT_end_Neph);
        hold on
       % plot (abs_519(ii)+scat_519(ii),Alt_TSI(ii),'-g*',abs_675(ii)+scat_675(ii),Alt_TSI(ii),'-r*',abs_453(ii)+scat_453(ii),Alt_TSI(ii),'-b*')
        plot (abs_519(ii)+scat_519(ii),Alt_TSI(ii),'-b*')
        hold off
        
        if strcmp(CARL,'yes')
            legend('AATS 354 nm','AATS 519 nm','AATS 675 nm','AATS 1550 nm')
        end
        if strcmp(CARL,'no')
            legend('AATS 453 nm','AATS 519 nm','AATS 675 nm','Neph+PSAP 453 nm','Neph+PSAP 519 nm','Neph+PSAP 675 nm')
        end
       
        %write neph_psap profile to file
        file_neph_psap=regexprep(filename,'_p','_neph_psap');
        fid=fopen(['c:\beat\data\Aerosol IOP\nephs_psap\',file_neph_psap],'w');
        fprintf(fid,'%7.4f %7.4f %9.6f %9.6f %9.6f %9.6f %9.6f %9.6f %8.4f %8.4f %9.4f %8.4f %8.4f %9.4f %8.4f %3.0f\r\n', ...
         [UT_TSI(ii)',Alt_TSI(ii)',abs_453(ii)',scat_453(ii)',abs_519(ii)',scat_519(ii)',abs_675(ii)',scat_675(ii)',gamma(ii)',T_TSI(ii)',p_TSI(ii)',...
         RH_TSI(ii)',T_ambient(ii)',p_ambient(ii)',RH_ambient(ii)',humid_flag(ii)']');
        fclose(fid)
        figure(11)
        plot(UT_TSI(ii),Alt_TSI(ii),'.',UT,Altitude,'.')
        legend('TSI','AATS')
        ylabel('Altitude [km]')
        xlabel('UT')
        hold on
        grid on
        
        %overplot with MPLNET 
        if strcmp(MPLNET,'yes')
            figure(10) 
            hold on
            plot(MPLNET_ext, MPLNET_z,'-ro','MarkerFaceColor','r')
            hold off
        end
        
        %overplot with MPLARM 
        if strcmp(MPLARM,'yes')
            figure(10) 
            hold on
            plot(MPLARM_ext, MPLARM_z,'-go','MarkerFaceColor','g')
            hold off
        end
        
        %overplot with Cadenza
        if strcmp(Cadenza,'yes')
            ii=find (UT_Cadenza>=UT_start_Cadenza & UT_Cadenza <=UT_end_Cadenza);
            figure(10) 
            hold on
            plot(Cad_Ext_675_amb(ii),Alt_Cadenza(ii),'-r^',Cad_Ext_1550_amb(ii),Alt_Cadenza(ii),'-k^')
            hold off
            if strcmp(CARL,'no')
 %               legend(              'AATS 453 nm','AATS 550 nm','AATS 675 nm','AATS 1550 nm','Neph+PSAP 450 nm','Neph+PSAP 550 nm','Neph+PSAP 700 nm','Cadenza 675 nm','Cadenza 1550')
            end    

           % write Cadenza profile to file
            file_cad=regexprep(filename,'_p','_cad');
            fid=fopen(['c:\beat\data\Aerosol IOP\Cadenza\Ver7\',file_cad],'w');
            fprintf(fid,'%7.4f %7.4f %9.6f %9.6f %9.6f %6.2f %7.2f %6.2f %9.6f %9.6f %9.6f %6.3f %9.6f %6.2f %7.2f %6.2f\r\n',...
            [UT_Cadenza(ii)',Alt_Cadenza(ii)',Cad_Ext_675(ii)',Cad_Ext_1550(ii)',Cad_Sca_675(ii)',RH_Cadenza(ii)',Cad_press(ii)',Cad_temp(ii)',...
            Cad_Ext_675_amb(ii)',Cad_Sca_675_amb(ii)',Cad_Abs_675_amb(ii)',Cad_SSA_675_amb(ii)',Cad_Ext_1550_amb(ii)',Cad_RH_amb(ii)',...
            Cad_Prs_amb(ii)',Cad_Temp_amb(ii)']');
            fclose(fid)
            
            figure(11)
            plot(UT_Cadenza(ii),Alt_Cadenza(ii),'r.')
            legend('TSI','AATS','Cadenza')
            hold off
            
        end
        
        if strcmp(CARL,'yes')
            figure(10) 
            hold on
            plot(CARL_ext,CARL_Alt,'-bo','MarkerFaceColor','b')
            hold off
  %          legend('AATS 354 nm','AATS 519 nm','AATS 675 nm','AATS 1558 nm','Neph+PSAP 519 nm','Neph+PSAP 675 nm','MPLNET 523 nm','Cadenza 675 nm','Cadenza 1555','Raman 355 nm')
        end
        
        figure(10)
        xlabel('Aerosol Extinction [1/km]','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        grid on
        set(gca,'ylim',[0 8])
        set(gca,'xlim',[0 0.200])
        title([title1 sprintf(' %5.2f-%5.2f %s',min(UT),max(UT),' UT')],'FontSize',14);
        set(gca,'FontSize',14) 
        %legend('AATS 519 nm', 'AATS 675 nm','AATS 1558 nm','Neph+PSAP 519 nm','MPLNET 523 nm', 'MPLARM 523 nm','Cadenza 675','Cadenza 1550')
        legend('AATS 519 nm', 'Neph+PSAP 519 nm','MPLNET 523 nm', 'MPLARM 523 nm')
        orient landscape
        
    end
end