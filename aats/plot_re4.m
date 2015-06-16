%CLOUD FILTERS
% #1 AOD is large: tau_aero_limit
% #2 measurement cycles with high standard deviations: sd_crit (only at the longest wavelength)
% #3 low Angstrom alpha: alpha_min
% #4 tau_aero_err is large: tau_aero_err_max
% AOD filters #1 to #4 combined
% H2O filters only #1 and #4
% Data that fail #1 or #4 are not written
% Data that fail #2 and/or #3 are flagged
% screened and unscreened data get plotted
%
% 11/22/2000 Filter #4 discards measurements above m_aero_max
% 02/02/2001 Removed UV ozone Bern stuff
%*******************************************************************************************
% Initialization
% if ~exist('filename','var')||(~exist(filename,'file'))
   filename = getfullname('R*.*','aats','read aats file')
% end
prepare

%following 3 lines added by JML 9Sep2005
flag_adj_ozone_foraltitude='yes';  %must set='yes' only for case where ozone is for total column
if strcmp(O3_estimate,'ON'), flag_adj_ozone_foraltitude='no';  end
flag_altitude_dependent_CWV='yes';

% Compute total optical depth (it's not really the total optical depth because it is m_aero).
n=size(data');
tau=(log(data'./(ones(n(1),1)*V0)/f))'./(ones(n(2),1)*(-m_aero));

% filter #4 discard measurements above m_aero_max
L=m_aero<=m_aero_max;
data=data(:,L~=0);
tau=tau(:,L~=0);
tau_ray=tau_ray(:,L~=0);
tau_O4=tau_O4(:,L~=0);
tau_CO2_CH4_N2O=tau_CO2_CH4_N2O(:,L~=0); %added by JML 9Sep2005
UT=UT(L~=0);
press=press(L~=0);
temp=temp(L~=0);
SZA=SZA(L~=0);
m_ray=m_ray(L~=0);
m_aero=m_aero(L~=0);
m_O3=m_O3(L~=0);
m_NO2=m_NO2(L~=0);
m_H2O=m_H2O(L~=0);
r=r(L~=0);
GPS_Alt=GPS_Alt(L~=0);
Press_Alt=Press_Alt(L~=0);
geog_long=geog_long(L~=0);
geog_lat =geog_lat (L~=0);
Sd_volts=Sd_volts(:,L~=0);
Elev_err=Elev_err(L~=0);
Az_err=Az_err(L~=0);
Elev_pos=Elev_pos(L~=0);
Az_pos=Az_pos(L~=0);
Temperature=Temperature(:,L~=0);
if strcmp(source,'Laptop_Otter') || strcmp(source,'Can')
    RH=RH(L~=0);
    H2O_dens_is=H2O_dens_is(L~=0);
end

n=size(data');

%following added by Livingston 12/19/2002 to account for altitude in columnar ozone correction
%use previously calculated (Livingston program ozonemdlcalc.m) 5th order polynomial fit to ozone model
%to calculate fraction of total column ozone above each altitude
coeff_polyfit_tauO3model=[8.60377e-007  -3.26194e-005   3.54396e-004  -1.30386e-003  -5.67021e-003   9.99948e-001];
frac_tauO3 = polyval(coeff_polyfit_tauO3model,r);
if strcmp(flag_adj_ozone_foraltitude,'no'), frac_tauO3=1*ones(1,n(1)); end

% Compute aerosol optical depth
ozone=(frac_tauO3*O3_col_start)';
tau_NO2=NO2_clima*a_NO2;
tau_NO2=(ones(n(1),1)*tau_NO2')';
tau_ozone=O3_col_start*a_O3;
tau_ozone=(frac_tauO3'*tau_ozone')';  %Livingston new
tau_aero= tau-tau_ray.*(ones(n(2),1)*(m_ray./m_aero))...
    -tau_NO2.*(ones(n(2),1)*(m_NO2./m_aero))...
    -tau_ozone.*(ones(n(2),1)*(m_O3./m_aero))...
    -tau_O4.*(ones(n(2),1)*(m_ray./m_aero))...
    -tau_CO2_CH4_N2O.*(ones(n(2),1)*(m_ray./m_aero)); %added by JML 9Sep2005

% interpolate tau_aero for non-windows channels and compute first and second derivative of spectrum
for i=1:n(1)
    wvl_use=(tau_aero(:,i)>0)';        %catch the AOD(lambda) which are < 0 and don't use for Angstrom fit
    x=log(lambda(wvl_chapp==1 & wvl_use==1));
    y=log(tau_aero(wvl_chapp==1 & wvl_use==1,i));
    if ~isempty(x)
        [p,S] = polyfit(x,y,degree);
        switch degree
            case 1
                a0(i)=p(2);
                alpha(i)=-p(1);
                gamma(i)=0;
            case 2
                a0(i)=p(3);
                alpha(i)=-p(2);
                gamma(i)=-p(1);
        end
    else
        a0(i)=-99.9999;
        alpha(i)=99.9999;
        gamma(i)=99.9999;
    end
    x2=log(lambda);
    [y_fit,delta] = polyval(p,x2,S);
    tau_aero(wvl_aero==0,i)=exp(y_fit(wvl_aero==0));
end

% Water Vapor
T =(data.*exp(tau_aero.*(ones(n(2),1)*m_aero)+tau_ray.*(ones(n(2),1)*m_ray)+tau_NO2.*(ones(n(2),1)*m_NO2)+tau_ozone.*(ones(n(2),1)*m_O3)))./(ones(n(1),1)*V0*f)';
U=(-log(T(wvl_water==1,:))./(ones(n(1),1)*a_H2O(wvl_water==1)')')'...
    .^(1./(ones(n(1),1)*b_H2O(wvl_water==1)'))'./(ones(sum(wvl_water),1)*m_H2O);

%===============  begin new code from Feb. 2005; added here by JML 9Sep2005   ======================
nn=size(data);
if strcmp(flag_altitude_dependent_CWV,'yes')
    H2O_fit_err=0.02*H2O_conv; % absolute error of H2O fit in atm-cm decreased error by factor 5 (a guess). BS 2/2/07
    path_H2Ocoeff='C:\case_studies\AATS\xsect\';
    filenameH2O='AATS14_940nm_LBLRTMcoeff_022205.txt';
    fidH2Ocoeff=fopen([path_H2Ocoeff filenameH2O],'rt');
    line = fgetl(fidH2Ocoeff);		%skip end-of-line character
    line = fgetl(fidH2Ocoeff);		%skip end-of-line character
    dataH2O=fscanf(fidH2Ocoeff,'%d %f %f %f',[4 inf]);
    zkm_LBLRTM_calcs=dataH2O(1,:);
    afit_H2O=dataH2O(2,:);
    bfit_H2O=dataH2O(3,:);
    cfit_H2O=dataH2O(4,:);
    fclose(fidH2Ocoeff);

    for j=1:nn(2),
        kk=find(abs(GPS_Alt(j))>=zkm_LBLRTM_calcs); %abs() needed to avoid crash when GPS altitudes are negative
        kz=kk(end);
        CWV1=(-log(T(wvl_water==1,j)./cfit_H2O(kz))./afit_H2O(kz)).^(1./bfit_H2O(kz))./m_H2O(j);
        CWV2=(-log(T(wvl_water==1,j)./cfit_H2O(kz+1))./afit_H2O(kz+1)).^(1./bfit_H2O(kz+1))./m_H2O(j);
        CWVint_atmcm = CWV1 + (GPS_Alt(j)-zkm_LBLRTM_calcs(kz))*(CWV2-CWV1)/(zkm_LBLRTM_calcs(kz+1)-zkm_LBLRTM_calcs(kz));
        Ucalc(j)=CWVint_atmcm;
    end
    Uold=U;
    U=Ucalc;
end
%===============  end new code (Feb. 2005)   ======================

%Water Vapor correction
%%nn=size(data);  %note that this statement has been moved above...JML 9Sep2005
tau_H2O=((ones(nn(2),1)*a1_H2O')'.*(ones(nn(1),1)*(m_H2O.*U))+(ones(nn(2),1)*a2_H2O')'.*(ones(nn(1),1)*(m_H2O.*U).^2))./(ones(nn(1),1)*m_H2O);
if (strcmp(O3_estimate,'OFF'))
    tau_aero=tau_aero-tau_H2O.*(ones(n(2),1)*(m_ray./m_aero));
end

%Ozone retrieval
O3_col_fit=O3_col_start*ones(1,size(tau_aero,2));  %added 12/2002 jml
if (strcmp(O3_estimate,'ON'))
    O3guess=0.200;  %always start here to permit 0.200<=O3_col<=0.400;
    for i=1:n(1)
        % [tau_a,tau_2,tau_3,O3_col2,p]=ozone_box(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,...
        % m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3_col_start,degree);

        %         [tau_a,tau_2,tau_3,O3_col,p]= ozone2(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,...
        %             m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3_col_start,degree);
        %
        [tau_a,tau_2,tau_3,O3_col,p]= ozone3(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,UT(i),GPS_Alt(i),...
            m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3guess,degree);

%         [UT(i) O3_col]

        tau_aero_sav(i,:) =tau_a';
        tau_NO2_sav(i,:)  =tau_2';
        tau_ozone_sav(i,:)=tau_3';
        ozone(i)=O3_col;
%         O3guess=O3_col;
        switch degree
            case 1
                a0(i)=p(2);
                alpha(i)=-p(1);
                gamma(i)=0;
            case 2
                a0(i)=p(3);
                alpha(i)=-p(2);
                gamma(i)=-p(1);
        end
    end
    clear tau_a
    clear tau_2
    clear tau_3
    tau_aero =tau_aero_sav';
    tau_NO2  =tau_NO2_sav';
    tau_ozone=tau_ozone_sav';
end

%Diffuse light correction
if strcmp(diffuse_corr,'ON') & (strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES6'))
    if strcmp(instrument,'AMES14#1_2001')
        method=2; % method=1 use alpha from 380 to 1020, method=2 use alpha from 1020 to 1558
        [F,runc_F]=diffuse(a0,alpha,gamma,method,xsect_dir);
    end
    if strcmp(instrument,'AMES6')
        method=1; % method=1 use alpha from 380 to 1020, method=2 use alpha from 1020 to 1558
        [F,runc_F]=diffuse(a0,alpha,gamma,method,xsect_dir);
        F=F(:,[2 3 5 9 10 11]);
        runc_F=runc_F(:,[2 3 5 9 10 11]);
    end

    tau_aero=tau_aero.*F';
    % interpolate tau_aero for non-windows channels and compute first and second derivative of spectrum
    for i=1:n(1)
        x=log(lambda(wvl_chapp==1));
        y=log(tau_aero(wvl_chapp==1,i));
        [p,S] = polyfit(x,y,degree);
        switch degree
            case 1
                a0(i)=p(2);
                alpha(i)=-p(1);
                gamma(i)=0;
            case 2
                a0(i)=p(3);
                alpha(i)=-p(2);
                gamma(i)=-p(1);
        end
        x2=log(lambda);
        [y_fit,delta] = polyval(p,x2,S);
        tau_aero(wvl_aero==0,i)=exp(y_fit(wvl_aero==0));
    end
end

% Error in aerosol optical depth according to Russell JGR, 1993 equation A15b
% extended for tau_O4 and tau_H2O

% expression for dm/m is from Reagan report
i=find(m_ray<=2);
m_err(i)=0.0003;
j=find(m_ray>2);
m_err(j)=0.0003.*(m_ray(j)/2).^2.2;

tau_aero_err1=tau.*(ones(n(2),1)*m_err);
tau_aero_err2=(ones(n(1),1)*V0err)'   ./(ones(n(2),1)*m_aero);
tau_aero_err3=(ones(n(1),1)*dV)'./data./(ones(n(2),1)*m_aero);
tau_aero_err4=tau_r_err*tau_ray.*   (ones(n(2),1)*(m_ray./m_aero));
tau_aero_err5=tau_O3_err*tau_ozone.*(ones(n(2),1)*(m_O3./m_aero));
tau_aero_err6=tau_NO2_err*tau_NO2.* (ones(n(2),1)*(m_NO2./m_aero));
tau_aero_err7=tau_O4_err*tau_O4.*   (ones(n(2),1)*(m_ray./m_aero));
tau_aero_err8=tau_H2O_err*tau_H2O.* (ones(n(2),1)*(m_H2O./m_aero));
if strcmp(instrument,'AMES14#1') | strcmp(instrument,'AMES14#1_2000')  | strcmp(instrument,'AMES14#1_2001')  | strcmp(instrument,'AMES14#1_2002')
    % take into account tracking error for AATS-14 only
    track_err=(Elev_err.^2+Az_err.^2).^0.5;
    tau_aero_err9=(ones(n(1),1)*slope)'.*(ones(n(2),1)*track_err) ./(ones(n(2),1)*m_aero);
else
    tau_aero_err9=0;
end
if (strcmp(diffuse_corr,'ON'))
    %error of diffuse light correction if on
    tau_aero_err10=tau_aero.*runc_F'; 
else
    tau_aero_err10=0;
end

tau_aero_err11=tau_CO2_CH4_N2O_abserr.*ones(n(2),1)*(m_ray./m_aero); %added by JML 9Sep2005...also added to rms calc below

%rms
tau_aero_err=(tau_aero_err1.^2+tau_aero_err2.^2+tau_aero_err3.^2+tau_aero_err4.^2+tau_aero_err5.^2+tau_aero_err6.^2+tau_aero_err7.^2+tau_aero_err8.^2+tau_aero_err9.^2+tau_aero_err10.^2+tau_aero_err11.^2).^0.5;

% interpolate tau_aero_err for non-windows channels
x1=log(lambda);
x=log(lambda(wvl_aero==1,:));
y=tau_aero_err(wvl_aero==1,:);
tau_aero_err=interp1(x,y,x1);

% Relative error in CWV according to Schmid et al., JGR 1996 equations 16-19
H2O_err1=((ones(n(1),1)*V0err(wvl_water==1))./((ones(n(1),1)*b_H2O(wvl_water==1)).*(ones(n(1),1)*a_H2O(wvl_water==1)).*((ones(sum(wvl_water),1)*m_H2O).*U)'.^(ones(n(1),1)*b_H2O(wvl_water==1))))';
H2O_err2=(((ones(sum(wvl_water),1)*m_H2O).*tau_aero_err(wvl_water==1,:))'./((ones(n(1),1)*b_H2O(wvl_water==1)).*(ones(n(1),1)*a_H2O(wvl_water==1)).*((ones(sum(wvl_water),1)*m_H2O).*U)'.^(ones(n(1),1)*b_H2O(wvl_water==1))))';
H2O_err3=(-1./b_H2O(wvl_water==1).*(ones(n(1),1)*a_H2O_err))';
H2O_err4=H2O_fit_err./U;
H2O_err=(H2O_err1.^2+H2O_err2.^2+H2O_err3.^2+H2O_err4.^2).^0.5;

%CLOUD FILTERS
% #1 AOD is large
L_AOD=all(tau_aero(wvl_aero==1,:)<=tau_aero_limit);

% #2 measurement cycles with high standard deviations
rel_sd=Sd_volts./data;
L_SD_aero=all(rel_sd(wvl_aero==1,:)<=sd_crit_aero);

L_SD_H2O=all(rel_sd(:,:)<=sd_crit_H2O);
%L_SD_H2O=rel_sd(wvl_water==1,:)<=sd_crit_H2O;

% #3 low Angstrom alpha
L_alpha=alpha>=alpha_min;

% #3b low Angstrom alpha
gamma_max = max(gamma);
L_gamma=gamma<=gamma_max;

% #4 tau_aero_err is large
L_err=all(tau_aero_err<=tau_aero_err_max);

% all cloud filters combined for AOD and H2O
L_cloud=L_AOD.*L_err.*L_SD_aero.*L_alpha.*L_gamma;
%L_H2O=L_AOD.*L_err; % for ARM groundbased
L_H2O=L_AOD.*L_err.*L_SD_H2O; % for airborne

slant_U=m_H2O(L_H2O==1).*U(L_H2O==1)/H2O_conv;
disp(sprintf('%s%g: %g','Total points with m<', m_aero_max,length(L_cloud)))
disp(sprintf('%s: %g','Total points with bad H2O', length(L_H2O)-sum(L_H2O)))
disp(sprintf('%s: %g','Total points with bad AOD', length(L_cloud)-sum(L_cloud)))
disp(sprintf('%s: %4.2f-%4.2f','Range of SWP[cm]', min(slant_U),max(slant_U)))

%START PLOTTING

%plot ozone columnn dens
figure(1)
subplot(3,1,1)
plot(UT,ozone*1000,UT,ozone*1000./frac_tauO3')
xlabel('UT [h]','FontSize',14);
ylabel('Ozone [DU]','FontSize',14);
title(sprintf('%s %2i.%2i.%2i %s %g-%g %s',site,day,month,year,filename,UT_start,UT_end,'UT'),'FontSize',14);
set(gca,'FontSize',14)

subplot(3,1,2)
plot(UT(L_cloud==1),ozone(L_cloud==1)*1000,'.',UT(L_cloud==1),ozone(L_cloud==1)*1000./frac_tauO3(L_cloud==1)','.')
xlabel('UT [h]','FontSize',14);
ylabel('Ozone [DU]','FontSize',14);
set(gca,'FontSize',14)
legend('above instrument','sea level')
grid on

subplot(3,1,3)
plot(UT,m_O3,'.',UT,m_aero,'.',UT,m_ray,'.')

xlabel('UT [h]','FontSize',14);
ylabel('m','FontSize',14);
set(gca,'FontSize',14)
%set(gca,'ylim',[0 100])
legend('O_3','Aerosol','Rayleigh')

% plot H2O uncertainty as a function of altitude
figure(2)
subplot(1,2,1)
plot(H2O_err1(L_H2O==1)*100,r(L_H2O==1),H2O_err2(L_H2O==1)*100,r(L_H2O==1),abs(H2O_err3(L_H2O==1))*100,r(L_H2O==1),H2O_err4(L_H2O==1)*100,...
    r(L_H2O==1),H2O_err(L_H2O==1)*100,r(L_H2O==1))
xlabel('CWV Uncertainty [%]','FontSize',14);
ylabel('Altitude [km]','FontSize',14);
title(sprintf('%s %2i.%2i.%2i %s %g-%g %s',site,day,month,year,filename,UT_start,UT_end,'UT'),'FontSize',14);
legend('Calibration','Aerosol','Spectroscopy','Model','Total')
set(gca,'FontSize',14)
% Convert to absolute error in CWV
H2O_err1=H2O_err1.*U/H2O_conv;
H2O_err2=H2O_err2.*U/H2O_conv;
H2O_err3=H2O_err3.*U/H2O_conv;
H2O_err4=H2O_err4.*U/H2O_conv;
H2O_err=H2O_err.*U/H2O_conv;
subplot(1,2,2)
plot(H2O_err1(L_H2O==1),r(L_H2O==1),H2O_err2(L_H2O==1),r(L_H2O==1),abs(H2O_err3(L_H2O==1)),r(L_H2O==1),H2O_err4(L_H2O==1)....
    ,r(L_H2O==1),H2O_err(L_H2O==1),r(L_H2O==1))
xlabel('CWV Uncertainty (g/cm²)','FontSize',14);
ylabel('Altitude [km]','FontSize',14);
set(gca,'FontSize',14)

%plot aerosol depth
figure(3)
subplot(4,1,1)
plot(UT,tau_aero(wvl_aero==1,:));
xx=get(gca,'xlim');
set(gca,'xlim',xx)
xlabel('UT');
ylabel('Aerosol Optical Depth');
title(sprintf('%s %2i/%2i/%2i %s %s',site,month,day,year,filename,flag_calib));
grid on
%set(gca,'ylim',[0 inf])
%if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000')
%   legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
%          num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(10)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
%  end
if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000')
    legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(10)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end
if strcmp(instrument,'AMES14#1_2001') |  strcmp(instrument,'AMES14#1_2002')
    legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end
if strcmp(instrument,'AMES6')
    legend('380.1','450.7','525.3','863.9','1020.7'	)
end

subplot(4,1,2)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
grid on
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD screened');

subplot(4,1,3)
plot(UT(L_cloud==1),rel_sd(wvl_aero==1,L_cloud==1),'.');
grid on
set(gca,'xlim',xx)
xlabel('UT');
ylabel('Rel Stdev - screened');

subplot(4,1,4)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
set(gca,'xlim',xx)
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')

%plot Angstrom exponent
figure(301);
subplot(2,1,1);
plot(UT(L_cloud==1),tau_aero([1:6],L_cloud==1))
xx=get(gca,'xlim');
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD screened');
title(sprintf('%s %2i/%2i/%2i %s %s',site,month,day,year,filename,flag_calib));
grid on
legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)));
subplot(2,1,2);
plot(UT(L_cloud==1),tau_aero([7:9,11,13:14],L_cloud==1))
xx=get(gca,'xlim');
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD screened');
legend(num2str(lambda(7)),num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(13)),num2str(lambda(14))  );


figure(4)
subplot(2,1,1)
switch degree
    case 1
        plot(UT,alpha,'.');
        xx=get(gca,'xlim');
        set(gca,'xlim',xx)
        title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
        ylabel('alpha');
        xlabel('UT');
        grid on
        subplot(2,1,2)
        plot(UT(L_cloud==1),alpha(L_cloud==1),'.');
        set(gca,'xlim',xx)
        xlabel('UT');
        ylabel('Alpha screened');
        grid on
    case 2
        plot(UT,alpha,'.',UT,gamma,'.');
        xx=get(gca,'xlim');
        set(gca,'xlim',xx)
        title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
        ylabel('coeff');
        xlabel('UT');
        legend('alpha','gamma')
        grid on
        subplot(2,1,2)
        plot(UT(L_cloud==1),alpha(L_cloud==1),'.',UT(L_cloud==1),gamma(L_cloud==1),'.');
        set(gca,'xlim',xx)
        xlabel('UT');
        ylabel('coeff screened');
        grid on
end

%plot water vapor
figure(5)
subplot(4,1,1)
plot(UT,U/H2O_conv,'.');
xx=get(gca,'xlim');
set(gca,'xlim',xx)
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
ylabel('H2O Column [cm]');
xlabel('UT');
grid on

subplot(4,1,2)
plot(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
set(gca,'xlim',xx)
ylabel('H2O Column [cm] - screened');
xlabel('UT');
grid on

subplot(4,1,3)
plot(UT(L_H2O==1),rel_sd(:,L_H2O==1),'.');
grid on
set(gca,'xlim',xx)
xlabel('UT');
ylabel('Rel Stdev - screened');

subplot(4,1,4)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
set(gca,'xlim',xx)
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')


%plot aerosol optical depth error
figure(7)
subplot(2,1,1)
plot(UT,tau_aero_err(wvl_aero==1,:),'.');
xx=get(gca,'xlim');
set(gca,'xlim',xx)
grid on
xlabel('UT');
ylabel('Aerosol Optical Depth Error');
title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
subplot(2,1,2)
plot(UT(L_cloud==1),tau_aero_err(wvl_aero==1,L_cloud==1),'.');
xlabel('UT');
ylabel('Aerosol Optical Depth Error');
set(gca,'xlim',xx)
grid on

%AOD on log-log
figure(8)
tau_a_max=max(tau_aero(:,L_cloud==1)');
tau_a_min=min(tau_aero(:,L_cloud==1)');
tau_a_std=std(tau_aero(:,L_cloud==1)');
tau_a_mean=mean(tau_aero(:,L_cloud==1)');
tau_a_err=mean(tau_aero_err(:,L_cloud==1)');
loglog(lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),'ko','MarkerSize',8,'MarkerFaceColor','k');
hold on

% AATS-6
%lambda_AATS6=[0.3801,0.4509,0.5257,0.8645,1.0213];
%tau_AATS6=[0.2128,0.1718,0.1429,0.0561,0.0656]; %comparison 4/3/2001
%tau_AATS6=[0.8577 0.7296 0.6206 0.4741 0.4186]; %comparison 4/3/2001
%loglog(lambda_AATS6,tau_AATS6,'rs','MarkerSize',9,'MarkerFaceColor','r')

% MODIS
%  lambda_MODIS=[0.47,  0.55,   0.66, 0.86, 1.24, 1.64, 2.1];
%tau_MODIS=   [0.404, 0.1536, 0.05, NaN,  NaN,  NaN,  NaN];  % Skukuza       Aug 22, 2000
%tau_MODIS=   [0.32,  0.28,   0.24, 0.18, 0.12, 0.09, 0.06]; % Inhaca Island Aug 24, 2000
%  tau_MODIS=   [0.43,  0.25,   0.14, NaN,  NaN,  NaN,  NaN];  % Kaoma         Sep 01, 2000
%  tau_MODIS_err=[0.02, 0.03,   0.03, NaN,  NaN,  NaN,  NaN];  % Kaoma         Sep 01, 2000

% MISR
% lambda_MISR=    [0.446       0.558       0.672       0.866];
%tau_MISR_unity=[1.247       1.000       0.794       0.537]  % Mixture 51
%tau_MISR_unity=[1.253       1.000       0.793       0.537] %  Mixture 52
%tau_MISR_unity=[1.073       1.000       0.952       0.863] %  Mixture 11
%tau_MISR_unity=[1.194       1.000       0.843       0.637] %  Mixture 21

%tau_MISR_558=[0.278]; %April 13, ACE-Asia 4:46 UT
%tau_MISR_558=[0.927]; %September, 03, 2000 SAFARI-2000 Sua Pan 8:52 UT, -20.483S 26.069E
%tau_MISR_558=[0.904]; %September, 03, 2000 SAFARI-2000 Sua Pan 8:52 UT, -20.641S 26.055E
%tau_MISR_558=[0.818]; %September, 03, 2000 SAFARI-2000 Sua Pan 8:52 UT, -20.628S 25.886E that is a fill in from next pixel North.
%tau_MISR_558=[0.571]; %September 11, 2000 SAFARI-2000  Off Namibia,9:37:38 UT,  -21.416 S, 12.335 E (center of pixel)
%tau_MISR_558=[0.813]; %September 11, 2000 SAFARI-2000  Off Namibia,9:37:38 UT,  -21.564 S, 12.321 E (center of pixel)

%tau_MISR=tau_MISR_558*tau_MISR_unity;

%tau_MISR_err= [0.05 0.05 0.05 0.05];

% TOMS
% lambda_TOMS=[0.380];
%tau_TOMS=[0.553]; %Sept 2, 2000 SAFARI-2000
% tau_TOMS=[2.38];   %Sept 6, 2000 SAFARI-2000
%tau_TOMS=[0.065]; %Sept 7, 2000 SAFARI-2000
% tau_TOMS_err=max([0.1, 0.3*tau_TOMS]); %Error is 0.1 or 30% whichever is larger

% SeaWiFS
%lambda_SeaWiFS_standard=[0.865]; %ACE-Asia 4/12/2001
%AOD_SeaWiFS_standard=[0.31];     %ACE-Asia 4/12/2001
% lambda_SeaWiFS= [  443    510    670   865]/1e3;
%AOD_SeaWiFS=    [0.783  0.727  0.540 0.463]; %ACE-Asia 4/9/2001, Location 38.1 N, 133.7 E, 3:07 UT
%err_AOD_SeaWiFS=[0.056  0.045  0.035 0.035]; %ACE-Asia 4/9/2001
%AOD_SeaWiFS=    [0.361  0.330  0.271 0.210]; %ACE-Asia 4/12/2001, Location 32.91 N, 127.83 E, 3:37 UT
%err_AOD_SeaWiFS=[0.016  0.015  0.014 0.012]; %ACE-Asia 4/12/2001
%  AOD_SeaWiFS=    [0.851  0.785  0.663 0.611]; %ACE-Asia 4/14/2001, Location 32.127 N, 132.7 E, 3:25 UT
%  err_AOD_SeaWiFS=[0.031  0.026  0.019 0.019]; %ACE-Asia 4/14/2001


% Cimel
% lambda_Cimel=[1020 870	670 500 440 380 340]/1e3;
%tau_Cimel=[0.118995	0.127637	0.227318	0.441236	0.553243	0.712925	0.814938]; % Aug 22, Skukuza Level 1.0
%tau_Cimel=[0.118974	0.127614	0.227275	0.441137	0.553111	0.712733	0.814683]; % Aug 22, 2000, 10:12 Skukuza Level 1.5
%tau_Cimel=[0.116345	0.122751	0.215294	0.415734	0.521132	0.668346	0.761888]; % Aug 22, 2000, 9:57 Skukuza Level 1.5
%tau_Cimel=[0.117903684	0.12563418	0.222397307	0.430794956	0.540091741	0.694662208	0.793189151];% Aug 22, 2000, Interpolated to 10:06 Skukuza Level 1.5
%tau_Cimel=[0.116322	0.124203	0.214694	0.419131	0.526887	0.674586	0.771716];   % Aug 22, 2000,  8:27:35	Terra Overpass
%tau_Cimel=[0.114967    0.155934	0.23813	    0.358868	0.428172	0.536236	0.598034];% Aug 24, 2000   8:37:33 Inhaca Island Level 2
%tau_Cimel=[0.10258	    0.140997	0.219652	0.332219	0.398107	0.500058	0.558795];% Aug 24, 2000   8:22:32 Inhaca Island Level 2
%tau_Cimel=[0.129905	0.18128	    0.325315	0.58241	    0.717418	0.90976	    1.061124];% Sep 1,  2000   8:36:15 Kaoma, Level 2
%tau_Cimel=[0.108952    0.172748	0.308456	0.563022	0.689595	0.867243	1.020407];% Sep 1,  2000   9:09:34 Kaoma, Level 1
%tau_Cimel=[0.189477	0.282863	0.512417	NaN	        1.124408	NaN         NaN     ];% Sep 03, 2000,  8:45:37 UT, Sua Pan, Level 2,
%tau_Cimel=[0.331086	0.473774	0.809929	1.41482	    1.708725	2.059931	2.311603];% Sep 06, 2000,  7:55:46 UT, Senanga, Level 2
%tau_Cimel=[0.310551	0.445488	0.768765	1.345765	1.611428	1.946164	2.183868];% Sep 06, 2000,  8:11:41 UT, Mongu, Level 2
%tau_Cimel=[0.310781	0.447566	0.774888	1.354877	1.624222	1.961968	2.207142];% Sep 06, 2000,  9:11:43 UT, Mongu Level 2
%tau_Cimel=[0.304739	0.438461	0.760858	1.328046	1.595065	1.933854	2.174415];% Sep 06, 2000, 10:11:16 UT, Mongu Level 2
%tau_Cimel=[0.084465	0.109181	0.17236  	0.283369	0.326764	0.405387	0.454072];% Sep 16, 2000,  9:21:46 UT, Etosha Pan Level 2
%  tau_Cimel=[0.073286	0.097409	0.153234	0.249464	0.287107	0.366537	0.406768];% Sep 16, 2000,  10:51:48 UT, Etosha Pan Level 2
%
%  tau_Cimel_err=[0.01  0.01     0.01     0.015     0.015     0.015     0.02    ];

%loglog(lambda_Cimel,tau_Cimel,'rs','MarkerSize',9,'MarkerFaceColor','r')
%loglog(lambda_TOMS,tau_TOMS,'bs','MarkerSize',9,'MarkerFaceColor','b')
%loglog(lambda_MODIS,tau_MODIS,'gs','MarkerSize',9,'MarkerFaceColor','g')
%loglog(lambda_MISR,tau_MISR,'bs','MarkerSize',9,'MarkerFaceColor','b')
%loglog(lambda_SeaWiFS,AOD_SeaWiFS,'ro','MarkerSize',9,'MarkerFaceColor','r')
%loglog(lambda_SeaWiFS_standard,AOD_SeaWiFS_standard,'ms','MarkerSize',9,'MarkerFaceColor','m')

set(gca,'xlim',[.30 1.6]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);

if strcmp(instrument,'AMES14#1_2002')
    set(gca,'xlim',[.30 2.2]);
    set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8 2.0 2.2]);
end

%yerrorbar('loglog',0.3,1.6, 1e-2  ,2.5,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),...
%   -tau_a_min(wvl_aero==1)+tau_a_mean(wvl_aero==1),tau_a_max(wvl_aero==1)-tau_a_mean(wvl_aero==1),'mo')
%yerrorbar('loglog',0.3,1.6, 1e-2  ,2.5,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_std(wvl_aero==1),'ko')

xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Aerosol Optical Depth','FontSize',14);

title(sprintf('%s %2i/%2i/%2i %s %g-%g %s %s %s',site,month,day,year,filename,UT_start,UT_end,'UT','V0',flag_calib),'FontSize',14);
set(gca,'FontSize',14)

yerrorbar('loglog',0.3,1.6, 0.001 ,2.5,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),'ko')
%yerrorbar('loglog',0.3,1.6,0.05, 2,lambda_SeaWiFS,AOD_SeaWiFS,err_AOD_SeaWiFS,'r.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,tau_Cimel,tau_Cimel_err,'r.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_MISR,tau_MISR,tau_MISR_err,'b.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.6,lambda_TOMS,tau_TOMS,tau_TOMS_err,'b.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.6,lambda_MODIS,tau_MODIS,tau_MODIS_err,'g.')


%legend('AATS-14','AATS-6')
%legend('AATS-14','SeaWiFS Hsu algo','SeaWiFS std algo')
%legend('AATS-14','SeaWiFS Hsu algo')
%legend('AATS-14','TOMS')
%legend('AATS-14','Cimel','TOMS')
%legend('AATS-14','Cimel')
%legend('AATS-14','Cimel','MISR best fit', 'MISR 2nd best fit')
%legend('AATS-14','MISR best fit','MISR 2nd best fit')
%legend('AATS-14','Cimel','MODIS')

grid on
hold off

%lambda_MFR=[415	501	615	675	868]/1e3;
%tau_MFR=[0.0786	0.0736	0.0696	0.066	0.0668];
%MFR_error=[0.007148971	0.006753354	0.006716233	0.007197763	0.006928765];
% for MFR
%yerrorbar('loglog',0.3,1.6, 1e-4 ,1,lambda_MFR,tau_MFR,MFR_error,'b*')
%legend ('AATS-14','MFR on P. del Teide')
% for AVHRR
%yerrorbar('loglog',0.3,0.8, 1e-4  ,1,[0.63 0.86],[0.35 0.28],[0.02 0.02],'b*')
%yerrorbar('loglog',0.3,1.6, 1e-4  ,1,[0.63 0.86],[0.35 0.28],[0.02 0.01],[0.04 0.02],'b*')
%legend ('AATS-14: 16.13-16.35 UT','AVHRR: 15.58 UT')
%hold off

%Altitude profile
figure(9)
subplot(1,4,1)
plot(tau_aero(wvl_aero==1,L_cloud==1),r(L_cloud==1),'.')
title(sprintf('%s %2i.%2i.%2i %s %g-%g',site,day,month,year,filename,UT_start,UT_end));
xlabel('Aerosol Optical Depth')
ylabel('Altitude [km]')
grid on
subplot(1,4,2)
plot(U(L_H2O==1)/H2O_conv,r(L_H2O==1),'.')
grid on
xlabel('Columnar Water Vapor [g/cm2]')
subplot(1,4,3)
plot(temp-273.15,r,'.')
grid on
xlabel('Temperature [°C]')
subplot(1,4,4)
plot(press,r,'.')
grid on
xlabel('Pressure[hPa]')

figure(10)
subplot(4,1,1)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
title(sprintf('%s %2i.%2i.%2i %s %g-%g',site,day,month,year,filename,UT_start,UT_end));
%axis([xx 0 8])
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')
grid on
subplot(4,1,2)
plot(UT,geog_lat,'.')
%axis([xx -inf inf])
ylabel('Latitude (°)')
grid on
subplot(4,1,3)
plot(UT,geog_long,'.')
ylabel('Longitude (°)')
%axis([xx -inf inf])
grid on
xlabel('UT')
subplot(4,1,4)
plot(UT,Elev_err,'.',UT,Az_err,'.')
ylabel('Track Err(°)')
%axis([xx -inf inf])
legend('ele','azi')
grid on
xlabel('UT')

%calculate Transmitttance
Trans=(data'./(ones(n(1),1)*V0)/f)';
figure(11)
plot(UT(L_cloud==1),Trans(:,L_cloud==1));

%Prepare output
%write Gaines-Hipskind format to file
if strcmp(archive_GH,'ON')
    if strcmp(site,'SOLVE2')
        dataarchive_dir='c:\beat\data\solve2\';
        FlightNo=1; %don't know any flight numbers yet
        [ntimwrt,filename_arc]=archive_AATS14_SOLVE2_GH(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
            L_cloud,L_H2O,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,ozone,tau_aero,tau_aero_err,...
            O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min);
    end
    if strcmp(site,'ICARTT')
        dataarchive_dir='c:\beat\data\ICARTT\';
        unc_ozone(1:length(UT))=-9.999;
        [ntimwrt,filename_arc]=archive_AATS14_ICARTT(filename,dataarchive_dir,flight_no,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
            L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,O3_col_fit,unc_ozone,tau_aero,tau_aero_err,...
            O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min,flag_calib);
    end
end

if strcmp(Result_File,'ON')
    if strcmp(instrument,'AMES14#1')
        resultfile=[filename '.asc']
        fid=fopen([path resultfile],'w');
        fprintf(fid,'%s\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14, unit #1');
        fprintf(fid,'%s %2i.%2i.%4i\n', site,day,month,year);
        fprintf(fid,'%s %s %s\n', 'Date processed:',date, 'by Beat Schmid, Revision 1.1');
        fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
        fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\n', 'aerosol wavelengths [10^-6 m]', lambda(wvl_aero==1));
        fprintf(fid,'%s\n','UT,Latitude,Longitude,Altitude[km],p[hPa],H2O[cm],O3[DU],Aerosol Optical Depth (13), Error in Aerosol Optical Depth (13),H2O Error[cm]');
        fprintf(fid,'%7.4f %8.4f %8.4f %7.3f %7.2f %7.4f %5.1f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f \n',...
            [UT',geog_lat',geog_long',r',press,U'/H2O_conv,ozone'*1000,tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',H2O_err']');
        fclose(fid);
    elseif strcmp(instrument,'AMES14#1_2000') | strcmp(instrument,'AMES14#1_2001')| strcmp(instrument,'AMES14#1_2002')
        if strcmp(site,'SAFARI-2000')
            resultfile=['AATS14_',filename,'.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 1.5');
            fprintf(fid,'%s %g\r\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n', 'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
            fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%s %g %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
            fprintf(fid,'%s', 'aerosol wavelengths [10^-6 m] ');
            fprintf(fid,'%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\r\n', lambda(wvl_aero==1));
            fprintf(fid,'%s %s %s %s\r\n','UT[h] Lat[deg] Long[deg] GPS_Alt[km] p_Alt[km] p[hPa] H2O[cm] H2O_Err[cm] AOD_flag',num2str(lambda(wvl_aero==1)'*1000,'AOD%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),'a2_fit a1_fit a0_fit');
            dummy=[UT',geog_lat',geog_long',GPS_Alt',Press_Alt',press,U'/H2O_conv,H2O_err',L_cloud',tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',-gamma',-alpha',a0']';
            dummy=dummy(:,L_H2O==1);  %save only cases where water vapor is acceptable
            fprintf(fid,'%08.5f %9.5f %9.5f %7.3f %7.3f %7.2f %7.4f %7.4f %13d %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        elseif strcmp(site,'ACE-Asia') | strcmp(site,'ADAM')| strcmp(site,'Aerosol IOP') | strcmp(site,'ALIVE')
            resultfile=['AATS14_',filename,'.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 2.0');
            fprintf(fid,'%s %g\r\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n', 'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
            fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f %s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min,'Max Gamma:',gamma_max);
            fprintf(fid,'%s %g %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
            fprintf(fid,'%s', 'aerosol wavelengths [10^-6 m] ');
            fprintf(fid,'%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f\r\n', lambda(wvl_aero==1));
            fprintf(fid,'%s %s %s %s\r\n','UT[h] Lat[deg] Long[deg] GPS_Alt[km] p_Alt[km] p[hPa] H2O[cm] H2O_Err[cm] AOD_flag',num2str(lambda(wvl_aero==1)'*1000,'AOD%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),'a2_fit a1_fit a0_fit');
            dummy=[UT',geog_lat',geog_long',GPS_Alt',Press_Alt',press,U'/H2O_conv,H2O_err',L_cloud',tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',-gamma',-alpha',a0']';
            dummy=dummy(:,L_H2O==1);  %save only cases where water vapor is acceptable
            fprintf(fid,'%08.5f %9.5f %9.5f %7.3f %7.3f %7.2f %7.4f %7.4f %13d %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        end
    end

    if strcmp(instrument,'AMES6')
        if strcmp(site,'Oklahoma')
            resultfile=['AATS6_',filename(1:7),'.asc']
            fid=fopen([path resultfile],'w');
            fprintf(fid,'%s\n','NASA Ames Airborne Tracking 6-Channel Sunphotometer, AATS-6');
            fprintf(fid,'%s %s %s\n', 'Date processed:',date, 'by Beat Schmid, Revision 0.2');
            fprintf(fid,'%s %2i/%2i/%4i\n',site,month,day,year);
            fprintf(fid,'%s %g %s %g %s %g \n', 'Latitude:',geog_lat(1),'Longitude:',geog_long(1),'Altitude[m]',r(1)*1000);
            fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\n', 'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.2f\n', 'Relative Std Dev Filter [%]:',100*sd_crit);
            fprintf(fid,'%s %g\n', 'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %3.1f\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%s %g %s %g\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
            fprintf(fid,'%s %6.1f %6.1f %6.1f %6.1f %6.1f\n', 'Aerosol wavelengths[nm]:', 1000*lambda(wvl_aero==1));
            fprintf(fid,'%s\n','UT,p[hPa],H2O[cm], H2O Error[cm],AOD_flag,alpha_Angstrom,Aerosol Optical Depth (5), Error in Aerosol Optical Depth (5)');
            dummy= [UT',press,U'/H2O_conv,H2O_err',L_cloud',alpha',tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)']';
            dummy=dummy(:,L_H2O==1);
            fprintf(fid,'%7.5f %7.2f %7.4f %7.4f %g %6.3f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',dummy);
            fclose(fid);
            clear dummy
        elseif strcmp(site,'ACE-Asia')
            FlightNo=05
            resultfile=['AATS6_',filename(1:7),'.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 6-Channel Sunphotometer, AATS-6');
            fprintf(fid,'%s  Date:%i/%2i/%4i  NCAR C130 Flight Number:%2i\r\n','ACE-ASIA',month,day,year,FlightNo);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 1.0');
            fprintf(fid,'%s %g\r\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n', 'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter [%]:',100*sd_crit);
            fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%s %g %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
            fprintf(fid,'%s %6.1f %6.1f %6.1f %6.1f %6.1f\r\n', 'aerosol wavelengths[nm]:', 1000*lambda(wvl_aero==1));
            fprintf(fid,'%s\n','UTC[hr],Latitude[deg],Longitude[deg],GPS_Altitude[km],Pressure_Altitude[km],Pressure[hPa],H2O[cm],H2O Error[cm],AOD_flag,alpha_Angstrom,Aerosol Optical Depth(5),Error in Aerosol Optical Depth(5)');
            dummy=[UT',geog_lat',geog_long',GPS_Alt',Press_Alt',press,U'/H2O_conv,H2O_err',L_cloud',alpha',tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)']';
            dummy=dummy(:,L_H2O==1);  %save only cases where water vapor is acceptable
            fprintf(fid,'%8.5f %9.5f %9.5f %7.3f %7.3f %7.2f %7.4f %7.4f %3d %5.2f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        else
            resultfile=[filename '.asc'];
            fid=fopen([path resultfile],'w');
            fprintf(fid,'%s\n','NASA Ames Airborne Tracking 6-Channel Sunphotometer, AATS-6');
            fprintf(fid,'%s %2i/%2i/%4i\n',site,month,day,year);
            fprintf(fid,'%s %s %s\n', 'Date processed:',date, 'by Beat Schmid, Revision 0.6');
            fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %6.3f %6.3f %6.3f %6.3f %6.3f \n', 'aerosol wavelengths[10^-6 m]', lambda(wvl_aero==1));
            fprintf(fid,'%s\n','UT,Latitude,Longitude,Pressure_Altitude[km],p[hPa],H2O[cm],O3[DU],alpha_Angstrom,Aerosol Optical Depth (5), Error in Aerosol Optical Depth (5), H2O Error[cm]');
            fprintf(fid,'%7.4f %8.4f %8.4f %7.3f %7.2f %7.4f %4.1f %5.2f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',...
                [UT',geog_lat',geog_long',r',press,U'/H2O_conv,ozone'*1000,alpha',tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',H2O_err']');
            fclose(fid);
        end
    end

    if strcmp(Result_File,'ACE-2') %Writes ACE-2 archive file
        if strcmp(instrument,'AMES14#1')
            archive_AATS14_ACE2(filename,path,UT,day,month,year,O3_col_start*1000,NO2_clima*Loschmidt,lambda*1000,V0,darks,...
                data,geog_lat,geog_long,r,press,U/H2O_conv,H2O_err,tau_aero(wvl_aero==1,:),tau_aero_err(wvl_aero==1,:),DGPS,wvl_aero);
        end
    end
end
if strcmp(Result_File,'Trans')
    resultfile=[filename '_trans.asc'];
    fid=fopen([data_dir resultfile],'w');
    fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
    fprintf(fid,'%s %02i.%02i.%4i\r\n', site,day,month,year);
    fprintf(fid,'%7.4f\r\n',f);
    fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n', lambda);
    fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n', V0');
        fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',[UT',Trans']');
%     fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',[UT(L_cloud==1)',Trans(:,L_cloud==1)']');
    fclose(fid);
end