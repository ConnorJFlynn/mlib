function delta_GHz = bandpass_GHz(lambda_nm, delta_nm);
% delta_wn = bandpass_GHz(lambda_nm, delta_nm);
% Returns the delta in wavenumbers corresponding to a width in nm about a
% central wavelength at lambda_nm

% delta_wn = (1./lambda_cm.^2).*delta_cm
% ==> delta_wn = (1e7.delta_nm./lambda_nm.^2);
% delta_wn = (1e7.*delta_nm./lambda_nm.^2);
delta_wn = bandpass_wn(lambda_nm, delta_nm);
delta_GHz = 2.99792458e1.*delta_wn;
