function [P,FWHM] = gaussian_sigma(w, mu, sigma);
% [P,FWHM] = gaussian(w, mu, sigma);
% Gaussian profile with unit height centered on mu having 
%   FWHM = sigma.*(2.*sqrt(2.*log(2)));
% Convert to unit area by dividing by (sigma.*sqrt(2*pi))
% See gaussian for unit-area version and gaussian_fwhm for FWHM input
% y=A * exp( -(x-mu)^2 / (2*sigma^2) )
% P = (1./(sigma.*(sqrt(2*pi)))).*exp(-((w-mu).^2)./(2.*(sigma.^2)));

FWHM = sigma.*(2.*sqrt(2.*log(2)));
P = exp(-((w-mu).^2)./(2.*(sigma.^2)));

