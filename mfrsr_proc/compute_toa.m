function toa = compute_toa(nm, T); 
%Computes TOA under envelope of T
% Normalizes area under T to unity
area = trapz(nm, T);
T = T/area; % Normalize to unity area;
load guey
 guey_esr = interp1(guey(:,1), guey(:,2), nm, 'pchip',0);
 toa = trapz(nm, T .* guey_esr);