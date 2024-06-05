function corr = hsrl_raycor(range)
% Empirical correction derived from the molecular channel in a clean region to
% recover correct range dependence.  Probably correcting for misalignment
% I may have used Tablecurve to fit the ratio between the computed
% Molecular_Backscatter_Coefficient and the measured Molecular_Backscatter_Channel
corr = (.96662551 + 574.01181./range).^2;
end