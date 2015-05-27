function [AATS, lidar] = ALIVE_plots(lidar,product)
%creates ALIVE multiframe plots of aerosol and h2o profiles
%does statistics for H2O comparison with in-situ
%compares with CARL and MPL
% lidar = 'MPL' or 'CARL'
% product = 'aod_profile' or 'h2o_profile'
% clear all
% close all
if strcmp(upper(lidar),'CARL')
    clear lidar
    lidar.type = 'CARL';
    CARL='Yes';
else
    CARL='No';
end
if strcmp(upper(lidar),'MPL')
    clear lidar
    lidar.type = 'MPL';
    MPL = 'Yes';
else
    MPL = 'No';
end

lidar.Latitude_SGP=36.6;    %SGP
lidar.Longitude_SGP=-97.48;  %SGP
if ~exist('product','var')
    product='aod_profile';
end
lidar.product = product;
% AOD profile produced by ext_profile_ave.m
%product='h2o_profile'; % H2O profile produced by h2o_profile_ave.m

lidar.zmax=8.00; %max altitude for binning [km]
lidar.bw=0.020; %bin width for AATS-14
if strcmp(MPL,'Yes')
    lidar.zmax=8.010; %max altitude for binning [km]
    lidar.bw=0.030; %bin width for MPL
    lidar.ext_all=[];
    lidar.aod_all=[];

end
if strcmp(CARL,'Yes')
    lidar.zmax=7.995; %max altitude for binning [km]
    lidar.bw=0.039; %bin width for CARL
    lidar.ext_all=[];
    lidar.aod_all=[];

end

%empty arrays
AATS.dist_all=[];
AATS.ext353_all=[];
AATS.ext519_all=[];
AATS.ext353_Error_all=[];
AATS.AOD353_all=[];
AATS.AOD_Error353_all=[];
AATS.ext519_Error_all=[];
AATS.AOD519_all=[];
AATS.AOD_Error519_all=[];

%read all AATS-14 extinction profile names in directory
if strcmp(product,'aod_profile')
    pathname='C:\case_studies\Alive\data\schmid-aats\atts.01-Mar-2006\Ver2\ext_profs\';
    direc=dir(fullfile(pathname,'*p.asc'));
    [filelist{1:length(direc),1}] = deal(direc.name);
    filelist(25:28,:)=[]; % delete profiles not over SGP
end

%read all AATS-14 water vapor profile names in directory
if strcmp(product,'h2o_profile')
    AATS.H2O_dens_all=[];
    AATS.H2O_dens_is_all=[];
    AATS.H2O_Error_all=[];
    lidar.H2O_dens_bin_all=[];
    lidar.H2O_dens_bin_is_all=[];

    pathname='c:\beat\data\ALIVE\Ver2\';
    direc=dir(fullfile(pathname,'*pw.asc'));
    [filelist{1:length(direc),1}] = deal(direc.name);
    filelist([42:47,64],:)=[]; % delete profiles not over SGP
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
    AATS.file_date=fscanf(fid,'ALIVE%g/%g/%g');     %get date
    AATS.month=AATS.file_date(1);
    AATS.day=AATS.file_date(2);
    AATS.year=AATS.file_date(3);
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
        AATS.UT=data(1,:);
        AATS.Latitude=data(2,:);
        AATS.Longitude=data(3,:);
        AATS.GPS_Altitude=data(4,:);
        AATS.Pressure_Altitude=data(5,:);
        AATS.Pressure=data(6,:);
        AATS.AOD=data(7:19,:);
        AATS.AOD_Error=data(20:32,:);
        AATS.gamma=-data(33,:);
        AATS.alpha=-data(34,:);
        AATS.a0=data(35,:);
        AATS.Extinction=data(36:48,:);
        AATS.Extinction_Error=data(49:61,:);
        AATS.gamma_ext=-data(62,:);
        AATS.alpha_ext=-data(63,:);
        AATS.a0_ext=data(64,:);
        %         clear dist;
        %         for L = length(Latitude):-1:1
        %             dist(L) = geodist(Latitude(L),Longitude(L),lidar.Latitude_SGP,lidar.Longitude_SGP)/1000;
        %         end
        AATS.dist = geodist2(AATS.Latitude,AATS.Longitude,lidar.Latitude_SGP,lidar.Longitude_SGP)/1000;
        %         dist = dist';
        %         dist=deg2km(distance(Latitude,Longitude,lidar.Latitude_SGP,lidar.Longitude_SGP));
        %bin data in altitude for the AATS-14 wavelengths I need which are 353 nm and 519 nm
        [ResMat]    = binning([AATS.GPS_Altitude',AATS.Extinction( 1,:)'],lidar.bw,0,lidar.zmax);
        AATS.Altitude    = ResMat(:,1);
        AATS.ext353 = ResMat(:,2);
        [ResMat]    = binning([AATS.GPS_Altitude',AATS.Extinction_Error( 1,:)'],lidar.bw,0,lidar.zmax);
        AATS.ext353_Error = ResMat(:,2);
        [ResMat]    = binning([AATS.GPS_Altitude',AATS.Extinction_Error( 1,:)'],lidar.bw,0,lidar.zmax);
        AATS.AOD353 = ResMat(:,2);
        [ResMat]    = binning([AATS.GPS_Altitude',AATS.AOD_Error( 1,:)'],lidar.bw,0,lidar.zmax);
        AATS.AOD_Error353 = ResMat(:,2);

        [ResMat]  =binning([AATS.GPS_Altitude',AATS.Extinction( 5,:)'],lidar.bw,0,lidar.zmax);
        AATS.ext519 = ResMat(:,2);
        [ResMat]  =binning([AATS.GPS_Altitude',AATS.Extinction_Error( 5,:)'],lidar.bw,0,lidar.zmax);
        AATS.ext519_Error = ResMat(:,2);
        [ResMat]  =binning([AATS.GPS_Altitude',AATS.Extinction_Error( 5,:)'],lidar.bw,0,lidar.zmax);
        AATS.AOD519 = ResMat(:,2);
        [ResMat]  =binning([AATS.GPS_Altitude',AATS.AOD_Error( 5,:)'],lidar.bw,0,lidar.zmax);
        AATS.AOD_Error519 = ResMat(:,2);

        [ResMat]  =binning([AATS.GPS_Altitude',AATS.dist'],lidar.bw,0,lidar.zmax);
        AATS.dist_bin = ResMat(:,2);

        clear ResMat;

        %find bottom and top AATS.Extinction_Error
        ii_AATS=~isnan(AATS.ext519);
        i_bot_AATS=min(find(ii_AATS==1));
        i_top_AATS=max(find(ii_AATS==1));

        %accumulate data
        AATS.ext353_all=[AATS.ext353_all; AATS.ext353'];
        AATS.ext353_Error_all=[AATS.ext353_Error_all; AATS.ext353_Error'];
        AATS.AOD353_all=[AATS.AOD353_all; AATS.AOD353'];
        AATS.AOD_Error353_all=[AATS.AOD_Error353_all; AATS.AOD_Error353'];

        AATS.ext519_all=[AATS.ext519_all; AATS.ext519'];
        AATS.ext519_Error_all=[AATS.ext519_Error_all; AATS.ext519_Error'];
        AATS.AOD519_all=[AATS.AOD519_all; AATS.AOD519'];
        AATS.AOD_Error519_all=[AATS.AOD_Error519_all; AATS.AOD_Error519'];
        AATS.dist_all=[AATS.dist_all; AATS.dist_bin'];
    end
    if strcmp(product,'h2o_profile')
        data=fscanf(fid,'%g',[11,inf]);
        fclose(fid);
        AATS.UT=data(1,:);
        AATS.Latitude=data(2,:);
        AATS.Longitude=data(3,:);
        AATS.GPS_Altitude=data(4,:);
        AATS.Pressure_Altitude=data(5,:);
        AATS.Pressure=data(6,:);
        AATS.H2O=data(7,:);
        AATS.H2O_Error=data(8,:);
        AATS.H2O_dens=data(9,:);
        AATS.H2O_dens_err=data(10,:);
        AATS.H2O_dens_is=data(11,:);
        AATS.dist=deg2km(distance(lidar.Latitude_SGP,lidar.Longitude_SGP,AATS.Latitude,AATS.Longitude));
        %accumulate data
        AATS.H2O_dens_all=[AATS.H2O_dens_all; AATS.H2O_dens];
        AATS.H2O_dens_is_all=[AATS.H2O_dens_is_all; AATS.H2O_dens_is];
        AATS.H2O_Error_all=[AATS.H2O_Error_all; AATS.H2O_Error];
        AATS.dist_all=[AATS.dist_all; AATS.dist];

        AATS.layer_H2O_is(jprof)=trapz(AATS.GPS_Altitude,AATS.H2O_dens_is)/10;
        AATS.layer_H2O_AATS14(jprof)=AATS.H2O(1)-AATS.H2O(end);
        AATS.mean_H2O(jprof)=(AATS.H2O(1)+AATS.H2O(2))/2;
        AATS.rng(jprof) = geodist(AATS.Latitude(1),AATS.Longitude(1),AATS.Latitude(end),AATS.Longitude(end));
    end

    AATS.UT_start=min(AATS.UT);
    AATS.UT_end=max(AATS.UT);

    %plots
    AATS.hour_start=floor(AATS.UT_start);
    AATS.hour_end=floor(AATS.UT_end);
    AATS.min_start=round((AATS.UT_start-floor(AATS.UT_start))*60);
    AATS.min_end=round((AATS.UT_end-floor(AATS.UT_end))*60);

    col=mod(jprof-1,5);
    row=mod(fix((jprof-1)/5),6);

    %     if strcmp(product,'aod_profile')
    %         % plot AATS.Extinction_Error profile
    %         figure(1)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(AATS.Extinction_Error,AATS.GPS_Altitude,'.')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[0 0.4]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',0:0.1:0.4);
    %         set(gca,'ytick',0:8);
    %         titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
    %         titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
    %         text(.13,6.8,titlestr1,'FontSize',8);
    %         text(.13,6.2,titlestr2,'FontSize',8);
    %         %legend
    %         %         if row==0 & col==0
    %         %                     legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
    %         %                         num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
    %         %         end
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-.05,-2,'Aerosol Optical Depth');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-0.12,5,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %
    %         % plot extinction profile
    %         figure(2)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(Extinction,AATS.GPS_Altitude,'.-')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[0 0.250]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',0:0.05:0.250);
    %         set(gca,'ytick',0:8);
    %         titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
    %         titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
    %         text(.08,6.8,titlestr1,'FontSize',8);
    %         text(.08,6.2,titlestr2,'FontSize',8);
    %
    %         %axis labels and titles
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(0.0,-2,'Extinction [km^-^1]');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-0.07,5,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %
    %         % plot AOD spectral shape profile
    %         figure(3)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(alpha,AATS.GPS_Altitude,'c.',gamma,AATS.GPS_Altitude,'m.')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[-2 2]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',-2:2);
    %         set(gca,'ytick',0:8);
    %         titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
    %         titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
    %         text(.08,6.8,titlestr1,'FontSize',8);
    %         text(.08,6.2,titlestr2,'FontSize',8);
    %
    %         %axis labels and titles
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-3,-2,'Aerosol Optical Depth Spectral Parameters');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-3,3,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %
    %         %plot spectral shape profile
    %         figure(4)
    %         %don't plot if extinction is low
    %         ii=all(Extinction(1:12,:)>=0.003);
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(alpha_ext(ii),AATS.GPS_Altitude(ii),'c.',gamma_ext(ii),AATS.GPS_Altitude(ii),'m.')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[-2 3]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',[-2 -1 0 1 2 3]);
    %         set(gca,'ytick',0:8);
    %         titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
    %         h1=text(-1.8,7,titlestr);
    %         set(h1,'FontSize',8)
    %
    %         %axis labels and titles
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-2,-2,'AATS-14 Extinction shape');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-3,3,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %
    %         % plot distance profile
    %         figure(5)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(dist,AATS.GPS_Altitude,'.')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[0 50]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',0:10:50);
    %         set(gca,'ytick',0:8);
    %         titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
    %         titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
    %         text(.13,6.8,titlestr1,'FontSize',8);
    %         text(.13,6.2,titlestr2,'FontSize',8);
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-.05,-2,'Distance (km)');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-0.12,5,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %     end
    %     if strcmp(product,'h2o_profile')
    %         %plot CWV profile
    %         figure(1)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(H2O,AATS.GPS_Altitude,'b.')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[0 5]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',0:5);
    %         set(gca,'ytick',0:8);
    %         titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
    %         h1=text(.1,7,titlestr);
    %         set(h1,'FontSize',8)
    %         %axis labels and titles
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-2,-2,'AATS-14 CWV');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-1,3,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %         %plot H2O dens profile
    %         figure(2)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(H2O_dens,AATS.GPS_Altitude,'b.-',H2O_dens_is,AATS.GPS_Altitude,'g.-')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[0 24]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',0:4:24);
    %         set(gca,'ytick',0:8);
    %         titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
    %         h1=text(.1,7,titlestr);
    %         set(h1,'FontSize',8)
    %         %axis labels and titles
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-2,-2,'H2O Density');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-3,3,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %         % plot distance profile
    %         figure(3)
    %         set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
    %         subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
    %         plot(dist,AATS.GPS_Altitude,'.')
    %         set(gca,'ylim',[0 8]);
    %         set(gca,'xlim',[0 50]);
    %         set(gca,'TickLength',[.03 .03]);
    %         set(gca,'xtick',0:10:50);
    %         set(gca,'ytick',0:8);
    %         titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
    %         titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
    %         text(.5,6.8,titlestr1,'FontSize',8);
    %         text(.5,6.2,titlestr2,'FontSize',8);
    %         if col>=1, set(gca,'YTickLabel',[]); end
    %         if row<5, set(gca,'XTickLabel',[]); end
    %         if row==5 && col==2
    %             h22=text(-.05,-2,'Distance [km]');
    %             set(h22,'FontSize',12)
    %         end
    %         if col==0 && row==3
    %             h33=text(-5,5,'Altitude [km]');
    %             set(h33,'FontSize',12,'Rotation',90)
    %         end
    %     end
    if strcmp(CARL,'Yes') && strcmp(lidar.product,'h2o_profile')
        %load CARL data
        [lidar.UT,lidar.aod,lidar.z,lidar.aod_profile,lidar.aod_err,lidar.ext,lidar.ext_err,lidar.r,lidar.p,lidar.t,lidar.h2o_dens,lidar.w_max_height]=read_CARL_ALIVE('c:\beat\data\alive\carl\',day,month,year);
        %remove profiles that have only values less or equal 0
        ii=find(all(lidar.r<=0,2)==1);
        lidar.w_max_height(ii)=[];
        lidar.r(ii,:)=[];
        lidar.UT(ii)=[];
        lidar.p(ii,:)=[];
        lidar.t(ii,:)=[];
        lidar.h2o_dens(ii,:)=[];
        ii=interp1(lidar.UT,1:length(lidar.UT),AATS.UT_start+1/60,'nearest','extrap');
        jj=interp1(lidar.UT,1:length(lidar.UT),AATS.UT_end-1/60,'nearest','extrap');
        nprof=jj-ii+1;

        lidar.hour_start=floor(lidar.UT(ii));
        lidar.hour_end=floor(lidar.UT(jj));
        lidar.min_start=round((lidar.UT(ii)-floor(lidar.UT(ii)))*60);
        lidar.min_end=round((lidar.UT(jj)-floor(lidar.UT(jj)))*60);

        lidar.t=mean(lidar.t(ii:jj,:),1);
        lidar.h2o_dens=mean(lidar.h2o_dens(ii:jj,:),1);
        lidar.w_max_height=mean(lidar.w_max_height(ii:jj));

        %lidar.w_max_height=lidar.zmax; % I think w_mx criteria is too conservative
        kk=find(lidar.z<=lidar.w_max_height);

        %binning: bin data in altitude for AATS-14 and CARL
        [ResMat]         = binning([AATS.GPS_Altitude',H2O_dens'],lidar.bw,0,lidar.zmax);
        AATS.Altitude         = ResMat(:,1);
        AATS.H2O_dens_bin     = ResMat(:,2);
        [ResMat]         = binning([AATS.GPS_Altitude',H2O_dens_is'],lidar.bw,0,lidar.zmax);
        AATS.H2O_dens_is_bin  = ResMat(:,2);
        [ResMat]         = binning([lidar.z(kk),lidar.h2o_dens(:,kk)'],lidar.bw,0,lidar.zmax);
        lidar.H2O_dens_bin= ResMat(:,2);

        %accumulate data
        lidar.H2O_dens_bin_all=[lidar.H2O_dens_bin_all; lidar.H2O_dens_bin'];
        AATS.H2O_dens_bin_all=[AATS.H2O_dens_bin_all; AATS.H2O_dens_bin'];
        AATS.H2O_dens_bin_is_all=[AATS.H2O_dens_bin_is_all; AATS.H2O_dens_is_bin'];

        % plot CARL t profile
        figure(4)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(lidar.t, lidar.z,'-bo')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[-20 40]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',-20:10:40);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
        text(.08,6.8,titlestr1,'FontSize',8);
        text(.08,6.2,titlestr2,'FontSize',8);
        text(.08,5.4,titlestr3,'FontSize',8);

        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(0.0,-2,'t');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-0.07,5,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        % plot CARL h2o_dens profile
        figure(5)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(lidar.h2o_dens,lidar.z,'r.-',AATS.H2O_dens,AATS.GPS_Altitude,'b.-',AATS.H2O_dens_is,AATS.GPS_Altitude,'g.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 24]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:4:24);
        set(gca,'ytick',0:8);
        titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',AATS.month,AATS.day,AATS.year-2000,AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
        h1=text(.1,7,titlestr);
        set(h1,'FontSize',8)
        %axis labels and titles
        if col>=1, set(gca,'YTickLabel',[]); end
        if row<5, set(gca,'XTickLabel',[]); end
        if row==5 && col==2
            h22=text(-2,-2,'H2O Density');
            set(h22,'FontSize',12)
        end
        if col==0 && row==3
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
    if strcmp(CARL,'Yes') && strcmp(product,'aod_profile')
        %load CARL data
        [lidar.UT,lidar.aod,lidar.z,lidar.aod_profile,lidar.aod_err,lidar.ext,lidar.ext_err,lidar.r,lidar.p,lidar.t]=read_CARL_ALIVE('C:\case_studies\Alive\data\ferrare-carl\Feb2007\',AATS.day,AATS.month,AATS.year);
        %remove profiles that have only values less or equal 0
        ii=find(all(lidar.ext<=0,2)==1);
        lidar.ext(ii,:)=[];
        lidar.UT(ii)=[];
        lidar.aod(ii)=[];
        lidar.aod_profile(ii,:)=[];
        ii=interp1(lidar.UT,1:length(lidar.UT),AATS.UT_start+4/60,'nearest','extrap');
        jj=interp1(lidar.UT,1:length(lidar.UT),AATS.UT_end-4/60,'nearest','extrap');
        nprof=jj-ii+1;

        lidar.hour_start=floor(lidar.UT(ii));
        lidar.hour_end=floor(lidar.UT(jj));
        lidar.min_start=round((lidar.UT(ii)-floor(lidar.UT(ii)))*60);
        lidar.min_end=round((lidar.UT(jj)-floor(lidar.UT(jj)))*60);

        %kk=find((lidar.ext(ii,:)~=-999) & (lidar.ext(ii,:)~=-777) ); %remove altitudes with invalid retrievals
        lidar.ext=mean(lidar.ext(ii:jj,2:end),1);
        lidar.aod_profile=mean(lidar.aod_profile(ii:jj,2:end),1);
        lidar.z=lidar.z(2:end);
        lidar.aod=mean(lidar.aod(ii:jj));
        lidar.aod_profile=-lidar.aod_profile+lidar.aod;

        %binning
        [ResMat]=binning([lidar.z,lidar.ext'],lidar.bw,0,lidar.zmax);
        ext_bin= ResMat(:,2);
        [ResMat]=binning([lidar.z,lidar.aod_profile'],lidar.bw,0,lidar.zmax);
        lidar.aod_profile_bin= ResMat(:,2);

        %accumulate data
        lidar.ext_all=[lidar.ext_all; ext_bin'];
        lidar.aod_all = [lidar.aod_all;lidar.aod_profile_bin'];
        % plot AOD profile
        figure(5)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(AATS.AOD(1,:), AATS.GPS_Altitude,'-bo')
        hold on
        plot(lidar.aod_profile,lidar.z,'g.-');
        plot(lidar.aod,.311,'ro','MarkerFaceColor','r')
        hold off
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.4]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.1:0.40);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
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
        plot(lidar.ext,lidar.z,'g.-',AATS.Extinction(1,:),AATS.GPS_Altitude,'b.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.300]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.300);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
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
        [lidar.z,lidar.UT,lidar.aot,lidar.ext]=read_MPLARM_ALIVE('C:\case_studies\Alive\data\flynn-mpl-102\2007_03_05\ext\',0.319,AATS.day,AATS.month,AATS.year);
        ii=interp1(lidar.UT,1:length(lidar.UT),AATS.UT_start+4/60,'nearest','extrap');
        jj=interp1(lidar.UT,1:length(lidar.UT),AATS.UT_end-4/60,'nearest','extrap');
        nprof=jj-ii+1;

        lidar.hour_start=floor(lidar.UT(ii));
        lidar.hour_end=floor(lidar.UT(jj));
        lidar.min_start=round((lidar.UT(ii)-floor(lidar.UT(ii)))*60);
        lidar.min_end=round((lidar.UT(jj)-floor(lidar.UT(jj)))*60);

        kk=find(lidar.ext(ii,:)~=-9999); %remove altitudes with invalid retrievals
        lidar.ext=mean(lidar.ext(ii:jj,kk),1);
        lidar.z=lidar.z(kk);
        lidar.aot=mean(lidar.aot(ii:jj));

        lidar.AOD=cumtrapz(lidar.z,lidar.ext);
        lidar.AOD=-lidar.AOD+lidar.AOD(end);

        %binning
        [ResMat]=binning([lidar.z,lidar.ext'],lidar.bw,0,lidar.zmax);
        ext_bin= ResMat(:,2);
        [ResMat]=binning([lidar.z,lidar.AOD'],lidar.bw,0,lidar.zmax);
        AOD_bin= ResMat(:,2);
        %accumulate data
        lidar.ext_all=[lidar.ext_all; ext_bin'];
        lidar.aod_all=[lidar.aod_all; AOD_bin'];

        %MPL and AATS AOD at min and max AATS altitudes
        ii_mpl=find(isnan(AOD_bin)==0);
        if isempty(ii_mpl)
            lidar.AOD_AATS_bot(jprof)=NaN;
            lidar.AOD_AATS_top(jprof)=NaN;
        else
            lidar.AOD_AATS_bot(jprof)=interp1(AATS.Altitude(ii_mpl),AOD_bin(ii_mpl),AATS.Altitude(i_bot_AATS),'nearest','extrap');
            lidar.AOD_AATS_top(jprof)=interp1(AATS.Altitude(ii_mpl),AOD_bin(ii_mpl),AATS.Altitude(i_top_AATS));
        end

        AATS.AOD519_mpl_bot(jprof)=AATS.AOD519(i_bot_AATS);
        AATS.AOD_Error519_mpl_bot(jprof)=AATS.AOD_Error519(i_bot_AATS);
        AATS.AOD519_mpl_top(jprof)=AATS.AOD519(i_top_AATS);
        AATS.AOD_Error519_mpl_top(jprof)=AATS.AOD_Error519(i_top_AATS);

        % plot AOD profile
        figure(5)
        set(gcf,'Paperposition',[0.2 0.1 8 10.7]);
        subplot('position',[0.06+col*0.19 0.85-row*0.16 0.16 0.14])
        plot(AATS.AOD(5,:), AATS.GPS_Altitude,'-bo')
        hold on
        plot(lidar.AOD,lidar.z,'g.-');
        plot(lidar.aot,0.319,'ro','MarkerFaceColor','r')
        hold off
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.25]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.250);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
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
        %plot(lidar.ext(ii:jj,:),lidar.z,'g.-',Extinction(5,:),AATS.GPS_Altitude,'b.-')
        plot(lidar.ext,lidar.z,'g.-',AATS.Extinction(5,:),AATS.GPS_Altitude,'b.-')
        set(gca,'ylim',[0 8]);
        set(gca,'xlim',[0 0.200]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',0:0.05:0.200);
        set(gca,'ytick',0:8);
        titlestr1=sprintf('%02d/%02d/%4d\n',AATS.month,AATS.day,AATS.year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',AATS.hour_start,AATS.min_start,AATS.hour_end,AATS.min_end);
        titlestr3=sprintf('%02d:%02d-%02d:%02d UT %i\n',lidar.hour_start,lidar.min_start,lidar.hour_end,lidar.min_end,nprof);
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
    AATS.layer_H2O_AATS14_Error=0.005.*deg2km(AATS.rng).*AATS.mean_H2O;
    figure(6)
    x=AATS.layer_H2O_AATS14;
    y=AATS.layer_H2O_is;
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

    figure(7)
    x=AATS.H2O_dens_all;
    y=AATS.H2O_dens_is_all;
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
    ylabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:2:23);
    set(gca,'ytick',0:2:23);
end
if strcmp(CARL,'Yes') && strcmp(product,'h2o_profile')
    figure(8)
    x=AATS.H2O_dens_bin_all;
    y=AATS.H2O_dens_bin_is_all;
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
    ylabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:2:23);
    set(gca,'ytick',0:2:23);

    figure(9)
    x=AATS.H2O_dens_bin_all;
    y=lidar.H2O_dens_bin_all;
    ii=find(AATS.dist_all<=30);
    x=x(ii); y=y(ii);
    ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
    x=x(ii); y=y(ii);
    %ii=find(y<100 & y>=-0.5); %Remove outliers
    %x=x(ii); y=y(ii);

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
    text(0,21.8, sprintf('n= %i ',n),'FontSize',14)
    text(0,21.0, sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(0,20.2, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(0,19.4, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',14)
    text(0,18.6, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',14)
    text(0,17.8, sprintf('mean x = %5.4f',mean(x)),'FontSize',14)
    text(0,17, sprintf('mean y = %5.4f',mean(y)),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('CARL - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',0:2:23);
    set(gca,'ytick',0:2:23);

    figure(10)
    hist(AATS.dist_all,50)
    set(gca,'FontSize',14)
    xlabel('Distance [km]','FontSize',14)
    ylabel('Frequency','FontSize',14)

end
%compare AATS and CARL exinction at 353 nm
if strcmp(CARL,'Yes') && strcmp(product,'aod_profile')
    figure(7)
    x=AATS.ext353_all;
    y=lidar.ext_all;
    ii=find(AATS.dist_all<=30); % remove points beyond 30 km
    x=x(ii); y=y(ii);
    ii=find((~isnan(x).*~isnan(y))==1); %remove NaNs
    x=x(ii); y=y(ii);
    ii=find(y<0.400); %remove CARL outliers
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

    figure(8)
    hist(AATS.dist_all,50)
    set(gca,'FontSize',14)
    xlabel('Distance [km]','FontSize',14)
    ylabel('Frequency','FontSize',14)
end
%compare AATS and MPL exinction at 519/523 nm
if strcmp(MPL,'Yes')
    figure(7)
    x=AATS.ext519_all;
    y=lidar.ext_all;
    ii=find(AATS.dist_all<=30); % remove points beyond 30 km
    x=x(ii); y=y(ii);
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
    plot(range,y_fit,'b-');

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-');

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
    y=lidar.AOD_AATS_top;
    x=AATS.AOD519_mpl_top;
    ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
    x=x(ii); y=y(ii);
    subplot(2,2,1)
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,AATS.AOD_Error519_mpl_top(ii),'k.')
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
    y=lidar.AOD_AATS_bot;
    x=AATS.AOD519_mpl_bot;
    ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
    x=x(ii); y=y(ii);
    subplot(2,2,2)
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,AATS.AOD_Error519_mpl_bot(ii),'k.')
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
    y=lidar.AOD_AATS_bot-lidar.AOD_AATS_top;
    x=AATS.AOD519_mpl_bot-AATS.AOD519_mpl_top;
    ii=find((~isnan(x).*~isnan(y)==1)); %remove NaNs
    x=x(ii); y=y(ii);
    subplot(2,2,3)
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,AATS.AOD_Error519_mpl_bot(ii),'k.')
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
lidar.Altitude = AATS.Altitude;
%whos