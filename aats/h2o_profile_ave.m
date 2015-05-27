%Computes Water Vapor Density Profiles by differentiating dU/dz
%but uses averages at bins

zbot=min(r(L_H2O==1 & L_dist ==1))-deltaz/2;
ztop=max(r(L_H2O==1 & L_dist ==1))+deltaz/2;

%averaging and binning
[U_mean,H2O_err_mean,U_std,r_mean,UT_mean,H2O_dens_is_mean,GPS_Alt_mean,Press_Alt_mean,press_mean,geog_lat_mean,geog_long_mean]= ...
    avg_h2oprofile(U(L_H2O==1 & L_dist ==1)/H2O_conv,...
    H2O_err(L_H2O==1 & L_dist ==1),...
    r(L_H2O==1 & L_dist ==1),...
    UT(L_H2O==1 & L_dist ==1),...
    zbot,ztop,deltaz,...
    H2O_dens_is(L_H2O==1 & L_dist ==1),...
    GPS_Alt(L_H2O==1 & L_dist ==1),...
    Press_Alt(L_H2O==1 & L_dist ==1),...
    press(L_H2O==1 & L_dist ==1),...
    geog_lat(L_H2O==1 & L_dist ==1),...
    geog_long(L_H2O==1 & L_dist ==1));

%smoothing U and differenting dU/dz
pp  = csaps(r_mean,U_mean,H2O_smoothing_para);
U_spline = fnval(pp,r_mean);
H2O_dens=-fnval(fnder(pp),r_mean)*10;;

% calculate h2o density errors
figure(27)
subplot(2,3,1)
plot(geog_long_mean,geog_lat_mean,'.-')
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
set(gca,'FontSize',14)
grid on
axis square

subplot(2,3,2)
rng=distance(ones(1,length(geog_lat_mean))*geog_lat_mean(1),ones(1,length(geog_long_mean))*geog_long_mean(1),geog_lat_mean,geog_long_mean);
rng=deg2km(rng);
plot(rng,r_mean,'.')
xlabel('Distance','FontSize',14)
ylabel('GPS Alt','FontSize',14)
set(gca,'FontSize',14)
grid on

dz=[];dx=[];
for k=(length(r_mean)-1):-1:1
   dz(k) = r_mean(k+1) - r_mean(k);   %this works because r_mean is in ascending order
   dx(k) = deg2km(distance(geog_lat_mean(k+1),geog_long_mean(k+1),geog_lat_mean(k),geog_long_mean(k)));
end

subplot(2,3,3)
plot(dx,r_mean(2:end),dz,r_mean(2:end))

subplot(2,3,4)
g=[0.0056]; %Average for ACE-Asia excluding short legs.

H2O_dens_err=abs(g.*dx.*U_mean(2:end)./dz)*10;
plot(H2O_dens_err,r_mean(2:end),'.')

%remove unrealistic errors and fill in with nearest neighbors
x=H2O_dens_err;
y=r_mean(2:end);

i=find(x~=0); %remove errors that are 0 because dx is 0
x=x(i);
y=y(i);

while max(abs(x))>mean(x)+4*std(x) %remove errors that are large because of very small dx 
    i=find(abs(x)<max (abs(x)));
    x=x(i);
    y=y(i);
end
H2O_dens_err=interp1(y,x,r_mean,'nearest','extrap');
subplot(2,3,5)
plot(H2O_dens_err,r_mean,'.')


figure(25)
plot(r_mean,U_mean-U_spline,'.')
xlabel('UT')
ylabel('Columnar Water Vapor Residuals [cm]')
grid on

figure(26)
orient landscape
subplot(1,2,1)
plot(U_spline,r_mean,'k--')
hold on
xerrorbar('linlin',-inf, inf, -inf, inf, U_mean, r_mean, H2O_err_mean,'.')
hold off
xlabel('Columnar Water Vapor [g/cm^2]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
axis([0 5 0 7.5])
set(gca,'FontSize',14)

subplot(1,2,2)
xerrorbar('linlin',-inf, inf, -inf, inf, H2O_dens, r_mean, H2O_dens_err,'.')
xlabel('Water Vapor Density [g/m^3]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);
axis([-0.5 20 0 7.5])
set(gca,'FontSize',14)

if strcmp(source,'Laptop_Otter') | strcmp(source,'Can')
    hold on
    plot(H2O_dens_is,r,'g');
    plot(H2O_dens_is_mean,r_mean,'g.');
    hold off
    legend('','AATS-14','','In situ')
end

if strcmp(Result_File,'ON')
    if strcmp(site,'ACE-Asia') | strcmp(site,'Aerosol IOP') | strcmp(site,'ALIVE')
        resultfile=['AATS14_' filename '.h2o_prof.asc']
        fid=fopen([data_dir resultfile],'w');
        fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
        fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
        fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 2.0');
        fprintf(fid,'%s %g\r\n',    'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
        fprintf(fid,'%s %g\r\n',    'O3 [DU]:',1000*O3_col_start);
        fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
        fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
        fprintf(fid,'%s %g\r\n',    'Max m_aero:',m_aero_max);
        fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
        fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
        fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
        fprintf(fid,'%s %g\r\n',    'H2O smoothing parameter:',H2O_smoothing_para);
        fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_aero==1));
        fprintf(fid,'%s\r\n','UT[h]     Lat[deg] Long[deg] z_GPS[km] z_p[km] p[hPa]  CWV[cm] Err[cm] D[g/m3] Err[g/m3] D_is[g/m3]');
        dummy=[UT_mean',geog_lat_mean',geog_long_mean',GPS_Alt_mean',Press_Alt_mean',press_mean',U_mean',H2O_err_mean',H2O_dens',H2O_dens_err',H2O_dens_is_mean']';
        fprintf(fid,'%08.5f %9.5f %9.5f %7.3f  %7.3f  %7.2f %7.4f %7.4f %7.4f %7.4f  %7.4f\r\n',dummy);
        fclose(fid);
    end
end