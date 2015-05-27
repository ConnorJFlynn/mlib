clear all
close all

load c:\beat\king\R17Aug00smoke  %Smoke+bg

%taup_meas; % measured AOD
%unc_taup_meas; % uncertainty of measured AOD
%lambda
%r_max;
%r_min;
%radcalc %radii
%rg_coarse 
%dndlgrsav(:,nu,nitermax) %dNdlogr
%dnlgrsv(:,nu,nitermax)   %dNdlogr coarse
%uncdnlgrsv(:,nu,nitermax)%dNdlogr_unc_coarse
%dSdlgrsav(:,nu,nitermax) %dSdlogr
%dSlgrsv(:,nu,nitermax)   %dSdlogr coarse

wvl_min=0.3; wvl_max=1.6;   
taup_min=0.01; taup_max=4;
rad_min=.05; rad_max=4;
dndlgr_min=1E+03 ; dndlgr_max=1E+12;
dSdlgr_min=1E+02; dSdlgr_max=1E+11;

figure(1)
subplot(1,2,1)
loglog(lambda,taup_meas,'ro','Markerfacecolor','r')
hold on
yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'ro')
loglog(lambda,taunumint(:,nitermax,1),'r-')
loglog(lambda,taunumint(:,nitermax,2),'r-')
loglog(lambda,taunumint(:,nitermax,3),'r-')
subplot(1,2,2)
loglog(radcalc,dndlgrsav(:,1,nitermax),'r')
hold on
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,1,nitermax),uncdnlgrsv(:,1,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,1,nitermax),'r*')
loglog(radcalc,dndlgrsav(:,2,nitermax),'r')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,2,nitermax),uncdnlgrsv(:,2,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,2,nitermax),'r*')
loglog(radcalc,dndlgrsav(:,3,nitermax),'r')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,3,nitermax),uncdnlgrsv(:,3,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,3,nitermax),'r*')

figure(2)
subplot(1,2,1)
loglog(lambda,taup_meas,'ro','Markerfacecolor','r')
hold on
yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'ro')
loglog(lambda,taunumint(:,nitermax,1),'r-')
loglog(lambda,taunumint(:,nitermax,2),'r-')
loglog(lambda,taunumint(:,nitermax,3),'r-')
subplot(1,2,2)
loglog(radcalc,dSdlgrsav(:,1,nitermax),'r')
hold on
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,1,nitermax),uncdSlgrsv(:,1,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,1,nitermax),'r*')
loglog(radcalc,dSdlgrsav(:,2,nitermax),'r')
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,2,nitermax),uncdSlgrsv(:,2,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,2,nitermax),'r*')
loglog(radcalc,dSdlgrsav(:,3,nitermax),'r')
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,3,nitermax),uncdSlgrsv(:,3,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,3,nitermax),'r*')


load c:\beat\king\R17Aug00plume

wvl_min=0.3; wvl_max=1.6;   
taup_min=0.01; taup_max=4;
rad_min=.05; rad_max=4;
dndlgr_min=1E+03 ; dndlgr_max=1E+12;
dSdlgr_min=1E+02; dSdlgr_max=1E+11;


figure(1)
subplot(1,2,1)
loglog(lambda,taup_meas,'go','Markerfacecolor','g')
yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'go')
loglog(lambda,taunumint(:,nitermax,1),'g-')
loglog(lambda,taunumint(:,nitermax,2),'g-')
loglog(lambda,taunumint(:,nitermax,3),'g-')

subplot(1,2,2)

loglog(radcalc,dndlgrsav(:,1,nitermax),'g')
hold on
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,1,nitermax),uncdnlgrsv(:,1,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,1,nitermax),'g*')

loglog(radcalc,dndlgrsav(:,2,nitermax),'g')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,2,nitermax),uncdnlgrsv(:,2,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,2,nitermax),'g*')

loglog(radcalc,dndlgrsav(:,3,nitermax),'g')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,3,nitermax),uncdnlgrsv(:,3,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,3,nitermax),'g*')


figure(2)
subplot(1,2,1)
loglog(lambda,taup_meas,'go','Markerfacecolor','g')
hold on
yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'g')
loglog(lambda,taunumint(:,nitermax,1),'g-')
loglog(lambda,taunumint(:,nitermax,2),'g-')
loglog(lambda,taunumint(:,nitermax,3),'g-')
subplot(1,2,2)
loglog(radcalc,dSdlgrsav(:,1,nitermax),'g')
hold on
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,1,nitermax),uncdSlgrsv(:,1,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,1,nitermax),'g*')
loglog(radcalc,dSdlgrsav(:,2,nitermax),'g')
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,2,nitermax),uncdSlgrsv(:,2,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,2,nitermax),'g*')
loglog(radcalc,dSdlgrsav(:,3,nitermax),'g')
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,3,nitermax),uncdSlgrsv(:,3,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,3,nitermax),'g*')



load c:\beat\king\R17Aug00bg
wvl_min=0.3; wvl_max=1.6;   
taup_min=0.01; taup_max=4;
rad_min=.05; rad_max=4;
dndlgr_min=1E+03 ; dndlgr_max=1E+12;
dSdlgr_min=1E+02; dSdlgr_max=1E+11;

figure(1)
subplot(1,2,1)
loglog(lambda,taup_meas,'bo','Markerfacecolor','b')
yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'bo')
loglog(lambda,taunumint(:,nitermax,1),'b-')
loglog(lambda,taunumint(:,nitermax,2),'b-')
loglog(lambda,taunumint(:,nitermax,3),'b-')
set(gca,'XLim',[wvl_min wvl_max],'YLim',[0.01 4])
set(gca,'XTick',[0.3:0.1:1.6],'FontSize',14);
set(gca,'XTickLabel',['0.3';'0.4';'0.5';'0.6';'0.7';'0.8';'   ';'1.0';'   ';'1.2';'   ';'1.4';'   ';'1.6'],'FontSize',14);
xlabel('Wavelength [\mum]');
ylabel('AOD');

subplot(1,2,2)

loglog(radcalc,dndlgrsav(:,1,nitermax),'b')
hold on
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,1,nitermax),uncdnlgrsv(:,1,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,1,nitermax),'b*')

loglog(radcalc,dndlgrsav(:,2,nitermax),'b')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,2,nitermax),uncdnlgrsv(:,2,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,2,nitermax),'b*')

loglog(radcalc,dndlgrsav(:,3,nitermax),'b')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dndlgr_max,rg_coarse,dnlgrsv(:,3,nitermax),uncdnlgrsv(:,3,nitermax),'r*')
loglog(rg_coarse,dnlgrsv(:,3,nitermax),'b*')
set(gca,'XLim',[0.04 5],'FontSize',14)
xlabel('Radius (\mum)');
ylabel('dN_c/dlogr (cm^{-2})');

hold off


figure(2)
subplot(1,2,1)
loglog(lambda,taup_meas,'bo','Markerfacecolor','b')
yerrorbar('loglog',wvl_min,wvl_max,taup_min,taup_max,lambda,taup_meas,unc_taup_meas,'bo')
loglog(lambda,taunumint(:,nitermax,1),'b-')
loglog(lambda,taunumint(:,nitermax,2),'b-')
loglog(lambda,taunumint(:,nitermax,3),'b-')
set(gca,'XLim',[wvl_min wvl_max],'YLim',[0.01 4])
set(gca,'XTick',[0.3:0.1:1.6],'FontSize',14);
set(gca,'XTickLabel',['0.3';'0.4';'0.5';'0.6';'0.7';'0.8';'   ';'1.0';'   ';'1.2';'   ';'1.4';'   ';'1.6'],'FontSize',14);
xlabel('Wavelength [\mum]');
ylabel('AOD');

subplot(1,2,2)

loglog(radcalc,dSdlgrsav(:,1,nitermax),'b')
hold on
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dndlgr_max,rg_coarse,dSlgrsv(:,1,nitermax),uncdSlgrsv(:,1,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,1,nitermax),'b*')

loglog(radcalc,dSdlgrsav(:,2,nitermax),'b')
%yerrorbar('loglog',r_min,r_max,dndlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,2,nitermax),uncdSlgrsv(:,2,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,2,nitermax),'b*')

loglog(radcalc,dSdlgrsav(:,3,nitermax),'b')
%yerrorbar('loglog',r_min,r_max,dSdlgr_min,dSdlgr_max,rg_coarse,dSlgrsv(:,3,nitermax),uncdSlgrsv(:,3,nitermax),'r*')
loglog(rg_coarse,dSlgrsv(:,3,nitermax),'b*')
set(gca,'XLim',[0.04 5],'FontSize',14)
xlabel('Radius (\mum)');
ylabel('dS_c/dlogr (\mum^{2} cm^{-2})');

hold off