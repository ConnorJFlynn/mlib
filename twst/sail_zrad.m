function  sail_zrad % AGU 2023 poster preps
% plots_ppt

% Need matched time series of AOD BE and MFRSR b1 or AOD for DDR.
% Find compute drad
prep_dir = ['E:\Instruments\TWST\TWST-EN0010\sail_twst_zenrad_tests\'];
all_legs = load([prep_dir,'guc_all_legs_July1_end.mat']);
tws = load([prep_dir,'guc_tws_wls.mat']); % TWST Ze Radiance 415, 440

zenrad_LUT = load([prep_dir, 'sbdart_zenrad_p01.mat']);
zenrad_LUT.sel = 90- zenrad_LUT.sza;
zenrad_LUT.drad_pct = 100.*diff2(zenrad_LUT.rad_by_SZA)./zenrad_LUT.rad_by_SZA;
% zenrad_LUT.drad_pct2 = 100.*diff2(zenrad_LUT.rad_by_SZA')'./zenrad_LUT.rad_by_SZA;

drad_pct = 100.* (zenrad_LUT.rad_by_SZA(1:end-1,:)-zenrad_LUT.rad_by_SZA(2:end,:))./zenrad_LUT.rad_by_SZA(2:end,:);

mfr_b4 = load([prep_dir,'gucmfr_July1_end.mat']);
qc_aod = anc_qc_impacts(mfr_b4.vdata.qc_aerosol_optical_depth_filter1, mfr_b4.vatts.qc_aerosol_optical_depth_filter1);
qc_ddr = anc_qc_impacts(mfr_b4.vdata.qc_direct_diffuse_ratio_filter1, mfr_b4.vatts.qc_direct_diffuse_ratio_filter1);
mfr_b4 = anc_sift(mfr_b4, qc_aod==0&qc_ddr==0);

mfr.time = mfr_b4.time;
mfr.aod_415 = mfr_b4.vdata.aerosol_optical_depth_filter1;
mfr.ddr_415 = mfr_b4.vdata.direct_diffuse_ratio_filter1;
mfr.airmass = mfr_b4.vdata.airmass;
mfr.sza = mfr_b4.vdata.solar_zenith_angle;
mfr.sel = 90-mfr.sza;
mfr.sel_i = interp1((zenrad_LUT.sel), [1:length(zenrad_LUT.sel)], mfr.sel,'nearest','extrap');
mfr.aod_j = interp1(zenrad_LUT.aod, [1:length(zenrad_LUT.aod)], mfr.aod_415,'nearest','extrap');

for t = length(mfr.time):-1:1
   mfr.drad(t) = zenrad_LUT.drad_pct(mfr.aod_j(t),mfr.sel_i(t));
end
lt_err = 1.5;
lt = find(abs(mfr.drad)<lt_err);
figure; scatter(mfr.sel(lt), mfr.aod_415(lt),12, abs(mfr.drad(lt)),'filled'); caxis([0,4]);  
cb = colorbar; set(get(cb,'title'),'string','%d(zrad)');
xlabel('Solar Elevation [degrees]');
ylabel('AOD [415 nm]')
title(['Points with less than ',num2str(lt_err),'% Variation'])

figure; scatter(mfr.time(lt), mfr.aod_415(lt),12, abs(mfr.drad(lt)),'filled'); caxis([0,4]);  
cb = colorbar; set(get(cb,'title'),'string','%d(zrad)');
xlabel('time'); dynamicDateTicks
ylabel('AOD [415 nm]')
title('% Variation in zenith radiance with 0.01 OD')


[ainm, mina] = nearest(all_legs.time_UT, mfr.time(lt));

% tws = load('D:\AGU_prep\tws_uv.mat'); % TWST Ze Radiance 415, 440
sb_zrad = getfullname_('*sb_zrad*.mat','sb_zrad');
if ~isempty(sb_zrad)
   sb_zrad_mat = load(sb_zrad);
   if isfield(sb_zrad_mat,'sb_zrad_mat')
      sb_zrad_mat = sb_zrad_mat.sb_zrad_mat;
   end
   zrad = sb_zrad_mat.zrad; ssa = sb_zrad_mat.ssa;
   ainm = sb_zrad_mat.ainm; mina = sb_zrad_mat.mina;
end
if ~isavar('sb_zrad_mat')||~isfield(sb_zrad_mat,'ssa')
   gd = 0;
   for m = length(ainm):-1:1
      try
         [ssa(m), zrad(m)] = ret_ssa_sbdart(all_legs.wl(7), all_legs.aod_fit(ainm(m),7), mfr.sza(lt(mina(m))), mfr.ddr_415(lt(mina(m))),[],[],720);
      catch
         % disp(['bad']);
         ssa(m) = NaN; zrad(m) = NaN;
      end
      gd = gd + double(~isnan(ssa(m))&~isnan(zrad(m))&ssa(m)>0&zrad(m)>0);
      if rem(m,50)==0
         disp(sprintf('%d good=%d aod=%1.2f sza=%2.1f ddr=%1.1f ssa=%1.2f zrad=%2.2f',[m/50, gd, all_legs.aod_fit(ainm(m),7),mfr.sza(lt(mina(m))), mfr.ddr_415(lt(mina(m))), ssa(m), zrad(m)]))
         end
   end
   bads = isnan(ssa)|isnan(zrad)|ssa(m)<=0|zrad(m)<=0;
   ainm(bads) = []; mina(bads) = []; ssa(bads) = []; zrad(bads) = [];
   sb_zrad_mat.time = mfr.time(mina);
   sb_zrad_mat.ainm = ainm; sb_zrad_mat.mina = mina;
   sb_zrad_mat.ssa = ssa; sb_zrad_mat.zrad = zrad;
   uisave('sb_zrad_mat')
end

length(unique(floor(mfr.time(lt(mina)))))

% figure; plot(all_legs.time_LST(ainm), zrad,'o'); dynamicDateTicks
% 
% figure; plot(all_legs.time_LST(ainm), ssa,'o'); dynamicDateTicks

rads.time_LST = all_legs.time_LST(ainm);
rads.time_UT = all_legs.time_UT(ainm);
rads.zrad = zrad';

[rint, tinr] = nearest(rads.time_UT, tws.time);
% figure; plot(rads.time_LST(rint), rads.zrad(rint), 'o', rads.time_LST(rint), 1e3.*tws.zrad(1,tinr),'x')
% figure; plot(rads.zrad(rint), 1e3.*tws.zrad(1,tinr),'x'); axis('square'); xlim(ylim); ylim(xlim)

% time series cals
figure_(18); sb(1) = subplot(3,1,1) ;
scatter(rads.time_LST(rint), 1e3.*(tws.zrad(1,tinr)'./rads.zrad(rint)),16,rads.time_LST(rint)-min(rads.time_LST(rint))); 
dynamicDateTicks; zoom('on')
sb(2) = subplot(3,1,2) ;
scatter(rads.time_LST(rint), 1e3.*(tws.zrad(1,tinr)'),16,rads.time_LST(rint)-min(rads.time_LST(rint))); legend('twst zrad')
dynamicDateTicks; zoom('on')
sb(3) = subplot(3,1,3) ;
scatter(rads.time_LST(rint), rads.zrad(rint),16,rads.time_LST(rint)-min(rads.time_LST(rint))); legend('SB zenrad')
dynamicDateTicks;zoom('on')
linkaxes(sb,'x');
xl = xlim; xl_ = tws.time>xl(1)&tws.time<xl(2);
tws_wls = load([prep_dir,'guc_tws_wls.mat']); tws_wls.wl = [415,440,500,615,673,870];


figure; plot(tws.time((xl_))+ double(mfr_b4.vdata.lon/15)./24, 1e3.*tws.zrad(1,(xl_)),'.'); dynamicDateTicks; legend('TWST 415 nm zen rad')
% xl2 = tws_wls.time>xl(1)&tws_wls.time<xl(2);
sb(2) = gca; 


cim_zrad = anc_bundle_files; unique(cim_zrad.vdata.exact_wavelength)
figure; plot(cim_zrad.time + double(mfr_b4.vdata.lon/15)./24, 10.*cim_zrad.vdata.zenith_sky_radiance_A(6,:),'c.'); dynamicDateTicks
sb(3) = gca; 
linkaxes(sb,'x')

figure; scatter(rads.zrad(rint), 1e3.*tws.zrad(1,tinr),32,rads.time_LST(rint)-min(rads.time_LST(rint)),'filled'); 
axis('square'); xlim(ylim); ylim(xlim)




return