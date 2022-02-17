function [cm] = ppv2cm(ppv, MW, P);
% [cm] = ppv2cm(ppv, MW, P);
% Convert column gas concentration in PPV (parts per volume) to cm
% default MW [g/mol] is O3 (= 47.9982 ~48 g/mol)
% CH4=16.043; H2O=18.0153; N2O=44.013;
% P [mbarr] is optional, default is 1013.25 mbar = 1.01325 bar = 1 atm. 
% This code assumed STP = 1013.25 mbarr at 0 deg C = 273.15 K
% and thus the molar volume of an ideal gas is 2.2414e4 cm^3 * atm / mol

if ~isavar('ppv')||ppv>1
    error('PPV is required <=1)')
    exit;
end
if ~isavar('MW')||isempty(MW)
    MW = 47.9982; % Default to O3
end
if ~isavar('P') || isempty(P) || P==1 || P == 760 || P == 1013.25;
    P = 1013.25; %Set to 1013.25mbar == 1 atm == 760 torr
end
% PV = nRT ==> V = nRT/P; 
R = 82.053 ; % [cm^3 atm / (K mol];
T = 273.15; % 0 C = 273.15 K
MV = 2.2414e4; % [cm^3 atm / mol]
if ppv < .1
    NpA = 1013.25./ MW; %[mol/cm^2]
else
end

cm_per_atm = ppv.*NpA.*MV;
if P == 1013.25;
    cm = cm_per_atm;
else
   cm = cm_per_atm .* P./1013.25;
end

%DU = cm .* 1000;

end