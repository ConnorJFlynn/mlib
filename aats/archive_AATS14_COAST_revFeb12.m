function [ntimwrt,resultfile]=archive_AATS14_COAST_revFeb12(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,CWV,CWV_err,gamma,alpha,a0,O3_col_fit,unc_O3_col,tau_aero,tau_aero_err,...
        O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,sd_crit_aero_highalt,zGPS_highalt_crit,m_aero_max,tau_aero_limit,...
        tau_aero_err_max,alpha_min,alpha_min_lowalt,flag_calib,Temperature,rel_sd,frost_filter,dirt_filter,UT_smoke,sd_crit_aero_smoke,...
        flag_interpOMIozone,filename_OMIO3,AvePeriod,UTCan);   

revision_number='0';  %use letter for in-field; begin post-mission archival with a zero - '0'

if strcmp(frost_filter,'yes')
    flag_filter354='yes';   %used for filtering the 354nm AOD's when we suspect frost
    if strcmp(flag_filter354,'yes')
     flag_354_frost=find(rel_sd(1,:)>rel_sd(3,:))  %found that rel_sd(354)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     tau_aero(1,flag_354_frost)=-9999;  %set 354-nm AOD=-9999
     tau_aero_err(1,flag_354_frost)=-9999;  %set 354-nm AOD=-9999
    end
end

if (julian(day, month,year,12) == julian(19,4,2008,12))
    if strcmp(dirt_filter,'yes')
        tau_aero(12:14,UT>21.2)=-9999;
        tau_aero_err(12:14,UT>21.2)=-9999;
    end
end
    
if (julian(day, month,year,12) == julian(9,7,2008,12))
        tau_aero(6,UT>=16.406&UT<=16.455)=-9999;
        tau_aero_err(6,UT>=16.406&UT<=16.455)=-9999;
end

if isempty(dataarchive_dir) dataarchive_dir='c:\johnmatlab\AATS14_2011_COASTarchive\'; end
resultfile=sprintf('AATS_TOtter_%4d%02d%02d_R%s.ict',year,month,day,revision_number);
%resultfile=sprintf('AATS14_COAST_%4d%02d%02d_R%s.ict',year,month,day,revision_number);
fid=fopen([dataarchive_dir resultfile],'w');

d=datevec(now);

comments_use={'STIPULATIONS_ON_USE: This version contains Aerosol Optical Depth (AOD) and Columnar Water Vapor (CWV) retrievals.'};

comments=[];

if (day==24 & month==6 & year==2008)
 comments={'Dirt accumulated on the AATS-14 quartz window during the low level legs over the ocean, and this resulted in a decrease in'
           'transmission through the window in some channels.  No correction has been applied to the data to account for this effect.'}; 
end

%number of special comment lines
nscoml=length(comments);
 
nlines_comments_use=length(comments_use);

comments_other={'OTHER_COMMENTS: Start_UTC may only be accurate to 1-2 seconds. Stop_UTC and Midpoint_UTC should be ignored. Reflection off aircraft wing during turns'
                'occasionally resulted in incorrect measurements in selected channels. Some but not all of these observations have been removed from the data set; '
                'in some of these cases, the AOD values and associated uncertainties in the channels affected have been set equal to -9999.'};

nlines_comments_other=length(comments_other);

nlines_normalcomments = 29 + nlines_comments_use + nlines_comments_other;

num_variables=38;

%total number of lines in the header
nlhead = 14 + num_variables + nscoml + nlines_normalcomments;

%begin #HEADER# section
fprintf(fid,'%2d,  1001\n',nlhead);
fprintf(fid,'Russell, Philip\n');
fprintf(fid,'NASA Ames Research Center\n');
fprintf(fid,'NASA Ames 14-Channel Airborne Tracking Sunphotometer (AATS-14)\n');
fprintf(fid,'COAST\n');
fprintf(fid,'1, 1\n');
fprintf(fid,'%4d, %2d, %2d, %4d, %2d, %2d\n',year,month,day,d(1,1),d(1,2),d(1,3));
fprintf(fid,'0\n');
fprintf(fid,'Start_UTC, Elapsed seconds from 0 hours UTC on day given by DATE\n');
fprintf(fid,sprintf('%2d\n',num_variables)); %number of primary variables
fprintf(fid,'1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1\n'); %primary variable scale factors
fprintf(fid,'-9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0, -9999.0\n'); %primary variable missing values
%fprintf(fid,'-9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999, -9999\n'); %primary variable missing values
fprintf(fid,'Stop_UTC, secs\n');
fprintf(fid,'Midpoint_UTC, secs\n');
fprintf(fid,'Latitude, Aircraft latitude (deg) at the indicated time\n');
fprintf(fid,'Longitude, Aircraft longitude (deg) at the indicated time\n');
fprintf(fid,'GPS_alt, Aircraft GPS geometric altitude (m) at the indicated time\n');
fprintf(fid,'P_alt, Aircraft pressure altitude (m) at the indicated time\n');
fprintf(fid,'Stat_P, Static atmospheric pressure (hPa) at the indicated time\n');
fprintf(fid,'CWV, Water vapor column content (cm)\n');
fprintf(fid,'unc_CWV, Absolute Uncertainty in water vapor column content (cm)\n');
fprintf(fid,'O3_col, Ozone column content (DU)\n')
fprintf(fid,'cld_scr, Cloud screen flag (0=possible cloud contamination, 1=no contamination)\n');
fprintf(fid,'a2, ln(AOD) vs ln(wavelength) polynomial fit coefficient\n');
fprintf(fid,'a1, ln(AOD) vs ln(wavelength) polynomial fit coefficient\n');
fprintf(fid,'a0, ln(AOD) vs ln(wavelength) polynomial fit coefficient\n');
iwvl_aer=find(wvl_aero==1);
for i=iwvl_aer,
    fprintf(fid,'AOD%3.0f, Aerosol optical depth at %5.1f nm\n',1000*lambda(i),1000*lambda(i));
end
for i=iwvl_aer,
    fprintf(fid,'u_AOD%3.0f, Aerosol optical depth uncertainty at %5.1f nm\n',1000*lambda(i),1000*lambda(i));
end
if isempty(comments)
    fprintf(fid,'0\n');
else
    fprintf(fid,'%d\n',nscoml);
    for j=1:nscoml,
        fprintf(fid,'%s\n',char(comments(j)));
    end
end

fprintf(fid,sprintf('%2d\n',nlines_normalcomments'));  %number of normal comment lines that follow

fprintf(fid,'COAST Flight No: %d\n',FlightNo);
fprintf(fid,'%s %g\r\n', 'Nitrogen dioxide columnar number density  [molec/cm2]:',NO2_clima*Loschmidt);
fprintf(fid,'%s %4.2f, %s %3.1f, %s %5.3f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero,'  Relative Std Dev Filter Aerosol High Alt[%]:',...
    100*sd_crit_aero_highalt,'  High Alt Cutoff[km]:',zGPS_highalt_crit);
fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
fprintf(fid,'%s %4.2f, %s %4.2f\r\n', 'Min Alpha Angstrom high altitude:',alpha_min,'   Min Alpha Angstrom low altitude:',alpha_min_lowalt);
fprintf(fid,'%s %g, %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
if strcmp(flag_interpOMIozone,'no')
    fprintf(fid,'Ozone fit: %s,    Uses OMI OMTO3 data product (http://toms.gsfc.nasa.gov/omi/OMTO3Readme.html) for full column\n',O3_estimate);
elseif strcmp(flag_interpOMIozone,'yes')
    fprintf(fid,'Ozone fit: %s,    Uses OMI OMTO3 data product (http://toms.gsfc.nasa.gov/omi/OMTO3Readme.html), file %s, for full column\n',O3_estimate,filename_OMIO3);
end
    
fprintf(fid,'V0_source: %s\n',flag_calib);

fprintf(fid,' Wavelength [nm]: %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f, %6.1f\r\n', 1000*lambda(wvl_aero==1),1000*lambda(wvl_water==1));
fprintf(fid,'       VZERO [V]: %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f, %6.3f\r\n',V0(wvl_aero==1),V0(wvl_water==1));

fprintf(fid,'PI_CONTACT_INFO: Philip B. Russell; address: Moffett Field, CA 94035; email: philip.b.russell@nasa.gov(650-604-5404)\n');
fprintf(fid,'PLATFORM: CIRPAS Twin Otter\n');
fprintf(fid,'LOCATION: Aircraft latitude, longitude, altitude are included in the data records\n');
fprintf(fid,'ASSOCIATED_DATA: N/A\n');
fprintf(fid,'INSTRUMENT_INFO: 14-channel automatic tracking airborne sunphotometer\n');
fprintf(fid,'DATA_INFO: Basic measurements represent 2-second averages acquired at a sample rate of 10 Hz. Spectral fit equation: log(AOD) = a2*log(wvl)*log(wvl) + a1*log(wvl) + a0.\n');
fprintf(fid,'UNCERTAINTY: included in the data records\n');
fprintf(fid,'ULOD_FLAG: -7777\n');
fprintf(fid,'ULOD_VALUE: N/A\n');
fprintf(fid,'LLOD_FLAG: -8888\n');
fprintf(fid,'LLOD_VALUE: N/A\n');
fprintf(fid,'DM_CONTACT_INFO: John Livingston, G-136, SRI International, Menlo Park,CA 94025; 650-859-4174; John.M.Livingston@nasa.gov\n');
fprintf(fid,'PROJECT_INFO: COAST deployment; October 2011; Marina,CA\n');

for j=1:nlines_comments_use,
    fprintf(fid,'%s\n',char(comments_use(j)));
end

for j=1:nlines_comments_other,
    fprintf(fid,'%s\n',char(comments_other(j)));
end

fprintf(fid,sprintf('REVISION: R%s\n',revision_number));
if strcmp(revision_number,'A')
    fprintf(fid,'RA: No comments for this revision\n');
elseif strcmp(revision_number,'B')
    fprintf(fid,'RB: No comments for this revision\n');
elseif strcmp(revision_number,'0')
    comment_output={'R0: '};
    for jj=1:length(comment_output)
        fprintf(fid,'%s\n',char(comment_output(jj)))
    end
elseif strcmp(revision_number,'1')
    comment_output={'R1: '};
    for jj=1:length(comment_output)
        fprintf(fid,'%s\n',char(comment_output(jj)))
    end
end    
fprintf(fid,'Start_UTC, Stop_UTC, Midpoint_UTC, Latitude,  Longitude,    GPS_alt,    P_alt,  Stat_P,     CWV,      unc_CWV,   O3_col,   cld_scr,    a2,       a1,       a0,     AOD354,    AOD380,    AOD452,    AOD501,    AOD520,    AOD605,    AOD675,    AOD780,    AOD865,   AOD1019,   AOD1236,   AOD2139,  u_AOD354,  u_AOD380,  u_AOD452,  u_AOD501,  u_AOD520,  u_AOD605,  u_AOD675,  u_AOD780,  u_AOD865,  u_AOD1019, u_AOD1236, u_AOD2139\n')

numsecs=round((86400/24)*UT);
stop_secs=numsecs+1.9; %dummy
mid_secs=numsecs+1.0; %dummy

%archive only those where water vapor is okay
jobsw=find(L_H2O==1);
ntimwrt=length(jobsw);
kwvuse=find(wvl_aero==1);
for jw = 1:ntimwrt,
   j=jobsw(jw);
   format_str = '%5d,     %7.1f,     %7.1f, %10.5f, %10.5f, %9.1f, %9.1f, %7.1f, %9.4f, %9.4f, %8.0f,       %1d, %9.3f, %8.3f, %8.3f,';
   %format_str = '%5d     %7.1f     %7.1f %10.5f %10.5f %9.1f %9.1f %7.1f %9.4f %9.4f %8.0f       %1d %9.3f %8.3f %8.3f';
   aod_str = '';
   err_str = '';
   for k = kwvuse,
       %if (k>9), k = k+1; end
       if tau_aero(k,j)>0
           aod_str = strcat(aod_str, ' %9.4f,');
           if k<kwvuse(end)
               err_str = strcat(err_str, ' %9.4f,') ;
           elseif k==kwvuse(end)
               err_str = strcat(err_str, ' %9.4f') ;
           end
       else
           aod_str = strcat(aod_str, ' %9.1f,');
           if k<kwvuse(end)
               err_str = strcat(err_str, ' %9.1f,') ;
           elseif k==kwvuse(end)
               err_str = strcat(err_str, ' %9.1f') ;
           end
       end
   end
   format_str = strcat(format_str, aod_str, err_str, ' \n');
   fprintf(fid,format_str,...
                   numsecs(j),stop_secs(j),mid_secs(j),geog_lat(j),geog_long(j),1000*GPS_Alt(j),1000*Press_Alt(j),press(j),CWV(j),CWV_err(j),1000*O3_col_fit(j),L_cloud(j),gamma(j),alpha(j),a0(j),tau_aero(wvl_aero==1,j),tau_aero_err(wvl_aero==1,j));
end
     

fclose(fid);

return