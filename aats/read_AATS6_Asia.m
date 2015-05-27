%This function reads 20 parameter from AATS-6
%function [UT,GLON,GLAT,GALT,PSFDC,ATX,PALT]=read_AATS6_Asia;
close all
clear all

UT_start =7.085  
UT_end =7.1   
data_dir='c:\beat\data\ACE-Asia\results\'
plot_loc_map='ON'
Cimel='yes'
Kosan_METRI='yes'

lambda_Cimel=[1020 870	670 500 440 380 340]/1e3;
lambda=[0.3801  0.4509  0.5257  1.0213];


[filename,path]=uigetfile([data_dir 'RF*.asc'],'Choose a File',0, 0);

fid=fopen([path filename]);
fgetl(fid);
site=fscanf(fid,'%25c',[1 1]);
for i=1:15
    fgetl(fid);
end   
data=fscanf(fid,'%f',[17,inf]);
fclose(fid);

UT=data(1,:);
GPS_Alt=data(4,:);
AOD_flag=data(8,:);

index = find(UT>=UT_start & UT<=UT_end);
UT=UT(index);

Latitude=data(2,index);
Longitude=data(3,index);
GPS_Alt=data(4,index);
Pressure=data(5,index);
H2O=data(6,index);
H2O_Error=data(7,index);
AOD_flag=data(8,index);
alpha_Angstrom=data(9,index);
AOD=data(10:13,index);
AOD_err=data(14:17,index);

%compute shape coeff. for AOD spectra
a0=[]; 
alpha=[];
gamma=[];
degree=1;
for i=1:length(index);
    x=log(lambda);
    y=log(AOD(:,i));
    if ~isempty(x)
        [p,S] = polyfit(x',y,degree);
        switch degree
        case 1
            a0(i)=p(2); 
            alpha(i)=-p(1);
            gamma(i)=0;
        case 2  
            a0(i)=p(3); 
            alpha(i)=-p(2);
            gamma(i)=-p(1); 
        end
    else
        a0(i)=-99.9999;
        alpha(i)=99.9999;
        gamma(i)=99.9999;
    end    
end

figure(1)
%AOD movie
ind=find(AOD_flag==1);
lambda_fit=[0.325:0.025:1.1];
j=1;
for i=ind
    loglog(lambda,AOD(:,i),'mo');
    hold on
    yerrorbar('loglog',0.3,1.1, 0.001, 3,lambda,AOD(:,i),AOD_err(:,i),AOD_err(:,i),'mo')
    AOD_fit(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_fit)));
    AOD_fit_Cimel(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_Cimel)));
%     AOD_fit_MISR(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_MISR)));
%     AOD_fit_MODIS(j,:)=exp(polyval([-gamma(i),-alpha(i),a0(i)],log(lambda_MODIS)));
    loglog(lambda_fit,AOD_fit(j,:));
    hold off
    set(gca,'xlim',[.300 1.60]);
    set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
    set(gca,'ylim',[0.001 1]);
    %title(title1);
    xlabel('Wavelength [microns]');
    ylabel('Optical Depth')
    pause (0.01)
    j=j+1;
end


figure(1)
orient landscape

subplot(6,1,1)
plot(UT,GPS_Alt,'.')
title(sprintf('%s %g-%g',site,UT_start,UT_end));
xx=get(gca,'xlim');
axis([xx 0 inf])
ylabel('Altitude (km)')
legend('GPS alt')
grid on

subplot(6,1,2)
plot(UT,Latitude,'.')
axis([xx -inf inf])
ylabel('Latitude (°)')
grid on

subplot(6,1,3)
plot(UT,Longitude,'.')
ylabel('Longitude (°)')
axis([xx -inf inf])
grid on

subplot(6,1,4)
plot(UT(AOD_flag==1),AOD(:,AOD_flag==1),'.')
grid on
ylabel('AOD');
legend('380.1','450.7','525.3','1020.7'	)
axis([xx -inf inf])

subplot(6,1,5)
plot(UT(AOD_flag==1),alpha_Angstrom(:,AOD_flag==1),'.')
grid on
ylabel('Alpha');
axis([xx -inf inf])

subplot(6,1,6)
plot(UT,H2O,'.')
grid on
ylabel('H2O(cm)');
xlabel('UT');
axis([xx -inf inf])


if strcmp(plot_loc_map,'ON')
    
    edge = 0.5;
    
    figure(2)
    worldmap([min(Latitude)-edge,max(Latitude)+edge],[min(Longitude)-edge,...
            max(Longitude)+edge],'patch')
    plotm(Latitude,Longitude,'LineWidth',2)
    hold on
    plotm(Latitude(AOD_flag==1),Longitude(AOD_flag==1),'m.','MarkerSize',8)
    if size(Longitude(AOD_flag==1 & GPS_Alt<0.08))~=0
        plotm(Latitude(AOD_flag==1 & GPS_Alt<0.08),Longitude(AOD_flag==1&GPS_Alt<0.08),'g.','MarkerSize',6)
    end
    jj=ceil(min(UT))
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
    set(handlem('allpatch'),'Facecolor',[0.7 0.7 0.4])
    setm(gca,'FFaceColor',[ 0.83 0.92 1.00 ])
    
    hidem(gca)
    
    
    plotm(33.283,126.167,'ms','MarkerSize',8,'MarkerFaceColor','m')   %Cheju, Kosan AERONET site
    plotm(35.62,135.07,'ms','MarkerSize',8,'MarkerFaceColor','m')   %Hoeller sunphotometer 35.62N, 135.07E
    plotm(34.1439,132.236,'k^','MarkerSize',8,'MarkerFaceColor','k')  %Iwakuni, ops. center
    plotm(35.66,139.80,'rs','MarkerSize',8,'MarkerFaceColor','r')   %TUMM lidar, Tokyo
    plotm(36.05,140.12,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Continuous observation at Tsukuba(36.05N,140.12E), 
    plotm(32.78,129.86,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Nagasaki(32.78N,129.86E)
    plotm(39.9,116.3,'rs','MarkerSize',8,'MarkerFaceColor','r')     %lidar Beijing(39.9N,116.3E)
    plotm(35.58,140.10,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar CEReS, Chiba University, Inage, Chiba (35.58N, 140.10E)
    plotm(35.1,137.0,'rs','MarkerSize',8,'MarkerFaceColor','r')     %lidar Nagoya, 35.1N, 137.0E
    plotm(34.47,133.23,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Fukuyama University, 133.23E / 34.47N
    plotm(28.44,129.70,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Amami 28.44N, 129.70E
    plotm(33.283,126.167,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar SNU Kosan, Korea (37.28N, 126.17E, ASL50m)???
    plotm(37.14,127.04,'rs','MarkerSize',8,'MarkerFaceColor','r')   %lidar Suwon, Korea(37.14N, 127.04E)
end


figure(3)
AOD_max=max(AOD(:,AOD_flag==1)');
AOD_min=min(AOD(:,AOD_flag==1)');
AOD_std=std(AOD(:,AOD_flag==1)');
AOD_mean=mean(AOD(:,AOD_flag==1)');
AOD_err=mean(AOD_err(:,AOD_flag==1)');
AOD_fit_mean=mean(AOD_fit);
loglog(lambda,AOD_mean,'ko','MarkerSize',8,'MarkerFaceColor','k');
set(gca,'ylim',[0.1 1]);
set(gca,'xlim',[.30 1.1]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1]);
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Aerosol Optical Depth','FontSize',14);
set(gca,'FontSize',14)
grid on


if strcmp(Cimel,'yes')
    hold on
     AOD_Cimel=[0.217202,0.235215,0.260254,0.314626,0.350036,0.393807,0.426862]; %  12:04:2001,07:06:06, Kosan, Cheju Island Korea, 0.295914,0.791553,1.691512 
    %AOD_Cimel=[0.231466,0.250678,0.271270,0.316415,0.356493,0.392153,0.418716]; %  12:04:2001,02:07:25, Kosan  Cheju Island Korea  0.088484,0.620013,1.176872 Level 2.0
    %AOD_Cimel=[0.231268,0.250461,0.271004,0.316037,0.356020,0.391462,0.417784]; %  12:04:2001,02:07:25, Kosan  Cheju Island Korea  Level 1.0
    %AOD_Cimel=[0.275705,0.297189,0.323147,0.377067,0.418103,0.462923,0.494672]; %  12:04:2001,01:45:02  Kosan  Cheju Island Korea  Level 1.0
    %AOD_Cimel=[0.111206,0.145382,0.202700,0.320554,0.361146,0.427951,0.457678]; %  02:05:2001,02:48:40, Kosan  Cheju Island Korea  Level 2.0 0.117130,2.041516,1.065345
   
    target=[126.167,33.283]; %long, lat Kosan
    target_alt=0;
    AOD_Cimel_err=[0.01  0.01     0.01     0.015     0.015     0.015     0.02    ];
    loglog(lambda_Cimel,AOD_Cimel,'ro','MarkerSize',8,'MarkerFaceColor','r');
    legend('AATS-6','Cimel')
    AOD_fit_Cimel_mean=mean(AOD_fit_Cimel);
    %loglog(lambda_Cimel,AOD_fit_Cimel_mean,'b.');
    hold off  
    %AOD_delta_Cimel=AOD_Cimel-AOD_fit_Cimel_mean;    
    rng=distance(ones(1,length(Latitude))*target(2),ones(1,length(Longitude))*target(1),Latitude,Longitude);
    rng=deg2km(rng);
    target_dist=mean(rng);
    figure(4)
    plot(UT,rng,'.-',UT(AOD_flag==1),rng(AOD_flag==1),'g.')
    grid on
    
    %append comparison to file
    %resultfile='cimel_aats14.txt';
    %fid=fopen(['c:\beat\data\ACE-Asia\Cimel\',resultfile],'a');
    %fprintf(fid,'%s',filename)
    %fprintf(fid,' %g',UT_start,UT_end,target_dist,target_alt,mean(GPS_Alt),mean(Pressure_Altitude),AOD_Cimel,AOD_fit_Cimel_mean,AOD_mean,AOD_err,AOD_fit_mean);
    %fprintf(fid,'\r\n');
    %fclose(fid);
end

if strcmp(Kosan_METRI,'yes')
   figure(3)
   hold on
   lambda_METRI=[0.368 0.500 0.675 0.778 0.862]; 
   %AOD_METRI=   [0.657 0.396 0.257 0.254 0.144]; % May 2    11.817 LT =2.817 UT, 2:49 UT
   %AOD_METRI=   [0.675 0.463 0.381 0.387 0.305]; % April 12 Day 102 10.717 LT = 1:43 UT
   AOD_METRI=   [0.515 0.345 0.281 0.277 0.212]; % April 12 Day  102 16.100 LT = 7:06 UT
   loglog(lambda_METRI,AOD_METRI,'bo','MarkerSize',8,'MarkerFaceColor','b');
   hold off
   legend('AATS-6','AERONET','METRI')
end


figure(3)
hold on
loglog(lambda_fit,AOD_fit_mean,'k');
yerrorbar('loglog',0.3,1.1, 1e-1  ,1,lambda,AOD_mean,AOD_err,'ko')
if strcmp(Cimel,'yes')
  yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,AOD_Cimel,AOD_Cimel_err,'ro')
end
hold off

    
    
    