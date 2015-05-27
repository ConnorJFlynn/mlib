%%

% Subset of SAS spectra
% Should take AATS-14 filters, Cimel filters, MFRSR filters,...
filts.aerosol_mfrsr = [415, 500, 615, 673, 676, 870]; % MFRSR
filts.aerosol_bsrn = [365:371, 375:385, 408:417, 496:504, 605:618, 671:679, 774:782,860:873];
filts.aerosol_aats14 = [354, 380, 453, 499, 519, 604, 675, 778, 865, 1019, 1241, 1558, 2139];
filts.aerosol_cimel = [340, 380 440, 670, 870, 870, 1020];
% filts.O2Aband = [760];
filts.pwv = [936, 940, 941];
% liq_ice_abs = [1100,1300]
%%
filts.aerosol = sort([filts.aerosol_aats14, filts.aerosol_bsrn,filts.aerosol_cimel, filts.aerosol_mfrsr]);

%%
% Spectroradiometry processing:
% Wavelength registration:
%   First apply nominal responsivities to remove general wavelength
%   dependence. Maybe de-trend?  Both of these are designed to reduce or
%   eliminate apparent shifts in peak location caused by baseline slope.
%   Approaches: Manual: visually identify a number of identifiable peaks or
%   dips assocaited with either Fraunhoffer lines (peaks) or molecular
%   absorption lines (dips).  Compute polynomial fits of the published
%   wavelengths versus the pixel number.  Possibly more accurate would be
%   to identify some smooth features by shape and use xcorr to find the
%   optimal shift.  This may be complicated by stretching.