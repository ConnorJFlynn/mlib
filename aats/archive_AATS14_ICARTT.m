function [ntimwrt,resultfile]=archive_AATS14_ICARTT(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,CWV,CWV_err,gamma,alpha,a0,O3_col_fit,unc_O3_col,tau_aero,tau_aero_err,...
        O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min,flag_calib);   

resultfile=sprintf('AATS14_J31_%4d%02d%02d_RA.ict',year,month,day);
fid=fopen([dataarchive_dir resultfile],'w');

d=datevec(now);

comments=[];

%number of special comment lines
nscoml=length(comments);

%total number of lines in the header
nlhead=84+nscoml;

%switch FlightNo
  %case 1,
       %for flight 1 on ??   Don't know any flight numbers yet.
       %comments={'None' ' '}; 
%end   

%begin #HEADER# section
fprintf(fid,'%2d  1001\n',nlhead);
fprintf(fid,'Philip Russell, Beat Schmid, Jens Redemann\n');
fprintf(fid,'NASA Ames Research Center\n');
fprintf(fid,'NASA Ames 14-Channel Airborne Tracking Sunphotometer (AATS-14)\n');
fprintf(fid,'ICARTT_INTEX-ITCT\n');
fprintf(fid,'1 1\n');
fprintf(fid,'%4d %2d %2d %4d %2d %2d\n',year,month,day,d(1,1),d(1,2),d(1,3));
fprintf(fid,'0\n');
fprintf(fid,'Elapsed seconds from 0 hours UT on day given by DATE: Start_UTC\n');
fprintf(fid,'41\n'); %number of primary variables
fprintf(fid,'1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1\n'); %primary variable scale factors
fprintf(fid,'-9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999 -9999\n'); %primary variable missing values
fprintf(fid,'Stop_UTC\n');
fprintf(fid,'Mid_UTC\n');
fprintf(fid,'Aircraft latitude (deg) at the indicated time: Latitude\n');
fprintf(fid,'Aircraft longitude (deg) at the indicated time: Longitude\n');
fprintf(fid,'Aircraft GPS geometric altitude (m) at the indicated time: GPS_alt\n');
fprintf(fid,'Aircraft pressure altitude (m) at the indicated time: P_alt\n');
fprintf(fid,'Static atmospheric pressure (hPa) at the indicated time: Stat_P\n');
fprintf(fid,'Water vapor column content (cm): CWV\n');
fprintf(fid,'Absolute Uncertainty in water vapor column content (cm): unc_CWV\n');
fprintf(fid,'Ozone column content (DU): O3_col\n')
fprintf(fid,'Absolute Uncertainty in ozone column content (DU): unc_O3\n')
fprintf(fid,'Cloud screen flag (0=possible cloud/obscuration, 1=no cloud/obscuration): cld_scr\n');
fprintf(fid,'ln(AOD) vs ln(wavelength) polynomial fit coefficient: a2\n');
fprintf(fid,'ln(AOD) vs ln(wavelength) polynomial fit coefficient: a1\n');
fprintf(fid,'ln(AOD) vs ln(wavelength) polynomial fit coefficient: a0\n');
iwvl_aer=find(wvl_aero==1);
for i=iwvl_aer,
    fprintf(fid,'Aerosol optical depth at %5.1f nm: AOD%3.0f\n',1000*lambda(i),1000*lambda(i));
end
for i=iwvl_aer,
    fprintf(fid,'Aerosol optical depth uncertainty at %5.1f nm: u_AOD%3.0f\n',1000*lambda(i),1000*lambda(i));
end
if isempty(comments)
    fprintf(fid,'0\n');
else
    fprintf(fid,'%d\n',nscoml);
    for j=1:nscoml,
        fprintf(fid,'%s\n',char(comments(j)));
    end
end
fprintf(fid,'29\n');  %number of normal comment lines that follow

%fprintf(fid,'NASA J-31 Flight No: %4d\n',FlightNo);
fprintf(fid,'%s %g\r\n', 'Nitrogen dioxide columnar number density  [molec/cm2]:',NO2_clima*Loschmidt);
fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
fprintf(fid,'%s %g %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
fprintf(fid,'Ozone fit: %s   V0_source: %s\n',O3_estimate,flag_calib);
fprintf(fid,' Wavelength [nm]: %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\r\n', 1000*lambda(wvl_aero==1),1000*lambda(wvl_water==1));
fprintf(fid,'       VZERO [V]: %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n',V0(wvl_aero==1),V0(wvl_water==1));
%fprintf(fid,'\nSpecial Notes:\n');
%comments_str=char(comments);
%fprintf(fid,'%s\n%s\n',comments_str(1,:),comments_str(2,:));

fprintf(fid,'PI_CONTACT_INFO: Address: Moffett Field, CA 94035; email: Philip.B.Russell@nasa.gov; 650-604-5404\n');
fprintf(fid,'PLATFORM: Jetstream-31\n');
fprintf(fid,'LOCATION: Aircraft latitude, longitude, altitude are included in the data records\n');
fprintf(fid,'ASSOCIATED_DATA: N/A\n');
fprintf(fid,'INSTRUMENT_INFO: 14-channel automatic tracking airborne sunphotometer\n');
fprintf(fid,'DATA_INFO: Basic measurements represent 9-sample averages over 3 seconds beginning at Start_UTC. Spectral fit equation: log(AOD) = a2*log(wvl)*log(wvl) + a1*log(wvl) + a0.\n');
fprintf(fid,'UNCERTAINTY: included in the data records\n');
fprintf(fid,'ULOD_FLAG: -7777\n');
fprintf(fid,'ULOD_VALUE: N/A\n');
fprintf(fid,'LLOD_FLAG: -8888\n');
fprintf(fid,'LLOD_VALUE: N/A\n');
fprintf(fid,'DM_CONTACT_INFO: Stephanie Ramirez,MS 245-5,NASA Ames Research Center,Moffett Field,CA 94035; 650-604-3632; saramirez@mail.arc.nasa.gov\n');
fprintf(fid,'PROJECT_INFO: ICARTT study; 1 July-15 August 2004; Gulf of Maine and North Atlantic Ocean\n');
fprintf(fid,'STIPULATIONS_ON_USE: Use of these data requires PRIOR OK from the PI\n');
fprintf(fid,'OTHER_COMMENTS: For analysis, use Start_UTC only. Stop_UTC is artificial and should be ignored.\n');
fprintf(fid,'REVISION: RA\n');
fprintf(fid,'RA: No comments for this revision\n');
fprintf(fid,'Start_UTC Stop_UTC    Mid_UTC   Latitude  Longitude   GPS_alt    P_alt  Stat_p     CWV      unc_CWV   O3_col  unc_O3   cld_scr    a2       a1       a0      AOD354    AOD380    AOD453    AOD499    AOD519    AOD604    AOD675    AOD778    AOD864   AOD1019   AOD1241    AOD1558   AOD2139  u_AOD353  u_AOD380  u_AOD452  u_AOD499  u_AOD519  u_AOD604  u_AOD675  u_AOD778  u_AOD864  u_AOD1019 u_AOD1241 u_AOD1558 u_AOD2139\n')

numsecs=round((86400/24)*UT);
stop_secs=numsecs+2.9; %necessary to create acceptable format
mid_secs=numsecs+1.5;

%archive only those where water vapor is okay
jobsw=find(L_H2O==1);
ntimwrt=length(jobsw);
for jw = 1:ntimwrt,
   j=jobsw(jw);
   fprintf(fid,'%5d     %7.1f     %7.1f %9.3f %10.3f %9.1f %9.1f %7.1f %9.4f %9.4f %8.0f %8.1f       %1d %9.3f %8.3f %8.3f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\n',...
      numsecs(j),stop_secs(j),mid_secs(j),geog_lat(j),geog_long(j),1000*GPS_Alt(j),1000*Press_Alt(j),press(j),CWV(j),CWV_err(j),1000*O3_col_fit(j),1000*unc_O3_col(j),L_cloud(j),gamma(j),alpha(j),a0(j),tau_aero(wvl_aero==1,j),tau_aero_err(wvl_aero==1,j));
   %fprintf(fid,'  %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\n',tau_aero(wvl_aero==1,j));
   %fprintf(fid,'  %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.4f\n',tau_aero_err(wvl_aero==1,j));
end

fclose(fid);

return