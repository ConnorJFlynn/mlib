%This routine takes Composite Caltech Size Distributions plots them and
%computes Reff, Total Number, Surface Area, Volume, and Mass and cumulative distributions (S-curves)

clear all
load d:\beat\data\ace-2\caltech\SizeDistr_tf20_rev2.mat
load d:\beat\data\ace-2\caltech\SizeDistr_tf20_time.mat
load d:\beat\data\ace-2\caltech\SizeDistr_tf20_altitude.mat

% Applies for old version only
% the first 5 size bins are skipped because there are no measurements anyway
% the first 19 size bins need to be skipped because Mie-code won't work

D=SizeDistr_tf20_rev2(1,1:end)/1e9; %conversion from nanometer into meter
dNdlogDp=SizeDistr_tf20_rev2(6:5:36,1:end)*1e6; % conversion from cm-3 in m-3

%lambda=450 % MISU blue
%lambda=545 %nanometer in meter UW
%lambda=550 %nanometer in meter MISU red
lambda=565 %nanometer in meter PSAP
%lambda=700 %nanometer in meter Misu green

%select cases
dNdlogDp=dNdlogDp([1:4],:) %
%m=1.55-0.005i;%Sahara Dust used in inversion
m_imag=0.17*10^(-0.0025*lambda); %Sahara Dust used by Collins
m=1.55-m_imag*i

%dNdlogDp=dNdlogDp([5:7],:) %
%m=1.4-0.0035i; %MBL

lambda=lambda/1e9; %nanometer to meter


%COMPUTES Reff,SURFACE AREA, VOLUME AND MASS and cumulative distributions (S-curves)
[mm,nn]=size(dNdlogDp);
x=log10(D);
N=trapz(x',dNdlogDp')
N_cum=cumtrapz(x',dNdlogDp')./(ones(nn,1)*N);
y=(ones(mm,1)*D).^2.*dNdlogDp;
S=pi*trapz(x',y')
S_cum=pi*cumtrapz(x',y')./(ones(nn,1)*S);
y=(ones(mm,1)*D).^3.*dNdlogDp;
V=pi/6*trapz(x',y')
V_cum=pi/6*cumtrapz(x',y')./(ones(nn,1)*V);
R_eff=3*V./S
%this should be identical
%y=(ones(m,1)*D).*dNdlogDp;
%x=D;
%S=pi/log(10)*trapz(x',y')
%y=(ones(m,1)*D).^2.*dNdlogDp;
%V=pi/log(10)/6*trapz(x',y')

chi=mie_par(D/2,lambda);
NN=mie_test(chi)

%computes extinction
[Q_ext,Q_scat]=mie(chi,m,NN);
Q_abs=Q_ext-Q_scat;
figure(2)
plot(chi,Q_ext,chi,Q_scat,chi,Q_abs)

y=(ones(mm,1)*D).^2.*(ones(mm,1)*Q_ext').*dNdlogDp;
ext=pi/4*trapz(x',y')
ext_cum=pi/4*cumtrapz(x',y')./(ones(nn,1)*ext);
y=(ones(mm,1)*D).^2.*(ones(mm,1)*Q_scat').*dNdlogDp;
scat=pi/4*trapz(x',y')
scat_cum=pi/4*cumtrapz(x',y')./(ones(nn,1)*scat);
y=(ones(mm,1)*D).^2.*(ones(mm,1)*Q_abs').*dNdlogDp;
abs=pi/4*trapz(x',y');
abs_cum=pi/4*cumtrapz(x',y')./(ones(nn,1)*abs);

figure(1)
%orient landscape
subplot(3,1,1)
semilogx(D*1e6,dNdlogDp/1e6)
axis([3e-3 12 0.0001 inf])
title('In-Situ Size Distributions tf20 17. July 1997')
set(gca,'xtick',[0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 10 12]);
xlabel('D [µm]');
ylabel('dN/dlogD [cm-3]');
grid on

legend(...
   sprintf('%g-%gm ', Altitude(1,:)),...
   sprintf('%g-%gm ', Altitude(2,:)),...
   sprintf('%g-%gm ', Altitude(3,:)),... 
   sprintf('%g-%gm ', Altitude(4,:)),...
   sprintf('%g-%gm ', Altitude(5,:)),...
   sprintf('%g-%gm ', Altitude(6,:)),...
   sprintf('%g-%gm ', Altitude(7,:)))

subplot(3,1,2)
loglog(D*1e6,dNdlogDp/1e6)
axis([3e-3 12 0.0001 1e5])
set(gca,'xtick',[0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 10 12]);
xlabel('D [µm]');
ylabel('dN/dlogD [cm-3]');
grid on

subplot(3,1,3)
semilogx(D*1e6,N_cum)
axis([3e-3 12 0 1])
set(gca,'xtick',[0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 10 12]);
xlabel('D [µm]');
ylabel('Cumulative Number Contribution');
grid on


figure(3)
subplot(3,1,1)
semilogx(D*1e6,S_cum,'--')
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 12]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);
ylabel('Surface Area');
grid on
hold on

subplot(3,1,2)
semilogx(D*1e6,V_cum,'--')
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 12]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);
ylabel('Volume');
grid on
%legend(...
%   sprintf('%g-%gm ', Altitude(1,:)),...
%   sprintf('%g-%gm ', Altitude(2,:)),...
%   sprintf('%g-%gm ', Altitude(3,:)),... 
%   sprintf('%g-%gm ', Altitude(4,:)),...
%   sprintf('%g-%gm ', Altitude(5,:)),...
%   sprintf('%g-%gm ', Altitude(6,:)),...
%   sprintf('%g-%gm ', Altitude(7,:)))


%subplot(2,1,2)
%semilogx(D*1e6,ext_cum)
%axis([0.01 12 0 1])
%set(gca,'xtick',[0.005 0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 10]);
%xlabel('D [µm]');
%ylabel('Cumulative Extinction');
%grid on
hold on

subplot(3,1,3)
semilogx(D*1e6,scat_cum,'--')
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 12]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);
xlabel('D [µm]');
ylabel('Scattering');
grid on
legend(...
   sprintf('%g-%gm ', Altitude(1,:)),...
   sprintf('%g-%gm ', Altitude(2,:)),...
   sprintf('%g-%gm ', Altitude(3,:)),... 
   sprintf('%g-%gm ', Altitude(4,:)),...
   sprintf('%g-%gm ', Altitude(5,:)),...
   sprintf('%g-%gm ', Altitude(6,:)),...
   sprintf('%g-%gm ', Altitude(7,:)))
hold on

figure(4) %create nice plot
orient landscape
semilogx(D*1e6,scat_cum,'--')
axis([0.05 12 0 1])
set(gca,'xtick',[0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 12]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);
xlabel('D [µm]','FontSize',14);
ylabel('Normalized Cumulative Scattering Coefficient','FontSize',14);
grid on
legend(...
   sprintf('%g-%gm ', Altitude(1,:)),...
   sprintf('%g-%gm ', Altitude(2,:)),...
   sprintf('%g-%gm ', Altitude(3,:)),... 
   sprintf('%g-%gm ', Altitude(4,:)),...
   sprintf('%g-%gm ', Altitude(5,:)),...
   sprintf('%g-%gm ', Altitude(6,:)),...
   sprintf('%g-%gm ', Altitude(7,:)))
hold on
set(gca,'FontSize',14)

figure(5) %create nice plot
orient landscape
semilogx(D*1e6,abs_cum,'-')
axis([0.05 12 0 1])
set(gca,'xtick',[0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 12]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);
xlabel('D [µm]','FontSize',14);
ylabel('Normalized Cumulative Absorption Coefficient','FontSize',14);
grid on
legend(...
   sprintf('%g-%gm ', Altitude(1,:)),...
   sprintf('%g-%gm ', Altitude(2,:)),...
   sprintf('%g-%gm ', Altitude(3,:)),... 
   sprintf('%g-%gm ', Altitude(4,:)),...
   sprintf('%g-%gm ', Altitude(5,:)),...
   sprintf('%g-%gm ', Altitude(6,:)),...
   sprintf('%g-%gm ', Altitude(7,:)))
hold on
set(gca,'FontSize',14)

figure(6) %create nice plot
orient landscape
semilogx(D*1e6,ext_cum,'-')
axis([0.05 12 0 1])
set(gca,'xtick',[0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 8 12]);
set(gca,'ytick',[0 0.2 0.4 0.6 0.8 1]);
xlabel('D [µm]','FontSize',14);
ylabel('Normalized Cumulative Extinction Coefficient','FontSize',14);
grid on
legend(...
   sprintf('%g-%gm ', Altitude(1,:)),...
   sprintf('%g-%gm ', Altitude(2,:)),...
   sprintf('%g-%gm ', Altitude(3,:)),... 
   sprintf('%g-%gm ', Altitude(4,:)),...
   sprintf('%g-%gm ', Altitude(5,:)),...
   sprintf('%g-%gm ', Altitude(6,:)),...
   sprintf('%g-%gm ', Altitude(7,:)))
hold on
set(gca,'FontSize',14)
