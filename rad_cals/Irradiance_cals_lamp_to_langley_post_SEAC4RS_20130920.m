function Irradiance_cals_lamp_to_langley_post_SEAC4RS_20130920
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


pname = 'C:\MatlabCodes\data\2013011_21_22CalLab\';
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

title({'Dark-subtracted counts from FEL lamp test';vis.fname},'interp','none');
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
F925vis = planck_tungsten_fit(F925.nm,F925.irad, vis.nm);
% vis.rad_9_lamps = interp1(hiss.nm,hiss.lamps_9, vis.nm,'linear');
vis.F925_irad = F925vis.Irad;
vis.FELresp = vis.rate./vis.F925_irad;
nir.dark = (mean(nir.spectra(B,:)));
nir.light =(mean(nir.spectra(A,:)));
nir.sig = nir.light - nir.dark;
nir.rate = nir.sig /mean(nir.t.t_ms(A));
F925nir = planck_tungsten_fit(F925.nm,F925.irad, nir.nm);
nir.F925_irad = F925nir.Irad;
nir.FELresp = nir.rate./nir.F925_irad;
vis.FELresp(vis.nm<300) = NaN;
vis.FELresp(vis.nm>994) = NaN;
nir.FELresp(nir.nm<950) = NaN;
nir.FELresp(nir.nm>1703) = NaN;


Langs_and_lamps.vis.F925_iradiance = vis.F925_irad;
Langs_and_lamps.nir.F925_iradiance = nir.F925_irad;
Langs_and_lamps.vis.F925_rate = vis.rate;
Langs_and_lamps.nir.F925_rate = nir.rate;
Langs_and_lamps.vis.F925_resp = vis.FELresp;
Langs_and_lamps.nir.F925_resp = nir.FELresp;

%%
figure;plot(vis.nm, vis.rate,'b-', nir.nm, nir.rate,'r-');
title({'Dark-subtracted count rate from FEL lamp test',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms');
legend('vis','nir');
grid('on');zoom('on');
%%
figure;plot(vis.nm, vis.FELresp,'b-', nir.nm, nir.FELresp,'r-');
title({'Responsivity from F925',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms/(W/m^2/um/sr)');
legend('vis','nir');
grid('on');zoom('on');
%% load c0
[visc0, nirc0]=starc0(now); 
%%
%% use kurucz for scaling
% [kur] = read_kurucz;
% import MODTRAN solar spectrum (kurucz)
kurvis = importdata('C:\MatlabCodes\code\Irradiance_cals_lamp_and_HISS_to_langley_post_SEAC4RS_20130920.m\kur2star_vis.ref');
kur.visnm     = kurvis.data(:,1);
kur.visIrad   = kurvis.data(:,2);
kur.visInterp = interp1(kur.visnm, kur.visIrad, vis.nm,'pchip','extrap');
kurnir = importdata('C:\MatlabCodes\code\Irradiance_cals_lamp_and_HISS_to_langley_post_SEAC4RS_20130920.m\kur2star_nir.ref');
kur.nirnm     = kurnir.data(:,1);
kur.nirIrad   = kurnir.data(:,2);
kur.nirInterp = interp1(kur.nirnm, kur.nirIrad, nir.nm,'pchip','extrap');
% plot conv kurucz4star
figure;plot(vis.nm,kur.visInterp,'-b');hold on;plot(nir.nm,kur.nirInterp,'-r');hold off;
axis([300 1700 0 2.2]);xlabel('wavelength [nm]');ylabel('Irradiance [W/m2/nm]');title('kurucz interpolated to 4STAR');
% end plot
lang_vis_resp = visc0./kur.visInterp; lang_nir_resp = nirc0./kur.nirInterp;
lang_vis_resp(vis.nm<300) = NaN;
lang_vis_resp(vis.nm>994) = NaN;
lang_nir_resp(nir.nm<950) = NaN;
lang_nir_resp(nir.nm>1703) = NaN;
% calculate S ratio only for valid wavelength
vis.lang_resp = lang_vis_resp;
nir.lang_resp = lang_nir_resp;
% normalize langley response
[vis.lang_resp_norm vis.lang_resp_mu vis.lang_resp_rng] = featureNormalizeRange(lang_vis_resp);
[nir.lang_resp_norm nir.lang_resp_mu nir.lang_resp_rng] = featureNormalizeRange(lang_nir_resp);
%
%[vis.lang_resp_std vis.lang_resp_mus vis.lang_resp_std] = featureNormalizeNaN(lang_vis_resp);
%[nir.lang_resp_std nir.lang_resp_mus nir.lang_resp_std] = featureNormalizeNaN(lang_nir_resp);

% normalize lamp response
[vis.lamp_resp_norm vis.lamp_resp_mu vis.lamp_resp_rng] = featureNormalizeRange(vis.FELresp);
[nir.lamp_resp_norm nir.lamp_resp_mu nir.lamp_resp_rng] = featureNormalizeRange(nir.FELresp);
%
%[vis.lamp_resp_std vis.lamp_resp_mus vis.lamp_resp_rng] = featureNormalizeNaN(vis.FELresp);
%[nir.lamp_resp_std nir.lamp_resp_mus nir.lamp_resp_rng] = featureNormalizeNaN(nir.FELresp);

% overlay normalized responsivities
figure;
plot(vis.nm,vis.lang_resp_norm,'--b','linewidth',2);hold on;plot(nir.nm,nir.lang_resp_norm,'--r','linewidth',2);hold on;
plot(vis.nm,vis.lamp_resp_norm,':c','linewidth',2); hold on;plot(nir.nm,nir.lamp_resp_norm,':y','linewidth',2); hold on;
xlabel('wavelength');ylabel('normalized responsivities');legend('c0 vis', 'c0 nir','FEL vis','FEL nir');

% calculate S ratio
% range normalization
vis.lang_lamp_ratio = vis.lang_resp_norm./vis.lamp_resp_norm;
nir.lang_lamp_ratio = nir.lang_resp_norm./nir.lamp_resp_norm;
% standard normalization
%vis.lang_lamp_ratios = vis.lang_resp_std./vis.lamp_resp_std;
%nir.lang_lamp_ratios = nir.lang_resp_std./nir.lamp_resp_std;

% load non-abs idx
nonabs = load(fullfile(starpaths,'nonabs.mat'));
vis.nonabs = nonabs.idx(1:1044);
nir.nonabs = nonabs.idx(1045:end);
% plot response ratios
figure; plot(vis.nm,vis.lang_lamp_ratio,'.b');hold on;plot(nir.nm,nir.lang_lamp_ratio,'.r');
hold on; plot(vis.nm(vis.nonabs==1),vis.nonabs(vis.nonabs==1),'.','color',[0.5 0.5 0.5]);
hold on; plot(nir.nm(nir.nonabs==1),nir.nonabs(nir.nonabs==1),'.','color',[0.5 0.5 0.5]);
xlabel('wavelength [nm]');ylabel('langley/lamp ratio (range normalization)');legend('vis ratio','nir ratio','non-abs wavelengths');
axis([300 1700 -2 2]);
%
% figure; plot(vis.nm,vis.lang_lamp_ratios,'.b');hold on;plot(nir.nm,nir.lang_lamp_ratios,'.r');
% hold on; plot(vis.nm(vis.nonabs==1),vis.nonabs(vis.nonabs==1),'.','color',[0.5 0.5 0.5]);
% hold on; plot(nir.nm(nir.nonabs==1),nir.nonabs(nir.nonabs==1),'.','color',[0.5 0.5 0.5]);
% xlabel('wavelength [nm]');ylabel('langley/lamp ratio (standard normalization)');legend('vis ratio','nir ratio','non-abs wavelengths');
% axis([300 1700 -2 2]);
%% scale with difference method
% choose wavelength to scale with
% vis.Sdiff = (vis.lang_lamp_ratio - ones(1,length(vis.nm))).^2;
% nir.Sdiff = (nir.lang_lamp_ratio - ones(1,length(nir.nm))).^2;
% figure;plot(vis.nm,vis.Sdiff,'.g');axis([300 1000 0 0.1]);xlabel('wavelength [nm]');ylabel('squared difference (ratio-1)');
% hold on;plot(nir.nm,nir.Sdiff,'.y');
% axis([300 1700 0 0.1]);
% %
% vis.scaleidx = logical(vis.Sdiff<=0.002);   % 463 wavelengths)
vis.Sratio   = lang_vis_resp./vis.FELresp;
% vis.SratioAvg = mean(vis.Sratio(vis.scaleidx==1));
% vis.SratioStd = std (vis.Sratio(vis.scaleidx==1));
% % scale lamp2lang
% vis.scaledLamp2Lang = (vis.FELresp*vis.SratioAvg).*kur.visInterp;   % in rate units
% % combine lamp and Langley
% vis.LangLampComb = visc0;
% vis.LangLampComb(vis.scaleidx==0) = vis.scaledLamp2Lang(vis.scaleidx==0);
% % plot compares and corrections
% figure;plot(vis.nm,vis.scaledLamp2Lang,'-y');hold on;plot(vis.nm,visc0,'--b');hold on;
% plot(vis.nm,vis.LangLampComb,':r');hold on;
% plot(vis.nm(vis.scaleidx==1),visc0(vis.scaleidx==1),'.','color',[0.5 0.5 0.5]);
% xlabel('wavelength');axis([300 1000 0 700]);legend('scaled lamp','vis c0','combined Langley','pixels used in scaling');
%%
%% scale with MODTRAN calculated wavelengths
MODTRANcalc = load('C:\MatlabCodes\4STAR\MODTRANcalc.mat');
vis.scaleaeroidx = MODTRANcalc.aeroind(1:1044); % 578 wavelengths
% plot aerosol index wavelength
figure;
plot(vis.nm,vis.lang_resp_norm,'-b');hold on;plot(vis.nm,vis.lamp_resp_norm,'--r');hold on;
plot(vis.nm(vis.scaleaeroidx==1),vis.lang_resp_norm(vis.scaleaeroidx==1),'.','color',[0.5 0.5 0.5]);
xlabel('wavelength');ylabel('responsivity');legend('Langley responsivity','Lamp responsivity','MODTRAN "good" scaling wavelength');
vis.SratioAvgMod = nanmean(vis.Sratio(vis.scaleaeroidx==1));
vis.SratioStdMod = nanstd (vis.Sratio(vis.scaleaeroidx==1));
% scale lamp2lang
vis.scaledLamp2LangMod = (vis.FELresp*vis.SratioAvgMod).*kur.visInterp;   % in rate units
% combine lamp and Langley
vis.LangLampCombMod = visc0;
vis.LangLampCombMod(vis.scaleaeroidx==0) = vis.scaledLamp2LangMod(vis.scaleaeroidx==0);
% plot compares and corrections
figure;plot(vis.nm,vis.scaledLamp2LangMod,'-y');hold on;plot(vis.nm,visc0,'--b');hold on;
plot(vis.nm,vis.LangLampCombMod,':r');hold on;
plot(vis.nm(vis.scaleaeroidx==1),visc0(vis.scaleaeroidx==1),'.','color',[0.5 0.5 0.5]);
xlabel('wavelength');axis([300 1000 0 700]);ylabel('counts');legend('scaled lamp','vis c0','combined Langley','pixels used in scaling');

% plot differences:
figure;
plot(vis.nm,((vis.scaledLamp2LangMod-visc0)./visc0)*100,'-y', 'linewidth',2);hold on;
plot(vis.nm,((vis.LangLampCombMod   -visc0)./visc0)*100,':r','linewidth',2);hold on;
xlabel('wavelength');ylabel('difference [%]');legend('scaled lamp - c0','combined Langley - c0');axis([300 1000 -10 10]);
% S    = lang_resp(MODTRANcalc.aeroind==1&MODTRANcalc.wln<995&MODTRANcalc.wln>400)./lamp_resp(MODTRANcalc.aeroind==1&MODTRANcalc.wln<995&MODTRANcalc.wln>400);
% Savg = nanmean(S);
% Sstd = nanstd (S);
%%


return