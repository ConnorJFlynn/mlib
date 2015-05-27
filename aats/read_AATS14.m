%plots AATS14 result files and compares with other measurements as an option 
clear all
close all
UT_start=0
UT_end=inf

%site='SAFARI-2000'
%site='ACE-Asia'
%site='CLAMS'
%site='ADAM'
%site='Aerosol IOP'
site='ALIVE'

product='aod_normal'  %aod_normal result produced by plot_re4.m
%product='aod_profile' % AOD profile produced by ext_profile_ave.m
%product='h2o_profile' % H2O profile produced by h2o_profile_ave.m
plot_loc_map='yes'
Cimel='no'
MISR='no'
TOMS='no'
ATSR='no'
MODIS='no'
Kosan_METRI='no'
write_g_file='no' % This is to write file about spatial variability
NIMFR='no' 

AOD_Cimel_err=[0.02 0.015  0.015     0.015     0.01    0.01     0.01     0.01    ];
% lambda_MISR= [0.446 0.558 0.672     0.866];
% lambda_TOMS= [0.380];
% lambda_ATSR= [0.555	 0.659	 0.865	1.6];
% lambda_MODIS=[0.47,  0.55,   0.66, 0.86, 1.24, 1.64, 2.1];


switch lower(product)
    case 'h2o_profile'
        [filename,pathname]=uigetfile('c:\beat\data\ALIVE\Ver2\*_pw.asc','Choose file', 0, 0);
        fid=fopen([pathname filename]);
        fgetl(fid);
        title1=fgetl(fid);
        for i=1:10
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
        fgetl(fid);
        fgetl(fid);
        data=fscanf(fid,'%g',[11,inf]);
        fclose(fid);
        UT=data(1,:);
        Latitude=data(2,:);
        Longitude=data(3,:);
        GPS_Altitude=data(4,:);
        Pressure_Altitude=data(5,:);
        Pressure=data(6,:);
        H2O=data(7,:);
        H2O_Error=data(8,:);
        H2O_dens=data(9,:);
        H2O_dens_err=data(10,:);
        H2O_dens_is_mean=data(11,:);
    case 'aod_normal'
        switch lower(site)
            case 'alive'
                [filename,pathname]=uigetfile('c:\beat\data\ALIVE\Ver2\*_r.asc','Choose file');
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                date=sscanf(title1,'%*s %d/%d/%d');
                day=date(2); month=date(1); year=date(3);
                for i=1:10
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
                a0=data(38,:)
            case 'adam'
                [filename,pathname]=uigetfile('c:\beat\data\ADAM\*_r.asc','Choose file');
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                date=sscanf(title1,'%*s %d/%d/%d');
                day=date(2); month=date(1); year=date(3);
                for i=1:10
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
                a0=data(38,:)
            case 'aerosol iop'
                [filename,pathname]=uigetfile('c:\beat\data\Aerosol IOP\Results_v2.1\*_r.asc','Choose file');
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                date=sscanf(title1,'%*s %*s %d/%d/%d');
                day=date(2); month=date(1); year=date(3);
                for i=1:10
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
            case 'ames'
            case 'mauna loa',
            case 'clams'
                [filename,pathname]=uigetfile('c:\beat\data\CLAMS\Results\*.asc','Choose file', 0, 0);
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
                [filename,pathname]=uigetfile('c:\beat\data\ACE-Asia\Results\*.asc','Choose file', 0, 0);
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                for i=1:10
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
                [filename,pathname]=uigetfile('c:\beat\data\SAFARI-2000\Results\*.asc','Choose file', 0, 0);
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                for i=1:10
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
            case 'ace-asia'
                [filename,pathname]=uigetfile('c:\beat\data\ACE-Asia\Results\*.asc','Choose file', 0, 0);
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1])
                for i=1:10
                    fgetl(fid);
                end
                lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
                fgetl(fid);
                fgetl(fid);
                switch version
                    case {1, 1.5, 2}
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
                    case {3}
                        data=fscanf(fid,'%g',[64,inf]);
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
                        Extinction_Error=data(49:61,:);
                        gamma_ext=-data(62,:);
                        alpha_ext=-data(63,:);
                        a0_ext=data(64,:);                        
                end
                
            case 'aerosol iop'       
                [filename,pathname]=uigetfile('c:\beat\data\aerosol iop\Results_v2.1\*p.asc','Choose file');
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                file_date=sscanf(title1,'Aerosol IOP%g/%g/%g');     %get date
                month=file_date(1);
                day=file_date(2);
                year=file_date(3);
                version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1])
                for i=1:10
                    fgetl(fid);
                end
                lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
                fgetl(fid);
                fgetl(fid);
                
                data=fscanf(fid,'%g',[64,inf]);
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
                Extinction_Error=data(49:61,:);
                gamma_ext=-data(62,:);
                alpha_ext=-data(63,:);
                a0_ext=data(64,:);                        
                           
              case 'alive'       
                [filename,pathname]=uigetfile('c:\beat\data\alive\Ver2\*p.asc','Choose file');
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                file_date=sscanf(title1,'ALIVE %g/%g/%g');     %get date
                month=file_date(1);
                day=file_date(2);
                year=file_date(3);
                version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1])
                for i=1:10
                    fgetl(fid);
                end
                lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g')
                fgetl(fid);
                fgetl(fid);
                
                data=fscanf(fid,'%g',[64,inf]);
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
                Extinction_Error=data(49:61,:);
                gamma_ext=-data(62,:);
                alpha_ext=-data(63,:);
                a0_ext=data(64,:);                           
                
            case 'safari-2000'
                [filename,pathname]=uigetfile('c:\beat\data\SAFARI-2000\Results\*.asc','Choose file', 0, 0);
                fid=fopen([pathname filename]);
                fgetl(fid);
                title1=fgetl(fid);
                for i=1:10
                    fgetl(fid);
                end
                lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g')
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
                AOD_Error=data(19:30,:);
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
    case 'aod_normal'
        %Apply time boundaries
        L=(UT>=UT_start & UT<=UT_end);
        UT=UT(L);
        Latitude=Latitude(L);
        Longitude=Longitude(L);
        GPS_Altitude=GPS_Altitude(L);
        Pressure_Altitude=Pressure_Altitude(L);
        Pressure=Pressure(L);
        H2O=H2O(L);
        H2O_Error=H2O_Error(L);
        AOD_flag=AOD_flag(L);
        AOD=AOD(:,L);
        AOD_Error=AOD_Error(:,L);
        gamma=gamma(L);
        alpha=alpha(L);
        a0=a0(L);
        
        if strcmp(plot_loc_map,'yes')
            edge = 0.2;
            low_alt=0.100;
            figure(1111)
            worldmap([min(Latitude)-edge,max(Latitude)+edge],[min(Longitude)-edge,max(Longitude)+edge])
            plotm(Latitude,Longitude,'LineWidth',2)
            hold on
            plotm(Latitude(AOD_flag==1),Longitude(AOD_flag==1),'m.','MarkerSize',8)
            if size(Longitude(AOD_flag==1 & GPS_Altitude<low_alt))~=0
                plotm(Latitude(AOD_flag==1 & GPS_Altitude<low_alt),Longitude(AOD_flag==1&GPS_Altitude<low_alt),'g.','MarkerSize',6)
            end
            jj=ceil(min(UT));
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
            setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
            states = shaperead('usastatehi', 'UseGeoCoords', true);
            symbols = makesymbolspec('Polygon',{'Name', 'California', 'FaceColor', [0.7 0.7 0.4]});
            geoshow(states, 'SymbolSpec', symbols,'DefaultFaceColor', 'blue','DefaultEdgeColor', 'black')
            hidem(gca)
            if strcmp(lower(site),'ace-asia')
                plotm(33.283,126.167,'ms','MarkerSize',8,'MarkerFaceColor','m')   %Cheju, Kosan AERONET site
            end
            if strcmp(lower(site),'aerosol iop')
                plotm(36.605,-97.485,'ms','MarkerSize',8,'MarkerFaceColor','r')   %SGP AERONET site
            end    
        end
        
        figure(1)
        subplot(6,1,1)
        plot(UT,AOD','.')
        subplot(6,1,2)
        plot(UT(AOD_flag==1),AOD(:,AOD_flag==1)','.')
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
        grid on
        subplot(2,1,2) 
        plot(UT,H2O,'.',UT,H2O+H2O_Error,'b',UT,H2O-H2O_Error,'b')
        
        figure(3)
        subplot(3,1,1)
        plot(Longitude,Latitude,'.-')
        axis square
        subplot(3,1,2)
        plot(UT,Longitude,'.')
        subplot(3,1,3)
        plot(UT,Latitude,'.')
        
        figure(4)
        subplot(2,1,1)
        plot(UT(AOD_flag==1),AOD(:,AOD_flag==1)','.-')
        xlabel('UT','FontSize',14)
        ylabel('AOD','FontSize',14)
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
        subplot(2,1,2)
        plot(UT(AOD_flag==1),alpha(AOD_flag==1),'.-',UT(AOD_flag==1),gamma(AOD_flag==1),'.-')
        legend('alpha','gamma')
        grid on
        xlabel('UT','FontSize',14)
        ylabel('Spectrum','FontSize',14)
        set(gca,'FontSize',14)
        
        figure(5)
        %plot AOD as a function of distance to assess variability
        [m,n]=size(AOD(:,AOD_flag==1));
        [value,anchor]=min(Latitude)
        
        rng=distance(ones(1,length(Latitude))*Latitude(anchor),ones(1,length(Longitude))*Longitude(anchor),Latitude,Longitude);
        rng=deg2km(rng);
        subplot(4,1,1)
        plot(rng(AOD_flag==1),AOD(:,AOD_flag==1),'.-')
        grid on
        title([title1,sprintf(' %5.2f-%5.2f %s',min(UT),max(UT),' UT')],'FontSize',14);
        if strcmp(site,'SAFARI-2000') 
            legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
                num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'));
        end
        if strcmp(site,'ACE-Asia')  | strcmp(site,'Aerosol IOP')
            legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
                num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
        end
        subplot(4,1,2)
        %plot(rng(AOD_flag==1),AOD(:,AOD_flag==1)./(mean(AOD(:,AOD_flag==1)')'*ones(1,n)),'.-')
        plot(rng(AOD_flag==1),AOD(:,AOD_flag==1)./(AOD(:,anchor)*ones(1,n)),'.-')
        grid on
        xlabel('Distance [km]')
        subplot(4,1,3)
        plot(rng,H2O,'.-')
        grid on
        subplot(4,1,4)
        plot(rng,H2O./mean(H2O))
        plot(rng,H2O./H2O(anchor))
        grid on
        xlabel('Distance [km]')
        
        range_AOD=max(rng(AOD_flag==1))
        ratio=AOD(:,AOD_flag==1)./(mean(AOD(:,AOD_flag==1)')'*ones(1,n));
        
        g_AOD=(max(ratio')-min(ratio'))/range_AOD
        g_AOD_std=std(AOD(:,AOD_flag==1)')./mean(AOD(:,AOD_flag==1)')/range_AOD
        
        range_H2O=max(rng)
        ratio=H2O./mean(H2O);
        g_H2O=(max(ratio')-min(ratio'))/range_H2O
        g_H2O_std=std(H2O)./mean(H2O)/range_H2O
        
        if strcmp(write_g_file,'yes')
            %write a file with g values
            [pathstr,name,ext,versn]=fileparts(filename);
            resultfile=['gradient.txt']
            fid=fopen([pathname resultfile],'a');
            fprintf(fid,'%s %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',...
                name,UT_start, UT_end, range_AOD,g_AOD,g_AOD_std,range_H2O,g_H2O,g_H2O_std);
            fclose(fid);
        end
        
        figure(6)
        %AOD
        ind=find(AOD_flag==1);
        lambda_fit=[0.325:0.025:2.2];
        j=1;
        for i=ind
            loglog(lambda,AOD(:,i),'mo');
            hold on
            yerrorbar('loglog',0.3,1.6, 0.001, .4,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
            AOD_fit(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_fit)));
            loglog(lambda_fit,AOD_fit(j,:));
            hold off
            set(gca,'xlim',[.300 2.20]);
            set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6 1.8 2 2.2]);
            set(gca,'ylim',[0.001 .4]);
            title(title1);
            xlabel('Wavelength [microns]');
            ylabel('Optical Depth')
            pause (0.01)
            j=j+1;
        end

        %Plot AOD spectrum averaged from UT_start to UT_end
        if strcmp(NIMFR,'yes')  % for AIOP 2003 only
            lambda_NIMFR=[415,500,615,673,870]/1e3;
            AOD_NIMFR_err=[0.01 0.01 0.01 0.01 0.01];
            xx=num2str(day,'%02i');
            data=load(['C:\Beat\Data\Aerosol IOP\NIMFR\nimfr.aot.may', xx]);
            UT_NIMFR=data(:,1);
            UT_target=(UT_start+UT_end)/2
            i_NIMFR=interp1(UT_NIMFR,1:length(UT_NIMFR),UT_target,'nearest','extrap');
            AOD_NIMFR=data(i_NIMFR,4:8);
            UT_NIMFR= UT_NIMFR(i_NIMFR);
            Delta_t=(UT_NIMFR-UT_target)*60
            clear data;

            target=[-97.485,36.605]; %long, lat SGP central cluster according to ARM
            target_alt=.319;

            figure(6)
            %AOD
            ind=find(AOD_flag==1);
            lambda_fit=[0.325:0.025:2.2];
            j=1;
            for i=ind
                loglog(lambda,AOD(:,i),'mo');
                hold on
                yerrorbar('loglog',0.3,1.6, 0.001, 3,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
                AOD_fit(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_fit)));
                AOD_fit_NIMFR(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_NIMFR)));
                loglog(lambda_fit,AOD_fit(j,:));
                hold off
                set(gca,'xlim',[.300 2.20]);
                set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6 1.8 2 2.2]);
                set(gca,'ylim',[0.001 2]);
                title(title1);
                xlabel('Wavelength [microns]');
                ylabel('Optical Depth')
                pause (0.01)
                j=j+1;
            end


            AOD_fit_NIMFR_mean=mean(AOD_fit_NIMFR);
            figure(7)
            loglog(lambda_NIMFR,AOD_NIMFR,'rs','MarkerSize',9,'MarkerFaceColor','r');
            hold on
            AOD_delta_NIMFR=AOD_NIMFR-AOD_fit_NIMFR_mean;
        end
        
        
        %Plot AOD spectrum averaged from UT_start to UT_end
        if strcmp(Cimel,'yes')
            %AOD_Cimel=[0.023276    0.025902    0.042234    0.072873    0.081844    0.117736    0.146426]   %Aug 17, 2000,08:05:18 Skukuza Level 2
            %AOD_Cimel=[0.027149   ,0.028996   ,0.051519   ,0.083233   ,0.091553   ,0.136038   ,0.166797]   %Aug 17, 2000,09:43:43 Skukuza Level 2
            %AOD_Cimel=[0.101225    0.132666    0.234913	0.425585	0.520358	0.682056    0.800609];  %Aug 22, 2000, Interpolated to 10:06 Skukuza Level 2
            %AOD_Cimel=[0.100989	0.130676	0.226212	0.414339	0.508728	0.662986	0.778548];	%Aug 22, 2000,  Skukuza 8:27:35 (Terra Overpass) Level 2
            %target=[31.585,-24.972]; %long, lat Skukuza
            %target_alt=0.150;
            
            %AOD_Cimel=[0.114967    0.155934	0.23813	    0.358868	0.428172	0.536236	0.598034];% Aug 24, 2000   8:37:33 Inhaca Island Level 2
            %AOD_Cimel=[0.10258	    0.140997	0.219652	0.332219	0.398107	0.500058	0.558795];% Aug 24, 2000   8:22:32 Inhaca Island Level 2 (Terra Overpass)
            %target=[32.9050,-26.041]; %long, lat Inhaca
            %target_alt=0.073;
            
            %AOD_Cimel=[0.129905	0.18128	    0.325315	0.58241	    0.717418	0.90976	    1.061124];% Sep 1,  2000   8:36:15 Kaoma, Level 2
            %AOD_Cimel=[0.108952    0.172748	0.308456	0.563022	0.689595	0.867243	1.020407];% Sep 1,  2000   9:09:34 Kaoma, Level 1
            %target=[24.7948,-14.7926]; %long, lat Kaoma
            %target_alt=1.179;
             
            %AOD_Cimel=[0.189477	0.282863	0.512417	NaN	        1.124408	NaN         NaN     ];% Sep 03, 2000,  8:45:37 UT, Sua Pan, Level 2,
            %target=[26.0667,-20.5167]; %long, lat Sua Pan
            %target_alt=0.900;
            
            %AOD_Cimel=[0.331086	0.473774	0.809929	1.41482	    1.708725	2.059931	2.311603];% Sep 06, 2000,  7:55:46 UT, Senanga, Level 2
            %target=[23.2977,-16.1115]; %long, lat Senanga
            %target_alt=1.025;
            
            %AOD_Cimel=[0.310551	0.445488	0.768765	1.345765	1.611428	1.946164	2.183868];% Sep 06, 2000,  8:11:41 UT, Mongu, Level 2
            %AOD_Cimel=[0.310781	0.447566	0.774888	1.354877	1.624222	1.961968	2.207142];% Sep 06, 2000,  9:11:43 UT, Mongu Level 2
            %AOD_Cimel=[0.304739	0.438461	0.760858	1.328046	1.595065	1.933854	2.174415];% Sep 06, 2000, 10:11:16 UT, Mongu Level 2
            %target=[23.1500,-15.2500]; %long, lat Mongu
            %target_alt=1.107;
            
            %AOD_Cimel=[0.084465	0.109181	0.17236  	0.283369	0.326764	0.405387	0.454072];% Sep 16, 2000,  9:21:46 UT, Etosha Pan Level 2
            %AOD_Cimel=[0.073286	    0.097409	0.153234	0.249464	0.287107	0.366537	0.406768];% Sep 16, 2000,  10:51:48 UT, Etosha Pan Level 2
            %target=[15.914,-19.175]; %long, lat Etosha Pan
            %target_alt=1.131;
                
            %AOD_Cimel=[0.049602,0.064127,0.069911,0.100280,0.123757,0.154819,0.172129]; %  16:04:2001,02:21:09 Gosan Jeju Island Korea  Level 2.0 
            %AOD_Cimel=[0.173347,0.205160,0.253651,0.346431,0.408474,0.479145,0.530593]; %  06:04:2001,01:46:17,Gosan Jeju Island Korea  Level 2.0 
            %AOD_Cimel=[0.257546,0.280058,0.304914,0.363515,0.403980,0.449889,0.483150];  %  12:04:2001,03:22:24,Gosan Jeju Island Korea  Level 2.0 
            %AOD_Cimel=[0.400083,0.428987,0.464427,0.541067,0.578911,0.635054,0.679437];  %  17:04:2001,05:44:22,Gosan Jeju Island Korea  Level 2.0 
            
            %target=[126.167,33.283]; %long, lat Kosan
            %target_alt=0;
            
            
            % read in AERONET Data
            [lambda_Cimel,AOD_Cimel_err,Time_Cimel,DOY_Cimel,AOD_Cimel,CWV_Cimel]=read_AERONET_04;
            UT_target=(UT_start+UT_end)/2;
            DOY_AATS14=DayOfYear(day,month,year)+UT_target/24;
            i_Cimel=interp1(DOY_Cimel,1:length(DOY_Cimel),DOY_AATS14,'nearest','extrap');
            DOY_Cimel=DOY_Cimel(i_Cimel);
            Delta_t=(DOY_Cimel-DOY_AATS14)*24*60
            AOD_Cimel=AOD_Cimel(i_Cimel,:);
            CWV_Cimel=CWV_Cimel(i_Cimel);
            lambda_Cimel=lambda_Cimel(i_Cimel,:);
            
            target=[-97.485,36.605]; %long, lat SGP central cluster according to ARM
            target_alt=.319;

            
            figure(6)
            %AOD
            ind=find(AOD_flag==1);
            lambda_fit=[0.325:0.025:2.2];
            j=1;
            for i=ind
                loglog(lambda,AOD(:,i),'mo');
                hold on
                yerrorbar('loglog',0.3,1.6, 0.001, 3,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
                AOD_fit(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_fit)));
                AOD_fit_Cimel(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_Cimel)));
%                 AOD_fit_MISR(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_MISR)));
%                 AOD_fit_MODIS(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_MODIS)));
                loglog(lambda_fit,AOD_fit(j,:));
                hold off
                set(gca,'xlim',[.300 2.20]);
                set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6 1.8 2 2.2]);
                set(gca,'ylim',[0.001 2]);
                title(title1);
                xlabel('Wavelength [microns]');
                ylabel('Optical Depth')
                pause (0.01)
                j=j+1;
            end
   
            
            AOD_fit_Cimel_mean=mean(AOD_fit_Cimel);
            figure(7)
            %loglog(lambda_Cimel,AOD_fit_Cimel_mean,'b-');
            loglog(lambda_Cimel,AOD_Cimel,'rs','MarkerSize',9,'MarkerFaceColor','r');
            hold on
            AOD_delta_Cimel=AOD_Cimel-AOD_fit_Cimel_mean;
        end
        
        if strcmp(MISR,'yes')
            %AOD_MISR_unity=[1.073       1.000       0.952       0.863]; %  Mixture 11
            %AOD_MISR_unity=[1.194       1.000       0.843       0.637]; %  Mixture 21
            %AOD_MISR_unity=[1.247       1.000       0.794       0.537];  % Mixture 51  
            %AOD_MISR_unity=[1.253       1.000       0.793       0.537];%  Mixture 52 
            AOD_MISR_unity=[1.176       1.000       0.845       0.634]; %  Mixture 55
            
            AOD_MISR_558=[0.380]; %August, 22, 2000 SAFARI-2000 Skukuza, 8:28 UT
            %AOD_MISR_558=[0.927]; %September, 03, 2000 SAFARI-2000 Sua Pan 8:52 UT, -20.483S 26.069E
            %AOD_MISR_558=[0.904]; %September, 03, 2000 SAFARI-2000 Sua Pan 8:52 UT, -20.641S 26.055E
            %AOD_MISR_558=[0.818]; %September, 03, 2000 SAFARI-2000 Sua Pan 8:52 UT, -20.628S 25.886E that is a fill in from next pixel North.
            %AOD_MISR_558=[0.571]; %September 11, 2000 SAFARI-2000  Off Namibia,9:37:38 UT,  -21.416 S, 12.335 E (center of pixel)
            %AOD_MISR_558=[0.813]; %September 11, 2000 SAFARI-2000  Off Namibia,9:37:38 UT,  -21.564 S, 12.321 E (center of pixel)
            %AOD_MISR_558=[0.278]; %April 13, 2001 ACE-Asia 4:46 UT
            
            AOD_MISR=AOD_MISR_558*AOD_MISR_unity;
            AOD_MISR_err= [0.05 0.05 0.05 0.05];
            
            AOD_fit_MISR_mean=mean(AOD_fit_MISR);
            % loglog(lambda_MISR,AOD_fit_MISR_mean,'b.');
            loglog(lambda_MISR,AOD_MISR,'mo','MarkerSize',8,'MarkerFaceColor','m');
            AOD_delta_MISR=AOD_MISR-AOD_fit_MISR_mean;
            hold on
            
        end
        
        if strcmp(TOMS,'yes')
            % TOMS 
            %AOD_TOMS=[0.553]; %Sept 2, 2000 SAFARI-2000
            %target=[23.69,-19.83]; %long, lat center of TOMS pixel
            
            AOD_TOMS=[2.38];   %Sept 6, 2000 SAFARI-2000
            target=[23.31,-15.31]; %long, lat center of TOMS pixel
            
            %AOD_TOMS=[0.065]; %Sept 7, 2000 SAFARI-2000
            %target=[30.85,-24.3]; %long, lat center of TOMS pixel
            
            AOD_TOMS_err=max([0.1, 0.3*AOD_TOMS]); %Error is 0.1 or 30% whichever is larger for absorbing aerosols
            %AOD_TOMS_err=max([0.1, 0.2*AOD_TOMS]); %Error is 0.1 or 20% whichever is larger for non-absorbing
            
            loglog(lambda_TOMS,AOD_TOMS,'bs','MarkerSize',8,'MarkerFaceColor','b');
            hold on
            rng=distance(ones(1,length(Latitude))*target(2),ones(1,length(Longitude))*target(1),Latitude,Longitude);
            rng=deg2km(rng);
            target_dist=mean(rng);
        end
        
        if strcmp(ATSR,'yes')
            % ATSR 
            AOD_ATSR=[0.14506	0.12033	0.10329	0.11908]; %North Box 9.13	-26.3 to -26.25	13.7 to 13.8 Sept 14, 2000 SAFARI-2000 off Namibian Coast
            target=[13.75,-26.275]; %long, lat center of ATSR Box
            
            % AOD_ATSR=[0.13564	0.11158	0.094133 0.10573];%South Box 9.13	-26.4 to -26.35	13.7 to 13.8 Sept 14, 2000 SAFARI-2000 off Namibian Coast
            loglog(lambda_ATSR,AOD_ATSR,'gs','MarkerSize',8,'MarkerFaceColor','g');
            hold on
            rng=distance(ones(1,length(Latitude))*target(2),ones(1,length(Longitude))*target(1),Latitude,Longitude);
            rng=deg2km(rng);
            target_dist=mean(rng);
        end
        
        % MODIS
        if strcmp(MODIS,'yes')
            %AOD_MODIS=   [0.404, 0.1536, 0.05, NaN,  NaN,  NaN,  NaN];  % Skukuza       Aug 22, 2000
            %AOD_MODIS=   [0.32,  0.28,   0.24, 0.18, 0.12, 0.09, 0.06]; % Inhaca Island Aug 24, 2000
            AOD_MODIS=    [0.43,  0.25,   0.14, NaN,  NaN,  NaN,  NaN];  % Kaoma         Sep 01, 2000
            AOD_MODIS_err=[0.02,  0.03,   0.03, NaN,  NaN,  NaN,  NaN];  % Kaoma         Sep 01, 2000
            AOD_MODIS_4=    [0.51,  0.38, 0.28, NaN,  NaN,  NaN,  NaN];  % Kaoma  v4   Sep 01, 2000
            AOD_MODIS_err_4=[0.032,  0.052,   0.061, NaN,  NaN,  NaN,  NaN];  % Kaoma  v4   Sep 01, 200
            
            loglog(lambda_MODIS,AOD_MODIS,'gs','MarkerSize',8,'MarkerFaceColor','g');
            hold on
            loglog(lambda_MODIS,AOD_MODIS_4,'gs','MarkerSize',8,'MarkerFaceColor','w');
            
            AOD_fit_MODIS_mean=mean(AOD_fit_MODIS);
            %loglog(lambda_MODIS,AOD_fit_MODIS_mean,'b*');
            AOD_delta_MODIS=AOD_MODIS-AOD_fit_MODIS_mean    
        end
        
        if strcmp(Kosan_METRI,'yes')
            lambda_METRI=[0.368 0.500 0.675 0.778 0.862]; 
            %AOD_METRI=    [0.374 0.228 0.128 0.152 0.072]; % April 16 Day 106 11.367 LT = 2:22 UT
            %AOD_METRI=    [0.640 0.397 0.289 0.284 0.191]; % April  6 Day  96 11.700 LT=  1:42 UT
            %AOD_METRI=    [0.682 0.455 0.368 0.374 0.280]; % April 12 Day 102 12.283 LT = 3:17 UT
            AOD_METRI=    [0.830 0.615 0.513 0.523 0.441]; % April 17 Day 107 14.733 LT = 5:44 UT
            loglog(lambda_METRI,AOD_METRI,'bo','MarkerSize',8,'MarkerFaceColor','b');
        end
        
        figure(7)
        AOD_max=max(AOD(:,AOD_flag==1)');
        AOD_min=min(AOD(:,AOD_flag==1)');
        AOD_std=std(AOD(:,AOD_flag==1)');
        AOD_mean=mean(AOD(:,AOD_flag==1)');
        AOD_err=mean(AOD_Error(:,AOD_flag==1)');
        %AOD_fit_mean=mean(AOD_fit);
        loglog(lambda,AOD_mean,'ko','MarkerSize',8,'MarkerFaceColor','k');
        hold on
        %loglog(lambda_fit,AOD_fit_mean,'k');
        set(gca,'ylim',[0.01 1]);
        set(gca,'xlim',[.30 2.2]);
        set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8, 2.0,2.2]);
        xlabel('Wavelength [\mum]','FontSize',14);
        ylabel('Aerosol Optical Depth','FontSize',14);
        set(gca,'FontSize',14)
        grid on
        
        if strcmp(MISR,'yes')& strcmp(Cimel,'yes')
            legend('Cimel','MISR','AATS14')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_MISR,AOD_MISR,AOD_MISR_err,'mo')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,AOD_Cimel,AOD_Cimel_err,'rs')
        end
        
        if strcmp(TOMS,'yes')& strcmp(Cimel,'no')
            legend('TOMS','AATS14')
            yerrorbar('loglog',0.3,1.6,0.01, 4,lambda_TOMS,AOD_TOMS,AOD_TOMS_err,'bs')
        end
        
        if strcmp(TOMS,'yes')& strcmp(Cimel,'yes')
            legend('Cimel','TOMS','AATS14')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,AOD_Cimel,AOD_Cimel_err,'ro')
            yerrorbar('loglog',0.3,1.6,0.01, 4,lambda_TOMS,AOD_TOMS,AOD_TOMS_err,'bs')
        end
        
        if strcmp(MISR,'no')& strcmp(Cimel,'yes') & strcmp(TOMS,'no')
            legend('Cimel','AATS-14')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,AOD_Cimel,AOD_Cimel_err,'rs')
            rng=distance(ones(1,length(Latitude))*target(2),ones(1,length(Longitude))*target(1),Latitude,Longitude);
            rng=deg2km(rng);
            target_dist=mean(rng);
            
            %append comparison to file
            resultfile='cimel_aats14.txt';
            if strcmp(lower(site),'ace-asia')
              fid=fopen(['c:\beat\data\safari-2000\cimel\',resultfile],'a');
            end
            if strcmp(lower(site),'aerosol iop')
              fid=fopen(['c:\beat\data\aerosol iop\aeronet\',resultfile],'a');
            end 
            fprintf(fid,'%s',filename)
            fprintf(fid,' %g',UT_start,UT_end,DOY_Cimel,Delta_t,target_dist,target_alt,mean(GPS_Altitude),mean(Pressure_Altitude),AOD_Cimel,AOD_fit_Cimel_mean,AOD_mean,...
                   AOD_err,AOD_fit_mean,CWV_Cimel,mean(H2O),mean(H2O_Error),lambda_Cimel);
            fprintf(fid,'\r\n');
            fclose(fid);
        end
        
        if  strcmp(NIMFR,'yes')
            legend('NIMFR','AATS-14')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_NIMFR,AOD_NIMFR,AOD_NIMFR_err,'rs')
            rng=distance(ones(1,length(Latitude))*target(2),ones(1,length(Longitude))*target(1),Latitude,Longitude);
            rng=deg2km(rng);
            target_dist=mean(rng);
            
            %append comparison to file
            resultfile='nimfr_aats14.txt';
            if strcmp(lower(site),'aerosol iop')
              fid=fopen(['c:\beat\data\aerosol iop\nimfr\',resultfile],'a');
            end 
            fprintf(fid,'%s',filename)
            fprintf(fid,' %g',UT_start,UT_end,UT_NIMFR,Delta_t,target_dist,target_alt,mean(GPS_Altitude),mean(Pressure_Altitude),AOD_NIMFR,AOD_fit_NIMFR_mean,AOD_mean,...
                   AOD_err,AOD_fit_mean,lambda_NIMFR);
            fprintf(fid,'\r\n');
            fclose(fid);
        end
        
        if strcmp(ATSR,'yes')
            legend('ATSR-2','AATS14')
        end
        
        if strcmp(MODIS,'yes')& strcmp(Cimel,'yes')
            legend('Cimel','MODIS','MODIS ver 4','AATS14')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_MODIS,AOD_MODIS,AOD_MODIS_err,'gs')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_MODIS,AOD_MODIS_4,AOD_MODIS_err_4,'gs')
            yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,AOD_Cimel,AOD_Cimel_err,'rs')
        end
        
        if strcmp(Kosan_METRI,'yes')& strcmp(Cimel,'yes')
            legend('AERONET','METRI','AATS-14')
        end
        
        %yerrorbar('loglog',0.3,1.6, 1e-2  ,2.5,lambda,AOD_mean,-AOD_min+AOD_mean,AOD_max-AOD_mean,'mo')
        yerrorbar('loglog',0.3,2.2, 1e-2  ,2.5,lambda,AOD_mean,AOD_err,'ko')
        %yerrorbar('loglog',0.3,1.6, 1e-2  ,2.5,lambda,AOD_mean,2*AOD_std,'ko')
        
        title([title1,sprintf(' %5.3f-%5.3f %s',min(UT),max(UT),' UT')],'FontSize',14);
        text(0.4,0.1,sprintf('Altitude= %5.3f km alpha= %4.2f gamma= %4.2f',mean(GPS_Altitude),mean(alpha),mean(gamma)),'FontSize',14)
        hold off
        
        if strcmp(Cimel,'yes') | strcmp(NIMFR,'yes')
            figure(41)
            %plot(UT,rng,'.-',UT(AOD_flag==1),rng(AOD_flag==1),'g.')
            plot(UT,rng,'.-',UT(AOD_flag==1 & GPS_Altitude<low_alt),rng(AOD_flag==1 & GPS_Altitude<low_alt),'g.')
            grid on  
        end    
        
        
    case 'aod_profile'
        Altitude=GPS_Altitude;    
        
        %plot AOD and Extinction profile with error bars
        figure(1)
        subplot(1,2,1)
        %xerrorbar('linlin',-inf, inf, -inf, inf, AOD', (ones(13,1)*Altitude)', AOD_Error','.')
        plot(AOD, Altitude,'.')
        xlabel('Aerosol Optical Depth','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        grid on
        set(gca,'FontSize',14) 
        set(gca,'ylim',[0 6])
        title(title1);
        subplot(1,2,2)
        %xerrorbar('linlin',-inf, inf, -inf, inf, Extinction', (ones(13,1)*Altitude)', Extinction_Error','.')
        plot(Extinction,Altitude,'.')
        xlabel('Aerosol Extinction [1/km]','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        grid on
        set(gca,'ylim',[0 6])
        %set(gca,'xlim',[0 0.5])
        title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
        set(gca,'FontSize',14) 
        if strcmp(site,'SAFARI-2000') 
            legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
                num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'));
        end
        if strcmp(site,'ACE-Asia') |  strcmp(site,'Aerosol IOP')
            legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
                num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
        end
        
        %         figure(1)
        %         orient landscape
        %         subplot(1,2,1)
        %         plot(AOD,Altitude,'.')
        %         xlabel('Aerosol Optical Depth','FontSize',14)
        %         ylabel('Altitude [km]','FontSize',14)
        %         set(gca,'FontSize',14)
        %         set(gca,'ylim',[0 4])
        %         title(title1);
        %         grid on
        %         subplot(1,2,2)
        %         plot(Extinction,Altitude,'.-')
        %         xlabel('Aerosol Extinction [1/km]','FontSize',14)
        %         ylabel('Altitude [km]','FontSize',14)
        %         set(gca,'FontSize',14)
        %         set(gca,'ylim',[0 4])
        %         set(gca,'xlim',[0 0.5])
        %         title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
        %         grid on
        %         if strcmp(site,'SAFARI-2000') 
        %             legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        %                 num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'));
        %         end
        %         if strcmp(site,'ACE-Asia') 
        %             legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        %                 num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
        %         end
        
        figure(2)
        orient landscape
        subplot(1,2,1)
        plot(alpha,Altitude,'c.',gamma,Altitude,'m.')
        xlabel('AOD Spectrum','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        set(gca,'FontSize',14)
        grid on
        legend('alpha','gamma')
        set(gca,'ylim',[0 6])
        set(gca,'xlim',[-1 3])
        title(title1);
        subplot(1,2,2)
        plot(alpha_ext,Altitude,'c.',gamma_ext,Altitude,'m.')
        xlabel('Extinction Spectrum','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        set(gca,'FontSize',14)
        set(gca,'ylim',[0 6])
        set(gca,'xlim',[-1 3])
        title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
        grid on
        legend('alpha','gamma')
        
        figure(4)
        % AOD movie
        ind=length(AOD);
        for i=1:ind
            loglog(lambda,AOD(:,i),'mo');
            hold on
            yerrorbar('loglog',0.3,1.6, 0.001, 1,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
            AOD_fit=exp(polyval([-gamma(i),-alpha(i),a0(i)],log([0.3:0.1:2.2])));
            loglog([0.3:0.1:2.2],AOD_fit);
            hold off
            set(gca,'xlim',[.300 2.20]);
            set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2]);
            set(gca,'ylim',[0.001 1]);
            title(title1);
            xlabel('Wavelength [\mum]');
            ylabel('Aerosol Optical Depth')
            pause (0.00000000001)
        end
        
        figure(5)
        % Extinction movie
        ind=length(AOD);
        for i=1:ind
            loglog(lambda,Extinction(:,i),'mo');
            hold on
            %yerrorbar('loglog',0.3,1.6,1e-3, 1,lambda,Extinction(:,i),Extinction_Error(:,i),'mo')
            %0.005*ones(1,length(lambda))
            ext_fit=exp(polyval([-gamma_ext(i),-alpha_ext(i),a0_ext(i)],log([0.3:0.1:2.2])));
            loglog([0.3:0.1:2.2],ext_fit);
            hold off
            set(gca,'xlim',[.300 2.20]);
            set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8,2.0 2.2]);
            set(gca,'ylim',[1e-3 1]);
            xlabel('Wavelength [\mum]','FontSize',14);
            ylabel('Aerosol Extinction [1/km]','FontSize',14)
            title(title1);
            text(0.4,0.1,sprintf('Altitude= %5.3f alpha= %4.2f gamma= %4.2f',GPS_Altitude(i),alpha_ext(i),gamma_ext(i)),'FontSize',14)
            set(gca,'FontSize',14)
            grid on
            pause (0.000000000000001)
        end
    case 'h2o_profile'
        Altitude=GPS_Altitude;    
        figure(6)
        orient landscape
        subplot(1,2,1)
        xerrorbar('linlin',-inf, inf, -inf, inf, H2O, Altitude, H2O_Error,'.')
        xlabel('Columnar Water Vapor [g/cm^2]','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        grid on
        title(title1,'FontSize',14);
        axis([0 1.5 0 4])
        set(gca,'FontSize',14)
        
        subplot(1,2,2)
        xerrorbar('linlin',-inf, inf, -inf, inf, H2O_dens, Altitude, H2O_dens_err,'.')
        xlabel('Water Vapor Density [g/m^3]','FontSize',14)
        ylabel('Altitude [km]','FontSize',14)
        grid on
        title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
        axis([0 10 0 4])
        set(gca,'FontSize',14)
end