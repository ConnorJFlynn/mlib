function ang = ang_exp(coef_1, coef_2, wl_1, wl_2);
% ang = ang_exp(coef_1, coef_2, wl_1, wl_2)
ang = log(coef_1./coef_2)./log(wl_2./wl_1);
