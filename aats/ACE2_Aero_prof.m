close all
clear all

read_AATS14_ext

%plot profile
figure(1)
%orient landscape

% defines wavelengths to be shown on plot
%          380.3  448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4 1018.7 1059  1557.5	
%channel     1      2      3      4      5      6      7      8       9     10   11     12    13
channel=[1 4 10 13];

subplot(1,2,1)
plot(AOD_AATS14(channel,:),Altitude_AATS14,'.')
ylabel('Altitude [km]','FontSize',14)
xlabel('Aerosol Optical Depth','FontSize',14)
grid on
title([title1 sprintf(' %5.2f-%5.2f %s',min(UT_AATS14),max(UT_AATS14),'UT')],'FontSize',14)
set(gca,'FontSize',14)
axis([0.0 0.4 0 4])

subplot(1,2,2)
plot(ext_AATS14(channel,:),Altitude_AATS14)
ylabel('Altitude [km]','FontSize',14)
xlabel('Extinction [1/km]','FontSize',14)
grid on
axis([0 0.2 0 4])
title(title2,'FontSize',10)
set(gca,'FontSize',14)
legend('380 nm','499 nm','864 nm','1558 nm')

