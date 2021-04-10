function sasModLangley
% Modified Langley calculation
% Based on old AATS method
% and AOD derivation by baseline
%


%daystr='20130712';
stdev_mult=2;%:0.5:3; % screening criteria, as multiples for standard deviation of the rateaero.
% col=408; % for screening. this should actually be plural - code to be developed
% cols=[225   258   347   408   432   539   627   761   869   969]; % for plots
% savefigure=0;

%********************
% generate a new cal
%********************
sfile = getfullname('*.cdf;*.nc','pvc_sashevis');
sasvis = anc_load(sfile)
sasnir = anc_load(strrep(sfile,'vis','nir'));
% t = sas.time; w = sas.vdata.wavelength; 
% starfile = getfullname('*starsun.mat','starsun','Select a starsun.mat file.');
% 
% star= load(starfile, 'w');

% % tau_aero = tau_aero_noscreening;
% % 
% % starinfofile=fullfile(starpaths, ['starinfo' daystr(1:8) '.m']);
% % s=importdata(starinfofile);
% % %s1=s(strmatch('langley',s));
% % s1=s(strncmp('langley',s,1));
% % eval(s1{:});
% % % chose Langley period values
% ok=incl(t,langley);
% load water vapor coef
% load H2O a and b parameters
 watvapcoef = load(which('H2O_cross_section_FWHM_new_spec_all_range_midLatwsum6000m.mat')); % Mid-Lat summer use for ORACLES 2nd transit  
 % Now merge vis and nir specs.
 cross_sections=load(which( 'cross_sections_uv_vis_swir_all.mat')); % load newest cross section vesion (October 15th 2012) MS
 mark = find(diff(cross_sections.wln)<0,1,'first');
 % th watvapcoef values are sorted by wavelength and so mix the 4STAR VIS and
 % NIR coefs.  The cross-section values are not sorted but show disjoint
 % values for VIS and NIR, perhaps due to WL?  Then why don't they differ
 % in the watvapcoef file? Bug?
 % But the wavelengts in each of these files agrees tightly by numeric
 % value. So I'll use this agreement to find the values from watvapcoef
 % that map directly to the VIS spectrometer
[ainb,bina] = nearest(watvapcoef.wavelen,  cross_sections.wln(1:mark)');
% Strike that, I'll just use the sorted WL and coefs n watvapcoef and map
% SAS wavelengths directly to those. 
vis_i = interp1(watvapcoef.wavelen, 1:length(watvapcoef.wavelen), sasvis.vdata.wavelength,'nearest');
% Strike that, I'll interpolate the watvapcoef values to the SAS wavelength
% grid
sasvis.watvap_cs = interp1(watvapcoef.wavelen, watvapcoef.cs_sort, sasvis.vdata.wavelength,'pchip');
sasvis.watvap_Tr = interp1(watvapcoef.wavelen, watvapcoef.T, sasvis.vdata.wavelength,'pchip');
sasnir.watvap_cs = interp1(watvapcoef.wavelen, watvapcoef.cs_sort, sasnir.vdata.wavelength,'pchip');
sasnir.watvap_Tr = interp1(watvapcoef.wavelen, watvapcoef.T, sasnir.vdata.wavelength,'pchip');

 t = sasvis.time;
 wvis = sasvis.vdata.wavelength./1000;
 H2Oa = sasvis.watvap_cs(:,1);
 H2Ob = sasvis.watvap_cs(:,2);
 % transform H2Oa nan to zero
 H2Oa(isnan(H2Oa)==1)=0;
 % transform H2Oa inf to zero
 H2Oa(isinf(H2Oa)==1)=0;
 % transform H2Oa negative to zero
 H2Oa(H2Oa<0)=0;
 % transform H2Ob to zero if H2Oa is zero
 H2Ob(H2Oa==0)=0;
 % plot parameter values
     figure;
     ax(1)=subplot(2,1,1);plot(wvis,H2Oa,'-b');legend('H2O a parameter');
     ax(2)=subplot(2,1,2);plot(wvis,H2Ob,'-r');legend('H2O b parameter');
     linkaxes(ax,'x');
     
figure; plot(serial2doys(sasvis.time), sasvis.vdata.direct_normal_transmittance(340,:),'.b-');
legend('direct normal Tr');xlabel('time UT'); ylabel('dirn Tr');zoom('on');
clip = menu('Select the region of time to use for Langley','OK');
xl = xlim; xl_ = serial2doys(sasvis.time)>=xl(1)&serial2doys(sasvis.time)<=xl(2);
plot(sasvis.vdata.airmass, log(sasvis.vdata.direct_normal_transmittance(340,:)),'.k',...
   sasvis.vdata.airmass(xl_), log(sasvis.vdata.direct_normal_transmittance(340,xl_)),'ro');
legend('direct normal Tr'); xlabel('airmass'); ylabel('ln(dirn Tr)');zoom('on');
clip = menu('Select the region of airmass for Langley','OK');
al = xlim; al_ = xl_ & sasvis.vdata.airmass>=al(1)&sasvis.vdata.airmass<=al(2);
%
figure; sb(1) = subplot(2,1,1); 
plot(serial2doys(sasvis.time(xl_)), sasvis.vdata.direct_normal_transmittance(340,xl_),'.b-', ...
   serial2doys(sasvis.time(al_)), sasvis.vdata.direct_normal_transmittance(340,al_),'ro');
legend('by time','by airmass');zoom('on');
sb(2) = subplot(2,1,2); 
plot(sasvis.vdata.airmass(xl_), log(sasvis.vdata.direct_normal_transmittance(340,xl_)),'.b-', ...
   sasvis.vdata.airmass(al_), log(sasvis.vdata.direct_normal_transmittance(340,al_)),'ro');
legend('by time','by airmass');zoom('on');

% estimate tau_aero for water vapor region by using baseline fit

iwln  = find(wvis>=0.920&wvis<=0.98);
iwln  = find(wvis>=0.8823&wvis<=0.9945);
iwln2 = find(wvis>=0.9000&wvis<=0.9945);
iwln_900nm = interp1(wvis,[1:length(wvis)],0.9,'nearest');

tau_aero = sasvis.vdata.aerosol_optical_depth';
ok = find(al_);
al_ = al_ & ~any(tau_aero(:,iwln)<-1000,2)';
ok = find(al_);


qq = length(wvis);
pp = length(t);

order=1;                            % order of baseline polynomial fit
poly=zeros(length(wvis(iwln)),pp);  % calculated polynomial
polycoef=zeros(pp,(order)+1);       % polynomial coefficients
order_in=1; thresh_in=0.01;
am = [min(sasvis.vdata.airmass(al_)), max(sasvis.vdata.airmass(al_))];
for i=1:length(ok)
% function (fn) can be: 'sh','ah','stq','atq'
% for gui use (visualization) write:
% [poly2_,poly2_c_,iter,order,thresh,fn]=backcor(wvis(wln_ind),tau_aero(goodTime(i),wln_ind));
[poly_,polycoef_,iter,order,thresh,fn] = backcor(wvis(iwln),tau_aero(ok(i),iwln),order_in,thresh_in,'atq');% backcor(wavelength,signal,order,threshold,function);
poly(:,i)=poly_;          % calculated polynomials
polycoef(i,:)=polycoef_'; % polynomial coefficients

% %plot AOD baseline interpolation and real AOD values
%   figure_(1112)
%   plot(wvis(iwln),tau_aero(ok(i),iwln),'-');hold on;
%   plot(wvis(iwln),poly_,'-r','linewidth',2);hold off;
%   legend('AOD','AOD baseline');title(num2str(serial2Hh(t(ok(i)))));
%   pause(0.01);
end
    
watvap_tau_aero=(real(poly))';

% run modified Langley
% tau_NO2 = repmat(tau_NO2,pp,1);
rate = sasvis.vdata.direct_normal_transmittance';
tau_ray = ones(size(t'))*sasvis.vdata.rayleigh_optical_depth';
tau_O3 = ones(size(t'))*sasvis.vdata.ozone_optical_depth';
tau_O4 = zeros(size(tau_O3));
tau_NO2 = zeros(size(tau_O3));
m_aero = sasvis.vdata.airmass';
m_O3 = m_aero;
m_ray = m_aero; m_NO2 = m_ray; m_H2O = m_ray;
[c0_mod,residual,U]=modLangley(am,iwln,wvis(iwln),rate(ok,iwln),watvap_tau_aero(ok,:),...
  tau_ray(ok,iwln),tau_O4(ok,iwln),tau_O3(ok,iwln),tau_NO2(ok,iwln),...
  m_aero(ok),m_ray(ok),m_O3(ok),m_NO2(ok),m_H2O(ok),H2Oa(iwln),H2Ob(iwln),2);
                          
                         
%***********************
% save new  modified c0
%***********************
% embedd c0_mod (water vapor region) within c0
c0unc=NaN(size(wvis)); % put NaN for uncertainty - to be updated later
wln = wvis;
if strcmp(daystr,'20130212');
    c0=load(which('20130212_VIS_C0_refined_Langley_on_G1_firstL_flight_screened_2x_withOMIozone.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    % filesuffix='modified_Langley_on_G1_first_flight_screened_2x_withOMIozone';
    % filesuffix='modified_Langley_on_G1_first_flight_6km_screened_2x_withOMIozone';
    filesuffix='modified_Langley_on_G1_first_flight_6km_3c_screened_2x_withOMIozone';
    visfilename=fullfile(starpaths, [daystr '_VIS_C0_' filesuffix '.dat']);
elseif strcmp(daystr,'20130214')
    c0=importdata(which('20130214_VIS_C0_refined_Langley_on_G1_secondL_flight_screened_2x_withOMIozone.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    % filesuffix='modified_Langley_on_G1_secondL_flight_screened_2x_withOMIozone';
    filesuffix='modified_Langley_on_G1_secondL_flight_6_85km_screened_2x_withOMIozone';
    % filesuffix='modified_Langley_on_G1_secondL_flight_6km_3c_screened_2x_withOMIozone';
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
elseif strcmp(daystr,'20141002')  % ARISE
    %c0old=importdata(which('20141002_VIS_C0_refined_Langley_on_C-130_calib_flight_screened_2x_wFORJcorrAODscreened_wunc.dat'));
    c0=importdata(which( '20141002_VIS_C0_refined_Langley_on_C-130_calib_flight_screened_2x_wFORJcorrAODscreened_wunc_201510newcodes.dat'));
    %c0modold=importdata(which( '20141002_VIS_C0_modified_Langley_on_C-130_calib_flight_screened_2x_wFORJcorrAODscreened_wunc.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln2) = c0_mod(24:end);% applying only the region from 900 nm to end
    % test figure;
%     figure;
%     plot(wln,c0vis,'-b');hold on;
%     plot(wln,c0old.data(:,3),'--g');hold on;
%     plot(wln,c0mod,'--c');hold on;
%     plot(wln,c0modold.data(:,3),':m');hold on;
%     legend('c0','coold','modc0','modc0old');
%     axis([0.3 1 0 800]);
%     figure;
%     %plot(wln,100*(c0old.data(:,3) - c0vis)./c0old.data(:,3),'-m');
%     %axis([1 1.7 -0.1 0.1]);
%     plot(w(1045:end),100*(c0old.data(:,3) - c0.data(:,3))./c0old.data(:,3),'-r');
%     xlabel('wavelength');ylabel('%');legend('c0old - c0');
%     axis([1 1.7 -5 1]);
    %axis([0.8 1 0 200]);
    %filesuffix='modified_Langley_on_C-130_calib_flight_screened_2x_wFORJcorrAODscreened_wunc';
    filesuffix='modified_Langley_on_C-130_calib_flight_screened_2x_wFORJcorrAODscreened_wunc_201510newcodes';
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
elseif strcmp(daystr,'20151118')  % NAAMES
    c0=importdata(which( '20151118_VIS_C0_sunrise_refined_Langley_on_C130_screened_3.0x.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    filesuffix='modified_Langley_sunrise_refined_Langley_on_C130_screened_3.0';
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
elseif strcmp(daystr,'20151104')  % NAAMES ground
    c0=importdata(which( '20151104_VIS_C0_refined_Langley_at_WFF_Ground_screened_3correctO3.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    filesuffix='modified_Langley_at_WFF_Ground_screened_3correctO3';
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
elseif strcmp(daystr,'20160426')  % KORUS transit 1
    c0=importdata(which('20160426_VIS_C0_refined_Langley_korusaq_transit1_v1.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    filesuffix='modified_Langley_korusaq_transit1_v1'; 
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
    
elseif strcmp(daystr,'20160702')  % June-2016 MLO   
    c0file = '20160707_VIS_C0_Langley_MLO_June2016_mean.dat';
    c0=importdata(which(c0file));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    filesuffix='modified_Langley_MLO';
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
elseif strcmp(daystr,'20160825')  % ORACLES transit 2
    c0=importdata(which( '20160825_VIS_C0_refined_Langley_ORACLES_transit2.dat'));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    filesuffix='modified_Langley_ORACLES_transit2'; 
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
else % MLO modified Langleys
    %c0file = strcat(daystr,'_VIS_C0_refined_Langley_MLO_screened_2x.dat');
    %c0file = strcat(daystr,'_VIS_C0_refined_Langley_MLO_constrained_airmass_screened_2x.dat');
    %c0file = '20130708_VIS_C0_refined_Langley_at_MLO_screened_3.0x_averagethru20130712_20140718.dat';
    c0file = strcat(daystr,'_VIS_C0_refined_Langley_MLO.dat');
    c0=importdata(which(c0file));
    c0vis = c0.data(:,3);
    c0mod = c0vis;
    c0mod(iwln) = c0_mod;
    % filesuffix='modified_Langley_on_G1_secondL_flight_screened_2x_withOMIozone';
    % filesuffix='modified_Langley_MLOscreened_2x';
    % filesuffix='modified_Langley_MLOscreened_constrained_airmass_2x';
    % filesuffix='modified_Langley_on_G1_secondL_flight_6km_3c_screened_2x_withOMIozone';
    filesuffix='modified_Langley_MLO';
    % this is for the averaged file
    % filesuffix='modified_Langley_at_MLO_screened_2.0x_averagethru20130712_20140718';
    visfilename=which([daystr '_VIS_C0_' filesuffix '.dat']);
end

%nirfilename=which([daystr '_NIR_C0_' filesuffix '.dat']);!
%should we run modified for NIR as well?
if strcmp(daystr,'20141002')  
    additionalnotes='Modified Langley processed for 0.9000-0.9945 micron region';
    starsavec0(visfilename, source, additionalnotes,wln , c0mod', c0unc);
else
    additionalnotes='Modified Langley processed for 0.8823-0.9945 micron region';
    starsavec0(visfilename, source, additionalnotes,wln , c0mod', c0unc);
end
%starsavec0(nirfilename, source, additionalnotes, w(nircols), c0new(k,nircols), c0unc(:,nircols));
%
return