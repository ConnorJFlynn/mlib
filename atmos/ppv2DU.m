function DU = ppv2DU(ppv, MW, P);
% DU = ppv2DU(ppv, MW, P);
% Convert column gas concentration in PPV (parts per volume) to DU
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

cm = ppv2cm(ppv,MW,P);
DU = 1000.* cm;

end