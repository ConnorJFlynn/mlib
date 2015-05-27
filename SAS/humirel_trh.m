function [T_C,rh] = humirel_trh(V_T,V_rh,V_cc);
% [T_C,rh] = humirel_trh(V_T,V_rh,V_cc);
% RH (V) and T (nsd) sensor
% Compute temperature first since RH has a temperature correction term
% RH computation requires determination of NTC resistance as below:
%%
NTC = (V_T .*10e3)./(V_cc - V_T);
A = 9.70316e-4; 
B = 2.42958e-4;
C = 9.97697e-7;
D = 7.85757e-8;
over_T = A + B.*log(NTC) + C.*(log(NTC)).^2 + D.*(log(NTC)).^3;
T_C = (1./over_T)-273.15;

% rh_ref = 100.*[.1:.01:1];
% Vrh_ref = (1.05e-3 .* (rh_ref.^3) - 1.76e-1 .* (rh_ref.^2) + 35.2.*rh_ref + 898.6)./1000;
% rh_poly = interp1(Vrh_ref, rh_ref, V_rh, 'linear','extrap');
rh = (1000.*V_rh-1006)./26.65;
% T_corr = (1-(T_C -23).*2.4e-3);
% rh = rh .* T_corr;

%%
return