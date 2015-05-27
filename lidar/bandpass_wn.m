function delta_wn = bandpass_wn(lambda_nm, delta_nm);
% delta_wn = bandpass_wn(lambda_nm, delta_nm);
% Returns the delta in wavenumbers corresponding to a shift in nm from an
% initial wavelength at lambda_nm

% delta_wn = (1./lambda_cm.^2).*delta_cm
% % ==> delta_wn = (1e7.delta_nm./lambda_nm.^2);
% delta_wn1 = (1e7.*delta_nm./lambda_nm.^2);
% 
% delta_wn2 = 1e7.*(1./(lambda_nm - delta_nm./2) - 1./(lambda_nm + delta_nm./2));
% delta_wn3 = 1e7.*(1./(lambda_nm - delta_nm) - 1./(lambda_nm));
delta_wn = 1e7.*(1./(lambda_nm) - 1./(lambda_nm + delta_nm));

%delta_GHz = (c./lambda_nm.^2).*delta_nm
