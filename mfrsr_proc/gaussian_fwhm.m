function [P,sigma] = gaussian_fwhm(w, mu, fwhm);
% [P,sigma] = gaussian_fwhm(w, mu, FWHM);
% Gaussian profile with unit height centered on mu with full-width half-max of FWHM
% Convert to unit area by dividing by (sigma(SS).*sqrt(2*pi))
% See gaussian for unit-area version and gaussian_sigma for sigma input
% y=A * exp( -(x-mu)^2 / (2*sigma^2) )
% P = (1./(sigma.*(sqrt(2*p)))).*exp(-((w-mu).^2)./(2.*(sigma.^2)));
sigma = fwhm./(2.*sqrt(2.*log(2)));
P = gaussian_sigma(w,mu,sigma);
% P = exp(-((w-mu).^2)./(2.*(sigma.^2)));
