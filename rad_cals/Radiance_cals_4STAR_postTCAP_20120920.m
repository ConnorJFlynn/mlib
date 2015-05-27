% nir = rd_spc_TCAP_v2([pname,'20120920_003_NIR_park.dat']);
% vis = rd_spc_TCAP_v2([pname,'20120920_003_VIS_park.dat']);
% Page 3 of 7 from the lab book, scaling integation time. 

% Seems like what I'll need to do is first screen for dark and light
% Then perhaps compute dark/ms over time.  Interpolate to nearest time,
% compute dark for integration time setting.
%%
clear
close('all')
pause(.1);
pname = 'C:\case_studies\4STAR\data\2012\2012_09_20_36insphere_monchromator\';
% Maybe _003_ all just messing around, bracketing performance for different
% settigs, etc. 
% nir = rd_spc_TCAP_v2([pname,'20120920_003_NIR_park.dat']);
% vis = rd_spc_TCAP_v2([pname,'20120920_003_VIS_park.dat']);
% Let's try 004...
nir = rd_spc_TCAP_v2([pname,'20120920_004_NIR_park.dat']);
vis = rd_spc_TCAP_v2([pname,'20120920_004_VIS_park.dat']);

%%
V = datevec(nir.time);
%%
roytime = V(:,4)*100+V(:,5)+V(:,6)./60;
shut = nir.t.shutter==0;
sun = nir.t.shutter==1;
sky = nir.t.shutter==2;
% figure; sb(1) = subplot(2,1,1);
% plot(roytime(shut), sum(vis.spectra(shut,:),2)./vis.t.t_ms(shut),'kx',...
%  roytime(sun), sum(vis.spectra(sun,:),2)./vis.t.t_ms(sun), 'r.',roytime(sky), sum(vis.spectra(sky,:),2)./vis.t.t_ms(sky),'bx');
% ylabel('sum(cts)')
% legend('shut','red sun','blue sky')
% sb(2) = subplot(2,1,2);
% plot(roytime(shut), vis.t.t_ms(shut),'kx',roytime(sun), vis.t.t_ms(sun),'r.',...
%     roytime(sky), vis.t.t_ms(sky), 'bx');
% ylabel('ms')
% legend('shut','sun','sky')
% linkaxes(sb,'x')
%%

figure; plot(vis.nm, mean(vis.spectra(sun&roytime>1733.5&roytime<1735.5, :))-mean(vis.spectra(shut&roytime>1733.5&roytime<1735.5, :)), 'b-',...
    nir.nm, mean(nir.spectra(sun&roytime>1733.5&roytime<1735.5, :))-mean(nir.spectra(shut&roytime>1733.5&roytime<1735.5, :)), 'r-')

title({'Dark-subtracted counts from HISS integrating sphere';vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('counts')
legend('vis','nir');
grid('on');zoom('on');
%%
Langs_and_lamps.figures.HISS_9_lamp_DNs = handle2struct(gcf);
%%
Langs_and_lamps.vis.nm = vis.nm;
Langs_and_lamps.nir.nm = nir.nm;

%%
hiss = get_hiss_Nov2011('201112131052Hiss-corrected.txt');

rad_577 = planck_fit(hiss.nm, hiss.lamps_12,star.nm);
figure; plot(hiss.nm, hiss.lamps_12, 'o',rad_577.nm, rad_577.Irad, '-r.');
title('Based on HISS in units F[W/(cm^2*nm)]','interp','none');

%%
Langs_and_lamps.figures.HISS_9_lamps_radiances = handle2struct(gcf);

A = sun&roytime>1733.5&roytime<1735.5;
B = shut&roytime>1733.5&roytime<1735.5;
vis.dark = (mean(vis.spectra(B,:)));
vis.light =(mean(vis.spectra(A,:)));
vis.sig = vis.light - vis.dark;
vis.rate = vis.sig /mean(vis.t.t_ms(A));
vis.rad_9_lamps = interp1(hiss.nm,hiss.lamps_9, vis.nm,'linear'); 
vis.resp = vis.rate./vis.rad_9_lamps;
nir.dark = (mean(nir.spectra(B,:)));
nir.light =(mean(nir.spectra(A,:)));
nir.sig = nir.light - nir.dark;
nir.rate = nir.sig /mean(nir.t.t_ms(A));
nir.rad_9_lamps = interp1(hiss.nm,hiss.lamps_9, nir.nm,'linear'); 
nir.resp = nir.rate./nir.rad_9_lamps;
vis.resp(vis.nm<337) = NaN;
vis.resp(vis.nm>994) = NaN;
nir.resp(nir.nm<950) = NaN;
nir.resp(nir.nm>1703) = NaN;

Langs_and_lamps.vis.HISS_9_lamps_radiance = vis.rad_9_lamps;
Langs_and_lamps.nir.HISS_9_lamps_radiance = nir.rad_9_lamps;
Langs_and_lamps.vis.HISS_9_lamps_rate = vis.rate;
Langs_and_lamps.nir.HISS_9_lamps_rate = nir.rate;
Langs_and_lamps.vis.HISS_9_lamps_resp = vis.resp;
Langs_and_lamps.nir.HISS_9_lamps_resp = nir.resp;

%%
figure;plot(vis.nm, vis.rate,'b-', nir.nm, nir.rate,'r-');
title({'Dark-subtracted count rate from HISS 9-lamps',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms');
legend('vis','nir');
grid('on');zoom('on');

Langs_and_lamps.figures.HISS_9_lamps_countrates = handle2struct(gcf);
%%
figure;plot(vis.nm, vis.resp,'b-', nir.nm, nir.resp,'r-');
title({'Responsivity from HISS 9-lamps',vis.fname},'interp','none');
xlabel('wavelength [nm]');
ylabel('DN/ms/(W/m^2/um/sr)');
legend('vis','nir');
grid('on');zoom('on');
Langs_and_lamps.figures.HISS_9_lamps_resp = handle2struct(gcf);

%%
[visc0, nirc0, visnote, nirnote]=starc0(now); 
%%
gy = gueymard_ESR;
% figure;plot(gy(:,1), gy(:,2), 'b-',gy(:,1), gy(:,3), 'm-'); 
gy_vis = interp1(gy(:,1), gy(:,3), vis.nm,'linear','extrap');
gy_nir = interp1(gy(:,1), gy(:,3), nir.nm,'linear','extrap');
lang_vis_resp = visc0./gy_vis; lang_nir_resp = nirc0./gy_nir;
lang_vis_resp(vis.nm<335) = NaN;
lang_vis_resp(vis.nm>994) = NaN;
lang_nir_resp(nir.nm<950) = NaN;
lang_nir_resp(nir.nm>1703) = NaN;
Langs_and_lamps.vis.Langley_Co = visc0;
Langs_and_lamps.nir.Langley_Co = nirc0;
Langs_and_lamps.vis.Guey_ESR = gy_vis;
Langs_and_lamps.nir.Guey_ESR = gy_nir;
Langs_and_lamps.vis.Langley_resp = lang_vis_resp;
Langs_and_lamps.nir.Langley_resp = lang_nir_resp;
%%
figure; plot(vis.nm, visc0, 'b-', nir.nm, nirc0, 'r-');
title('Langley-derived Co');
xlabel('wavelength [nm]');
legend('vis C_0','nir C_0');
ylabel('(DN/ms)');
grid('on');
zoom('on');
axis([310    1700   0    1250]);
Langs_and_lamps.figures.Lang_Co = handle2struct(gcf);
%%
figure; plot(vis.nm, lang_vis_resp, 'b-', nir.nm, lang_nir_resp, 'r-');
title('Langley-derived responsivity');
xlabel('wavelength [nm]');
legend('vis spec','nir spec');
ylabel('(DN/ms)/(W/m^2/nm)');
grid('on'); zoom('on');
Langs_and_lamps.figures.Lang_resp = handle2struct(gcf);

%%
figure; plot(vis.nm, lang_vis_resp./vis.resp, 'b-', nir.nm, lang_nir_resp./nir.resp, 'r-');
xlabel('wavelength [nm]');
legend('vis spec','nir spec')
ylabel('Co Lang / Co Lamp')
title('Langley over Lamp responsivity');
grid('on');zoom('on');
Langs_and_lamps.figures.Lang_resp_scaling = handle2struct(gcf);
%%
figure; plot(vis.nm, lang_vis_resp, 'b-', nir.nm, lang_nir_resp, 'b-',...
   vis.nm, vis.resp*3.68e5, 'r-', nir.nm, nir.resp*3.68e5, 'r-' );
xlabel('wavelength [nm]');
ylabel('Co')
title('Langley Co (blue), Scaled lamp (red)');
grid('on');zoom('on');
Langs_and_lamps.figures.Lang_resp_scaled = handle2struct(gcf);

save('C:\case_studies\4STAR\data\2012\2012_09_20_36insphere_monchromator\Langs_and_lamps.mat','Langs_and_lamps');
%%
% vis.dark_6ms_9lamps = (mean(vis.spectra(shut&vis.t.t_ms==6&nir.t.t_ms==30&roytime<1812.5&roytime>1811.75,:)));
% vis.light_6ms_9lamps =(mean(vis.spectra(sky&vis.t.t_ms==6&nir.t.t_ms==30&roytime<1812.5&roytime>1811.75,:)));
% vis.sig_6ms_9lamps = vis.light_6ms_9lamps - vis.dark_6ms_9lamps;
% vis.rate_9ms_9lamps = vis.sig_6ms_9lamps /6;
% vis.rad_9lamps = interp1(archi.nm,archi.lamps_9, vis.nm,'linear'); 
% vis.resp_6ms_9lamps = vis.rate_9ms_9lamps./vis.rad_9lamps;
% figure;plot(vis.nm, vis.resp_6ms_9lamps,'r-');
%%
%
% ti = [80:90];
% rec = [1:length(vis.time)];
% figure; these = plot(vis.nm, vis.spectra(ti,:),'-');
% recolor(these, rec(ti)); colorbar
% tl = title({'Raw cts vs wavelength recs 80:90';vis.fname},'interp','none');
% ylabel('raw cts')
% xlabel('wavelength [nm]');
% %%
% savefig;
% %%
% %1:49 dark
% 
% %%
% rec = [1:length(vis.time)];
% [vis.t.maxcts, vis.t.max_ii] = max(vis.spectra,[],2);
% [nir.t.maxcts, nir.t.max_ii] = max(nir.spectra,[],2);
% figure; ax(1) = subplot(2,1,1);
% semilogy(rec, vis.t.maxcts, 'b.',[1:length(nir.time)], nir.t.maxcts,'r.' );
% ax(2) = subplot(2,1,2);
% plot(rec, vis.nm(vis.t.max_ii), 'b.', [1:length(nir.time)],nir.nm(nir.t.max_ii),'r.');
% linkaxes(ax,'x')
% %%
% archi = get_hiss_Nov2011('201112131052Hiss-corrected.txt');
% % Now checking 005 and 006 for 12 lamps full on.
% % settigs, etc. 
% % nir = rd_spc_TCAP_v2([pname,'20120920_003_NIR_park.dat']);
% % vis = rd_spc_TCAP_v2([pname,'20120920_003_VIS_park.dat']);
% % Let's try 004...
% %%
% pname = 'C:\case_studies\4STAR\data\2012\2012_09_20_36insphere_monchromator\';
% % nir = rd_spc_TCAP_v2([pname,'20120920_005_NIR_park.dat']);
% % vis = rd_spc_TCAP_v2([pname,'20120920_005_VIS_park.dat']);
% nir = rd_spc_TCAP_v2([pname,'20120920_006_NIR_park.dat']);
% vis = rd_spc_TCAP_v2([pname,'20120920_006_VIS_park.dat']);
% V = datevec(nir.time);
% %%
% 
% roytime = V(:,4)*100+V(:,5)+V(:,6)./60;
% shut = nir.t.shutter==0;
% sun = nir.t.shutter==1;
% sky = nir.t.shutter==2;
% shut(2:end) = shut(1:end-1)&shut(2:end); %Shutter motion is not very clean.  Need to strip some adjacent records on both ends.`
% shut(1:end-1) = shut(1:end-1)&shut(2:end);
% shut(1:end-1) = shut(1:end-1)&shut(2:end);
% sky(2:end) = sky(1:end-1)&sky(2:end);
% sky(1:end-1) = sky(1:end-1)&sky(2:end);
% sun(2:end) = sun(1:end-1)&sun(2:end);
% sun(1:end-1) = sun(1:end-1)&sun(2:end);
% figure; sb(1) = subplot(3,1,1);
% plot(roytime(shut), sum(vis.spectra(shut,:),2)./vis.t.t_ms(shut),'kx',...
%  roytime(sun), sum(vis.spectra(sun,:),2)./vis.t.t_ms(sun), 'r.',roytime(sky), sum(vis.spectra(sky,:),2)./vis.t.t_ms(sky),'bx');
% ylabel('sum(cts)')
% legend('shut','sky is blue, sun is red')
% sb(2) = subplot(3,1,2);
% plot(roytime(shut), vis.t.t_ms(shut),'kx',roytime(sun), vis.t.t_ms(sun),'r.',...
%     roytime(sky), vis.t.t_ms(sky), 'bx');
% ylabel('ms')
% legend('shut','sky is blue, sun is red')
% sb(3) = subplot(3,1,3);
% plot(roytime(shut), nir.t.t_ms(shut),'kx',roytime(sun), nir.t.t_ms(sun),'r.',...
%     roytime(sky), nir.t.t_ms(sky), 'bx');
% ylabel('NIR ms')
% legend('shut','sky is blue, sun is red')
% linkaxes(sb,'x')
% 
% %%
% vis.dark_6ms_9lamps = (mean(vis.spectra(shut&vis.t.t_ms==6&nir.t.t_ms==30&roytime<1812.5&roytime>1811.75,:)));
% vis.light_6ms_9lamps =(mean(vis.spectra(sky&vis.t.t_ms==6&nir.t.t_ms==30&roytime<1812.5&roytime>1811.75,:)));
% vis.sig_6ms_9lamps = vis.light_6ms_9lamps - vis.dark_6ms_9lamps;
% vis.rate_9ms_9lamps = vis.sig_6ms_9lamps /6;
% vis.rad_9lamps = interp1(archi.nm,archi.lamps_9, vis.nm,'linear'); 
% vis.resp_6ms_9lamps = vis.rate_9ms_9lamps./vis.rad_9lamps;
% figure;plot(vis.nm, vis.resp_6ms_9lamps,'r-');
% %%
% TCAP_star_cals = loadinto(['C:\Users\d3k014\Desktop\TCAP\instruments\4STAR\mats\TCAP_STAR_sunsky_cals.mat']);
% %%
% figure; plot(vis.nm, vis.resp_6ms_9lamps,'r-', TCAP_star_cals.vis.sky.wavelength, TCAP_star_cals.vis.sky.resp,'-k');
% legend('new post TCAP', 'ad hoc old to new estimate');
% xlabel('wavelength [nm]');
% ylabel('responsivity [cts/W/nm/m^2/ms/sterad]')
% %%
% figure; plot(vis.nm, vis.resp_6ms_9lamps./TCAP_star_cals.vis.sky.resp','-k');
% legend('new post TCAP', 'ad hoc old to new estimate');
% xlabel('wavelength [nm]');
% ylabel('responsivity [cts/W/nm/m^2/ms/sterad]')