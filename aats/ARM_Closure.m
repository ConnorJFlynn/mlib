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

AATS14='yes'
MPL='no'
Neph='no'
Cadenza='no'
CARL='no'

if strcmp(title1,'May 6')
    UT_start_Neph=15.875  %TSI and PSAP valve only opened then
    Delta_t=-4; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 7')
    UT_start_Neph=15.92  %TSI and PSAP valve only opened then
     Delta_t=0; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'Aerosol IOP  5/ 9/2003')
    UT_start_Neph=15.507  %TSI and PSAP valve only opened then
    Delta_t=-8; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 12')
    UT_start_Neph=14.91  %TSI and PSAP valve only opened then
    Delta_t=-4; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 1401')
    UT_start_Neph=15.857  %TSI and PSAP valve only opened then
    Delta_t=-10; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 1402')
    UT_start_Neph=21.45  %TSI and PSAP valve only opened then
    Delta_t=0; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 15')
    UT_start_Neph=16.585  %TSI and PSAP valve only opened then
     Delta_t=0; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 17')
    UT_start_Neph=18.91  %TSI and PSAP valve only opened then
    Delta_t=39; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 18')
    UT_start_Neph=15.11  %TSI and PSAP valve only opened then
    Delta_t=0; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 20')
    UT_start_Neph=14.84  %TSI and PSAP valve only opened then
    Delta_t=0; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 21')
    UT_start_Neph=15.925  %TSI and PSAP valve only opened then
    Delta_t=0; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 2201')
    UT_start_Neph=13.495  %TSI and PSAP valve only opened then
    Delta_t=-5; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 2202')
    UT_start_Neph=17.04  %TSI and PSAP valve only opened then
     Delta_t=-14758; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 25')
    UT_start_Neph=20.55  %removed 1 micron cut-off then
    Delta_t=-2; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'Aerosol IOP  5/27/2003')
    UT_start_Neph=14.39  %TSI and PSAP valve only opened then
    Delta_t=10; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 28')
    UT_start_Neph=18.43  %TSI and PSAP valve only opened then
    Delta_t=-2; % MT_Cab-MT_Cadenza (sec)
end
if strcmp(title1,'May 29')
    UT_start_Neph=14.24  %TSI and PSAP valve only opened then
    Delta_t=-8; % MT_Cab-MT_Cadenza (sec)
end
%************************************************
if strcmp(MPL,'yes')
    %load MPL data
    [MPL_z,MPL_ext, MPL_ext_unc,MPL_UT_start,MPL_UT_end]=read_MPL('c:\beat\data\aerosol iop\',17,18,0.319);
    MPL_AOD=cumtrapz(MPL_z,MPL_ext);
    MPL_AOD=-MPL_AOD+MPL_AOD(end);
    
    %plot MPL and AATS-14 data
    figure(3)
    subplot(1,2,1)
    plot(AOD(5,:), GPS_Altitude,'-bo')
    hold on
    plot(MPL_AOD,MPL_z,'-ro')
    axis([0 0.3, 0,8])
    xlabel('AOD')
    ylabel ('Altitude (km, asl)')
    subplot(1,2,2)
    plot(Extinction(5,:), GPS_Altitude,'-bo')
    hold on
    plot(MPL_ext, MPL_z,'-ro')
    hold off
    axis([0 0.3, 0,8])
    xlabel('Extinction (1/km)')
    ylabel ('Altitude (km, asl)')
    title(title1)
    legend(sprintf('AATS-14 519 nm %5.2f-%5.2f UT',min(UT),max(UT)),sprintf('MPL 523 nm %5.2f-%5.2f UT',MPL_UT_start,MPL_UT_end))
    
    
    %interpolate to same altitudes
    MPL_AOD_interp=interp1(MPL_z,MPL_AOD,GPS_Altitude);
    MPL_ext_interp=interp1(MPL_z,MPL_ext,GPS_Altitude);
    
    %     %write MPL comparison to file
    %     fid=fopen('c:\beat\data\aerosol iop\mpl\comparison.txt','a');
    %     fprintf(fid,'%6.3f %6.4f %6.4f %6.4f %6.4f\n', [GPS_Altitude',AOD(5,:)',MPL_AOD_interp',Extinction(5,:)',MPL_ext_interp']');
    %     fclose(fid);
    
end

if strcmp(CARL,'yes')
    [CARL_Alt,CARL_ext]=read_CARL_aerosol;
end

if strcmp(Neph,'yes')
    [MT_TSI,scat_450,scat_550,scat_700,RH_TSI,alpha550_450,alpha700_450,alpha700_550,...
            MT_humid,scat_540_low_RH,scat_540_mid_RH,scat_540_high_RH,low_RH,mid_RH,high_RH,gamma_neph,...
            MT_PSAP,PSAP_467,PSAP_530,PSAP_660,...
            MT_SSA,SSA_467,SSA_530,SSA_660]=read_Neph;
    
    %read Otter cabin file
    [MT,UT_cab,Lat,Long,GPS_Alt,Roll,Pitch,Heading,GST,Tamb,Tdamb,RHamb,Pstatic,Palt,Wind_dir,Wind_Speed,GST2,TAS,Ws,Rad_Alt,Theta,Thetae,CNC_CC,PCASP_CC,...
            PCASP_Vol_CC,CASFWD_CC,CASFWD_Vol_CC,FSSP_CC,FSSP_Vol_CC,LWC,H2O_dens]=read_Otter_Cabin('c:\beat\data\aerosol iop\');  
     
    %fix RH amb
    RHamb(RHamb>=100)=99.999;
    
    % go from Mission Time to UT 
    UT_TSI=interp1(MT,UT_cab,MT_TSI); 
    Alt_TSI=interp1(MT,GPS_Alt,MT_TSI);
    RH_amb_TSI=interp1(MT,RHamb,MT_TSI);
    UT_humid=interp1(MT,UT_cab,MT_humid,'linear','extrap'); 
    UT_PSAP=interp1(MT,UT_cab,MT_PSAP); 
    abs_467=interp1(MT_PSAP,PSAP_467,MT_TSI);
    abs_530=interp1(MT_PSAP,PSAP_530,MT_TSI);
    abs_660=interp1(MT_PSAP,PSAP_660,MT_TSI);
    
    % calculate alpha for absorption
    for i=1:length(MT_TSI)
        x=log([0.467,0.530,0.660]);
        y=log([abs_467(i),abs_530(i),abs_660(i)]);
        if isreal(y)
            [p,S] = polyfit(x,y,1);
            a0_abs(i)=p(2); 
            alpha_abs(i)=-p(1);
        else
            a0_abs(i)=0; 
            alpha_abs(i)=1;
        end
    end
    
    UT_SSA=interp1(MT,UT_cab,MT_SSA); 
    
    scat_467=scat_450.*(450/467).^alpha550_450; %for PSAP
    scat_530=scat_550.*(550/530).^alpha550_450; %for PSAP
    scat_660=scat_700.*(700/660).^alpha700_550; %for PSAP
    
    scat_675=scat_700.*(700/675).^alpha700_550; %for Cadenza and AATS-14 comparisons
     abs_675= abs_660.*(660/675).^alpha_abs;    %for Cadenza and AATS-14 comparisons
    
    scat_519=scat_550.*(550/519).^alpha550_450; %for Cadenza and AATS-14 comparisons
     abs_519= abs_530.*(530/519).^alpha_abs;    %for Cadenza and AATS-14 comparisons
    
    
    %read in Cadenza data
    [Cad_time,Cad_ext_675,Cad_ext_1550,RH_Cadenza,Cad_press]=read_cadenza_IOP;  
    Cad_time=Cad_time+Delta_t;
    
    figure(5)
    plot(MT,Pstatic,Cad_time,-20+Cad_press*1.04) %cadenza pressure is calibrated incorrectly. This is just a rough estimated correction
    grid on
    xlabel('Mission Time')
    ylabel('Pressure (hPa)')
    legend('Cabfile','Cadenza File')
    title(title1)
    UT_Cadenza=interp1(MT,UT_cab,Cad_time,'linear','extrap'); 
    Alt_Cadenza=interp1(MT,GPS_Alt,Cad_time);
    RH_amb_Cadenza=interp1(MT,RHamb,Cad_time); %ambient RH at Cadenza times
    RH_Cadenza_TSI=interp1(UT_Cadenza,RH_Cadenza,UT_TSI); %Cadenza RH at TSI times
    
    figure(6)
    subplot(3,1,1)
    plot(UT_TSI,scat_450,UT_TSI,scat_550,UT_TSI,scat_700);
    ylabel('TSI scat (1/km)')
    legend('450 nm','550 nm', '700 nm')
    grid on
    title(title1)
    subplot(3,1,2)
    plot(UT_humid,scat_540_low_RH,UT_humid,scat_540_mid_RH,UT_humid,scat_540_high_RH);
    ylabel('RRscat @ 540nm (1/km)')
    legend('low','mid','high')
    grid on
    subplot(3,1,3)
    plot(UT_humid,low_RH, UT_humid,mid_RH, UT_humid,high_RH,UT_cab,RHamb,UT_TSI,RH_TSI,UT_Cadenza,RH_Cadenza) 
    legend('low','mid','high','ambient','TSI','Cadenza')
    set(gca,'ylim',[0 100])
    ylabel('RH (%)')
    xlabel('UT')
    grid on
    
    figure(7) 
    subplot(4,1,1)
    plot(UT_PSAP,PSAP_467,UT_PSAP,PSAP_530,UT_PSAP,PSAP_660);
    %     hold on
    %     plot(UT_TSI,abs_675);
    %     hold off
    ylabel('Absorption (1/km)')
    set(gca,'ylim',[-0.005 .06])
    legend('467 nm','530 nm','660 nm')
    grid on
    title(title1)
    subplot(4,1,2)
    plot(UT_SSA,SSA_467,UT_SSA,SSA_530,UT_SSA,SSA_660);
    %     hold on
    %     plot(UT_TSI,scat_467./(abs_467+scat_467),UT_TSI,scat_530./(abs_530+scat_530),UT_TSI,scat_660./(abs_660+scat_660));
    %     hold off
    ylabel('\omega')
    set(gca,'ylim',[0 1.2])
    legend('467 nm','530 nm','660 nm')
    grid on
    subplot(4,1,3)
    plot(UT_TSI,alpha550_450,UT_TSI,alpha700_450,UT_TSI,alpha700_550);
    set(gca,'ylim',[-1 5])
    ylabel('\alpha scat')
    legend('550/450 nm','700/450 nm','700/550 nm')
    grid on
    subplot(4,1,4)
    plot(UT_TSI,alpha_abs);
    set(gca,'ylim',[-1 5])
    ylabel('\alpha abs')
    xlabel('UT')
    grid on
    
    
    
    
    % calculate f(RH) and gamma
    x=log(1-[low_RH',mid_RH',high_RH']/100);
    y=log([scat_540_low_RH',scat_540_mid_RH',scat_540_high_RH']);
    
    %     % two RR's only
    %     x=log(1-[low_RH',high_RH']/100);
    %     y=log([scat_540_low_RH',scat_540_high_RH']);
    
    x3=log(1-[1:99]/100);
    gamma3=[];
    for i=1:length(x)
        [p,S] = polyfit(x(i,:),y(i,:),1);
%         figure(9)
%         [y_fit,delta] = polyval(p,x3,S);
%         plot((1-exp(x(i,:)))*100,exp(y(i,:)),'*',(1-exp(x3))*100,exp(y_fit))
%         axis([0 100 0 .3])
%         xlabel('RH [%]');
%         ylabel('Scattering [1/km]');
%         grid on
%         pause(0.01);
        gamma3(i)=-p(1);
    end
    
    figure(9)
    gamma3(gamma3<0)=0; %set negative values to 0
    plot(UT_humid,gamma_neph,UT_humid,gamma3)
    legend('Rob','Beat')
    xlabel('UT')
    ylabel('\gamma')
    set(gca,'ylim',[-1 2])
    grid on
    title(title1)
    
    
    growth_factor=0.8.^gamma3./(0.15.^gamma3); % Growth 20 to 85
    
    gamma_TSI=interp1(UT_humid,gamma3,UT_TSI);
    growth_factor_TSI=(1-RH_TSI/100).^gamma_TSI./(1-RH_amb_TSI/100).^gamma_TSI; % factor to correct TSI to ambient RH
    growth_factor_TSItoCadenza= (1-RH_TSI/100).^gamma_TSI./(1-RH_Cadenza_TSI/100).^gamma_TSI; % factor to correct TSI to Cadenza RH
       
    gamma_Cadenza=interp1(UT_humid,gamma3,UT_Cadenza);
    growth_factor_Cadenza=(1-RH_Cadenza/100).^gamma_Cadenza./(1-RH_amb_Cadenza/100).^gamma_Cadenza;
    
    figure(12)
    plot(UT_humid,growth_factor,UT_TSI,growth_factor_TSI,UT_Cadenza,growth_factor_Cadenza,UT_TSI,growth_factor_TSItoCadenza)
    legend('20% to 85%','TSI to ambient','Cadenza to ambient','TSI to Cadenza')
    set(gca,'ylim',[0 3])
    xlabel('UT')
    ylabel('ext growth factor')
    grid on
    
    
    %compare Cadenza and Neph
    
    figure(8)
    subplot(2,1,1)
    plot(UT_Cadenza,Cad_ext_675,UT_TSI,abs_675+scat_675,UT_TSI,abs_675+scat_675.*growth_factor_TSItoCadenza)
    xlabel('UT')
    ylabel('Extinction')
    legend('Cadenza ext 675 nm','TSI 675 nm +PSAP 675 nm','TSI 675 nm (RH corr) +PSAP 675 nm')
    title(title1) 
    grid on
    xx=get(gca,'xlim');
    

    ii= UT_TSI>=UT_start_Neph;
    TSI_ext675_intrp=interp1(UT_TSI(ii),abs_675(ii)+scat_675(ii).*growth_factor_TSItoCadenza(ii),UT_Cadenza);
    subplot(2,1,2)
    plot(UT_Cadenza,Cad_ext_675-TSI_ext675_intrp)
    xlabel('UT')
    ylabel('TSI-Cadenza')
    grid on
    set(gca,'xlim',xx);
    
    
    figure(13)
    x=TSI_ext675_intrp;
    y=Cad_ext_675;
    
    ii=~isnan(x);
    x=x(ii==1);
    y=y(ii==1);
    
    range=[0:.05:.3];
    plot(x,y,'.');
    hold on
    xlabel('TSI 675 nm + PSAP 675 nm')
    ylabel('Cadenza 675 nm')
    
    %use new Matlab scripts by Edward T. Peltzer
    %standard model 1
    [my,by,ry,smy,sby]=lsqfity(x,y); 
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')
    
    % inverted or reversed model 1
    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')
    
    % least squares bisector
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')
    
    axis([0 max(range) 0 max(range)])
    axis square
    hold off
    grid on

 %     %write Cadenza comparison to file
%     Day_of_May=sscanf(title1, 'May %g');
%     Day_of_May=repmat(Day_of_May,length(x),1);
%     fid=fopen('c:\beat\data\Aerosol IOP\Cadenza\ver2\comparison.txt','a');
%     fprintf(fid,'%g %5.3f %8.6f %8.6f\r\n', [Day_of_May,UT_Cadenza(ii==1)',x',y']');
%     fclose(fid);
end 

if strcmp(Neph,'yes') & strcmp(AATS14,'yes')
    %   May 7
%     UT_start_Neph=15.92  %TSI and PSAP valve only opened then
%     UT_end_Neph=16.2
%     
%     UT_start_Cadenza=15.904 
%     UT_end_Cadenza=16.2

if strcmp(title1,'Aerosol IOP  5/ 9/2003')
    UT_start_Neph=16.45
    UT_end_Neph=17.06
    UT_start_Cadenza=16.45
    UT_end_Cadenza=17.06
end
    
    %May 9 (1st)
    %     UT_start=15.655
    %     UT_end=16.28
    
    %     %May 9 (2nd)
    %      UT_start=16.45
    %      UT_end=17.06
    
    %   %May 12 (1st)
    %     UT_start=15.135
    %     UT_end=15.7065
    
    % %     May 12 (2nd)
    % %     UT_start=16.19
    % %     UT_end=16.778
    
    % 
    %     %May 14 (1st)
    %     UT_start=19.2
    %     UT_end=19.736
    
    % 
    % %     %May 14 (1st)
    %      UT_start=19.7355
    %      UT_end=20.3
    
    %May 17 (1st)
    %       UT_start=19.04
    %       UT_end=19.645
    % %May 18
    %       UT_start=15.214
    %       UT_end=15.852
    
    % %May 21
    %       UT_start=16.046
    %       UT_end=16.635
    
    % %May 22
    %       UT_start=13.61
    %       UT_end=14.19
    
    
    % % %May 25
    %       UT_start=20.685
    %       UT_end=21.2295
    
    if strcmp(title1,'Aerosol IOP  5/27/2003')
        UT_start_Neph=18.565  
        UT_end_Neph=18.8615
        UT_start_Cadenza=18.565
        UT_end_Cadenza=18.8615
    end
    
    x=log(0.550); % 550 nm  and 700 nm are TSI wavelengths
    AOD_550=exp(-gamma.*x.^2-alpha.*x+a0);
    Ext_550=exp(-gamma_ext.*x.^2-alpha_ext.*x+a0_ext);
    
    x=log(0.700); % 550 nm  and 700 nm are TSI wavelengths
    AOD_700=exp(-gamma.*x.^2-alpha.*x+a0);
    Ext_700=exp(-gamma_ext.*x.^2-alpha_ext.*x+a0_ext);
    
    
    %plot AOD and Extinction profile with error bars
    figure(10)
    title(title1);
    %xerrorbar('linlin',-inf, inf, -inf, inf, Extinction', (ones(13,1)*Altitude)', Extinction_Error','.')
    
    if strcmp(CARL,'yes')
        plot(Extinction(1,:),Altitude,'-c.',Extinction(5,:),Altitude,'-g.', Extinction(7,:),Altitude,'-r.',Extinction(12,:),Altitude,'-k.')
    end
    
    if strcmp(CARL,'no')
        plot(Extinction(3,:),Altitude,'-b.',Ext_550,Altitude,'-g.',Extinction(7,:),Altitude,'-r.',Extinction(12,:),Altitude,'-k.')
    end
    
    
    %overplot with neph
    ii=find (UT_TSI>=UT_start_Neph & UT_TSI <=UT_end_Neph);
    hold on
    plot (abs_519(ii)+scat_519(ii).*growth_factor_TSI(ii),Alt_TSI(ii),'-g*',abs_675(ii)+scat_675(ii).*growth_factor_TSI(ii),Alt_TSI(ii),'-r*')
    hold off
    
    if strcmp(CARL,'yes')
        legend('AATS 354 nm','AATS 519 nm','AATS 675 nm','AATS 1550 nm')
    end
    
    if strcmp(CARL,'no')
        legend(              'AATS 453 nm','AATS 550 nm','AATS 675 nm','AATS 1550 nm','Neph+PSAP 450 nm','Neph+PSAP 550 nm','Neph+PSAP 700 nm')
    end
    
    
    
    
    figure(11)
    plot(UT_TSI(ii),Alt_TSI(ii),'.',UT,Altitude,'.')
    legend('TSI','AATS')
    ylabel('Altitude [km]')
    xlabel('UT')
    grid on
    
    %overplot with MPL 
    if strcmp(MPL,'yes')
        figure(10) 
        hold on
        plot(MPL_ext, MPL_z,'-go','MarkerFaceColor','g')
        hold off
    end
    
    %overplot with Cadenza
    if strcmp(Cadenza,'yes')
        ii=find (UT_Cadenza>=UT_start_Cadenza & UT_Cadenza <=UT_end_Cadenza);
        figure(10) 
        hold on
        plot(Cad_ext_675(ii).*growth_factor_Cadenza(ii),Alt_Cadenza(ii),'-r^',Cad_ext_1550(ii).*growth_factor_Cadenza(ii),Alt_Cadenza(ii),'-k^')
        %   plot(Cad_ext_675(ii),Alt_Cadenza(ii),'-r+')
        hold off
        if strcmp(CARL,'no')
            legend(              'AATS 453 nm','AATS 550 nm','AATS 675 nm','AATS 1550 nm','Neph+PSAP 450 nm','Neph+PSAP 550 nm','Neph+PSAP 700 nm','MPL 523 nm','Cadenza 675 nm','Cadenza 1550')
        end    
        
    end
    
    
    if strcmp(CARL,'yes')
        figure(10) 
        hold on
        plot(CARL_ext,CARL_Alt,'-co','MarkerFaceColor','c')
        hold off
        legend('AATS 354 nm','AATS 519 nm','AATS 675 nm','AATS 1558 nm','Neph+PSAP 519 nm','Neph+PSAP 675 nm','MPL 523 nm','Cadenza 675 nm','Cadenza 1555','Raman 355 nm')
    end
    
    
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    grid on
    set(gca,'ylim',[0 6])
    set(gca,'xlim',[0 0.200])
    title([title1 sprintf(' %5.2f-%5.2f %s',min(UT),max(UT),' UT')],'FontSize',14);
    set(gca,'FontSize',14) 
    orient landscape
    
end