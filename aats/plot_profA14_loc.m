% Program to plot location of all AATS-14 profiles in ACE-Asia

figure(100)
worldmap([30,40],[125,140],'patch')
%pathname='c:\beat\data\ACE-Asia\results\ver3\';
pathname='c:\beat\data\ACE-Asia\results\';
direc=dir(fullfile(pathname,'CIR*p.asc')); 
[filelist{1:length(direc),1}] = deal(direc.name);

for i=1:length(filelist)
    disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    
    for i=1:12
        fgetl(fid);
    end
    lambda=fscanf(fid,'aerosol wavelengths [10^-6 m]%g%g%g%g%g%g%g%g%g%g%g%g%g');
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
        
    mean_lat=mean(Latitude);
    mean_long=mean(Longitude);
    
    plotm(mean(Latitude),mean(Longitude), 'or', 'MarkerSize',6)%,'MarkerFaceColor','r')
    hold on
end  
scaleruler on
set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
hidem(gca)
hold off
orient landscape