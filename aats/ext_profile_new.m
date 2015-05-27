clear
site='ACE-2'
day=17
month=7
year=1997
UT_start=18.49
UT_end=19.16

load d:\beat\data\ace-2\results\R17Jul97_izana_prof.asc;
r=R17Jul97_izana_prof(:,4)';
tau_aero=R17Jul97_izana_prof(:,8:20)';
close all
[n,m]=size(tau_aero);
  %        380.3  448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  1018.7 1059   1557.5	
wvl_plot= [1      0      0      1      0      0      0      0      0      1      0      0      1     ];

pp  = csaps(1:m,r,0.000015);
r_spline = fnval(pp,1:m);
dr_spline=fnval(fnder(pp),1:m);

pp  = csaps(1:m,tau_aero(wvl_plot==1,:),0.000015);
tau_aero_spline = fnval(pp,1:m);
dtau_aero_spline=fnval(fnder(pp),1:m);

[n,m]=size(dtau_aero_spline);
ext_coeff=-dtau_aero_spline./(ones(n,1)*dr_spline);

figure(10)
subplot(2,1,1)
plot(1:m,r-r_spline,'.')
xlabel('n')
ylabel('Altitude Residuals [km]')
grid on

subplot(2,1,2)
plot(1:m,tau_aero(wvl_plot==1,:)-tau_aero_spline,'.')
xlabel('n')
ylabel('AOD Residuals [cm]')
grid on

figure(11)
orient landscape
subplot(1,2,1)
plot(tau_aero(wvl_plot==1,:),r,'.',tau_aero_spline,r_spline,'k--')
legend('380.3 nm', '499.4 nm', '864.4 nm', '1557.5 nm')
xlabel('Aerosol Optical Depth','FontSize',14')
ylabel('Altitude [km]','FontSize',14)
grid on
title(sprintf('%s %2i.%2i.%2i %g-%g',site,day,month,year,UT_start,UT_end,'UT'),'FontSize',14);
axis([0 0.25 2.2 5.2])
set(gca,'FontSize',14)

subplot(1,2,2)
plot(ext_coeff,r)
xlabel('Aerosol Extinction (1/km)','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
axis([0 0.2 2.2 5.2])
set(gca,'FontSize',14)

%Lidar profile
subplot(1,2,2)
hold on
read_lidar_Izana
plot(Lidar_Aerosol_Ext,Lidar_Altitude,':');