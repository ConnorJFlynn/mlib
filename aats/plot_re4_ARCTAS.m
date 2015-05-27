%CLOUD FILTERS
% #1 AOD is large: tau_aero_limit
% #2 measurement cyclesfi with high standard deviations: sd_crit (only at the longest wavelength)
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
clear all
close all

%flag_use_V0='MLOJan06';
%flag_use_V0='MLOMay06';
%flag_use_V0='meanMLOJanMay06';
%flag_use_V0='interpMLOJanMay06';   use this one for INTEXB
%flag_use_timeinterp_and_Jan06combo='yes'; use this one for INTEXB
flag_use_timeinterp_and_Jan06combo='no';
flag_use_V0='ignore';

prepare_ARCTAS

global symbsize linethick

symbsize=8;
linethick=1.5;

UTbeg_use=UT(1);
UTend_use=UT(end);

flag_adj_ozone_foraltitude='yes';  %for ICARTT, must set='yes' only for case where ozone is for total column
if strcmp(O3_estimate,'ON') flag_adj_ozone_foraltitude='yes';  end
flag_call_ozone4_polfit='no';
flag_adjust_1019_for_temperature='no';
flag_altitude_dependent_CWV='yes';
flag_interpOMIozone='yes';%'yes';  'no' for MLO

%following flag to adj V0 for temp dependence...INTEX-B
flag_adj_V0_tempdepend='no'; %yes for INTEX-B/MILAGRO measurements

if strcmp(flag_adjust_1019_for_temperature,'yes')
    detTC_mean=0.5*(Temperature(1,:)+Temperature(2,:)); %mean of two detector plate temp sensors 
    tempcoeff_percentperdeg=0.51+(lambda(11)-1.000)/(1.060-1.00)*(1.51-0.51);
    factor=(1+tempcoeff_percentperdeg/100).^(45-detTC_mean);
    V1019calc=data(11,:).*factor;
    data(11,:)=V1019calc;
    figure(93)
    subplot(2,1,1)
    plot(UT,factor,'k.')
    grid on
    set(gca,'ylim',[-inf inf])
    set(gca,'fontsize',12)
    ylabel('response correction factor','fontsize',12)
    subplot(2,1,2)
    plot(UT,data(11,:),'b.',UT,V1019calc,'g.')
    grid on
    xlabel('UT (hr)','fontsize',12)
    ylabel('1019-nm detector output (V)','fontsize',12)
    set(gca,'fontsize',12)
end

% Compute total optical depth (it's not really the total optical depth because it is m_aero).
n=size(data');
tau=(log(data'./(ones(n(1),1)*V0)/f))'./(ones(n(2),1)*(-m_aero));
tauadj=tau; %added 1/14/2008

if strcmp(flag_adj_V0_tempdepend,'yes')
    %pfit=[-0.00052	0.01793;	-0.00073	0.02192;	-0.00008	0.00139;	0.00029	-0.00866;	0.00028	-0.00979;...
    %       0.00006	0.00223;	 0.00044   -0.01531;	 0.00016   -0.02420;   -0.00169	 0.06010;   0.0      0.0;...
    %      -0.00050	0.01694;    -0.00055	0.02153;	-0.00130	0.04112;	0.00011	-0.0037];
%following are from 083106 fits for V0=MLOJanMayinterpolated except V0(605) and V0(778) adjusted from MLOJan06
    pfit=[-0.00016	0.00611;	-0.00046	0.01542;	 0.00001   -0.00071;	0.00032	-0.01112;	0.00028	-0.00908;...
          -0.00001 -0.00029;	 0.00033   -0.01216;	 0.00004   -0.00337;   -0.00181	 0.06531;     0.0      0.0;...
          -0.00063	 0.02111;   -0.00063	0.02275;	-0.00137	0.04641;    0.00013 -0.00464];
    for iwl=1:14,
        rel_deltaV0(:,iwl)=polyval(pfit(iwl,:),Temperature(3,:)');   %pfit=f(degree,aero_wvl)...but we need for all wvl
    end
    iwltimeadj=[0 0 0 0 0 0 0 0 1 0 1 1 1 0];
    rel_deltaV0=rel_deltaV0';
    V0adjusted = (ones(size(rel_deltaV0,2),1)*V0)';
    for iwl=1:14,
        if iwltimeadj(iwl)==1
            V0adjusted(iwl,:) = V0(iwl)*(1+rel_deltaV0(iwl,:));
        end
    end
    tauadj=(log(data./V0adjusted/f))./(ones(n(2),1)*(-m_aero));
    tau=tauadj;  %this was inadvertently commented out for archive R0 Sept 06...uncommented it 11/08/06
end

% filter #4 discard measurements above m_aero_max
L=m_aero<=m_aero_max;
data=data(:,L~=0);
Heading=Heading(L~=0);
tauadj=tauadj(:,L~=0);  %added 6/22/08
tau=tau(:,L~=0);
tau_ray=tau_ray(:,L~=0);
tau_O4=tau_O4(:,L~=0);
tau_CO2_CH4_N2O=tau_CO2_CH4_N2O(:,L~=0);
UT=UT(L~=0);
press=press(L~=0);
temp=temp(L~=0);
%tempfudge=tempfudge(L~=0);
SZA=SZA(L~=0);
SZA_unrefrac=SZA_unrefrac(L~=0);
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
if strcmp(source,'Laptop_Otter') | strcmp(source,'Can') | strcmp(source,'Jetstream31') | strcmp(source,'NASA_P3')
     RH=RH(L~=0);
     %RH_new=RH_new(L~=0);
     %Tstat_new=Tstat_new(L~=0);
     H2O_dens_is=H2O_dens_is(L~=0);
end

n=size(data');

% Compute aerosol optical depth

%following added by Livingston 12/19/2002 to account for altitude in columnar ozone correction
%use previously calculated (Livingston program ozonemdlcalc.m) 5th order polynomial fit to ozone model
%to calculate fraction of total column ozone above each altitude
coeff_polyfit_tauO3model=[8.60377e-007  -3.26194e-005   3.54396e-004  -1.30386e-003  -5.67021e-003   9.99948e-001];
frac_tauO3 = polyval(coeff_polyfit_tauO3model,GPS_Alt);
if strcmp(flag_adj_ozone_foraltitude,'no') frac_tauO3=1*ones(1,n(1)); end

if strcmp(flag_interpOMIozone,'yes')
    imoda_OMI=100*month+day;
    if strcmp(flag_OMI_substitute,'yes')
        imoda_OMI=imoda_OMI_substitute;
    end
    [OMIozone_interp,filename_OMIO3] = readinterp_OMIozone(imoda_OMI,geog_lat,geog_long);
    ozone=(frac_tauO3.*OMIozone_interp)';
    tau_ozone=(ozone*a_O3')';
else
    ozone=(frac_tauO3*O3_col_start)';
    tau_ozone=O3_col_start*a_O3;
    tau_ozone=(frac_tauO3'*tau_ozone')';
end

tau_NO2=NO2_clima*a_NO2;
tau_NO2=(ones(n(1),1)*tau_NO2')';
tau_aero= tau-tau_ray.*(ones(n(2),1)*(m_ray./m_aero))...
    -tau_NO2.*(ones(n(2),1)*(m_NO2./m_aero))...
    -tau_ozone.*(ones(n(2),1)*(m_O3./m_aero))...
    -tau_O4.*(ones(n(2),1)*(m_ray./m_aero))...
    -tau_CO2_CH4_N2O.*(ones(n(2),1)*(m_ray./m_aero));

tau_aero_adj= tauadj-tau_ray.*(ones(n(2),1)*(m_ray./m_aero))...
    -tau_NO2.*(ones(n(2),1)*(m_NO2./m_aero))...
    -tau_ozone.*(ones(n(2),1)*(m_O3./m_aero))...
    -tau_O4.*(ones(n(2),1)*(m_ray./m_aero))...
    -tau_CO2_CH4_N2O.*(ones(n(2),1)*(m_ray./m_aero));

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
tau_aero_adj(wvl_aero==0,:)=tau_aero(wvl_aero==0,:);

% Water Vapor 
T =(data.*exp(tau_aero.*(ones(n(2),1)*m_aero)+tau_ray.*(ones(n(2),1)*m_ray)+tau_NO2.*(ones(n(2),1)*m_NO2)+tau_ozone.*(ones(n(2),1)*m_O3)))./(ones(n(1),1)*V0*f)';
U=(-log(T(wvl_water==1,:))./(ones(n(1),1)*a_H2O(wvl_water==1)')')'...
    .^(1./(ones(n(1),1)*b_H2O(wvl_water==1)'))'./(ones(sum(wvl_water),1)*m_H2O);

%new code (Feb. 2005)
nn=size(data);

if strcmp(flag_altitude_dependent_CWV,'yes')
  path_H2Ocoeff='c:\johnmatlab\data\xsect\';
  filenameH2O='AATS14_940nm_LBLRTMcoeff_022205.txt';
  fidH2Ocoeff=fopen([path_H2Ocoeff filenameH2O],'rt');
  linedum = fgetl(fidH2Ocoeff);		%skip end-of-line character
  linedum = fgetl(fidH2Ocoeff);		%skip end-of-line character
  dataH2O=fscanf(fidH2Ocoeff,'%d %f %f %f',[4 inf]);
  zkm_LBLRTM_calcs=dataH2O(1,:);
  afit_H2O=dataH2O(2,:);
  bfit_H2O=dataH2O(3,:);
  cfit_H2O=dataH2O(4,:);
  fclose(fidH2Ocoeff);

  for j=1:nn(2),
      kk=find(GPS_Alt(j)>=zkm_LBLRTM_calcs);
      if GPS_Alt(j)<0 kk=1; end  %handles GPS alts slightly less than zero
      kz=kk(end);
      CWV1=(-log(T(wvl_water==1,j)./cfit_H2O(kz))./afit_H2O(kz)).^(1./bfit_H2O(kz))./m_H2O(j);
      CWV2=(-log(T(wvl_water==1,j)./cfit_H2O(kz+1))./afit_H2O(kz+1)).^(1./bfit_H2O(kz+1))./m_H2O(j);
      CWVint_atmcm = CWV1 + (GPS_Alt(j)-zkm_LBLRTM_calcs(kz))*(CWV2-CWV1)/(zkm_LBLRTM_calcs(kz+1)-zkm_LBLRTM_calcs(kz));
      Ucalc(j)=CWVint_atmcm;      
  end
  Uold=U;
  U=Ucalc;
end

%stopherenow

%Water Vapor correction
%nn=size(data);
tau_H2O=((ones(nn(2),1)*a1_H2O')'.*(ones(nn(1),1)*(m_H2O.*U))+(ones(nn(2),1)*a2_H2O')'.*(ones(nn(1),1)*(m_H2O.*U).^2))./(ones(nn(1),1)*m_H2O);
if (strcmp(O3_estimate,'OFF'))
    tau_aero=tau_aero-tau_H2O.*(ones(n(2),1)*(m_ray./m_aero));   
    tau_aero_adj=tau_aero_adj-tau_H2O.*(ones(n(2),1)*(m_ray./m_aero));   
end

%Now recalculate opt depth vs wvl fits
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
tau_aero_adj(wvl_aero==0,:)=tau_aero(wvl_aero==0,:);

%Ozone retrieval

O3_col_fit=O3_col_start*ones(1,size(tau_aero,2));  %added 12/2002 jml

% Error in aerosol optical depth according to Russell JGR, 1993 equation A15b
% extended for tau_O4 and tau_H2O

% expression for dm/m is from Reagan report
i=find(m_ray<=2);
m_err(i)=0.0003;
j=find(m_ray>2);
m_err(j)=0.0003.*(m_ray(j)/2).^2.2;

%above expression overestimates uncertainty due to airmass uncertainty
%for the time being, just set this relative error = 0.01
m_err=0.01*ones(size(m_ray));

%MUST SET ozone error=0 for call to ozone4_polfit to get reasonable results.
if (strcmp(O3_estimate,'ON') & strcmp(flag_call_ozone4_polfit,'yes'))
  tau_O3_err_use=0;
  tau_aero_err1=tau.*(ones(n(2),1)*m_err);
  tau_aero_err2=(ones(n(1),1)*V0err)'   ./(ones(n(2),1)*m_aero);
  tau_aero_err3=(ones(n(1),1)*dV)'./data./(ones(n(2),1)*m_aero);
  tau_aero_err4=tau_r_err*tau_ray.*   (ones(n(2),1)*(m_ray./m_aero));
  tau_aero_err5=tau_O3_err_use*tau_ozone.*(ones(n(2),1)*(m_O3./m_aero));  %hence,=0
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
  tau_aero_err11=tau_CO2_CH4_N2O_abserr.*ones(n(2),1)*(m_ray./m_aero);
  tau_aero_err=(tau_aero_err1.^2+tau_aero_err2.^2+tau_aero_err3.^2+tau_aero_err4.^2+tau_aero_err5.^2+tau_aero_err6.^2+tau_aero_err7.^2+tau_aero_err8.^2+tau_aero_err9.^2+tau_aero_err11.^2).^0.5;
end

O3_col_fit=O3_col_start*ones(1,size(tau_aero,2));  %added 12/2002 jml
O3_col_fit=frac_tauO3.*O3_col_fit;
%O3guess=round(1000*frac_tauO3*O3_col_start)/1000;  %round guess to nearest DU
unc_ozone(1:length(UT))=-9.999;
if (strcmp(O3_estimate,'ON'))
 O3guess=0.200;  %always start here to permit 0.200<=O3_col<=0.500;
 sigmaO3col=0;
   for i=1:n(1),
        
%        [tau_a,tau_2,tau_3,O3_col2,p]=ozone_box(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,...
%             m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3_col_start,degree);
%         [tau_a,tau_2,tau_3,O3_col,p]= ozone2(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,...
%             m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3_col_start,degree);
%         [tau_a,tau_2,tau_3,O3_col,p]= ozone3(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,UT(i),GPS_Alt(i),...
%             m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3guess,degree);
       if strcmp(flag_call_ozone4_polfit,'yes')
        [tau_a,tau_2,tau_3,O3_col,sigmaO3col,p]= ozone4_polfit(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,UT(i),GPS_Alt(i),...
            m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),tau_CO2_CH4_N2O(:,i),tau_aero_err(:,i),O3guess,degree);%O3_col_start,degree);
        [UT(i) O3_col SZA_unrefrac(i) SZA(i)]
       else
        [tau_a,tau_2,tau_3,O3_col,p]= ozone4(site,day,month,year,lambda,a_O3,a_NO2,NO2_clima,UT(i),GPS_Alt(i),...
            m_aero(i),m_ray(i),m_NO2(i),m_O3(i),m_H2O(i),wvl_chapp,wvl_aero,tau(:,i),tau_ray(:,i),tau_O4(:,i),tau_H2O(:,i),O3guess,degree);%O3_col_start,degree);
        [UT(i) O3_col]
       end        
        
        tau_aero_sav(i,:) =tau_a';
        tau_NO2_sav(i,:)  =tau_2';
        tau_ozone_sav(i,:)=tau_3';
        ozone(i)=O3_col;
        unc_ozone(i)=sigmaO3col;
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
    O3_col_fit=ozone;     %added 12/2002 jml
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CLOUD FILTERS

% #1 AOD is large
L_AOD=all(tau_aero(wvl_aero==1,:)<=tau_aero_limit);

% #2 measurement cycles with high standard deviations
rel_sd=Sd_volts./data;

%following added by JML 7/4/08 to allow different rel_sd screening during different periods of a particular fligh
if strcmp(flag_relsd_timedep,'yes')
 jt_smoke=find(UT>=UT_smoke(1)&UT<=UT_smoke(2));
 jt_notsmoke=find(UT<UT_smoke(1) | UT>UT_smoke(2));
 L_SD_aero=ones(1,size(rel_sd,2));
 L_SD_H2O=L_SD_aero;
 L_SD_aero(jt_notsmoke)=all(rel_sd(wvl_aero==1,jt_notsmoke)<=sd_crit_aero);
 L_SD_aero(jt_smoke)=all(rel_sd(wvl_aero==1,jt_smoke)<=sd_crit_aero_smoke);
 L_SD_H2O(jt_notsmoke)=all(rel_sd(:,jt_notsmoke)<=sd_crit_H2O);
else  %following two lines are the default
 L_SD_aero=all(rel_sd(wvl_aero==1,:)<=sd_crit_aero); 
 L_SD_H2O=all(rel_sd(:,:)<=sd_crit_H2O);
end

%following added by JML 3/16/06 to handle high alt runs separately
L_SD_aero_highalt=ones(size(L_SD_aero));
idxhighalt=find(GPS_Alt>=zGPS_highalt_crit);
if ~isempty(idxhighalt)
    L_SD_aero_highalt(idxhighalt)=all(rel_sd(wvl_aero==1,idxhighalt)<=sd_crit_aero_highalt);
end

% #3 low Angstrom alpha
L_alpha=alpha>=alpha_min;

%test for low Angstrom for low altitude obs
L_alpha_lowalt=ones(size(L_SD_aero));
idxlowalt=find(GPS_Alt<zGPS_highalt_crit);
if ~isempty(idxlowalt)
    L_alpha_lowalt(idxlowalt)=alpha(idxlowalt)>=alpha_min_lowalt;
end

%Diffuse light correction
if strcmp(diffuse_corr,'ON') & (strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES6') | strcmp(instrument,'AMES14#1_2002'))
    if strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES14#1_2002')
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
tau_aero_err11=tau_CO2_CH4_N2O_abserr.*ones(n(2),1)*(m_ray./m_aero);

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
H2O_err4=H2O_fit_err./U; %Beat   H2O_fit_err=0.1 g/cm^2
%H2O_err4=0.1*ones(1,size(H2O_err3,2)); %H2O_fit_err;  %John 10% error...too much
H2O_err=(H2O_err1.^2+H2O_err2.^2+H2O_err3.^2+H2O_err4.^2).^0.5;

% #4 tau_aero_err is large
L_err=all(tau_aero_err<=tau_aero_err_max);

% all cloud filters combined for AOD and H2O
L_cloud=L_AOD.*L_err.*L_SD_aero.*L_alpha.*L_SD_aero_highalt.*L_alpha_lowalt; %L_alpha_lowalt added by JML 1/4/07
%L_cloud=L_AOD.*L_err.*L_SD_aero.*L_alpha.*L_SD_aero_highalt; %L_SD_aero_highalt added by JML 3/16/06
%L_H2O=L_AOD.*L_err; % for ARM groundbased
L_H2O=L_AOD.*L_err.*L_SD_H2O;

slant_U=m_H2O(L_H2O==1).*U(L_H2O==1)/H2O_conv;
disp(sprintf('%s%g: %g','Total points with m<', m_aero_max,length(L_cloud)))
disp(sprintf('%s: %g','Total points with bad H2O', length(L_H2O)-sum(L_H2O)))
disp(sprintf('%s: %g','Total points with bad AOD', length(L_cloud)-sum(L_cloud)))
disp(sprintf('%s: %4.2f-%4.2f','Range of SWP[cm]', min(slant_U),max(slant_U)))

%START PLOTTING
titlestr=sprintf('%s %2i.%2i.%2i %s %g-%g %s',site,day,month,year,filename,UT_start,UT_end,'UT');
for i=1:length(titlestr),
    if strcmp(titlestr(i),'_') titlestr(i)='-'; end
end

titlestr2=sprintf('%s %2i/%2i/%2i %s V0:%s',site,month,day,year,filename,flag_calib);
for i=1:length(titlestr2),
    if strcmp(titlestr2(i),'_') titlestr2(i)='-'; end
end

titlestr3=sprintf('%s %2i/%2i/%2i %s UT:%g-%g V0:%s',site,month,day,year,filename,UT_start,UT_end,flag_calib);
for i=1:length(titlestr3),
    if strcmp(titlestr3(i),'_') titlestr3(i)='-'; end
end

%plot ozone columnn dens
figure(1)
subplot(3,1,1)
plot(UT(L_cloud==1),GPS_Alt(L_cloud==1),'.')
%plot(UT,ozone*1000,UT,ozone*1000./frac_tauO3')
xlabel('UT [hr]','FontSize',14);
%ylabel('Ozone [DU]','FontSize',14);
ylabel('Altitude (km)','fontsize',14)
title(titlestr,'FontSize',14);
set(gca,'FontSize',14)
grid on

ozonelim=[250 450];
subplot(3,1,2)
plot(UT(L_cloud==1),ozone(L_cloud==1)*1000,'.',UT(L_cloud==1),ozone(L_cloud==1)*1000./frac_tauO3(L_cloud==1)','.')
xlabel('UT [h]','FontSize',14);
ylabel('Ozone [DU]','FontSize',14);
set(gca,'ylim',ozonelim,'FontSize',14)
legend('above instrument','sea level')
grid on
xlimval=get(gca,'xlim');

subplot(3,1,3)
plot(UT,m_O3,'.',UT,m_aero,'.',UT,m_ray,'.')
xlabel('UT [h]','FontSize',14);
ylabel('m','FontSize',14);
set(gca,'xlim',xlimval,'FontSize',14)
%set(gca,'ylim',[0 100])
legend('O_3','Aerosol','Rayleigh')
grid on


%plot ozone columnn dens
figure(31)
subplot(4,1,1)
plot(UT(L_cloud==1),GPS_Alt(L_cloud==1),'.','markersize',8)
%plot(UT,ozone*1000,UT,ozone*1000./frac_tauO3')
%ylabel('Ozone [DU]','FontSize',14);
ylabel('Altitude (km)','fontsize',14)
title(titlestr,'FontSize',14);
set(gca,'FontSize',14)
grid on
xlimval=get(gca,'xlim');
set(gca,'xlim',xlimval)

ozonelim=[260 380];
subplot(4,1,2)
plot(UT(L_cloud==1),ozone(L_cloud==1)*1000,'.',UT(L_cloud==1),ozone(L_cloud==1)*1000./frac_tauO3(L_cloud==1)','.','markersize',8)
ylabel('Ozone [DU]','FontSize',14);
set(gca,'xlim',xlimval,'ylim',ozonelim,'FontSize',14)
%legend('above instrument','sea level')
grid on
%xlimval=get(gca,'xlim');

subplot(4,1,3)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.','markersize',8);
grid on
set(gca,'xlim',xlimval,'FontSize',14)
ylabel('AOD screened','fontsize',14);
if strcmp(instrument,'AMES14#1_2001') |  strcmp(instrument,'AMES14#1_2002') 
    hleg31=legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
    set(hleg31,'fontsize',10)
end

subplot(4,1,4)
plot(UT,m_O3,'.',UT,m_aero,'.',UT,m_ray,'.','markersize',8)
xlabel('UT [h]','FontSize',14);
ylabel('m','FontSize',14);
set(gca,'xlim',xlimval,'FontSize',14)
%set(gca,'ylim',[0 100])
legend('O_3','Aerosol','Rayleigh')
grid on

% plot H2O uncertainty as a function of altitude
figure(2)
subplot(1,2,1)
plot(H2O_err1(L_H2O==1)*100,r(L_H2O==1),H2O_err2(L_H2O==1)*100,r(L_H2O==1),abs(H2O_err3(L_H2O==1))*100,r(L_H2O==1),H2O_err4(L_H2O==1)*100,...
    r(L_H2O==1),H2O_err(L_H2O==1)*100,r(L_H2O==1))
xlabel('CWV Uncertainty [%]','FontSize',14);
ylabel('Altitude [km]','FontSize',14);
title(titlestr,'FontSize',14);
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
plot(UT,tau_aero(wvl_aero==1,:),'.','markersize',6);
xx=get(gca,'xlim');
set(gca,'xlim',xx)
xlabel('UT');
ylabel('Aerosol Optical Depth');
title(titlestr2);
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
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.','markersize',6);
grid on
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD screened');

subplot(4,1,3)
plot(UT(L_cloud==1),rel_sd(wvl_aero==1,L_cloud==1),'.','markersize',6);
grid on
set(gca,'xlim',xx)
xlabel('UT');
ylabel('Rel Stdev - screened');

subplot(4,1,4)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.','markersize',6)
set(gca,'xlim',xx)
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(33)
UTlim33=xx;
%UTlim33=[20.3 20.5];
%UTlim33=[19.75 21.75];
%UTlim33=[17 19];
%UTlim33=[21.1 23.7];
subplot(4,1,1)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
%semilogy(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
%set(gca,'ylim',[0.001 1])
%grid on
set(gca,'xlim',UTlim33,'fontsize',14)
%xlabel('UT');
ylabel('AOD screened','fontsize',14);
title(titlestr2);
grid on
if strcmp(instrument,'AMES14#1_2001') |  strcmp(instrument,'AMES14#1_2002') 
    legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end

subplot(4,1,2)
plot(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
%semilogy(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
set(gca,'xlim',UTlim33,'fontsize',14)
ylabel('H2O Column [cm] - screened','fontsize',14);
%xlabel('UT');
grid on

subplot(4,1,3)  
plot(UT(L_cloud==1),alpha(L_cloud==1),'.',UT(L_cloud==1),gamma(L_cloud==1),'.');
set(gca,'xlim',UTlim33,'fontsize',14)
xlabel('UT');
ylabel('coeff screened','fontsize',14);
legend('alpha','gamma','fontsize',14)
grid on

%subplot(4,1,3)
%plot(UT(L_cloud==1),rel_sd(wvl_aero==1,L_cloud==1),'.');
%grid on
%set(gca,'xlim',xx)
%ylabel('Rel Stdev - screened');

subplot(4,1,4)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
set(gca,'xlim',UTlim33,'fontsize',14)
ylabel('Altitude (km)','fontsize',14)
legend('GPS alt', 'Press alt')
grid on
xlabel('UT','fontsize',14);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(34)
UTlim33=xx;
subplot(5,1,1)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
set(gca,'xlim',UTlim33,'fontsize',14)
ylabel('AOD screened','fontsize',12);
title(titlestr2);
grid on

subplot(5,1,2)
plot(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
set(gca,'xlim',UTlim33,'fontsize',14)
ylabel('CWV [cm] - screened','fontsize',12);
grid on

subplot(5,1,3)
plot(UT(L_cloud==1),U(L_cloud==1)/H2O_conv,'.');
set(gca,'xlim',UTlim33,'fontsize',14)
ylabel('CWV [cm] - AOD screened','fontsize',12);
grid on

subplot(5,1,4)  
plot(UT(L_cloud==1),alpha(L_cloud==1),'.',UT(L_cloud==1),gamma(L_cloud==1),'.');
set(gca,'xlim',UTlim33,'fontsize',14)
xlabel('UT');
ylabel('coeff screened','fontsize',12);
legend('alpha','gamma','fontsize',12)
grid on

subplot(5,1,5)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
set(gca,'xlim',UTlim33,'fontsize',14)
ylabel('Altitude (km)','fontsize',12)
legend('GPS alt', 'Press alt')
grid on
xlabel('UT','fontsize',14);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(35)
xlimval=xx;
subplot(4,1,1)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
set(gca,'xlim',xlimval,'FontSize',14)
%xlabel('UT');
ylabel('AOD','FontSize',14);
title(titlestr2);
grid on
if strcmp(instrument,'AMES14#1_2001') |  strcmp(instrument,'AMES14#1_2002') 
    hleg341=legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
    set(hleg341,'fontsize',10)
end
colorordsav=get(gca,'colororder');

subplot(4,1,2)
plot(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
set(gca,'xlim',xlimval,'FontSize',14)
ylabel('H2O Column [cm]','FontSize',14);
%xlabel('UT');
grid on

subplot(4,1,3)  
plot(UT(L_cloud==1),alpha(L_cloud==1),'.',UT(L_cloud==1),gamma(L_cloud==1),'.');
set(gca,'xlim',xlimval,'FontSize',14)
xlabel('UT','FontSize',14);
ylabel('coeff screened','FontSize',14);
hleg34=legend('alpha','gamma');
set(hleg34,'FontSize',14)
grid on

flag_airmassframe4='no';
if strcmp(flag_airmassframe4,'yes')

subplot(4,1,4)
plot(UT,m_O3,'.',UT,m_aero,'.',UT,m_ray,'.','markersize',8)
xlabel('UT [h]','FontSize',14);
ylabel('airmass','FontSize',14);
set(gca,'xlim',xlimval,'ylim',[0 20],'ytick',[0 5 10 15 20],'FontSize',14)
%set(gca,'ylim',[0 100])
legend('O_3','Aerosol','Rayleigh')
grid on
xlabel('UT');

else

ozonelim=[300 320];
subplot(4,1,4)
plot(UT(L_cloud==1),ozone(L_cloud==1)*1000,'.')
xlabel('UT [h]','FontSize',14);
ylabel('Ozone [DU]','FontSize',14);
set(gca,'ylim',ozonelim,'xlim',xlimval,'FontSize',14)
grid on
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(36)
plot(UT,L_SD_H2O,'g.','markersize',6)
hold on
plot(UT,L_SD_aero+2,'b.','markersize',6)
plot(UT,L_alpha+4,'r.','markersize',6)
set(gca,'fontsize',16)
set(gca,'ylim',[0 6])
xlabel('UT','fontsize',16)
ylabel('L value','fontsize',16)
h36=legend('L-SD-H2O','L-SD-aero','L-alpha');
set(h36,'fontsize',12)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot raw signals for selected wvls
flag_oplottemp='yes';
idxwvlp=[2 9 11];%[5 8];
ylimval=[8.6 9.5;5.5 5.8]; %for 5,8
ylimval=[6.4 7;8 8.3]; %for 5,8
ylimval=[4.6 5.6;6.8 7.2;7.2 7.6]; %for 2,11 6/9/08
dely=[0.1 0.05];%[0.1 0.05];
dely=[0.2 0.1 0.1];
xlim401=[18.5 23.5];
figure(401)
for iwl=1:length(idxwvlp),
subplot(length(idxwvlp),1,iwl)
coloruse=colorordsav(mod(idxwvlp(iwl),7),1:3);
if idxwvlp(iwl)>=10 coloruse=colorordsav(mod(idxwvlp(iwl),7)-1,1:3); end
plot(UT,data(idxwvlp(iwl),:),'.','color',coloruse)
set(gca,'xlim',xlim401,'ylim',ylimval(iwl,:),'ytick',[ylimval(iwl,1):dely(iwl):ylimval(iwl,2)],'fontsize',16)
grid on
ylabel(sprintf('Voltage (%6.1f nm)',1000*lambda(idxwvlp(iwl))),'fontsize',18)
if iwl==1 title(titlestr,'fontsize',14); end
end
xlabel('UT','fontsize',18)
if strcmp(flag_oplottemp,'yes')
    ax1=gca;
    ax2 = axes('Position',get(ax1,'Position'),'XAxisLocation','top','YAxisLocation','right','XLim',xlim401,'YLim',...
        [35 55],'XTickLabel','','Color','none','XColor','k','YColor',[1 140/255 0]);
    set(ax2,'ytick',[35:5:55],'fontsize',14)
    h12=line(UT,Temperature(3,:),'Color',[1 140/255 0],'Parent',ax2,'linewidth',2);
    ylabel('Filter Plate #1 Temp (C)','fontsize',16);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%plot aerosol depth 
figure(303)
subplot(3,1,1)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.','markersize',6);
xx=get(gca,'xlim');
set(gca,'xlim',xx,'fontsize',14)
xlabel('UT');
ylabel('Aerosol Optical Depth','fontsize',14);
title(titlestr2);
grid on
if strcmp(instrument,'AMES14#1_2001') |  strcmp(instrument,'AMES14#1_2002') 
    legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
        num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end

subplot(3,1,2)
plot(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
%semilogy(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
set(gca,'xlim',xx,'fontsize',14)
ylabel('H2O Column [cm]','fontsize',14);
grid on

subplot(3,1,3)
plot(UT,m_O3,'.',UT,m_aero,'.',UT,m_ray,'.','markersize',8)
xlabel('UT [h]','FontSize',14);
ylabel('m','FontSize',14);
set(gca,'xlim',xlimval,'FontSize',14)
%set(gca,'ylim',[0 100])
legend('O_3','Aerosol','Rayleigh')
grid on
xlabel('UT');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%plot Angstrom exponent 
figure(4)
subplot(2,1,1)
switch degree
case 1
    plot(UT,alpha,'.','markersize',8);
    xx=get(gca,'xlim');
    set(gca,'xlim',xx)
    title(titlestr2);
    ylabel('alpha');
    xlabel('UT');
    grid on
    subplot(2,1,2)  
    plot(UT(L_cloud==1),alpha(L_cloud==1),'.','markersize',8);
    set(gca,'xlim',xx)
    xlabel('UT');
    ylabel('Alpha screened');
    grid on
case 2   
    plot(UT,alpha,'.',UT,gamma,'.','markersize',8);
    xx=get(gca,'xlim');
    set(gca,'xlim',xx)
    title(titlestr2);
    ylabel('coeff');
    xlabel('UT');
    legend('alpha','gamma')
    grid on
    subplot(2,1,2)  
    plot(UT(L_cloud==1),alpha(L_cloud==1),'.',UT(L_cloud==1),gamma(L_cloud==1),'.','markersize',8);
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
title(titlestr2);
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
grid on

%plot aerosol optical depth error
figure(7)
subplot(2,1,1)
plot(UT,tau_aero_err(wvl_aero==1,:),'.');
xx=get(gca,'xlim');
set(gca,'xlim',xx)
grid on
xlabel('UT');
ylabel('Aerosol Optical Depth Error');
title(titlestr2);
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

%special adjustment for 17 July 03
%%tau_a_mean_sav=tau_a_mean;
%%tau_a_err_sav=tau_a_err;
%%tau_a_mean(12)= 0.5*(.0127+.0242);
%%tau_a_err(12)=0.0242-tau_a_mean(12);
%%tau_a_err(13)=3*tau_a_err_sav(13);
%%tau_a_err(14)=3*tau_a_err_sav(14);
loglog(lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),'ko','MarkerSize',8,'MarkerFaceColor','k');
hold on

% AATS-6
%lambda_AATS6=[0.3801,0.4509,0.5257,0.8645,1.0213];
%tau_AATS6=[0.2128,0.1718,0.1429,0.0561,0.0656]; %comparison 4/3/2001
%tau_AATS6=[0.8577 0.7296 0.6206 0.4741 0.4186]; %comparison 4/3/2001
%loglog(lambda_AATS6,tau_AATS6,'rs','MarkerSize',9,'MarkerFaceColor','r')

% MODIS
lambda_MODIS = [.470 .550 .660 .870 1.240 1.640 2.140];
tau_MODIS=   [0.164	 0.136	0.114	0.083	0.059	0.049	0.041];  % Monterey, April 17, 2003
tau_MODIS=   [0.08      0.07      0.06      0.04      0.03      0.02      0.01];  % Pease, July 17, 2004
tau_MODIS_err = (0.03 + 0.05*tau_MODIS);

% MISR
lambda_MISR=    [0.446       0.558       0.672       0.866];
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
lambda_TOMS=[0.380];
%tau_TOMS=[0.553]; %Sept 2, 2000 SAFARI-2000
tau_TOMS=[2.38];   %Sept 6, 2000 SAFARI-2000
%tau_TOMS=[0.065]; %Sept 7, 2000 SAFARI-2000
tau_TOMS_err=max([0.1, 0.3*tau_TOMS]); %Error is 0.1 or 30% whichever is larger

% SeaWiFS
%lambda_SeaWiFS_standard=[0.865]; %ACE-Asia 4/12/2001
%AOD_SeaWiFS_standard=[0.31];     %ACE-Asia 4/12/2001
lambda_SeaWiFS= [  443    510    670   865]/1e3;
%AOD_SeaWiFS=    [0.783  0.727  0.540 0.463]; %ACE-Asia 4/9/2001, Location 38.1 N, 133.7 E, 3:07 UT
%err_AOD_SeaWiFS=[0.056  0.045  0.035 0.035]; %ACE-Asia 4/9/2001
%AOD_SeaWiFS=    [0.361  0.330  0.271 0.210]; %ACE-Asia 4/12/2001, Location 32.91 N, 127.83 E, 3:37 UT
%err_AOD_SeaWiFS=[0.016  0.015  0.014 0.012]; %ACE-Asia 4/12/2001
 AOD_SeaWiFS=    [0.851  0.785  0.663 0.611]; %ACE-Asia 4/14/2001, Location 32.127 N, 132.7 E, 3:25 UT
 err_AOD_SeaWiFS=[0.031  0.026  0.019 0.019]; %ACE-Asia 4/14/2001


% Cimel
%lambda_Cimel=[1020 870	670 500 440 380 340]/1e3;
 %tau_Cimel=[0.073286	0.097409	0.153234	0.249464	0.287107	0.366537	0.406768];% Sep 16, 2000,  10:51:48 UT, Etosha Pan Level 2
 %tau_Cimel_err=[0.01  0.01     0.01     0.015     0.015     0.015     0.02    ];
%loglog(lambda_Cimel,tau_Cimel,'rs','MarkerSize',9,'MarkerFaceColor','r')
%loglog(lambda_TOMS,tau_TOMS,'bs','MarkerSize',9,'MarkerFaceColor','b')
%loglog(lambda_MODIS,tau_MODIS,'gs','MarkerSize',9,'MarkerFaceColor','g')
%loglog(lambda_MISR,tau_MISR,'bs','MarkerSize',9,'MarkerFaceColor','b')
%loglog(lambda_SeaWiFS,AOD_SeaWiFS,'ro','MarkerSize',9,'MarkerFaceColor','r')
%loglog(lambda_SeaWiFS_standard,AOD_SeaWiFS_standard,'ms','MarkerSize',9,'MarkerFaceColor','m')

loglog(lambda_MODIS,tau_MODIS,'rs','MarkerSize',9,'MarkerFaceColor','r')
yerrorbar('loglog',0.3,2.2, 0.008 ,0.2,lambda_MODIS,tau_MODIS,tau_MODIS_err,'ro')

set(gca,'xlim',[.30 1.6]);
set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
%set(gca,'ylim',[0.008 0.2])
set(gca,'ylim',[0.01 0.3])

if strcmp(instrument,'AMES14#1_2002')
   set(gca,'xlim',[.30 2.2]);
   set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8 2.0 2.2]);
end

%yerrorbar('loglog',0.3,1.6, 1e-2  ,2.5,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),...
%   -tau_a_min(wvl_aero==1)+tau_a_mean(wvl_aero==1),tau_a_max(wvl_aero==1)-tau_a_mean(wvl_aero==1),'mo')
%yerrorbar('loglog',0.3,1.6, 1e-2  ,2.5,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_std(wvl_aero==1),'ko')

xlabel('Wavelength [\mum]','FontSize',14);
ylabel('Aerosol Optical Depth','FontSize',14);

%title(titlestr3,'FontSize',14);
titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g %s',site,month,day,year,filename,UTbeg_use,UTend_use,'UT');
if ~isempty(flag_calib)
    titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g UT  V0:%s',site,month,day,year,filename,UTbeg_use,UTend_use,flag_calib)
end
title(titlestr,'FontSize',14);
set(gca,'FontSize',14)

%yerrorbar('loglog',0.3,1.6, 0.001 ,2.5,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),'ko')
%yerrorbar('loglog',0.3,1.6,0.05, 2,lambda_SeaWiFS,AOD_SeaWiFS,err_AOD_SeaWiFS,'r.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_Cimel,tau_Cimel,tau_Cimel_err,'r.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.5,lambda_MISR,tau_MISR,tau_MISR_err,'b.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.6,lambda_TOMS,tau_TOMS,tau_TOMS_err,'b.')
%yerrorbar('loglog',0.3,1.6,0.01, 2.6,lambda_MODIS,tau_MODIS,tau_MODIS_err,'g.')

yerrorbar('loglog',0.3,2.2, 0.008 ,0.2,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),'ko')
yerrorbar('loglog',0.3,2.2, 0.01 ,0.3,lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),'ko')
legend ('AATS-14: 15:11-15:15 UT','MODIS: 15:13 UT')

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
set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.1 0.2])
set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3])
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

flag_plotfig28='yes';
if strcmp(flag_plotfig28,'yes')
%special AOD on log-log...Livingston added
figure(28)
%GPSalt_bot=12;
%GPSalt_top=13;
%Palt_bot=7.15;
%Palt_top=7.25;
UTplim=[16.84 16.9];;  %7/29 Flt 16 high alt 
UTplim=[23.0 23.5]; %7/28 Flt 17 Langley cal
UTplim=[15 15.3]; %7/31 Flt 18 high alt
UTplim=[22 23]; %8/02 Flt 20 high alt
UTplim=[22.35 22.85]; %7/10 Flt5 McCook,NB to Niagara Falls
UTplim=[16.06 16.13]; %7/15 Flt8 MODIS underpass date...this is high altitude time
UTplim=[18.6 18.9]; %7/16 Flt9
UTplim=[14.49 14.51]; %7/17 Flt10
UTplim=[15.04 15.14]; %7/20 Flt 11
UTplim=[16.05 16.18]; %7/20 Flt 11
UTplim=[17.4 17.63]; %7/21 Flt 12
UTplim=[14.5 14.9]; %7/22 Flt 13
UTplim=[16.05 16.12]; %7/22 Flt 13
UTplim=[14.5 14.9; 16.05 16.12]; %7/22 Flt 13
UTplim=[17.53 17.55]; %7/23 Flt 14
UTplim=[19.51 19.55]; %7/26 Flt 15
UTplim=[14.81 14.86; 16.855 16.9]; %7/29 Flt 16
UTplim=[21 21.5; 22 22.5; 23.35 23.55]; %7/29 Langley flight Flt 17
UTplim=[14.8 14.85; 16.1 16.25]; %8/2 Flt 19
UTplim=[20.53 20.77; 22.4 23.4]; %8/2 Flt 20  Langley
UTplim=[13.86 13.93; 15.8 15.9]; %8/7 Flt 22
UTplim=[21 21.5]; %8/7 Flt 23 Langley
UTplim=[17.26 17.36; 18.18 18.28]; %Flt 24  8 Aug
UTplim=[22.3 22.46]; %Flt 26 8 Aug

UTplim=[17.26 17.36; 18.18 18.28]; %Flt 24  8 Aug

UTplim=[16.5 20];  %MLO Aug 2005
UTplim=[19.4 24.1];  %Ames Sept 01, 2005
UTplim=[18.6 18.72]; %high alt INTEX-B test flight 2/24/2006
%UTplim=[17.9 18.15]; %high alt INTEX-B test flight 3/3/2006
UTplim=[16.13 16.19; 17.54 17.66]; %high alt INTEX-B flight 3/5/2006
%UTplim=[16 16.8; 18 18.4]; %high alt INTEX-B flight 3/6/2006
%UTplim=[18 18.5]; %high alt INTEX-B  flight 3/6/2006
UTplim=[15.72 15.78; 17.31 17.8]; %high alt INTEX-B flight 1 on 3/10/2006
%UTplim=[19.417 19.433; 20.23 21.125]; %high alt INTEX-B flight 2 on 3/10/2006
UTplim=[20.2 20.5]; %high alt 3/10 F2
UTplim=[16.55 16.85; 18.3 18.5]; %high alt INTEX-B flight on 3/11/2006
UTplim=[16.2 16.8; 18.2 18.9]; %high alt INTEX-B flight on 3/15/2006
UTplim=[16 16.4;17.25 17.9]; %high alt 3/13/2006
UTplim=[18.97 19.11; 19.78 20.37; 21.4 21.49]; %high alt 3/17/2006
UTplim=[17.07 17.27; 18.35 18.55] %high alt clear 3/18/2006
UTplim=[18.75 19.4; 20.7 21.2] %high alt clear 3/19/2006
UTplim=[16.8 17.0]; %Wallops 3/25? or 3/27?
UTplim=[19.5 19.9; 21.23 21.6]; %ARCTAS 4/1/08 Yellowknife-->Fairbanks flight
UTplim=[26.3 26.4]; %ARCTAS 4/6/08 Fairbanks-->Barrow N flight
UTplim=[16.4 20.0]; %MLO 5/7/08
UTplim=[16.4 19.6]; %MLO 5/9/08
UTplim=[16.4 20.0]; %MLO 5/10/08
UTplim=[17.1 19.0]; %MLO 5/15/08
UTplim=[17.1 18.2]; %MLO 5/14/08
UTplim=[16.5 18.5]; %MLO 5/16/08
UTplim=[16.5 19.65]; %MLO 5/17/08
UTplim=[16.2 19.45]; %MLO 5/18/08
UTplim=[22.05 22.6]; %at Ames 060508
UTplim=[22.05 22.6; 22.9 23.8]; %at Ames 060508
UTplim=[19 20; 21 22]; %at Ames 060985
UTplim=[19 19.5; 19.5 20]; %at Ames 061708
UTplim=[19.8 20.2; 20.2 20.6]; %early afternoon at Ames 061808 after changing 1240 detector and 521 gain resistor
UTplim=[22.4 22.6; 22.6 22.8; 22.8 23.0; 23.0 23.2]; %mid-afternoon at Ames 061808 after changing 1240 detector and 521 gain resistor
UTplim=[16.85 17.3;17.4 17.65 ] %Ames 061908
UTplim=[19.63 19.74]; %ARCTASsummer test flight...Flt 11...6/22/2008 high alt
UTplim=[15.99 16.20; 17.5 17.6; 18.95 19.0]; %high alt ARCTASsummer test flight...Flt 13...6/25/2008 high alt
%UTplim=[17.89 17.905;18.46 18.65]; %ARCTASsummer test flight...Flt 13...6/25/2008 Sac valley
%UTplim=[21.422 21.46];
UTplim=[18.13 18.3;21.26 21.38; 21.46 21.54]; %F18 02July08 3.1km,3.1 km,5.1km 
%UTplim=[18.1 18.11;18.5 18.53;18.6 18.67]; %F19 03July08

ylimits=[0.001 0.1]; 
ylimits=[0.02 0.5];
colorchoice=['b';'g';'k';'r'];
%colorchoice=['b';'r'];
for icase=1:size(UTplim,1),
 colorsym=colorchoice(icase,1);   
 %L_clouduse=(L_cloud==1&UT>=UTpbeg&UT<=UTpend&GPS_Alt>=GPSalt_bot&GPS_Alt<=GPSalt_top);
 L_clouduse=(L_cloud==1&UT>=UTplim(icase,1)&UT<=UTplim(icase,2)); %&Press_Alt>=Palt_bot&Press_Alt<=Palt_top);
 O3mean=mean(O3_col_start*frac_tauO3(L_clouduse==1));
 O3std=std(O3_col_start*frac_tauO3(1,L_clouduse==1));
 if strcmp(O3_estimate,'ON')
    O3mean=mean(O3_col_fit(L_clouduse==1));
    O3std=std(O3_col_fit(L_clouduse==1));
 end
 tau_a_max=max(tau_aero(:,L_clouduse==1)');
 tau_a_min=min(tau_aero(:,L_clouduse==1)');
 tau_a_std=std(tau_aero(:,L_clouduse==1)');
 tau_a_mean=mean(tau_aero(:,L_clouduse==1)');
 tau_a_err=mean(tau_aero_err(:,L_clouduse==1)');
 GPSmean=mean(GPS_Alt(L_clouduse==1));
 GPSstd=std(GPS_Alt(1,L_clouduse==1)');
 zpmean=mean(Press_Alt(L_clouduse==1));
 zpstd=std(Press_Alt(1,L_clouduse==1)');
 alphamean=mean(alpha(L_clouduse==1));
 alphastd=std(alpha(1,L_clouduse==1)');
 mraymin=min(m_ray(L_clouduse==1));
 mraymax=max(m_ray(L_clouduse==1));
 tCmean_FP1=mean(Temperature(3,L_clouduse==1));
 tCstd_FP1=std(Temperature(3,L_clouduse==1)');
 tCmean_FP2=mean(Temperature(10,L_clouduse==1));
 tCstd_FP2=std(Temperature(10,L_clouduse==1)');
 loglog(lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),strcat(colorsym,'o'),'MarkerSize',8);%,'MarkerFaceColor',colorsym);
 %set(gca,'ylim',ylimits,'ytick',[0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1])
 %set(gca,'ylim',ylimits,'ytick',[0.005,0.006,0.007,0.008,0.009,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.12,0.15,0.2])
 set(gca,'ylim',ylimits)
 %set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0])
 set(gca,'ticklen',[0.015 0.03])
%tl0=[0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.3 0.4 0.5 1.0];
%tl=num2str(tl0)
 %set(gca,'yticklabel',tl)
 hold on
 %set(gca,'xlim',[.30 1.6]);
 %set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 if strcmp(instrument,'AMES14#1_2002')
   set(gca,'xlim',[.30 2.2]);
   set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8 2.0 2.2]);
 end
 %set(gca,'ytick',[0.0001:0.01:0.1 0.2 0.3]);
 set(gca,'ytick',[0.02:0.01:0.1 0.2:0.1:0.5]);
 xlabel('Wavelength [\mum]','FontSize',24);
 ylabel('Aerosol Optical Depth','FontSize',24);
 filenamestr=filename;
 for ii=1:length(filenamestr),
    if strcmp(filenamestr(ii),'_') filenamestr(ii)='-'; end
 end
 titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g %s',site,month,day,year,filenamestr,UTplim(1),UTplim(2),'UT');
 if ~isempty(flag_calib)
    %titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g UT  V0:%s  zGPS:%5.2f-%5.2f km  zGPS:%5.2f+-%5.2f  O3:%3.0f',site,month,day,year,filename,UTpbeg,UTpend,flag_calib,GPSalt_bot,GPSalt_top,GPSmean,GPSstd,1000*O3_col_start)
    %%titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g UT V0:%s zGPS:%5.2f+-%5.2f km zP:%5.2f+-%5.2f  m:%6.3f-%6.3f O3:%3.0f+-%3.1f',site,month,day,year,filenamestr,UTplim(1),UTplim(2),flag_calib,GPSmean,GPSstd,zpmean,zpstd,mraymin,mraymax,1000*O3mean,1000*O3std)
    if icase==1 
        titlestr=sprintf('%s %2i/%2i/%2i   %s V0:%s    O3:%3.0f+-%3.1f',site,month,day,year,filenamestr,flag_calib);%,1000*O3mean,1000*O3std);
        title(titlestr,'fontsize',14)
    end
end

 textstr=sprintf('%7.3f-%7.3f UT zGPS:%5.2f+-%5.2f km zP:%5.2f+-%5.2f  m:%6.3f-%6.3f  tFP1:%6.2f+-%6.2f  tFP2:%6.2f+-%6.2f  O3:%5.3f+-%5.3f',UTplim(icase,1),UTplim(icase,2),GPSmean,GPSstd,zpmean,zpstd,mraymin,mraymax,tCmean_FP1,tCstd_FP1,tCmean_FP2,tCstd_FP2,O3mean,O3std)
 %if icase==1
 %    textstr=sprintf( 'Central CA valley:%7.3f-%7.3f UT    zGPS:%5.2f km    a'':%5.2f',UTplim(icase,1),UTplim(icase,2),GPSmean,alphamean)
 %elseif icase==2
 %     textstr=sprintf(' Lake Tahoe basin:%7.3f-%7.3f UT    zGPS:%5.2f km    a'':%5.2f',UTplim(icase,1),UTplim(icase,2),GPSmean,alphamean)
 %end
 ht5=text(0.302,0.1-icase*0.02,textstr)
 set(ht5,'fontsize',13,'color',colorsym)


 set(gca,'FontSize',20)
 %yerrorbar('loglog',0.3,2.2, ylimits(1),ylimits(2),lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),strcat(colorsym,'o'))
 yerrorbar2('loglog',0.3,2.2,ylimits(1),ylimits(2),lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),tau_a_err(wvl_aero==1),'o',0.4,colorsym)
 yerrorbar2('loglog',0.3,2.2,ylimits(1),ylimits(2),lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_std(wvl_aero==1),tau_a_std(wvl_aero==1),'o',0.25,colorsym)
 grid off
end
end

%Altitude profile
figure(9)
subplot(1,4,1)
plot(tau_aero(wvl_aero==1,L_cloud==1),r(L_cloud==1),'.')
title(titlestr);
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

%Altitude profile
flag_altprf='yes';
if strcmp(flag_altprf,'yes')
figure(91)
zmin=2; 
zmax=8;
taulim91=[0.01 0.5];
flag_direc=['descent';'ascent ';'descent';'ascent '];
%UTbeg_prf=[18.9]; %7/16/04 RB
%UTend_prf=[19.32]; %7/16/04 RB
%UTbeg_prf=[20.975 21.6]; %8/2/04
%UTend_prf=[21.235 22]; %8/2/04 
%flag_direc='ascent';
%UTbeg_prf=21.6; %8/2/04 ascent
%UTend_prf=22; %8/2/04 ascent
UTbeg_prf=15.34; %8/7 ascent, DC-8 rendezvous
UTend_prf=15.77; %8/7 ascent, DC-8 rendezvous
UTbeg_prf=17.52; %8/7 ascent, DC-8 rendezvous
UTend_prf=17.68; %3/15/06 ascent
UTbeg_prf=17.55;%ascent out of VER 3/20/2006 with cirrus
UTend_prf=17.8; %ascent out of VER 3/20/2006 with cirrus
UTbeg_prf=19.09; %ARCTASsummer test flight...Flt 11...6/22/2008
UTend_prf=19.62; %ARCTASsummer test flight...Flt 11...6/22/2008
%UTbeg_prf=[18.97 21.49]; %ARCTASsummer test flight...Flt 12...6/24/2008
%UTend_prf=[19.42 21.75]; %ARCTASsummer test flight...Flt 12...6/24/2008
%UTend_prf=21.49;%ARCTASsummer test flight...Flt 12...6/24/2008
%UTend_prf=21.75;%ARCTASsummer test flight...Flt 12...6/24/2008
UTbeg_prf=[16.21 17.28 17.58 18.65]; 
UTend_prf=[16.48 17.49 17.90 18.95];
wvl_aer_plt=[0 0 0 1 0 0 0 1 0 0 1 1 1 1];
wvl_aer_plt=wvl_aero;

for ip=1:size(UTbeg_prf,2);
 %subplot(1,size(UTbeg_prf,2),ip)
 subplot(2,2,ip)
 jtuse=find(UT>=UTbeg_prf(1,ip)&UT<=UTend_prf(1,ip)&L_cloud==1);
 meanlat=mean(geog_lat(jtuse));
 stdlat=std(geog_lat(jtuse));
 meanlon=mean(geog_long(jtuse));
 stdlon=std(geog_long(jtuse));
 semilogx(tau_aero(wvl_aer_plt==1,jtuse),r(jtuse),'.')
 %plot(tau_aero(wvl_aer_plt==1,jtuse),r(jtuse),'.')
 titlestr4=sprintf('%s %2i/%2i/%2i %s V0:%s\nUT:%5.2f-%5.2f mean lat:%7.2f+-%5.2f   mean lon:%7.2f+-%5.2f  %s',site,month,day,year,filename,flag_calib,UTbeg_prf(ip),UTend_prf(ip),meanlat,stdlat,meanlon,stdlon,flag_direc(ip,:));
 for i=1:length(titlestr4),
    if strcmp(titlestr4(i),'_') titlestr4(i)='-'; end
 end
 title(titlestr4,'fontsize',12);
 xlabel('Aerosol Optical Depth','fontsize',16)
 ylabel('Altitude [km]','fontsize',16)
 grid on
 set(gca,'ylim',[zmin zmax],'xlim',taulim91,'fontsize',16)
 str91=[];
 for j=1:14,
  if wvl_aer_plt(j)==1
      str91=[str91;sprintf('%6.4f',lambda(j))];
  end
 end
 hleg91=legend(str91);
 set(hleg91,'fontsize',10)
end
end

figure(10)
subplot(4,1,1)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
title(titlestr);
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

figure(11)
subplot(6,1,1)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
title(titlestr,'FontSize',14);
%axis([xx 0 inf])
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')
set(gca,'ylim',[-0.1 7])
grid on

%set(1,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0;0.8 0.2 0.2;0 0 0]) %cyan,blue,green,magenta,red,brown?,black
%orient landscape

%set(11,'DefaultAxesColorOrder',[0 1 1;0 0 1;0 1 0;1 0 1;1 0 0])
%cyan,blue,green,magenta,red

subplot(6,1,2)
plot(UT,data(wvl_aero==1,:))
axis([xx 0 10])
xlabel('UT');
ylabel('Signals(V)')
%set(gca,'ylim',[0 10])
%axis([-inf inf 0 10])
%title(sprintf('%s %2i/%2i/%2i %s',site,month,day,year,filename));
grid on

subplot(6,1,3)
plot(UT,tau_aero(wvl_aero==1,:),'.');
grid on
set(gca,'ylim',[0 2])
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD');

if strcmp(frost_filter,'yes')
    flag_filter354='yes';   %used for filtering the 354nm AOD's when we suspect frost
    if strcmp(flag_filter354,'yes')
     flag_354_frost=find(rel_sd(1,:)>rel_sd(3,:))  %found that rel_sd(354)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     tau_aero(1,flag_354_frost)=-9999;  %set 354-nm AOD=-9999
     tau_aero_err(1,flag_354_frost)=-9999;  %set 354-nm AOD=-9999
    end

    flag_filter499='yes';   %used for filtering the 499nm AOD's when we suspect frost 
    if strcmp(flag_filter499,'yes')
     flag_499_frost1=find(rel_sd(4,:)>rel_sd(3,:))  %found that rel_sd(499)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     flag_499_frost2=find(tau_aero(4,:)>tau_aero(2,:))
     tau_aero(4,flag_499_frost1)=-9999;  %set 499-nm AOD=-9999
     tau_aero(4,flag_499_frost2)=-9999;  %set 499-nm AOD=-9999
     tau_aero_err(4,flag_499_frost1)=-9999;  %set 499-nm AOD=-9999
     tau_aero_err(4,flag_499_frost2)=-9999;  %set 499-nm AOD=-9999
    end

    flag_filter605='yes';   %used for filtering the 605nm AOD's when we suspect frost 
    if strcmp(flag_filter605,'yes')
     flag_605_frost1=find(rel_sd(6,:)>rel_sd(3,:)) %found that rel_sd(605)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     flag_605_frost2=find(tau_aero(6,:)>tau_aero(2,:))
     tau_aero(6,flag_605_frost1)=-9999;  %set 605-nm AOD=-9999
     tau_aero(6,flag_605_frost2)=-9999;  %set 605-nm AOD=-9999
     tau_aero_err(6,flag_605_frost1)=-9999;  %set 605-nm AOD=-9999
     tau_aero_err(6,flag_605_frost2)=-9999;  %set 605-nm AOD=-9999
    end

    flag_filter675='yes';   %used for filtering the 675nm AOD's when we suspect frost 
    if strcmp(flag_filter675,'yes')
     flag_675_frost=find((rel_sd(7,:)>rel_sd(3,:)))%found that rel_sd(675)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     tau_aero(7,flag_675_frost)=-9999;  %set 675-nm AOD=-9999
     tau_aero_err(7,flag_675_frost)=-9999;  %set 675-nm AOD=-9999
    end

    flag_filter779='yes';   %used for filtering the 779nm AOD's when we suspect frost 
    if strcmp(flag_filter779,'yes')
     flag_779_frost1=find(rel_sd(8,:)>rel_sd(3,:))  %found that rel_sd(779)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     flag_779_frost2=find(tau_aero(8,:)>tau_aero(2,:))
     tau_aero(8,flag_779_frost1)=-9999;  %set 779-nm AOD=-9999
     tau_aero(8,flag_779_frost2)=-9999;  %set 779-nm AOD=-9999
     tau_aero_err(8,flag_779_frost1)=-9999;  %set 779-nm AOD=-9999
     tau_aero_err(8,flag_779_frost2)=-9999;  %set 779-nm AOD=-9999
    end

    flag_filter1241='yes';   %used for filtering the 1241nm AOD's when we suspect frost 
    if strcmp(flag_filter1241,'yes')
     flag_1241_frost=find(rel_sd(12,:)>rel_sd(3,:))  %found that rel_sd(1241)>rel_sd(452nm) is a sufficient statement to sort out most data points with frost
     tau_aero(12,flag_1241_frost)=-9999;  %set 1241-nm AOD=-9999
     tau_aero_err(12,flag_1241_frost)=-9999;  %set 1241-nm AOD=-9999
    end
end

if strcmp(dirt_filter,'yes')
     tau_aero(12:14,UT>21.2)=-9999;
     tau_aero_err(12:14,UT>21.2)=-9999;
end

subplot(6,1,4)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
grid on
%set(gca,'ylim',[0 inf])
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD screened');

if strcmp(instrument,'AMES14#1') |  strcmp(instrument,'AMES14#1_2000') 
   %legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
   %       num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(10)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end
if strcmp(instrument,'AMES14#1_2001') |  strcmp(instrument,'AMES14#1_2002') 
   %legend(num2str(lambda(1)),num2str(lambda(2)),num2str(lambda(3)),num2str(lambda(4)),num2str(lambda(5)),num2str(lambda(6)),num2str(lambda(7)),...
   %       num2str(lambda(8)),num2str(lambda(9)),num2str(lambda(11)),num2str(lambda(12)),num2str(lambda(13)),num2str(lambda(14))  );
end
if strcmp(instrument,'AMES6')
 legend('380.1','450.9','525.7','864.5','1021.3'	)
end

subplot(6,1,5)
plot(UT,rel_sd(wvl_aero==1,:),'.');
grid on
set(gca,'xlim',xx)
set(gca,'ylim',[0 2*sd_crit_aero])
xlabel('UT');
ylabel('Rel Stdev - not screened');

subplot(6,1,6)
plot(UT,alpha,'.',UT(L_cloud==1),alpha(L_cloud==1),'g.');
grid on
set(gca,'xlim',xx)
set(gca,'ylim',[-1 4])
xlabel('UT');
ylabel('\alpha');
legend('all','cloud-screened');
%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(111)
subplot(6,1,1)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
title(titlestr,'FontSize',14);
%axis([xx 0 inf])
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')
set(gca,'ylim',[-0.1 7])
grid on

subplot(6,1,2)
plot(UT,tau_aero(wvl_aero==1,:),'.');
grid on
set(gca,'ylim',[0 2])
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD');

subplot(6,1,3)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.');
grid on
%set(gca,'ylim',[0 inf])
set(gca,'xlim',xx)
xlabel('UT');
ylabel('AOD screened');

subplot(6,1,4)
plot(UT,rel_sd(wvl_aero==1,:),'.');
grid on
set(gca,'xlim',xx)
set(gca,'ylim',[0 2*sd_crit_aero])
xlabel('UT');
ylabel('Rel Stdev - not screened');

subplot(6,1,5)
plot(UT(L_cloud==1),rel_sd(wvl_aero==1,L_cloud==1),'.');
grid on
set(gca,'xlim',xx)
set(gca,'ylim',[0 2*sd_crit_aero])
xlabel('UT');
ylabel('Rel Stdev - cloud-screened');

subplot(6,1,6)
plot(UT,alpha,'.',UT(L_cloud==1),alpha(L_cloud==1),'g.');
grid on
set(gca,'xlim',xx)
set(gca,'ylim',[-1 4])
xlabel('UT');
ylabel('\alpha');
legend('all','cloud-screened');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(211)
subplot(3,1,1)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.')
title(titlestr,'FontSize',14);
%axis([xx 0 inf])
ylabel('Altitude (km)','fontsize',14)
legend('GPS alt', 'Press alt')
set(gca,'ylim',[-0.1 8])
set(gca,'fontsize',14)
grid on
xx=get(gca,'xlim')

subplot(3,1,2)
plot(UT,data(wvl_aero==1,:),'.')
axis([xx 0 10])
set(gca,'fontsize',14)
xlabel('UT');
ylabel('Signals(V)')
grid on

subplot(3,1,3)
plot(UT(L_cloud==1),data(wvl_aero==1,L_cloud==1),'.');
grid on
plot(UT(L_cloud==1),data(wvl_aero==1,L_cloud==1),'.')
set(gca,'xlim',xx,'ylim',[0 10])
set(gca,'fontsize',14)
xlabel('UT');
ylabel('Signals(V) screened')
grid on

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%UTspec=[16.75 16.85];%29 June constant altitude circles
UTspec=[21.3 21.5];%[21.6 21.8] %low altitude 29 June CAR circles over Great Slave Lake and over land
%UTspec=[22.65 22.92];%30 June CAR circles
titlestr221=sprintf('%s %2i.%2i.%2i %s %g-%g %s',site,day,month,year,filename,UTspec,'UT');
for i=1:length(titlestr),
    if strcmp(titlestr(i),'_') titlestr(i)='-'; end
end
kspec=find(UT>=UTspec(1)&UT<=UTspec(2));
figure(221)
subplot(3,1,1)
plot(UT(kspec),geog_lat(kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec)
grid on
ylabel('Latitude','fontsize',16)
title(titlestr221,'fontsize',14)
subplot(3,1,2)
plot(UT(kspec),geog_long(kspec),'.','markersize',8)
ylabel('Longitude','fontsize',16)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec)
grid on
subplot(3,1,3)
plot(UT(kspec),Heading(kspec),'.','markersize',8)
ylabel('Heading','fontsize',16)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 360])
grid on
xlabel('UT','fontsize',16)

legstr222=[];
for i=1:length(lambda),
    legstr222=[legstr222;sprintf('%5.3f',lambda(i))];
end
figure(222)
subplot(3,1,1)
plot(UT(kspec),tau_aero(:,kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 0.04],'ytick',[0:0.01:0.04])
ylabel('AOD','fontsize',16)
grid on
title(titlestr221,'fontsize',14)
hleg222=legend(legstr222);
set(hleg222,'fontsize',9)
subplot(3,1,2)
plot(UT(kspec),Az_pos(kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 360])
grid on
ylabel('AATS Azimuth','fontsize',16)
subplot(3,1,3)
plot(UT(kspec),Elev_pos(kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec)
grid on
ylabel('AATS Elev','fontsize',16)
xlabel('UT','fontsize',16)

figure(223)
subplot(4,1,1)
plot(UT(kspec),Az_err(kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[-0.5 +0.5])
ylabel('Azim err','fontsize',16)
grid on
title(titlestr221,'fontsize',14)
subplot(4,1,2)
plot(UT(kspec),Elev_err(kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[-0.5 +0.5])
ylabel('Elev err','fontsize',16)
grid on
subplot(4,1,3)
plot(UT(kspec),data(:,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[2 10])
ylabel('Det V','fontsize',16)
grid on
subplot(4,1,4)
plot(UT(kspec),rel_sd(:,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 0.004])
ylabel('Det Rel Sd','fontsize',16)
grid on
xlabel('UT','fontsize',16)

figure(224)
subplot(2,1,1)
plot(Az_pos(kspec),tau_aero(:,kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',[0 360],'ylim',[0 0.04])
ylabel('AOD','fontsize',16)
xlabel('Solar Azimuth relative to AATS (deg)','fontsize',16)
grid on
title(titlestr221,'fontsize',14)
subplot(2,1,2)
plot(Elev_pos(kspec),tau_aero(:,kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'ylim',[0 0.04])
ylabel('AOD','fontsize',16)
xlabel('Solar Elevation relative to AATS (deg)','fontsize',16)
grid on


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prepare output
%write to file
if strcmp(archive_GH,'ON')
 %dataarchive_dir='c:\johnmatlab\AATS14_2004_ICARTTarchive_Feb05\';
 %dataarchive_dir='c:\johnmatlab\AATS14_2004_ICARTTarchive_Dec05test\';
 %dataarchive_dir='c:\johnmatlab\AATS14_2004_ICARTTarchive_Jan05\high altitude with ozone fit\';
 %dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_Aug06\'; %AATS14_2006_INTEXBarchive
 if strcmp(flag_use_V0,'MLOJan06')  
    dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_V0Jan06noadj\'; %AATS14_2006_INTEXBarchive
 elseif strcmp(flag_use_V0,'MLOMay06')  
    dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_V0May06noadj\'; %AATS14_2006_INTEXBarchive
 elseif strcmp(flag_use_V0,'meanMLOJanMay06')
    dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_V0meanJanMay06noadj\'; %AATS14_2006_INTEXBarchive
 elseif strcmp(flag_use_V0,'interpMLOJanMay06')
    %dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_R0_Sep06\';
    %dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_R1_Nov06\';
    %dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_R1_Dec06\';
    dataarchive_dir='c:\johnmatlab\AATS14_2006_INTEXBarchive_R1_Jan07\';
 end
 FlightNo=18; %don't know any flight numbers yet
 %[ntimwrt,filename_arc]=archive_AATS14_SOLVE2_GH(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
 %       L_cloud,L_H2O,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,ozone,tau_aero,tau_aero_err,...
 %       O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min);   
 %[ntimwrt,filename_arc]=archive_AATS14_ICARTT(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        %L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,O3_col_fit,unc_ozone,tau_aero,tau_aero_err,...
        %O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min,flag_calib,Temperature);   
 %[ntimwrt,filename_arc]=archive_AATS14_INTEXB(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        %L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,O3_col_fit,unc_ozone,tau_aero,tau_aero_err,...
        %O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,m_aero_max,tau_aero_limit,tau_aero_err_max,alpha_min,flag_calib,Temperature);   
 if strcmp(site,'INTEXB')
     [ntimwrt,filename_arc]=archive_AATS14_INTEXB(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,O3_col_fit,unc_ozone,tau_aero,tau_aero_err,...
        O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,sd_crit_aero_highalt,zGPS_highalt_crit,m_aero_max,tau_aero_limit,...
        tau_aero_err_max,alpha_min,alpha_min_lowalt,flag_calib,Temperature);   
 end
 if strcmp(site(1:6),'ARCTAS')
     dataarchive_dir='c:\johnmatlab\AATS14_2008_ARCTASsummerarchive_RA_prelim\';
     
     if julian(day,month,year,0)==julian(26,6,2008,0) 
         ireset=find(UT>=16.2895 & UT<=16.2905); %remove bad pressure data point
         L_H2O(ireset)=0;
         L_cloud(ireset)=0;
     elseif julian(day,month,year,0)==julian(30,6,2008,0)
         ireset=find((UT>=20.993&UT<=20.994) | (UT>=21.379&UT<=21.38) | (UT>=21.381&UT<=21.382) | (UT>=21.656&UT<=21.6575)); %remove bad pressure data point
         L_H2O(ireset)=0;
         L_cloud(ireset)=0;         
     end
     
     day_arr = [ julian(25,3,2008,0) julian(27,3,2008,0) julian(31,3,2008,0) julian(1,4,2008,0)  julian(6,4,2008,0)...
         julian(8,4,2008,0)  julian(9,4,2008,0) julian(13,4,2008,0) julian(15,4,2008,0)  julian(19,4,2008,0)...
         julian(22,6,2008,0) julian(24,6,2008,0) julian(26,6,2008,0) julian(27,6,2008,0) julian(28,6,2008,0)...
         julian(29,6,2008,0) julian(30,6,2008,0) julian(2,7,2008,0) julian(3,7,2008,0)];
                 
     FlightNo_arr = [1:length(day_arr)];
        
     FlightNo = FlightNo_arr(find( day_arr == julian(day, month,year,0)))
     
     flag_substitute_PDS_GPSAlt='yes';  %added JML 07/05/2008 to fix bad GPS_Alt points in serial data stream
     if strcmp(flag_substitute_PDS_GPSAlt,'yes')
         substitute_PDS
     end
     
     if strcmp(flag_LH2O_equal_Lcloud,'yes') %for archival purposes, set L_H2O=L_cloud
        L_H2O=L_cloud;
     end
     
     [ntimwrt,filename_arc]=archive_AATS14_ARCTAS(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,O3_col_fit,unc_ozone,tau_aero,tau_aero_err,...
        O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,sd_crit_aero_highalt,zGPS_highalt_crit,m_aero_max,tau_aero_limit,...
        tau_aero_err_max,alpha_min,alpha_min_lowalt,flag_calib,Temperature,rel_sd,frost_filter,dirt_filter,UT_smoke,sd_crit_aero_smoke,...
        flag_interpOMIozone,filename_OMIO3);   
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
        elseif strcmp(site,'ACE-Asia') | strcmp(site,'Aerosol IOP')
            resultfile=['AATS14_',filename,'.asc']
            fid=fopen([data_dir resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by Beat Schmid, Version 2.1');
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
            resultfile=[filename '.asc']
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
    
    if strcmp(Result_File,'Box')
        if strcmp(instrument,'AMES14#1')
            resultfile=[filename '.asc']
            fid=fopen([path resultfile],'w');
            fprintf(fid,'%s\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14, unit #1');
            fprintf(fid,'%s %2i.%2i.%4i\n', site,day,month,year);
            fprintf(fid,'%s %s %s\n', 'Date processed:',date, 'by Beat Schmid, Revision 1.2, for Gail Box');
            fprintf(fid,'%s %g\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s\n', 'wavelengths used [10^-6 m]');
            fprintf(fid,'%6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f %6.3f\n', lambda(wvl_chapp==1));
            fprintf(fid,'%s\n','UT, Aerosol+Ozone Optical Depth');
            fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\n',[UT',tau_aero(wvl_chapp==1,:)'+tau_ozone(wvl_chapp==1,:)']');
            fclose(fid);
        end
    end
end