function []= write_AATS6_aceasia_prof(filename,path,UT_mean,UT_start,UT_end,dateday,datemon,dateyr,O3_col,NO2_col,lambda,V0,darks,...
   lat,long,altitude,tau_aero,tau_aero_err,ext_coeff,wvl_plot,aero_smoothing_para, deltaz, flight_num);

%flag bad data and give date specific information

resultfile=['AATS6_',flight_num,'_',num2str(round(mean(UT_mean))),'UTprof.asc']
fid=fopen([path resultfile],'w');

fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 6-Channel Sunphotometer, AATS-6');
fprintf(fid,'%s  Date:%i/%2i/%4i %s \r\n','ACE-ASIA ',datemon,dateday,dateyr, flight_num);
fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid (bschmid@mail.arc.nasa.gov), Version 1.0');
fprintf(fid,'%s %6.3f %s\r\n', 'This file contains aerosol optical depth, extinction and other variables, averaged vertically over ', 1000*deltaz, ' m');
fprintf(fid,'%s %6.3f %s %6.3f %s\r\r\n', 'intervals; time period: ',UT_start, 'to', UT_end, 'UT');
fprintf(fid,'%s %g\r\r\n', 'TOMS O3 used for analysis [DU]:',O3_col);
fprintf(fid,'%s %6.1f %6.1f %6.1f %6.1f %6.1f  \r\r\n\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_plot==1));
fprintf(fid,'%s\r\n','UT[hours], Latitude[deg], Longitude[deg], Altitude[km], Aerosol Optical Depth(5), Error in Aerosol Optical Depth(5), Aerosol extinction(5) [km^-1]');


fprintf(fid,'%7.3f %7.3f %7.3f %9.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f \n',...
[UT_mean',lat',long',altitude',tau_aero',tau_aero_err',ext_coeff']')
fclose(fid);

return