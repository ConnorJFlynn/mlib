clear
close all
read_AATS14_H2O
%read_UW_H2O;

read_UW_scat;
i=find(UT_AATS14<=max(UT_UW) & UT_AATS14>=min(UT_UW));
H2O_Dens_UW= interp1(UT_UW,H2O_Dens_UW,UT_AATS14(i));

CWV_AATS14_int=-cumtrapz(Altitude_AATS14,H2O_Dens_AATS14)/10;
CWV_UW_int=-cumtrapz(Altitude_AATS14,H2O_Dens_UW)/10;
CWV_UW=CWV_UW_int-min(CWV_UW_int)+CWV_AATS14(1);


figure(1)
%orient landscape     
subplot(1,2,1)
plot(CWV_AATS14,Altitude_AATS14,'b',...
     CWV_UW,Altitude_AATS14,'r--')
  
hold on  
i=find(Altitude_AATS14);
i=find(mod(i,40)==2);
xerrorbar('linlin',0,3,0,4,CWV_AATS14(i),Altitude_AATS14(i),H2O_err_AATS14(i),-H2O_err_AATS14(i),'b.')
hold off  

xlabel('Columnar Water Vapor [g/cm^2]','FontSize',13)
ylabel('Altitude [km]','FontSize',13)
set(gca,'ylim',[0 4])
set(gca,'xlim',[0 2.5]) %July 8
%set(gca,'xlim',[0 3])
set(gca,'xtick',[0:0.5:3]);
grid on
title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',10)
set(gca,'FontSize',13)

subplot(1,2,2)
plot(H2O_Dens_AATS14,Altitude_AATS14,'b',H2O_Dens_UW,Altitude_AATS14,'r--')
xlabel('Water Vapor Density [g/m^3]','FontSize',13)
%ylabel('Altitude [km]','FontSize',13)
legend('AATS-14','RH measurement')
set(gca,'ylim',[0 4])
set(gca,'xlim',[0 20])
grid on
%title(title2)
set(gca,'FontSize',13)


figure(2)
%ratios
subplot(1,2,1)
plot(CWV_UW./CWV_AATS14-1,Altitude_AATS14,'b.')

subplot(1,2,2)
plot(H2O_Dens_UW./H2O_Dens_AATS14-1,Altitude_AATS14,'r.')

figure(3)
%differences
subplot(1,2,1)
plot(CWV_UW-CWV_AATS14,Altitude_AATS14,'b.')
n=length(Altitude_AATS14);
rms_diff_CWV=(sum((CWV_UW-CWV_AATS14).^2)/(n-1))^0.5
mean_CVW=mean(CWV_AATS14)
rms_diff_CWV/mean_CVW
subplot(1,2,2)
plot(H2O_Dens_UW-H2O_Dens_AATS14,Altitude_AATS14,'r.')
rms_diff_H2O_Dens=(sum((H2O_Dens_UW-H2O_Dens_AATS14).^2)/(n-1))^0.5
mean_H2O_Dens=mean(H2O_Dens_AATS14)
rms_diff_H2O_Dens/mean_H2O_Dens