close all
clear all

read_AATS14_ext

%lambda_AATS14=[0.3800 0.4491 0.4539 0.4995 0.5248 0.6059 0.6672 0.7119 0.7786 0.8640 1.0194 1.0597 1.5579];
ext_err=[1 1 1 1 1 1 1 1 1 1 1 1 1]*5e-3; 
figure(1)
orient landscape
[m,n]=size(AOD_AATS14)

%compute mean extinction
max_Alt=3437/1e3 %km
min_Alt=2603/1e3 %km

ii=find(Altitude_AATS14<=max_Alt & Altitude_AATS14>=min_Alt);
mean_ext_AATS14=mean(ext_AATS14(:,ii)')
loglog(lambda_AATS14,mean_ext_AATS14,'mo');
hold on
yerrorbar('loglog',0.3,1.6, 1e-4, inf,lambda_AATS14,mean_ext_AATS14,ext_err,'mo')
hold off
set(gca,'xlim',[.300 1.60]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
xlabel('Wavelength [microns]');
ylabel('Extinction')
grid on

%extinction
for i=1:n
 Altitude_AATS14(i)  
 loglog(lambda_AATS14,ext_AATS14(:,i),'mo');
 hold on
 yerrorbar('loglog',0.3,1.6, 1e-4, inf,lambda_AATS14,ext_AATS14(:,i),ext_err,ext_err,'mo')
 hold off
 set(gca,'xlim',[.300 1.60]);
 set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 xlabel('Wavelength [microns]');
 ylabel('Extinction')
 pause(0.01)
end 

% AOD
for i=1:n
 Altitude_AATS14(i)  
 loglog(lambda_AATS14,AOD_AATS14(:,i),'o');
 hold on
 yerrorbar('loglog',0.3,1.6, -inf, inf,lambda_AATS14,AOD_AATS14(:,i),AOD_err_AATS14(:,i),AOD_err_AATS14(:,i),'mo')
 hold off
 set(gca,'xlim',[.300 1.60]);
 set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 %set(gca,'ylim',[0.1 0.35]);
 title(title1);
 xlabel('Wavelength [microns]');
 ylabel('Optical Depth')
 pause (0.01)
end


