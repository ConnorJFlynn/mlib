close all
clear all
% %read in smps data
% [r_raw,dNdr,r_low,r_high,filename]=read_SMPS;

%interpolate on fine grid
% N_points=2000;
% r_low=0.2; %lower radius limit in microns
% %r_low=0.150; %lower radius limit in microns
% r_high=0.5;
% r=linspace(r_low, r_high, N_points);
% dNdr_fine = INTERP1(r_raw,dNdr,r,'nearest','extrap');
% figure(1)
% plot(r,dNdr_fine,'-',r_raw,dNdr,'.-');
% text(100,10,filename)

%get rid of raw values
% dNdr=dNdr_fine;

r=linspace(0.3, 0.4, 200);
[dNdr]=lognorm(r,1,0.3505,0.0045,1);
filename='lognorm D=700 nm NIST'

% r=linspace(0.2, 0.3, 200);
% [dNdr]=lognorm(r,1,0.2495,0.00325,1);
% filename='lognorm D=500 nm NIST'

% r=linspace(0.15, 0.35, 300);
% [dNdr]=lognorm(r,1,0.2575,0.05,1);
% filename='lognorm D=500 nm broad'


N_part=trapz(r,dNdr) %Total Number


dNdr=dNdr/N_part; %normalize to one particle/cm3

N=trapz(r,dNdr) %Total Number
dSdr=4*pi*r.^2.*dNdr; %Area

%define scattering angles
scat_angle=[0:0.25:180]; 
sinscatang_rad=sin(deg2rad(scat_angle));  %sin(theta) in radians
scatang_rad=deg2rad(scat_angle);    %scattering angles in radians

%ideal nephelometer
lambda=.690;
m=polystyrene(lambda); % PSL spheres
%m=n_air(lambda); % air
x=mie_par(r,lambda);
N=mie_test(x);
[Q_ext_ideal,Q_scat_ideal,a,b]=mie(x,m,N);

m=polystyrene(lambda); % PSL spheres
%m=1.0003; % air

[S11,S12]=phase2(a,b,x,N,scat_angle);
    
% no truncation or illumination correction
integ_ang=trapz(scatang_rad,repmat(sinscatang_rad, [length(x),1]).*S11,2);
integ_ang=squeeze(integ_ang);
Q_scat_test=2.*integ_ang./x.^2;

%Test if inegrated S11 is Q_scat
figure(3) 
subplot(2,1,1)
plot(r,Q_scat_ideal,r,Q_scat_test)     
subplot(2,1,2)
plot(r,Q_scat_ideal-Q_scat_test)     

i_ang=find(scat_angle >10 & scat_angle <170);
% truncation
integ_ang=trapz(scatang_rad(i_ang),repmat(sinscatang_rad(i_ang), [length(x),1]).*S11(:,i_ang),2);
integ_ang=squeeze(integ_ang);
Q_scat_trunc=2.*integ_ang./x.^2;
  
figure(4)
subplot(2,1,1)
plot(r,Q_scat_ideal,r,Q_scat_trunc)     
subplot(2,1,2)
plot(r,Q_scat_ideal./Q_scat_trunc)     
   
% scattering coefficient (with angular non-idealities)
y=pi.*r.^2.*Q_scat_trunc'.*dNdr;
scat_trunc=trapz(r',y');

% scattering coefficient for ideal nephelometer
y=pi.*r.^2.*Q_scat_ideal'.*dNdr;
scat_ideal=trapz(r',y');
scat_ideal_cum=cumtrapz(r',y');

%Correction factor
Kr=[1.0243];
scat_trunc=scat_trunc.*Kr
scat_ideal./scat_trunc


r_lognorm=linspace(0.2, 0.3, 200);
dNdr_lognorm=lognorm(r_lognorm,.04,0.2495,0.00325,1);
filename='lognorm D=500 nm NIST'

figure(2)
subplot(3,1,1)
plot(r,dNdr,r_lognorm,dNdr_lognorm);
title(filename)
subplot(3,1,2)
plot(r,dSdr,'-');
subplot(3,1,3)
plot(r,scat_ideal_cum./scat_ideal);