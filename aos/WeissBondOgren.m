function k_WBO = WeissBondOgren(Tr)
% Computes Weiss transfer function adjusted as per Bond99 and Ogren2010
% as summarized in Virkkula 2010 errata

% Weiss original:
% 1/(1.0796 Tr + 0.71)

% Bond adjustment:
% 1/1.22 * Weiss

% Ogren correction:
% 0.97.*.873 * Bond

k0 = 1.5557; k1 = 1.0227;

k_WBO = 1./(k0.*Tr + k1);

% 
return