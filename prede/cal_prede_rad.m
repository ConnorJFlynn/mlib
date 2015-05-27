function prede = cal_prede_rad(prede);
% Applies radiance calibration to Prede based on NASA Ames 30" sphere
% Eventually this calibration should be time-dependent

% y = NasaAmesSphere(xx)
means = [1.615e-012 3.761e-010 3.889e-009 2.043e-008 2.693e-008 3.504e-008 3.187e-008];
wl = [315; 400; 500; 675; 870; 940; 1020]';
rad = NasaAmesSphere(wl); % Probably want to patch a blackbody curve onto the short wavelength end.
% resp = cnts per W
% cal = W per cnt
cal = rad ./ means;
for f = 2:7
   prede.(['skyrad_filter_',num2str(f)]) = prede.(['filter_',num2str(f)]).* cal(f);
end