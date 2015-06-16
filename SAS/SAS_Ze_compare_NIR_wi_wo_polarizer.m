function outs = SAS_compare_bare_He_Ze;

% SAS transmittance of Ze and He vs bare fiber using blue integrating
% sphere with V = 10.42, I = 2.78

% Read bare_fiber:
bare = SAS_read_ava(getfullname('*.csv','ava','Select bare fiber spectra'));
bare.dark = sum(bare.spec,2)<mean(sum(bare.spec,2));
bare.darks = mean(bare.spec(bare.dark,:),1);
bare.lights = mean(bare.spec(~bare.dark,:),1)-bare.darks;
figure; subplot(2,1,1); plot(bare.nm, bare.darks, 'k-');
title('Bare darks');
subplot(2,1,2); semilogy(bare.nm, bare.lights,'b-');
title('Bare DN-darks');


He = SAS_read_ava(getfullname('*.csv','ava','Select Hemispheric diffuser spectra'));
He.dark = sum(He.spec,2)<mean(sum(He.spec,2));
He.darks = mean(He.spec(He.dark,:),1);
He.lights = mean(He.spec(~He.dark,:),1)-He.darks;

Ze = SAS_read_ava(getfullname('*.csv','ava','Select Zenith collimator spectra'));
Ze.dark = sum(Ze.spec,2)<mean(sum(Ze.spec,2));
Ze.darks = mean(Ze.spec(Ze.dark,:),1);
Ze.lights = mean(Ze.spec(~Ze.dark,:),1)-Ze.darks;

figure; subplot(2,1,1); plot(Ze.nm, Ze.darks, 'k-');
title('Zenith darks');
subplot(2,1,2); semilogy(Ze.nm, Ze.lights,'b-');
title('Zenith DN-darks');

figure; subplot(2,1,1); plot(He.nm, He.darks, 'k-');
title('Hemispheric darks');
subplot(2,1,2); semilogy(He.nm, He.lights,'b-');
title('Hemispheric DN-darks');

figure; plot(bare.nm, He.lights./bare.lights, '.r-',bare.nm, Ze.lights./bare.lights, '.b-');
title({['Transmittance'],bare.sn});

legend('Hemispheric','Zenith')

figure; plot(bare.nm, He.lights./Ze.lights, '.k-');
title({['Ratio of Hemispheric Transmittance over Zenith Transmittance'],bare.sn});

outs.bare = bare;
outs.He = He;
outs.Ze = Ze;
outs.He_T = He.lights./bare.lights;
outs.Ze_T = Ze.lights./bare.lights;
outs.He_by_Ze  = He.lights./Ze.lights;

return