function [P,sigma] = gaussian(w, cw, FWHM);
% [P,sigma] = gaussian(w, cw, FWHM);
% Gaussian profile with unit area centered on cw with full-width half-max of FWHM
% See gaussian_fwhm and gaussian_sigma for unit-height variants
[P,sigma] = gaussian_fwhm(w, cw, FWHM);
P = (1./(sigma.*(sqrt(2*pi)))).*P;