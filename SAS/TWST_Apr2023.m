% SGP SASZe & TWST clash on 2023-04-15
% Based on comment from Steve Jones, the Ze shows poor agreement with TWST and CSPHOT
% I have looked carefully at Ze netccdf files and do not see any error (wrong cal file,
% incorrect processing) to account for the difference.  

% load nir, nirb, and nir_a1
% C:\Users\Connor Flynn\OneDrive - University of Oklahoma\Desktop\xdata\ARM\adc\mentor\sgpsasze
 clear

nir = anc_load;
nirb = anc_load;
nir_a1 = anc_load;

dark_ = nir.vdata.shutter_state==0;
nir_dark = interp1(nir.time(dark_), nir.vdata.spectra(:,dark_)', nir.time,'nearest','extrap')';
nir_sig = nir.vdata.spectra - nir_dark;
nir_rate = nir_sig./unique(nir.vdata.integration_time);

dark_ = nirb.vdata.shutter_state==0;
nirb_dark = interp1(nirb.time(dark_), nirb.vdata.spectra(:,dark_)', nirb.time,'nearest','extrap')';
nirb_sig = nirb.vdata.spectra - nirb_dark;
nirb_rate = nirb_sig./unique(nirb.vdata.integration_time);

figure; plot(nir.vdata.wavelength, nir_sig(:,10000), '-',nirb.vdata.wavelength, nirb_sig(:,10000), '-')

figure; plot(nir.vdata.wavelength, nir_rate(:,10000), '-',nirb.vdata.wavelength, nirb_rate(:,10000), '-')

resp = nir_a1.vdata.responsivity;
resp(resp<=0) = NaN;

figure; plot(nir.vdata.wavelength, nir_rate(:,10000)./resp, '-',nirb.vdata.wavelength, nirb_rate(:,10000)./resp, '-')
a1_t = interp1(nir_a1.time, [1:length(nir_a1.time)],nir.time(10000),'nearest');

figure; plot(nir_a1.vdata.wavelength, nir_a1.vdata.zenith_radiance(:,a1_t).*resp./resp,'k-')

cimzen = anc_load;
figure; plot(cimzen.time, cimzen.vdata.zenith_sky_radiance_A,'o'); dynamicDateTicks
cimzen.vdata.nominal_wavelength

nir_cim_i = interp1(nir_a1.vdata.wavelength, [1:length(nir_a1.vdata.wavelength)],double(cimzen.vdata.nominal_wavelength(1:2)),'nearest','extrap')

figure; plot(cimzen.time, cimzen.vdata.zenith_sky_radiance_A(1:2,:),'o',nir_a1.time, nir_a1.vdata.zenith_radiance(nir_cim_i,:)./10,'x'); dynamicDateTicks

cims = anc_bundle_files;
sasfilt = anc_bundle_files;
[cins, sinc] = nearest(cims.time, sasfilt.time);
cims = anc_sift(cims, cins); sasfilt = anc_sift(sasfilt, sinc);

figure; plot(cims.time, cims.vdata.zenith_sky_radiance_A(2,:),'o',sasfilt.time, sasfilt.vdata.zenith_radiance_1020nm./10,'x'); logy; dynamicDateTicks


% Let's look at VIS, and at least see how well the spectra line up
vis = anc_load;
visb = anc_load;
vis_a1 = anc_load;

dark_ = vis.vdata.shutter_state==0;
vis_dark = interp1(vis.time(dark_), vis.vdata.spectra(:,dark_)', vis.time,'nearest','extrap')';
vis_sig = vis.vdata.spectra - vis_dark;
vis_rate = vis_sig./unique(vis.vdata.integration_time);

dark_ = visb.vdata.shutter_state==0;
visb_dark = interp1(visb.time(dark_), visb.vdata.spectra(:,dark_)', visb.time,'nearest','extrap')';
visb_sig = visb.vdata.spectra - visb_dark;
visb_rate = visb_sig./unique(visb.vdata.integration_time);

figure; plot(vis.vdata.wavelength, vis_sig(:,10000), '-',visb.vdata.wavelength, visb_sig(:,10000), '-')

figure; plot(vis.vdata.wavelength, vis_rate(:,10000), '-',visb.vdata.wavelength, visb_rate(:,10000), '-')

resp = vis_a1.vdata.responsivity;
resp(resp<=0) = NaN;

figure; plot(vis.vdata.wavelength, vis_rate(:,10000)./resp, '-',visb.vdata.wavelength, visb_rate(:,10000)./resp, '-')
a1_t = interp1(vis_a1.time, [1:length(vis_a1.time)],vis.time(10000),'nearest');

figure; plot(vis_a1.vdata.wavelength, vis_a1.vdata.zenith_radiance(:,a1_t).*resp./resp,'c-')

