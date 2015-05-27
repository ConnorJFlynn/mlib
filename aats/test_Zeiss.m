close all
%location Ames
geog_long=-122.057
geog_lat=37.42
id_model_atm=2; %for Rayleigh
temp=298.0;
press=1013.25;
press_low=200;

% read data
[wvl,counts,day,month,year,hour,min,sec]=read_Zeiss;
[wvl,counts_dark]=read_Zeiss;
counts=counts-counts_dark;

%calculate airmass
UT=hour+7+min/60+sec/3600;
[azimuth, altitude,refr]=sun(geog_long, geog_lat,day, month, year, UT,temp,press);
SZA=90-altitude;
m_ray=1./(cos(SZA*pi/180)+0.50572*(96.07995-SZA).^(-1.6364)); %Kasten and Young (1989)

%Sun Distance
f=sundist(day,month,year) ;

%Rayleigh Scat
tau_ray=rayleigh(wvl/1e3,press,id_model_atm);
tau_aero=0.05.*(wvl/1e3).^-1.3;

figure(11)
plot(wvl,tau_ray,wvl,tau_aero)
xlabel('Wavelength (nm)')
ylabel('tau')
grid
axis([300 1050 0 1.5])

T=exp(-m_ray.*(tau_ray+tau_aero));

tau_ray200=rayleigh(wvl/1e3,press_low,id_model_atm);
T200=exp(-tau_ray200);

figure(1)
plot(wvl,counts,'.-')
grid on
axis([300 1050 0 2^16])
xlabel('Wavelength (nm)')
ylabel('Counts')

%Read near Sun data
[wvl,counts_nearSun]=read_Zeiss;
counts_nearSun=counts_nearSun-counts_dark;

%read filter data
[filename, pathname] = uigetfile('c:\beat\data\ddf\*.xls', 'Pick a file');
[A, B]= xlsread([pathname filename],'Schott') ;
wvl_filter=A(:,1);
FG3       =A(:,2);
BG23      =A(:,3);
NG3       =A(:,4);
BG24A     =A(:,5);
UG5       =A(:,6);
NG4       =A(:,7);
NG1       =A(:,8);
NG5	      =A(:,9);
NG9       =A(:,10);
NG10      =A(:,11);
NG11      =A(:,12);
NG12      =A(:,13);
UG1       =A(:,14);
UG11      =A(:,15);
BG26      =A(:,16);
BG28      =A(:,17);

[filename, pathname] = uigetfile('c:\beat\data\ddf\*.xls', 'Pick a file');
[A, B]= xlsread([pathname filename],'Hoya') ;
wvl_filter_H=A(:,1);
U325C     =A(:,2);
B410      =A(:,3);
U330      =A(:,4);
LB200     =A(:,5);

figure(2)
subplot(2,1,1)
plot(wvl_filter,BG23,'.-',wvl_filter,BG24A,'.-',wvl_filter,BG26,'.-',wvl_filter,BG28,'.-',wvl_filter,UG1,'.-',wvl_filter,UG5,'.-',wvl_filter,UG11,'.-')
legend('BG23','BG24A','BG26','BG28','UG1','UG5','UG11')
xlabel('Wavelength (nm)')
ylabel('Transmittance')
grid on

subplot(2,1,2)
plot(wvl_filter,NG1,'.-',wvl_filter,NG3,'.-',wvl_filter,NG4,'.-',wvl_filter,NG5,'.-',wvl_filter,NG9,'.-',wvl_filter,NG10,'.-',wvl_filter,NG11,'.-',wvl_filter,NG12,'.-')
legend('NG1','NG3','NG4','NG5','NG9','NG10','NG11','NG12')
xlabel('Wavelength (nm)')
ylabel('Transmittance')
grid on

figure(3)
plot(wvl_filter,FG3,'.-',wvl_filter_H,U325C ,'.-',wvl_filter_H,B410,'.-',wvl_filter_H,U330,'.-',wvl_filter_H,LB200)
legend('FG3','U325C','B410','U330','LB200')
xlabel('Wavelength (nm)')
ylabel('Transmittance')
grid on

NG3_int=interp1(wvl_filter,NG3,wvl);
NG4_int=interp1(wvl_filter,NG4,wvl);
NG5_int=interp1(wvl_filter,NG5,wvl);
UG5_int=interp1(wvl_filter,UG5,wvl);
BG24A_int=interp1(wvl_filter,BG24A,wvl);
BG26_int=interp1(wvl_filter,BG26,wvl);
FG3_int=interp1(wvl_filter,FG3,wvl);

LB200_int=interp1(wvl_filter_H,LB200,wvl);
B410_int=interp1(wvl_filter_H,B410,wvl);
U330_int=interp1(wvl_filter_H,U330,wvl);

figure(4)
counts_naked=counts./NG3_int./UG5_int;
plot(wvl,counts_naked)
xlabel('Wavelength (nm)')
ylabel('Counts')
grid
axis([300 1050 0 600000])
hold on
plot(wvl,25*counts_nearSun,'.-')
grid on
xlabel('Wavelength (nm)')
ylabel('Counts')
hold off

figure(5)
plot(wvl,25*counts_nearSun,wvl,25*counts_nearSun./T,wvl,25*counts_nearSun./T.*T200)
legend('direct sun','SZA=0, no ray, no aero','SZA=0, ray 500 hPa, no aero')
axis([300 1050 0 800000])
grid on
xlabel('Wavelength (nm)')
ylabel('Counts')


figure(6)
T_filter=50000./(25*counts_nearSun./T.*T200);
plot(wvl,T_filter)
hold on
[filename, pathname] = uigetfile('c:\beat\data\ddf\*.xls', 'Pick a file');
[A, B]= xlsread([pathname filename],'Wish') ;
wvl_filter_W=A(:,1);
T_filter_W  =A(:,2);

plot(wvl_filter_W,T_filter_W,'r')
plot(wvl,UG5_int.*NG4_int.*BG26_int,'g')
axis([300 1050 0 1])
grid on
hold off

