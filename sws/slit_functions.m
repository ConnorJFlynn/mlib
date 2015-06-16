 vis_slit.I = load(getfullname('*.dat'));
 [~,mi] = max(vis_slit.I);
 vis_slit.nm = 0.25.*([1:length(vis_slit.I)]-mi)';
 
nm_ = vis_slit.I>0.025;
[vis_slit.sigma,vis_slit.mu,vis_slit.A,vis_slit.FWHM,vis_slit.peak]=mygaussfit(vis_slit.nm(nm_),vis_slit.I(nm_),0);
vis_slit.Gaussian = gaussian_fwhm(vis_slit.nm(nm_), 0, vis_slit.FWHM);
figure; 
s(1) = subplot(2,1,1); plot(vis_slit.nm(nm_), vis_slit.Gaussian, 'r-'); xl = xlim; hold('on');
plot(vis_slit.nm, vis_slit.I,'-b.'); xlim(xl);
title('Pilewski measured slit function of SWS VIS spectrometer.')
ylabel('relative response')
legend('measurement','Gaussian fit');
yl = [min(vis_slit.Gaussian), 1.1];ylim(yl);
s(2) = subplot(2,1,2); semilogy(vis_slit.nm(nm_), vis_slit.Gaussian, 'r-',vis_slit.nm, vis_slit.I,'-b.'); 
linkaxes(s,'x'); 
xlim(s(1),xl);ylim(yl);
xlabel('wavelength [nm]');
ylabel('log response')

%%
 nir_slit.I = load(getfullname('*.dat'));
 [~,mi] = max(nir_slit.I);
 nir_slit.nm = 0.25.*([1:length(nir_slit.I)]-mi)';
 
nm_ = nir_slit.I>0.025;
[nir_slit.sigma,nir_slit.mu,nir_slit.A,nir_slit.FWHM,nir_slit.peak]=mygaussfit(nir_slit.nm(nm_),nir_slit.I(nm_),0);
nir_slit.Gaussian = gaussian_fwhm(nir_slit.nm(nm_), 0, nir_slit.FWHM);
figure; 
s(1) = subplot(2,1,1); plot(nir_slit.nm(nm_), nir_slit.Gaussian, 'r-'); xl = xlim; hold('on');
plot(nir_slit.nm, nir_slit.I,'-b.'); xlim(xl);
title('Pilewski measured slit function of SWS NIR spectrometer.')
ylabel('relative response')
legend('measurement','Gaussian fit');
yl = [min(nir_slit.Gaussian), 1.1];ylim(yl);
s(2) = subplot(2,1,2); semilogy(nir_slit.nm(nm_), nir_slit.Gaussian, 'r-',nir_slit.nm, nir_slit.I,'-b.'); 
linkaxes(s,'x'); 
xlim(s(1),xl);ylim(yl);
xlabel('wavelength [nm]');
ylabel('log response')