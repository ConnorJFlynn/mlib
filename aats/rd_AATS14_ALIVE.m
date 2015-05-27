function prod = rd_AATS14_Alive(product, filename, plots)
%reads the desired product from the supplied file
% product must be "aod_normal", "aod_profile", or "h2o_profile"
% default is "aod_profile"

if ~exist('product','var')
    product = 'aod_profile';
elseif strcmp(lower(product),'aod_profile')
    product = 'aod_profile';
elseif strcmp(lower(product),'aod_normal')
    product = 'aod_normal';
elseif strcmp(lower(product),'h2o_profile')
    product = 'h2o_profile';
else
    disp(['Invalid product specified as:',product]);
    disp(['Set to ''aod_profile'' by default']);
    product = 'aod_profile';
end

if ~exist('plots','var')
    plots = 1<0;
else
    plots = plots>=0;
end

%plots AATS14 result files and compares with other measurements as an option
% clear all
% close all
UT_start=0;
UT_end=inf;
site='ALIVE';

% product='aod_normal'  %aod_normal result produced by plot_re4.m
% % product='aod_profile' % AOD profile produced by ext_profile_ave.m
% %product='h2o_profile' % H2O profile produced by h2o_profile_ave.m

%Reads in data based on product selected
switch lower(product)
    case 'h2o_profile'
        if ~exist('filename', 'var')
            [fname, pname] = uigetfile('*_pw.asc','Choose a pwv file');
        else
            if exist(filename, 'file')&~exist(filename,'dir')
                [pname,fname,ext] = fileparts(filename);
                fname = [fname, ext];
            elseif exist(filename,'dir')
                [fname, pname] = uigetfile([filename,'*_pw.asc'],'Choose a pwv file');
            else
                [fname, pname] = uigetfile(['*_pw.asc'],'Choose a pwv file');
            end
        end
        filename = fname;
        pathname = pname;
        %         [filename,pathname]=uigetfile('C:\case_studies\Alive\data\schmid-aats\atts.01-Mar-2006\Ver2\ext_profs\*_pw.asc','Choose file');
        fid=fopen([pathname filename]);
        fgetl(fid);
        title1=fgetl(fid);
        file_date=sscanf(title1,'ALIVE %g/%g/%g');     %get date
        month=file_date(1);
        day=file_date(2);
        year=file_date(3);
        serial_date = datenum(year, month,day);
%         fid=fopen([pathname, filename]);
%         fgetl(fid);
%         title1=fgetl(fid);
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
        
        prod.product = product;
        prod.time = serial_date + UT/24;
        prod.lat = Latitude;
        prod.lon = Longitude;
        prod.alt_gps = GPS_Altitude;
        prod.alt_pres = Pressure_Altitude;
        prod.pres = Pressure;
        prod.h20 = H2O;
        prod.h20_err = H2O_Error;
        prod.h20_dens = H2O_dens;
        prod.h20_dens_err = H2O_dens_err;
        prod.h20_dens_is_mean = H2O_dens_is_mean;
        prod.lambda = -lambda;

    case 'aod_normal'
        if ~exist('filename', 'var')
            [fname, pname] = uigetfile('*_r.asc','Choose an aod ''r'' file');
        else
            if exist(filename, 'file')&~exist(filename,'dir')
                [pname,fname,ext] = fileparts(filename);
                fname = [fname, ext];
            elseif exist(filename,'dir')
                [fname, pname] = uigetfile([filename,'*_r.asc'],'Choose an aod ''r'' file');
            else
                [fname, pname] = uigetfile(['*_r.asc'],'Choose an aod ''r'' file');
            end
        end
        filename = fname;
        pathname = [pname,filesep];
        %         [filename,pathname]=uigetfile('c:\beat\data\ALIVE\Ver2\*_r.asc','Choose file');
        fid=fopen([pathname filename]);
        fgetl(fid);
        title1=fgetl(fid);
        file_date=sscanf(title1,'ALIVE %g/%g/%g');     %get date
        month=file_date(1);
        day=file_date(2);
        year=file_date(3);
        serial_date = datenum(year, month,day);
        date=sscanf(title1,'%*s %d/%d/%d');
        day=date(2); month=date(1); year=date(3);
        for i=1:10
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
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
        
        prod.product = product;
        prod.time = serial_date + UT/24;
        prod.lat = Latitude;
        prod.lon = Longitude;
        prod.alt_gps = GPS_Altitude;
        prod.alt_pres = Pressure_Altitude;
        prod.pres = Pressure;
        prod.h20 = H2O;
        prod.h20_err = H2O_Error;

        prod.aod = AOD;
        prod.aod_flag = AOD_flag>0;
        prod.aod_err = AOD_Error;
        prod.gamma = -gamma;
        prod.alpha = -alpha;
        prod.a0 = a0; 
        prod.lambda = lambda;
    case 'aod_profile'
        %         [filename,pathname]=uigetfile('c:\beat\data\ALIVE\Ver2\*p.asc','Choose file');
        if ~exist('filename', 'var')
            [fname, pname] = uigetfile('*_p.asc','Choose an aod profile ''p'' file');
        else
            if exist(filename, 'file')&~exist(filename,'dir')
                [pname,fname,ext] = fileparts(filename);
                fname = [fname, ext];
            elseif exist(filename,'dir')
                [fname, pname] = uigetfile([filename,'*_p.asc'],'Choose an aod profile ''p'' file');
            else
                [fname, pname] = uigetfile(['*_p.asc'],'Choose an aod profile ''p'' file');
            end
        end
        filename = fname;
        pathname = pname;

        fid=fopen([pathname filesep filename]);
        fgetl(fid);
        title1=fgetl(fid);
        file_date=sscanf(title1,'ALIVE %g/%g/%g');     %get date
        month=file_date(1);
        day=file_date(2);
        year=file_date(3);
        serial_date = datenum(year, month,day);
        version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1]);
        for i=1:10
            fgetl(fid);
        end
        lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
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
        prod.product = product;
        prod.time = serial_date + UT/24;
        prod.lat = Latitude;
        prod.lon = Longitude;
        prod.alt_gps = GPS_Altitude;
        prod.alt_pres = Pressure_Altitude;
        prod.pres = Pressure;
        prod.aod = AOD;
        prod.aod_err = AOD_Error;
        prod.gamma = gamma;
        prod.alpha = alpha;
        prod.a0 = a0;
        prod.ext = Extinction;
        prod.ext_err = Extinction_Error;
        prod.gamma_ext = -gamma_ext;
        prod.alpha_ext = -alpha_ext;
        prod.a0_ext = a0_ext; 
        prod.lambda = lambda;
end

%plots data based on product selected
if plots
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

            figure(1)
            subplot(6,1,1)
            plot(UT,AOD','.')
            ylabel('AOD all')
            subplot(6,1,2)
            plot(UT(AOD_flag==1),AOD(:,AOD_flag==1)','.')
            ylabel('AOD screened')
            subplot(6,1,3)
            plot(UT,AOD_Error,'.')
            ylabel('AOD err')
            subplot(6,1,4)
            plot(UT(AOD_flag==1),AOD_Error(:,AOD_flag==1),'.')
            ylabel('AOD err screened')
            subplot(6,1,5)
            plot(UT,alpha,'.',UT,gamma,'.')
            legend('\alpha*','\gamma')
            subplot(6,1,6)
            plot(UT(AOD_flag==1),alpha(AOD_flag==1),'.',UT(AOD_flag==1),gamma(AOD_flag==1),'.')
            ylabel('screened')
            xlabel('UT')
            legend('\alpha*','\gamma')

            figure(2)
            subplot(2,1,1)
            plot(UT,Pressure,'.')
            ylabel('Pressure [hPa]')
            grid on
            subplot(2,1,2)
            plot(UT,H2O,'.',UT,H2O+H2O_Error,'b',UT,H2O-H2O_Error,'b')
            ylabel('CWV [cm]')
            xlabel('UT')

            figure(3)
            subplot(3,1,1)
            plot(Longitude,Latitude,'.-')
            axis square
            ylabel('Lat')
            xlabel('Long')
            subplot(3,1,2)
            plot(UT,Longitude,'.')
            ylabel('Long')
            xlabel('UT')
            subplot(3,1,3)
            plot(UT,Latitude,'.')
            ylabel('Lat')
            xlabel('UT')

            figure(4)
            subplot(2,1,1)
            plot(UT(AOD_flag==1),AOD(:,AOD_flag==1)','.-')
            xlabel('UT','FontSize',14)
            ylabel('AOD','FontSize',14)
            set(gca,'FontSize',14)
            grid on
            legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
                num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
            subplot(2,1,2)
            plot(UT(AOD_flag==1),alpha(AOD_flag==1),'.-',UT(AOD_flag==1),gamma(AOD_flag==1),'.-')
            legend('alpha','gamma')
            grid on
            xlabel('UT','FontSize',14)
            ylabel('Spectrum','FontSize',14)
            set(gca,'FontSize',14)

            figure(6)
            %movie of AOD spectra
            ind=find(AOD_flag==1);
            lambda_fit=[0.325:0.025:2.2];
            j=1;
            for i=ind
                loglog(lambda,AOD(:,i),'mo');
                hold on
                %             yerrorbar('loglog',0.3,1.6, 0.001, 3,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
                AOD_fit(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_fit)));
                loglog(lambda_fit,AOD_fit(j,:));
                hold off
                set(gca,'xlim',[.300 2.20]);
                set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6 1.8 2 2.2]);
                set(gca,'ylim',[0.001 .5]);
                title(title1);
                xlabel('Wavelength [microns]');
                ylabel('Optical Depth')
                pause (0.01)
                j=j+1;
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
            set(gca,'ylim',[0 8])
            set(gca,'xlim',[0 0.4])
            title(title1);
            subplot(1,2,2)
            %xerrorbar('linlin',-inf, inf, -inf, inf, Extinction', (ones(13,1)*Altitude)', Extinction_Error','.')
            plot(Extinction,Altitude,'.')
            xlabel('Aerosol Extinction [1/km]','FontSize',14)
            ylabel('Altitude [km]','FontSize',14)
            grid on
            set(gca,'ylim',[0 8])
            set(gca,'xlim',[-0.005 0.2])
            title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
            set(gca,'FontSize',14)
            legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
                num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));

            figure(2)
            orient landscape
            subplot(1,2,1)
            plot(alpha,Altitude,'c.',gamma,Altitude,'m.')
            xlabel('AOD Spectrum','FontSize',14)
            ylabel('Altitude [km]','FontSize',14)
            set(gca,'FontSize',14)
            grid on
            legend('alpha','gamma')
            set(gca,'ylim',[0 8])
            set(gca,'xlim',[-2 2])
            title(title1);
            subplot(1,2,2)
            plot(alpha_ext,Altitude,'c.',gamma_ext,Altitude,'m.')
            xlabel('Extinction Spectrum','FontSize',14)
            ylabel('Altitude [km]','FontSize',14)
            set(gca,'FontSize',14)
            set(gca,'ylim',[0 8])
            set(gca,'xlim',[-2 2])
            title(sprintf('%5.2f-%5.2f %s',min(UT),max(UT),' UT'),'FontSize',14);
            grid on
            legend('alpha','gamma')

            figure(4)
            % AOD movie
            ind=length(AOD);
            for i=1:ind
                loglog(lambda,AOD(:,i),'mo');
                hold on
                %             yerrorbar('loglog',0.3,1.6, 0.001, 0.5,lambda,AOD(:,i),AOD_Error(:,i),AOD_Error(:,i),'mo')
                AOD_fit=exp(polyval([-gamma(i),-alpha(i),a0(i)],log([0.3:0.1:2.2])));
                loglog([0.3:0.1:2.2],AOD_fit);
                hold off
                set(gca,'xlim',[.300 2.20]);
                set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6,1.8,2.0,2.2]);
                set(gca,'ylim',[0.001 .5]);
                title(title1);
                xlabel('Wavelength [\mum]');
                ylabel('Aerosol Optical Depth')
                pause (0.01)
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
                set(gca,'ylim',[1e-3 .2]);
                xlabel('Wavelength [\mum]','FontSize',14);
                ylabel('Aerosol Extinction [1/km]','FontSize',14)
                title(title1);
                text(0.4,0.1,sprintf('Altitude= %5.3f alpha= %4.2f gamma= %4.2f',GPS_Altitude(i),alpha_ext(i),gamma_ext(i)),'FontSize',14)
                set(gca,'FontSize',14)
                grid on
                pause (0.01)
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
end