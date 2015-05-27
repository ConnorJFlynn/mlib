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
%h=[min(Altitude_AATS14) 1.00 2.72 max(Altitude_AATS14)]

%Jul 17 Profile
h=[min(Altitude_AATS14) 1.02 1.925 max(Altitude_AATS14)]

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

%Error Bars
AOD_AATS14_bars= INTERP1(Altitude_AATS14_sort,AOD_AATS14_sort,ErrBarLevel,'nearest');
AOD_err_AATS14_level= INTERP1(Altitude_AATS14_sort,AOD_err_AATS14_sort,ErrBarLevel,'nearest');

clear Altitude_AATS14_sort
clear AOD_AATS14_sort
clear AOD_err_AATS14_sort

AOD_AATS14_whole=abs(AOD_AATS14(:,1)-AOD_AATS14(:,end));
AOD_AATS14_MBL=abs(AOD_AATS14(:,end)-AOD_AATS14_level(:,1));
AOD_AATS14_Dust=abs(AOD_AATS14_level(:,2)-AOD_AATS14(:,1));

read_Caltech
i_Caltech=find(UT<=max(UT_Caltech) & UT>=min(UT_Caltech));
Ext_Caltech= interp1(UT_Caltech,Ext_Caltech,UT(i_Caltech));

AOD_Caltech=-cumtrapz(Altitude_AATS14(i_Caltech),Ext_Caltech)*1e3;
AOD_Caltech_whole=-trapz(Altitude_AATS14(i_Caltech),Ext_Caltech)*1e3;

j=(Altitude_AATS14(i_Caltech)>=h(1))&(Altitude_AATS14(i_Caltech)<h(2));
AOD_Caltech_MBL=-trapz(Altitude_AATS14(j),Ext_Caltech(j,:))*1e3;

j=(Altitude_AATS14(i_Caltech)>=h(3))&(Altitude_AATS14(i_Caltech)<h(4));
AOD_Caltech_Dust=-trapz(Altitude_AATS14(j),Ext_Caltech(j,:))*1e3;

read_Misu_ambient
i_Misu=find(UT<=max(UT_Misu) & UT>=min(UT_Misu));
Amb_scat_Misu=interp1(UT_Misu,Amb_scat_Misu',UT(i_Misu));

read_PSAP
Abs_PSAP_corr=interp1(Altitude_PSAP,Abs_PSAP_corr,Altitude_AATS14(i_Misu));
Ext_Misu=Amb_scat_Misu+(ones(3,1)*Abs_PSAP_corr)';

read_Caltech_errors
Caltech_err_green_plus=interp1(Altitude_Caltech_errors,Caltech_err_green_plus,Altitude_AATS14(i_Misu),'nearest');
Caltech_err_green_minus=interp1(Altitude_Caltech_errors,Caltech_err_green_minus,Altitude_AATS14(i_Misu),'nearest');


AOD_Misu=-cumtrapz(Altitude_AATS14(i_Misu),Ext_Misu);
AOD_Misu_whole=-trapz(Altitude_AATS14(i_Misu),Ext_Misu);
%AOD_Misu=-cumtrapz(Altitude_AATS14(i_Misu),Amb_scat_Misu);
%AOD_Misu_whole=-trapz(Altitude_AATS14(i_Misu),Amb_scat_Misu);

j=(Altitude_AATS14(i_Misu)>=h(1))&(Altitude_AATS14(i_Misu)<h(2));
AOD_Misu_MBL=-trapz(Altitude_AATS14(j),Ext_Misu(j,:));
%AOD_Misu_MBL=-trapz(Altitude_AATS14(j),Amb_scat_Misu(j,:));

j=(Altitude_AATS14(i_Misu)>=h(3))&(Altitude_AATS14(i_Misu)<h(4));
AOD_Misu_Dust=-trapz(Altitude_AATS14(j),Ext_Misu(j,:));
%AOD_Misu_Dust=-trapz(Altitude_AATS14(j),Amb_scat_Misu(j,:));

%Dry_scat_UW= interp1(UT_UW,Dry_scat_UW,UT(i));
%Wet_scat_UW= interp1(UT_UW,Wet_scat_UW,UT(i));
Amb_scat_UW= interp1(UT_Misu,Amb_scat_UW,UT(i_Misu));
Ext_UW=Amb_scat_UW+Abs_PSAP_corr;

AOD_UW_Amb=-cumtrapz(Altitude_AATS14(i_Misu),Ext_UW);
%AOD_UW_Amb=-cumtrapz(Altitude_AATS14(i),Amb_scat_UW);
%AOD_UW_Dry=-cumtrapz(Altitude_AATS14(i),Dry_scat_UW);
AOD_UW_Amb_whole=-trapz(Altitude_AATS14(i_Misu),Ext_UW);
%AOD_UW_Amb_whole=-trapz(Altitude_AATS14(i),Amb_scat_UW);
%AOD_UW_Dry_whole=-trapz(Altitude_AATS14(i),Dry_scat_UW);

j=(Altitude_AATS14(i_Misu)>=h(1))&(Altitude_AATS14(i_Misu)<h(2));
AOD_UW_Amb_MBL=-trapz(Altitude_AATS14(j),Ext_UW(j));
%AOD_UW_Amb_MBL=-trapz(Altitude_AATS14(j),Amb_scat_UW(j));
%AOD_UW_Dry_MBL=-trapz(Altitude_AATS14(j),Dry_scat_UW(j));

j=(Altitude_AATS14(i_Misu)>=h(3))&(Altitude_AATS14(i_Misu)<h(4));
AOD_UW_Amb_Dust=-trapz(Altitude_AATS14(j),Ext_UW(j));
%AOD_UW_Amb_Dust=-trapz(Altitude_AATS14(j),Amb_scat_UW(j));
%AOD_UW_Dry_Dust=-trapz(Altitude_AATS14(j),Dry_scat_UW(j));

%plot profile
figure(13)
orient landscape
subplot(1,2,1)
plot(AOD_AATS14(channel,i_Misu),Altitude_AATS14(i_Misu),...
   AOD_Caltech(:,channel)    -min(AOD_Caltech(:,channel))    +min(AOD_AATS14(channel,:)),Altitude_AATS14(i_Caltech),...
   AOD_UW_Amb                -min(AOD_UW_Amb)                +min(AOD_AATS14(channel,:)),Altitude_AATS14(i_Misu))
hold on
xerrorbar('linlin',0,0.4,0,4,AOD_AATS14_bars(:,channel),ErrBarLevel, -AOD_err_AATS14_level(:,channel),AOD_err_AATS14_level(:,channel),'.')
%axis([0 0.08 -0.050 3.5])
hold off
%+min(AOD_AATS14(channel,:))
%+AOD_AATS14(channel,1)
ylabel('Altitude [km]','FontSize',14)
xlabel('Aerosol Optical Depth','FontSize',14)
grid on
title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',14)
set(gca,'FontSize',14)

subplot(1,2,2)
plot(ext_AATS14(channel,i_Misu),Altitude_AATS14(i_Misu),'b',...
   Ext_Caltech(:,channel)*1e3,Altitude_AATS14(i_Caltech),'g',...
  (Ext_Caltech(:,channel)+Caltech_err_green_plus')*1e3,Altitude_AATS14(i_Caltech),':g',...
  (Ext_Caltech(:,channel)-Caltech_err_green_minus')*1e3,Altitude_AATS14(i_Caltech),':g',...
   Ext_UW,Altitude_AATS14(i_Misu),'r')
ylabel('Altitude [km]','FontSize',14)
xlabel('Extinction [1/km]','FontSize',14)
grid on
axis([-0.006 0.2 0 4])
title(title2,'FontSize',10)
set(gca,'FontSize',14)
legend('AATS-14','Caltech OPC','3 Nephs(amb)+PSAP(dry)')

figure(20)
plot(Ext_Caltech(:,channel)'*1e3-ext_AATS14(channel,i_Misu),Altitude_AATS14(i_Misu),'b',...
     Caltech_err_green_plus*1e3,Altitude_AATS14(i_Caltech),':g',...
     -Caltech_err_green_minus*1e3,Altitude_AATS14(i_Caltech),':g',...
     Ext_UW-ext_AATS14(channel,i_Misu),Altitude_AATS14(i_Misu),'r')
ylabel('Altitude [km]','FontSize',14)
xlabel('Extinction [1/km]','FontSize',14)
grid on
%axis([-0.006 0.2 0 4])
title(title2,'FontSize',10)
set(gca,'FontSize',14)
legend('AATS-14','Caltech OPC','3 Nephs(amb)+PSAP(dry)')

%plot profile but with Las Galletas MPL lidar
read_lidar_Galletas
figure(15)
orient landscape
subplot(1,2,1)
plot(AOD_AATS14(channel,i_Misu),Altitude_AATS14(i_Misu),...
   AOD_Caltech(:,channel)    -min(AOD_Caltech(:,channel))    +min(AOD_AATS14(channel,:)),Altitude_AATS14(i_Caltech),...
   AOD_UW_Amb                -min(AOD_UW_Amb)                +min(AOD_AATS14(channel,:)),Altitude_AATS14(i_Misu),...
   AOD_Misu(:,2)             -min(AOD_Misu(:,2))             +min(AOD_AATS14(channel,:)),Altitude_AATS14(i_Misu),...
   lidar_AOD_16GMT, lidar_altitude)
hold on
xerrorbar('linlin',0,0.4,0,4,AOD_AATS14_bars(:,channel),ErrBarLevel, -AOD_err_AATS14_level(:,channel),AOD_err_AATS14_level(:,channel),'.')
axis([0 0.4 0 5.2])
hold off
%+min(AOD_AATS14(channel,:))
%+AOD_AATS14(channel,1)
ylabel('Altitude [km]','FontSize',14)
xlabel('Aerosol Optical Depth','FontSize',14)
grid on
title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',14)
set(gca,'FontSize',14)

subplot(1,2,2)
plot(ext_AATS14(channel,i_Misu),Altitude_AATS14(i_Misu),...
   Ext_Caltech(:,channel)*1e3,Altitude_AATS14(i_Caltech),...
   Ext_UW,Altitude_AATS14(i_Misu),...
   Ext_Misu(:,2),Altitude_AATS14(i_Misu),...
   lidar_ext_16GMT, lidar_altitude)
ylabel('Altitude [km]','FontSize',14)
xlabel('Extinction [1/km]','FontSize',14)
grid on
axis([0 0.2 0 5.2])
title(title2,'FontSize',10)
set(gca,'FontSize',14)
legend('AATS-14','Caltech OPC','UW Neph(amb)+PSAP(dry)','MISU Neph(amb)+PSAP(dry)','Lidar Las Galletas')

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

figure(17)
orient landscape
loglog(lambda_AATS14,AOD_AATS14_MBL,'b*',...
       lambda_Caltech,AOD_Caltech_MBL,'--g.',...
       lambda_UW,AOD_UW_Amb_MBL,'ro',...
       lambda_Misu,AOD_Misu_MBL,':mx');
hold on    
yerrorbar('loglog',0.3,1.6,0.01,0.4,lambda_AATS14,AOD_AATS14_MBL, -0.07*AOD_AATS14_MBL,0.07*AOD_AATS14_MBL,'b*')
hold off
set(gca,'xlim',[.30 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ylim',[0.01,0.2])
set(gca,'ylim',[0.01,0.1])
%set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2])
set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1])
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Layer Aerosol Optical Depth','FontSize',14);
text(0.301,0.015,sprintf('Layer: %g-%g km',min(Altitude_AATS14),h(2)),'FontSize',12)
title([title1 '           (' title2 ')'],'FontSize',12)
set(gca,'FontSize',14)
grid on
%legend('AATS-14','Caltech OPC','UW Neph. amb','MISU Neph. amb.')
legend('AATS-14','Caltech OPC','UW Neph(amb)+PSAP(dry)','MISU Neph(amb)+PSAP(dry)')

figure(18)
orient landscape
loglog(lambda_AATS14,AOD_AATS14_Dust,'b*',...
       lambda_Caltech,AOD_Caltech_Dust,'--g.',...
       lambda_UW,AOD_UW_Amb_Dust,'ro',...
       lambda_Misu,AOD_Misu_Dust,':mx');
hold on    
yerrorbar('loglog',0.3,1.6,-inf, inf,lambda_AATS14,AOD_AATS14_Dust, -0.04*AOD_AATS14_Dust,0.04*AOD_AATS14_Dust,'b*')
hold off
set(gca,'xlim',[.30 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ylim',[0.008 0.1])
set(gca,'ylim',[0.14 0.28])
%set(gca,'ytick',[0.008 0.009 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1])
set(gca,'ytick',[0.14 0.16 0.18 0.2 0.22 0.24 0.26 0.28])
xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Layer Aerosol Optical Depth','FontSize',14);
title([title1 ' ' title2],'FontSize',14)
text(0.31,0.15,sprintf('Layer: %g-%g km',h(3),max(Altitude_AATS14)),'FontSize',12)
title([title1 '           (' title2 ')'],'FontSize',12)
set(gca,'FontSize',14)
grid on
%legend('AATS-14','Caltech OPC','UW Neph. amb.','MISU Neph. amb.')
legend('AATS-14','Caltech OPC','UW Neph(amb)+PSAP(dry)','MISU Neph(amb)+PSAP(dry)')


figure(19)
plot(Amb_scat_UW./Ext_UW,Altitude_AATS14(i_Misu))
xlabel('SSA','FontSize',14);
ylabel('Altitude [km]','FontSize',14);
