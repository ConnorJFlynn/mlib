%creates ACE-Asia multiframe plots
clear all
close all

Hegg='Yes'
Paper='No'% 16 profiles for paper only
product='aod_profile' % AOD profile produced by ext_profile_ave.m
%product='h2o_profile' % H2O profile produced by h2o_profile_ave.m

%empty arrays
h2o_EdgeTech_all=[];
h2o_Vaisala_all =[];    
H2O_dens_all=[];
H2O_dens_is_all=[];
Ext_Hegg_Error_all=[];
Extinction_Error_all=[];
Ext_AATS14_all=[];
Ext_Hegg_all  =[];

%read all AATS-14 profile names in directory
%pathname='c:\beat\data\ACE-Asia\results\';
pathname='c:\beat\data\ACE-Asia\results\ver3\';
if strcmp(product,'aod_profile')
    direc=dir(fullfile(pathname,'CIR*p.asc')); 
end
if strcmp(product,'h2o_profile')
    direc=dir(fullfile(pathname,'CIR*pw.asc')); 
end
[filelist{1:length(direc),1}] = deal(direc.name);

if strcmp(Hegg,'Yes')
    %read all Hegg profile names in directory
    pathname2='c:\beat\data\ACE-Asia\Hegg\';
    direc=dir(fullfile(pathname2,'*.dat')); 
    [filelist2{1:length(direc),1}] = deal(direc.name);
    Ext_Error_Hegg=[8.9 16.0 16.1 9.8 13.3 3 10.6 17.4 17.1 13.6 6.2 5.9 8.6 8.6]/1e3; %Errors independent of Altitude for all 14 profiles
    
    %use only AATS-14 that have Hegg data.
    filelist([1 2 3 4 7 10 11 13 18 21 23 26],:)=[];
end

if strcmp(Paper,'Yes')
    filelist([1 2 3 7 10 11 13 18 21 26],:)=[];
end
    

nprofiles_proc_ext=length(filelist);

%for jprof=1:26
for jprof=1:nprofiles_proc_ext
     
    filename=char(filelist(jprof,:));
    disp(sprintf('Processing %s (No. %i of %i)',filename,jprof,nprofiles_proc_ext))
    
    %determine date and flight number from filename
    flt_no=filename(1:5); 
    
    % read AATS-14 profile
    fid=fopen(deblank([pathname,filename]));
    fgetl(fid);
    file_date=fscanf(fid,'ACE-Asia%g/%g/%g');     %get date
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
        
        H2O_dens_all=[H2O_dens_all H2O_dens];
        H2O_dens_is_all=[H2O_dens_is_all H2O_dens_is];
        
        layer_H2O_is(jprof)=trapz(GPS_Altitude,H2O_dens_is)/10;
        layer_H2O_AATS14(jprof)=H2O(1)-H2O(end);   
        mean_H2O(jprof)=(H2O(1)+H2O(2))/2;
        rng(jprof) = DISTANCE(Latitude(1),Longitude(1),Latitude(end),Longitude(end));
        
        %read in in-situ files
        [UT_TO,GPS_Alt_TO,h2o_EdgeTech,h2o_Vaisala]=read_Td_Asia(flt_no);
        if flt_no=='CIR07'
            UT_TO=UT_TO+24;
        end
        ii=interp1(UT_TO,1:length(UT_TO),UT,'nearest');
        h2o_EdgeTech=h2o_EdgeTech(ii)';
        h2o_Vaisala=h2o_Vaisala(ii)';
        GPS_Alt_TO=GPS_Alt_TO(ii)';
        
        layer_h2o_EdgeTech(jprof)=trapz(GPS_Alt_TO,h2o_EdgeTech)/10;
        layer_h2o_Vaisala(jprof)=trapz(GPS_Alt_TO,h2o_Vaisala)/10;

        h2o_EdgeTech_all=[h2o_EdgeTech_all h2o_EdgeTech];
        h2o_Vaisala_all =[h2o_Vaisala_all  h2o_Vaisala ];
        
        
    end
    if strcmp(product,'aod_profile')
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
                Extinction_Error=AOD_Error.*0;
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
        
        x=log(0.550); % 550 nm is Hegg's wavelength
        AOD_fit=exp(-gamma*x^2-alpha*x+a0);
        Ext_fit=exp(-gamma_ext*x^2-alpha_ext*x+a0_ext);
        ii_ext=find(a0_ext~=0);
        
    end    
    
    UT_start=min(UT);
    UT_end=max(UT);
    
    if UT_start > 24 
        UT_start=UT_start-24;
        UT_end=UT_end-24;
        day=day+1;
    end        
    
    col=mod(jprof-1,4);
    %row=fix((jprof-1)/4);
    row=mod(fix((jprof-1)/4),4);
    
    if strcmp(product,'h2o_profile')
        % plot H2O profile
        figure(1)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(H2O,GPS_Altitude,'.')
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[0 1.5]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0:0.3:1.5]);
        hour_start=floor(UT_start);
        hour_end=floor(UT_end);
        min_start=round((UT_start-floor(UT_start))*60);
        min_end=round((UT_end-floor(UT_end))*60);
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(0.08,3.5,titlestr);
        set(h1,'FontSize',8)
        
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
            h22=text(0.2,-1.2,'AATS-14 Columnar Water Vapor [g/m^2]');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.5,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        
        % plot H2O density
        figure(2)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(h2o_EdgeTech,GPS_Altitude,'c.-',h2o_Vaisala,GPS_Altitude,'m.-',H2O_dens,GPS_Altitude,'g.-')
        %hold on
        %xerrorbar('linlin',-inf, inf, -inf, inf, H2O_dens, GPS_Altitude, H2O_dens_err,'.')
        %hold off
        
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[0 12]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0:2:12]);
        
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(0.7,3.5,titlestr);
        set(h1,'FontSize',8)
        
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
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
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(AOD,GPS_Altitude,'.')
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[0 0.8]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',[0 0.2 0.4 0.6 0.8]);
        hour_start=floor(UT_start);
        hour_end=floor(UT_end);
        min_start=round((UT_start-floor(UT_start))*60);
        min_end=round((UT_end-floor(UT_end))*60);
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(0.08,3.6,titlestr);
        set(h1,'FontSize',8)
        
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
            h22=text(0.2,-1.2,'AATS-14 Aerosol Optical Depth');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.2,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
       
        % plot extinction profile
        figure(2)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(Extinction,GPS_Altitude,'.-')
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[0 0.5]);
        set(gca,'TickLength',[.03 .03]);
        set(gca,'xtick',[0 0.1 0.2 0.3 0.4 0.5]);
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(0.04,3.6,titlestr);
        set(h1,'FontSize',8)
        
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
            h22=text(0.2,-1.2,'AATS-14 Extinction [km^-^1]');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.15,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        
        % plot spectral shape profile
        figure(3)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(alpha,GPS_Altitude,'c.',gamma,GPS_Altitude,'m.')
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[-.5 1.5]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[-.5 0 .5 1 1.5]);
        
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(-0.4,3.6,titlestr);
        set(h1,'FontSize',8)
        
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
            h22=text(-0.5,-1.2,'Aerosol Optical Depth Spectral Parameters');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-1,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        
        %plot spectral shape profile
        figure(4)
        
        %don't plot if extinction is low
        ii=all(Extinction(1:12,:)>=0.003);
        
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(alpha_ext(ii),GPS_Altitude(ii),'c.',gamma_ext(ii),GPS_Altitude(ii),'m.')
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[-1 3]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[-1 0 1 2 3]);
        
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(-0.8,3.6,titlestr);
        set(h1,'FontSize',8)
        
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
            h22=text(0.5,-1.2,'AATS-14 Extinction shape');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-2,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        
    end
    if strcmp(Hegg,'Yes')
        % read Hegg profiles
        fid=fopen(deblank([pathname2,char(filelist2(jprof,:))]));
        [data]=fscanf(fid,'%g %g',[2,inf]);
        Alt_Hegg=data(1,:)/1000;
        Ext_Hegg=data(2,:)/1000;
        fclose(fid);
        % plot Hegg profile
        figure(5)
        set(gcf,'Paperposition',[0.25 0.1 8 10]);
        subplot('position',[0.13+col*0.21 0.75-row*0.21 0.18 0.19])
        plot(Ext_Hegg,Alt_Hegg,'b.-',Ext_fit(ii_ext),GPS_Altitude(ii_ext),'g.-')
        set(gca,'ylim',[0 4]);
        set(gca,'xlim',[0 0.3]);
        set(gca,'TickLength',[.03 .05]);
        set(gca,'xtick',[0 0.1 0.2 0.3]);
        hour_start=floor(UT_start);
        hour_end=floor(UT_end);
        min_start=round((UT_start-floor(UT_start))*60);
        min_end=round((UT_end-floor(UT_end))*60);
        titlestr=sprintf('%2d/%2d/%2d %2d:%02d-%2d:%02d UT\n',month,day,year,hour_start,min_start,hour_end,min_end);
        h1=text(0.03,3.5,titlestr);
        set(h1,'FontSize',8)
         
        %axis labels and titles
        if col>=1 set(gca,'YTickLabel',[]); end
        if row<3 set(gca,'XTickLabel',[]); end
        if row==3 & col==1
            h22=text(0.2,-1.2,'Extinction [km^-^1]');
            set(h22,'FontSize',12)
        end
        if col==0 & row==2
            h33=text(-0.05,3,'Altitude [km]');
            set(h33,'FontSize',12,'Rotation',90)
        end
        
        %prepare data for scatter plots
        Latitude=Latitude(ii_ext);
        Longitude=Longitude(ii_ext);
        Ext_Altitude=GPS_Altitude(ii_ext);
        Ext_fit     =Ext_fit(ii_ext);
        Extinction_Error=Extinction_Error(:,ii_ext);
        
        % consider only altitudes where both profiles have data
        Ext_int=interp1(Ext_Altitude, Ext_fit ,Alt_Hegg,'linear');
        ii=~isnan(Ext_int);
        Alt_Hegg=Alt_Hegg(ii);
        Ext_int=Ext_int(ii);
        Ext_Hegg=Ext_Hegg(ii);
        
        Ext_Hegg_Error=Ext_Error_Hegg(jprof)*(ones(1,length(Alt_Hegg)));
        Ext_Hegg_Error_all=[Ext_Hegg_Error_all Ext_Hegg_Error];
        
        ii= interp1(Ext_Altitude,1:length(Ext_Altitude),Alt_Hegg,'nearest');
        Latitude=Latitude(ii);
        Longitude=Longitude(ii);
        AOD_fit=AOD_fit(ii);
        Extinction_Error=Extinction_Error(:,ii);
        
        Extinction_Error_all=[Extinction_Error_all Extinction_Error];
        
        mean_AOD_fit(jprof)=(AOD_fit(1)+AOD_fit(end))/2;
        
        rng(jprof) = DISTANCE(Latitude(1),Longitude(1),Latitude(end),Longitude(end));
        
        layer_depth(jprof)=max(Alt_Hegg)-min(Alt_Hegg);
        
        layer_AOD_AATS14(jprof)=AOD_fit(1)-AOD_fit(end);   
        layer_AOD_AATS14_2(jprof)=trapz(Alt_Hegg,Ext_int);   
        layer_AOD_Hegg(jprof)=trapz(Alt_Hegg,Ext_Hegg); 
                
        Ext_AATS14_all=[Ext_AATS14_all Ext_int];
        Ext_Hegg_all  =[Ext_Hegg_all   Ext_Hegg];
    end
    
end  

if strcmp(Hegg,'Yes')
    layer_AOD_Hegg_Error=Ext_Error_Hegg.*layer_depth;
    layer_AOD_AATS14_Error=0.005.*deg2km(rng).*mean_AOD_fit;
    layer_AOD_AATS14   
    layer_AOD_AATS14_2  
    
%     figure(6)
%     x=layer_AOD_AATS14;
%     y=layer_AOD_Hegg;
%     plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
%     hold on
%     xerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_AATS14_Error,'k.')
%     yerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_Hegg_Error,'k.')
%     n=length(x);
%     rmsd=(sum((x-y).^2)/(n-1))^0.5;
%     r=corrcoef(x,y);
%     r=r(1,2);
%     range=[0 0.5];
%     [p,S] = polyfit (x,y,1);
%     [y_fit,delta] = polyval(p,range,S);
%     plot(range,y_fit,'k--',range,range,'k')
%     text(0.02,0.48 ,sprintf('n= %i ',n))
%     text(0.02,0.46,sprintf('r^2 = %5.3f',r.^2))
%     text(0.02,0.44,sprintf('y = %5.3f x + %5.3f',p))
%     text(0.02,0.42 ,sprintf('rms= %5.3f, %3.1f %%',rmsd))
%     hold off
%     set(gca,'ylim',[0 0.5]);
%     set(gca,'xlim',[0 0.5]);
%     xlabel('Layer AOD: AATS-14','FontSize',14)
%     ylabel('Layer AOD: in-situ','FontSize',14)
%     axis square
%     set(gca,'FontSize',14)
%     set(gca,'xtick',[0:0.1:0.5]);
%     set(gca,'ytick',[0:0.1:0.5]);
 
    
    
    figure(7)
    x=layer_AOD_AATS14_2;
    y=layer_AOD_Hegg;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    xerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_AATS14_Error,'k.')
    yerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_Hegg_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.5];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(0.02,0.48 ,sprintf('n= %i ',n))
    text(0.02,0.46,sprintf('r^2 = %5.3f',r.^2))
    text(0.02,0.44,sprintf('y = %5.3f x + %5.3f',p))
    text(0.02,0.42 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))
   
    set(gca,'ylim',[0 0.5]);
    set(gca,'xlim',[0 0.5]);
    xlabel('Layer AOD: AATS-14','FontSize',14)
    ylabel('Layer AOD: in-situ','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.1:0.5]);
    set(gca,'ytick',[0:0.1:0.5]);
 
    %use new Matlab scripts by Edward T. Peltzer
    sX=layer_AOD_AATS14_Error;
    sY=layer_AOD_Hegg_Error;

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
    
    [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-6);
    disp([m,b,rc,sm,sb,xc,yc,ct])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'c-')
    hold off
    
    figure(8)
    x=Ext_AATS14_all;
    y=Ext_Hegg_all;
    plot(x,y,'k.')
    hold on
    %xerrorbar('linlin',0, .3, 0, .3, x, y, Extinction_Error_all(5,:),'k.')
    %yerrorbar('linlin',0, .3, 0, .3, x, y, Ext_Hegg_Error_all,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 0.3];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(0.02,0.29 ,sprintf('n= %i ',n))
    text(0.02,0.28,sprintf('r^2 = %5.3f',r.^2))
    text(0.02,0.27,sprintf('y = %5.3f x + %5.3f',p))
    text(0.02,0.26 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Extinction [km^-^1]: AATS-14','FontSize',14)
    ylabel('Extinction [km^-^1]: in-situ','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:0.05:0.3]);
    set(gca,'ytick',[0:0.05:0.3]);
 
    %use new Matlab scripts by Edward T. Peltzer
    sX=Extinction_Error_all(5,:);
    sY=Ext_Hegg_Error_all;
    
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
    
    % weighted model 1
    [mw,bw,rw,smw,sbw,xw,yw]=lsqfityw(x,y,sY);
    disp([mw,bw,rw,smw,sbw,xw,yw])
        
    % wigthed model 1 (errors from York (1966)
    [mz,bz,rz,smz,sbz,xz,yz] = lsqfityz(x,y,sY);
    disp([mz,bz,rz,smz,sbz,xz,yz]) 
    
    %model 2 major axis or first PC
    [m,b,r,sm,sb]=lsqfitma(x,y);
    disp([m,b,r,sm,sb])
    
    % geometric mean, reduce major axis or standard major axis
    [m,b,r,sm,sb] = lsqfitgm(x,y);
    disp([m,b,r,sm,sb])
     
    % least squares bisector
    [m,b,r,sm,sb]=lsqbisec(x,y);
    disp([m,b,r,sm,sb])
    [y_fit] = polyval([m,b],range);
    plot(range,y_fit,'r-')

    
    
%     %leas-squares cubic
%     [m,b,rc,sm,sb,xc,yc,ct]=lsqcubic(x,y,sX,sY,1e-4);
%     disp([m,b,rc,sm,sb,xc,yc,ct])
%     [y_fit] = polyval([m,b],range);
%     plot(range,y_fit,'c-')
%     hold off
    
end

if strcmp(product,'h2o_profile')
    layer_H2O_AATS14_Error=0.0056.*deg2km(rng).*mean_H2O;

    figure(3)
    y=layer_H2O_AATS14;
    x=layer_H2O_is;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    yerrorbar('linlin',0, 1.6, 0, 1.6, x, y,layer_H2O_AATS14_Error,'k.')
    %yerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_Hegg_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0.2 1.6];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(0.22,1.56 ,sprintf('n= %i ',n))
    text(0.22,1.52,sprintf('r^2 = %5.3f',r.^2))
    text(0.22,1.48,sprintf('y = %5.3f x + %5.3f',p))
    text(0.22,1.44 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('in-situ - Layer H_2O [g/cm^2]','FontSize',14)
    ylabel('AATS-14 - Layer H_2O [g/cm^2]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0.2:0.2:1.6]);
    set(gca,'ytick',[0.4:0.2:1.6]);
    
    figure(4)
    y=H2O_dens_all;
    x=H2O_dens_is_all;
    plot(x,y,'k.')
    hold on
    %xerrorbar('linlin',0, 12, 0, 12, x, y, Extinction_Error_all(5,:),'k.')
    %yerrorbar('linlin',0, 12, 0, 12, x, y, Ext_Hegg_Error_all,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 12];
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
    set(gca,'xtick',[0:1:12]);
    set(gca,'ytick',[0:1:12]);
    
    figure(5)
    y=layer_H2O_AATS14;
    x=layer_h2o_EdgeTech;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    yerrorbar('linlin',0, 1.6, 0, 1.6, x, y,layer_H2O_AATS14_Error,'k.')
    %yerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_Hegg_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0.2 1.6];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(0.22,1.56 ,sprintf('n= %i ',n))
    text(0.22,1.52,sprintf('r^2 = %5.3f',r.^2))
    text(0.22,1.48,sprintf('y = %5.3f x + %5.3f',p))
    text(0.22,1.44 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('EdgeTech 137-C3 - Layer H_2O [g/cm^2]','FontSize',14)
    ylabel('AATS-14 - Layer H_2O [g/cm^2]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0.2:0.2:1.6]);
    set(gca,'ytick',[0.4:0.2:1.6]);
    
    figure(6)
    y=H2O_dens_all;
    x=h2o_EdgeTech_all;
    plot(x,y,'k.')
    hold on
    %xerrorbar('linlin',0, 12, 0, 12, x, y, Extinction_Error_all(5,:),'k.')
    %yerrorbar('linlin',0, 12, 0, 12, x, y, Ext_Hegg_Error_all,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 12];
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
    xlabel('EdgeTech 137-C3 - H_2O Density [g/m^3]','FontSize',14)
    ylabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:1:12]);
    set(gca,'ytick',[0:1:12]);
    
    figure(7)
    y=layer_H2O_AATS14;
    x=layer_h2o_Vaisala;
    plot(x,y,'ko','MarkerFaceColor','k','MarkerSize',7)
    hold on
    yerrorbar('linlin',0, 1.6, 0, 1.6, x, y,layer_H2O_AATS14_Error,'k.')
    %yerrorbar('linlin',0, .5, 0, .5, x, y,layer_AOD_Hegg_Error,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0.2 1.6];
    [p,S] = polyfit (x,y,1);
    [y_fit,delta] = polyval(p,range,S);
    plot(range,y_fit,'k--',range,range,'k')
    text(0.22,1.56 ,sprintf('n= %i ',n))
    text(0.22,1.52,sprintf('r^2 = %5.3f',r.^2))
    text(0.22,1.48,sprintf('y = %5.3f x + %5.3f',p))
    text(0.22,1.44 ,sprintf('rms= %5.3f, %3.1f %%',rmsd, 100*rmsd/mean(x)))
    hold off
    set(gca,'ylim',range);
    set(gca,'xlim',range);
    xlabel('Vaisala HMP 243 - Layer H_2O [g/cm^2]','FontSize',14)
    ylabel('AATS-14 - Layer H_2O [g/cm^2]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0.2:0.2:1.6]);
    set(gca,'ytick',[0.4:0.2:1.6]);
    
    figure(8)
    y=H2O_dens_all;
    x=h2o_Vaisala_all;
    plot(x,y,'k.')
    hold on
    %xerrorbar('linlin',0, 12, 0, 12, x, y, Extinction_Error_all(5,:),'k.')
    %yerrorbar('linlin',0, 12, 0, 12, x, y, Ext_Hegg_Error_all,'k.')
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[0 12];
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
    xlabel('Vaisala HMP 243 - H_2O Density [g/m^3]','FontSize',14)
    ylabel('AATS-14 - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)
    set(gca,'xtick',[0:1:12]);
    set(gca,'ytick',[0:1:12]);
end