% Read SAS_filterbands file
ze = ARM_display_beta; ze = anc_bundle_files;
ze = anc_sift(ze, ze.vdata.zenith_radiance_500nm>0);
% Read anet cloudmode file
cim_cld = read_cimel_cloudrad;
% Read anet PPL file
cim_zenrad = aeronet_zenith_radiance;

figure; plot(ze.time, ze.vdata.zenith_radiance_500nm, 'b-', ...
   cim_cld.time, cim_cld.A500nm,'gx',cim_cld.time, cim_cld.K500nm,'go',...
   cim_zenrad.time, [cim_zenrad.zen_rad_500_nm],'c*'); dynamicDateTicks;
legend('SASZe 500 nm','A500 nm', 'K500 nm', 'PPL Zen 500nm'); xlabel('time'); 
ylabel('mW/m^2/nm/sr')

nfov = anc_bundle_files;
figure; plot(nfov.time, 1000.*nfov.vdata.radiance_673nm, '.', ze.time, ze.vdata.zenith_radiance_673nm,'o'); 
dynamicDateTicks; xlabel('time');
legend('nfov 673 nm','sasze 673 nm');
% nfov.vatts.radiance_673nm.units 'W/m^2/nm/sr'

