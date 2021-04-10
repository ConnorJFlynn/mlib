function sws_b1_test
%sws_b1_test: use this function to test SWS b-level ingested data during
%development of this datastream.  Reproduce data from raw and/or a0 a1
%levels
sws_vis_b1 = anc_load(getfullname('*swsvis*.b1*.nc','sws_b1'));
sws_nir_b1 = anc_load(getfullname('*swsnir*.b1*.nc','sws_b1'));
sws_vis_a0 = anc_load(getfullname('*swsvis*.a0*.nc','sws_a0'));
sws_nir_a0 = anc_load(getfullname('*swsnir*.a0*.nc','sws_a0'));
sws_vis = proc_sws_a0(sws_vis_a0);
sws_nir = proc_sws_a0(sws_nir_a0);
wl = interp1(sws_vis_a0.vdata.wavelength,[1:length(sws_vis_a0.vdata.wavelength)],500,'nearest')
figure; plot(sws_vis_b1.vdata.wavelength, sws_vis_b1.vdata.zenith_radiance(:,(500:10:600)),'-')
figure; plot(sws_nir_b1.vdata.wavelength, sws_nir_b1.vdata.zenith_radiance(:,(500:10:600)),'-')
[min(sws_vis_a0.vdata.wavelength), max(sws_vis_a0.vdata.wavelength)]-[min(sws_vis_b1.vdata.wavelength), max(sws_vis_b1.vdata.wavelength)]


[min(sws_nir_b1.vdata.wavelength), max(sws_nir_b1.vdata.wavelength)]-[min(sws_nir_a0.vdata.wavelength), max(sws_nir_a0.vdata.wavelength)]
% figure; plot(sws_vis_a0.time, sws_vis_a0.vdata.shutter_state, '-o',sws_nir_a0.time, sws_nir_a0.vdata.shutter_state, 'r.')
% figure; plot(sws_vis_a0.time, sws_vis_a0.vdata.shutter_state-sws_nir_a0.vdata.shutter_state, 'rx-')
% figure; plot(sws_vis_b1.time, sws_vis_b1.vdata.shutter_state, '-o',sws_nir_b1.time, sws_nir_b1.vdata.shutter_state, 'r.')
% figure; plot(sws_vis_b1.time, sws_vis_b1.vdata.shutter_state- sws_nir_b1.vdata.shutter_state, 'rx-')
figure; plot(sws_vis_a0.time, sws_vis_a0.vdata.shutter_state, 'o',sws_vis_b1.time, sws_vis_b1.vdata.shutter_state, 'rx-')
dynamicDateTicks;
legend('a0','b1')
title('shutter state in sws files')
xlabel('time');
a0_dark = find(sws_vis_a0.vdata.shutter_state==0)
a0_dark(1:20)
[ainb, bina] = nearest(sws_vis_a0.time, sws_vis_b1.time);
figure; plot(sws_vis_b1.vdata.wavelength, sws_vis_b1.vdata.zenith_radiance(:,bina(500:10:600)),'-')
figure; plot(sws_nir_b1.vdata.wavelength, sws_nir_b1.vdata.zenith_radiance(:,bina(500:10:600)),'-')

figure; plot(sws_vis.vdata.wavelength, sws_vis.vdata.zen_rad(:,ainb(500:10:600)),'-'); title('ainb')
figure; plot(sws_nir.vdata.wavelength, sws_nir.vdata.zen_rad(:,ainb(500:10:600)),'-'); title('ainb')

bina(1:50)
bina(1:100)
bina(1:200)
size(sws_vis_a0.time)
size(sws_vis_b1.time)
whos
[ainb, bina] = nearest(sws_vis_a0.time, sws_vis_b1.time);[ainb', bina']
%-- 1/18/2019 5:41 PM --%
return