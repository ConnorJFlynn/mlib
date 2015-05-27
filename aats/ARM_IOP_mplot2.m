%creates ARM IOP multiframe plots and statistics for H2O
clear all
close all

%product='h2o_profile' % H2O profile produced by h2o_profile_ave.m
product='aod_profile' % AOD profile produced by ext_profile_ave.m
Neph_PSAP='Yes'
Cadenza='Yes'
MPLNET='Yes'  % if Level 2 or Level 3
MPLNET2='Yes' %if Level 2 data
MPLARM='Yes'

zmax=8; %max altitude for binning [km]

%empty arrays
H2O_dens_all=[];
H2O_dens_is_all=[];
H2O_Error_all=[];
GPS_Altitude_all=[];
AATS_ext453_all=[];
AATS_ext519_all=[];
AATS_ext675_all=[];
AATS_ext1558_all=[];
AATS_ext453_Error_all=[];
AATS_ext519_Error_all=[];
AATS_ext675_Error_all=[];
AATS_ext1558_Error_all=[];
AATS_AOD453_all=[];
AATS_AOD519_all=[];
AATS_AOD675_all=[];
AATS_AOD1558_all=[];
AATS_AOD_Error453_all=[];
AATS_AOD_Error519_all=[];
AATS_AOD_Error675_all=[];
AATS_AOD_Error1558_all=[];
Cad_Ext_675_all=[];
Cad_Ext_1550_all=[];
ext_453_neph_all=[];
ext_519_neph_all=[];
ext_675_neph_all=[];
Neph_RH_all=[];
Neph_RH_ambient_all=[];
gamma_all=[];
Cad_RH_all=[];
Cad_RH_ambient_all=[];
alpha_neph_all=[];
alpha_aats_all=[];
mplnet_ext_all=[];
mplarm_ext_all=[];
nskip=0;

%read all AATS-14 profile names in directory
if strcmp(product,'h2o_profile')
    pathname='c:\beat\data\Aerosol IOP\Results_v2.1\';
    direc=dir(fullfile(pathname,'CIR*pw.asc'));
    [filelist{1:length(direc),1}] = deal(direc.name);
 %   filelist([1:3,5,6,11,16,19,29,30],:)=[]; %delete profiles where there are no extinction profiles
end
if strcmp(product,'aod_profile')
    pathname='c:\beat\data\Aerosol IOP\Results_v2.2\';
    direc=dir(fullfile(pathname,'CIR*p.asc'));
    [filelist{1:length(direc),1}] = deal(direc.name);
    filelist([10],:)=[]; %delete profile 10 so that we have exactly 5*5=25
end
%read all Neph+PSAP profile names in directory
if strcmp(Neph_PSAP,'Yes')
    pathname2='c:\beat\data\Aerosol IOP\nephs_psap\';
    direc=dir(fullfile(pathname2,'*_psap.asc'));
    [filelist2{1:length(direc),1}] = deal(direc.name);
    filelist2([10],:)=[]; %delete profile 10 so that we have exactly 5*5=25
end
%read all Cadenza profile names in directory
if strcmp(Cadenza,'Yes')
    pathname3='c:\beat\data\Aerosol IOP\Cadenza\Ver7\';
    direc=dir(fullfile(pathname3,'*_cad.asc'));
    [filelist3{1:length(direc),1}] = deal(direc.name);
    filelist3([10],:)=[]; %delete profile 10 so that we have exactly 5*5=25
end
%read filenames of MPLNET level 2 or 3 data
if strcmp(MPLNET,'Yes')
    mplnet=load('C:\Beat\Data\Aerosol IOP\MPLNET\5degTest_ext.txt'); % Level 2
    %mplnet=load('C:\Beat\Data\Aerosol IOP\MPLNET\IOP_Level3_Ext_5deg.txt'); %Level 3
    mplnet_z=mplnet(1,2:end);
    mplnet(1,:)=[];
    mplnet_DOY=mplnet(:,1);
    mplnet(:,1)=[];
    if strcmp(MPLNET2,'Yes')
        mplnet_z(1)=[];
        ii=find(mplnet(:,1)==0);
        mplnet(ii,:)=[];
        mplnet(:,1)=[];
        mplnet_DOY(ii)=[];
    end
end
%read filenames of MPLARM data (C. Flynn)
if strcmp(MPLARM,'Yes')
    pathname4='c:\beat\data\Aerosol IOP\MPLARM\Dec05_2004\';
    direc=dir(fullfile(pathname4,'*_mplarm.asc'));
    [filelist4{1:length(direc),1}] = deal(direc.name);
end

nprofiles=length(filelist);

for jprof=1:nprofiles
    filename=char(filelist(jprof,:));
    disp(sprintf('Processing %s (No. %i of %i)',filename,jprof,nprofiles))

    %determine date and flight number from filename
    flt_no=filename(1:5);

    % read AATS-14 profile
    fid=fopen(deblank([pathname,filename]));
    fgetl(fid);
    file_date=fscanf(fid,'Aerosol IOP%g/%g/%g');     %get date
    month=file_date(1);
    day=file_date(2);
    year=file_date(3);
    fgetl(fid);
    version=fscanf(fid,'%*s %*s %*s %*s %*s %*s %*s %g',[1,1])
    for i=1:10
        fgetl(fid);
    end
    lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
    fgetl(fid);
    fgetl(fid);
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
        rng(jprof) = DISTANCE(Latitude(1),Longitude(1),Latitude(end),Longitude(end));
    end
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

        %bin data in altitude for the wavelength I need which are 453, 519, 675 and 1558
        [ResMat_453,NewMat_453]  =binning([GPS_Altitude',Extinction( 3,:)'],0.020,0,zmax);
        [ResMat_519,NewMat_519]  =binning([GPS_Altitude',Extinction( 5,:)'],0.020,0,zmax);
        [ResMat_675,NewMat_675]  =binning([GPS_Altitude',Extinction( 7,:)'],0.020,0,zmax);
        [ResMat_1558,NewMat_1558]=binning([GPS_Altitude',Extinction(12,:)'],0.020,0,zmax);

        Altitude    = ResMat_453(:,1);
        AATS_ext453 = ResMat_453(:,2);
        AATS_ext519 = ResMat_519(:,2);
        AATS_ext675 = ResMat_675(:,2);
        AATS_ext1558= ResMat_1558(:,2);

        [ResMat_453,NewMat_453]  =binning([GPS_Altitude',Extinction_Error( 3,:)'],0.020,0,zmax);
        [ResMat_519,NewMat_519]  =binning([GPS_Altitude',Extinction_Error( 5,:)'],0.020,0,zmax);
        [ResMat_675,NewMat_675]  =binning([GPS_Altitude',Extinction_Error( 7,:)'],0.020,0,zmax);
        [ResMat_1558,NewMat_1558]=binning([GPS_Altitude',Extinction_Error(12,:)'],0.020,0,zmax);

        AATS_ext453_Error = ResMat_453(:,2);
        AATS_ext519_Error = ResMat_519(:,2);
        AATS_ext675_Error = ResMat_675(:,2);
        AATS_ext1558_Error= ResMat_1558(:,2);

        [ResMat_453,NewMat_453]  =binning([GPS_Altitude',AOD( 3,:)'],0.020,0,zmax);
        [ResMat_519,NewMat_519]  =binning([GPS_Altitude',AOD( 5,:)'],0.020,0,zmax);
        [ResMat_675,NewMat_675]  =binning([GPS_Altitude',AOD( 7,:)'],0.020,0,zmax);
        [ResMat_1558,NewMat_1558]=binning([GPS_Altitude',AOD(12,:)'],0.020,0,zmax);

        AATS_AOD453 = ResMat_453(:,2);
        AATS_AOD519 = ResMat_519(:,2);
        AATS_AOD675 = ResMat_675(:,2);
        AATS_AOD1558= ResMat_1558(:,2);

        [ResMat_453,NewMat_453]  =binning([GPS_Altitude',AOD_Error( 3,:)'],0.020,0,zmax);
        [ResMat_519,NewMat_519]  =binning([GPS_Altitude',AOD_Error( 5,:)'],0.020,0,zmax);
        [ResMat_675,NewMat_675]  =binning([GPS_Altitude',AOD_Error( 7,:)'],0.020,0,zmax);
        [ResMat_1558,NewMat_1558]=binning([GPS_Altitude',AOD_Error(12,:)'],0.020,0,zmax);

        AATS_AOD_Error453 = ResMat_453(:,2);
        AATS_AOD_Error519 = ResMat_519(:,2);
        AATS_AOD_Error675 = ResMat_675(:,2);
        AATS_AOD_Error1558= ResMat_1558(:,2);

        %accumulate data
        AATS_ext453_all=[AATS_ext453_all AATS_ext453'];
        AATS_ext519_all=[AATS_ext519_all AATS_ext519'];
        AATS_ext675_all=[AATS_ext675_all AATS_ext675'];
        AATS_ext1558_all=[AATS_ext1558_all AATS_ext1558'];

        AATS_ext453_Error_all=[AATS_ext453_Error_all AATS_ext453_Error'];
        AATS_ext519_Error_all=[AATS_ext519_Error_all AATS_ext519_Error'];
        AATS_ext675_Error_all=[AATS_ext675_Error_all AATS_ext675_Error'];
        AATS_ext1558_Error_all=[AATS_ext1558_Error_all AATS_ext1558_Error'];

        AATS_AOD453_all=[AATS_AOD453_all AATS_AOD453'];
        AATS_AOD519_all=[AATS_AOD519_all AATS_AOD519'];
        AATS_AOD675_all=[AATS_AOD675_all AATS_AOD675'];
        AATS_AOD1558_all=[AATS_AOD1558_all AATS_AOD1558'];

        AATS_AOD_Error453_all=[AATS_AOD_Error453_all AATS_AOD_Error453'];
        AATS_AOD_Error519_all=[AATS_AOD_Error519_all AATS_AOD_Error519'];
        AATS_AOD_Error675_all=[AATS_AOD_Error675_all AATS_AOD_Error675'];
        AATS_AOD_Error1558_all=[AATS_AOD_Error1558_all AATS_AOD_Error1558'];
    end

    UT_start=min(UT);
    UT_end=max(UT);

    col=mod(jprof-1,5);
    row=mod(fix((jprof-1)/5),5);

    if strcmp(product,'h2o_profile')
        % plot H2O profile
        figure(1)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(H2O,GPS_Altitude,'.')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 3]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0:0.5:3]);
        set(gca,'ytick',[0:1:6]);

        hour_start=floor(UT_start);
        hour_end=floor(UT_end);
        min_start=round((UT_start-floor(UT_start))*60);
        min_end=round((UT_end-floor(UT_end))*60);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(1,5.3,titlestr1,'FontSize',8);
        text(1,4.8,titlestr2,'FontSize',8);

        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<4 set(gca,'XTickLabel',[]); end
        if row==4 & col==1
            h22=text(0.2,-1.2,'Columnar Water Vapor [g/cm^2]');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.5,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot H2O density
        figure(2)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(H2O_dens_is,GPS_Altitude,'c.-',H2O_dens,GPS_Altitude,'m.-')
        %hold on
        %xerrorbar('linlin',-inf, inf, -inf, inf, H2O_dens, GPS_Altitude, H2O_dens_err,'.')
        %hold off

        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 15]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0:3:15]);
        set(gca,'ytick',[0:1:6]);

        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(5,5.3,titlestr1,'FontSize',8);
        text(5,4.8,titlestr2,'FontSize',8);

        %axis labels and titles
        if row==0 & col==0
            legend('in-situ','AATS-14')
        end
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<4 set(gca,'XTickLabel',[]); end
        if row==4 & col==2
            h22=text(8,-1.5,'Water Vapor Density [g/m^3]');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
    end
    if strcmp(product,'aod_profile')
        % plot AOD profile
        figure(1)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(AOD,GPS_Altitude,'.')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 0.5]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',[0:0.1:0.5]);
        set(gca,'ytick',[0:6]);
        hour_start=floor(UT_start);
        hour_end=floor(UT_end);
        min_start=round((UT_start-floor(UT_start))*60);
        min_end=round((UT_end-floor(UT_end))*60);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(.17,5.3,titlestr1,'FontSize',8);
        text(.17,4.8,titlestr2,'FontSize',8);

        %legend
        %         if row==0 & col==0
        %             legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        %                 num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'));
        %         end
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<4 set(gca,'XTickLabel',[]); end
        if row==4 & col==1
            h22=text(0.2,-1.2,'Aerosol Optical Depth');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.2,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot extinction profile
        figure(2)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(Extinction,GPS_Altitude,'.-')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 0.320]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',[0:0.08:0.32]);
        set(gca,'ytick',[0:6]);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(.12,5.3,titlestr1,'FontSize',8);
        text(.12,4.8,titlestr2,'FontSize',8);

        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<4 set(gca,'XTickLabel',[]); end
        if row==4 & col==1
            h22=text(0.2,-1.2,'Extinction [km^-^1]');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.07,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        % plot AOD spectral shape profile
        figure(3)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(alpha,GPS_Altitude,'c.',gamma,GPS_Altitude,'m.')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[-2 2]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[-2:2]);
        set(gca,'ytick',[0:6]);
        titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year-2000,hour_start,min_start,hour_end,min_end);
        h1=text(-1.8,5.4,titlestr);
        set(h1,'FontSize',8)

        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<4 set(gca,'XTickLabel',[]); end
        if row==4 & col==1
            h22=text(-0.5,-1.2,'Aerosol Optical Depth Spectral Parameters');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-3,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end

        %plot spectral shape profile
        figure(4)

        %don't plot if extinction is low
        ii=all(Extinction(1:12,:)>=0.003);

        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(alpha_ext(ii),GPS_Altitude(ii),'c.',gamma_ext(ii),GPS_Altitude(ii),'m.')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[-2 3]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[-2 -1 0 1 2 3]);
        set(gca,'ytick',[0:6]);
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(-1.8,5.4,titlestr);
        set(h1,'FontSize',8)

        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<4 set(gca,'XTickLabel',[]); end
        if row==4 & col==1
            h22=text(0.5,-1.2,'AATS-14 Extinction shape');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-2,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        if strcmp(MPLNET,'Yes')
            aats_DOY=DayOfYear(day,month,year)+(UT_start+UT_end)/2/24;
            %         this searches for exact match
            %         jj_mplnet(jprof)=interp1(mplnet_DOY,[1:length(mplnet_DOY)],aats_DOY,'nearest');
            %this searches back and forward for valid profiles, relevant for Level 3 only
            %         ii=0;
            %         while all(mplnet(jj_mplnet(jprof)+ii,:)<0)
            %             ii=ii+1;
            %         end
            %         jj=0;
            %         while all(mplnet(jj_mplnet(jprof)-jj,:)<0)
            %             jj=jj+1;
            %         end
            %         if  jj<=ii
            %             jj_mplnet(jprof)=jj_mplnet(jprof)-jj;
            %         end
            %         if  ii<jj
            %             jj_mplnet(jprof)=jj_mplnet(jprof)+ii;
            %         end
            %best matches
            %  jj_mplnet=[129,223,227,368,371,472,473,616,617,619,625,656,800,803,845,846,847,851,852,853,1003,1089,1091,1094,1145,1186]; % Lev3, 2deg
            %   jj_mplnet=[129,223,227,368,371,472,473,616,617,    625,656,800,803,845,846,847,851,852,853,1003,1089,1091,1094,1145,1186]; % Lev3, 2deg, 25 figures
            %    jj_mplnet=[129,225,226,368,371,472,475,616,617,619,622,656,802,803,845,846,847,  1,  1, 1  ,1003,1089,1091,1098,1145,1186]; % Lev3, 5deg, 25 figures
            %        jj_mplnet=[1,1,6,1,1,1,15,1,1,1,1,19,20,1,1,1,1,1,1,1,21,23,1,1,24]; % Lev2, 5deg, 25 figures old mining tool
            %        jj_mplnet=[1,1,1,1,1,1,1,1,1,1,36,1,1,38,1,1,1,1,1,1,39,1,1,42,48]; % Lev2, 5deg, 25 figures new mining tool, July 1
            jj_mplnet=[1,51,55,111,112,1,117 ,1,1,1,119,136,138,141,1,1,1,1,1,1,152,157,1,163,170]; % Lev2, 5deg, 25 figures test data set July 20
            %     jj_mplnet=[1,12,1,27,28,1,1,1,1,1,1,1,1,31,1,1,1,1,1,1,34,38,1,1,47]; % Lev2, 2deg, 25 figures test data set July 20

            if strcmp(MPLNET2,'Yes')
                mplnet(1,:)=-999;
            end
            delta_min=(mplnet_DOY(jj_mplnet(jprof))-aats_DOY)*24*60;
            UT_mplnet=(mplnet_DOY(jj_mplnet(jprof))-floor(mplnet_DOY(jj_mplnet(jprof))))*24;
            ii_mplnet=find(mplnet(jj_mplnet(jprof),:)~=-999);
            if isempty(ii_mplnet)
                mplnet_AOD=NaN.*mplnet_z;
                UT_mplnet=0;
            else
                mplnet_AOD=cumtrapz(mplnet_z(ii_mplnet),mplnet(jj_mplnet(jprof),ii_mplnet));
                mplnet_AOD=-mplnet_AOD+mplnet_AOD(end);
            end

            %bin data in altitude
            [ResMat,NewMat]=binning([mplnet_z',mplnet(jj_mplnet(jprof),:)'],0.020,0,zmax);
            mplnet_ext= ResMat(:,2);
            [ResMat,NewMat]=binning([mplnet_z',mplnet_AOD'],0.020,0,zmax);
            mplnet_AOD= ResMat(:,2);

            %accumulate data
            mplnet_ext_all=[mplnet_ext_all mplnet_ext'];

            %plot MPLNET profiles
            figure(5)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(mplnet(jj_mplnet(jprof),:),mplnet_z,'r.-')
            set(gca,'ylim',[0 8]);
            set(gca,'xlim',[-0.05 0.4]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0 0.1 0.2 0.3 0.4]);
            set(gca,'ytick',[0:1:8]);
            hour_mplnet=floor(UT_mplnet);
            min_mplnet=round((UT_mplnet-floor(UT_mplnet))*60);
            if min_mplnet==60
                hour_mplnet=hour_mplnet+1;
                min_mplnet=0;
            end
            titlestr=sprintf('%g %02d:%02dUT\n',mplnet_DOY(jj_mplnet(jprof)),hour_mplnet,min_mplnet);
            h1=text(0.08,7.3,titlestr);
            set(h1,'FontSize',8)
            titlestr=sprintf('%g %4.0fmin\n',jj_mplnet(jprof),delta_min);
            h1=text(0.08,6.7,titlestr);
            set(h1,'FontSize',8)
            %axis labels and titles
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Extinction [km^-^1]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.05,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end
        end

        %read MPLARM data (C. Flynn)
        if strcmp(MPLARM,'Yes')
            switch jprof
                case {8,9,10,17,18,19}     %these are the profiles where there are no MPLARM data
                    mplarm_ext=NaN.*Altitude;
                    mplarm_AOD=NaN.*Altitude;
                    UT_start_mplarm=0;
                    UT_end_mplarm=0;
                    nskip=nskip+1;
                otherwise
                    fid=fopen(deblank([pathname4,char(filelist4(jprof-nskip,:))]));
                    [data]=fscanf(fid,'%f %f %f %f',[4,inf]);
                    fclose(fid);
                    UT_start_mplarm=data(1,1);
                    UT_end_mplarm=data(1,2);
                    mplarm_z=data(2,:);
                    mplarm_ext=data(3,:);
                    mplarm_AOD=data(4,:);
                    %bin data in altitude
                    [ResMat,NewMat]=binning([mplarm_z',mplarm_ext'],0.020,0,zmax);
                    mplarm_ext= ResMat(:,2);
                    [ResMat,NewMat]=binning([mplarm_z',mplarm_AOD'],0.020,0,zmax);
                    mplarm_AOD= ResMat(:,2);
            end
            %accumulate data
            mplarm_ext_all=[mplarm_ext_all mplarm_ext'];
        end

        % read Cadenza data
        if strcmp(Cadenza,'Yes')
            % read Cadenza files
            fid=fopen(deblank([pathname3,char(filelist3(jprof,:))]));
            [data]=fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',[16,inf]);
            fclose(fid);

            UT_Cadenza=data(1,:);
            Alt_Cadenza=data(2,:);
            Cad_Ext_675_dry=data(3,:);
            Cad_Ext_1550_dry=data(4,:);
            Cad_Sca_675_dry=data(5,:);
            Cad_RH=data(6,:);
            Cad_press=data(7,:);
            Cad_temp=data(8,:);
            Cad_Ext_675=data(9,:);
            Cad_Sca_675=data(10,:);
            Cad_Abs_675=data(11,:);
            Cad_SSA_675=data(12,:);
            Cad_Ext_1550=data(13,:);
            Cad_RH_ambient=data(14,:);
            Cad_Prs_ambient=data(15,:);
            Cad_Temp_ambient=data(16,:);

            % plot Cadenza profiles
            %         figure(5)
            %         set(gcf,'Paperposition',[0.25 0.1 8 10]);
            %         subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            %         plot(Cad_Ext_675,Alt_Cadenza,'r.',Cad_Ext_1550,Alt_Cadenza,'k.')
            %         set(gca,'ylim',[0 6]);
            %         set(gca,'xlim',[0 0.3]);
            %         set(gca,'TickLength',[.03 .05]);
            %         set(gca,'xtick',[0 0.1 0.2 0.3]);
            %         set(gca,'ytick',[0:6]);
            %         UT_start=min(UT_Cadenza);
            %         UT_end=max(UT_Cadenza);
            %         hour_start=floor(UT_start);
            %         hour_end=floor(UT_end);
            %         min_start=round((UT_start-floor(UT_start))*60);
            %         min_end=round((UT_end-floor(UT_end))*60);
            %         titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
            %         h1=text(0.03,5.3,titlestr);
            %         set(h1,'FontSize',8)
            %         %axis labels and titles
            %         if row==0 & col==0
            %             legend('675 nm','1550 nm')
            %         end
            %         if col>=1 set(gca,'YTickLabel',[]); end
            %         if row<4 set(gca,'XTickLabel',[]); end
            %         if row==4 & col==1
            %             h22=text(0.2,-1.2,'Extinction [km^-^1]');
            %             set(h22,'FontSize',12)
            %         end
            %         if col==0 & row==2
            %             h33=text(-0.05,3,'Altitude [km]');
            %             set(h33,'FontSize',12,'Rotation',90)
            %         end

            %bin data in altitude
            [ResMat_675,NewMat_675]  =binning([Alt_Cadenza',Cad_Ext_675'],0.020,0,zmax);
            [ResMat_1550,NewMat_1550]=binning([Alt_Cadenza',Cad_Ext_1550'],0.020,0,zmax);
            [ResMat_RH,NewMat_RH]    =binning([Alt_Cadenza',Cad_RH'],0.020,0,zmax);
            [ResMat_RH_ambient,NewMat_RH_ambient]=binning([Alt_Cadenza',Cad_RH_ambient'],0.020,0,zmax);

            Cad_Ext_675   =ResMat_675(:,2);
            Cad_Ext_1550  =ResMat_1550(:,2);
            Cad_RH2=Cad_RH;
            Cad_RH        =ResMat_RH(:,2);
            Cad_RH_ambient=ResMat_RH_ambient(:,2);

            %accumulate data
            Cad_Ext_675_all   =[Cad_Ext_675_all Cad_Ext_675'];
            Cad_Ext_1550_all  =[Cad_Ext_1550_all Cad_Ext_1550'];
            Cad_RH_all        =[Cad_RH_all Cad_RH'];
            Cad_RH_ambient_all=[Cad_RH_ambient_all Cad_RH_ambient'];

            figure(6)   % plot Cadenza profiles binned
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(Cad_Ext_675,Altitude,'r.',Cad_Ext_1550,Altitude,'k.')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 0.2]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0:0.05:0.2]);
            set(gca,'ytick',[0:6]);
            UT_start=min(UT_Cadenza);
            UT_end=max(UT_Cadenza);
            hour_start=floor(UT_start);
            hour_end=floor(UT_end);
            min_start=round((UT_start-floor(UT_start))*60);
            min_end=round((UT_end-floor(UT_end))*60);
            titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
            h1=text(0.03,5.3,titlestr);
            set(h1,'FontSize',8)
            %axis labels and titles
            if row==0 & col==0
                legend('675 nm','1550 nm')
            end
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Extinction [km^-^1]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.05,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end

            %overplot Cadenza & AATS extinction at 1550 nm
            figure(7)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(Cad_Ext_1550,Altitude,'g.-',AATS_ext1558,Altitude,'m.-')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 0.09]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0:0.03:0.09]);
            set(gca,'ytick',[0:6]);
            titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
            titlestr2=sprintf('%02d:%02d-%02d:%02d\n',hour_start,min_start,hour_end,min_end);
            text(.04,5.3,titlestr1,'FontSize',8);
            text(.04,4.8,titlestr2,'FontSize',8);

            %axis labels and titles
            if row==0 & col==0
                legend('Cadenza','AATS-14')
            end
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Extinction [km^-^1]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(0.0,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end
        end
        if strcmp(Neph_PSAP,'Yes')
            % read Neph+PSAP profiles
            fid=fopen(deblank([pathname2,char(filelist2(jprof,:))]));
            [data]=fscanf(fid,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f',[16,inf]);
            fclose(fid);

            UT_neph=data(1,:);
            Alt_neph=data(2,:);
            ext_453_neph=data(3,:) + data(4,:);
            ext_519_neph=data(5,:) + data(6,:);
            ext_675_neph=data(7,:) + data(8,:);
            gamma=data(9,:);
            T_neph=data(10,:);
            p_neph=data(11,:);
            Neph_RH=data(12,:);
            Neph_T_ambient=data(13,:);
            Neph_p_ambient=data(14,:);
            Neph_RH_ambient=data(15,:);
            humid_flag=data(16,:);

            % plot RH amb profiles
            figure(8)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(Neph_RH_ambient,Alt_neph,'b.-',Cad_RH2,Alt_Cadenza,'c.-',Neph_RH,Alt_neph,'m.-')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 100]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0:20:100]);
            set(gca,'ytick',[0:6]);
            UT_start=min(UT_neph);
            UT_end=max(UT_neph);
            hour_start=floor(UT_start);
            hour_end=floor(UT_end);
            min_start=round((UT_start-floor(UT_start))*60);
            min_end=round((UT_end-floor(UT_end))*60);
%             titlestr1=sprintf('%02d/%02d/%02d\n',month,day,year-2000);
%             titlestr2=sprintf('%02d:%02d-%02d:%02d\n',hour_start,min_start,hour_end,min_end);
%             text(60,5.3,titlestr1,'FontSize',7);
%             text(60,4.8,titlestr2,'FontSize',7);
%          
            %axis labels and titles
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==2
                h22=text(40,-1.2,'RH [%]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-20,1,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end
            if row==0 & col==0
                legend('ambient','Cadenza','Neph')
            end

            % plot Neph+PSAP profiles
            figure(9)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(ext_453_neph,Alt_neph,'b.',ext_519_neph,Alt_neph,'g.',ext_675_neph,Alt_neph,'r.')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 0.3]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0 0.1 0.2 0.3]);
            set(gca,'ytick',[0:6]);
            UT_start=min(UT_neph);
            UT_end=max(UT_neph);
            hour_start=floor(UT_start);
            hour_end=floor(UT_end);
            min_start=round((UT_start-floor(UT_start))*60);
            min_end=round((UT_end-floor(UT_end))*60);
            titlestr=sprintf('%02d/%02d/%02d %02d:%02d-%02d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
            h1=text(0.03,5.3,titlestr);
            set(h1,'FontSize',8)
            %axis labels and titles
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Extinction [km^-^1]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.05,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end

            %bin data in altitude
            [ResMat_453,NewMat_453]      =binning([Alt_neph',ext_453_neph'],0.020,0,zmax);
            [ResMat_519,NewMat_519]      =binning([Alt_neph',ext_519_neph'],0.020,0,zmax);
            [ResMat_675,NewMat_675]      =binning([Alt_neph',ext_675_neph'],0.020,0,zmax);
            [ResMat_RH,NewMat_RH]        =binning([Alt_neph',Neph_RH_ambient'],0.020,0,zmax);
            [ResMat_RH_amb,NewMat_RH_amb]=binning([Alt_neph',Neph_RH_ambient'],0.020,0,zmax);
            [ResMat_RH, NewMat_RH]       =binning([Alt_neph',Neph_RH'],0.020,0,zmax);
            [ResMat_gamma,NewMat_gamma]  =binning([Alt_neph',gamma'],0.020,0,zmax);

            ext_453_neph   =ResMat_453(:,2);
            ext_519_neph   =ResMat_519(:,2);
            ext_675_neph   =ResMat_675(:,2);
            Neph_RH        =ResMat_RH(:,2);
            Neph_RH_ambient=ResMat_RH_amb(:,2);
            gamma          =ResMat_gamma(:,2);

            %calculate alpha
            clear alpha_neph
            for bin=1:length(Altitude)
                x=log([453,519,675]/1e3);
                y=log([ext_453_neph(bin),ext_519_neph(bin),ext_675_neph(bin)]);
                [p,S] = polyfit(x,y,1);
                alpha_neph(bin)=-p(1);
                if (ext_453_neph(bin)<=0.001 | ext_519_neph(bin)<=0.001 | ext_675_neph(bin)<=0.001);
                    alpha_neph(bin)=NaN;
                end
            end

            %calculate alpha aats for neph wvl.
            clear alpha_aats
            for bin=1:length(Altitude)
                x=log(lambda([3,5,7]))';
                y=log([AATS_ext453(bin),AATS_ext519(bin),AATS_ext675(bin)]);
                [p,S] = polyfit(x,y,1);
                alpha_aats(bin)=-p(1);
                if (AATS_ext453(bin)<=0.001 |  AATS_ext519(bin)<=0.001 | AATS_ext675(bin)<=0.001);
                    alpha_aats(bin)=NaN;
                end
            end

            %accumulate data
            ext_453_neph_all=[ext_453_neph_all ext_453_neph'];
            ext_519_neph_all=[ext_519_neph_all ext_519_neph'];
            ext_675_neph_all=[ext_675_neph_all ext_675_neph'];
            Neph_RH_ambient_all=[Neph_RH_ambient_all Neph_RH_ambient'];
            Neph_RH_all=[Neph_RH_all Neph_RH'];
            gamma_all  =[gamma_all gamma'];
            alpha_neph_all =[alpha_neph_all alpha_neph'];
            alpha_aats_all =[alpha_aats_all alpha_aats'];

            %plot binned data

            %RH amb profiles
            figure(10)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(Neph_RH_ambient,Altitude,'b.-',Cad_RH,Altitude,'c.-',Neph_RH,Altitude,'m.-')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 100]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0:20:100]);
            set(gca,'ytick',[0:6]);
            UT_start=min(UT_neph);
            UT_end=max(UT_neph);
            hour_start=floor(UT_start);
            hour_end=floor(UT_end);
            min_start=round((UT_start-floor(UT_start))*60);
            min_end=round((UT_end-floor(UT_end))*60);
            titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
            titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
            text(40,5.3,titlestr1,'FontSize',8);
            text(40,4.8,titlestr2,'FontSize',8);    %axis labels and titles
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(20,-1.2,'RH [%]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.05,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end

            %Extinction
            figure(11)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(ext_453_neph,Altitude,'b.-',ext_519_neph,Altitude,'g.-',ext_675_neph,Altitude,'r.-')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 0.320]);
            set(gca,'TickLength',[.03 .03]);
            set(gca,'xtick',[0:0.08:0.32]);
            set(gca,'ytick',[0:6]);
            titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
            titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
            text(.12,5.3,titlestr1,'FontSize',8);
            text(.12,4.8,titlestr2,'FontSize',8);
            %axis labels and titles
            if row==0 & col==0
                legend('453 nm','519 nm','675 nm')
            end
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Extinction [km^-^1]');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.05,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end

            %overplot neph & aats  & mplnet extinction
            if strcmp(MPLNET,'Yes')
                figure(12)
                set(gcf,'Paperposition',[0.25 0.1 8 10]);
                subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
                %plot(ext_519_neph,Altitude,'c.-',AATS_ext519,Altitude,'m.-',...
                %    mplarm_ext,Altitude,'g.-',...
                %    mplnet(jj_mplnet(jprof),:),mplnet_z,'r.-')
                plot(ext_519_neph(~isnan(ext_519_neph)),Altitude(~isnan(ext_519_neph)),'c.-',...
                    mplnet(jj_mplnet(jprof),:),mplnet_z,'r.-',...
                    mplarm_ext(~isnan(mplarm_ext)),Altitude(~isnan(mplarm_ext)),'k.-')
                set(gca,'ylim',[0 8]);
                set(gca,'xlim',[0.0 0.3]);
                set(gca,'TickLength',[.03 .05]);
                set(gca,'xtick',[0 0.1 0.2 0.3]);
                set(gca,'ytick',[0:8]);
                titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
                titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
                titlestr3=sprintf('%02d:%02d UT\n',hour_mplnet,min_mplnet);
                text(.1,7.2,titlestr1,'FontSize',8);
                text(.1,6.4,titlestr2,'Color','c','FontSize',8);
                text(.1,5.6,titlestr3,'Color','r','FontSize',8);
                text(.1,5.1,[time2str(UT_start_mplarm,'24','hm'),'-',time2str(UT_end_mplarm,'24','hm'),' UT'],'FontSize',8);
                % axis labels and titles
                if row==0 & col==0
                    legend('Neph+PSAP','MPLNET','MPLARM')
                end
                if col>=1 set(gca,'YTickLabel',[]); end
                if row<4 set(gca,'XTickLabel',[]); end
                if row==4 & col==1
                    h22=text(0.2,-1.2,'Extinction [km^-^1]');
                    set(h22,'FontSize',12)
                end
                if col==0 & row==2
                    h33=text(-0.05,3,'Altitude [km]');
                    set(h33,'FontSize',12,'Rotation',90)
                end
            end

            %overplot Neph & AATS-14 & Cadenza all at 675 nm
            if strcmp(Cadenza,'Yes')
                figure(13)
                set(gcf,'Paperposition',[0.25 0.1 8 10]);
                subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
                %plot(ext_675_neph,Altitude,'c.-',AATS_ext675, Altitude,'m.-',Cad_Ext_675, Altitude,'g.-')
                plot(ext_675_neph(~isnan(ext_675_neph)),Altitude(~isnan(ext_675_neph)),'c.-',...
                    AATS_ext675(~isnan(AATS_ext675)), Altitude(~isnan(AATS_ext675)),'m.-')
                set(gca,'ylim',[0 6]);
                set(gca,'xlim',[0 0.2]);
                set(gca,'TickLength',[.03 .05]);
                set(gca,'xtick',[0:0.05:0.2]);
                set(gca,'ytick',[0:6]);
                titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
                titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
                text(.07,5.3,titlestr1,'FontSize',8);
                text(.07,4.7,titlestr2,'FontSize',8);
                %axis labels and titles
                if row==0 & col==0
                    legend('Neph+PSAP','AATS-14')
                end
                if col>=1 set(gca,'YTickLabel',[]); end
                if row<4 set(gca,'XTickLabel',[]); end
                if row==4 & col==1
                    h22=text(0.2,-1.2,'Extinction [km^-^1]');
                    set(h22,'FontSize',12)
                end
                if col==0 & row==2
                    h33=text(-0.05,3,'Altitude [km]');
                    set(h33,'FontSize',12,'Rotation',90)
                end
            end

            %overplot Neph  & AATS & Cadenza & MPLNET AODs
            ii_neph=~isnan(ext_675_neph);
            AOD_453_neph=cumtrapz(Altitude(ii_neph),ext_453_neph(ii_neph));
            AOD_519_neph=cumtrapz(Altitude(ii_neph),ext_519_neph(ii_neph));
            AOD_675_neph=cumtrapz(Altitude(ii_neph),ext_675_neph(ii_neph));

            ii_Cad=~isnan(Cad_Ext_675);
            AOD_675_cad =cumtrapz(Altitude(ii_Cad),Cad_Ext_675(ii_Cad));
            AOD_1550_cad =cumtrapz(Altitude(ii_Cad),Cad_Ext_1550(ii_Cad));

            ii_AATS=~isnan(AATS_ext675);

            %find AOD at max Neph and Cadenza Alt
            AATS_AOD453_nephtop=interp1(Altitude(ii_AATS),AATS_AOD453(ii_AATS),max(Altitude(ii_neph)),'linear','extrap');
            AATS_AOD519_nephtop=interp1(Altitude(ii_AATS),AATS_AOD519(ii_AATS),max(Altitude(ii_neph)),'linear','extrap');
            AATS_AOD675_nephtop=interp1(Altitude(ii_AATS),AATS_AOD675(ii_AATS),max(Altitude(ii_neph)),'linear','extrap');

            AATS_AOD675_cadtop =interp1(Altitude(ii_AATS),AATS_AOD675(ii_AATS),max(Altitude(ii_Cad)),'linear','extrap');
            AATS_AOD1558_cadtop =interp1(Altitude(ii_AATS),AATS_AOD1558(ii_AATS),max(Altitude(ii_Cad)),'linear','extrap');

            %calculate Neph and Cadenza AOD
            AOD_453_neph=-AOD_453_neph+max(AOD_453_neph)+AATS_AOD453_nephtop;
            AOD_519_neph=-AOD_519_neph+max(AOD_519_neph)+AATS_AOD519_nephtop;
            AOD_675_neph=-AOD_675_neph+max(AOD_675_neph)+AATS_AOD675_nephtop;

            AOD_675_cad =-AOD_675_cad +max(AOD_675_cad) +AATS_AOD675_cadtop;
            AOD_1550_cad =-AOD_1550_cad +max(AOD_1550_cad) +AATS_AOD1558_cadtop;

            %find bottom and top AOD
            i_bot_AATS=min(find(ii_AATS==1));
            i_top_AATS=max(find(ii_AATS==1));
            i_bot_neph=min(find(ii_neph==1));
            i_bot_Cad =min(find(ii_Cad==1));

            AOD_453_neph_bot=interp1(Altitude(ii_neph),AOD_453_neph,Altitude(max([i_bot_AATS,i_bot_neph])));
            AOD_519_neph_bot=interp1(Altitude(ii_neph),AOD_519_neph,Altitude(max([i_bot_AATS,i_bot_neph])));
            AOD_675_neph_bot=interp1(Altitude(ii_neph),AOD_675_neph,Altitude(max([i_bot_AATS,i_bot_neph])));

            AOD_675_cad_bot =interp1(Altitude(ii_Cad),AOD_675_cad, Altitude(max([i_bot_AATS,i_bot_Cad])));
            AOD_1550_cad_bot =interp1(Altitude(ii_Cad),AOD_1550_cad, Altitude(max([i_bot_AATS,i_bot_Cad])));

            AATS_AOD453_nephbot=interp1(Altitude(ii_AATS),AATS_AOD453(ii_AATS),Altitude(max([i_bot_AATS,i_bot_neph])));
            AATS_AOD519_nephbot=interp1(Altitude(ii_AATS),AATS_AOD519(ii_AATS),Altitude(max([i_bot_AATS,i_bot_neph])));
            AATS_AOD675_nephbot=interp1(Altitude(ii_AATS),AATS_AOD675(ii_AATS),Altitude(max([i_bot_AATS,i_bot_neph])));

            AATS_AOD675_cadbot =interp1(Altitude(ii_AATS),AATS_AOD675(ii_AATS),Altitude(max([i_bot_AATS,i_bot_Cad])));
            AATS_AOD1558_cadbot =interp1(Altitude(ii_AATS),AATS_AOD1558(ii_AATS),Altitude(max([i_bot_AATS,i_bot_Cad])));

            %calculate layer AODs
            AOD_453_neph_layer(jprof)=AOD_453_neph_bot-AATS_AOD453_nephtop;
            AOD_519_neph_layer(jprof)=AOD_519_neph_bot-AATS_AOD519_nephtop;
            AOD_675_neph_layer(jprof)=AOD_675_neph_bot-AATS_AOD675_nephtop;

            AOD_675_cad_layer(jprof)=AOD_675_cad_bot-AATS_AOD675_cadtop ;
            AOD_1550_cad_layer(jprof)=AOD_1550_cad_bot-AATS_AOD1558_cadtop ;

            AOD_453_aats_neph_layer(jprof)=AATS_AOD453_nephbot-AATS_AOD453_nephtop;
            AOD_519_aats_neph_layer(jprof)=AATS_AOD519_nephbot-AATS_AOD519_nephtop;
            AOD_675_aats_neph_layer(jprof)=AATS_AOD675_nephbot-AATS_AOD675_nephtop;

            AOD_675_aats_cad_layer(jprof) =AATS_AOD675_cadbot -AATS_AOD675_cadtop;
            AOD_1558_aats_cad_layer(jprof) =AATS_AOD1558_cadbot -AATS_AOD1558_cadtop;

            if strcmp(MPLNET,'Yes')
                %MPLNET and AATS AOD at min and max AATS altitudes
                ii_mplnet=find(isnan(mplnet_AOD)==0);
                if isempty(ii_mplnet)
                    mplnet_AOD_AATS_bot(jprof)=NaN;
                    mplnet_AOD_AATS_top(jprof)=NaN;
                else
                    mplnet_AOD_AATS_bot(jprof)=interp1(Altitude(ii_mplnet),mplnet_AOD(ii_mplnet),Altitude(i_bot_AATS));
                    mplnet_AOD_AATS_top(jprof)=interp1(Altitude(ii_mplnet),mplnet_AOD(ii_mplnet),Altitude(i_top_AATS));
                end

                AATS_AOD519_mpl_bot(jprof)=AATS_AOD519(i_bot_AATS);
                AATS_AOD_Error519_mpl_bot(jprof)=AATS_AOD_Error519(i_bot_AATS);
                AATS_AOD519_mpl_top(jprof)=AATS_AOD519(i_top_AATS);
                AATS_AOD_Error519_mpl_top(jprof)=AATS_AOD_Error519(i_top_AATS);
            end

            if strcmp(MPLARM,'Yes')
                %MPLARM and AATS AOD at min and max AATS altitudes
                ii_mplarm=find(isnan(mplarm_AOD)==0);
                switch jprof
                    case {8,9,10,17,18,19}     %these are the profiles where there are no MPLARM data
                        mplarm_AOD_AATS_bot(jprof)=NaN;
                        mplarm_AOD_AATS_top(jprof)=NaN;
                    otherwise
                        mplarm_AOD_AATS_bot(jprof)=interp1(Altitude(ii_mplarm),mplarm_AOD(ii_mplarm),Altitude(i_bot_AATS),'linear','extrap');
                        mplarm_AOD_AATS_top(jprof)=interp1(Altitude(ii_mplarm),mplarm_AOD(ii_mplarm),Altitude(i_top_AATS));
                end
            end

            %claculate error of layer AOD
            mean_AOD_453(jprof)=AOD_453_aats_neph_layer(jprof)/2;
            mean_AOD_519(jprof)=AOD_519_aats_neph_layer(jprof)/2;
            mean_AOD_675(jprof)=AOD_675_aats_neph_layer(jprof)/2;
            mean_AOD_1558(jprof)=AOD_1558_aats_cad_layer(jprof)/2;

            rng(jprof) = DISTANCE(Latitude(1),Longitude(1),Latitude(end),Longitude(end));
            layer_depth(jprof)=max(Altitude(ii_AATS))-min(Altitude(ii_AATS));

            %overplot AODs
            figure(14)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(AOD_675_neph,Altitude(ii_neph),'c.-',AATS_AOD675, Altitude,'m.',AOD_675_cad,Altitude(ii_Cad),'g.-')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 0.3]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0 0.1 0.2 0.3]);
            set(gca,'ytick',[0:6]);
            titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
            titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
            text(.1,5.3,titlestr1,'FontSize',8);
            text(.1,4.8,titlestr2,'FontSize',8);
            %axis labels and titles
            if row==0 & col==0
                legend('Neph+PSAP','AATS-14','Cadenza')
            end
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Aerosol Optical Depth');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.05,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end

            %overplot AODs
            if strcmp(MPLNET,'Yes')
                figure(15)
                set(gcf,'Paperposition',[0.25 0.1 8 10]);
                subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
                %plot(AOD_519_neph,Altitude(ii_neph),'c.-',AATS_AOD519, Altitude,'m.',mplarm_AOD,Altitude,'g.-',mplnet_AOD,Altitude,'r.-')
                plot(mplarm_AOD,Altitude,'k.-',...
                    mplnet_AOD,Altitude,'r.-',...
                    AATS_AOD519(~isnan(AATS_AOD519)), Altitude(~isnan(AATS_AOD519)),'g.-')
                set(gca,'ylim',[0 8]);
                set(gca,'xlim',[0 0.42]);
                set(gca,'TickLength',[.03 .05]);
                set(gca,'xtick',[0 0.1 0.2 0.3 0.4]);
                set(gca,'ytick',[0:8]);
                titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
                titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
                text(.1,7.0,titlestr1,'FontSize',8);
                text(.1,6.3,titlestr2,'FontSize',8);
                %                axis labels and titles
                if row==0 & col==0
                    legend('MPLARM','MPLNET','AATS-14')
                end
                if col>=1 set(gca,'YTickLabel',[]); end
                if row<4 set(gca,'XTickLabel',[]); end
                if row==4 & col==1
                    h22=text(0.2,-1.2,'Aerosol Optical Depth');
                    set(h22,'FontSize',12)
                end
                if col==0 & row==2
                    h33=text(-0.05,3,'Altitude [km]');
                    set(h33,'FontSize',12,'Rotation',90)
                end
            end

            %plot alpha's
            figure(16)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(alpha_neph(ii_neph),Altitude(ii_neph),'m.-',alpha_aats(ii_AATS), Altitude(ii_AATS),'c.')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[-2 3]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[-2:3]);
            set(gca,'ytick',[0:6]);
            titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
            titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
            text(-1.7,0.7,titlestr1,'FontSize',8);
            text(-1.9,0.2,titlestr2,'FontSize',8);
            %axis labels and titles
            if row==0 & col==0
                legend('Neph+PSAP','AATS-14')
            end
            if col>=1 set(gca,'YTickLabel',[]); end
            if row<4 set(gca,'XTickLabel',[]); end
            if row==4 & col==1
                h22=text(0.2,-1.2,'Alpha');
                set(h22,'FontSize',12)
            end
            if col==0 & row==2
                h33=text(-0.8,3,'Altitude [km]');
                set(h33,'FontSize',12,'Rotation',90)
            end
        end
    end
end

%Overall comparisons
if strcmp(product,'h2o_profile')
    layer_H2O_AATS14_Error=0.005.*deg2km(rng).*mean_H2O;
    figure(3)
    x=layer_H2O_AATS14;
    y=layer_H2O_is;
    n=length(x);
    mean_x=mean(x)
    mean_y=mean(y)
    rmsd=(sum((x-y).^2)/(n-1))^0.5
    rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
    bias=mean(y-x)
    rel_bias=bias/mean(x)
    range=[0 3];
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, 3, 0, 3, x, y,layer_H2O_AATS14_Error,'ko')
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'k--',range,range,'k')
    text(2,.6,sprintf('n= %i ',n),'FontSize',14)
    text(2,.47,sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(2,.34,sprintf('y = %5.3fx %+5.3f',[m b]),'FontSize',14)
    text(2,.21,sprintf('rms = %5.3f, %3.1f %%',rmsd, 100*rel_rmsd),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('in-situ - Layer H_2O [g/cm^2]','FontSize',14)
    xlabel('AATS-14 - Layer H_2O [g/cm^2]','FontSize',14)
    axis square
    set(gca,'FontSize',14)

    figure(4)
    x=H2O_dens_all;
    y=H2O_dens_is_all;
    n=length(x);
    mean_x=mean(x)
    mean_y=mean(y)
    rmsd=(sum((x-y).^2)/(n-1))^0.5
    rel_rmsd=rmsd/0.5/(mean(x)+mean(y))
    bias=mean(y-x)
    rel_bias=bias/mean(x)
    range=[0 16];
    plot(x,y,'k.')
    hold on
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'k--',range,range,'k')
    text(10,3,sprintf('n= %i ',n),'FontSize',14)
    text(10,2.2,sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(10,1.4,sprintf('y = %5.3fx %+5.3f',[m b]),'FontSize',14)
    text(10,0.6,sprintf('rms = %5.3f, %3.1f %%',rmsd, 100*rel_rmsd),'FontSize',14)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    xlabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:2:16]);
    set(gca,'ytick',[0:2:16]);

    figure(5)
    plot(H2O_Error_all)

end
if strcmp(Neph_PSAP,'Yes')
    figure(17)
    x=AOD_453_aats_neph_layer;
    y=AOD_453_neph_layer;
    layer_AOD_AATS14_Error=0.018.*deg2km(rng).*mean_AOD_453;
    layer_AOD_Neph_Error=0.1*y;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .4, 0, .4, x, y,layer_AOD_AATS14_Error,'k.')
    yerrorbar('linlin',0, .4, 0, .4, x, y,layer_AOD_Neph_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.4];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Layer AOD: AATS-14','FontSize',14)
    ylabel('Layer AOD: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14);
    set(gca,'xtick',[0:0.05:0.4]);
    set(gca,'ytick',[0:0.05:0.4]);

    %use new Matlab scripts by Edward T. Peltzer
    sX=layer_AOD_AATS14_Error;
    sY=layer_AOD_Neph_Error;
    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')
    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')
    [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(x,y,sY);
    disp([mw,bw,rw,smw,sbw,xw,yw])
    [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(x,y,sY);
    disp([mz,bz,rz,smz,sbz,xz,yz])
    [m,b,r,sm,sb]=lsqfitma(x,y);
    disp([m,b,r,sm,sb])
    [m,b,r,sm,sb] = lsqfitgm(x,y);
    disp([m,b,r,sm,sb])
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')
    %     [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    %     disp([m,b,rc,sm,sb,xc,yc,ct])
    text(0.02,0.38,'\lambda= 453 nm','FontSize',12)
    text(0.02,0.36, sprintf('n= %i ',n),'FontSize',12)
    text(0.02,0.34, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.02,0.32, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.02,0.30, sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.02,0.28, sprintf('bias= %5.3f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.02,0.26, sprintf('mean x = %5.3f; mean y = %5.3f',mean(x),mean(y)),'FontSize',12)
    hold off

    figure(18)
    x=AOD_519_aats_neph_layer;
    y=AOD_519_neph_layer;
    layer_AOD_AATS14_Error=0.018.*deg2km(rng).*mean_AOD_519;
    layer_AOD_Neph_Error=0.1*y;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .35, 0, .35, x, y,layer_AOD_AATS14_Error,'k.')
    yerrorbar('linlin',0, .35, 0, .35, x, y,layer_AOD_Neph_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.35];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Layer AOD: AATS-14','FontSize',14)
    ylabel('Layer AOD: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.35]);
    set(gca,'ytick',[0:0.05:0.35]);

    %use new Matlab scripts by Edward T. Peltzer
    sX=layer_AOD_AATS14_Error;
    sY=layer_AOD_Neph_Error;
    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')
    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')
    [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(x,y,sY);
    disp([mw,bw,rw,smw,sbw,xw,yw])
    [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(x,y,sY);
    disp([mz,bz,rz,smz,sbz,xz,yz])
    [m,b,r,sm,sb]=lsqfitma(x,y);
    disp([m,b,r,sm,sb])
    [m,b,r,sm,sb] = lsqfitgm(x,y);
    disp([m,b,r,sm,sb])
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')
    %     [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    %     disp([m,b,rc,sm,sb,xc,yc,ct])
    text(0.01,0.32 ,'\lambda= 519 nm','FontSize',12)
    text(0.01,0.30, sprintf('n= %i ',n),'FontSize',12)
    text(0.01,0.28, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.01,0.26, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.01,0.24, sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.01,0.22, sprintf('bias= %5.3f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.01,0.20, sprintf('mean x = %5.3f; mean y = %5.3f',mean(x),mean(y)),'FontSize',12)
    hold off

    figure(19)
    x=AOD_675_aats_neph_layer;
    y=AOD_675_neph_layer;
    layer_AOD_AATS14_Error=0.018.*deg2km(rng).*mean_AOD_675;
    layer_AOD_Neph_Error=0.1*y;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .3, 0, .3, x, y,layer_AOD_AATS14_Error,'k.')
    yerrorbar('linlin',0, .3, 0, .3, x, y,layer_AOD_Neph_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.3];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Layer AOD: AATS-14','FontSize',14)
    ylabel('Layer AOD: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.3]);
    set(gca,'ytick',[0:0.05:0.3]);

    %use new Matlab scripts by Edward T. Peltzer
    sX=layer_AOD_AATS14_Error;
    sY=layer_AOD_Neph_Error;
    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')
    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')
    [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(x,y,sY);
    disp([mw,bw,rw,smw,sbw,xw,yw])
    [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(x,y,sY);
    disp([mz,bz,rz,smz,sbz,xz,yz])
    [m,b,r,sm,sb]=lsqfitma(x,y);
    disp([m,b,r,sm,sb])
    [m,b,r,sm,sb] = lsqfitgm(x,y);
    disp([m,b,r,sm,sb])
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')
    %     [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    %     disp([m,b,rc,sm,sb,xc,yc,ct])
    text(0.01,0.29 ,'\lambda= 675 nm','FontSize',12)
    text(0.01,0.275, sprintf('n= %i ',n),'FontSize',12)
    text(0.01,0.26, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.01,0.245, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.01,0.23, sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.01,0.215, sprintf('bias= %5.3f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.01,0.2, sprintf('mean x = %5.3f; mean y = %5.3f',mean(x),mean(y)),'FontSize',12)
    hold off
end
if strcmp(Cadenza,'Yes')
    figure(20)
    x=AOD_675_aats_cad_layer;
    y=AOD_675_cad_layer;
    layer_AOD_AATS14_Error=0.018.*deg2km(rng).*mean_AOD_675;
    layer_AOD_Neph_Error=0.1*y;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .3, 0, .3, x, y,layer_AOD_AATS14_Error,'k.')
    yerrorbar('linlin',0, .3, 0, .3, x, y,layer_AOD_Neph_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.3];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Layer AOD: AATS-14','FontSize',14)
    ylabel('Layer AOD: Cadenza','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.3]);
    set(gca,'ytick',[0:0.05:0.3]);

    %use new Matlab scripts by Edward T. Peltzer
    sX=layer_AOD_AATS14_Error;
    sY=layer_AOD_Neph_Error;

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(x,y,sY);
    disp([mw,bw,rw,smw,sbw,xw,yw])

    [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(x,y,sY);
    disp([mz,bz,rz,smz,sbz,xz,yz])

    [m,b,r,sm,sb]=lsqfitma(x,y);
    disp([m,b,r,sm,sb])

    [m,b,r,sm,sb] = lsqfitgm(x,y);
    disp([m,b,r,sm,sb])

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')
    text(0.01,0.29 ,'\lambda= 675 nm','FontSize',12)
    text(0.01,0.275, sprintf('n= %i ',n),'FontSize',12)
    text(0.01,0.26, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.01,0.245, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.01,0.23, sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.01,0.215, sprintf('bias= %5.3f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.01,0.2, sprintf('mean x = %5.3f; mean y = %5.3f',mean(x),mean(y)),'FontSize',12)

    [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    disp([m,b,rc,sm,sb,xc,yc,ct])
    %      [y_fit] = polyval([m,b],range);
    %      plot(range,y_fit,'c-')
    hold off

    figure(21)
    x=AOD_1558_aats_cad_layer;
    y=AOD_1550_cad_layer;
    layer_AOD_AATS14_Error=0.018.*deg2km(rng).*mean_AOD_1558;
    layer_AOD_Neph_Error=0.1*y;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .14, 0, .14, x, y,layer_AOD_AATS14_Error,'k.')
    yerrorbar('linlin',0, .14, 0, .14, x, y,layer_AOD_Neph_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.14];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Layer AOD: AATS-14','FontSize',14)
    ylabel('Layer AOD: Cadenza','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.02:0.14]);
    set(gca,'ytick',[0:0.02:0.14]);

    %use new Matlab scripts by Edward T. Peltzer
    sX=layer_AOD_AATS14_Error;
    sY=layer_AOD_Neph_Error;

    [my,by,ry,smy,sby]=lsqfity(x,y);
    disp([my,by,ry,smy,sby])
    [y_fit] = polyval([my,by],range);
    plot(range,y_fit,'b-')

    [mxi,bxi,rxi,smxi,sbxi]=lsqfitxi(x,y);
    disp([mxi,bxi,rxi,smxi,sbxi])
    [y_fit] = polyval([mxi,bxi],range);
    plot(range,y_fit,'g-')

    [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(x,y,sY);
    disp([mw,bw,rw,smw,sbw,xw,yw])

    [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(x,y,sY);
    disp([mz,bz,rz,smz,sbz,xz,yz])

    [m,b,r,sm,sb]=lsqfitma(x,y);
    disp([m,b,r,sm,sb])

    [m,b,r,sm,sb] = lsqfitgm(x,y);
    disp([m,b,r,sm,sb])

    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')
    text(0.01,0.13 ,'\lambda= 1550/1558 nm','FontSize',12)
    text(0.01,0.125, sprintf('n= %i ',n),'FontSize',12)
    text(0.01,0.12, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.01,0.115, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.01,0.11, sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.01,0.105, sprintf('bias= %5.3f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.01,0.1, sprintf('mean x = %5.3f; mean y = %5.3f',mean(x),mean(y)),'FontSize',12)

    [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    disp([m,b,rc,sm,sb,xc,yc,ct])
    %      [y_fit] = polyval([m,b],range);
    %      plot(range,y_fit,'c-')
    hold off

    %compare AATS and Cadenza

    %calculate alphas at Cadenza wavelengths
    alpha_Cad=-log(Cad_Ext_675_all./Cad_Ext_1550_all)./log(675/1550);
    ii=find(Cad_Ext_675_all<=0.001);
    jj=find(Cad_Ext_1550_all<=0.001);
    alpha_Cad(ii)=NaN;
    alpha_Cad(jj)=NaN;

    alpha_aatsNIR=-log(AATS_ext675_all./AATS_ext1558_all)./log(675/1558)
    ii=find(AATS_ext675_all<=0.001);
    jj=find(AATS_ext1558_all<=0.001);
    alpha_aatsNIR(ii)=NaN;
    alpha_aatsNIR(jj)=NaN;

    %Exinction at 675 nm
    %stratify by RH
    i_strat=find(Cad_RH_ambient_all>=0 & Cad_RH_ambient_all<=100);
    
    %stratify by gamma
    %i_strat=find(gamma_all~=0);

    %stratify by alpha
%     i_strat=find(alpha_aats_all>1.5 & alpha_aats_all<=2.5);
   
%     x=Cad_RH_all;
%     y=Cad_RH_ambient_all;
%     z=gamma_all;
%     f_Cad=((100-x)./(100-y)).^z;
    
%     %mess around with humidification
%     z(z==0)=0.3; % set gamma 0 to median value
%     z=z*1.48;
%     f_Cad_test=((100-x)./(100-(y+3))).^z;

    figure(22)
     
    x=AATS_ext675_all(i_strat);
    y=Cad_Ext_675_all(i_strat);
    
%     %mess around with humidification
%     y=y./f_Cad(i_strat).*f_Cad_test(i_strat);
 
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.013 0.20];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: Cadenza','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.2]);
    set(gca,'ytick',[0:0.05:0.2]);

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
    text(-.005,0.19 ,'\lambda= 675 nm','FontSize',12)
    text(-.005,0.18, sprintf('n= %i ',n),'FontSize',12)
    text(-.005,0.17, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(-.005,0.16, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(-.005,0.15, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(-.005,0.14, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(-.005,0.13, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(-.005,0.12, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare AATS and Cadenza exinction at 1550/1558 nm
    figure(23)
    x=AATS_ext1558_all(i_strat);
    y=Cad_Ext_1550_all(i_strat);
    
%     %mess around with humidification
%     y=y./f_Cad(i_strat).*f_Cad_test(i_strat);
    
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.01 0.06];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: Cadenza','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[-0.01:0.01:0.06]);
    set(gca,'ytick',[-0.01:0.01:0.06]);

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
    text(-.005,0.056,'\lambda= 1550/1558 nm','FontSize',12)
    text(-.005,0.052, sprintf('n= %i ',n),'FontSize',12)
    text(-.005,0.048, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(-.005,0.044, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(-.005,0.040, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(-.005,0.036, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(-.005,0.032, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(-.005,0.028, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare AATS and Neph exinction at 453 nm
    %stratify by RH
    i_strat=find(Neph_RH_ambient_all>=0 & Neph_RH_ambient_all<=100);

    %stratify by alpha
    %i_strat=find(alpha_aats_all>=0 & alpha_aats_all<=2.5);

%     x=Neph_RH_all;
%     y=Neph_RH_ambient_all;
%     z=gamma_all;
%     f_Neph=((100-x)./(100-y)).^z;
%     
%     %mess around with humidification
%     z(z==0)=0.3; % set gamma 0 to median value
%     z=z*1;
%     median(z(~isnan(z)))
%     f_Neph_test=((100-x)./(100-(y+3))).^z;
        
    figure(24)
    x=AATS_ext453_all(i_strat);
    y=ext_453_neph_all(i_strat);
    
%     %mess around with humidification
%     y=y./f_Neph(i_strat).*f_Neph_test(i_strat);
    
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.025 0.35];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.35]);
    set(gca,'ytick',[0:0.05:0.35]);

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
    text(0.21,0.09,'\lambda= 453 nm','FontSize',12)
    text(0.21,0.075, sprintf('n= %i ',n),'FontSize',12)
    text(0.21,0.06, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.21,0.045, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.21,0.030, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.21,0.015, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.21,0.000, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.21,-0.015, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare AATS and Neph exinction at 519 nm
    figure(25)
    x=AATS_ext519_all(i_strat);
    y=ext_519_neph_all(i_strat);
    
%     %mess around with humidification
%     y=y./f_Neph(i_strat).*f_Neph_test(i_strat);
    
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.02 0.3];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.3]);
    set(gca,'ytick',[0:0.05:0.3]);

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
    text(0.2,0.092 ,'\lambda= 519 nm','FontSize',12)
    text(0.2,0.077, sprintf('n= %i ',n),'FontSize',12)
    text(0.2,0.062, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.2,0.047, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.2,0.032, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.2,0.017, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.2,0.002, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.2,-0.013, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare AATS and Neph exinction at 675 nm
    figure(26)
    x=AATS_ext675_all(i_strat);
    y=ext_675_neph_all(i_strat);
       
%     %mess around with humidification
%     y=y./f_Neph(i_strat).*f_Neph_test(i_strat);
    
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.013 0.200];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0.0:0.05:0.2]);
    set(gca,'ytick',[0.0:0.05:0.2]);

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
    text(-0.01,0.19 ,'\lambda= 675 nm','FontSize',12)
    text(-0.01,0.18, sprintf('n= %i ',n),'FontSize',12)
    text(-0.01,0.17, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(-0.01,0.16, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(-0.01,0.15, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(-0.01,0.14, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(-0.01,0.13, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(-0.01,0.12, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare Cad and Neph exinction at 675 nm
    figure(27)
    y=Cad_Ext_675_all;
    x=ext_675_neph_all;
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    plot(x,y,'.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.005 0.200];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    ylabel('Extinction [km^-^1]: Cadenza','FontSize',14)
    xlabel('Extinction [km^-^1]: Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.2]);
    set(gca,'ytick',[0:0.05:0.2]);

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
    text(0.0,0.19 ,'\lambda= 675 nm','FontSize',12)
    text(0.0,0.18, sprintf('n= %i ',n),'FontSize',12)
    text(0.0,0.17, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.0,0.16, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(0.0,0.15, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(0.0,0.14, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(0.0,0.13, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(0.0,0.12, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    %compare AATS and MPLNET exinction at 519/523 nm
    if strcmp(MPLNET,'Yes')
        figure(28)
        x=AATS_ext519_all;
        y=mplnet_ext_all;
        ii=find((~isnan(x).*~isnan(y).*(y~=-999))==1.); %remove NaNs
        x=x(ii); y=y(ii);
        plot(x,y,'.')
        hold on
        n=length(x);
        rmsd=(sum((x-y).^2)/(n-1))^0.5;
        bias=mean(y-x);
        r=corrcoef(x,y);
        r=r(1,2);
        range=[-0.02 0.3];
        [p,S] = polyfit (x,y,1);
        [y_fit,delta] = polyval(p,range,S);
        plot(range,y_fit,'k--',range,range,'k')
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
        ylabel('Extinction [km^-^1]: MPLNET L2','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:.05:0.3]);
        set(gca,'ytick',[0:.05:0.3]);

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
        text(0.2,0.08,'\lambda= 519/523 nm','FontSize',12)
        text(0.2,0.07, sprintf('n= %i ',n),'FontSize',12)
        text(0.2,0.06, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.2,0.05, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.2,0.04, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.2,0.03, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.2,0.02, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

        %compare MPLNET and AATS top, bottom and layer AOD 519/523 nm
        figure(29)
        %top
        y=mplnet_AOD_AATS_top;
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
        r=corrcoef(x,y);
        r=r(1,2);
        range=[0 0.100];
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('top AOD: AATS-14','FontSize',14)
        ylabel('top AOD: MPLNET','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:0.02:0.1]);
        set(gca,'ytick',[0:0.02:0.1]);

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
        text(0.07,0.045 ,'\lambda= 519/523 nm','FontSize',12)
        text(0.07,0.04, sprintf('n= %i ',n),'FontSize',12)
        text(0.07,0.035, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.07,0.03, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.07,0.025, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.07,0.02, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.07,0.015, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.07,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

        %bottom
        y=mplnet_AOD_AATS_bot;
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
        r=corrcoef(x,y);
        r=r(1,2);
        range=[0 0.500];
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('bottom AOD: AATS-14','FontSize',14)
        ylabel('bottom AOD: MPLNET','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:0.05:0.5]);
        set(gca,'ytick',[0:0.05:0.5]);

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
        text(0.3,0.15 ,'\lambda= 519/523 nm','FontSize',12)
        text(0.3,0.13, sprintf('n= %i ',n),'FontSize',12)
        text(0.3,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.3,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.3,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.3,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.3,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.3,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

        %layer
        y=mplnet_AOD_AATS_bot-mplnet_AOD_AATS_top;
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
        r=corrcoef(x,y);
        r=r(1,2);
        range=[0 0.500];
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('layer AOD: AATS-14','FontSize',14)
        ylabel('layer AOD: MPLNET','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:0.05:0.5]);
        set(gca,'ytick',[0:0.05:0.5]);

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
        text(0.3,0.15 ,'\lambda= 519/523 nm','FontSize',12)
        text(0.3,0.13, sprintf('n= %i ',n),'FontSize',12)
        text(0.3,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.3,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.3,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.3,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.3,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.3,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
    end
    %compare AATS and MPLARM exinction at 519/523 nm
    if strcmp(MPLARM,'Yes')
        figure(30)
        x=AATS_ext519_all;
        y=mplarm_ext_all;
        ii=find((~isnan(x).*~isnan(y).*(y~=-999))==1.); %remove NaNs
        x=x(ii); y=y(ii);
        plot(x,y,'.')
        hold on
        n=length(x);
        rmsd=(sum((x-y).^2)/(n-1))^0.5;
        bias=mean(y-x);
        r=corrcoef(x,y);
        r=r(1,2);
        range=[-0.02 0.3];
        [p,S] = polyfit (x,y,1);
        [y_fit,delta] = polyval(p,range,S);
        plot(range,y_fit,'k--',range,range,'k')
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
        ylabel('Extinction [km^-^1]: MPLARM','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:.05:0.3]);
        set(gca,'ytick',[0:.05:0.3]);

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
        text(0.2,0.08,'\lambda= 519/523 nm','FontSize',12)
        text(0.2,0.07, sprintf('n= %i ',n),'FontSize',12)
        text(0.2,0.06, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.2,0.05, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.2,0.04, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.2,0.03, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.2,0.02, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.2,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

        %compare MPLARM and AATS top and bottom AOD 519/523 nm
        figure(31)
        %top
        y=mplarm_AOD_AATS_top;
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
        r=corrcoef(x,y);
        r=r(1,2);
        range=[0 0.100];
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('top AOD: AATS-14','FontSize',14)
        ylabel('top AOD: MPLARM','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:0.02:0.1]);
        set(gca,'ytick',[0:0.02:0.1]);

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
        text(0.07,0.045 ,'\lambda= 519/523 nm','FontSize',12)
        text(0.07,0.04, sprintf('n= %i ',n),'FontSize',12)
        text(0.07,0.035, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.07,0.03, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.07,0.025, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.07,0.02, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.07,0.015, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.07,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

        %bottom
        y=mplarm_AOD_AATS_bot;
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
        r=corrcoef(x,y);
        r=r(1,2);
        range=[0 0.350];
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('bottom AOD: AATS-14','FontSize',14)
        ylabel('bottom AOD: MPLARM','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:0.05:0.35]);
        set(gca,'ytick',[0:0.05:0.35]);

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
        text(0.3,0.15 ,'\lambda= 519/523 nm','FontSize',12)
        text(0.3,0.13, sprintf('n= %i ',n),'FontSize',12)
        text(0.3,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.3,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.3,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.3,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.3,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.3,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

        %layer
        y=mplarm_AOD_AATS_bot-mplarm_AOD_AATS_top;
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
        r=corrcoef(x,y);
        r=r(1,2);
        range=[0 0.350];
        set(gca,'ylim',range);
        set(gca,'xlim',range);
        xlabel('layer AOD: AATS-14','FontSize',14)
        ylabel('layer AOD: MPLARM','FontSize',14)
        axis square
        set(gca,'FontSize',14)
        set(gca,'xtick',[0:0.05:0.35]);
        set(gca,'ytick',[0:0.05:0.35]);

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
        text(0.3,0.15 ,'\lambda= 519/523 nm','FontSize',12)
        text(0.3,0.13, sprintf('n= %i ',n),'FontSize',12)
        text(0.3,0.11, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
        text(0.3,0.09, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
        text(0.3,0.07, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
        text(0.3,0.05, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
        text(0.3,0.03, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
        text(0.3,0.01, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)
    end
    %plot RH histograms
    figure(32)
    subplot(2,1,1)
    x=Neph_RH_all;
    y=Cad_RH_all;
    z=Cad_RH_ambient_all;
    ii=find(~isnan(x).*~isnan(y).*~isnan(z)==1); %remove NaNs
    x=x(ii); y=y(ii);z=z(ii);
    n=length(x);
    bias=mean(y-x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    plot(y-x,'.')
    grid on
    subplot(2,1,2)
    hist([x' y' z'],-10:2:100);
    set(gca,'xlim',[-1, 100]);

    %plot gamma
    figure(33)
    subplot(3,1,1)
    x=gamma_all(gamma_all~=0);
    hist(x,0:0.02:1);
    
    subplot(3,1,2)
    x=Cad_RH_all;
    y=Cad_RH_ambient_all;
    z=gamma_all;
    ii=find(~isnan(x).*~isnan(y).*~isnan(z).*z~=0 ==1); %remove NaNs
    x=x(ii); y=y(ii);z=z(ii);
    f_Cad=((100-x)./(100-y)).^z;
    
    hist(f_Cad,0.9:0.02:8)    
    set(gca,'xlim',[.9, 2]);
    
    x=Neph_RH_all;
    y=Neph_RH_ambient_all;
    z=gamma_all;
    ii=find(~isnan(x).*~isnan(y).*~isnan(z).*z~=0 ==1); %remove NaNs
    x=x(ii); y=y(ii);z=z(ii);
    f_Neph=((100-x)./(100-y)).^z;  
  
    subplot(3,1,3)
    hist(f_Neph,0.9:0.02:8);
    set(gca,'xlim',[.9, 2]);
   
    %plot alpha histograms
    figure(34)
    subplot(2,1,1)
    x=alpha_aats_all;
    y=alpha_neph_all;
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    ii=find((x>=0 & x<=2.5).*(y>=0 & y<=2.5)==1); %remove outliers
    x=x(ii); y=y(ii);
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-1 3];
    plot(x,y,'.')
    grid on
    hold on
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('alpha AATS-14','FontSize',14)
    ylabel('alpha Neph+PSAP','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    %         set(gca,'xtick',[0:0.05:0.35]);
    %         set(gca,'ytick',[0:0.05:0.35]);

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
    text(3,2, sprintf('n= %i ',n),'FontSize',12)
    text(3,1.6, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(3,1.2, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(3,0.8, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(3,0.4, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(3,0.0, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(3,-0.4, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    subplot(2,1,2)
    hist([x y],[0:0.25:2.5])
    set(gca,'xlim',[-0.25, 2.75]);

    %Cadenza alpha
    figure(35)
    subplot(2,1,1)
    x=alpha_aatsNIR;
    y=alpha_Cad;
    ii=find(~isnan(x).*~isnan(y)==1); %remove NaNs
    x=x(ii); y=y(ii);
    ii=find((x>=-1 & x<=3).*(y>=-1 & y<=3)==1); %remove outliers
    x=x(ii); y=y(ii);
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    bias=mean(y-x);
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-1 3];
    plot(x,y,'.')
    grid on
    hold on
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('alpha AATS-14','FontSize',14)
    ylabel('alpha Cadenza','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    %         set(gca,'xtick',[0:0.05:0.35]);
    %         set(gca,'ytick',[0:0.05:0.35]);

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
    text(3,2, sprintf('n= %i ',n),'FontSize',12)
    text(3,1.6, sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(3,1.2, sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',12)
    text(3,0.8, sprintf('rms= %5.4f, %3.1f %%',rmsd, 100*rmsd/0.5/(mean(x)+mean(y))),'FontSize',12)
    text(3,0.4, sprintf('bias= %5.4f, %3.1f %%',bias, 100*bias/mean(x)),'FontSize',12)
    text(3,0.0, sprintf('mean x = %5.4f',mean(x)),'FontSize',12)
    text(3,-0.4, sprintf('mean y = %5.4f',mean(y)),'FontSize',12)

    subplot(2,1,2)
    hist([x' y'],[-1:0.25:3])
    set(gca,'xlim',[-2, 4]);

    %plot AATS-14 error
    %     ii=~isnan(AATS_AOD453_all); %find NaNs
    %     figure(32)
    %     subplot(2,1,1)
    %     hold on
    %     plot(AATS_AOD453_all,'b.')
    %     plot(AATS_AOD519_all,'g.')
    %     plot(AATS_AOD675_all,'r.')
    %     plot(AATS_AOD1558_all,'k.')
    %     grid on
    %     hold off
    %     subplot(2,1,2)
    %     hold on
    %     plot(AATS_AOD_Error453_all,'b.')
    %     plot(AATS_AOD_Error519_all,'g.')
    %     plot(AATS_AOD_Error675_all,'r.')
    %     plot(AATS_AOD_Error1558_all,'k.')
    %     grid on
    %     hold off
    %     mean(AATS_AOD_Error453_all(ii))
    %     mean(AATS_AOD_Error519_all(ii))
    %     mean(AATS_AOD_Error675_all(ii))
    %     mean(AATS_AOD_Error1558_all(ii))
    %
    %     figure(33)
    %     subplot(3,1,1)
    %     hold on
    %     plot(AATS_ext453_all,'b.')
    %     plot(AATS_ext519_all,'g.')
    %     plot(AATS_ext675_all,'r.')
    %     plot(AATS_ext1558_all,'k.')
    %     grid on
    %     hold off
    %     subplot(3,1,2)
    %     hold on
    %     plot(AATS_ext453_Error_all,'b.')
    %     plot(AATS_ext519_Error_all,'g.')
    %     plot(AATS_ext675_Error_all,'r.')
    %     plot(AATS_ext1558_Error_all,'k.')
    %     grid on
    %     hold off
    %     subplot(3,1,3)
    %     hold on
    %     plot(AATS_ext453_Error_all./AATS_ext453_all,'b.')
    %     plot(AATS_ext519_Error_all./AATS_ext519_all,'g.')
    %     plot(AATS_ext675_Error_all./AATS_ext675_all,'r.')
    %     plot(AATS_ext1558_Error_all./AATS_ext1558_all,'k.')
    %     grid on
    %     hold off
    %
    %     mean(AATS_ext453_all(ii))
    %     mean(AATS_ext519_all(ii))
    %     mean(AATS_ext675_all(ii))
    %     mean(AATS_ext1558_all(ii))
    %
    %     mean(AATS_ext453_Error_all(ii))
    %     mean(AATS_ext519_Error_all(ii))
    %     mean(AATS_ext675_Error_all(ii))
    %     mean(AATS_ext1558_Error_all(ii))

end