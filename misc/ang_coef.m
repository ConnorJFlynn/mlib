function coef = ang_coef(coef, ang, old_wl, new_wl);
% new_coef = ang_coef(old_coef, ang, old_wl, new_wl);

 coef = coef .*((old_wl./new_wl).^ang);