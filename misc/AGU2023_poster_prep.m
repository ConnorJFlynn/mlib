% AGU 2023 poster preps
plots_ppt

% Need matched time series of AOD BE and MFRSR b1 or AOD for DDR.
% Find compute drad
prep_dir = ['D:\AGU_prep\'];
all_legs = load([prep_dir,'all_legs2.mat']);
tws = load('D:\AGU_prep\tws_uv.mat'); % TWST Ze Radiance 415, 440
Ze = load('D:\AGU_prep\Ze_filtered.mat');

zenrad_LUT = load([prep_dir, 'sbdart_zenrad_p01.mat']);
zenrad_LUT.sel = 90- zenrad_LUT.sza;
zenrad_LUT.drad_pct = 100.*diff2(zenrad_LUT.rad_by_SZA)./zenrad_LUT.rad_by_SZA;
% zenrad_LUT.drad_pct2 = 100.*diff2(zenrad_LUT.rad_by_SZA')'./zenrad_LUT.rad_by_SZA;

drad_pct = 100.* (zenrad_LUT.rad_by_SZA(1:end-1,:)-zenrad_LUT.rad_by_SZA(2:end,:))./zenrad_LUT.rad_by_SZA(2:end,:);

mfr_b4 = load([prep_dir,'mfr_b4.mat']);
qc_aod = anc_qc_impacts(mfr_b4.vdata.qc_aerosol_optical_depth_filter1, mfr_b4.vatts.qc_aerosol_optical_depth_filter1);
qc_ddr = anc_qc_impacts(mfr_b4.vdata.qc_direct_diffuse_ratio_filter1, mfr_b4.vatts.qc_direct_diffuse_ratio_filter1);
mfr_b4 = anc_sift(mfr_b4, qc_aod==0&qc_ddr==0);

mfr_ftr = load([prep_dir,'mfr_ftr.mat']);
qc_aod = anc_qc_impacts(mfr_ftr.vdata.qc_aerosol_optical_depth_filter1, mfr_ftr.vatts.qc_aerosol_optical_depth_filter1);
qc_ddr = anc_qc_impacts(mfr_ftr.vdata.qc_direct_diffuse_ratio_filter1, mfr_ftr.vatts.qc_direct_diffuse_ratio_filter1);
mfr_ftr = anc_sift(mfr_ftr, qc_aod==0&qc_ddr==0);

mfr.time = [mfr_b4.time, mfr_ftr.time];
mfr.aod_415 = [mfr_b4.vdata.aerosol_optical_depth_filter1, mfr_ftr.vdata.aerosol_optical_depth_filter1];
mfr.ddr_415 = [mfr_b4.vdata.direct_diffuse_ratio_filter1, mfr_ftr.vdata.direct_diffuse_ratio_filter1];
mfr.airmass = [mfr_b4.vdata.airmass, mfr_ftr.vdata.airmass];
mfr.sza = [mfr_b4.vdata.solar_zenith_angle, mfr_ftr.vdata.solar_zenith_angle];
mfr.sel = 90-mfr.sza;
mfr.sel_i = interp1((zenrad_LUT.sel), [1:length(zenrad_LUT.sel)], mfr.sel,'nearest','extrap');
mfr.aod_j = interp1(zenrad_LUT.aod, [1:length(zenrad_LUT.aod)], mfr.aod_415,'nearest','extrap');

for t = length(mfr.time):-1:1
   mfr.drad(t) = zenrad_LUT.drad_pct(mfr.aod_j(t),mfr.sel_i(t));
end
figure; scatter(mfr.sel, mfr.aod_415,12, abs(mfr.drad),'filled'); caxis([0,4]);  
cb = colorbar; set(get(cb,'title'),'string','%d(zrad)');
xlabel('Solar Elevation [degrees]');
ylabel('AOD [415 nm]')
title('% Variation in zenith radiance with 0.01 OD')

figure; scatter(mfr.time, mfr.aod_415,12, abs(mfr.drad),'filled'); caxis([0,4]);  
cb = colorbar; set(get(cb,'title'),'string','%d(zrad)');
xlabel('time'); dynamicDateTicks
ylabel('AOD [415 nm]')
title('% Variation in zenith radiance with 0.01 OD')

ltp5 = find(abs(mfr.drad)<1);
[ainm, mina] = nearest(all_legs.time_UT, mfr.time(ltp5));

for m = length(ainm):-1:1
   try
   [ssa(m), zrad(m)] = ret_ssa_sbdart(413.2, all_legs.aod_fit(ainm(m),7), mfr.sza(ltp5(mina(m))), mfr.ddr_415(ltp5(mina(m))));
   catch
      disp(['bad']);
      ssa(m) = NaN; zrad(m) = NaN;
   end
   [m, all_legs.aod_fit(ainm(m),7),mfr.sza(ltp5(mina(m))), mfr.ddr_415(ltp5(mina(m))), ssa(m), zrad(m)]
end
bads = isnan(ssa)|isnan(zrad);
ainm(bads) = []; mina(bads) = []; ssa(bads) = []; zrad(bads) = [];
length(unique(floor(mfr.time(ltp5(mina)))))
figure; plot(all_legs.time_LST(ainm), zrad,'o'); dynamicDateTicks

rads.time_LST = all_legs.time_LST(ainm);
rads.time_UT = all_legs.time_UT(ainm);
rads.zrad = zrad';

[rint, tinr] = nearest(rads.time_UT, tws.time);
figure; plot(rads.time_LST(rint), rads.zrad(rint), 'o', rads.time_LST(rint), 1e3.*tws.zrad(1,tinr),'x')
figure; plot(rads.zrad(rint), 1e3.*tws.zrad(1,tinr),'x'); axis('square'); xlim(ylim); ylim(xlim)

figure; scatter(rads.zrad(rint), 1e3.*tws.zrad(1,tinr),32,rads.time_LST(rint)-min(rads.time_LST(rint)),'filled'); 
axis('square'); xlim(ylim); ylim(xlim)

[rinz, zinr] = nearest(rads.time_UT, Ze.time);
figure; plot(rads.time_LST(rinz), rads.zrad(rinz), 'o', rads.time_LST(rinz), Ze.vdata.zenith_radiance_415nm(zinr),'x'); logy
figure; plot(rads.zrad(rint), 1e3.*tws.zrad(1,tinr),'x'); 
figure; scatter(rads.zrad(rinz), Ze.vdata.zenith_radiance_415nm(zinr),32,rads.time_LST(rinz)-min(rads.time_LST(rinz)),'filled'); 
axis('square'); xlim(ylim); ylim(xlim)

twst = rd_twst_nc4

