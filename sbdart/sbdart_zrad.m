function sbdart_zrad
% Based on sbdart_zrad_ppl
% Goal is to validate modeled radiances, esp understanding the difference between
% iout=6, iout=21, and the associated filter functions.
% To model the zen radiance accurately we need AOD, SZA, SSA, SFA
% We restrict to the UV for our retrieval to avoid SFA dependence.

% Having troubles getting units to match up cleanly.
% Will try comparing iout = 6 and iout = 21.  Seems like 6 should be correct

% C1 = anc_bundle_files(getfullname('sgpmfr*.*','mfrC1'));
% E13 = anc_bundle_files(getfullname('sgpmfr*.*','mfrE13')); % Load both to check quality of DDR
% [cine, enic] = nearest(C1.time, E13.time);
% C1 = anc_sift(C1, cine); E13 = anc_sift(E13, enic);
% am_good = C1.vdata.airmass >=1 & C1.vdata.airmass<=6 & C1.vdata.direct_diffuse_ratio_filter1>0 & E13.vdata.direct_diffuse_ratio_filter1;
% C1 = anc_sift(C1, am_good); E13 = anc_sift(E13, am_good);

% csphot_zrad = anc_bundle_files(getfullname('*csp*.*','csphot'));
aip_all = rd_anetaip_v3;
aip_440_ij = find(aip_all.Single_Scattering_Albedo_440nm_>0& aip_all.time>datenum('2023-05-05'));
% aip_alm = anet_alm_SA_and_radiance;
% alm_440_ij = find(aip_alm.Nominal_Wavelength_nm_==440 & aip_alm.time>aip_all.time(1) & aip_alm.time<aip_all.time(end));
ppl = anet_ppl_SA_and_radiance; 
ppl_440_ij = find(ppl.Nominal_Wavelength_nm_==440&ppl.time>datenum('2023-05-05'));

[ainp, pina] = nearest(aip_all.time(aip_440_ij), ppl.time(ppl_440_ij));

qry.WLINF =  0.440;  
qry.WLSUP =  0.010;  
% qry.WLINC =  0.001;
qry.ISAT = -2; qry.ISAT = 14;% mfrsr 410nm
qry.iaer=5;
qry.wlbaer = [0.44, 0.675, 0.87, 1.02];
qry.iout = 6;


for ij = 1:length(pina)
   % ij = ij+1
   figure_(12); close(12); figure_(44); close(44);
   qry.qbaer(4) = interp1(aip_all.time, aip_all.AOD_Coincident_Input_1020nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.qbaer(3) = interp1(aip_all.time, aip_all.AOD_Coincident_Input_870nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.qbaer(2) = interp1(aip_all.time, aip_all.AOD_Coincident_Input_675nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.qbaer(1) = interp1(aip_all.time, aip_all.AOD_Coincident_Input_440nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');   

   qry.wbaer(4) = interp1(aip_all.time, aip_all.Single_Scattering_Albedo_1020nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.wbaer(3) = interp1(aip_all.time, aip_all.Single_Scattering_Albedo_870nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.wbaer(2) = interp1(aip_all.time, aip_all.Single_Scattering_Albedo_675nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.wbaer(1) = interp1(aip_all.time, aip_all.Single_Scattering_Albedo_440nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');   

   qry.gbaer(4) = interp1(aip_all.time, aip_all.Asymmetry_Factor_Total_1020nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.gbaer(3) = interp1(aip_all.time, aip_all.Asymmetry_Factor_Total_870nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.gbaer(2) = interp1(aip_all.time, aip_all.Asymmetry_Factor_Total_675nm_, ppl.time(ppl_440_ij(pina(ij))),'linear');
   qry.gbaer(1) = interp1(aip_all.time, aip_all.Asymmetry_Factor_Total_440nm_ , ppl.time(ppl_440_ij(pina(ij))),'linear');   
   qry.SZA=ppl.Solar_Zenith_Angle_Degrees_(ppl_440_ij(pina(ij))); 
   figure_(44);
   plot(ppl.SA,ppl.radiance(ppl_440_ij(pina(ij)),:),'-');logy
   title({['SGP CF Aeronet PPL 440 nm'];[datestr(ppl.time(ppl_440_ij(pina(ij))),'yyyy-mm-dd HH:MM:SS')]});
   xlabel('Scattering Angle [deg]'); ylabel(['Radiance [uW/(cm^2/nm/sr)]'],'interp','tex')
   figure_(45);
   plot(ppl.Solar_Zenith_Angle_Degrees_(ppl_440_ij(pina(ij)))-ppl.dZa,ppl.radiance(ppl_440_ij(pina(ij)),:),'-');logy
   title({['SGP CF Aeronet PPL 440 nm'];[datestr(ppl.time(ppl_440_ij(pina(ij))),'yyyy-mm-dd HH:MM:SS')]});
   xlabel('Zenith Angle [deg]'); ylabel(['Radiance [uW/(cm^2/nm/sr)]'],'interp','tex')
   % alm  = run_sbdart_alm(qry);
   % qry.iout = 6
   ppl  = run_sbdart_ppl(qry);
   
   
   % sas_xl = sasze.time>(ppl.time(ppl_440_ij(ij))-.25./24)&sasze.time<(ppl.time(ppl_440_ij(ij))+.25./24);
   % sasze_zrad = mean(sasze.vdata.zenith_radiance_440nm(sas_xl & sasze.vdata.zenith_radiance_440nm>0));
   % figure_(4); xlim([ppl.time(ppl_440_ij(ij))-.5./24,ppl.time(ppl_440_ij(ij))+.5./24] );
   % hold('on'); plot( mean(sasze.time(sas_xl & sasze.vdata.zenith_radiance_440nm>0)), sasze_zrad,'k*'); hold('off');
   % Krad = 1000.*ppl.zrad ./ (sasze_zrad); %factor of 10 is just for units
   % 
   % twst_440 = interp1(twst.wl_A, [1:length(twst.wl_A)],440,'nearest');
   % twst_time = interp1(twst.time, [1:length(twst.time)], ppl.time(ppl_440_ij(ij)),'nearest', 'extrap');
   % figure_(5); plot(twst.time, twst.zenrad_A(twst_440,:),'k.',twst.time(twst_time), twst.zenrad_A(twst_440,twst_time),'ro' ); dynamicDateTicks;
   % ylabel('W/m2/nm/sr')

   menu('Hit ok to continue','OK')
end


