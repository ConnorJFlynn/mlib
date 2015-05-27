% Program to plot location of all AATS-6 and AATS-14 profiles in ACE-Asia

figure(100)
worldmap([22,45],[120,145],'patch')

pathname='c:\beat\data\ACE-Asia\results\';
direc=dir(fullfile(pathname,'RF*p.asc')); 
[filelist{1:length(direc),1}] = deal(direc.name);

for i=1:length(filelist)
    disp(sprintf('Processing %s (No. %i of %i)',char(filelist(i,:)),i,length(filelist)))
    fid=fopen(deblank([pathname,char(filelist(i,:))]));
    for i=1:8
        fgetl(fid);
    end
    lambda=fscanf(fid,'aerosol wavelengths [10^-9 m]%g%g%g%g');
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    fgetl(fid);
    data=fscanf(fid,'%g',[20,inf]);
    fclose(fid);
    UT=data(1,:);
    Latitude=data(2,:);
    Longitude=data(3,:);
    GPS_Altitude=data(4,:);
    AOD=data(5:8,:);
    AOD_Error=data(9:12,:);
    alpha=-data(13,:);
    a0=data(14,:);
    Extinction=data(15:18,:);
    alpha_ext=-data(19,:);
    a0_ext=data(20,:);
    
    mean_lat=mean(Latitude);
    mean_long=mean(Longitude);
    
    plotm(mean(Latitude),mean(Longitude), 'ob', 'MarkerSize',6)%,'MarkerFaceColor','b')
    hold on
end  

scaleruler on
set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
hidem(gca)
hold on




