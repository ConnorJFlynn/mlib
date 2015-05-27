% Spectral Aerosol Optical Depth and Angstrom Exponent at Kosan supersite(PI: Jiyoung Kim, jykim@metri.re.kr)
% Instrument: Sunphometer(model: MS-110, EKO Ltd., Japan; auto suntracking system(STR-01) by sun sensor)
% Cloud screening algorithm was applied(using the method developed by NASA/GSFC AERONET)
% Angstrom Exponent(alpha) was calculated from the linear fitting of AOD(368, 500, 675, 778, and 862) vs. each wavelength
% 
% Columns in the following data indicates 
% Julian_day(JD), LST(UTC+9, hr), JD+LST/24, Zenith_Angle  Airmass  AOD368  AOD500  AOD675  AOD778 AOD862  alpha   beta   vis


load -ascii c:\beat\data\ACE-asia\EKO_Kosan\METRI_Sunphoto.txt

Julian_day=METRI_Sunphoto(:,1);
LST=METRI_Sunphoto(:,2);
DOY_METRI=METRI_Sunphoto(:,3)-9/24; %make it UT
Zenith_Angle=METRI_Sunphoto(:,4);
Airmass=METRI_Sunphoto(:,5);
AOD368=METRI_Sunphoto(:,6);
AOD500=METRI_Sunphoto(:,7);
AOD675=METRI_Sunphoto(:,8);
AOD778=METRI_Sunphoto(:,9);
AOD862=METRI_Sunphoto(:,10);
alpha=METRI_Sunphoto(:,11);
beta=METRI_Sunphoto(:,12);
vis=METRI_Sunphoto(:,13);
Air_Mass_METRI=1./cos(pi/180*Zenith_Angle);

%read cimel data
pathname='c:\Beat\Data\ACE-Asia\Cimel\';
filename='Kosan_AprilMay2001.txt' 
[DOY_Cimel,IPWV_Cimel,AOD_Cimel,lambda_Cimel,Air_Mass_Cimel]=read_Cimel_Lev20(pathname,filename);

figure(1)
subplot(3,1,1)
plot(DOY_METRI,AOD500,'.',DOY_Cimel, AOD_Cimel(4,:) ,'.')
%set(gca,'ylim',[0 2])
set(gca,'xlim',[90 125])
legend('EKO 500 nm','AERONET 500 nm')
ylabel('AOD')
grid on
subplot(3,1,2)
plot(DOY_METRI,AOD675,'.',DOY_Cimel, AOD_Cimel(5,:) ,'.')
%set(gca,'ylim',[0 2])
set(gca,'xlim',[90 125])
legend('EKO 675 nm','AERONET 670 nm')
ylabel('AOD')
grid on
subplot(3,1,3)
plot(DOY_METRI,AOD862,'.',DOY_Cimel, AOD_Cimel(6,:) ,'.')
%set(gca,'ylim',[0 2])
set(gca,'xlim',[90 125])
legend('EKO 862 nm','AERONET 870 nm')
ylabel('AOD')
grid on

DOY_start=101.7; % May2
DOY_end=102.7;

ii=find(DOY_Cimel>=DOY_start & DOY_Cimel<=DOY_end);
jj=find(DOY_METRI>=DOY_start & DOY_METRI<=DOY_end);

figure(2)
subplot(3,1,1)
plot((DOY_METRI(jj)-floor(DOY_start))*24,AOD500(jj),'.',(DOY_Cimel(ii)-floor(DOY_start))*24,AOD_Cimel(4,ii),'.')
grid on
legend('EKO 500 nm','AERONET 500 nm')
ylabel('AOD')

subplot(3,1,2)
plot((DOY_METRI(jj)-floor(DOY_start))*24,AOD675(jj),'.',(DOY_Cimel(ii)-floor(DOY_start))*24,AOD_Cimel(5,ii),'.')
grid on
legend('EKO 675 nm','AERONET 670 nm')
ylabel('AOD')

subplot(3,1,3)
plot((DOY_METRI(jj)-floor(DOY_start))*24,AOD862(jj),'.',(DOY_Cimel(ii)-floor(DOY_start))*24,AOD_Cimel(6,ii),'.')   
grid on
legend('EKO 862 nm','AERONET 870 nm')
ylabel('AOD')

AOD500_int=interp1(DOY_METRI,AOD500,DOY_Cimel);
AOD675_int=interp1(DOY_METRI,AOD675,DOY_Cimel);
AOD862_int=interp1(DOY_METRI,AOD862,DOY_Cimel);
Air_Mass_METRI_int=interp1(DOY_METRI,Air_Mass_METRI,DOY_Cimel);

figure(3)
subplot(3,1,1)
plot(DOY_Cimel,AOD500_int-AOD_Cimel(4,:) ,'.')
set(gca,'ylim',[-.1 .2])
set(gca,'xlim',[90 125])
legend('METRI 500 nm - AERONET 500 nm')
ylabel('Delta AOD')
grid on
subplot(3,1,2)
plot(DOY_Cimel,AOD675_int-AOD_Cimel(5,:) ,'.')
set(gca,'ylim',[-.1 .1])
set(gca,'xlim',[90 125])
legend('METRI 675 nm - AERONET 670 nm')
ylabel('Delta AOD')
grid on
subplot(3,1,3)
plot(DOY_Cimel,AOD862_int-AOD_Cimel(6,:) ,'.')
set(gca,'ylim',[-.1 .1])
set(gca,'xlim',[90 125])
legend('METRI 862 nm - AERONET 870 nm')
ylabel('Delta AOD')
grid on

figure(4)
subplot(2,1,1)
plot(DOY_Cimel,Air_Mass_Cimel,'.',DOY_METRI, Air_Mass_METRI)
set(gca,'xlim',[90 125])
legend('AERONET','METRI')
ylabel('Airmass')
grid on
subplot(2,1,2)
plot(DOY_Cimel,Air_Mass_METRI_int-Air_Mass_Cimel,'.')
set(gca,'xlim',[90 125])
set(gca,'ylim',[-0.1 0.3])
grid on
ylabel('Airmass AERONET-METRI')
xlabel('DOY 2001')