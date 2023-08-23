function sbdart_zrad_ppl
% small picture
% read aip "all" 
% model sbdart skyscans ppl and alm to validate modeled radiances
% which implies also reading alm and ppl aeronet files and plotting measured and
% modeled radiances together. See how differences compare to aeronet reported errors.
% Modeled PPL by design also returns zenith radiance.  

% Having troubles getting units to match up cleanly.
% Will try modifying the funtion to use PPL instead of ALM, interpolating the
% Relevant fields as needed.  This should provide:
% 1. Cimel/Aeronet zenith radiance
% 2. SBDART 
% 3. SASZe
% 4. TWST 

% C1 = anc_bundle_files(getfullname('sgpmfr*.*','mfrC1'));
% E13 = anc_bundle_files(getfullname('sgpmfr*.*','mfrE13')); % Load both to check quality of DDR
% [cine, enic] = nearest(C1.time, E13.time);
% C1 = anc_sift(C1, cine); E13 = anc_sift(E13, enic);
% am_good = C1.vdata.airmass >=1 & C1.vdata.airmass<=6 & C1.vdata.direct_diffuse_ratio_filter1>0 & E13.vdata.direct_diffuse_ratio_filter1;
% C1 = anc_sift(C1, am_good); E13 = anc_sift(E13, am_good);

csphot_zrad = anc_bundle_files(getfullname('*csp*.*','csphot'));
cim_all = rd_anetaip_v3;
cim_440_ij = find(cim_all.Single_Scattering_Albedo_440nm_>0);
% aip_alm = anet_alm_SA_and_radiance;
% alm_440_ij = find(aip_alm.Nominal_Wavelength_nm_==440 & aip_alm.time>cim_all.time(1) & aip_alm.time<cim_all.time(end));
aip_ppl = anet_ppl_SA_and_radiance; 
ppl_440_ij = find(aip_ppl.Nominal_Wavelength_nm_==440 & aip_ppl.time>C1.time(1) & aip_ppl.time<C1.time(end));

figure_(9); plot(C1.time, C1.vdata.direct_diffuse_ratio_filter1,'o', ...
   E13.time, E13.vdata.direct_diffuse_ratio_filter1,'x',...
  cim_all.time, cim_all.Single_Scattering_Albedo_440nm_,'c*' ); 
legend('D2D C1','D2D E13','SSA');dynamicDateTicks;
yl = ylim; yl(1) = 0; yl(2) = 1.1;
ylim(yl);
liny
% twst = rd_twst_nc4;

nfov  = anc_bundle_files(getfullname('*nfov*','nfov'));
sasze = anc_bundle_files(getfullname('*saszefilter*.*','sasaze_filt'));
sasze = anc_sift(sasze, sasze.vdata.zenith_radiance_415nm>0);
figure_(4); plot(sasze.time, sasze.vdata.zenith_radiance_440nm, 'rx'); dynamicDateTicks; 
xlabel('time'); ylabel(sasze.vatts.zenith_radiance_440nm.units,'interp','tex')

% Medium picture, apply homogeniety sceen to sasze filterbands to identify times
% (Doesn't work well.  Diffuse is too noisy, especially during clear sky
% when zenith radiance is unperturbed for 15 mins?  30 mins?  Use these times to
% pre-filter aip retrieval times and sky scans.
% Develop a time-series of ratios between sasze and sbdart zrad


% Bigger picture:
% Using surface albedo from aeronet files, populate albedo.dat file for SBDART.
% Using CAD or BE-AOD, run SBDART iteratively with SSA to converge on MFRSR DDR value
% Do this for 415 nm and 440 nm?  

qry.WLINF =  0.440;  
qry.WLSUP =  0.010;  
% qry.WLINC =  0.001;
qry.ISAT = -2;
qry.iaer=5;
qry.wlbaer = [0.44, 0.675, 0.87, 1.02];

for ij = 1:length(ppl_440_ij)
   % ij = ij+1
   figure_(12); close(12); figure_(44); close(44);
   qry.qbaer(4) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_1020nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.qbaer(3) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_870nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.qbaer(2) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_675nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.qbaer(1) = interp1(cim_all.time, cim_all.AOD_Coincident_Input_440nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');   

   qry.wbaer(4) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_1020nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.wbaer(3) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_870nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.wbaer(2) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_675nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.wbaer(1) = interp1(cim_all.time, cim_all.Single_Scattering_Albedo_440nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');   

   qry.gbaer(4) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_1020nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.gbaer(3) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_870nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.gbaer(2) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_675nm_, aip_ppl.time(ppl_440_ij(ij)),'linear');
   qry.gbaer(1) = interp1(cim_all.time, cim_all.Asymmetry_Factor_Total_440nm_ , aip_ppl.time(ppl_440_ij(ij)),'linear');   
   qry.SZA=aip_ppl.Solar_Zenith_Angle_Degrees_(ppl_440_ij(ij)); 
   figure_(44);
   plot(aip_ppl.SA,aip_ppl.radiance(ppl_440_ij(ij),:),'-');logy
   title({['SGP CF Aeronet PPL 440 nm'];[datestr(aip_ppl.time(ppl_440_ij(ij)),'yyyy-mm-dd HH:MM:SS')]});
   xlabel('Scattering Angle [deg]'); ylabel(['Radiance [uW/(cm^2/nm/sr)]'],'interp','tex')
   figure_(45);
   plot(aip_ppl.Solar_Zenith_Angle_Degrees_(ppl_440_ij(ij))-aip_ppl.dZa,aip_ppl.radiance(ppl_440_ij(ij),:),'-');logy
   title({['SGP CF Aeronet PPL 440 nm'];[datestr(aip_ppl.time(ppl_440_ij(ij)),'yyyy-mm-dd HH:MM:SS')]});
   xlabel('Zenith Angle [deg]'); ylabel(['Radiance [uW/(cm^2/nm/sr)]'],'interp','tex')
   % alm  = run_sbdart_alm(qry);
   ppl  = run_sbdart_ppl(qry);
   
   
   sas_xl = sasze.time>(aip_ppl.time(ppl_440_ij(ij))-.25./24)&sasze.time<(aip_ppl.time(ppl_440_ij(ij))+.25./24);
   sasze_zrad = mean(sasze.vdata.zenith_radiance_440nm(sas_xl & sasze.vdata.zenith_radiance_440nm>0));
   figure_(4); xlim([aip_ppl.time(ppl_440_ij(ij))-.5./24,aip_ppl.time(ppl_440_ij(ij))+.5./24] );
   hold('on'); plot( mean(sasze.time(sas_xl & sasze.vdata.zenith_radiance_440nm>0)), sasze_zrad,'k*'); hold('off');
   Krad = 1000.*ppl.zrad ./ (sasze_zrad); %factor of 10 is just for units

   twst_440 = interp1(twst.wl_A, [1:length(twst.wl_A)],440,'nearest');
   twst_time = interp1(twst.time, [1:length(twst.time)], aip_ppl.time(ppl_440_ij(ij)),'nearest', 'extrap');
   figure_(5); plot(twst.time, twst.zenrad_A(twst_440,:),'k.',twst.time(twst_time), twst.zenrad_A(twst_440,twst_time),'ro' ); dynamicDateTicks;
   ylabel('W/m2/nm/sr')

   menu('Hit ok to continue','OK')
end


