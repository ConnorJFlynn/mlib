%creates ARM IOP multiframe plots and statistics for H2O
clear all
close all

%product='h2o_profile' % H2O profile produced by h2o_profile_ave.m
product='aod_profile' % AOD profile produced by ext_profile_ave.m
Neph_PSAP='Yes'
Cadenza='Yes'

%empty arrays
H2O_dens_all=[];
H2O_dens_is_all=[];
GPS_Altitude_all=[];
Ext_AATS14_all=[];

%read all AATS-14 profile names in directory
if strcmp(product,'h2o_profile')
    pathname='c:\beat\data\Aerosol IOP\Results_v2.1\';
    direc=dir(fullfile(pathname,'CIR*pw.asc')); 
    [filelist{1:length(direc),1}] = deal(direc.name);
    filelist([1:3,5,6,11,16,19,29,30],:)=[]; %delete profiles where there are no extinction profiles
end
if strcmp(product,'aod_profile')
    pathname='c:\beat\data\Aerosol IOP\Results_v2.2\';
    direc=dir(fullfile(pathname,'CIR*p.asc')); 
    [filelist{1:length(direc),1}] = deal(direc.name);
   % filelist([10],:)=[]; %delete profile 10 so that we have exactly 5*5=25
end    
%read all Neph+PSAP profile names in directory
if strcmp(Neph_PSAP,'Yes')
    pathname2='c:\beat\data\Aerosol IOP\nephs_psap\';
    direc=dir(fullfile(pathname2,'*_psap.asc')); 
    [filelist2{1:length(direc),1}] = deal(direc.name);
    %filelist2([10],:)=[]; %delete profile 10 so that we have exactly 5*5=25
end
%read all Cadenza profile names in directory
if strcmp(Cadenza,'Yes')
    pathname3='c:\beat\data\Aerosol IOP\Cadenza\Final\';
    direc=dir(fullfile(pathname3,'*_cad.asc')); 
    [filelist3{1:length(direc),1}] = deal(direc.name);   
%    filelist3([10],:)=[]; %delete profile 10 so that we have exactly 5*5=25
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
        
        % plot spectral shape profile
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
    end
    if strcmp(Cadenza,'Yes')
        % read Cadenza files   
        fid=fopen(deblank([pathname3,char(filelist3(jprof,:))]));
        [data]=fscanf(fid,'%f %f %f %f',[4,inf]);
        fclose(fid);
        UT_Cadenza=data(1,:);
        Alt_Cadenza=data(2,:);
        Cad_Ext_675=data(3,:);
        Cad_Ext_1550=data(4,:);
        
        % plot Cadenza profiles
        figure(5)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(Cad_Ext_675,Alt_Cadenza,'r.',Cad_Ext_1550,Alt_Cadenza,'k.')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 0.3]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0 0.1 0.2 0.3]);
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
        
        %bin data in altitude
        [ResMat_675,NewMat_675]=binning([Alt_Cadenza',Cad_Ext_675'],0.020,0,6);
        [ResMat_1550,NewMat_1550]=binning([Alt_Cadenza',Cad_Ext_1550'],0.020,0,6);
        
        % Alt_Cadenza= ResMat_675(:,1);
        % Cad_Ext_675= ResMat_675(:,2);
        % Cad_Ext_1550=ResMat_1550(:,2);
        
        Alt_Cadenza= NewMat_675(:,1);
        Cad_Ext_675= NewMat_675(:,2);
        Cad_Ext_1550=NewMat_1550(:,2);
        
        figure(6)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(Cad_Ext_675,Alt_Cadenza,'r.',Cad_Ext_1550,Alt_Cadenza,'k.')
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
        plot(Cad_Ext_1550,Alt_Cadenza,'g.-',Extinction(12,:), GPS_Altitude,'m.-')
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
        [data]=fscanf(fid,'%f %f %f %f %f %f',[6,inf]);
        fclose(fid);
        UT_neph=data(1,:);
        Alt_neph=data(2,:);
        ext_453_neph=data(3,:);
        ext_519_neph=data(4,:);
        ext_675_neph=data(5,:);
        RH_ambient=data(6,:);
        
        % plot RH amb profiles
        figure(8)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(RH_ambient,Alt_neph,'b.-')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 100]);
        set(gca,'TickLength',[.03 .05]);
        %set(gca,'xtick',[0 0.1 0.2 0.3]);
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
        [ResMat_453,NewMat_453]=binning([Alt_neph',ext_453_neph'],0.020,0,6);
        [ResMat_519,NewMat_519]=binning([Alt_neph',ext_519_neph'],0.020,0,6);
        [ResMat_675,NewMat_675]=binning([Alt_neph',ext_675_neph'],0.020,0,6);
        [ResMat_RH, NewMat_RH ]=binning([Alt_neph',RH_ambient'  ],0.020,0,6);
        
        % Alt_neph= ResMat_453(:,1);
        % ext_453_neph=ResMat_453(:,2);
        % ext_519_neph=ResMat_519(:,2);
        % ext_675_neph=ResMat_675(:,2);
        
        Alt_neph=    NewMat_453(:,1);
        ext_453_neph=NewMat_453(:,2);
        ext_519_neph=NewMat_519(:,2);
        ext_675_neph=NewMat_675(:,2);
        RH_ambient=  NewMat_RH(:,2); 
        
        %calculate alpha
        clear alpha_neph
        for bin=1:length(Alt_neph)
            x=log([453,519,675]/1e3);
            y=log([ext_453_neph(bin),ext_519_neph(bin),ext_675_neph(bin)]);
            [p,S] = polyfit(x,y,1);
            %a0(bin)=p(2); 
            alpha_neph(bin)=-p(1);
        end
        %calculate alpha aats for neph wvl.
        clear alpha_aats
        for bin=1:length(GPS_Altitude)
            x=log(lambda([3,5,7]))'; 
            y=log([Extinction(3,bin),Extinction(5,bin),Extinction(7,bin)]);
            [p,S] = polyfit(x,y,1);
            %a0(bin)=p(2); 
            alpha_aats(bin)=-p(1);
        end
        
        %plot binned data
        % RH amb profiles
        figure(10)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(RH_ambient,Alt_neph,'b.-')
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
        plot(ext_453_neph,Alt_neph,'b.-',ext_519_neph,Alt_neph,'g.-',ext_675_neph,Alt_neph,'r.-')
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
        %overplot neph & aats extinction
        figure(12)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(ext_519_neph,Alt_neph,'c.-',Extinction(5,:), GPS_Altitude,'m.-')
        set(gca,'ylim',[0 6]);
        set(gca,'xlim',[0 0.3]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0 0.1 0.2 0.3]);
        set(gca,'ytick',[0:6]);
        titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
        titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
        text(.12,5.3,titlestr1,'FontSize',8);
        text(.12,4.8,titlestr2,'FontSize',8);
        
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
        
        %overplot Neph & Cadenza
        if strcmp(Cadenza,'Yes')
            figure(13)
            set(gcf,'Paperposition',[0.25 0.1 8 10]);
            subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
            plot(ext_675_neph,Alt_neph,'c.-',Extinction(7,:), GPS_Altitude,'m.-',Cad_Ext_675, Alt_Cadenza,'g.-')
            set(gca,'ylim',[0 6]);
            set(gca,'xlim',[0 0.2]);
            set(gca,'TickLength',[.03 .05]);
            set(gca,'xtick',[0:0.05:0.2]);
            set(gca,'ytick',[0:6]);
            titlestr1=sprintf('%02d/%02d/%4d\n',month,day,year);
            titlestr2=sprintf('%02d:%02d-%02d:%02d UT\n',hour_start,min_start,hour_end,min_end);
            text(.07,5.3,titlestr1,'FontSize',8);
            text(.07,4.8,titlestr2,'FontSize',8);
            
            %axis labels and titles
            if row==0 & col==0
                legend('Neph+PSAP','AATS-14','Cadenza')    
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
        %overplot Neph & AATS & Cadenza AOD
        
        AOD_675_neph=cumtrapz(Alt_neph,ext_675_neph);
        AOD_675_cad =cumtrapz(Alt_Cadenza,Cad_Ext_675);

        %find AOD at max Neph and Cadenza Alt
        AOD_neph_top=interp1(GPS_Altitude,AOD',max(Alt_neph),'linear','extrap');
        AOD_cad_top=interp1(GPS_Altitude,AOD',max(Alt_Cadenza),'linear','extrap');
      
        %calculate Neph and Cadenza AOD
        AOD_675_neph=-AOD_675_neph+max(AOD_675_neph)+AOD_neph_top(7); 
        AOD_675_cad =-AOD_675_cad +max(AOD_675_cad) +AOD_cad_top(7); 

        %find bottom AOD
        bot_Altitude_neph=max([min(GPS_Altitude),min(Alt_neph)]);
        bot_Altitude_cad =max([min(GPS_Altitude),min(Alt_Cadenza)]);
    
        AOD_675_neph_bot=interp1(Alt_neph,AOD_675_neph,bot_Altitude_neph);
        AOD_675_cad_bot =interp1(Alt_Cadenza,AOD_675_cad, bot_Altitude_cad );

        AOD_aats_neph_bot=interp1(GPS_Altitude,AOD',bot_Altitude_neph);
        AOD_aats_cad_bot =interp1(GPS_Altitude,AOD',bot_Altitude_cad);

        %calculate layer AODs
        AOD_675_neph_layer(jprof)=AOD_675_neph_bot-AOD_neph_top(7);
        AOD_675_cad_layer(jprof)=AOD_675_cad_bot-AOD_cad_top(7);
       
        AOD_675_aats_neph_layer(jprof)=AOD_aats_neph_bot(7)-AOD_neph_top(7);
        AOD_675_aats_cad_layer(jprof) =AOD_aats_cad_bot(7) -AOD_cad_top(7);
        
        %claculate error of layer AOD
        mean_AOD_675(jprof)=(AOD_aats_neph_bot(7)-AOD_neph_top(7))/2;
        rng(jprof) = DISTANCE(Latitude(1),Longitude(1),Latitude(end),Longitude(end));
        layer_depth(jprof)=max(GPS_Altitude)-bot_Altitude_neph;
        
        %overplot AODs
        figure(14)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(AOD_675_neph,Alt_neph,'c.-',AOD(7,:), GPS_Altitude,'m.',AOD_675_cad,Alt_Cadenza,'g.-')
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
        
        %plot alpha's
        ii=all(Extinction([3,5,7],:)>=0.002);   %don't plot if extinction is low
        jj=all([ext_453_neph,ext_519_neph,ext_675_neph]'>=0.002);
        
        figure(15)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.06+col*0.19 0.8-row*0.18 0.16 0.16])
        plot(alpha_neph(jj),Alt_neph(jj),'m.-',alpha_aats(ii), GPS_Altitude(ii),'c.')
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

%Overall comparisons
if strcmp(product,'h2o_profile')
    layer_H2O_AATS14_Error=0.005.*deg2km(rng).*mean_H2O;
    
    figure(3)
    y=layer_H2O_AATS14;
    x=layer_H2O_is;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    yerrorbar('linlin',0, 3, 0, 3, x, y,layer_H2O_AATS14_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0.0 3];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(0.22,1.8 ,sprintf('n= %i ',n),'FontSize',12)
    text(0.22,1.7,sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(0.22,1.6,sprintf('y = %5.3f x + %5.3f',p),'FontSize',12)
    text(0.22,1.5 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)),'FontSize',12)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('in-situ - Layer H_2O [g/cm^2]','FontSize',14)
    ylabel('AATS-14 - Layer H_2O [g/cm^2]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    
    figure(4)
    y=H2O_dens_all;
    x=H2O_dens_is_all;
    plot(x,y,'k.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 16];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(1,11 ,sprintf('n= %i ',n),'FontSize',12)
    text(1,10.5,sprintf('r^2 = %5.3f',r.^2),'FontSize',12)
    text(1,10,sprintf('y = %5.3f x + %5.3f',p),'FontSize',12)
    text(1,9.5 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)),'FontSize',12)
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    ylabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:2:16]);
    set(gca,'ytick',[0:2:16]);
    
    
    figure(5)
    y=H2O_dens_all(GPS_Altitude_all<3);
    x=H2O_dens_is_all(GPS_Altitude_all<3);
    plot(x,y,'k.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 16];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(1,11 ,sprintf('n= %i ',n))
    text(1,10.5,sprintf('r^2 = %5.3f',r.^2))
    text(1,10,sprintf('y = %5.3f x + %5.3f',p))
    text(1,9.5 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('in-situ - H_2O Density [g/m^3]','FontSize',14)
    ylabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
end
if strcmp(Neph_PSAP,'Yes')
    figure(16)
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
    
    text(0.02,0.28 ,sprintf('n= %i ',n),'FontSize',14)
    text(0.02,0.26,sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(0.02,0.24,sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(0.02,0.22 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)),'FontSize',14)
    
    [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    disp([m,b,rc,sm,sb,xc,yc,ct])
    %      [y_fit] = polyval([m,b],range);
    %      plot(range,y_fit,'c-')
    hold off
end
if strcmp(Cadenza,'Yes')
    figure(17)
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
    
    text(0.02,0.28 ,sprintf('n= %i ',n),'FontSize',14)
    text(0.02,0.26,sprintf('r^2 = %5.3f',r.^2),'FontSize',14)
    text(0.02,0.24,sprintf('y = %5.3f x + %5.3f',m,b),'FontSize',14)
    text(0.02,0.22 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)),'FontSize',14)
    
    [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    disp([m,b,rc,sm,sb,xc,yc,ct])
    %      [y_fit] = polyval([m,b],range);
    %      plot(range,y_fit,'c-')
    hold off
end