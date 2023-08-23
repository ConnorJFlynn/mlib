%This code reads N twst netcdf files for a single day and prompts for 
% corresponding sasze vis and nir files.
% Besides a roughly factor of 2 difference in calibration, the two
% instrument have very comparable spectral shape for both VIS and NIR.

twst = rd_twst_nc4; % TWST-EN0011_20230415 for clear sky
zenir = anc_bundle_files(getfullname('sgpsaszenir*.nc','zenir'));
zevis = anc_bundle_files(getfullname('sgpsaszevis*.nc','zevis'));
[ninv, vinn] = nearest(zenir.time, zevis.time);
if length(ninv)<length(zenir.time)||length(vinn)<length(zevis.time)
   zenir = anc_sift(zenir, ninv);
   zevis = anc_sift(zevis, vinn);
end
[tinz, zint] = nearest(twst.time, zenir.time);
zenir = anc_sift(zenir, zint); zevis = anc_sift(zevis,zint);
twst.time = twst.time(tinz); twst.zenrad_B = twst.zenrad_B(:,tinz); twst.zenrad_A = twst.zenrad_A(:,tinz);
twst = rmfield(twst,'epoch');

z_500 = interp1(zevis.vdata.wavelength, [1:length(zevis.vdata.wavelength)],500,'nearest');
t_500 = interp1(twst.wl_A, [1:length(twst.wl_A)],500,'nearest');

z_870 = interp1(zevis.vdata.wavelength, [1:length(zevis.vdata.wavelength)],870,'nearest');
t_870 = interp1(twst.wl_A, [1:length(twst.wl_A)],870,'nearest');
figure; plot([1:length(twst.time)], 450.*twst.zenrad_A(t_870,:),'-',[1:length(zevis.time)], zevis.vdata.zenith_radiance(z_870,:),'-');

figure; plot([1:length(twst.time)], 450.*twst.zenrad_A(t_500,:),'-',[1:length(zevis.time)], zevis.vdata.zenith_radiance(z_500,:),'-');
figure; plot(twst.time, 450.*twst.zenrad_A(t_500,:),'-',zevis.time, zevis.vdata.zenith_radiance(z_500,:),'-');dynamicDateTicks


% figure; plot(zevis.vdata.wavelength-3.5, 2.*zevis.vdata.zenith_radiance(:,10600),'r-',twst.wl_A, 1e3.*twst.zenrad_A(:,10600), 'b-',...
% zenir.vdata.wavelength, 2.*zenir.vdata.zenith_radiance(:,10600),'r-',twst.wl_B, 1e3.*twst.zenrad_B(:,10600), 'b-'); logy
% legend('SASZe (x2)','TWST'); 
% title({['SASZe and TWST Zenith Radiance'];['SGP ', datestr(twst.time(10600),'yyyy-mm-dd HH:MM:SS UT')]})
% xlabel('wavelength [nm]'); ylabel('Radiance [W/m2/nm/sr]')

% from PPL struct: aip.sky_rad_units = 'W/(m^2 um sr)';
% clean up the WL limits for both systems, spectrometers.
wl_A = twst.wl_A>385 & twst.wl_A<980; vis_wl = zevis.vdata.wavelength>385 & zevis.vdata.wavelength<980;

figure; plot(twst.wl_A(wl_A), 1e3.*twst.zenrad_A(wl_A,10600), 'b-',zevis.vdata.wavelength(vis_wl)-3.5, 1.15.*2.*zevis.vdata.zenith_radiance(vis_wl,10600),'r-',...
twst.wl_B, 1e3.*twst.zenrad_B(:,10600), 'b-',zenir.vdata.wavelength, 1.15.*2.*zenir.vdata.zenith_radiance(:,10600),'r-'); logy
legend('TWST','f*SASZe'); 
title({['SASZe and TWST Zenith Radiance'];['SGP ', datestr(twst.time(10600),'yyyy-mm-dd HH:MM:SS UT')]})
xlabel('wavelength [nm]'); ylabel('Radiance [W/m2/nm/sr]')

figure; plot(zenir.time, zenir.vdata.solar_zenith,'o'); logy
% anet = rd_anetaip_v3;
% figure; plot(anet.time, anet.Coincident_AOD440nm,'o');
% figure; plot(anet.time, anet.Single_Scattering_Albedo_440nm_,'o');
% figure; plot(anet.time, anet.Average_Solar_Zenith_Angles_for_Flux_Calculation_Degrees_,'o');

ppl = rd_anetaip_v3;
zen = load(['C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Lit\MyPresents\ARM\STM\ARM_STM_2023\sbdart_zenrad.mat']);


ti_1946 = interp1(twst.time, [1:length(twst.time)],datenum(2023,4,15,19,46,2),'nearest')
if ~isnan(ti_1946)
   figure; plot(twst.wl_A, 450.*twst.zenrad_A(:,ti_1946), 'b-', zevis.vdata.wavelength-3.5, zevis.vdata.zenith_radiance(:,ti_1946),'r-',...
      twst.wl_B, 450.*twst.zenrad_B(:,ti_1946), 'b-', zenir.vdata.wavelength, zenir.vdata.zenith_radiance(:,ti_1946),'r-'); logy

   tl = xlim;
   tl_ = twst.time>tl(1)&twst.time<tl(2);
   figure; plot(twst.wl_A(wl_A), 1e3.*mean(twst.zenrad_A(wl_A,tl_),2), 'b-',zevis.vdata.wavelength(vis_wl)-3.5, 1.15.*2.*mean(zevis.vdata.zenith_radiance(vis_wl,tl_),2),'r-',...
      twst.wl_B, 1e3.*mean(twst.zenrad_B(:,tl_),2), 'b-',zenir.vdata.wavelength, 1.15.*2.*mean(zenir.vdata.zenith_radiance(:,tl_),2),'r-'); logy
   legend('TWST','f*SASZe');
   title({['SASZe and TWST Zenith Radiance'];['SGP ', datestr(mean(twst.time(tl_)),'yyyy-mm-dd HH:MM:SS UT')]})
   xlabel('wavelength [nm]'); ylabel('Radiance [W/m2/nm/sr]')

end
