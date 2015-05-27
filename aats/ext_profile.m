%Computes aerosol extinction profiles, by differentiating dtau_a/dz
% defines wavelengths to be shown on plot

if strcmp(instrument,'AMES14#1_2001')  %AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia
    % ACE-Asia      354    380    448    499    525    605    675    779    864    940    1019   1060   1240     1558 
    wvl_plot= [1      1      1      1      1      1      1      1       1      0      1      1      1      1     ];
elseif strcmp(instrument,'AMES14#1_2000')  %AATS-14 after December 8, 2000, for MLO February 2001, Twin Otter ACE-Asia
    % ACE-2         380.3  448.25 452.97 499.4  524.7  605.4  666.8  711.8  778.5  864.4  939.5  1018.7 1059   1557.5	
    % SAFARI        354    380    448    453    499    525    605    675    779    864    940    1019   1240   1558	
    wvl_plot=       [1      1      1      0      1      1      1      1       1      1      0      1      1      1     ];
elseif strcmp(instrument,'AMES6')  %AATS-6
    %               380.1  450.7  525.3  863.9   941.5   1020.7	
    wvl_plot=       [1      1      1      1      0      1   ];
    
end      

%smoothing altitude and differenting dz/dt
pp  = csaps(UT(L_cloud==1 & L_dist ==1),r(L_cloud==1 & L_dist ==1),aero_smoothing_para);
r_spline = fnval(pp,UT(L_cloud==1 & L_dist ==1));
dr_spline=fnval(fnder(pp),UT(L_cloud==1 & L_dist ==1));

%smoothing tau_aero and differenting dtau_a/dt
pp  = csaps(UT(L_cloud==1 & L_dist ==1),tau_aero(:,L_cloud==1 & L_dist ==1),aero_smoothing_para);
tau_aero_spline = fnval(pp,UT(L_cloud==1 & L_dist ==1));
dtau_aero_spline=fnval(fnder(pp),UT(L_cloud==1 & L_dist ==1));
[n,m]=size(dtau_aero_spline);

ext_coeff=-dtau_aero_spline./(ones(n,1)*dr_spline);

%compute shape coeff. for ext. spectra
for i=1:length(ext_coeff);
    x=log(lambda(wvl_chapp==1));
    y=log(ext_coeff(wvl_chapp==1,i));
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
end

L=prod(ext_coeff(:,:)>0);
a0_ext(L==0)=-99.9999;
alpha_ext(L==0)=99.9999;
gamma_ext(L==0)=99.9999;

%plot residuals
figure(41)
subplot(2,1,1)
plot(UT(L_cloud==1 & L_dist ==1),r(L_cloud==1 & L_dist ==1)-r_spline,'.')
xlabel('UT')
ylabel('Altitude Residuals [km]')
grid on
subplot(2,1,2)
plot(UT(L_cloud==1 & L_dist ==1),tau_aero(:,L_cloud==1 & L_dist ==1)-tau_aero_spline,'.')
xlabel('UT')
ylabel('AOD Residuals')
grid on

%plot AOD and extinction profiles
figure(42)
orient landscape
subplot(1,2,1)
plot(tau_aero(wvl_plot==1,L_cloud==1 & L_dist ==1),r(L_cloud==1 & L_dist ==1),'.',tau_aero_spline(wvl_plot==1,:),r_spline,'k--')
xlabel('Aerosol Optical Depth','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
%set(gca,'xlim',[0 0.6])
set(gca,'ylim',[0 4])
subplot(1,2,2)
plot(ext_coeff(wvl_plot==1,:),r(L_cloud==1 & L_dist ==1))
xlabel('Aerosol Extinction [1/km]','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
%set(gca,'xlim',[0 0.2])
set(gca,'ylim',[0 4])
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);
%if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000') 
%   legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
%          num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(10)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
%end
if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000') 
    legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(10)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end
if strcmp(instrument,'AMES14#1_2001') 
    legend(num2str(lambda(1),'%4.3f'),num2str(lambda(2),'%4.3f'),num2str(lambda(3)','%4.3f'),num2str(lambda(4),'%4.3f'),num2str(lambda(5),'%4.3f'),num2str(lambda(6),'%4.3f'),num2str(lambda(7),'%4.3f'),...
        num2str(lambda(8),'%4.3f'),num2str(lambda(9),'%4.3f'),num2str(lambda(11),'%4.3f'),num2str(lambda(12),'%4.3f'),num2str(lambda(13),'%4.3f'),num2str(lambda(14),'%4.3f'));
end
if strcmp(instrument,'AMES6')
    legend('380.1','450.7','525.3','863.9','1020.7'	)
end

%Overplot Lidar profile
%subplot(1,2,2)
%hold on
%read_lidar_Izana
%plot(Lidar_Aerosol_Ext,Lidar_Altitude,':');

%plot AOD and extinction spectral shape profiles
figure(43)
orient landscape
subplot(1,2,1)
plot(alpha(L_cloud==1 & L_dist ==1),r(L_cloud==1 & L_dist ==1),'.',gamma(L_cloud==1 & L_dist ==1),r(L_cloud==1 & L_dist ==1),'.')
xlabel('AOD Spectrum','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
title(sprintf('%s %s','NASA Ames Sunphotometer',site),'FontSize',14);
set(gca,'xlim',[-0.5 3])
set(gca,'ylim',[0 4])
legend('alpha','gamma')

subplot(1,2,2)
plot(alpha_ext,r(L_cloud==1 & L_dist ==1),'.',gamma_ext,r(L_cloud==1 & L_dist ==1),'.')
xlabel('Extinction Spectrum','FontSize',14)
ylabel('Altitude [km]','FontSize',14)
set(gca,'FontSize',14)
grid on
title(sprintf('%2i/%2i/%2i %g-%g %s',month,day,year,UT_start,UT_end,' UT'),'FontSize',14);
set(gca,'xlim',[-0.5 3])
set(gca,'ylim',[0 4])
legend('alpha','gamma')


%write to file
if strcmp(Result_File,'ON')
    if strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES14#1_2000')
        if strcmp(site,'SAFARI-2000')
            resultfile=['AATS14_' filename '.aero_prof.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 1.0');
            fprintf(fid,'%s %g\r\n',    'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n',    'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
            fprintf(fid,'%s %g\r\n',    'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%g\r\n',       'AOD smoothing parameter',aero_smoothing_para);
            fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_aero==1));
            fprintf(fid,'%s\r\n','UTC[hr] Latitude[deg] Longitude[deg] GPS_Altitude[km] Pressure_Altitude[km] Pressure[hPa] AOD(12) Error_AOD(12) AOD_fit_para(3) Extinction[km-1](12) Extinction_fit_para(3)');
            dummy=[UT',geog_lat',geog_long',GPS_Alt',Press_Alt',press,tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',-gamma',-alpha',a0']';
            dummy=dummy(:,L_cloud==1 & L_dist ==1);  %save only cases where AOD is acceptable
            dummy=[dummy' ,ext_coeff(wvl_aero==1,:)', -gamma_ext',-alpha_ext',a0_ext']';
            fprintf(fid,'%8.5f %9.5f %9.5f %7.3f %7.3f %7.2f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        elseif strcmp(site,'ACE-Asia')
            resultfile=['AATS14_' filename '.aero_prof.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 1.0');
            fprintf(fid,'%s %g\r\n',    'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n',    'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
            fprintf(fid,'%s %g\r\n',    'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%s %g\r\n',    'AOD smoothing parameter:',aero_smoothing_para);
            fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\r\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_aero==1));
            fprintf(fid,'%s\r\n','UTC[hr] Latitude[deg] Longitude[deg] GPS_Altitude[km] Pressure_Altitude[km] Pressure[hPa] AOD(13) Error_AOD(13) AOD_fit_para(3) Extinction[km-1](13) Extinction_fit_para(3)');
            dummy=[UT',geog_lat',geog_long',GPS_Alt',Press_Alt',press,tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',-gamma',-alpha',a0']';
            dummy=dummy(:,L_cloud==1 & L_dist ==1);  %save only cases where AOD is acceptable
            dummy=[dummy' ,ext_coeff(wvl_aero==1,:)', -gamma_ext',-alpha_ext',a0_ext']';
            fprintf(fid,'%8.5f %9.5f %9.5f %7.3f %7.3f %7.2f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        end
    end
end