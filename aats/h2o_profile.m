%Computes Water Vapor Density Profiles by differentiating dU/dz

% smoothing altitude and differenting dz/dt
pp  = csaps(UT(L_H2O==1 & L_dist ==1),r(L_H2O==1 & L_dist ==1),H2O_smoothing_para);
r_spline = fnval(pp,UT(L_H2O==1 & L_dist ==1));
dr_spline=fnval(fnder(pp),UT(L_H2O==1 & L_dist ==1));

% smoothing altitude and differenting dU/dt
pp  = csaps(UT(L_H2O==1 & L_dist ==1),U(L_H2O==1 & L_dist ==1)/H2O_conv,H2O_smoothing_para);
U_spline = fnval(pp,UT(L_H2O==1 & L_dist ==1));
dU_spline=fnval(fnder(pp),UT(L_H2O==1 & L_dist ==1));

H2O_dens=-dU_spline./dr_spline*10;
trapz(r(L_H2O==1 & L_dist ==1),H2O_dens)

figure(23)
orient landscape
subplot(2,1,1)
plot(UT(L_H2O==1 & L_dist ==1),r(L_H2O==1 & L_dist ==1)-r_spline,'.')
xlabel('UT')
ylabel('Altitude Residuals [km]')
grid on

subplot(2,1,2)
plot(UT(L_H2O==1 & L_dist ==1),U(L_H2O==1 & L_dist ==1)/H2O_conv-U_spline,'.')
xlabel('UT')
ylabel('Columnar Water Vapor Residuals [cm]')
grid on

figure(24)
orient landscape
subplot(1,2,1)
plot(U(L_H2O==1 & L_dist ==1)/H2O_conv,r(L_H2O==1 & L_dist ==1),'.',U_spline,r_spline,'k--')
xlabel('Columnar Water Vapor [g/cm^2]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
axis([0 1.5 0 4])
set(gca,'FontSize',14)

subplot(1,2,2)
plot(H2O_dens,r(L_H2O==1 & L_dist ==1))
xlabel('Water Vapor Density [g/m^3]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);
axis([0 10 0 4])
set(gca,'FontSize',14)

%write to file
if strcmp(Result_File,'ON')
  if strcmp(instrument,'AMES14#1')
   resultfile=[filename '.h2o_prof.asc']
   fid=fopen([path resultfile],'w');
   fprintf(fid,'%s\n','NASA Ames Airborne Sunphotometer, 14 channel, unit #1');
   fprintf(fid,'%s %2i.%2i.%4i\n', site,day,month,year);
   fprintf(fid,'%s %s %s\n', 'Date processed:',date, 'by Beat Schmid, Revision 1.1');
   fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
   fprintf(fid,'%s\n','UT,Lat,Long,Altitude[km],p[hPa],H2O[cm],O3[DU],H2ODens[g/m3],H2O Error[cm]');
   fprintf(fid,'%7.4f %8.4f %8.4f %7.3f %7.2f %7.4f %5.1f %7.4f %7.4f\n',...
    [UT',geog_lat',geog_long',r',press,U'/H2O_conv,ozone'*1000,H2O_dens',H2O_err']');
   fclose(fid);
 end
end