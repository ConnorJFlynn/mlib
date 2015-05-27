close all
clear all

%lambda_AATS14=[0.3800 0.4491 0.4539 0.4995 0.5248 0.6059 0.6672 0.7119 0.7786 0.8640 1.0194 1.0597 1.5579];
channel=5

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

read_AATS14_ext
UT=UT_AATS14;

ErrBarLevel=[min(Altitude_AATS14)+0.1:0.4:max(Altitude_AATS14)];

%Jun 21 Profile
%h=[min(Altitude_AATS14) 1.7 1.7 max(Altitude_AATS14)]

%Jul 8 Profile
%h=[min(Altitude_AATS14) 1.111 2.722 max(Altitude_AATS14)]

%Jul 17 Profile
h=[min(Altitude_AATS14) 1.121 1.844 max(Altitude_AATS14)]

%compute layer AOD
A=sortrows([Altitude_AATS14' AOD_AATS14' AOD_err_AATS14'],1);
Altitude_AATS14_sort=A(:,1);
AOD_AATS14_sort=A(:,2:14);
AOD_err_AATS14_sort=A(:,15:27);
clear A

L=find(diff(Altitude_AATS14_sort)~=0);
Altitude_AATS14_sort=Altitude_AATS14_sort(L);
AOD_AATS14_sort     =AOD_AATS14_sort(L,:);
AOD_err_AATS14_sort     =AOD_err_AATS14_sort(L,:);
AOD_AATS14_level = (INTERP1(Altitude_AATS14_sort,AOD_AATS14_sort,h(2:3),'nearest'))';

%AATS-14 Error Bars
AOD_AATS14_bars= INTERP1(Altitude_AATS14_sort,AOD_AATS14_sort,ErrBarLevel,'nearest');
AOD_err_AATS14_level= INTERP1(Altitude_AATS14_sort,AOD_err_AATS14_sort,ErrBarLevel,'nearest');
clear Altitude_AATS14_sort
clear AOD_AATS14_sort
clear AOD_err_AATS14_sort

%AATS-14 layer AOD
AOD_AATS14_whole=abs(AOD_AATS14(:,1)-AOD_AATS14(:,end-1));
AOD_AATS14_MBL=abs(AOD_AATS14(:,end-1)-AOD_AATS14_level(:,1));
AOD_AATS14_Dust=abs(AOD_AATS14_level(:,2)-AOD_AATS14(:,1));

%AATS-14 extinction error
Ext_err_AATS14=0.005*ones(size(ext_AATS14)); % that's how much it can go negative

j=(Altitude_AATS14 >=h(1)& Altitude_AATS14<=h(2));
Ext_err_AATS14(:,j)=sqrt((0.067*ext_AATS14(:,j)).^2+(0.005)^2); % these are Collins value's no clue how he came up with those

j=(Altitude_AATS14 >=h(3)& Altitude_AATS14<=h(4));
Ext_err_AATS14(:,j)=sqrt((0.036*ext_AATS14(:,j)).^2+(0.005)^2); % these are Collins value's no clue how he came up with those

%Caltech OPC
read_Caltech
i_Caltech=find(UT_Caltech<=max(UT) & UT_Caltech>=min(UT));
Altitude_Caltech= interp1(UT,Altitude_AATS14,[UT(1) UT_Caltech(i_Caltech) UT(end)],'nearest');
ext_AATS14_Caltech=interp1(UT,ext_AATS14',[UT(1) UT_Caltech(i_Caltech) UT(end)],'nearest');
Ext_err_AATS14_Caltech=interp1(UT,Ext_err_AATS14',[UT(1) UT_Caltech(i_Caltech) UT(end)],'nearest');
Ext_Caltech=interp1(UT_Caltech,Ext_Caltech,[UT(1) UT_Caltech(i_Caltech) UT(end)]);

read_Caltech_errors
Caltech_err_plus=interp1(Altitude_Caltech_errors',Caltech_err_plus',Altitude_Caltech','nearest');
Caltech_err_minus=interp1(Altitude_Caltech_errors',Caltech_err_minus',Altitude_Caltech','nearest');

AOD_Caltech=-cumtrapz(Altitude_Caltech,Ext_Caltech)*1e3;
AOD_Caltech_whole=-trapz(Altitude_Caltech,Ext_Caltech)*1e3;
AOD_Caltech_err_plus_whole=-trapz(Altitude_Caltech,Caltech_err_plus)*1e3;
AOD_Caltech_err_minus_whole=-trapz(Altitude_Caltech,Caltech_err_minus)*1e3;

j=(Altitude_Caltech>=h(1)& Altitude_Caltech<=h(2));
AOD_Caltech_MBL=-trapz(Altitude_Caltech(j),Ext_Caltech(j,:))*1e3;
AOD_Caltech_err_plus_MBL=-trapz(Altitude_Caltech(j),Caltech_err_plus(j,:))*1e3;
AOD_Caltech_err_minus_MBL=-trapz(Altitude_Caltech(j),Caltech_err_minus(j,:))*1e3;
x=Ext_Caltech(j,channel)*1e3;
y=ext_AATS14_Caltech(j,channel);
n=length(find(j==1));
mean_rel_diff_Caltech_MBL=mean(x./y-1)
std_rel_diff_Caltech_MBL=std(x./y-1)
rms_rel_diff_Caltech_MBL=(sum((x./y-1).^2)/(n-1))^0.5
mean_diff_Caltech_MBL=mean(x-y)
std_diff_Caltech_MBL=std(x-y)
rms_diff_Caltech_MBL=(sum((x-y).^2)/(n-1))^0.5


j=(Altitude_Caltech>=h(3)& Altitude_Caltech<=h(4));
AOD_Caltech_Dust=-trapz(Altitude_Caltech(j),Ext_Caltech(j,:))*1e3;
AOD_Caltech_err_plus_Dust=-trapz(Altitude_Caltech(j),Caltech_err_plus(j,:))*1e3;
AOD_Caltech_err_minus_Dust=-trapz(Altitude_Caltech(j),Caltech_err_minus(j,:))*1e3;
x=Ext_Caltech(j,channel)*1e3;
y=ext_AATS14_Caltech(j,channel);
n=length(find(j==1));
mean_rel_diff_Caltech_Dust=mean(x./y-1)
std_rel_diff_Caltech_Dust=std(x./y-1)
rms_rel_diff_Caltech_Dust=(sum((x./y-1).^2)/(n-1))^0.5
mean_diff_Caltech_Dust=mean(x-y)
std_diff_Caltech_Dust=std(x-y)
rms_diff_Caltech_Dust=(sum((x-y).^2)/(n-1))^0.5

%Neph+PSAP results
read_Misu_ambient
i_Misu=find(UT_Misu<=max(UT) & UT_Misu>=min(UT));
Altitude_Misu=interp1(UT,Altitude_AATS14,UT_Misu(i_Misu));
Amb_scat_Misu=Amb_scat_Misu(:,i_Misu);
Scat_corr_err_Misu=Scat_corr_err_Misu(:,i_Misu);

ext_AATS14_UW=interp1(UT,ext_AATS14',UT_Misu(i_Misu));
Ext_err_AATS14_UW=interp1(UT,Ext_err_AATS14',UT_Misu(i_Misu));


read_PSAP
Abs_PSAP_corr=interp1(Altitude_PSAP,Abs_PSAP_corr,Altitude_Misu);
PSAP_err=interp1(Altitude_PSAP,PSAP_err,Altitude_Misu);
[m,n]=size(Amb_scat_Misu);
Ext_Misu=(Amb_scat_Misu+(ones(m,1)*Abs_PSAP_corr).*(ones(n,1)*(lambda_PSAP./lambda_Misu))')';

AOD_Misu=-cumtrapz(Altitude_Misu,Ext_Misu);
AOD_Misu_whole=-trapz(Altitude_Misu,Ext_Misu);

% UW Scattering errors and layer AODs
Amb_scat_UW=Amb_scat_UW(i_Misu);
Scat_corr_err_UW=Scat_corr_err_UW(i_Misu);
Ext_UW=Amb_scat_UW+Abs_PSAP_corr*lambda_PSAP/lambda_UW; %Correction assuming abs proportional 1/lambda
AOD_UW_Amb=-cumtrapz(Altitude_Misu,Ext_UW);
AOD_UW_Amb_whole=-trapz(Altitude_Misu,Ext_UW);

Scat_err_random_UW=0.0025*ones(size(Amb_scat_UW));
Scat_err_random_Misu=0.0025*ones(size(Amb_scat_Misu));

Scat_err_growth_UW=zeros(size(Amb_scat_UW));
Scat_err_growth_Misu=zeros(size(Amb_scat_Misu));

j=(Altitude_Misu>=h(1)& Altitude_Misu<=h(2)); %MBL
AOD_UW_Amb_MBL=-trapz(Altitude_Misu(j),Ext_UW(j));
AOD_Misu_MBL=-trapz(Altitude_Misu(j),Ext_Misu(j,:));
Scat_err_growth_UW(j)=0.15*Amb_scat_UW(j);
Scat_err_growth_Misu(:,j)=0.15*Amb_scat_Misu(:,j);

j=(Altitude_Misu>=h(3)& Altitude_Misu<=h(4)); % Dust
AOD_UW_Amb_Dust=-trapz(Altitude_Misu(j),Ext_UW(j));
AOD_Misu_Dust=-trapz(Altitude_Misu(j),Ext_Misu(j,:));
%Scat_err_growth_UW(j)=0.00*Amb_scat_UW(j);
%Scat_err_growth_Misu(:,j)=0.15*Amb_scat_Misu(:,j);

Ext_err_UW=sqrt(Scat_err_random_UW.^2+Scat_err_growth_UW.^2+Scat_corr_err_UW.^2+PSAP_err.^2);
Ext_err_Misu=sqrt(Scat_err_random_Misu.^2+Scat_err_growth_Misu.^2+Scat_corr_err_Misu.^2+(ones(3,1)*PSAP_err).^2);

j=(Altitude_Misu>=h(1)& Altitude_Misu<=h(2));%MBL
AOD_err_UW_Amb_MBL=-trapz(Altitude_Misu(j),Ext_err_UW(j));
AOD_err_Misu_MBL=-trapz(Altitude_Misu(j),Ext_err_Misu(:,j)');
x=Ext_UW(j)';
y=ext_AATS14_UW(j,channel);
n=length(find(j==1));
mean_rel_diff_UW_MBL=mean(x./y-1)
std_rel_diff_UW_MBL=std(x./y-1)
rms_rel_diff_UW_MBL=(sum((x./y-1).^2)/(n-1))^0.5
mean_diff_UW_MBL=mean(x-y)
std_diff_UW_MBL=std(x-y)
rms_diff_UW_MBL=(sum((x-y).^2)/(n-1))^0.5


j=(Altitude_Misu>=h(3)& Altitude_Misu<=h(4));%Dust
AOD_err_UW_Amb_Dust=-trapz(Altitude_Misu(j),Ext_err_UW(j));
AOD_err_Misu_Dust=-trapz(Altitude_Misu(j),Ext_err_Misu(:,j)');
x=Ext_UW(j)';
y=ext_AATS14_UW(j,channel);
n=length(find(j==1));
mean_rel_diff_UW_Dust=mean(x./y-1)
std_rel_diff_UW_Dust=std(x./y-1)
rms_rel_diff_UW_Dust=(sum((x./y-1).^2)/(n-1))^0.5
mean_diff_UW_Dust=mean(x-y)
std_diff_UW_Dust=std(x-y)
rms_diff_UW_Dust=(sum((x-y).^2)/(n-1))^0.5

%Las Galletas Lidar
read_lidar_Galletas
j=(lidar_altitude>=h(1)& lidar_altitude<=h(2)); %MBL
AOD_lidar_MBL=trapz(lidar_altitude(j),lidar_ext_16GMT(j));
j=(lidar_altitude>=h(3)& lidar_altitude<=h(4)); %Dust
AOD_lidar_Dust=trapz(lidar_altitude(j),lidar_ext_16GMT(j));

%plot profile
figure(13)
orient landscape
subplot(1,2,1)
plot(AOD_AATS14(channel,:),Altitude_AATS14,...
   AOD_Caltech(:,channel)    -min(AOD_Caltech(:,channel))    +min(AOD_AATS14(channel,:)),Altitude_Caltech,...
   AOD_UW_Amb                -min(AOD_UW_Amb)                +min(AOD_AATS14(channel,:)),Altitude_Misu)
hold on
xerrorbar('linlin',0,0.4,0,4,AOD_AATS14_bars(:,channel),ErrBarLevel, -AOD_err_AATS14_level(:,channel),AOD_err_AATS14_level(:,channel),'.')
%axis([0.1 0.3 0 4]) %July 8
axis([0.0 0.4 0 4]) %July 17
hold off
ylabel('Altitude [km]','FontSize',14)
xlabel('Aerosol Optical Depth','FontSize',14)
set(gca,'FontSize',14)
grid on
title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',10)
subplot(1,2,2)
plot(ext_AATS14(channel,:),Altitude_AATS14,'-',...
     Ext_Caltech(:,channel)*1e3,Altitude_Caltech,'.-',...
     Ext_UW,Altitude_Misu,'-')  
%  ext_AATS14(channel,:)+Ext_err_AATS14(channel,:),Altitude_AATS14,':b',...
%     ext_AATS14(channel,:)-Ext_err_AATS14(channel,:),Altitude_AATS14,':b',...
%    (Ext_Caltech(:,channel)+Caltech_err_green_plus')*1e3,Altitude_Caltech,':g',...
%    (Ext_Caltech(:,channel)-Caltech_err_green_minus')*1e3,Altitude_Caltech,':g',...
%   Ext_UW+Ext_err_UW,Altitude_Misu,':r',...
%     Ext_UW-Ext_err_UW,Altitude_Misu,':r'
ylabel('Altitude [km]','FontSize',14)
xlabel('Extinction [1/km]','FontSize',14)
grid on
%axis([-0.006 0.16 0 4])        July 8
%set(gca,'xtick',[0:0.04:0.16])
axis([0 0.2 0 4])      %  July 17
set(gca,'xtick',[0:0.05:0.2])
%title(title2,'FontSize',10)
set(gca,'FontSize',14)
legend('AATS-14','Caltech OPC','Neph+PSAP')

%plot profile but with Las Galletas Lidar
figure(14)
orient landscape
subplot(1,2,1)
plot(AOD_AATS14(channel,:),Altitude_AATS14,...
   AOD_Caltech(:,channel)    -min(AOD_Caltech(:,channel))    +min(AOD_AATS14(channel,:)),Altitude_Caltech,...
   AOD_UW_Amb                -min(AOD_UW_Amb)                +min(AOD_AATS14(channel,:)),Altitude_Misu,...
   lidar_AOD_16GMT, lidar_altitude,'c')
hold on
xerrorbar('linlin',0,0.4,0,4,AOD_AATS14_bars(:,channel),ErrBarLevel, -AOD_err_AATS14_level(:,channel),AOD_err_AATS14_level(:,channel),'.')
%axis([0.1 0.3 0 4]) %July 8
axis([0.0 0.45 0 5.5]) %July 17
hold off
ylabel('Altitude [km]','FontSize',14)
xlabel('Aerosol Optical Depth','FontSize',14)
set(gca,'FontSize',14)
grid on
title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',10)
subplot(1,2,2)
plot(ext_AATS14(channel,:),Altitude_AATS14,'-',...
     Ext_Caltech(:,channel)*1e3,Altitude_Caltech,'.-',...
     Ext_UW,Altitude_Misu,'-',...
     lidar_ext_16GMT, lidar_altitude,'c')  
%  ext_AATS14(channel,:)+Ext_err_AATS14(channel,:),Altitude_AATS14,':b',...
%     ext_AATS14(channel,:)-Ext_err_AATS14(channel,:),Altitude_AATS14,':b',...
%    (Ext_Caltech(:,channel)+Caltech_err_green_plus')*1e3,Altitude_Caltech,':g',...
%    (Ext_Caltech(:,channel)-Caltech_err_green_minus')*1e3,Altitude_Caltech,':g',...
%   Ext_UW+Ext_err_UW,Altitude_Misu,':r',...
%     Ext_UW-Ext_err_UW,Altitude_Misu,':r'
ylabel('Altitude [km]','FontSize',14)
xlabel('Extinction [1/km]','FontSize',14)
grid on
%axis([-0.006 0.16 0 4])        July 8
%set(gca,'xtick',[0:0.04:0.16])
axis([0 0.2 0 5.5])      %  July 17
set(gca,'xtick',[0:0.05:0.2])
%title(title2,'FontSize',10)
set(gca,'FontSize',14)
legend('AATS-14','Caltech OPC','Neph+PSAP','Lidar')

% plot differences
orient portrait
figure(15)
subplot(2,2,1)
plot(Ext_Caltech(:,channel)*1e3-ext_AATS14_Caltech(:,channel),Altitude_Caltech,'ok-',...
    sqrt(Ext_err_AATS14_Caltech(:,channel).^2+(Caltech_err_plus(:,2)*1e3).^2),Altitude_Caltech,':k',...
    -sqrt(Ext_err_AATS14_Caltech(:,channel).^2+(Caltech_err_minus(:,2)*1e3).^2),Altitude_Caltech,':k',...
     [0 0],[0, 4],'k','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',[5])
%    +Ext_err_AATS14_Caltech(:,channel)',Altitude_Caltech,':r',...
%    -Ext_err_AATS14_Caltech(:,channel)',Altitude_Caltech,':r',...
%    Caltech_err_plus(:,2)*1e3,Altitude_Caltech,':k',...
%    -Caltech_err_minus(:,2)*1e3,Altitude_Caltech,':k',...
ylabel('Altitude [km]','FontSize',13)
xlabel('(\sigma_{e Caltech} - \sigma_{e AATS-14}) [km^{-1}]','FontSize',13)
axis([-0.1 0.1 0 4])
%title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',10)
set(gca,'FontSize',13)
subplot(2,2,2)
plot(Ext_UW'-ext_AATS14_UW(:,channel),Altitude_Misu,'k.',...
 sqrt(Ext_err_UW.^2+Ext_err_AATS14_UW(:,channel)'.^2),Altitude_Misu,':k',...
-sqrt(Ext_err_UW.^2+Ext_err_AATS14_UW(:,channel)'.^2),Altitude_Misu,':k',...
 [0 0],[0, 4],'k')
%+Scat_err_random_UW,Altitude_Misu,':y',...
%-Scat_err_random_UW,Altitude_Misu,':y',...
%+Scat_err_growth_UW,Altitude_Misu,':g',...
%-Scat_err_growth_UW,Altitude_Misu,':g',...
%+Scat_corr_err_UW,Altitude_Misu,':b',...
%-Scat_corr_err_UW,Altitude_Misu,':b',...
%+PSAP_err,Altitude_Misu,':c',...
%-PSAP_err,Altitude_Misu,':c',...
%+Ext_err_UW,Altitude_Misu,':m',...
%-Ext_err_UW,Altitude_Misu,':m',...
%+Ext_err_AATS14_UW(:,channel),Altitude_Misu,':r',...
%-Ext_err_AATS14_UW(:,channel),Altitude_Misu,':r',...
ylabel('Altitude [km]','FontSize',13)
xlabel('(\sigma_{e Neph+PSAP} - \sigma_{e AATS-14}) [km^{-1}]','FontSize',13)
%grid on
axis([-0.1 0.1 0 4])
%title(title2,'FontSize',10)
set(gca,'FontSize',13)

%plot ratios
subplot(2,2,3)
plot(Ext_Caltech(:,channel)*1e3./ext_AATS14_Caltech(:,channel)-1,Altitude_Caltech,'ok-',...
    sqrt((Caltech_err_plus(:,2)*1e3).^2+(Ext_err_AATS14_Caltech(:,channel)).^2)./abs(ext_AATS14_Caltech(:,channel)),Altitude_Caltech,'k:',...
    -sqrt((Caltech_err_minus(:,2)*1e3).^2+(Ext_err_AATS14_Caltech(:,channel)).^2)./abs(ext_AATS14_Caltech(:,channel)),Altitude_Caltech,'k:',...
    [0 0],[0, 4],'k','MarkerFaceColor','k','MarkerEdgeColor','k','MarkerSize',[5])
ylabel('Altitude [km]','FontSize',13)
xlabel('(\sigma_{e Caltech} - \sigma_{e AATS-14}) / \sigma_{e AATS-14}','FontSize',13)
%grid on
axis([-1 1 0 4])
set(gca,'FontSize',13)
subplot(2,2,4)
plot(Ext_UW'./ext_AATS14_UW(:,channel)-1,Altitude_Misu,'k.',...
sqrt(Ext_err_UW.^2+Ext_err_AATS14_UW(:,channel)'.^2)'./ext_AATS14_UW(:,channel),Altitude_Misu,'k:',...
-sqrt(Ext_err_UW.^2+Ext_err_AATS14_UW(:,channel)'.^2)'./ext_AATS14_UW(:,channel),Altitude_Misu,'k:',...
 [0 0],[0, 4],'k')
ylabel('Altitude [km]','FontSize',13)
xlabel('(\sigma_{e Neph+PSAP} - \sigma_{e AATS-14}) / \sigma_{e AATS-14}','FontSize',13)
axis([-1 1 0 4])
set(gca,'FontSize',13)

%plot layer AOD spectra for whole profile
figure(16)
orient landscape
loglog(lambda_AATS14,AOD_AATS14_whole,'b*',...
       lambda_Caltech,AOD_Caltech_whole,'--g.',...
       lambda_UW,AOD_UW_Amb_whole,'ro',...
       lambda_Misu,AOD_Misu_whole,':mx');
hold on    
yerrorbar('loglog',0.3,1.6,0.02,0.4,lambda_AATS14,AOD_AATS14_whole, -0.05*AOD_AATS14_whole,0.05*AOD_AATS14_whole,'b*')
hold off
%legend('AATS-14','Caltech OPC','UW Neph. amb','MISU Neph. amb.')
legend('AATS-14','Caltech OPC','UW Neph(amb)+PSAP(dry)','MISU Neph(amb)+PSAP(dry)')
set(gca,'xlim',[.30 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ylim',[0.02,0.3])
set(gca,'ylim',[0.04,0.4])
%set(gca,'ytick',[0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3])
set(gca,'ytick',[0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4])
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Layer Aerosol Optical Depth','FontSize',14);
text(0.301,0.045,sprintf('Layer: %g-%g km',min(Altitude_AATS14),max(Altitude_AATS14 )),'FontSize',12)
title([title1 '           (' title2 ')'],'FontSize',12)
set(gca,'FontSize',14)
grid on

%plot layer AOD spectra for MBL
figure(17)
orient portrait
loglog(lambda_AATS14,AOD_AATS14_MBL,'*','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',8)
hold on    
loglog(lambda_Caltech,AOD_Caltech_MBL,'--g.','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',20)
loglog(lambda_UW,AOD_UW_Amb_MBL,'ro','MarkerSize',8)
loglog(lambda_Misu,AOD_Misu_MBL,'--mv','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize',8)
loglog(lambda_lidar,AOD_lidar_MBL,'cs','MarkerFaceColor','c','MarkerEdgeColor','c','MarkerSize',8)
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_Caltech([3 5 7]),AOD_Caltech_MBL([3 5 7]),AOD_Caltech_err_minus_MBL,AOD_Caltech_err_plus_MBL,'g--')
yerrorbar('loglog',0.3,1.6,-inf, inf,lambda_AATS14,AOD_AATS14_MBL, -0.07*AOD_AATS14_MBL,0.07*AOD_AATS14_MBL,'b*')
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_UW,AOD_UW_Amb_MBL,-AOD_err_UW_Amb_MBL,AOD_err_UW_Amb_MBL,'r')
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_Misu,AOD_Misu_MBL,-AOD_err_Misu_MBL,AOD_err_Misu_MBL,'m--')
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_lidar,AOD_lidar_MBL,-0.2*AOD_lidar_MBL,0.2*AOD_lidar_MBL,'c')
hold off
set(gca,'xlim',[.30 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ylim',[0.02,0.14]) % 8 July
set(gca,'ylim',[0.02,0.1]) %17 July
set(gca,'ytick',[ 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.12 0.14 0.16])
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Layer Aerosol Optical Depth','FontSize',14);
text(0.301,0.025,sprintf('Layer: %g-%g km',min(Altitude_AATS14),h(2)),'FontSize',12)
set(gca,'FontSize',14)
title(title1,'FontSize',12)
grid on
legend('AATS-14','Caltech OPC','UW Neph+PSAP','MISU Neph+PSAP','Lidar')

%plot layer AOD spectra for Dust
figure(18)
orient portrait
loglog(lambda_AATS14,AOD_AATS14_Dust,'*','MarkerFaceColor','b','MarkerEdgeColor','b','MarkerSize',8)
hold on    
loglog(lambda_Caltech,AOD_Caltech_Dust,'--g.','MarkerFaceColor','g','MarkerEdgeColor','g','MarkerSize',20)
loglog(lambda_UW,AOD_UW_Amb_Dust,'ro','MarkerSize',8)
loglog(lambda_Misu,AOD_Misu_Dust,'--mv','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize',8)
loglog(lambda_lidar,AOD_lidar_Dust,'cs','MarkerFaceColor','c','MarkerEdgeColor','c','MarkerSize',8)
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_Caltech([3 5 7]),AOD_Caltech_Dust([3 5 7]),AOD_Caltech_err_minus_Dust,AOD_Caltech_err_plus_Dust,'g--')
yerrorbar('loglog',0.3,1.6,-inf, inf,lambda_AATS14,AOD_AATS14_Dust, -0.04*AOD_AATS14_Dust,0.04*AOD_AATS14_Dust,'b*')
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_UW,AOD_UW_Amb_Dust,-AOD_err_UW_Amb_Dust,AOD_err_UW_Amb_Dust,'r')
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_Misu,AOD_Misu_Dust,-AOD_err_Misu_Dust,AOD_err_Misu_Dust,'m--')
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_lidar,AOD_lidar_Dust,-0.2*AOD_lidar_Dust,0.2*AOD_lidar_Dust,'c')
hold off
set(gca,'xlim',[.30 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ylim',[0.04 0.1]) % 8 July
%set(gca,'ytick',[0.04 0.05 0.06 0.07 0.08 0.09 0.1])
%text(0.301,0.045,sprintf('Layer: %g-%g km',h(3),max(Altitude_AATS14)),'FontSize',12)
set(gca,'ylim',[0.12 0.32]) % 17 July
set(gca,'ytick',[0.12:0.02:0.32])
text(0.301,0.13,sprintf('Layer: %g-%g km',h(3),max(Altitude_AATS14)),'FontSize',12)
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Layer Aerosol Optical Depth','FontSize',14);
%title([title1 ' ' title2],'FontSize',14)
title(title1,'FontSize',12)
set(gca,'FontSize',14)
grid on
legend('AATS-14','Caltech OPC','UW Neph+PSAP','MISU Neph+PSAP','Lidar')

figure(19)
plot(Amb_scat_UW./Ext_UW,Altitude_Misu,Amb_scat_Misu'./Ext_Misu,Altitude_Misu)
xlabel('SSA','FontSize',14);
ylabel('Altitude [km]','FontSize',14);
