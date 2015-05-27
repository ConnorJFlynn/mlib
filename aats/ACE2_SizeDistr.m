%This routine plots results of Call_CLI and Caltech

%lambda: wavelengths used for inversion
%taup_meas: measured tau or extinction;
%unc_taup_meas= uncertainty in measured tau or extinction;
%r_max, r_min : max and min radius used in inversion
%date_text : some text explaining the case
%refrac_idx: complex refractive index
%n_coarse_rad_bin: number of coarse radii bins
%nustar(3)= 3 different Junge Parameter values
%nitermax=maximum number of integrations
%rg_coarse(n_coarse_rad_bin,nitermax): Coarse radii bins, 
%dnlgrsv(n_coarse_rad_bin,nustar,nitermax):  dNdlog10R at the coarse bins 
%uncdnlgrsv(n_coarse_rad_bin,nustar,nitermax): Uncertainty of dNdlog10R at the coarse bins
%radcalc(n_coarse_rad_bin+2): radii with two endpoints
%dndlgrsav(radcalc,nustar,nitermax)):dNdlog10R at radcalc

clear all
close all
load d:\beat\data\ace-2\caltech\SizeDistr_tf20_rev2.mat
load d:\beat\data\ace-2\caltech\SizeDistr_tf20_time.mat
load d:\beat\data\ace-2\caltech\SizeDistr_tf20_altitude.mat

D_Caltech=SizeDistr_tf20_rev2(1,:)/1e9; %conversion from nanometer into meter
dNdlogDp=SizeDistr_tf20_rev2(6:5:36,:)*1e6; % conversion from cm-3 in m-3


%dNdlogD_Caltech=dNdlogDp(3,:); % 3 is Dust 6 is MBL
dNdlogD_Caltech=dNdlogDp(6,:); % 3 is Dust 6 is MBL

%dNdlogD_Caltech_err=23 %percent Dust
dNdlogD_Caltech_err=15 % percent MBL
D_Caltech_err=5 % percent MBL and Dust
dSdlogD_Caltech_err= sqrt((2*D_Caltech_err)^2+(dNdlogD_Caltech_err)^2);

close all
%load d:\beat\king\R17Jul97Dust
load d:\beat\king\R17Jul97MBL

%Remer Modes
%Remer_modes=[0 0.0036 0.1046 0]  %Dust
Remer_modes=[0 0.0070 0.0222 0]  %MBL

[dummy,nwvl]=size(lambda);

%convert to SI units and Diameters
taup_meas=taup_meas/1e3;
unc_taup_meas=unc_taup_meas/1e3;
lambda=lambda/1e6;
D_max=r_max*2/1e6;
D_min=r_min*2/1e6;
D_AATS14=radcalc*2/1e6;
dNdlogD_AATS14=dndlgrsav(:,2,nitermax)'/1e5*1e6; % 1km =10^5 cm
D_coarse_AATS14=rg_coarse*2/1e6;
dNdlogD_coarse_AATS14=dnlgrsv(:,2,nitermax)/1e5*1e6;
dNdlogD_unc_coarse_AATS14=uncdnlgrsv(:,2,nitermax)/1e5*1e6;

%interpolates AATS-14 and Caltech SizeDistr at fine bins
N_bins=200;
D_fine_AATS14=logspace(log10(D_min)+1e-10,log10(D_max)-1e-10,N_bins);
dNdlogD_fine_AATS14=10.^interp1(log10(D_AATS14),log10(dNdlogD_AATS14),log10(D_fine_AATS14));
dNdlogD_unc_fine_AATS14=10.^interp1(log10(D_coarse_AATS14),log10(dNdlogD_unc_coarse_AATS14),log10(D_fine_AATS14),'nearest');

%D_fine_Caltech=logspace(log10(min(D_Caltech)),log10(max(D_Caltech)),N_bins);
D_fine_Caltech=logspace(min(log10(D_Caltech)),max(log10(D_Caltech)),N_bins);

dNdlogD_fine_Caltech=10.^interp1(log10(D_Caltech),log10(dNdlogD_Caltech),log10(D_fine_Caltech));
dNdlogD_fine_Caltech(isnan(dNdlogD_fine_Caltech))=0;


figure(1)
%Number Size Distribution
loglog(D_AATS14*1e6,dNdlogD_AATS14/1e6)
hold on
%loglog(D_fine_AATS14*1e6,dNdlogD_fine_AATS14/1e6,'r.')
%loglog(D_fine_AATS14*1e6,(dNdlogD_fine_AATS14+dNdlogD_unc_fine_AATS14)/1e6,'-')
%loglog(D_fine_AATS14*1e6,(dNdlogD_fine_AATS14-dNdlogD_unc_fine_AATS14)/1e6,'-')
loglog(D_Caltech*1e6,dNdlogD_Caltech/1e6,'r.-')
loglog(D_Caltech*1e6,dNdlogD_Caltech/1e6*(1+dNdlogD_Caltech_err/100),'r:',D_Caltech*1e6,dNdlogD_Caltech/1e6/(1+dNdlogD_Caltech_err/100),'r:')
yerrorbar('loglog',1e-3, 10 ,1e-4, 1e5, D_coarse_AATS14*1e6,dNdlogD_coarse_AATS14/1e6,dNdlogD_unc_coarse_AATS14/1e6,'o')
hold off
title(date_text)
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2.5 5 10]);
xlabel('D [\mum]','FontSize',14);
ylabel('dN/dlogD [cm-3]','FontSize',14);
axis([9e-3 12 1e-4 1e5])
legend('AATS-14','Caltech OPC')
set(gca,'xgrid','on')
set(gca,'FontSize',14)

figure(2)
%Area Size Distribution
dSdlogD_unc_coarse_AATS14=pi*D_coarse_AATS14.^2.*dNdlogD_unc_coarse_AATS14;
dSdlogD_coarse_AATS14=pi*D_coarse_AATS14.^2.*dNdlogD_coarse_AATS14;
dSdlogD_AATS14=pi*D_AATS14.^2.*dNdlogD_AATS14;
dSdlogD_Caltech=pi*D_Caltech.^2.*dNdlogD_Caltech;
semilogx(D_AATS14*1e6,dSdlogD_AATS14*1e6,'-')
hold on
semilogx(D_Caltech*1e6,dSdlogD_Caltech*1e6,'r.-')
semilogx(D_Caltech*1e6,dSdlogD_Caltech*1e6*(1+dSdlogD_Caltech_err/100),'r--',D_Caltech*1e6,dSdlogD_Caltech*1e6/(1+dSdlogD_Caltech_err/100),'r--')
yerrorbar('semilogx',0.01, 12 ,0, 600, D_coarse_AATS14*1e6,dSdlogD_coarse_AATS14*1e6,dSdlogD_unc_coarse_AATS14*1e6,'o')
hold off
title(date_text)
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2 4 8 12]);
xlabel('D [\mum]','FontSize',14);
ylabel('dS/dlogD [\mum^2 cm^{-3}]','FontSize',14);
grid on
axis([1e-2 12 0 450])% Dust
%axis([1e-2 12 0 550])% MBL
legend('AATS-14','Caltech OPC')
set(gca,'xgrid','on')
set(gca,'FontSize',14)

figure(3)
%Area Size Distribution with Remer
dVdlnr=dVdlnr_lognorm_remer(D_fine_Caltech/2*1e6,Remer_modes)
%loglog(D_fine_Caltech*1e6/2,dVdlnr)
%computes extinction for Remer
%chi=mie_par(D_fine_Caltech/2,lambda);
%NN=mie_test(chi);
%[Q_ext,Q_scat]=mie(chi,refrac_idx,NN);
%[mm,nn]=size(Q_ext);
%x=log(D_fine_Caltech/2*1e6);
%y=Q_ext'./(ones(nn,1)*D_fine_Caltech*1e6/2).*(ones(nn,1)*dVdlnr);
%ext_Remer=3/4*trapz(x',y')
dSdlogD_Remer=1e3*log(10)*3*dVdlnr./(D_fine_Caltech/2*1e6);

dSdlogD_unc_coarse_AATS14=pi*D_coarse_AATS14.^2.*dNdlogD_unc_coarse_AATS14;
dSdlogD_coarse_AATS14=pi*D_coarse_AATS14.^2.*dNdlogD_coarse_AATS14;
dSdlogD_AATS14=pi*D_AATS14.^2.*dNdlogD_AATS14;
dSdlogD_Caltech=pi*D_Caltech.^2.*dNdlogD_Caltech;
semilogx(D_AATS14*1e6,dSdlogD_AATS14*1e6,'-')
hold on
semilogx(D_fine_Caltech*1e6,dSdlogD_Remer,'g')
semilogx(D_Caltech*1e6,dSdlogD_Caltech*1e6,'r.-')
semilogx(D_Caltech*1e6,dSdlogD_Caltech*1e6*(1+dSdlogD_Caltech_err/100),'r--',D_Caltech*1e6,dSdlogD_Caltech*1e6/(1+dSdlogD_Caltech_err/100),'r--')
yerrorbar('semilogx',0.01, 12 ,0, 600, D_coarse_AATS14*1e6,dSdlogD_coarse_AATS14*1e6,dSdlogD_unc_coarse_AATS14*1e6,'o')
hold off
title(date_text)
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2 4 8 12]);
xlabel('D [\mum]','FontSize',14);
ylabel('dS/dlogD [\mum^2 cm^{-3}]','FontSize',14);
grid on
%axis([1e-2 12 0 700])% Dust
axis([1e-2 12 0 550])% MBL
legend('AATS-14 King','AATS-14 Remer','Caltech OPC')
set(gca,'xgrid','on')
set(gca,'FontSize',14)




figure (4)
loglog(D_AATS14*1e6,dSdlogD_AATS14*1e6)
hold on
loglog(D_Caltech*1e6,dSdlogD_Caltech*1e6,'g.-')
loglog(D_Caltech*1e6,dSdlogD_Caltech*1e6*(1+dSdlogD_Caltech_err/100),'g--',D_Caltech*1e6,dSdlogD_Caltech*1e6/(1+dSdlogD_Caltech_err/100),'g--')
yerrorbar('loglog',1e-3, 10 ,1e-4, 1e3, D_coarse_AATS14*1e6,dSdlogD_coarse_AATS14*1e6,dSdlogD_unc_coarse_AATS14*1e6,'o')
hold off
%title(date_text)
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2.5 5 10]);
xlabel('D [\mum]','FontSize',14);
ylabel('dS/dlogD [\mum^2 cm^{-3}]','FontSize',14);
axis([9e-3 12 1e-4 600])
legend('AATS-14','Caltech OPC')
set(gca,'xgrid','on')
set(gca,'FontSize',14)

%COMPUTES Reff,SURFACE AREA, VOLUME and cumulative distributions (S-curves) for AATS-14
% used for error analysis
%dNdlogD_fine_AATS14=dNdlogD_fine_AATS14-dNdlogD_unc_fine_AATS14;
%dNdlogD_fine_AATS14(dNdlogD_fine_AATS14<0)=0
[mm,nn]=size(dNdlogD_fine_AATS14);
x=log10(D_fine_AATS14);
N_AATS14=trapz(x',dNdlogD_fine_AATS14')
N_cum=cumtrapz(x',dNdlogD_fine_AATS14')./(ones(nn,1)*N_AATS14);
y=(ones(mm,1)*D_fine_AATS14).^2.*dNdlogD_fine_AATS14;
S_AATS14=pi*trapz(x',y')
S_cum=pi*cumtrapz(x',y')./(ones(nn,1)*S_AATS14);
y=(ones(mm,1)*D_fine_AATS14).^3.*dNdlogD_fine_AATS14;
V_AATS14=pi/6*trapz(x',y')
V_cum=pi/6*cumtrapz(x',y')./(ones(nn,1)*V_AATS14);
R_eff_AATS14=3*V_AATS14./S_AATS14

%COMPUTES Reff,SURFACE AREA, VOLUME and cumulative distributions (S-curves) for Caltech

% used for error analysis
%D_Caltech=D_Caltech*1.05;
%dNdlogD_Caltech=dNdlogD_Caltech*(1+dNdlogD_Caltech_err/100);

[mm,nn]=size(dNdlogD_fine_Caltech);
x=log10(D_fine_Caltech);
N_Caltech=trapz(x',dNdlogD_fine_Caltech')
N_cum=cumtrapz(x',dNdlogD_fine_Caltech')./(ones(nn,1)*N_Caltech);
y=(ones(mm,1)*D_fine_Caltech).^2.*dNdlogD_fine_Caltech;
S_Caltech=pi*trapz(x',y')
S_cum=pi*cumtrapz(x',y')./(ones(nn,1)*S_Caltech);
y=(ones(mm,1)*D_fine_Caltech).^3.*dNdlogD_fine_Caltech;
V_Caltech=pi/6*trapz(x',y')
V_cum=pi/6*cumtrapz(x',y')./(ones(nn,1)*V_Caltech);
R_eff_Caltech=3*V_Caltech./S_Caltech


%computes extinction for AATS-14
chi=mie_par(D_fine_AATS14/2,lambda);
NN=mie_test(chi)
[Q_ext,Q_scat]=mie(chi,refrac_idx,NN);
[mm,nn]=size(Q_ext);
x=log10(D_fine_AATS14);
y=(ones(nn,1)*D_fine_AATS14).^2.*Q_ext'.*(ones(nn,1)*dNdlogD_fine_AATS14);
ext_AATS14=pi/4*trapz(x',y')
ext_cum=pi/4*cumtrapz(x',y')./(ones(mm,1)*ext_AATS14);
y=(ones(nn,1)*D_fine_AATS14).^2.*Q_scat'.*(ones(nn,1)*dNdlogD_fine_AATS14);
scat_AATS14=pi/4*trapz(x',y')
scat_cum=pi/4*cumtrapz(x',y')./(ones(mm,1)*scat_AATS14);
SSA_AATS14=scat_AATS14./ext_AATS14;

%computes extinction for Caltech
chi=mie_par(D_fine_Caltech/2,lambda);
NN=mie_test(chi);
[Q_ext,Q_scat]=mie(chi,refrac_idx,NN);
[mm,nn]=size(Q_ext);
x=log10(D_fine_Caltech);
y=(ones(nn,1)*D_fine_Caltech).^2.*Q_ext'.*(ones(nn,1)*dNdlogD_fine_Caltech);
ext_Caltech=pi/4*trapz(x',y')
ext_cum_Caltech=pi/4*cumtrapz(x',y')./(ones(mm,1)*ext_Caltech);
y=(ones(nn,1)*D_fine_Caltech).^2.*Q_scat'.*(ones(nn,1)*dNdlogD_fine_Caltech);
scat_Caltech=pi/4*trapz(x',y')
scat_cum_Caltech=pi/4*cumtrapz(x',y')./(ones(mm,1)*scat_Caltech);
SSA_Caltech=scat_Caltech./ext_Caltech;

%create plots
%extinction
figure(5)
loglog(lambda*1e6,taup_meas*1e3,'mo');
hold on
loglog(lambda*1e6,ext_AATS14*1e3,'b-o')
loglog(lambda*1e6,ext_Caltech*1e3,'g-*')
yerrorbar('loglog',0.3,1.6, -inf, inf,lambda*1e6,taup_meas*1e3,unc_taup_meas*1e3,'mo')
hold off
set(gca,'xlim',[.300 1.60]);
%set(gca,'ylim',[0.1 0.2]);
%set(gca,'ytick',[0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 .2]);
set(gca,'ylim',[0.01 0.1]);
set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
xlabel('Wavelength [\mum]');
ylabel('Extinction [1/km]')
title(date_text)
legend('AATS-14 meas','AATS-14 calc.','Caltech calc.')
grid on

stop
%Number and Surface
figure(3)
orient landscape
subplot(3,1,1)
semilogx(D_fine_AATS14*1e6,N_cum)
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2.5 5 10]);
xlabel('D [\mum]');
ylabel('Cumulative Number Contribution');
title(date_text)
grid on

subplot(3,1,2)
semilogx(D_fine_AATS14*1e6,S_cum)
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2.5 5 10]);
xlabel('D [\mum]');
ylabel('Cumulative Surface Area Contribution');
grid on

subplot(3,1,3)
semilogx(D_fine_AATS14*1e6,V_cum)
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 2.5 5 10]);
xlabel('D [\mum]');
ylabel('Cumulative Mass Contribution');
grid on

%Cumulative Extinction
figure(4)
orient landscape
subplot(2,1,1)
semilogx(D_fine_AATS14*1e6,ext_cum)
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 1.5  2.2 3 5 10]);
xlabel('D [\mum]');
ylabel('Cumulative Extinction');
title(date_text)
grid on

subplot(2,1,2)
semilogx(D_fine_AATS14*1e6,scat_cum)
axis([0.01 12 0 1])
set(gca,'xtick',[0.01 0.02 0.05 0.1 0.2 0.5 1 1.5 2.2 3 5 10]);
xlabel('D [\mum]');
ylabel('Cumulative Scattering');
grid on


%Single Scatter Albedo
figure(5)
plot(lambda*1e6,SSA_AATS14,lambda*1e6,SSA_Caltech)
set(gca,'xlim',[.300 1.60]);
set(gca,'ylim',[0.7 1]);
%set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ytick',[0.7 0.8 0.9 1]);
xlabel('Wavelength [\mum]');
ylabel('SSA')
title(date_text)
grid on
legend('AATS-14','Caltech')
