function T_K = BrightnessTemp_vs_nm(I,lambda_nm)

% I must be mW/m2/ster/cm
% ARCHI units: W(m^2.sr.um)
c1 = 1.191044e-5; %(mW/m2/ster/cm-4)
c2 = 1.438769; % (cm deg K))
lambda_cm = lambda_nm.*1e-7;
T_K = c2./(lambda_cm .* log(c1./(I.*lambda_cm.^5)+1));

return