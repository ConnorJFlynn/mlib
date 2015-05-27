function []= archive_AATS6_ace2(filename,path,UTdechr,dateday,datemon,dateyr,O3_col,NO2_col,lambda,V0,darks,...
   data,geog_lat,geog_long,altitude,pressure,H2O_col,H2O_col_err,tau_aero,tau_aero_err,DGPS,wvl_aero,...
   H2O_dens,ext_coeff,H2O_smoothing_para,aero_smoothing_para);

resultfile=[filename '.ace2']
fid=fopen([path resultfile],'w');

switch DGPS
  case 'Y',  altitude_flag='differential GPS'
  case 'N', altitude_flag='pressure altitudes'
end

%flag bad data and give date specific information
if dateday==18 & datemon==6 & dateyr==1997
   flight=1
end   
if dateday==21 & datemon==6 & dateyr==1997
   flight=3
end   
if dateday==30 & datemon==6 & dateyr==1997
   flight=8
   ext_coeff([11],:)=ext_coeff([11],:).^0*-9.9999;
end   
if dateday==1 & datemon==7 & dateyr==1997
   flight=9
end   
if dateday==8 & datemon==7 & dateyr==1997
   flight=15
end   
if dateday==10 & datemon==7 & dateyr==1997
   flight=17
   ext_coeff([5 11],:)=ext_coeff([5 11],:).^0*-9.9999;
end   
if dateday==17 & datemon==7 & dateyr==1997
   flight=20
end   


%begin #HEADER# section
fprintf(fid,'#HEADER#\n');
fprintf(fid,'TOTAL FILES=7\n');

hhmmss=100*hr2hms(UTdechr);
ymd=10000*(dateyr-1900)+100*datemon+dateday;
[m,n]=size(UTdechr);
ymd=ones(1,n)*ymd;

fprintf(fid,'FILE START TIME=');
fprintf(fid,'%6d%08.1f\n',ymd(1),hhmmss(1));
fprintf(fid,'FILE STOP TIME=');
fprintf(fid,'%6d%08.1f\n',ymd(end),hhmmss(end));

fprintf(fid,'VERSION=1\n');

d=datevec(now);
submit_date_str=num2str(10000*(d(1,1)-1900)+100*d(1,2)+d(1,3));
fprintf(fid,'SUBMIT_DATE=');
fprintf(fid,'%s\n',submit_date_str);

%begin #REMARK# section
fprintf(fid,'#REMARKS#\n');
fprintf(fid,'%s %i\n', 'Flight: TF',flight);
fprintf(fid,'%s %0.1f\n','Ozone column content [DU]:',O3_col);
fprintf(fid,'%s %0.1e\n','NO2 column content [molec/cm2]:',NO2_col);
fprintf(fid,'%s %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %5.1f %6.1f %6.1f %6.1f\n', 'Wavelength [nm]:',lambda);
fprintf(fid,'%s %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %6.3f %6.3f %6.3f\n', 'V0    [V]      :',V0);
fprintf(fid,'%s %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %5.3f %6.3f %6.3f %6.3f\n', 'VDARK [V]      :',darks);
fprintf(fid,'%s\n', 'Detector outputs given below are corrected for VDARK');
fprintf(fid,'%s %0.5f\n', 'H2O spline smoothing parameter: ',H2O_smoothing_para);
fprintf(fid,'%s %0.5f\n', 'Aerosol spline smoothing parameter: ',aero_smoothing_para);
fprintf(fid,'%s\n', 'This version is identical to Version 1.1 on http://geo.arc.nasa.gov/sgg/ACE-2');

%begin #PARAMETER# section

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Time\nUTC\n*\n*\n*\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Aircraft Latitude\ndeg\n-90.0\n90.0\n-99.9999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Aircraft Longitude\ndeg\n-180.0\n180.0\n-999.9999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Aircraft Altitude\nkm\n-0.2\n4.0\n-9.999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Atmospheric Pressure\nmb\n500.0\n1050.0\n9999.99\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Water Vapor Density\ng/cm^3\n-5.0\n100.0\n999.9999\n*\n*\n*\n');

fprintf(fid,'#PARAMETER#\n');
fprintf(fid,'Aerosol Extinction Coefficient\n1/km\n-0.05\n10.0\n-9.9999\nwavelength\nnm\n');
fprintf(fid,'%6.1f ',lambda(wvl_aero==1));
fprintf(fid,'\n');

%begin #DATA# section
fprintf(fid,'#DATA#\n');
fprintf(fid,'%6d%08.1f %8.4f %9.4f %6.3f %7.2f %8.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',...
[ymd',hhmmss',geog_lat',geog_long',altitude',pressure,H2O_dens',ext_coeff']')
fclose(fid);

return