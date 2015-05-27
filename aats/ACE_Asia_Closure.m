%load AATS-14 data
read_AATS14;

Hegg='Yes'
Wang='No'
Ship='Yes'
write_550nm='No'

x=log(0.550); % 550 nm is Hegg's wavelength
AOD_fit=exp(-gamma*x^2-alpha*x+a0);
Ext_fit=exp(-gamma_ext*x^2-alpha_ext*x+a0_ext);
ii_ext=find(a0_ext~=0);

%calculate alpha from extinction for lambda range
lambda_1=[0.380];
lambda_2=[1.020];
x=log(lambda_1);
ext_1=exp(-gamma_ext*x^2-alpha_ext*x+a0_ext);
x=log(lambda_2);
ext_2=exp(-gamma_ext*x^2-alpha_ext*x+a0_ext);
real_alpha=log(ext_1./ext_2)./log(lambda_2/lambda_1);

if strcmp(write_550nm,'Yes')
    %write a file for closure studies at 550 nm
    [pathstr,name,ext,versn]=fileparts(filename);
    resultfile=[name '_550.asc']
    fid=fopen([pathname resultfile],'w');
    fprintf(fid,'%s\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14, unit #1');
    fprintf(fid,'%s %2i.%2i.%4i\n', site);
    fprintf(fid,'%s %s %s\n', 'Date processed:',date, 'by Beat Schmid, Revision 2.0');
    fprintf(fid,'%s\n','UT, Altitude, Ext_550nm, Ext_Err_550nm, Alpha_ext_380_1020');
    fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f \n',...
        [UT(ii_ext)',Altitude(ii_ext)',Ext_fit(ii_ext)',Extinction_Error(5,ii_ext)',real_alpha(ii_ext)']');
    fclose(fid);
end

% Lidar data from Ship available
if strcmp(Ship,'Yes')
    [filename,pathname]=uigetfile('c:\beat\data\ACE-Asia\Lidar Ship\*.txt','Choose file', 0, 0);
    fid=fopen([pathname filename]);
    fgetl(fid);
    data=fscanf(fid,'%f',[6,inf]);
    Alt_Ship=data(1,:);
    Ext_Ship=data(2,:)*1e3;
    AOD_Ship_up=data(3,:);
    AOD_Ship_down=data(4,:);
    Sa_Inversion_Ship=data(5,:);
    Sa_Implied_Ship=data(6,:);
    fclose(fid);
    
    figure(4) %plot 523/525 nm
    subplot(1,3,1)
    plot(AOD_Ship_down,Alt_Ship,'r.-',AOD(5,:),GPS_Altitude,'g.-') %+min(AOD(5,:))
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 10])
    set(gca,'xlim',[0 0.6])
    title(title1);
    legend('MPL: 523 nm', 'AATS-14: 525 nm')
    
    grid on
  
    subplot(1,3,2)
    plot(Ext_Ship,Alt_Ship,'r.-',Extinction(5,:),GPS_Altitude,'g.-')
    grid on
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 10])
    set(gca,'xlim',[0 0.4])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
    
    subplot(1,3,3)
    plot(Sa_Implied_Ship(Sa_Implied_Ship~=0),Alt_Ship(Sa_Implied_Ship~=0),'g.-',Sa_Inversion_Ship,Alt_Ship,'r.-')
    grid on
    xlabel('Lidar Ratio [sr]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 10])
    set(gca,'xlim',[0 80])
    legend('Implied','Assumed')
    grid on
       
    %transfrom to 550 nm from 523 nm using alpha and gamma from AATS-14
    alpha_int=interp1(GPS_Altitude,alpha,Alt_Ship,'nearest','extrap');
    gamma_int=interp1(GPS_Altitude,gamma,Alt_Ship,'nearest','extrap');
   
    AOD_Ship_down_550=exp(log(AOD_Ship_down)+alpha_int*log(0.523/0.550)+gamma_int*(log(0.523)^2-log(0.550)^2));

    alpha_ext_int=interp1(GPS_Altitude,alpha_ext,Alt_Ship,'nearest','extrap');
    gamma_ext_int=interp1(GPS_Altitude,gamma_ext,Alt_Ship,'nearest','extrap');
    
    Ext_Ship_550=exp(log(Ext_Ship)+alpha_ext_int*log(0.523/0.550)+gamma_ext_int*(log(0.523)^2-log(0.550)^2));
    
    figure(5) %plot 523/525 nm and 550 nm
    subplot(1,2,1)
    plot(AOD_Ship_down,Alt_Ship,'r',AOD(5,:),GPS_Altitude,'r.-',...
         AOD_Ship_down_550,Alt_Ship,'b',AOD_fit,GPS_Altitude,'b.-')
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.6])
    title(title1);
    grid on
    subplot(1,2,2)
    plot(Ext_Ship,Alt_Ship,'r',Extinction(5,:),GPS_Altitude,'r.-',...
         Ext_Ship_550,Alt_Ship,'b',Ext_fit,GPS_Altitude,'b.-')
    grid on
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.3])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
    
    figure(6)
    orient landscape
    subplot(1,2,1)
    plot(alpha,Altitude,'.',gamma,Altitude,'.',alpha_int,Alt_Ship,gamma_int,Alt_Ship)
    xlabel('AOD Spectrum','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    grid on
    legend('alpha','gamma')
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[-1 3])
    subplot(1,2,2)
    plot(alpha_ext,Altitude,'.',gamma_ext,Altitude,'.',alpha_ext_int,Alt_Ship,'.',gamma_ext_int,Alt_Ship,'.')
    xlabel('Extinction Spectrum','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[-1 3])
    grid on
    legend('alpha','gamma')
end


% Data from Caltech at 550 nm available
if strcmp(Wang,'Yes')
    % 1st column: Midpoint altitude (meter)
    % 2nd column: Calculated aerosol extinction (y)
    % 3rd column: Lower bound altitude of the point (meter)
    % 4th column: Upper bound altitude of the point (meter)
    % 5th column: Negative uncertainty of aerosol extinction (y1)
    % 6th column: Positive uncertainty of aerosol extinction (y2)
    [filename,pathname]=uigetfile('c:\beat\data\ACE-Asia\Wang\*.dat','Choose file', 0, 0);
    fid=fopen([pathname filename]);
    data=fscanf(fid,'%f',[6,inf]);
    fclose(fid);
    Alt_Wang=data(1,:)/1e3;
    Ext_Wang=data(2,:);
    Alt_Wang_Low=data(3,:)/1e3;
    Alt_Wang_High=data(4,:)/1e3;
    Unc_Wang_Neg=data(5,:);
    Unc_Wang_Pos=data(6,:);
   
    data=[Alt_Wang, Alt_Wang_Low+1e-8, Alt_Wang_High; Ext_Wang, Ext_Wang, Ext_Wang]';
    data=sortrows(data,1);
   
    Alt_Wang_Full=data(:,1);
    Ext_Wang_Full=data(:,2);
          
    AOD_Wang=cumtrapz(Alt_Wang_Full,-Ext_Wang_Full);
    AOD_Wang=AOD_Wang-min(AOD_Wang)+min(AOD_fit);
    
    figure(7)
    orient landscape
    subplot(1,2,1)
    plot(AOD_fit,GPS_Altitude,'g.-',AOD_Wang,Alt_Wang_Full,'b')
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.8])
    title(title1);
    grid on
    
    subplot(1,2,2)
    plot(Ext_fit,GPS_Altitude,'g.-',Ext_Wang,Alt_Wang,'b.',Ext_Wang_Full,Alt_Wang_Full,'b-')
    hold on 
    xerrorbar('linlin',0, 0.4,0, 4, Ext_Wang, Alt_Wang,Unc_Wang_Neg,Unc_Wang_Pos,'b.')
    hold off
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
    legend('AATS-14','Size Distr.')
end




if strcmp(Hegg,'Yes')
    %load Hegg data
    
    pathname = ['c:\beat\data\ace-asia\hegg\' '*.dat']
    [filename,pathname]=uigetfile(pathname,'Choose a File', 0, 0);
    fid=fopen(deblank([pathname filename]));
    [data]=fscanf(fid,'%g %g',[2,inf]);
    Alt_Hegg=data(1,:)/1000;
    Ext_Hegg=data(2,:)/1000;
    fclose(fid);
    
    Ext_Error_Hegg=[8.9 16.0 16.1 9.8 13.3 3 10.6 17.4 17.1 13.6 6.2 5.9 8.6 8.6]/1e3; %Errors independent of Altitude for all 14 profiles
  %  Ext_Error_Hegg=Ext_Error_Hegg(1); %April 6
  %  Ext_Error_Hegg=Ext_Error_Hegg(5); %April 14
     Ext_Error_Hegg=Ext_Error_Hegg(7); %April 17
  %   Ext_Error_Hegg=Ext_Error_Hegg(9); %April 19
   % Ext_Error_Hegg=Ext_Error_Hegg(12); %April 23
    
    AOD_Hegg=cumtrapz(Alt_Hegg,-Ext_Hegg)-min(cumtrapz(Alt_Hegg,-Ext_Hegg));
    
    %Add AOD from AATS-14 at maximum altitude
    AOD_top=interp1(GPS_Altitude,AOD_fit,max(Alt_Hegg),'linear','extrap');
    AOD_Hegg=AOD_Hegg+AOD_top;
    AOD_bot=interp1(GPS_Altitude,AOD_fit,min(Alt_Hegg),'linear','extrap');
    delta_AOD_AATS14=AOD_bot-AOD_top;   
    
    Ext_Altitude=GPS_Altitude(ii_ext);
    Ext_fit     =Ext_fit(ii_ext);
    
   % Ext_int=interp1(Alt_Hegg,Ext_Hegg,Ext_Altitude,'linear');
    Ext_int=interp1(Ext_Altitude, Ext_fit ,Alt_Hegg,'linear');
    ii=~isnan(Ext_int);
    
   % delta_AOD_AATS14_2=trapz(Ext_Altitude(ii),Ext_fit(ii));   
    delta_AOD_AATS14_2=trapz(Alt_Hegg(ii),Ext_int(ii));   
   
   %delta_AOD_Hegg=trapz(Ext_Altitude(ii),Ext_int(ii))
    delta_AOD_Hegg=trapz(Alt_Hegg(ii),Ext_Hegg(ii));   
    
%     %write layer AOD results to file
%     fid=fopen('c:\beat\data\ace-asia\hegg\layer_AOD.txt','a');
%     fprintf(fid,'%s %5.2f %5.2f %6.4f %6.4f %6.4f\n', title1,min(UT),max(UT),delta_AOD_AATS14,delta_AOD_AATS14_2,delta_AOD_Hegg);
%     fclose(fid);
%     
%     %write extinction results to file
%     fid=fopen('c:\beat\data\ace-asia\hegg\extinction.txt','a');
%     fprintf(fid,'%6.4f %6.4f %6.4f\n', [Alt_Hegg(ii)',Ext_int(ii)',Ext_Hegg(ii)']');
%     fclose(fid);    
    
    figure(8)
    orient landscape
    subplot(1,2,1)
    plot(AOD_Hegg,Alt_Hegg,'b.-',AOD_fit,GPS_Altitude,'g.-')
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.6])
    title(title1);
    text(0.05,3.77,sprintf('Layer AOD from AATS-14      = %5.3f',delta_AOD_AATS14_2),'FontSize',13);
    text(0.05,3.65,sprintf('Layer AOD from Neph+PSAP = %5.3f',delta_AOD_Hegg),'FontSize',13);
    text(0.05,3.53,'\lambda = 550 nm','FontSize',13);
    grid on
    
    subplot(1,2,2)
    plot(Ext_Hegg,Alt_Hegg,'b.-',Ext_fit,Ext_Altitude,'g.-')
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.4])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
    legend('Neph+PSAP','AATS-14')
    
end

if strcmp(Ship,'Yes') & strcmp(Hegg,'Yes')
    figure(9)
    orient landscape
    subplot(1,2,1)
    plot(AOD_Hegg,Alt_Hegg,'b.-',AOD_fit,GPS_Altitude,'g.-',AOD_Ship_down_550,Alt_Ship,'r.-')
    hold on
    xerrorbar('linlin',-inf, inf, -inf, inf, AOD_fit, GPS_Altitude,AOD_Error(5,:),'g.')
    hold off
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.7])
    title(title1);
    legend('Neph+PSAP','AATS-14','MPL')
    text(0.47,3.2,'\lambda = 550 nm','FontSize',13);
    grid on
    
    subplot(1,2,2)
    plot(Ext_Hegg,Alt_Hegg,'b.-',Ext_fit,Ext_Altitude,'g.-',Ext_Ship_550,Alt_Ship,'r.-')
    hold on
    xerrorbar('linlin',-inf, inf, -inf, inf, Ext_fit, Ext_Altitude,Extinction_Error(5,:),'g.')
    xerrorbar('linlin',-inf, inf, -inf, inf, Ext_Hegg,Alt_Hegg    ,Ext_Error_Hegg*ones(1,length(Alt_Hegg)),'b.')
    hold off
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.25])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
    
end


if strcmp(Wang,'Yes') & strcmp(Hegg,'Yes')
    figure(10)
    orient landscape
    subplot(1,2,1)
    plot(AOD_Hegg,Alt_Hegg,'b.-',AOD_fit,GPS_Altitude,'g.-',AOD_Wang,Alt_Wang_Full,'m')
    hold on
    xerrorbar('linlin',-inf, inf, -inf, inf, AOD_fit, GPS_Altitude,AOD_Error(5,:),'g.')
    hold off
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.7])
    title(title1);
    text(0.4,3.28,'\lambda = 550 nm','FontSize',13);
    grid on
    legend('Neph+PSAP','AATS-14','Size Distr.')
    
    subplot(1,2,2)
    plot(Ext_Hegg,Alt_Hegg,'b.-',Ext_fit,Ext_Altitude,'g.-',Ext_Wang,Alt_Wang,'m.',Ext_Wang_Full,Alt_Wang_Full,'m-')
    hold on 
    xerrorbar('linlin',0, 0.25,0, 4, Ext_Wang, Alt_Wang,Unc_Wang_Neg,Unc_Wang_Pos,'m.')
    xerrorbar('linlin',-inf, inf, -inf, inf, Ext_fit, Ext_Altitude,Extinction_Error(5,ii_ext),'g.')
    xerrorbar('linlin',-inf, inf, -inf, inf, Ext_Hegg,Alt_Hegg    ,Ext_Error_Hegg*ones(1,length(Alt_Hegg)),'b.')
    hold off
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.25])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
end

if strcmp(Wang,'Yes') & strcmp(Hegg,'Yes') & strcmp(Ship,'Yes') 
    figure(11)
    orient landscape
    subplot(1,2,1)
    plot(AOD_Hegg,Alt_Hegg,'b.-',AOD_fit,GPS_Altitude,'g.-',AOD_Wang,Alt_Wang_Full,'m',AOD_Ship_down_550,Alt_Ship,'c.-')
    hold on
    xerrorbar('linlin',-inf, inf, -inf, inf, AOD_fit, GPS_Altitude,AOD_Error(5,:),'g.')
    hold off
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.7])
    title(title1);
    text(0.15,3.28,'\lambda = 550 nm','FontSize',13);
    legend('Neph+PSAP','AATS-14','Size Distr.','Lidar')
    grid on
    
    subplot(1,2,2)
    plot(Ext_Hegg,Alt_Hegg,'b.-',Ext_fit,GPS_Altitude,'g.-',Ext_Wang,Alt_Wang,'m.',Ext_Wang_Full,Alt_Wang_Full,'m-',Ext_Ship_550,Alt_Ship,'c.-')
    hold on 
    xerrorbar('linlin',0, 0.25,0, 4, Ext_Wang, Alt_Wang,Unc_Wang_Neg,Unc_Wang_Pos,'m.')
    xerrorbar('linlin',-inf, inf, -inf, inf, Ext_fit, Ext_Altitude,Extinction_Error(5,ii_ext),'g.')
    xerrorbar('linlin',-inf, inf, -inf, inf, Ext_Hegg,Alt_Hegg    ,Ext_Error_Hegg*ones(1,length(Alt_Hegg)),'b.')
    hold off
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'ylim',[0 4])
    set(gca,'xlim',[0 0.25])
    grid on
    title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
end
