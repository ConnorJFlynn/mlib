% ARM Spectral Radiation measurements strategy review

anet_M1 = read_cimel_aod_v3;
mfr_M1 = anc_bundle_files;
mfr_S1 = anc_bundle_files;

good_M1 = anc_qc_impacts(mfr_M1.vdata.qc_aerosol_optical_depth_filter2,mfr_M1.vatts.qc_aerosol_optical_depth_filter1)~=2 & ...
   anc_qc_impacts(mfr_M1.vdata.qc_aerosol_optical_depth_filter4,mfr_M1.vatts.qc_aerosol_optical_depth_filter4)~=2 & ...
   anc_qc_impacts(mfr_M1.vdata.qc_aerosol_optical_depth_filter5,mfr_M1.vatts.qc_aerosol_optical_depth_filter5)~=2;


good_S1 = anc_qc_impacts(mfr_S1.vdata.qc_aerosol_optical_depth_filter2,mfr_S1.vatts.qc_aerosol_optical_depth_filter1)~=2 & ...
   anc_qc_impacts(mfr_S1.vdata.qc_aerosol_optical_depth_filter4,mfr_S1.vatts.qc_aerosol_optical_depth_filter4)~=2 & ...
   anc_qc_impacts(mfr_S1.vdata.qc_aerosol_optical_depth_filter5,mfr_S1.vatts.qc_aerosol_optical_depth_filter5)~=2;

anet_B1 = read_cimel_aod_v3;

figure; plot(anet_M1.time, anet_M1.AOD_500nm,'gx',...
   mfr_M1.time(good_M1), mfr_M1.vdata.aerosol_optical_depth_filter2(good_M1),'g+',...
   mfr_S1.time(good_S1), mfr_S1.vdata.aerosol_optical_depth_filter2(good_S1),'go',...
   anet_M1.time,anet_M1.AOD_675nm,'rx',...
   mfr_M1.time(good_M1), mfr_M1.vdata.aerosol_optical_depth_filter4(good_M1),'r+',...
   mfr_S1.time(good_S1), mfr_S1.vdata.aerosol_optical_depth_filter4(good_S1),'ro',...
   anet_M1.time,anet_M1.AOD_870nm,'cx',...
   mfr_M1.time(good_M1), mfr_M1.vdata.aerosol_optical_depth_filter5(good_M1),'c+',...
   mfr_S1.time(good_S1), mfr_S1.vdata.aerosol_optical_depth_filter5(good_S1),'co');
dynamicDateTicks; legend('500','675','870'); title('ANET HighLands')


figure; plot(anet_B1.time, [anet_B1.AOD_440nm, anet_B1.AOD_500nm,anet_B1.AOD_675nm,anet_B1.AOD_870nm,anet_B1.AOD_1020nm],'x'); 
dynamicDateTicks; legend('440','500','675','870','1020'); title('ANET Barnstable')




figure; plot(he_aod.time, he_aod.vdata.airmass,'kx'); xlim(xl);

Io_str = he_aod.vatts.Io_time.units(findstr(he_aod.vatts.Io_time.units,'20'):end);
Io_time = datenum(Io_str, 'yyyy-mm-dd HH:MM:SS') + he_aod.vdata.Io_time./(24*60*60);
figure;plot(Io_time, he_aod.vdata.Io_values(wl_i,:),'-o'); dynamicDateTicks
xl = xlim;
he_aod = anc_load(getfullname('pvcsashevisaod*.c1.*.cdf; pvcsashevisaod*.c1.*.nc','sashe_aod'));
he_good = he_aod.vdata.normalized_atmospheric_variability<1e-4 & he_aod.vdata.airmass<5;
wl = [415, 500, 615, 676, 870]; wl_i = interp1(he_aod.vdata.wavelength, [1:length(he_aod.vdata.wavelength)],wl,'nearest')
qc_me = anc_qc_impacts(he_aod.vdata.qc_aerosol_optical_depth, he_aod.vatts.qc_aerosol_optical_depth);
nanbad = zeros(size(he_aod.vdata.qc_aerosol_optical_depth));
nanbad(qc_me==1) = NaN;
nanbad = nanbad(wl_i,he_good);
figure; plot(he_aod.time(he_good), nanbad+he_aod.vdata.aerosol_optical_depth(wl_i,he_good),'.'); 
legend('415','500','615','676','870'); 
dynamicDateTicks; xlim(xl); ylim([0,.2]);

mfr_aod = ARM_display_beta;