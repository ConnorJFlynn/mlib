function WBOF = WBOF_noscat(WBO, SSA);
% WBOF = WBOF_noscat(WBO, SSA);
% Weiss/Bond/Ogren/Flynn corrections assuming a given WBO (filter-loading
% correction) and SSA (with corresponding scattering correction)

% Ba = Ba_raw*WBO -  0.0164.* Bs
%  Bx = Bs + Ba
%  Bs/Bx + Ba/Bx  = 1
%  SSA = Bs/Bx , COA = Ba/Bx
%  SSA/COA = Bs/Ba
% Ba = Ba_raw*WBO -  0.0164.* Ba * SSA/COA
% Ba (1+0.0164*SSA/COA) = Ba_raw*WBO
% Ba = Ba_raw * WBO/(1+0.0164*SSA/COA)
% ==> WBOF = WBO/(1+0.0164*SSA/COA)

COA = 1-SSA;
WBOF = WBO./(1+.0164*WBO.*SSA./COA);

return