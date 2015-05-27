close all
clear all
%site='SAFARI-2000'
%site='ACE-Asia'
site='ace-asia'
product='normal'  %normal result produced by plot_re4.m
%product='aod_profile' % AOD profile produced by ext_profile.m
plot_loc_map = 'ON'   %plots location map with time stamps for 'normal' data




switch lower(product)
case 'normal'
    switch lower(site)
    case 'ames'
    case 'mauna loa',
    case 'clams'
        [filename,pathname]=uigetfile('c:\jens\data\CLAMS\Results\*.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        for i=1:13
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[37,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        Pressure_Altitude=data(4,:);
        Pressure=data(5,:);
        H2O=data(6,:);
        H2O_Error=data(7,:);
        AOD_flag=data(8,:);
        AOD=data(9:21,:);
        AOD_Error=data(22:34,:);
        gamma=-data(35,:);
        alpha=-data(36,:);
        a0=data(37,:);
        GPS_Altitude=Pressure_Altitude;
    case 'ace-asia'
        [filename,pathname]=uigetfile('c:\jens\data\ACE-Asia\AATS14_r\CIR*.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        for i=1:12
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[38,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        GPS_Altitude=data(4,:);
        Pressure_Altitude=data(5,:);
        Pressure=data(6,:);
        H2O=data(7,:);
        H2O_Error=data(8,:);
        AOD_flag=data(9,:);
        AOD=data(10:22,:);
        AOD_Error=data(23:35,:);
        gamma=-data(36,:);
        alpha=-data(37,:);
        a0=data(38,:);  
    case 'safari-2000'
        [filename,pathname]=uigetfile('c:\jens\data\SAFARI-2000\Results\*.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        for i=1:12
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g')
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[36,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        GPS_Altitude=data(4,:);
        Pressure_Altitude=data(5,:);
        Pressure=data(6,:);
        H2O=data(7,:);
        H2O_Error=data(8,:);
        AOD_flag=data(9,:);
        AOD=data(10:21,:);
        AOD_Error=data(22:33,:);
        gamma=-data(34,:);
        alpha=-data(35,:);
        a0=data(36,:);    
    case 'everett',
    otherwise, disp('Unknown site')
    end
case 'aod_profile'
    switch lower(site)
    case 'ames'
    case 'mauna loa',
    case 'clams'
        [filename,pathname]=uigetfile('c:\jens\data\clams\*p.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        for i=1:12
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[50,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        Pressure_Altitude=data(4,:);
        Pressure=data(5,:);
        AOD=data(6:18,:);
        AOD_Error=data(19:31,:);
        gamma=-data(32,:);
        alpha=-data(33,:);
        a0=data(34,:);
        Extinction=data(35:47,:);
        gamma_ext=-data(48,:);
        alpha_ext=-data(49,:);
        a0_ext=data(50,:);
        GPS_Altitude=Pressure_Altitude;
    case 'ace-asia'
        [filename,pathname]=uigetfile('c:\jens\data\ACE-Asia\\*.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        for i=1:12
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[51,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        GPS_Altitude=data(4,:);
        Pressure_Altitude=data(5,:);
        Pressure=data(6,:);
        AOD=data(7:19,:);
        AOD_Error=data(20:32,:);
        gamma=-data(33,:);
        alpha=-data(34,:);
        a0=data(35,:);
        Extinction=data(36:48,:);
        gamma_ext=-data(49,:);
        alpha_ext=-data(50,:);
        a0_ext=data(51,:);
    case 'safari-2000'
        [filename,pathname]=uigetfile('c:\beat\data\SAFARI-2000\Results\*.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        for i=1:12
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g')
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[48,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        GPS_Altitude=data(4,:);
        Pressure_Altitude=data(5,:);
        Pressure=data(6,:);
        AOD=data(7:18,:);
        AOD_Error=data(29:30,:);
        gamma=-data(31,:);
        alpha=-data(32,:);
        a0=data(33,:);
        Extinction=data(34:45,:);
        gamma_ext=-data(46,:);
        alpha_ext=-data(47,:);
        a0_ext=data(48,:);
    case 'everett',
    otherwise, disp('Unknown site')
    end
end

switch lower(product)
case 'normal'
    
    if strcmp(plot_loc_map,'ON')
        
        edge = 1.0;

        figure(1111)
        worldmap([min(Latitude)-edge,max(Latitude)+edge],[min(Longitude)-edge,...
        max(Longitude)+edge],'patch')
        plotm(Latitude,Longitude,'LineWidth',2)
        hold on
        plotm(Latitude(AOD_flag==1),Longitude(AOD_flag==1),'m.','MarkerSize',8)
        if size(Longitude(AOD_flag==1 & GPS_Altitude<0.08))~=0
            plotm(Latitude(AOD_flag==1 & GPS_Altitude<0.08),Longitude(AOD_flag==1&GPS_Altitude<0.08),'g.','MarkerSize',6)
        end
        jj=ceil(min(UT))
        while jj <= floor(max(UT))  
           index = find(abs([double(UT)-jj])==min(abs([double(UT)-jj])));
           if length(index)>1 
              index=index(1,1); 
           end
           if round(UT(index))>=24 
              time_str = num2str(round(UT(index))-24)
           else
              time_str = num2str(round(UT(index)))
           end
           textm(Latitude(index),Longitude(index), sprintf('%sUT',time_str))
           jj=jj+1  
        end

        scaleruler on
        set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
        setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
        
        hidem(gca)


        if strcmp(lower(site),'clams')
            plotm(36.9,-75.71,'rs','MarkerSize',8,'MarkerFaceColor','r');   %COVE
        end
        if strcmp(lower(site),'ace-asia')
            plotm(33.32,126.24,'ms','MarkerSize',8,'MarkerFaceColor','m')   %Cheju, Kosan AERONET site???
            plotm(35.62,135.07,'ms','MarkerSize',8,'MarkerFaceColor','m')   %Hoeller sunphotometer 35.62N, 135.07E
            plotm(34.1439,132.236,'k^','MarkerSize',8,'MarkerFaceColor','k')  %Iwakuni, ops. center
            plotm(35.66,139.80,'rs','MarkerSize',8,'MarkerFaceColor','r')   %TUMM lidar, Tokyo
            plotm(36.05,140.12,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Continuous observation at Tsukuba(36.05N,140.12E), 
            plotm(32.78,129.86,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Nagasaki(32.78N,129.86E)
            plotm(39.9,116.3,'rs','MarkerSize',8,'MarkerFaceColor','r')     %lidar Beijing(39.9N,116.3E)
            plotm(35.58,140.10,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar CEReS, Chiba University, Inage, Chiba (35.58N, 140.10E)
            plotm(35.1,137.0,'rs','MarkerSize',8,'MarkerFaceColor','r')     %lidar Nagoya, 35.1N, 137.0E
            plotm(34.47,133.23,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Fukuyama University, 133.23E / 34.47N
            plotm(28.44,129.70,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Amami 28.44N, 129.70E
            plotm(33.283,126.167,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar SNU Kosan, Korea (37.28N, 126.17E, ASL50m)???
            plotm(37.14,127.04,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Suwon, Korea(37.14N, 127.04E)
        end
        hold off
        min(UT)
        max(UT)
        filename
        
    else
    
      figure(1)
      subplot(6,1,1)
      plot(UT,AOD,'.')
      subplot(6,1,2)
      plot(UT(AOD_flag==1),AOD(:,AOD_flag==1),'.')
      subplot(6,1,3)
      plot(UT,AOD_Error,'.')
      subplot(6,1,4)
      plot(UT(AOD_flag==1),AOD_Error(:,AOD_flag==1),'.')
      subplot(6,1,5)
      plot(UT,alpha,'.',UT,gamma,'.')
      subplot(6,1,6)
      plot(UT(AOD_flag==1),alpha(AOD_flag==1),'.',UT(AOD_flag==1),gamma(AOD_flag==1),'.')
    
      figure(2)
      subplot(2,1,1)
      plot(UT,Pressure,'.')
      subplot(2,1,2) 
      plot(UT,H2O,'.',UT,H2O+H2O_Error,'b',UT,H2O-H2O_Error,'b')
    
    
      figure(3)
      subplot(1,2,1)
      plot(Longitude,Latitude,'.-')
      axis square
      subplot(1,2,2)
      plot(GPS_Altitude, Pressure_Altitude,'.')
      axis square
    
      figure(4)
      % AOD
      ind=find(AOD_flag==1);
      for i=ind
        loglog(lambda,AOD(:,i),'mo');
        hold on
        yerrorbar('loglog',0.3,1.6, 0.01, 2,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
        AOD_fit=exp(polyval([-gamma(i),-alpha(i),a0(i)],log([0.3:0.1:1.6])));
        loglog([0.3:0.1:1.6],AOD_fit);
        hold off
        set(gca,'xlim',[.300 1.60]);
        set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
        set(gca,'ylim',[0.01 2]);
        %title(title1);
        xlabel('Wavelength [microns]');
        ylabel('Optical Depth')
        pause (0.01)
      end
  end
    
case 'aod_profile'
    figure(1)
    subplot(1,2,1)
    plot(AOD,GPS_Altitude,'.')
    xlabel('Aerosol Optical Depth','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    grid on
    subplot(1,2,2)
    plot(Extinction,GPS_Altitude,'.')
    xlabel('Aerosol Extinction [1/km]','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    grid on
    if strcmp(site,'SAFARI-2000') 
        legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
            num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'));
    end
    if strcmp(site,'ACE-Asia') 
        legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
            num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
    end
    
    figure(2)
    subplot(1,2,1)
    plot(alpha,GPS_Altitude,'.',gamma,GPS_Altitude,'.')
    xlabel('AOD Spectrum','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    grid on
    legend('alpha','gamma')
    subplot(1,2,2)
    plot(alpha_ext,GPS_Altitude,'.',gamma_ext,GPS_Altitude,'.')
    xlabel('Extinction Spectrum','FontSize',14)
    ylabel('Altitude [km]','FontSize',14)
    set(gca,'FontSize',14)
    set(gca,'xlim',[-0.5 3])
    grid on
    legend('alpha','gamma')
    
    figure(3)
    subplot(1,2,1)
    plot(Longitude,Latitude,'.-')
    xlabel('Longitude','FontSize',14)
    ylabel('Latitude','FontSize',14)
    set(gca,'FontSize',14)
    grid on
    axis square
    subplot(1,2,2)
    plot(GPS_Altitude, Pressure_Altitude,'.')
    xlabel('GPS Alt','FontSize',14)
    ylabel('Press Alt','FontSize',14)
    set(gca,'FontSize',14)
    grid on
    axis square
    
    figure(4)
    % AOD
    ind=length(AOD);
    for i=1:ind
        loglog(lambda,AOD(:,i),'mo');
        hold on
        yerrorbar('loglog',0.3,1.6, 0.01, 2,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
        AOD_fit=exp(polyval([-gamma(i),-alpha(i),a0(i)],log([0.3:0.1:1.6])));
        loglog([0.3:0.1:1.6],AOD_fit);
        hold off
        set(gca,'xlim',[.300 1.60]);
        set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
        set(gca,'ylim',[0.01 2]);
        %title(title1);
        xlabel('Wavelength [microns]');
        ylabel('Optical Depth')
        pause (0.01)
    end
    
    figure(5)
    % Extinction
    ind=length(AOD);
    for i=1:ind
        loglog(lambda,Extinction(:,i),'mo');
        hold on
        yerrorbar('loglog',0.3,1.6,1e-4, 1,lambda,Extinction(:,i),0.005*ones(1,length(lambda)),'mo')
        ext_fit=exp(polyval([-gamma_ext(i),-alpha_ext(i),a0_ext(i)],log([0.3:0.1:1.6])));
        loglog([0.3:0.1:1.6],ext_fit);
        hold off
        set(gca,'xlim',[.300 1.60]);
        set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
        set(gca,'ylim',[1e-4 1]);
        %title(title1);
        xlabel('Wavelength [microns]');
        ylabel('Aerosol Extinction')
        pause (0.01)
    end
end