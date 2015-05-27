function [P,P_sum] = gaussian_barnard(t,ct,fwhm)
% [P,P_sum] = gaussian_barnard(t,ct,fwhm)
% Returns a unit-height gaussian profile centered at ct with width FWHM.

gauss_factor = fwhm / 2.0 / sqrt(log(2.0));
delta_t   = abs(ct - t);
gauss_arg = delta_t ./ gauss_factor;
P  = exp(-1.0 .* gauss_arg .* gauss_arg);
P_sum = sum(P);
%%

%%

return