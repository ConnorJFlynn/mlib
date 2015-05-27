pp  = csaps(UT,r,0.9999);
r_spline = fnval(pp,UT);
dr_spline=fnval(fnder(pp),UT);

pp  = csaps(UT,ozone*1000,0.99);
ozone_spline = fnval(pp,UT);
dozone_spline=fnval(fnder(pp),UT);

ozone_dens=-dozone_spline./dr_spline;
trapz(r,ozone_dens)

figure(10)
subplot(2,1,1)
plot(UT,r-r_spline,'.')
xlabel('UT')
ylabel('Altitude Residuals [km]')
grid on

subplot(2,1,2)
plot(UT,ozone*1000-ozone_spline,'.')
xlabel('UT')
ylabel('Ozone Residuals [cm]')
grid on

figure(11)
subplot(1,2,1)
plot(ozone*1000,r,'.',ozone_spline,r_spline)
xlabel('Columnar Ozone [DU]')
ylabel('Altitude')
grid on
title(sprintf('%s %2i.%2i.%2i %g-%g',site,day,month,year,UT_start,UT_end,' UT'));

subplot(1,2,2)
plot(ozone_dens,r)
xlabel('Ozone Density [DU/km]')
ylabel('Altitude')
grid on



