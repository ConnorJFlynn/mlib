function delta_nm = nm_shift(lambda_nm, delta_wn);
% delta_nm = nm_shift(lambda_nm, delta_wn);
% Returns the shift in nm of a provided wavenumber shift (1/cm) relative to lambda (nm)
% Ei = h.*c/(lambda_nm*1e-9);
% Ef = Ei + h.*c.*delta_wn.*100;
% = h.*c .* (1./lambda*1e-9 + delta_wn * 100)
%lambda_f = h.*c/Ef = h.*c./(Ei + h.*c.*delta_wn*100)
%         = h.*c./(h.*c./lambda_nm*1e-9 + h.*c.*delta_wn*100)
lambda_f  = 1e7./(1./(lambda_nm*1e-7) + delta_wn)
delta_nm = lambda_f - lambda_nm;

