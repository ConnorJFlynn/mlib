%creates ARM IOP statistics for H2O from the Raman Lidar files that Rich
%provided

clear all
close all

Altitude_all=[];
H2O_CARL_all=[];
H2O_AATS14_all=[];
H2O_Otter_all=[];


%read all CARL profile names in directory
pathname='c:\beat\data\Aerosol IOP\CARL H2O\';
direc=dir(fullfile(pathname,'*.wv')); 
[filelist{1:length(direc),1}] = deal(direc.name);

nprofiles=length(filelist);

for jprof=1:nprofiles
    
    filename=char(filelist(jprof,:));
    disp(sprintf('Processing %s (No. %i of %i)',filename,jprof,nprofiles))
    
    %reads in CARL aerosol data
    fid=fopen([pathname filename]);
    
    for i=1:6,
        fgetl(fid);
    end
    % Altitude (km, ASL), CARL, AATS-14, AATS-14 insitu, IAP
    data=fscanf(fid,'%g,%g,%g,%g,%g',[5,inf]);
    fclose(fid);
    Altitude=data(1,:);   
    H2O_CARL=data(2,:);
    H2O_AATS14=data(3,:);
    H2O_Otter=data(4,:);
    H2O_IAP=data(5,:);
    
    Altitude_all=[Altitude_all Altitude];
    H2O_CARL_all=[H2O_CARL_all H2O_CARL];
    H2O_AATS14_all=[H2O_AATS14_all H2O_AATS14];
    H2O_Otter_all=[H2O_Otter_all H2O_Otter];
    
    % layer_H2O_is(jprof)=trapz(GPS_Altitude,H2O_dens_is)/10;
    % layer_H2O_AATS14(jprof)=H2O(1)-H2O(end);   
    
end


    figure(1)
    x=H2O_Otter_all;
    y=H2O_AATS14_all;
    z=Altitude_all;
    
    xi = x~=-999.00;
    yi = y~=-999.00;
    zi = z<=inf;
    
    ii=xi.*yi.*zi;
    
    x=x(ii==1);
    y=y(ii==1);
    z=z(ii==1);
    
    plot(x,y,'k.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.5 16];
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
    
    figure(2)
    x=H2O_Otter_all;
    y=H2O_AATS14_all;
    z=Altitude_all;
    
    xi = x~=-999.00;
    yi = y~=-999.00;
    zi = z<=3;
    
    ii=xi.*yi.*zi;
    
    x=x(ii==1);
    y=y(ii==1);
    z=z(ii==1);
    
    plot(x,y,'k.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.5 16];
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

    figure(3)
    x=H2O_Otter_all;
    y=H2O_CARL_all;
    z=Altitude_all;
    
    xi = x~=-999.00;
    yi = y>=0;
    zi = z<=3;
    
    ii=xi.*yi.*zi;
    
    x=x(ii==1);
    y=y(ii==1);
    z=z(ii==1);
    
    plot(x,y,'k.')
    hold on
    n=length(x);
    rmsd=(sum((x-y).^2)/(n-1))^0.5;
    r=corrcoef(x,y);
    r=r(1,2);
    range=[-0.5 16];
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
    ylabel('Raman Lidar - H_2O Density [g/m^3]','FontSize',14)
    axis square
    set(gca,'FontSize',14)