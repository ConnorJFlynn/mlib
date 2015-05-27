%Computes aerosol extinction profiles, by differentiating dtau_a/dz but allows for averages at altitudes bins.

% defines wavelengths to be shown on plot
if strcmp(instrument,'AMES14#1_2002') 
     %SOLVE-2       354    380    453    499    520    605    675    779    864    940   1019    1240   1558    2138
          wvl_plot= [1      1      1      1      1      1      1      1       1      0      1      1      1      1     ];
 elseif strcmp(instrument,'AMES14#1_2001')  %AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia
    % ACE-Asia      354    380    448    499    525    605    675    779    864    940    1019   1060   1240     1558 
          wvl_plot= [1      1      1      1      1      1      1      1       1      0      1      1      1      1     ];
elseif strcmp(instrument,'AMES14#1_2000')  %AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia
    % ACE-2         380.3  448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5	
    % SAFARI        354    380    449    454    499    525    606    675    778    864    940    1019   1241   1557	
    wvl_plot=       [1      1      1      0      1      1      1      1       1      1      0      1      1      1     ];
elseif strcmp(instrument,'AMES6')  %AATS-6
    %            380.1  450.7  525.3  863.9   941.5   1020.7	
          wvl_plot= [1      1      1      1     0      1   ];
    
end      

zbot=min(r(L_cloud==1 & L_dist ==1))-deltaz/2;
ztop=max(r(L_cloud==1 & L_dist ==1))+deltaz/2;

%averaging and binning
[tau_aero_mean,tau_aero_err_mean,tau_aero_std,r_mean,GPS_Alt_mean,Press_Alt_mean,press_mean,geog_lat_mean,geog_long_mean,UT_mean,gamma_mean,alpha_mean,a0_mean]= ...
    avg_aodprofile(tau_aero(:,L_cloud==1 & L_dist ==1),tau_aero_err(:,L_cloud==1 & L_dist ==1),r(L_cloud==1 & L_dist ==1),GPS_Alt(L_cloud==1 & L_dist ==1),...
    Press_Alt(L_cloud==1 & L_dist ==1),press(L_cloud==1 & L_dist ==1),UT(L_cloud==1 & L_dist ==1),geog_lat(L_cloud==1 & L_dist ==1),...
    geog_long(L_cloud==1 & L_dist ==1),gamma(L_cloud==1 & L_dist ==1),alpha(L_cloud==1 & L_dist ==1),a0(L_cloud==1 & L_dist ==1),zbot,ztop,deltaz);

%smoothing tau_aero and differenting dtau_a/dz

pp  = csaps(r_mean,tau_aero_mean,aero_smoothing_para);
tau_aero_spline = fnval(pp,r_mean);
ext_coeff=-fnval(fnder(pp),r_mean);

%compute shape coeff. for ext. spectra
a0_ext=[]; 
alpha_ext=[];
gamma_ext=[];
for i=1:length(ext_coeff);
    wvl_use=(ext_coeff(:,i)>0)';
    x=log(lambda(wvl_chapp==1 & wvl_use==1));
    y=log(ext_coeff(wvl_chapp==1 & wvl_use==1,i));
    if ~isempty(x)
        [p,S] = polyfit(x,y,degree);
        switch degree
            case 1
                a0_ext(i)=p(2); 
                alpha_ext(i)=-p(1);
                gamma_ext(i)=0;
            case 2  
                a0_ext(i)=p(3); 
                alpha_ext(i)=-p(2);
                gamma_ext(i)=-p(1); 
        end
    else
        a0_ext(i)=-99.9999;
        alpha_ext(i)=99.9999;
        gamma_ext(i)=99.9999;
    end    
end


%plot residuals
figure(51)
plot(r_mean,tau_aero_mean-tau_aero_spline,'.')
xlabel('r')
ylabel('AOD Residuals')
grid on

%plot profiles
figure(52)
orient landscape
subplot(1,2,1)
plot(tau_aero_mean(wvl_plot==1,:),r_mean,'.',tau_aero_spline(wvl_plot==1,:),r_mean,'k--')
xlabel('Aerosol Optical Depth','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
set(gca,'xlim',[0 .3])
set(gca,'ylim',[0 7.5])
subplot(1,2,2)
plot(ext_coeff(wvl_plot==1,:),r_mean,'.-')
xlabel('Aerosol Extinction [1/km]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000') 
    legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(10),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'),num2str(lambda(14),'%4.3f')  );
end
if strcmp(instrument,'AMES14#1_2001')|  strcmp(instrument,'AMES14#1_2002') 
    legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'),num2str(lambda(14),'%4.3f'));
end
if strcmp(instrument,'AMES6')
    legend('380.1','450.7','525.3','863.9','1020.7'	)
end
set(gca,'FontSize',14)
grid on
set(gca,'xlim',[0 0.15])
set(gca,'ylim',[0 7.5])
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);

%plot AOD and extinction spectral shape profiles
figure(53)
orient landscape
subplot(1,2,1)
plot(alpha_mean,r_mean,'.',gamma_mean,r_mean,'.')
xlabel('AOD Spectrum','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
%set(gca,'xlim',[-0.5 2])
set(gca,'ylim',[0 6])
legend('alpha','gamma')

subplot(1,2,2)
plot(alpha_ext,r_mean,'.',gamma_ext,r_mean,'.')
xlabel('Extinction Spectrum','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);
% set(gca,'xlim',[-2 3])
set(gca,'ylim',[0 6])
legend('alpha','gamma')

% calculate extinction errors
figure(61)
subplot(2,2,1)
plot(geog_long_mean,geog_lat_mean,'.-')
xlabel('Longitude','FontSize',14)
ylabel('Latitude','FontSize',14)
set(gca,'FontSize',14)
grid on
axis square

%calculate extinction errors
switch lower(site)
    case 'ace-asia'
        g=[0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005]; %Average for ACE-Asia excluding short legs.
    case 'aerosol iop'
        g=[0.014 0.014 0.015 0.016 0.016 0.017 0.018 0.019 0.019 0.019 0.020 0.022 0.021]; %Average Aerosol IOP lower legs
    otherwise
        g=[0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005 0.005]; %Average for ACE-Asia excluding short legs.
end
AOD=tau_aero_mean(wvl_aero==1,:);
[m,n]=size(AOD);

dz=[];dx=[];
for k=(length(r_mean)-1):-1:1
   dz(k) = r_mean(k+1) - r_mean(k);   %this works because r_mean is in ascending order
   dx(k) = deg2km(distance(geog_lat_mean(k+1),geog_long_mean(k+1),geog_lat_mean(k),geog_long_mean(k)));
end

ext_err=abs((ones(n-1,1)*g)'.*(ones(m,1)*dx).*AOD(:,2:end)./(ones(m,1)*dz));

subplot(2,2,3)
plot(ext_err,r_mean(2:end),'.')

%remove unrealistic errors and fill in with nearest neighbors
x=ext_err(1,:);
y=r_mean(2:end);

i=find(x~=0); %remove errors that are 0 because dx is 0
x=x(i);
y=y(i);
ext_err=ext_err(:,i);

while max(abs(x))>mean(x)+3*std(x) 
    i=find(abs(x)<max (abs(x)));
    x=x(i);
    y=y(i);
    ext_err=ext_err(:,i);
end
ext_err=interp1(y,ext_err',r_mean,'nearest','extrap');
subplot(2,2,4)
plot(ext_err,r_mean,'.')
ext_err=ext_err';

%plot AOD and Extinction profile with error bars
figure(63)
subplot(1,2,1)
xerrorbar('linlin',-inf, inf, -inf, inf, tau_aero_mean(wvl_aero==1,:)', (ones(13,1)*r_mean)', tau_aero_err_mean(wvl_aero==1,:)','.')
xlabel('Aerosol Optical Depth','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
set(gca,'FontSize',14) 
subplot(1,2,2)
xerrorbar('linlin',-inf, inf, -inf, inf, ext_coeff(wvl_aero==1,:)', (ones(13,1)*r_mean)', ext_err(:,:)','.')
xlabel('Aerosol Extinction [1/km]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
grid on
set(gca,'FontSize',14) 


%write to file
if strcmp(Result_File,'ON')
    if strcmp(instrument,'AMES6')
        flight_num='RF12';
        write_AATS6_aceasia_prof(filename,path,UT_mean,UT_start,UT_end,day,month,year,O3_col_start*1000,NO2_clima*Loschmidt,lambda*1000,V0,darks,...
            geog_lat_mean,geog_long_mean,r_mean,tau_aero_mean(wvl_plot==1,:),tau_aero_err_mean(wvl_plot==1,:),...
            ext_coeff(wvl_plot==1,:),wvl_plot,aero_smoothing_para,deltaz,flight_num); 
    end
    if strcmp(instrument,'AMES14#1_2002') | strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES14#1_2000')
        if strcmp(site,'SAFARI-2000')
            resultfile=['AATS14_' filename '.aero_prof.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 1.6');
            fprintf(fid,'%s %g\r\n',    'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n',    'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
            fprintf(fid,'%s %g\r\n',    'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%s %g\r\n',       'AOD smoothing parameter',aero_smoothing_para);
            fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_aero==1));
            fprintf(fid,'%s %s%s%s %s%s\r\n','UT[h]     Lat[deg]  Lon[deg]  GPS_Alt p_Alt[km] p[hPa] ',num2str(lambda(wvl_aero==1)'*1000,'AOD%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),'a2_fit  a1_fit  a0_fit ',...
                num2str(lambda(wvl_aero==1)'*1000,'Ext%04.0f '),'a2_fit  a1_fit  a0_fit');
            dummy=[UT_mean',geog_lat_mean',geog_long_mean',GPS_Alt_mean',Press_Alt_mean',press_mean',tau_aero_mean(wvl_aero==1,:)',tau_aero_err_mean(wvl_aero==1,:)',-gamma_mean',-alpha_mean',a0_mean']';
            dummy=[dummy' ,ext_coeff(wvl_aero==1,:)', -gamma_ext',-alpha_ext',a0_ext']';
            fprintf(fid,'%08.5f %9.5f %9.5f %6.3f %7.3f %10.2f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        elseif strcmp(site,'ACE-Asia') | strcmp(site,'Aerosol IOP')| strcmp(site,'ALIVE')
            resultfile=['AATS14_' filename '.aero_prof.asc']
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
            fprintf(fid,'%s %4.2f %s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min,'Max Gamma:',gamma_max);
            fprintf(fid,'%s %g\r\n',    'AOD smoothing parameter:',aero_smoothing_para);
            fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_aero==1));
            fprintf(fid,'%s %s%s%s %s%s%s\r\n','UT[h]     Lat[deg] Lon[deg] GPS_Alt p_Alt[km] p[hPa] ',num2str(lambda(wvl_aero==1)'*1000,'AOD%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),'a2_fit  a1_fit  a0_fit ',...
                num2str(lambda(wvl_aero==1)'*1000,'Ext%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),'a2_fit  a1_fit  a0_fit');
            dummy=[UT_mean',geog_lat_mean',geog_long_mean',GPS_Alt_mean',Press_Alt_mean',press_mean',tau_aero_mean(wvl_aero==1,:)',tau_aero_err_mean(wvl_aero==1,:)',-gamma_mean',-alpha_mean',a0_mean']';
            dummy=[dummy' ,ext_coeff(wvl_aero==1,:)', ext_err',-gamma_ext',-alpha_ext',a0_ext']';
            fprintf(fid,'%08.5f %9.5f %9.5f %7.3f %7.3f %7.2f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        end
    end
end
