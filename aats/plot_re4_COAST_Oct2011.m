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
clear 
close all

%flag_use_V0='MLOJan06';
%flag_use_V0='MLOMay06';
%flag_use_V0='meanMLOJanMay06';
%flag_use_V0='interpMLOJanMay06';   use this one for INTEXB
%flag_use_timeinterp_and_Jan06combo='yes'; use this one for INTEXB
flag_use_timeinterp_and_Jan06combo='no';
flag_use_V0='ignore';
flag_call_wingglintremoval='no';  %reset, as necessary, in prepare_COAST_Oct2011

%prepare_ARCTAS
%prepare_ARCTAS_summer
%prepare_ground_Sept2011
prepare_COAST_Oct2011

global symbsize linethick

symbsize=8;
linethick=1.5;

UTbeg_use=UT(1);
UTend_use=UT(end);

%set following = 'no' for usual run
flag_use_only_rayleighairmass='no';

%omit 1558-nm channel for COAST
wvluse_alpha=[1 1 1 1 1 1 1 1 1 0 1 1 0 1]; %added 7/11/08 JML to permit exclusion of certain wvls in calculating alpha

flag_adj_ozone_foraltitude='yes';  %for ICARTT, must set='yes' only for case where ozone is for total column
if strcmp(O3_estimate,'ON') flag_adj_ozone_foraltitude='yes';  end
flag_call_ozone4_polfit='no';
flag_adjust_1019_for_temperature='no';
flag_altitude_dependent_CWV='yes';  %NOTE THAT I STILL NEED TO UPDATE THE VALUES FOR COAST
flag_interpOMIozone='no';%'yes';  'no' for MLO   %FOR COAST WILL EVENTUALLY SET = 'yes' after downloading OMI O3

%following flag to adj V0 for temp dependence...INTEX-B
flag_adj_V0_tempdepend='no'; %yes for INTEX-B/MILAGRO measurements

if strcmp(flag_adjust_1019_for_temperature,'yes')
    detTC_mean=0.5*(Temperature(1,:)+Temperature(2,:)); %mean of two detector plate temp sensors 
    tempcoeff_percentperdeg=0.51+(lambda(11)-1.000)/(1.060-1.00)*(1.51-0.51);
    factor=(1+tempcoeff_percentperdeg/100).^(45-detTC_mean);
    V1019calc=data(11,:).*factor;
    data(11,:)=V1019calc;
    figure(97)
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
if strcmp(flag_use_only_rayleighairmass,'yes')
    m_aero=m_ray;
end
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
UTCan=UTCan(L~=0);
if ~strcmp(source,'Can') 
    AvePeriod=AvePeriod(L~=0);
end
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
    filename_OMIO3=[];
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
    wvl_use=(tau_aero(:,i)>0)' & wvluse_alpha==1;  %modified 7/11/08 to omit certain wvl; catch the AOD(lambda) which are < 0 and don't use for Angstrom fit
    %wvl_use=(tau_aero(:,i)>0)';        %catch the AOD(lambda) which are < 0 and don't use for Angstrom fit
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

if strcmp(flag_altitude_dependent_CWV,'yes')  %STILL NEED NEW FILE TO READ IN FOR COAST
  path_H2Ocoeff='c:\johnmatlab\data\xsect\';
  path_H2Ocoeff='C:\case_studies\AATS\xsect\'; % CJF
  filenameH2O='AATS14_940nm_LBLRTMcoeff_102811_COAST.txt'; 
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
end %ozone fit stuff
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
    L_alpha(idxlowalt)=L_alpha_lowalt(idxlowalt); %added 7/22/08 jml
end

%Diffuse light correction
if strcmp(diffuse_corr,'ON') & (strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES6') | strcmp(instrument,'AMES14#1_2002'))
    if strcmp(instrument,'AMES14#1_2001') | strcmp(instrument,'AMES14#1_2002')
%         method=2; % method=1 use alpha from 380 to 1020, method=2 use alpha from 1020 to 1558   
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
%xlimval=xx;
xlimval=[16.5 19.7];
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

ozonelim=[260 300];
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
set(gca,'xlim',xx,'FontSize',14)
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
xlim5=[14 18];
figure(5)
subplot(5,1,1)
plot(UT,U/H2O_conv,'.');
set(gca,'xlim',xlim5)
xx=get(gca,'xlim');
%set(gca,'xlim',xx)
title(titlestr2);
ylabel('H2O Column [cm]');
xlabel('UT');
grid on

subplot(5,1,2)
plot(UT(L_H2O==1),U(L_H2O==1)/H2O_conv,'.');
set(gca,'xlim',xx)
ylabel('H2O Column [cm] - screened');
xlabel('UT');
grid on

subplot(5,1,3)
plot(UT(L_H2O==1),rel_sd(10,L_H2O==1),'.');
grid on
set(gca,'xlim',xx)
xlabel('UT');
ylabel('Rel Stdev(940) - screened');

subplot(5,1,4)
plot(UT(L_H2O==1),alpha(L_H2O==1),'.');
grid on
set(gca,'xlim',xx,'ylim',[0 1])
xlabel('UT');
ylabel('alpha - screened');

subplot(5,1,5)
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

flag_plot_MLOAODspectrum='yes';
if strcmp(flag_plot_MLOAODspectrum,'yes')
    ammin=1.37;
    ammax=12;
    idxmuse=find(m_ray>=ammin & m_ray<=ammax & L_cloud==1);
    idlim=[idxmuse(1) idxmuse(end)];
    tau_a27_max=max(tau_aero(:,idxmuse)');
    tau_a27_min=min(tau_aero(:,idxmuse)');
    tau_a27_std=std(tau_aero(:,idxmuse),0,2)';
    tau_a27_mean=mean(tau_aero(:,idxmuse)');
    tau_a27_err=mean(tau_aero_err(:,idxmuse)');
    figure(27)
    subplot(2,1,1)
    loglog(lambda(wvl_aero==1),tau_a27_mean(wvl_aero==1),'ko','MarkerSize',8);%,'MarkerFaceColor',colorsym);
    set(gca,'FontSize',16)
    set(gca,'ylim',[0.001 0.1],'ticklen',[0.015 0.03])
	set(gca,'xlim',[.30 2.2],'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8 2.0 2.2]);
    xlabel('Wavelength [\mum]','FontSize',20);
	ylabel('Aerosol Optical Depth','FontSize',20);
    filenamestr=filename;
    for ii=1:length(filenamestr),
     if strcmp(filenamestr(ii),'_') filenamestr(ii)='-'; end
    end
    titlestr=sprintf('%s %2i/%2i/%2i   %s   V0:%s  Time:%5.3f-%5.3f UT   m:%6.3f-%6.3f',site,month,day,year,filenamestr,flag_calib,UT(idlim),m_ray(idlim));
    title(titlestr,'fontsize',14)
    hold on
    yerrorbar2('loglog',0.3,2.2,0.001,0.1,lambda(wvl_aero==1),tau_a27_mean(wvl_aero==1),tau_a27_err(wvl_aero==1),tau_a27_err(wvl_aero==1),'o',0.4,'k')
    yerrorbar2('loglog',0.3,2.2,0.001,0.1,lambda(wvl_aero==1),tau_a27_mean(wvl_aero==1),tau_a27_std(wvl_aero==1),tau_a27_std(wvl_aero==1),'o',0.25,'k')
    grid off
    subplot(2,1,2)
    plot(UT(idxmuse),tau_aero(wvl_aero==1,idxmuse),'.-')
    grid on
    set(gca,'fontsize',16)
    xlabel('UT [hr]','fontsize',20)
    ylabel('Aerosol Optical Depth','fontsize',20)
    legst=[];
    for i=1:length(lambda),
        if(wvl_aero(i)==1),
            legst=[legst;sprintf('%6.1f',1000*lambda(i))];
        end
    end
    hleg27=legend(legst);
    set(hleg27,'fontsize',9)

 %now plot OD contributions of various species    
 tauplus=tau_aero + tau_O4 + tau_CO2_CH4_N2O + tau_H2O;
 figure(28)
 kwp=[11:14];
 for iw=1:length(kwp),
  kw=kwp(iw);
  subplot(2,2,iw)
  semilogy(UT(idxmuse),tau_aero(kw,idxmuse),'.','color',[0.6 0.2 0])
  hold on
  semilogy(UT(idxmuse),tau_O4(kw,idxmuse),'r-','linewidth',2)
  semilogy(UT(idxmuse),tau_CO2_CH4_N2O(kw,idxmuse),'b-','linewidth',2)
  semilogy(UT(idxmuse),tau_H2O(kw,idxmuse),'g.')
  semilogy(UT(idxmuse),tauplus(kw,idxmuse),'k.')
  set(gca,'fontsize',14)
  set(gca,'ylim',[0.0001 0.1])
  xlabel('UT (hr)','fontsize',16)
  ylabel('Optical Depth','fontsize',16)
  title(sprintf('%6.1f nm',1000*lambda(kw)),'fontsize',14)
  if iw==1
    title(sprintf('%s   %6.1f nm  V0:%6.4f',filename,1000*lambda(kw),V0(kw)),'fontsize',14)
    hleg28=legend('aerosol','O2-O2','CO2-CH4-N2O','H2O','sum');
    set(hleg28,'fontsize',12)
  elseif iw==2
    title(sprintf('%6.1f nm  V0:%6.4f  %s',1000*lambda(kw),V0(kw),flag_calib),'fontsize',14)
  else
    title(sprintf('%6.1f nm  V0:%6.4f',1000*lambda(kw),V0(kw)),'fontsize',14)
  end
 end

end


flag_AODspectrum_special='yes';
if strcmp(flag_AODspectrum_special,'yes')
%special AOD on log-log...Livingston added
figure(29)
UTplim=[16.5 20.5];
UTplim=[19.25 21.25];
switch day
    case 26
        UTplim=[18.96 19.12;19.271 19.37;20.216 20.353;21.082 21.11;21.244 21.2675]; %COAST 10/26 bottom
        UTplim=[18.1 18.82;19.5 20.05;20.485 20.958;21.383 21.942]; %COAST 10/26 top
    case 27
    case 28
        UTplim=[17.744 17.83; 17.83 17.92; 18.84 18.928; 18.928 19.02; 20.015 20.051; 20.051 20.115]; %COAST 10/28 bottom
        %UTplim=[18.1 18.64; 19.2 19.75; 20.322 20.865; 21.288 21.891];  %COAST 10/28 top
end
ylimits=[0.01 0.5];%[0.01 0.5]; %[0.001 0.1];%[0.01 10];
%ylimits=[0.001 0.1];
%ylimits=[0.02 0.5];
colorchoice=['bo';'rx';'g^';'kv'];
ncols=size(UTplim,1)/2;
for icase=1:size(UTplim,1),
 jf=ceil(icase/2);
 subplot(2,3,jf)
 jcolr=mod(icase,2);
 if jcolr==0 jcolr=2; end
 colorsym=colorchoice(jcolr,1);   
 %L_clouduse=(L_cloud==1&UT>=UTpbeg&UT<=UTpend&GPS_Alt>=GPSalt_bot&GPS_Alt<=GPSalt_top);
 %%L_clouduse=(L_cloud==1&UT>=UTplim(icase,1)&UT<=UTplim(icase,2)); %&Press_Alt>=Palt_bot&Press_Alt<=Palt_top);
 L_clouduse=(UT>=UTplim(icase,1)&UT<=UTplim(icase,2)); %&Press_Alt>=Palt_bot&Press_Alt<=Palt_top);
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
 loglog(lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),colorsym,'MarkerSize',8);%,'MarkerFaceColor',colorsym);
 %set(gca,'ylim',ylimits,'ytick',[0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1])
 %set(gca,'ylim',ylimits,'ytick',[0.005,0.006,0.007,0.008,0.009,0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.12,0.15,0.2])
 set(gca,'ylim',ylimits,'ytick',[0.01 0.02 0.03 0.05 0.07 0.1 0.2 0.3 0.5])
 %set(gca,'ytick',[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0])
 set(gca,'ticklen',[0.030 0.05])
%tl0=[0.01 0.02 0.03 0.04 0.05 0.1 0.2 0.3 0.4 0.5 1.0];
%tl=num2str(tl0)
 %set(gca,'yticklabel',tl)
 hold on
 %set(gca,'xlim',[.30 1.6]);
 %set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6]);
 if strcmp(instrument,'AMES14#1_2002')
   set(gca,'xlim',[.30 2.2]);
   set(gca,'xtick',[0.3,0.4,0.5,0.7,1.0,1.2,1.5,2.0]);
   %set(gca,'xtick',[0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.2,1.4,1.6, 1.8 2.0 2.2]);
 end
 %set(gca,'ytick',[0.0001:0.01:0.1 0.2 0.3]);
 %set(gca,'ytick',[0.02:0.01:0.1 0.2:0.1:0.5]);
 if jf==2 xlabel('Wavelength [\mum]','FontSize',20); end
 if icase==1 ylabel('Aerosol Optical Depth','FontSize',20); end
 filenamestr=filename;
 for ii=1:length(filenamestr),
    if strcmp(filenamestr(ii),'_') filenamestr(ii)='-'; end
 end
 titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g %s',site,month,day,year,filenamestr,UTplim(1),UTplim(2),'UT');
 if ~isempty(flag_calib)
    %titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g UT  V0:%s  zGPS:%5.2f-%5.2f km  zGPS:%5.2f+-%5.2f  O3:%3.0f',site,month,day,year,filename,UTpbeg,UTpend,flag_calib,GPSalt_bot,GPSalt_top,GPSmean,GPSstd,1000*O3_col_start)
    %%titlestr=sprintf('%s %2i/%2i/%2i %s %g-%g UT V0:%s zGPS:%5.2f+-%5.2f km zP:%5.2f+-%5.2f  m:%6.3f-%6.3f O3:%3.0f+-%3.1f',site,month,day,year,filenamestr,UTplim(1),UTplim(2),flag_calib,GPSmean,GPSstd,zpmean,zpstd,mraymin,mraymax,1000*O3mean,1000*O3std)
    if icase==1 
        titlestr=sprintf('%s %2i/%2i/%2i   %s V0:%s    O3:%3.0f DU',site,month,day,year,filenamestr,flag_calib,1000*O3mean);%,1000*O3mean,1000*O3std);
        title(titlestr,'fontsize',14)
    end
end

 textstr=sprintf('UT:%7.3f-%6.3f   z:%5.2f+-%4.2f km',UTplim(icase,1),UTplim(icase,2),GPSmean,GPSstd)
 %textstr=sprintf('%7.3f-%7.3f UT zGPS:%5.2f+-%5.2f km zP:%5.2f+-%5.2f  m:%6.3f-%6.3f  tFP1:%6.2f+-%6.2f  tFP2:%6.2f+-%6.2f  O3:%5.3f+-%5.3f',UTplim(icase,1),UTplim(icase,2),GPSmean,GPSstd,zpmean,zpstd,mraymin,mraymax,tCmean_FP1,tCstd_FP1,tCmean_FP2,tCstd_FP2,O3mean,O3std)
 %if icase==1F
 %    textstr=sprintf( 'Central CA valley:%7.3f-%7.3f UT    zGPS:%5.2f km    a'':%5.2f',UTplim(icase,1),UTplim(icase,2),GPSmean,alphamean)
 %elseif icase==2
 %     textstr=sprintf(' Lake Tahoe basin:%7.3f-%7.3f UT    zGPS:%5.2f km    a'':%5.2f',UTplim(icase,1),UTplim(icase,2),GPSmean,alphamean)
 %end
 ht5=text(0.35,0.45-jcolr*0.08,textstr)
 set(ht5,'fontname','Arial','fontsize',11,'color',colorsym)


 set(gca,'FontSize',14)
 %yerrorbar('loglog',0.3,2.2, ylimits(1),ylimits(2),lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),strcat(colorsym,'o'))
 yerrorbar2('loglog',0.3,2.2,ylimits(1),ylimits(2),lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_err(wvl_aero==1),tau_a_err(wvl_aero==1),colorchoice(jcolr,2),0.4,colorchoice(jcolr,1))
 yerrorbar2('loglog',0.3,2.2,ylimits(1),ylimits(2),lambda(wvl_aero==1),tau_a_mean(wvl_aero==1),tau_a_std(wvl_aero==1),tau_a_std(wvl_aero==1),colorchoice(jcolr,2),0.25,colorchoice(jcolr,1))
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

%Altitude profile multiple graphs
flag_altprf='no'; %'yes';
if strcmp(flag_altprf,'yes')
    zmin=0;
    zmax=2;
    taulim91=[0 0.2];
    switch day
        case 26
            UTbeg_prf=[17.86 18.818 19.125 19.194 19.37  20.05 20.35  20.958 21.264 21.94]; %10/26/11
            UTend_prf=[18.1  18.951 19.194 19.266 19.502 20.21 20.482 21.082 21.384 22.073]; %10/26/11
        case 27
            UTbeg_prf=[19.12 21.333]; %10/27/11
            UTend_prf=[19.27 21.51]; %10/27/11
        case 28
            UTbeg_prf=[17.92  18.641  19.02  19.75 20.115 20.864 21.186 21.891]; %10/28/11
            UTend_prf=[18.068 18.8365 19.194 20.0  20.322 21.025 21.288 22.072]; %10/28/11
    end
    flag_direc=['ascent ';'descent';'ascent ';'descent';'ascent ';'descent';'ascent ';'descent';'ascent ';'descent'];
    %wvl_aer_plt=[0 0 0 0 1 0 0 0 0 0 0 0 0 0];
    wvl_aer_plt=[1 1 1 1 1 1 1 1 1 0 1 1 0 1];
    %wvl_aer_plt=wvl_aero;
    
    nprf_figs=ceil(size(UTbeg_prf,2)/2);
    for jf=1:nprf_figs,
        figure(90+jf)
        for ip=1:2,
            subplot(1,2,ip)
            jp = (jf-1)*2 + ip
            jtuse=find(UT>=UTbeg_prf(1,jp)&UT<=UTend_prf(1,jp)&L_cloud==1);
            meanlat=mean(geog_lat(jtuse));
            stdlat=std(geog_lat(jtuse));
            meanlon=mean(geog_long(jtuse));
            stdlon=std(geog_long(jtuse));
            %semilogx(tau_aero(wvl_aer_plt==1,jtuse),r(jtuse),'.')
            plot(tau_aero(wvl_aer_plt==1,jtuse),r(jtuse),'.')
            titlestr4=sprintf('%s %2i/%2i/%2i %s V0:%s\nUT:%5.2f-%5.2f mean lat:%7.2f+-%5.2f   mean lon:%7.2f+-%5.2f  %s',site,month,day,year,filename,flag_calib,UTbeg_prf(jp),UTend_prf(jp),meanlat,stdlat,meanlon,stdlon,flag_direc(jp,:));
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
            set(hleg91,'fontsize',14)
        end
    end
    
    flag_CWVprf='yes';
    if strcmp(flag_CWVprf,'yes')
        CWVlim=[0.6 1.4];
        CWVlim=[0.2 1.2];
        colsymCWV=['c^';'bx';'g^';'rx';'y^';'mx';'k^';'cx';'b^';'gx'];
        figure(190)
        legst=[];
        for jf=1:nprf_figs,
            for ip=1:2,
                jp = (jf-1)*2 + ip
                jtuse=find(UT>=UTbeg_prf(1,jp)&UT<=UTend_prf(1,jp)&L_cloud==1);
                meanlat=mean(geog_lat(jtuse));
                stdlat=std(geog_lat(jtuse));
                meanlon=mean(geog_long(jtuse));
                stdlon=std(geog_long(jtuse));
                plot(U(jtuse)/H2O_conv,r(jtuse),colsymCWV(jp,:),'markersize',8,'linewidth',2)
                hold on
                legst=[legst;sprintf('%5.2f-%5.2f UT  lat:%6.2f+-%5.2f  lon:%7.2f+-%5.2f  %s',UTbeg_prf(jp),UTend_prf(jp),meanlat,stdlat,meanlon,stdlon,flag_direc(jp,:))];
            end
            xlabel('Columnar Water Vapor [cm]','fontsize',16)
            ylabel('Altitude [km]','fontsize',16)
            grid on
            set(gca,'ylim',[zmin zmax],'xlim',CWVlim,'xtick',[CWVlim(1):0.1:CWVlim(2)],'fontsize',16)
        end
        titlestr4=sprintf('%s %2i/%2i/%2i %s V0:%s',site,month,day,year,filename,flag_calib);
        for i=1:length(titlestr4),
            if strcmp(titlestr4(i),'_') titlestr4(i)='-'; end
        end
        title(titlestr4,'fontsize',14);
        hleg190=legend(legst);
        set(hleg190,'fontsize',14)
        
        figure(191)
        for jf=1:nprf_figs,
            for ip=1:2,
                jp = (jf-1)*2 + ip
                jtuseall=find(UT>=UTbeg_prf(1,jp)&UT<=UTend_prf(1,jp));
                plot(U(jtuseall)/H2O_conv,r(jtuseall),colsymCWV(jp,:),'markersize',8,'linewidth',2)
                hold on
            end
            xlabel('Columnar Water Vapor [cm] unfiltered','fontsize',16)
            ylabel('Altitude [km]','fontsize',16)
            grid on
            set(gca,'ylim',[zmin zmax],'xlim',CWVlim,'xtick',[CWVlim(1):0.1:CWVlim(2)],'fontsize',16)
        end        
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

%This was location of frost_filter for ARCTAS...note that it did not recalculate spectral fit params
%if strcmp(frost_filter,'yes')
%end

if strcmp(dirt_filter,'yes')
     tau_aero(12:14,UT>21.2)=-9999;
     tau_aero_err(12:14,UT>21.2)=-9999;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% begin special treatment for COAST to handle wing reflection data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(flag_call_wingglintremoval,'yes')
    test_COAST_wingglint_removal

    %replace tau_aero and tau_aero_err with filtered values
    tau_aero=tau_aero_filt_all;
    tau_aero_err=tau_aero_err_filt_all;
   
    %Now recalculate opt depth vs wvl fits
    for i=1:n(1)
        wvl_use=(tau_aero(:,i)>0)' & wvluse_alpha==1;  %modified 7/11/08 to omit certain wvl; catch the AOD(lambda) which are < 0 and don't use for Angstrom fit
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
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end special treatment for COAST to handle wing reflection data  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
UTlim111=[-inf inf];
%UTlim111=[13.8 18];
subplot(6,1,1)
plot(UT,GPS_Alt,'.',UT,Press_Alt,'.','markersize',6)
title(titlestr,'FontSize',14);
set(gca,'xlim',UTlim111)
ylabel('Altitude (km)')
legend('GPS alt', 'Press alt')
set(gca,'ylim',[-0.1 9])
grid on

subplot(6,1,2)
plot(UT,tau_aero(wvl_aero==1,:),'.','markersize',6);
grid on
%set(gca,'ylim',[0 .04])
set(gca,'xlim',UTlim111)
xlabel('UT');
ylabel('AOD');

subplot(6,1,3)
plot(UT(L_cloud==1),tau_aero(wvl_aero==1,L_cloud==1),'.','markersize',6);
grid on
%set(gca,'ylim',[0 inf])
%set(gca,'xlim',xx)
set(gca,'xlim',UTlim111)
xlabel('UT');
ylabel('AOD screened');

subplot(6,1,4)
plot(UT,rel_sd(wvl_aero==1,:),'.','markersize',6);
grid on
%set(gca,'xlim',xx)
set(gca,'xlim',UTlim111)
set(gca,'ylim',[0 2*sd_crit_aero])
xlabel('UT');
ylabel('Rel Stdev - not screened');

subplot(6,1,5)
plot(UT(L_cloud==1),rel_sd(wvl_aero==1,L_cloud==1),'.','markersize',6);
grid on
%set(gca,'xlim',xx)
set(gca,'xlim',UTlim111)
set(gca,'ylim',[0 2*sd_crit_aero])
xlabel('UT');
ylabel('Rel Stdev - cloud-screened');

subplot(6,1,6)
plot(UT,alpha,'.',UT(L_cloud==1),alpha(L_cloud==1),'g.','markersize',6);
grid on
%set(gca,'xlim',xx)
set(gca,'xlim',UTlim111)
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
UTspec=[18.9 19.2]; %%
UTspec=[15.8 16.2]; %7/12/08
UTspec=[16.4 17.8]; %MLO 9/20/11
switch day
    case 26
        UTspec=[17.5 22.5]; %COAST 10/26/11
    case 27
        UTspec=[19 21.55]; %COAST 10/27/11
    case 28
        UTspec=[17.5 22.5]; %COAST 10/28/11
end
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

jwp=[2 3 5 8 11 14];
jwp=[1:9 11 12 14];
aodlim222=[0 1];
legstr222=[];
for i=1:length(jwp),
    legstr222=[legstr222;sprintf('%5.3f',lambda(jwp(i)))];
end
figure(222)
subplot(3,1,1)
plot(UT(kspec),tau_aero(jwp,kspec),'.','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',aodlim222)%,'ytick',[0:0.01:0.04])
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
set(gca,'xlim',UTspec,'ylim',[0 90])
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
plot(UT(kspec),data(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[2 10])
ylabel('Det V','fontsize',16)
grid on
subplot(4,1,4)
plot(UT(kspec),rel_sd(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 0.004])
ylabel('Det Rel Sd','fontsize',16)
grid on
xlabel('UT','fontsize',16)

figure(224)
subplot(2,1,1)
plot(Az_pos(kspec),tau_aero(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',[0 360],'ylim',aodlim222)
ylabel('AOD','fontsize',16)
xlabel('Solar Azimuth relative to AATS (deg)','fontsize',16)
grid on
title(titlestr221,'fontsize',14)
subplot(2,1,2)
plot(Elev_pos(kspec),tau_aero(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'ylim',aodlim222)
ylabel('AOD','fontsize',16)
xlabel('Solar Elevation relative to AATS (deg)','fontsize',16)
grid on

figure(225)
subplot(4,1,1)
[ax,h1,h2]=plotyy(UT(kspec),geog_lat(kspec),UT(kspec),geog_long(kspec))
set(h1,'marker','.','color','b','markersize',8)
set(h2,'marker','.','color','r','markersize',8)
set(ax(1),'fontsize',16,'ylim',[36.6 37.2],'ytick',[36.6:0.2:37.2],'xlim',UTspec,'ycolor','b')
ylabel(ax(1),'Latitude','fontsize',16)
set(ax(2),'fontsize',16,'ylim',[-122.2 -121.6],'ytick',[-122.2:0.2:-121.6],'xlim',UTspec,'ycolor','r')
ylabel(ax(2),'Longitude','fontsize',16)
grid on
title(titlestr221,'fontsize',14)
subplot(4,1,2)
plot(UT(kspec),data(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[2 10])
ylabel('Det V','fontsize',16)
grid on
subplot(4,1,3)
plot(UT(kspec),rel_sd(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 0.004])
ylabel('Det Rel Sd','fontsize',16)
grid on
subplot(4,1,4)
plot(UT(kspec),tau_aero(jwp,kspec),'.','markersize',8)
set(gca,'xlim',UTspec,'ylim',[0 0.2])
set(gca,'fontsize',16)
grid on
ylabel('AOD unscreened','fontsize',16)
xlabel('UT','fontsize',16)
hleg222=legend(legstr222);
set(hleg222,'fontsize',9)

%now redefine kspec_filt to include only L_cloud==1 measurements
kspec_filt=find(UT>=UTspec(1)&UT<=UTspec(2)&L_cloud==1);
figure(227)
ax=subplot(4,1,1)
%plot(UT(kspec),data(jwp,kspec),'.-','markersize',8)
%[ax,h1,h2]=plotyy(UT(kspec),GPS_Alt(kspec),UT(kspec),data(jwp,kspec))%'.-','markersize',8)
%set(h2,'marker','.','markersize',8)
%set(h1,'marker','x','color','k','linestyle','--','linewidth',2)
%set(ax(2),'fontsize',16,'ylim',[2 10],'ytick',[2:2:10],'xlim',UTspec,'ycolor','b')
%ylabel(ax(2),'Det Signal (V)','fontsize',16)
%set(ax(1),'fontsize',16,'ylim',[0 2],'ytick',[0:0.5:2],'xlim',UTspec,'ycolor','k')
%ylabel(ax(1),'GPS alt (km)','fontsize',16)
plot(UT(kspec),GPS_Alt(kspec),'x--','markersize',6)
set(gca,'ylim',[0 2],'ytick',[0:0.5:2],'xlim',UTspec,'ycolor','k')
set(gca,'fontsize',16)
ylabel('GPS alt (km)','fontsize',16)
grid on
title(sprintf('%s  relsd-crit:%6.4f',titlestr221,sd_crit_aero),'fontsize',14)
ax2=subplot(4,1,2)
plot(UT(kspec),rel_sd(jwp,kspec),'.-','markersize',8)
set(gca,'fontsize',16)
set(gca,'xlim',UTspec,'ylim',[0 0.004])
ylabel('Det Rel Sd','fontsize',16)
grid on
ax3=subplot(4,1,3)
plot(UT(kspec),tau_aero(jwp,kspec),'.','markersize',8)
set(gca,'xlim',UTspec,'ylim',[0 0.2])
set(gca,'fontsize',16)
grid on
ylabel('AOD unscreened','fontsize',16)
ax4=subplot(4,1,4)
plot(UT(kspec_filt),tau_aero(jwp,kspec_filt),'.','markersize',8)
set(gca,'xlim',UTspec,'ylim',[0 0.2])
set(gca,'fontsize',16)
grid on
ylabel('AOD screened','fontsize',16)
xlabel('UT','fontsize',16)
hleg222=legend(legstr222);
set(hleg222,'fontsize',9)
linkaxes([ax ax2 ax3 ax4],'x')

%3-frame plot of lat/lon vs UT, GPS alt vs UT, screened AOD vs UT
figure(229)
subplot(3,1,1)
[ax1,h1,h2]=plotyy(UT(kspec),geog_lat(kspec),UT(kspec),geog_long(kspec))
set(h1,'marker','.','color','b','markersize',8)
set(h2,'marker','.','color','r','markersize',8)
set(ax1(1),'fontsize',16,'ylim',[36.6 37.2],'ytick',[36.6:0.2:37.2],'xlim',UTspec,'ycolor','b')
ylabel(ax1(1),'Latitude','fontsize',16)
set(ax1(2),'fontsize',16,'ylim',[-122.2 -121.6],'ytick',[-122.2:0.2:-121.6],'xlim',UTspec,'ycolor','r')
ylabel(ax1(2),'Longitude','fontsize',16)
grid on
title(sprintf('%s  relsd-crit:%6.4f',titlestr221,sd_crit_aero),'fontsize',14)
subplot(3,1,2)
[ax2,h1,h2]=plotyy(UT(kspec),data(jwp,kspec),UT(kspec),GPS_Alt(kspec))
set(h1,'marker','.','markersize',8)
set(h2,'marker','none','color','y','linestyle','-','linewidth',4)
set(ax2(1),'fontsize',16,'ylim',[2 10],'ytick',[2:2:10],'xlim',UTspec,'ycolor','b')
ylabel(ax2(1),'Det Signal (V)','fontsize',16)
set(ax2(2),'fontsize',16,'ylim',[0 2],'ytick',[0:0.5:2],'xlim',UTspec,'ycolor','k')
axes(ax2(2))
hold on
hyellow=line(UT(kspec),GPS_Alt(kspec))
set(hyellow,'linestyle','-','color','k','linewidth',2)
ylabel(ax2(2),'GPS alt (km)','fontsize',16)
set(gca,'fontsize',16)
grid on
ax3=subplot(3,1,3)
plot(UT(kspec_filt),tau_aero(jwp,kspec_filt),'.','markersize',8)
set(gca,'xlim',UTspec,'ylim',[0 0.2])
set(gca,'fontsize',16)
grid on
ylabel('AOD screened','fontsize',16)
xlabel('UT','fontsize',16)
hleg222=legend(legstr222);
set(hleg222,'fontsize',9)
linkaxes([ax1 ax2 ax3],'x')

%plot Latitude or Longitude vs AOD
kwp=[5];
UTcritlat=[18.4 18.65];
klatlon=find(UT>=UTcritlat(1)&UT<=UTcritlat(2)&L_cloud==1);
titlestr231=sprintf('%s %2i.%2i.%2i %s %g-%g %s',site,day,month,year,filename,UTcritlat,'UT');
figure(231)
subplot(1,2,1)
scatter(tau_aero(kwp,klatlon),geog_lat(klatlon),50,GPS_Alt(klatlon),'filled')
set(gca,'fontsize',16,'box','on')
grid on
xlabel(sprintf('AOD (%4.0f nm)',1000*lambda(kwp)),'fontsize',20)
ylabel('Latitude','fontsize',20)
title(titlestr231,'fontsize',14)
colorbar('North')
subplot(1,2,2)
scatter(tau_aero(kwp,klatlon),geog_long(klatlon),50,GPS_Alt(klatlon),'filled')
set(gca,'fontsize',16,'box','on')
grid on
xlabel(sprintf('AOD (%4.0f nm)',1000*lambda(kwp)),'fontsize',20)
ylabel('Longitude','fontsize',20)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prepare output
%write to file
if strcmp(archive_GH,'ON')
    dataarchive_dir='c:\johnmatlab\AATS14_2011_COASTarchive\';
    day_arr = [ julian(26,10,2011,0) julian(27,10,2011,0) julian(28,10,2011,0)];
    FlightNo_arr = [1:length(day_arr)];
    FlightNo = FlightNo_arr(find( day_arr == julian(day, month,year,0)))
    
    if strcmp(flag_LH2O_equal_Lcloud,'yes') %for archival purposes, set L_H2O=L_cloud
        L_H2O=L_cloud;
    end
    
    [ntimwrt,filename_arc]=archive_AATS14_COAST(filename,dataarchive_dir,FlightNo,UT,day,month,year,lambda,V0,NO2_clima,Loschmidt,...
        L_cloud,L_H2O,SZA,geog_lat,geog_long,GPS_Alt,Press_Alt,press,U/H2O_conv,H2O_err,-gamma,-alpha,a0,O3_col_fit,unc_ozone,tau_aero,tau_aero_err,...
        O3_estimate,wvl_aero,wvl_water,a_H2O,b_H2O,sd_crit_aero,sd_crit_H2O,sd_crit_aero_highalt,zGPS_highalt_crit,m_aero_max,tau_aero_limit,...
        tau_aero_err_max,alpha_min,alpha_min_lowalt,flag_calib,Temperature,rel_sd,frost_filter,dirt_filter,UT_smoke,sd_crit_aero_smoke,...
        flag_interpOMIozone,filename_OMIO3,AvePeriod,UTCan);
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
        if strcmp(site,'Mauna Loa')
            data_dir_wrt='c:\johnmatlab\AATS14_2008_MLOarchive\';
            resultfile=['AATS14_',filename(1:8),'.asc']
            fid=fopen([data_dir_wrt resultfile],'w');
            fprintf(fid,'%s\r\n','NASA Ames Airborne Tracking 14-Channel Sunphotometer, AATS-14');
            fprintf(fid,'%s %2i/%2i/%4i\r\n',site,month,day,year);
            fprintf(fid,'%s %s %s\r\n', 'Date processed:',date, 'by John Livingston, Version 1.0');
            fprintf(fid,'%s %g\r\n', 'NO2 [molec/cm2]:',NO2_clima*Loschmidt);
            fprintf(fid,'%s %g\r\n', 'O3 [DU]:',1000*O3_col_start);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter Aerosol[%]:',100*sd_crit_aero);
            fprintf(fid,'%s %3.1f\r\n', 'Relative Std Dev Filter H2O [%]:',100*sd_crit_H2O);
            fprintf(fid,'%s %g\r\n', 'Max m_aero:',m_aero_max);
            fprintf(fid,'%s %3.1f\r\n', 'Max tau_aero:',tau_aero_limit);
            fprintf(fid,'%s %3.2f\r\n', 'Max tau_aero error:',tau_aero_err_max);
            fprintf(fid,'%s %4.2f\r\n', 'Min Alpha Angstrom:',alpha_min);
            fprintf(fid,'%s %g %s %g\r\n','H2O coeff.  a:',a_H2O(wvl_water==1),'b:', b_H2O(wvl_water==1));
            fprintf(fid,'%s', 'wavelengths [10^-6 m]:        ');
            fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n', lambda);
            fprintf(fid,'%s',flag_calib,' V0 values:');
            fprintf(fid,'%7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n', V0);
            %fprintf(fid,'%s %s %s %s\r\n','UT[h] Lat[deg] Long[deg] GPS_Alt[km] p_Alt[km] p[hPa]  H2O[cm] H2O_Err[cm] ozone[matm-cm] unc_O3[matm-cm] AOD_flag',num2str(lambda(wvl_aero==1)'*1000,'AOD%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),'a2_fit a1_fit a0_fit');
            fprintf(fid,'%s %s %s %s\r\n','  UT[h]   Lat[deg]  Long[deg]  Alt[km]   p[hPa]   H2O[cm]  H2O_Err[cm] O3[matm-cm] unc_O3[matm-cm]  AOD_flag',num2str(lambda(wvl_aero==1)'*1000,'AOD%04.0f '),num2str(lambda(wvl_aero==1)'*1000,'Err%04.0f '),' a2_fit  a1_fit  a0_fit');
            dummy=[UT',geog_lat',geog_long',GPS_Alt',press,U'/H2O_conv,H2O_err',ozone,unc_ozone',L_cloud',tau_aero(wvl_aero==1,:)',tau_aero_err(wvl_aero==1,:)',-gamma',-alpha',a0']';
            dummy=dummy(:,L_H2O==1);  %save only cases where water vapor is acceptable
            fprintf(fid,'%08.5f %9.5f %9.5f %8.3f %8.2f %9.4f %10.4f %10.3f %13.4f %10d %11.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f %7.4f\r\n',dummy);
            fclose(fid);
        elseif strcmp(site,'SAFARI-2000')
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
end