function Irradiance_cals_lamp_and_HISS_to_langley_post_SEAC4RS_20130920
% This is an attempt to use HISS and F-925 to provide a spectrally characterized
% light source to improve our irradiance cals between valid Langley
% wavelengths.  Thus, we observe the sphere with the sun barrel, and then
% divide by the radiance curve provided with ARCHI to get the spectral 
% responsivity from the sphere in arbitrary units. Seperately, we compute
% the responsivity from a Langley Co spectrum by dividing by an ESR
% spectrum.  We then compute the ratio between these two and compute a
% scaling factor from those points that fall within a close range of the
% mean.  Multiplying the Lamp responsivity by this scaling factor puts it
% in the same units as the ESR irradiance spectrum.
% nir = rd_spc_TCAP_v2([pname,'20120920_003_NIR_park.dat']);
% vis = rd_spc_TCAP_v2([pname,'20120920_003_VIS_park.dat']);
% Page 3 of 7 from the lab book, scaling integation time. 

% Seems like what I'll need to do is first screen for dark and light
% Then perhaps compute dark/ms over time.  Interpolate to nearest time,
% compute dark for integration time setting.
%%
% clear
% close('all')


pname = 'D:\case_studies\radiation_cals\2013_11_20.SASZe1_4STAR.NASA_Ames.Flynn\FEL_lamp_F-925\';
% Maybe _003_ all just messing around, bracketing performance for different
% settigs, etc. 
% nir = rd_spc_TCAP_v2([pname,'20120920_003_NIR_park.dat']);
% vis = rd_spc_TCAP_v2([pname,'20120920_003_VIS_park.dat']);
% Let's try 004...
nir = rd_spc_TCAP_v2([pname,'20131122_002_NIR_park.dat']);
vis = rd_spc_TCAP_v2([pname,'20131122_002_VIS_park.dat']);

%%
V = datevec(nir.time);
%%
roytime = V(:,4)*100+V(:,5)+V(:,6)./60;
shut = nir.t.shutter==0;
sun = nir.t.shutter==1;
sky = nir.t.shutter==2;
% exclude edges shut, sun, sky
    shut(2:end)= shut(1:end-1)&shut(2:end); shut(1:end-1) = shut(1:end-1)&shut(2:end);
    sun(2:end) = sun(1:end-1)&sun(2:end); sun(1:end-1) = sun(1:end-1)&sun(2:end);
    sky(2:end) = sky(1:end-1)&sky(2:end); sky(1:end-1) = sky(1:end-1)&sky(2:end);

figure; sb(1) = subplot(2,1,1);
plot(roytime(shut), sum(vis.spectra(shut,:),2)./vis.t.t_ms(shut),'kx',...
 roytime(sun), sum(vis.spectra(sun,:),2)./vis.t.t_ms(sun), 'r.',roytime(sky), sum(vis.spectra(sky,:),2)./vis.t.t_ms(sky),'bx');
ylabel('sum(cts)')
legend('shut','red sun','blue sky','location','South');
sb(2) = subplot(2,1,2);
plot(roytime(shut), vis.t.t_ms(shut),'kx',roytime(sun), vis.t.t_ms(sun),'r.',...
    roytime(sky), vis.t.t_ms(sky), 'bx');
ylabel('ms')
legend('shut','sun','sky')
linkaxes(sb,'x')
%%
menu('Click OK when suitable range of points are selected.','OK')
xl = xlim;

figure; plot(vis.nm, mean(vis.spectra(sun&roytime>xl(1)&roytime<xl(2), :))-mean(vis.spectra(shut&roytime>xl(1)&roytime<xl(2), :)), 'b-',...
    nir.nm, mean(nir.spectra(sun&roytime>xl(1)&roytime<xl(2), :))-mean(nir.spectra(shut&roytime>xl(1)&roytime<xl(2), :)), 'r-')

title({'Dark-subtracted counts from HISS integrating sphere';vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('counts')
legend('vis','nir');
grid('on');zoom('on');
%%
% Langs_and_lamps.figures.HISS_9_lamp_DNs = handle2struct(gcf);
%%
Langs_and_lamps.vis.nm = vis.nm;
Langs_and_lamps.nir.nm = nir.nm;

%%
F925 = get_irad_F925;

% Langs_and_lamps.figures.HISS_9_lamps_radiances = handle2struct(gcf);

A = sun&roytime>xl(1)&roytime<xl(2);
B = shut&roytime>xl(1)&roytime<xl(2);
vis.dark = (mean(vis.spectra(B,:)));
vis.light =(mean(vis.spectra(A,:)));
vis.sig = vis.light - vis.dark;
vis.rate = vis.sig /mean(vis.t.t_ms(A));
F925_ = planck_tungsten_fit(F925.nm,F925.irad, vis.nm);
% vis.rad_9_lamps = interp1(hiss.nm,hiss.lamps_9, vis.nm,'linear');
vis.F925_irad = F925_.Irad;
vis.resp = vis.rate./vis.F925_irad;
nir.dark = (mean(nir.spectra(B,:)));
nir.light =(mean(nir.spectra(A,:)));
nir.sig = nir.light - nir.dark;
nir.rate = nir.sig /mean(nir.t.t_ms(A));
F925_ = planck_tungsten_fit(F925.nm,F925.irad, nir.nm);
nir.F925_irad = F925_.Irad;
nir.resp = nir.rate./nir.F925_irad;
vis.resp(vis.nm<300) = NaN;
vis.resp(vis.nm>994) = NaN;
nir.resp(nir.nm<950) = NaN;
nir.resp(nir.nm>1703) = NaN;


Langs_and_lamps.vis.F925_iradiance = vis.F925_irad;
Langs_and_lamps.nir.F925_iradiance = nir.F925_irad;
Langs_and_lamps.vis.F925_rate = vis.rate;
Langs_and_lamps.nir.F925_rate = nir.rate;
Langs_and_lamps.vis.F925_resp = vis.resp;
Langs_and_lamps.nir.F925_resp = nir.resp;


% Langs_and_lamps.vis.HISS_9_lamps_radiance = vis.rad_9_lamps;
% Langs_and_lamps.nir.HISS_9_lamps_radiance = nir.rad_9_lamps;
% Langs_and_lamps.vis.HISS_9_lamps_rate = vis.rate;
% Langs_and_lamps.nir.HISS_9_lamps_rate = nir.rate;
% Langs_and_lamps.vis.HISS_9_lamps_resp = vis.resp;
% Langs_and_lamps.nir.HISS_9_lamps_resp = nir.resp;

%%
figure;plot(vis.nm, vis.rate,'b-', nir.nm, nir.rate,'r-');
title({'Dark-subtracted count rate from F925 lamp',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms');
legend('vis','nir');
grid('on');zoom('on');

% Langs_and_lamps.figures.HISS_9_lamps_countrates = handle2struct(gcf);
%%
figure;plot(vis.nm, vis.resp,'b-', nir.nm, nir.resp,'r-');
title({'Responsivity from F925',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms/(W/m^2/um/sr)');
legend('vis','nir');
grid('on');zoom('on');
% Langs_and_lamps.figures.HISS_9_lamps_resp = handle2struct(gcf);
%% begining of HISS 12-lamp
pname = 'D:\case_studies\radiation_cals\2013_11_20.SASZe1_4STAR.NASA_Ames.Flynn\Lamps_12_sun_barrel\';
% Maybe _003_ all just messing around, bracketing performance for different
% settigs, etc. 
% nir = rd_spc_TCAP_v2([pname,'20120920_003_NIR_park.dat']);
% vis = rd_spc_TCAP_v2([pname,'20120920_003_VIS_park.dat']);
% Let's try 004...
nir = rd_spc_TCAP_v2([pname,'20131121_008_NIR_park.dat']);
vis = rd_spc_TCAP_v2([pname,'20131121_008_VIS_park.dat']);

%%
V = datevec(nir.time);
%%
roytime = V(:,4)*100+V(:,5)+V(:,6)./60;
shut = nir.t.shutter==0;
sun = nir.t.shutter==1;
sky = nir.t.shutter==2;
figure; sb(1) = subplot(2,1,1);
plot(roytime(shut), sum(vis.spectra(shut,:),2)./vis.t.t_ms(shut),'kx',...
 roytime(sun), sum(vis.spectra(sun,:),2)./vis.t.t_ms(sun), 'r.',roytime(sky), sum(vis.spectra(sky,:),2)./vis.t.t_ms(sky),'bx');
ylabel('sum(cts)')
legend('shut','red sun','blue sky')
sb(2) = subplot(2,1,2);
plot(roytime(shut), vis.t.t_ms(shut),'kx',roytime(sun), vis.t.t_ms(sun),'r.',...
    roytime(sky), vis.t.t_ms(sky), 'bx');
ylabel('ms')
legend('shut','sun','sky')
linkaxes(sb,'x')
%%
menu('Click OK when suitable range of points are selected.','OK')
xl = xlim;

figure; plot(vis.nm, mean(vis.spectra(sun&roytime>xl(1)&roytime<xl(2), :))-mean(vis.spectra(shut&roytime>xl(1)&roytime<xl(2), :)), 'b-',...
    nir.nm, mean(nir.spectra(sun&roytime>xl(1)&roytime<xl(2), :))-mean(nir.spectra(shut&roytime>xl(1)&roytime<xl(2), :)), 'r-')

title({'Dark-subtracted counts from HISS integrating sphere';vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('counts')
legend('vis','nir');
grid('on');zoom('on');
%%
% Langs_and_lamps.figures.HISS_9_lamp_DNs = handle2struct(gcf);
%%
hiss = get_hiss_2013June;

% Langs_and_lamps.figures.HISS_9_lamps_radiances = handle2struct(gcf);

A = sun&roytime>xl(1)&roytime<xl(2);
B = shut&roytime>xl(1)&roytime<xl(2);
vis.dark = (mean(vis.spectra(B,:)));
vis.light =(mean(vis.spectra(A,:)));
vis.sig = vis.light - vis.dark;
vis.rate = vis.sig /mean(vis.t.t_ms(A));
hiss.fit = planck_tungsten_fit(hiss.nm,hiss.lamps_12, vis.nm);
% vis.rad_9_lamps = interp1(hiss.nm,hiss.lamps_9, vis.nm,'linear');
vis.hiss_irad = hiss.fit.Irad;
vis.resp = vis.rate./vis.hiss_irad;
nir.dark = (mean(nir.spectra(B,:)));
nir.light =(mean(nir.spectra(A,:)));
nir.sig = nir.light - nir.dark;
nir.rate = nir.sig /mean(nir.t.t_ms(A));
hiss.fit = planck_tungsten_fit(hiss.nm,hiss.lamps_12, nir.nm);
nir.hiss_irad = hiss.fit.Irad;
nir.resp = nir.rate./nir.hiss_irad;
vis.resp(vis.nm<300) = NaN;
vis.resp(vis.nm>994) = NaN;
nir.resp(nir.nm<950) = NaN;
nir.resp(nir.nm>1703) = NaN;


Langs_and_lamps.vis.hiss_iradiance = vis.hiss_irad;
Langs_and_lamps.nir.hiss_iradiance = nir.hiss_irad;
Langs_and_lamps.vis.hiss_rate = vis.rate;
Langs_and_lamps.nir.hiss_rate = nir.rate;
Langs_and_lamps.vis.hiss_resp = vis.resp;
Langs_and_lamps.nir.hiss_resp = nir.resp;


% Langs_and_lamps.vis.HISS_9_lamps_radiance = vis.rad_9_lamps;
% Langs_and_lamps.nir.HISS_9_lamps_radiance = nir.rad_9_lamps;
% Langs_and_lamps.vis.HISS_9_lamps_rate = vis.rate;
% Langs_and_lamps.nir.HISS_9_lamps_rate = nir.rate;
% Langs_and_lamps.vis.HISS_9_lamps_resp = vis.resp;
% Langs_and_lamps.nir.HISS_9_lamps_resp = nir.resp;

%%
figure;plot(vis.nm, vis.rate,'b-', nir.nm, nir.rate,'r-');
title({'Dark-subtracted count rate from HISS 9-lamps',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms');
legend('vis','nir');
grid('on');zoom('on');

% Langs_and_lamps.figures.HISS_9_lamps_countrates = handle2struct(gcf);
%%
figure;plot(vis.nm, vis.resp,'b-', nir.nm, nir.resp,'r-');
title({'Responsivity from HISS 12-lamps',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms/(W/m^2/um/sr)');
legend('vis','nir');
grid('on');zoom('on');
% Langs_and_lamps.figures.HISS_9_lamps_resp = handle2struct(gcf);
%% end of HISS 12-lamp
[visc0, nirc0]=starc0(now); 
%%
gy = gueymard_ESR;
% figure;plot(gy(:,1), gy(:,2), 'b-',gy(:,1), gy(:,3), 'm-'); 
gy_vis = interp1(gy(:,1), gy(:,2), vis.nm,'pchip','extrap');
gy_nir = interp1(gy(:,1), gy(:,2), nir.nm,'pchip','extrap');
lang_vis_resp = visc0./gy_vis; lang_nir_resp = nirc0./gy_nir;
lang_vis_resp(vis.nm<300) = NaN;
lang_vis_resp(vis.nm>994) = NaN;
lang_nir_resp(nir.nm<950) = NaN;
lang_nir_resp(nir.nm>1703) = NaN;
Langs_and_lamps.vis.Langley_Co = visc0;
Langs_and_lamps.nir.Langley_Co = nirc0;
Langs_and_lamps.vis.Guey_ESR = gy_vis;
Langs_and_lamps.nir.Guey_ESR = gy_nir;
Langs_and_lamps.vis.Langley_resp = lang_vis_resp;
Langs_and_lamps.nir.Langley_resp = lang_nir_resp;
%
figure; plot(Langs_and_lamps.vis.nm, [Langs_and_lamps.vis.Langley_Co;350.*Langs_and_lamps.vis.Guey_ESR;  2.*Langs_and_lamps.vis.Langley_resp],'-')
legend('Co','ESR','Resp'); xlim([400,800])
% We've got a bit more work to do before this becomes valuable, but there
% is potential.  We need to convolve the source function with an
% appropriate lineshape (corresponding to 4STAR resolution) to minimize correlation between features in the
% ESR source function with responsivity.  Maybe we should (finally) try to
% deconvolve the 4STAR data to pixel-spaced resolution.  This makes the
% corresponding apodization of the source function merely a square wave of
% width equal to the pixel spacing.
% Once this is done, the remaining sharp features in the responsivity are
% attributable to atmospheric phenomena.  Typically absorbers yield
% "dips" in the responsivity but if changing during Langley peaks are also
% possible.  We want to use the lamp to patch over each of these features. 

%%
figure; plot(vis.nm, visc0, 'b-', nir.nm, nirc0, 'r-');
title('Langley-derived Co');
xlabel('wavelength [nm]');
legend('vis C_0','nir C_0');
ylabel('(DN/ms)');
grid('on');
zoom('on');
axis([310    1700   0    1250]);
% Langs_and_lamps.figures.Lang_Co = handle2struct(gcf);
%%
figure; plot(vis.nm, lang_vis_resp, 'b-', nir.nm, lang_nir_resp, 'r-');
title('Langley-derived responsivity');
xlabel('wavelength [nm]');
legend('vis spec','nir spec');
ylabel('(DN/ms)/(W/m^2/nm)');
grid('on'); zoom('on');
% Langs_and_lamps.figures.Lang_resp = handle2struct(gcf);

%%
figure; plot(vis.nm, lang_vis_resp./Langs_and_lamps.vis.hiss_resp, 'b-', ... 
    nir.nm, lang_nir_resp./Langs_and_lamps.nir.hiss_resp, 'r-');
xlabel('wavelength [nm]');
legend('vis spec','nir spec')
ylabel('Co Lang / Co HISS')
title('Langley over HISS responsivity');
grid('on');zoom('on');
% Langs_and_lamps.figures.Lang_resp_scaling = handle2struct(gcf);
%%
figure; plot(vis.nm, lang_vis_resp./Langs_and_lamps.vis.F925_resp, 'b-', ... 
    nir.nm, lang_nir_resp./Langs_and_lamps.nir.F925_resp, 'r-');
xlabel('wavelength [nm]');
legend('vis spec','nir spec')
ylabel('Co Lang / Co F925')
title('Langley over F925 responsivity');
grid('on');zoom('on');
% Langs_and_lamps.figures.Lang_resp_scaling = handle2struct(gcf);
%%
figure; plot(vis.nm, lang_vis_resp, 'b-', nir.nm, lang_nir_resp, 'b-',...
   vis.nm, Langs_and_lamps.vis.hiss_resp*5.3e5, 'r-', nir.nm, Langs_and_lamps.nir.hiss_resp*5.3e5, 'r-' );
xlabel('wavelength [nm]');
ylabel('Co')
title('Langley Co (blue), Scaled lamp (red)');
grid('on');zoom('on');
%%
figure; plot(vis.nm, lang_vis_resp, 'b-', nir.nm, lang_nir_resp, 'b-',...
 vis.nm,  Langs_and_lamps.vis.F925_resp*1.32e-4, 'r-', nir.nm, Langs_and_lamps.nir.F925_resp*1.32e-4, 'r-' );
xlabel('wavelength [nm]');
ylabel('Co')
title('Langley Co (blue), Scaled lamp (red)');
grid('on');zoom('on');
% Langs_and_lamps.figures.Lang_resp_scaled = handle2struct(gcf);
%%
save([vis.pname,'..',filesep,'Langs_hiss_F925.mat'],'-struct','Langs_and_lamps');
%%

return