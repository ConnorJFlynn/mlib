function toa = compute_toa(nm, T); 
% Computes TOA (uW/cm2.nm) under envelope of T
% Normalizes area under T to unity
% Guey is initially in W/m2-nm
% We convert this to uW/cm2-nm by multiplying by 100.  This matches Aeronet
% units
area = trapz(nm, T);
T = T/area; % Normalize to unity area;
load guey

% "Synthetic/composite Extraterrestrial Spectrum by Chris Gueymard, May 2003"	
% "Reference: C. Gueymard, ""THE SUN‚S TOTAL AND SPECTRAL IRRADIANCE FOR SOLAR ENERGY APPLICATIONS AND SOLAR RADIATION MODELS"", submitted to Solar Energy, 2003."	
% "1st column: wavelength (nm) in vacuum below 280 nm, in air above 280 nm"	
% 2nd column: irradiance (W/m2 nm)	
% Number of wavelengths: 2460	
% "Resolution: variable, approximately equal to spectral step"	
% Total irradiance (solar constant)=1366.1 W/m2
guey_esr = interp1(guey(:,1), guey(:,2), nm, 'pchip',0);
toa = 100.*trapz(nm, T .* guey_esr);