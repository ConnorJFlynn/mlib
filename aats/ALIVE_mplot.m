%creates ALIVE multiframe plots of aerosol and h2o profiles
%does statistics for H2O comparison with in-situ
%compares with CARL and MPL
clear all
close all
CARL='Yes';
MPL='No';
%product='aod_profile'; % AOD profile produced by ext_profile_ave.m
product='h2o_profile'; % H2O profile produced by h2o_profile_ave.m

if strcmp(MPL,'Yes')
    zmax=8.010; %max altitude for binning [km]
    bw=0.030; %bin width for MPL
end
if strcmp(CARL,'Yes')
    zmax=7.995; %max altitude for binning [km]
    bw=0.039; %bin width for CARL
end

%empty arrays
H2O_dens_all=[];
H2O_dens_is_all=[];
H2O_Error_all=[];
GPS_Altitude_all=[];
AATS_ext353_all=[];
AATS_ext353_Error_all=[];
AATS_AOD353_all=[];
AATS_AOD_Error353_all=[];
AATS_ext519_all=[];
AATS_ext519_Error_all=[];
AATS_AOD519_all=[];
AATS_AOD_Error519_all=[];
CARL_ext_all=[];
MPL_ext_all=[];
CARL_h2o_dens_bin_all=[];
H2O_dens_bin_all=[];
H2O_dens_bin_is_all=[];

%read all AATS-14 extinction profile names in directory
if strcmp(product,'aod_profile')
    pathname='c:\beat\data\ALIVE\Ver2\';
    direc=dir(fullfile(pathname,'*p.asc'));
    [filelist{1:length(direc),1}] = deal(direc.name);
    filelist(25:28,:)=[]; % delete profiles not over SGP
end

%read all AATS-14 water vapor profile names in directory
if strcmp(product,'h2o_profile')
    pathname='c:\beat\data\ALIVE\Ver2\';
    direc=dir(fullfile(pathname,'*pw.asc'));
    [filelist{1:length(direc),1}] = deal(direc.name);
   % filelist([42:47,64],:)=[]; % delete profiles not over SGP
     filelist([1,42:47,64],:)=[]; % delete profiles not over SGP and no CARL data
end

nprofiles=length(filelist);

%for jprof=1:30
for jprof=1:nprofiles;
    filename=char(filelist(jprof,:));
    disp(sprintf('Processing %s (No. %i of %i)',filename,jprof,nprofiles))

    %determine date and flight number from filename
    flt_no=filename(1:5);

    % read AATS-14 profile
    fid=fopen(deblank([pathname,filename]));
    fgetl(fid);
    file_date=fscanf(fid,'ALIVE%g/%g/%g');     %get date
    month=file_date(1);
    day=file_date(2);
    year=file_date(3);
    fgetl(fid);
    version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1]);
    for i=1:10
        fgetl(fid);
    end
    lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
    fgetl(fid);
    fgetl(fid);
    if strcmp(product,'aod_profile')
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

        %bin data in altitude for the AATS-14 wavelengths I need which are 353 nm and 519 nm
        [ResMat]    = binning([GPS_Altitude',Extinction( 1,:)'],bw,0,zmax);
        Altitude    = ResMat(:,1);
        AATS_ext353 = ResMat(:,2);
        [ResMat]    = binning([GPS_Altitude',Extinction_Error( 1,:)'],bw,0,zmax);
        AATS_ext353_Error = ResMat(:,2);
        [ResMat]    = binning([GPS_Altitude',AOD( 1,:)'],bw,0,zmax);
        AATS_AOD353 = ResMat(:,2);
        [ResMat]    = binning([GPS_Altitude',AOD_Error( 1,:)'],bw,0,zmax);
        AATS_AOD_Error353 = ResMat(:,2);
        
        [ResMat]  =binning([GPS_Altitude',Extinction( 5,:)'],bw,0,zmax);
        AATS_ext519 = ResMat(:,2);
        [ResMat]  =binning([GPS_Altitude',Extinction_Error( 5,:)'],bw,0,zmax);
        AATS_ext519_Error = ResMat(:,2);
        [ResMat]  =binning([GPS_Altitude',AOD( 5,:)'],bw,0,zmax);
        AATS_AOD519 = ResMat(:,2);
        [ResMat]  =binning([GPS_Altitude',AOD_Error( 5,:)'],bw,0,zmax);
        AATS_AOD_Error519 = ResMat(:,2);

        clear ResMat;

        %find bottom and top AOD
        ii_AATS=~isnan(AATS_ext519);
        i_bot_AATS=min(find(ii_AATS==1));
        i_top_AATS=max(find(ii_AATS==1));

        %accumulate data
        AATS_ext353_all=[AATS_ext353_all AATS_ext353'];
        AATS_ext353_Error_all=[AATS_ext353_Error_all AATS_ext353_Error'];
        AATS_AOD353_all=[AATS_AOD353_all AATS_AOD353'];
        AATS_AOD_Error353_all=[AATS_AOD_Error353_all AATS_AOD_Error353'];
        
        AATS_ext519_all=[AATS_ext519_all AATS_ext519'];
        AATS_ext519_Error_all=[AATS_ext519_Error_all AATS_ext519_Error'];
        AATS_AOD519_all=[AATS_AOD519_all AATS_AOD519'];
        AATS_AOD_Error519_all=[AATS_AOD_Error519_all AATS_AOD_Error519'];
    end
    if strcmp(product,'h2o_profile')
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
        H2O_dens_is=data(11,:);
        %accumulate data
        H2O_dens_all=[H2O_dens_all H2O_dens];
        H2O_dens_is_all=[H2O_dens_is_all H2O_dens_is];
        H2O_Error_all=[H2O_Error_all H2O_Error];
        GPS_Altitude_all=[GPS_Altitude_all GPS_Altitude];
        layer_H2O_is(jprof)=trapz(GPS_Altitude,H2O_dens_is)/10;
        layer_H2O_AATS14(jprof)=H2O(1)-H2O(end);
        mean_H2O(jprof)=(H2O(1)+H2O(2))/2;
        rng(jprof) = distance(Latitude(1),Longitude(1),Latitude(end),Longitude(end));
    end

    UT_start=min(UT);
    UT_end=max(UT);

    %plots
    hour_start=floor(UT_start);
    hour_end=floor(UT_end);
    min_start=round((UT_start-floor(UT_start))*60);
    min_end=round((UT_end-floor(UT_end))*60);

    col=mod(jprof-1,5);
    row=mod(fix((jprof-1)/5),6);

    if strcmp(product,'aod_profile')
        % plot AOD profile
        figure(1)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(AOD,GPS_Altitude,'.')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.4]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.1:0.4);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(.13,6.8,titlestr1,'FontSize',8);
        text(.13,6.2,titlestr2,'FontSize',8);
        %legend
        %         if row==0 & col==0
        %                     legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        %                         num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
        %         end
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-.05,-2,'Aerosol Optical Depth');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.12,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot extinction profile
        figure(2)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(Extinction,GPS_Altitude,'.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.250]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.250);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'Extinction [km^-^1]');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot AOD spectral shape profile
        figure(3)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(alpha,GPS_Altitude,'c.',gamma,GPS_Altitude,'m.')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[-2 2]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',-2:2);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-3,-2,'Aerosol Optical Depth Spectral Parameters');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        %plot spectral shape profile
        figure(4)

        %don't plot if extinction is low
        ii=all(Extinction(1:12,:)>=0.003);

        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(alpha_ext(ii),GPS_Altitude(ii),'c.',gamma_ext(ii),GPS_Altitude(ii),'m.')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[-2 3]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',[-2 -1 0 1 2 3]);
        set(gca,'ytick',0:8);
        titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
        h1=text(-1.8,7,titlestr);
        set(h1,'FontSize',8)

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-2,-2,'AATS-14 Extinction shape');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
    if strcmp(product,'h2o_profile')
        %plot CWV profile
        figure(1)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(H2O,GPS_Altitude,'b.')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 5]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:5);
        set(gca,'ytick',0:8);
        titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
        h1=text(.1,7,titlestr);
        set(h1,'FontSize',8)
        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-2,-2,'AATS-14 CWV');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-1,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        %plot H2O dens profile
        figure(2)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(H2O_dens,GPS_Altitude,'b.-',H2O_dens_is,GPS_Altitude,'g.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 24]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:4:24);
        set(gca,'ytick',0:8);
        titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
        h1=text(.1,7,titlestr);
        set(h1,'FontSize',8)
        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-2,-2,'AATS-14 CWV');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
     if strcmp(CARL,'Yes') && strcmp(product,'h2o_profile')
        %load CARL data
        [CARL_UT,CARL_aod,CARL_z,CARL_aod_profile,CARL_aod_err,CARL_ext,CARL_ext_err,CARL_r,CARL_p,CARL_t,CARL_h2o_dens]=read_CARL_ALIVE('c:\beat\data\alive\carl\',day,month,year);
        %remove profiles that have only values less or equal 0
        ii=find(all(CARL_r<=0,2)==1);
        CARL_r(ii,:)=[];
        CARL_UT(ii)=[];
        CARL_p(ii,:)=[];
        CARL_t(ii,:)=[];
        CARL_h2o_dens(ii,:)=[];
        ii=interp1(CARL_UT,1:length(CARL_UT),UT_start+1/60,'nearest','extrap');
        jj=interp1(CARL_UT,1:length(CARL_UT),UT_end-1/60,'nearest','extrap');
        nprof=jj-ii+1;
        
        CARL_hour_start=floor(CARL_UT(ii));
        CARL_hour_end=floor(CARL_UT(jj));
        CARL_min_start=round((CARL_UT(ii)-floor(CARL_UT(ii)))*60);
        CARL_min_end=round((CARL_UT(jj)-floor(CARL_UT(jj)))*60);
        
        CARL_t=mean(CARL_t(ii:jj,:),1);
        CARL_h2o_dens=mean(CARL_h2o_dens(ii:jj,:),1);
               
        %binning: bin data in altitude for AATS-14 and CARL
        [ResMat]         = binning([GPS_Altitude',H2O_dens'],bw,0,zmax);
        Altitude         = ResMat(:,1);
        H2O_dens_bin     = ResMat(:,2);
        [ResMat]         = binning([GPS_Altitude',H2O_dens_is'],bw,0,zmax);
        H2O_dens_is_bin  = ResMat(:,2);
        [ResMat]         = binning([CARL_z,CARL_h2o_dens'],bw,0,zmax);
        CARL_h2o_dens_bin= ResMat(:,2);
                
        %accumulate data
        CARL_h2o_dens_bin_all=[CARL_h2o_dens_bin_all CARL_h2o_dens_bin'];
        H2O_dens_bin_all=[H2O_dens_bin_all H2O_dens_bin'];
        H2O_dens_bin_is_all=[H2O_dens_bin_is_all H2O_dens_is_bin'];
        
        % plot CARL t profile
        figure(3)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(CARL_t, CARL_z,'-bo')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[-20 40]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',-20:10:40);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',CARL_hour_start,CARL_min_start,CARL_hour_end,CARL_min_end,nprof);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);
        text(.08,5.4,titlestr3,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'p');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        % plot CARL h2o_dens profile
        figure(4)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(H2O_dens,GPS_Altitude,'b.-',H2O_dens_is,GPS_Altitude,'g.-',CARL_h2o_dens,CARL_z,'r.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 24]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:4:24);
        set(gca,'ytick',0:8);
        titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
        h1=text(.1,7,titlestr);
        set(h1,'FontSize',8)
        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-2,-2,'AATS-14 CWV');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
    if strcmp(CARL,'Yes') && strcmp(product,'aod_profile')
        %load CARL data
        [CARL_UT,CARL_aod,CARL_z,CARL_aod_profile,CARL_aod_err,CARL_ext,CARL_ext_err,CARL_r,CARL_p,CARL_t]=read_CARL_ALIVE('c:\beat\data\alive\carl\',day,month,year);
        %remove profiles that have only values less or equal 0
        ii=find(all(CARL_ext<=0,2)==1);
        CARL_ext(ii,:)=[];
        CARL_UT(ii)=[];
        CARL_aod(ii)=[];
        CARL_aod_profile(ii,:)=[];
        ii=interp1(CARL_UT,1:length(CARL_UT),UT_start+4/60,'nearest','extrap');
        jj=interp1(CARL_UT,1:length(CARL_UT),UT_end-4/60,'nearest','extrap');
        nprof=jj-ii+1;
        
        CARL_hour_start=floor(CARL_UT(ii));
        CARL_hour_end=floor(CARL_UT(jj));
        CARL_min_start=round((CARL_UT(ii)-floor(CARL_UT(ii)))*60);
        CARL_min_end=round((CARL_UT(jj)-floor(CARL_UT(jj)))*60);
        
        %kk=find((CARL_ext(ii,:)~=-999) & (CARL_ext(ii,:)~=-777) ); %remove altitudes with invalid retrievals
        CARL_ext=mean(CARL_ext(ii:jj,2:end),1);
        CARL_aod_profile=mean(CARL_aod_profile(ii:jj,2:end),1);
        CARL_z=CARL_z(2:end);
        CARL_aod=mean(CARL_aod(ii:jj));
        CARL_aod_profile=-CARL_aod_profile+CARL_aod;
        
        %binning
        [ResMat]=binning([CARL_z,CARL_ext'],bw,0,zmax);
        CARL_ext_bin= ResMat(:,2);
        [ResMat]=binning([CARL_z,CARL_aod_profile'],bw,0,zmax);
        CARL_aod_profile_bin= ResMat(:,2);
        
        %accumulate data
        CARL_ext_all=[CARL_ext_all CARL_ext_bin'];
        
        % plot AOD profile
        figure(5)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(AOD(1,:), GPS_Altitude,'-bo')
        hold on
        plot(CARL_aod_profile,CARL_z,'g.-');
        plot(CARL_aod,.311,'ro','MarkerFaceColor','r')
        hold off
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.4]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.1:0.40);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',CARL_hour_start,CARL_min_start,CARL_hour_end,CARL_min_end,nprof);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);
        text(.08,5.4,titlestr3,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'AOD');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot extinction profile
        figure(6)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(CARL_ext,CARL_z,'g.-',Extinction(1,:),GPS_Altitude,'b.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.300]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.300);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',CARL_hour_start,CARL_min_start,CARL_hour_end,CARL_min_end,nprof);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);
        text(.08,5.4,titlestr3,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'Extinction [km^-^1]');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
    if strcmp(MPL,'Yes')
        %load MPLNET data
        [MPL_z,MPL_UT,MPL_aot,MPL_ext]=read_MPLARM_ALIVE('c:\beat\data\alive\mpl\',0.319,day,month,year);
        ii=interp1(MPL_UT,1:length(MPL_UT),UT_start+4/60,'nearest','extrap');
        jj=interp1(MPL_UT,1:length(MPL_UT),UT_end-4/60,'nearest','extrap');
        nprof=jj-ii+1;

        MPL_hour_start=floor(MPL_UT(ii));
        MPL_hour_end=floor(MPL_UT(jj));
        MPL_min_start=round((MPL_UT(ii)-floor(MPL_UT(ii)))*60);
        MPL_min_end=round((MPL_UT(jj)-floor(MPL_UT(jj)))*60);

        kk=find(MPL_ext(ii,:)~=-9999); %remove altitudes with invalid retrievals
        MPL_ext=mean(MPL_ext(ii:jj,kk),1);
        MPL_z=MPL_z(kk);
        MPL_aot=mean(MPL_aot(ii:jj));

        MPL_AOD=cumtrapz(MPL_z,MPL_ext);
        MPL_AOD=-MPL_AOD+MPL_AOD(end);

        %binning
        [ResMat]=binning([MPL_z,MPL_ext'],bw,0,zmax);
        MPL_ext_bin= ResMat(:,2);
        [ResMat]=binning([MPL_z,MPL_AOD'],bw,0,zmax);
        MPL_AOD_bin= ResMat(:,2);
        %accumulate data
        MPL_ext_all=[MPL_ext_all MPL_ext_bin'];

        %MPL and AATS AOD at min and max AATS altitudes
        ii_mpl=find(isnan(MPL_AOD_bin)==0);
        if isempty(ii_mpl)
            mpl_AOD_AATS_bot(jprof)=NaN;
            mpl_AOD_AATS_top(jprof)=NaN;
        else
            mpl_AOD_AATS_bot(jprof)=interp1(Altitude(ii_mpl),MPL_AOD_bin(ii_mpl),Altitude(i_bot_AATS),'nearest','extrap');
            mpl_AOD_AATS_top(jprof)=interp1(Altitude(ii_mpl),MPL_AOD_bin(ii_mpl),Altitude(i_top_AATS));
        end

        AATS_AOD519_mpl_bot(jprof)=AATS_AOD519(i_bot_AATS);
        AATS_AOD_Error519_mpl_bot(jprof)=AATS_AOD_Error519(i_bot_AATS);
        AATS_AOD519_mpl_top(jprof)=AATS_AOD519(i_top_AATS);
        AATS_AOD_Error519_mpl_top(jprof)=AATS_AOD_Error519(i_top_AATS);

        % plot AOD profile
        figure(5)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(AOD(5,:), GPS_Altitude,'-bo')
        hold on
        plot(MPL_AOD,MPL_z,'g.-');
        plot(MPL_aot,0.319,'ro','MarkerFaceColor','r')
        hold off
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.25]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.250);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',MPL_hour_start,MPL_min_start,MPL_hour_end,MPL_min_end,nprof);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);
        text(.08,5.4,titlestr3,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'AOD');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot extinction profile
        figure(6)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        %plot(MPL_ext(ii:jj,:),MPL_z,'g.-',Extinction(5,:),GPS_Altitude,'b.-')
        plot(MPL_ext,MPL_z,'g.-',Extinction(5,:),GPS_Altitude,'b.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.200]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.200);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',MPL_hour_start,MPL_min_start,MPL_hour_end,MPL_min_end,nprof);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);
        text(.08,5.4,titlestr3,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'Extinction [km^-^1]');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
end
%Overall comparisons
if strcmp(product,'h2o_profile')
    layer_H2O_AATS14_Error=0.005.*deg2km(rng).*mean_H2O;
    figure(5)
    x=layer_H2O_AATS14;
    y=layer_H2O_is;
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[0 4.5];
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin', min(range), max(range), min(range), max(range), x, y,layer_H2O_AATS14_Error,'ko')
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'k--',range,range,'k')
    text(2.5,1.4, sprintf('n= %i ',n),'FontSize',14)
    text(2.5,1.2, sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(2.5,1.0, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(2.5,0.8, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',14)
    text(2.5,0.6, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',14)
    text(2.5,0.4, sprintf('mean x = %5.4f',mean(x)),'FontSize',14)
    text(2.5,0.2, sprintf('mean y = %5.4f',mean(y)),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('in-situ - Layer H_2O [g/cm^2]','FontSize',14)
    xlabel('AATS-14 - Layer H_2O [g/cm^2]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:.5:4.5);
    set(gca,'ytick',0:.5:4.5);

    figure(6)
    x=H2O_dens_all;
    y=H2O_dens_is_all;
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[-0.5 23];
    plot(x,y,'k.')
    hold on
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'k--',range,range,'k')
    text(0,18.8, sprintf('n= %i ',n),'FontSize',14)
    text(0,18.0, sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(0,17.2, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(0,16.4, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',14)
    text(0,15.6, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',14)
    text(0,14.8, sprintf('mean x = %5.4f',mean(x)),'FontSize',14)
    text(0,14, sprintf('mean y = %5.4f',mean(y)),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:2:23);
    set(gca,'ytick',0:2:23);
end
if strcmp(CARL,'Yes') && strcmp(product,'h2o_profile')
    figure(7)
    x=H2O_dens_bin_all;
    y=H2O_dens_bin_is_all;
    ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
    x=x(ii); y=y(ii);
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[-0.5 23];
    plot(x,y,'k.')
    hold on
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'k--',range,range,'k')
    text(0,18.8, sprintf('n= %i ',n),'FontSize',14)
    text(0,18.0, sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(0,17.2, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(0,16.4, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',14)
    text(0,15.6, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',14)
    text(0,14.8, sprintf('mean x = %5.4f',mean(x)),'FontSize',14)
    text(0,14, sprintf('mean y = %5.4f',mean(y)),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:2:23);
    set(gca,'ytick',0:2:23);
    
    figure(8)
    x=H2O_dens_bin_all;
    y=CARL_h2o_dens_bin_all;
    ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
    x=x(ii); y=y(ii);
    ii=find(y<100); %Remove outliers
    x=x(ii); y=y(ii);
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[-0.5 23];
    plot(x,y,'k.')
    hold on
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'k--',range,range,'k')
    text(0,20.8, sprintf('n= %i ',n),'FontSize',14)
    text(0,20.0, sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(0,19.2, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(0,18.4, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',14)
    text(0,17.6, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',14)
    text(0,16.8, sprintf('mean x = %5.4f',mean(x)),'FontSize',14)
    text(0,16, sprintf('mean y = %5.4f',mean(y)),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('CARL - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:2:23);
    set(gca,'ytick',0:2:23);
end
%compare AATS and CARL exinction at 353 nm
if strcmp(CARL,'Yes') && strcmp(product,'aod_profile')
    figure(7)
    x=AATS_ext353_all;
    y=CARL_ext_all;
    ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[-0.02 0.4];
    plot(range,range,'k');
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: CARL','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:.05:0.4);
    set(gca,'ytick',0:.05:0.4);

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')

    hold off
    text(0.2,0.15,'\lambda= 353/355 nm','FontSize',12)
    text(0.2,0.13, sprintf('n= %i ',n),'FontSize',12)
    text(0.2,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.2,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.2,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.2,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.2,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
end
%compare AATS and MPL exinction at 519/523 nm
if strcmp(MPL,'Yes')
    figure(7)
    x=AATS_ext519_all;
    y=MPL_ext_all;
    ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[-0.01 0.2];
    plot(range,range,'k');
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: MPL','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:.05:0.2);
    set(gca,'ytick',0:.05:0.2);

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')

    hold off
    text(0.12,0.08,'\lambda= 519/523 nm','FontSize',12)
    text(0.12,0.07, sprintf('n= %i ',n),'FontSize',12)
    text(0.12,0.06, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.12,0.05, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.12,0.04, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.12,0.03, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.12,0.02, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.12,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare MPLARM and AATS top and bottom AOD 519/523 nm
    figure(8)
    %top
    y=mpl_AOD_AATS_top;
    x=AATS_AOD519_mpl_top;
    ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
    x=x(ii); y=y(ii);
    subplot(2,2,1)
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,AATS_AOD_Error519_mpl_top(ii),'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[0 0.06];
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('top AOD: AATS-14','FontSize',14)
    ylabel('top AOD: MPLARM','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:0.01:0.06);
    set(gca,'ytick',0:0.01:0.06);

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-',range,range,'k-')

    hold off
    text(0.05,0.045 ,'\lambda= 519/523 nm','FontSize',12)
    text(0.05,0.04, sprintf('n= %i ',n),'FontSize',12)
    text(0.05,0.035, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.05,0.03, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.05,0.025, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.05,0.02, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.05,0.015, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.05,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %bottom
    y=mpl_AOD_AATS_bot;
    x=AATS_AOD519_mpl_bot;
    ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
    x=x(ii); y=y(ii);
    subplot(2,2,2)
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,AATS_AOD_Error519_mpl_bot(ii),'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[0 0.250];
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('bottom AOD: AATS-14','FontSize',14)
    ylabel('bottom AOD: MPLARM','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:0.05:0.25);
    set(gca,'ytick',0:0.05:0.25);

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-',range,range,'k-')

    hold off
    text(0.2,0.15 ,'\lambda= 519/523 nm','FontSize',12)
    text(0.2,0.13, sprintf('n= %i ',n),'FontSize',12)
    text(0.2,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.2,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.2,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.2,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.2,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %layer
    y=mpl_AOD_AATS_bot-mpl_AOD_AATS_top;
    x=AATS_AOD519_mpl_bot-AATS_AOD519_mpl_top;
    ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
    x=x(ii); y=y(ii);
    subplot(2,2,3)
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,AATS_AOD_Error519_mpl_bot(ii),'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    range=[0 0.250];
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('layer AOD: AATS-14','FontSize',14)
    ylabel('layer AOD: MPLARM','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:0.05:0.25);
    set(gca,'ytick',0:0.05:0.25);

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-',range,range,'k-')

    hold off
    text(0.2,0.15 ,'\lambda= 519/523 nm','FontSize',12)
    text(0.2,0.13, sprintf('n= %i ',n),'FontSize',12)
    text(0.2,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.2,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.2,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.2,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.2,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
end