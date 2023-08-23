function zrad_csphot_nfov_sasze(fig)
% zrad_csphot_nfov_sasze(fig)
% If fig is not supplied then no plots will be generated.
% This function  prompts for zenith radiance measurements, PPL scans, and MFRSR files 
% (for DDR test) to model PPL and zenith radiance.  The agreement between the
% measured and modeled PPL, the measured and modedl DDR, and the aip sky_err 
% provide QA for a calibration factor between the SASZe measure radiances and 
% model (SBDART). Also limit airmass range?  Also look at clearsky fraction derived
% from spectral shape of direct-diffuse?

% Having troubles getting HOU PPL to match over full WL range. Maybe sfc_alb
% Ideas: modify with strings to identify wavelengths
% Evaluate Krad stability as function of SASZe WL
% Stitch VIS and NIR
% Test with both Ze and TWST
% Explore MFRSR-like retrieval, require good duration of stable AOD plus low
% diffuse-based cloud fraction
% Incorporate imager based cloud fraction or radflux clearsky
% Implement with case statement blocks for different combos.
% Divide SBDART zenith radiance by ESR, thus reporting unitless/normalized zenith
% radiances
% See how constant the Krad factor is vs wavelength
% Smooth Krad with IQ and lowess etc.


loopy = false;
if ~loopy
   fig = [];
end
M1_ = anc_bundle_files(getfullname('*mfr*.*','mfrC1'));
nfov  = anc_bundle_files(getfullname('*nfov*','nfov'));

csphot_zrad = anc_bundle_files(getfullname('*csp*.*','csphot'));
cim_all = rd_anetaip_v3;
aip_ppl = anet_ppl_SA_and_radiance;


% figure_(9); plot(C1.time, C1.vdata.direct_diffuse_ratio_filter1,'o', ...
%    E13.time, E13.vdata.direct_diffuse_ratio_filter1,'x',...
%   cim_all.time, cim_all.Single_Scattering_Albedo_440nm_,'c*' );
% legend('D2D C1','D2D E13','SSA');dynamicDateTicks;
% yl = ylim; yl(1) = 0; yl(2) = 1.1;
% ylim(yl);
% liny
% twst = rd_twst_nc4;


sasze_ = anc_bundle_files(getfullname('*saszefilter*.*','sasaze_filt'));

% Medium picture, apply homogeniety sceen to sasze filterbands to identify times

% These define the Aeronet WLs for the sky scan retrieved quantities
qry.wlbaer = [0.44, 0.675, 0.87, 1.02];

K = 1;
% ppl_ij = find(aip_ppl.Nominal_Wavelength_nm_==675 & aip_ppl.time>datenum(2022,9,14) & aip_ppl.time<nfov.time(end));
%%%
% Put filter blocks here:
mfr_am_filt = '1';
mfr_ddr_filt = '1'; %415 nm
cim_wl = '440nm_';
cim_wl_ij = 6; %1640   1020    870    675    500    440    380
ppl_wl = 440;
ze_filt = '415nm';
nfov_filt = '673nm';
sb_wl = 415./1000;

am_good = M1_.vdata.airmass >=1 & M1_.vdata.airmass<=6 & M1_.vdata.(['direct_diffuse_ratio_filter',mfr_am_filt])>0;
M1 = anc_sift(M1_, am_good);

cim_ij = find(cim_all.(['Single_Scattering_Albedo_',cim_wl])>0);
ppl_ij = find(aip_ppl.Nominal_Wavelength_nm_==ppl_wl & aip_ppl.time>nfov.time(1) & aip_ppl.time<nfov.time(end));

sasze = anc_sift(sasze_, sasze_.vdata.(['zenith_radiance_',ze_filt])>0);

qry.WLINF =  sb_wl;
qry.WLSUP =  sb_wl;
% qry.WLINC =  0.001;
qry.ISAT = 0;
qry.iaer=5;
%%%
% Put filter blocks here:
mfr_am_filt = '1';
mfr_ddr_filt = '1'; %415 nm
cim_wl = '440nm_';
cim_wl_ij = 5; %1640   1020    870    675    500    440    380
ppl_wl = 440;
ze_filt = '500nm';
nfov_filt = '673nm';
sb_wl = 500./1000;

am_good = M1_.vdata.airmass >=1 & M1_.vdata.airmass<=6 & M1_.vdata.(['direct_diffuse_ratio_filter',mfr_am_filt])>0;
M1 = anc_sift(M1_, am_good);

cim_ij = find(cim_all.(['Single_Scattering_Albedo_',cim_wl])>0);
ppl_ij = find(aip_ppl.Nominal_Wavelength_nm_==ppl_wl & aip_ppl.time>nfov.time(1) & aip_ppl.time<nfov.time(end));

sasze = anc_sift(sasze_, sasze_.vdata.(['zenith_radiance_',ze_filt])>0);

qry.WLINF =  sb_wl;
qry.WLSUP =  sb_wl;
% qry.WLINC =  0.001;
qry.ISAT = 0;
qry.iaer=5;
%%%
% Put filter blocks here:
mfr_am_filt = '1';
mfr_ddr_filt = '4'; %675 nm
cim_wl = '675nm_';
cim_wl_ij = 4;
ppl_wl = 675;
ze_filt = '673nm';
nfov_filt = '673nm';
sb_wl = 675./1000;

am_good = M1_.vdata.airmass >=1 & M1_.vdata.airmass<=6 & M1_.vdata.(['direct_diffuse_ratio_filter',mfr_am_filt])>0;
M1 = anc_sift(M1_, am_good);

cim_ij = find(cim_all.(['Single_Scattering_Albedo_',cim_wl])>0);
ppl_ij = find(aip_ppl.Nominal_Wavelength_nm_==ppl_wl & aip_ppl.time>nfov.time(1) & aip_ppl.time<nfov.time(end));

sasze = anc_sift(sasze_, sasze_.vdata.(['zenith_radiance_',ze_filt])>0);

qry.WLINF =  sb_wl;
qry.WLSUP =  sb_wl;
% qry.WLINC =  0.001;
qry.ISAT = 0;
qry.iaer=5;
%%%
% put outside plots here:

if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
   figure_(fig.Number+3); plot(csphot_zrad.time, csphot_zrad.vdata.zenith_sky_radiance_A(cim_wl_ij,:),'o',...
      aip_ppl.time(ppl_ij), aip_ppl.zen_rad(ppl_ij),'x', ...
      nfov.time, 100.*nfov.vdata.(['radiance_',nfov_filt]), '.', ...
      sasze.time, sasze.vdata.(['zenith_radiance_',ze_filt])./10, '.'); dynamicDateTicks;
   xlabel('time'); ylabel(csphot_zrad.vatts.zenith_sky_radiance_A.units,'interp','tex');
   legend('csphot cld','csphot ppl','nfov*100','sasze/10')
end

if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
   figure_(fig.Number+1); plot(M1.time, M1.vdata.(['direct_diffuse_ratio_filter',mfr_ddr_filt]), 'k+');legend(['D2D ',ze_filt]); dynamicDateTicks
end

%%%
for ij = length(ppl_ij):-1:1
      if loopy
      mn = menu('Select "One Loop" or "Free Run" or "Pause" or "Exit":', 'One Loop','Free Run','Pause','Exit');
      if mn==1
         loopy = true; % Check everytime
      elseif mn==2
         loopy = false; fig = [];
      elseif mn==3
         keyboard;
      elseif mn==4
         return
      end
   end
   ij
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig.Number+11); close(fig.Number+11); figure_(fig.Number+43); close(fig.Number+43);
   end
   qry.qbaer(4) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_1020nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.qbaer(3) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_870nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.qbaer(2) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_675nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.qbaer(1) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_440nm_, aip_ppl.time(ppl_ij(ij)),'linear');

   qry.wbaer(4) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_1020nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.wbaer(3) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_870nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.wbaer(2) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_675nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.wbaer(1) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_440nm_, aip_ppl.time(ppl_ij(ij)),'linear');

   qry.gbaer(4) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_1020nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.gbaer(3) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_870nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.gbaer(2) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_675nm_, aip_ppl.time(ppl_ij(ij)),'linear');
   qry.gbaer(1) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_440nm_ , aip_ppl.time(ppl_ij(ij)),'linear');
   qry.SZA=aip_ppl.Solar_Zenith_Angle_Degrees_(ppl_ij(ij));
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig.Number+43);
      plot(aip_ppl.SA,aip_ppl.radiance(ppl_ij(ij),:),'-');logy
      title({['SGP CF Aeronet PPL ',sprintf('%d nm',ppl_wl)];[datestr(aip_ppl.time(ppl_ij(ij)),'yyyy-mm-dd HH:MM:SS')]});
      xlabel('Scattering Angle [deg]'); ylabel(['Radiance [uW/(cm^2/nm/sr)]'],'interp','tex');
   end
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig.Number+44);
      plot(aip_ppl.Solar_Zenith_Angle_Degrees_(ppl_ij(ij))-aip_ppl.dZa,aip_ppl.radiance(ppl_ij(ij),:),'-');logy
     title({['SGP CF Aeronet PPL ',sprintf('%d nm',ppl_wl)];[datestr(aip_ppl.time(ppl_ij(ij)),'yyyy-mm-dd HH:MM:SS')]});
      xlabel('Zenith Angle [deg]'); ylabel(['Radiance [uW/(cm^2/nm/sr)]'],'interp','tex')
   end
   % alm  = run_sbdart_alm(qry);
   qry.ISALB = 4; qry.IOUT=6;
   ppl  = run_sbdart_ppl(qry);
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig.Number+44); hold('on'); plot(ppl.zen, ppl.rad./10,'r-');legend('sbdart ppl./10'); logy; hold('off')
   end
   sas_xl = sasze.time>(aip_ppl.time(ppl_ij(ij))-.25./24)&sasze.time<(aip_ppl.time(ppl_ij(ij))+.25./24);
   sasze_zrad = mean(sasze.vdata.(['zenith_radiance_',ze_filt])(sas_xl & sasze.vdata.(['zenith_radiance_',ze_filt])>0));
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig.Number+3); xlim([aip_ppl.time(ppl_ij(ij))-.5./24,aip_ppl.time(ppl_ij(ij))+.5./24] );
      hold('on'); plot( mean(sasze.time(sas_xl & sasze.vdata.(['zenith_radiance_',ze_filt])>0)), sasze_zrad./10,'k*'); hold('off');
   end
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig.Number+1); xlim([aip_ppl.time(ppl_ij(ij))-.5./24,aip_ppl.time(ppl_ij(ij))+.5./24] );
   end
   Krad(ij) = ppl.zrad ./ (sasze_zrad); %factor of 10 is just for units
   D2D(ij) = ppl.DIRN2DIF;

   % twst_440 = interp1(twst.wl_A, [1:length(twst.wl_A)],440,'nearest');
   % twst_time = interp1(twst.time, [1:length(twst.time)], aip_ppl.time(ppl_ij(ij)),'nearest', 'extrap');
   % figure_(5); plot(twst.time, twst.zenrad_A(twst_440,:),'k.',twst.time(twst_time), twst.zenrad_A(twst_440,twst_time),'ro' ); dynamicDateTicks;
   % ylabel('W/m2/nm/sr')
   % legend([leg_str(:);'mean'])
end
K = K+1;
% The agreement between the
% measured and modeled PPL, the measured and modedl DDR, and the aip sky_err 
% provide QA for a calibration factor between the SASZe measure radiances and 
% model (SBDART). Also limit airmass range?  Also look at clearsky fraction derived
% from spectral shape of direct-diffuse?

% Make an array or structure with Krad and different blocks or tests?

%How-to: 
% 1) Interpolate the prospective QA parameter onto Krad times (aip_ppl.time(ppl_ij)
% 2) Create a scatter plot of Krad(s) colored with parameter to see if pattern appears
% 3) Apply a threshold cut to Krad, look at before and after time series
% 4) Look at smoothed time-series before and after.


Kal(K).time = aip_ppl.time(ppl_ij); 
Kal(K).Krad = Krad;
Kal(K).wl = {ze_filt};
%direct-diffuse ratio tests. Some correlation with Krad is clear
mfr_D2D = interp1(M1.time, M1.vdata.(['direct_diffuse_ratio_filter',mfr_am_filt]), Kal(K).time,'linear')'; 
D2D_rat = D2D./mfr_D2D;
figure; plot(Kal(K).time, D2D_rat,'x'); dynamicDateTicks; title('high values are bad')
figure; plot(Kal(K).time, Krad,'r.',Kal(K).time(D2D_rat>.75&D2D_rat<2.5), Krad(D2D_rat>.75&D2D_rat<2.5),'go' );  dynamicDateTicks
figure; scatter(Kal(K).time, Krad, 32, (D2D_rat),'filled')

%sky_err, no correlation evident
Sky_err = interp1(cim_all.time, cim_all.Sky_Residual_pct__, Kal(K).time,'linear')'; 
figure; plot(Kal(K).time, Sky_err,'x'); dynamicDateTicks; title('high values are bad')
figure; scatter(Kal(K).time, Krad, 16, Sky_err,'filled');colorbar; caxis([0,10])

%no AOD correlation observed
AOD_in = interp1(cim_all.time, cim_all.Coincident_AOD440nm, Kal(K).time,'linear')'; 
figure; scatter(Kal(K).time, Krad, 16, AOD_in,'filled');colorbar; 

%airmass observed but unhelpful
AM_in = interp1(M1.time, M1.vdata.airmass, Kal(K).time,'linear')'; 
figure; scatter(Kal(K).time, Krad, 16, AM_in,'filled');colorbar; 

Kal(K).time_ = Kal(K).time(D2D_rat>.5&D2D_rat<3);
Kal(K).Krad_ = Kal(K).Krad(D2D_rat>.5&D2D_rat<3)';

[good] = IQF_span(Kal(K).Krad_, 30);

figure; plot(Kal(K).time_(good), Kal(K).Krad_(good),'go',...
   Kal(K).time_(good), smooth(Kal(K).time_(good),Kal(K).Krad_(good),30,'lowess'),'-');dynamicDateTicks

figure; plot(Kal(K).time, Kal(K).Krad, 'r.',Kal(K).time_, Kal(K).Krad_, '*',...
   Kal(K).time_(good), Kal(K).Krad_(good),'go',...
   Kal(K).time_(good), smooth(Kal(K).time_(good),Kal(K).Krad_(good),30,'lowess'),'-');

end


