function [ntimwrt,resultfile]=archive_AATS14_SOLVE2_GH(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        L_cloud,L_H2O,geog_lat,geog_long,GPS_Alt,Press_Alt,press,CWV,CWV_err,gamma,alpha,a0,O3_col_fit,tau_aero,tau_aero_err,...
        O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min);   

if isempty(dataarchive_dir) dataarchive_dir='c:\johnmatlab\AATS14_2002_archive\'; end
resultfile=sprintf('checkAA%4d%02d%02d__all.DC8',year,month,day);
fid=fopen([dataarchive_dir resultfile],'w');

d=datevec(now);

if (day==13 & month==12 & year==2002)
       comments=[]; 
end
if (day==17 & month==12 & year==2002)
       comments=[]; 
end
if (day==19 & month==12 & year==2002)
       comments=[];
end
if (day==04 & month==01 & year==2003)
           %123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 comments={'During normal operation, the plate containing the AATS-14 silicon photodetectors (i.e., all wavelengths shorter than 1241 nm) is '
           'maintained at a constant temperature of 45 deg C.  During this flight, an apparent computer malfunction caused the detector plate '
           'temperature to be held constant near 36 deg C during the time period 21.67-21.81 UT and near 27 deg C after 21.82 UT.  These '
           'temperature differences have not been taken into account in deriving the aerosol optical depth (AOD) and columnar water vapor (CWV) '
           'values listed in this archive file.  As a result, the AOD values for wavelengths less than 1241 nm and the calculated CWV values '
           'must be considered suspect at this time.  These data will be corrected and a revised data file will be submitted to the archive at '
           'a future date.'} 
end
if (day==12 & month==1 & year==2003)
           %123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 comments={'Due to the unusual shape of the spectrum I use 864 nm and 1020 nm to derive the AOD at 940 nm. Hence alpha is from a linear fit and'
           'gamma is zero'};
end
if (day==14 & month==01 & year==2003)
       comments=[];
end
if (day==16 & month==01 & year==2003)
           %123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 comments={'Window iced over. Only 520 and maybe 1558 and 2139 are valid'};
end
if (day==19 & month==01 & year==2003)
           %123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 comments={'Window NOT iced over. All channels valid. Currently only data with zenith angle smaller than 90 deg. archived. We need to improve'
           ' zenith angle and airmass computations'  };
end
if (day==21 & month==01 & year==2003)
           %123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
 comments={'Window NOT iced over. All channels valid. Currently only data with zenith angle smaller than 90 deg. archived. We need to improve'
           ' zenith angle and airmass computations'  };
end

%number of special comment lines
nscoml=length(comments);

%total number of lines in the header
nlhead=48+nscoml;

%switch FlightNo
  %case 1,
       %for flight 1 on ??   Don't know any flight numbers yet.
       %comments={'None' ' '}; 
%end   

%begin #HEADER# section
fprintf(fid,'%2d  2010\n',nlhead);
fprintf(fid,'Philip Russell, John Livingston, Beat Schmid, Jens Redemann\n');
fprintf(fid,'NASA Ames Research Center\n');
fprintf(fid,'NASA Ames 14-Channel Airborne Tracking Sunphotometer (AATS-14)\n');
fprintf(fid,'SOLVE II\n');
fprintf(fid,'1  1\n');
fprintf(fid,'%4d %2d %2d %4d %2d %2d\n',year,month,day,d(1,1),d(1,2),d(1,3));
fprintf(fid,'0.0 0.0\n');
fprintf(fid,'13\n');
fprintf(fid,'13\n');
fprintf(fid,'%6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\r\n', 1000*lambda(wvl_aero==1));
fprintf(fid,'Wavelengths (nm)\n');
fprintf(fid,'Elapsed seconds from 0 hours UT on day given by DATE\n');
fprintf(fid,'2\n');
fprintf(fid,'0.0001  0.0001\n');
fprintf(fid,'999999  999999\n');
fprintf(fid,'Aerosol optical depth\n');
fprintf(fid,'Absolute uncertainty in aerosol optical depth\n');
fprintf(fid,'12\n');
fprintf(fid,'0.001  0.001  1.0  1.0  0.1 0.0001  0.0001 1.0 1.0 0.001 0.001 0.001\n');
fprintf(fid,'99999  99999  99999  99999  99999  99999  99999  99999  99999  99999  99999  99999\n');
fprintf(fid,'Aircraft latitude (deg) at the indicated time\n');
fprintf(fid,'Aircraft longitude (deg) at the indicated time\n');
fprintf(fid,'Aircraft GPS geometric altitude (m) at the indicated time\n');
fprintf(fid,'Aircraft pressure altitude (m) at the indicated time\n');
fprintf(fid,'Atmospheric pressure (hPa) at the indicated time\n');
fprintf(fid,'Water vapor column content (cm)\n');
fprintf(fid,'Absolute Uncertainty in water vapor column content (cm)\n');
fprintf(fid,'Ozone column content (DU)\n')
fprintf(fid,'Cloud screen flag (0=possible cloud/obscuration, 1=no cloud/obscuration)\n');
fprintf(fid,'ln(AOD) vs ln(wavelength) polynomial fit coefficient: a2\n');
fprintf(fid,'ln(AOD) vs ln(wavelength) polynomial fit coefficient: a1\n');
fprintf(fid,'ln(AOD) vs ln(wavelength) polynomial fit coefficient: a0\n');
if isempty(comments)
    fprintf(fid,'0\n');
else
    fprintf(fid,'%d\n',nscoml);
    for j=1:nscoml,
        fprintf(fid,'%s\n',char(comments(j)));
    end
end
fprintf(fid,'13\n');  %number of comment lines that follow
%fprintf(fid,'NASA DC-8 Flight No: %4d\n',FlightNo);
fprintf(fid,'%s %g\r\n', 'Nitrogen dioxide columnar number density  [molec/cm2]:',NO2_clima*Loschmidt);
fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
fprintf(fid,'%s %g %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
fprintf(fid,'Ozone fit: %s\n',O3_estimate);
fprintf(fid,'\n');
fprintf(fid,' Wavelength [nm]: %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f\r\n', 1000*lambda(wvl_aero==1),1000*lambda(wvl_water==1));
fprintf(fid,'       VZERO [V]: %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n',V0(wvl_aero==1),V0(wvl_water==1));
%fprintf(fid,'\nSpecial Notes:\n');
%comments_str=char(comments);
%fprintf(fid,'%s\n%s\n',comments_str(1,:),comments_str(2,:));
fprintf(fid,'\n');

numsecs=round((86400/24)*UT);

%archive only those where water vapor is okay
jobsw=find(L_H2O==1);
ntimwrt=length(jobsw);
for jw = 1:ntimwrt,
   j=jobsw(jw);
   fprintf(fid,'%5d %6.0f %7.0f %5.0f %5.0f %5.0f %6.0f %6.0f %5.0f %3d %5.0f %5.0f %5.0f\n',numsecs(j),1000*geog_lat(j),1000*geog_long(j),...
      1000*GPS_Alt(j),1000*Press_Alt(j),10*press(j),10000*CWV(j),10000*CWV_err(j),1000*O3_col_fit(j),L_cloud(j),-1000*gamma(j),-1000*alpha(j),1000*a0(j));
   fprintf(fid,'  %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f\n',10000*tau_aero(wvl_aero==1,j));
   fprintf(fid,'  %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f %5.0f\n',10000*tau_aero_err(wvl_aero==1,j));
end

fclose(fid);

return