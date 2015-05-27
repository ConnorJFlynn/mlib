function R_MHz = apply_generic_dtc(D_MHz)
% R_MHz = apply_generic_dtc(D_MHz)
% max D_MHz of 14.5
% 
% fin = isfinite(D_MHz)&(D_MHz>0);
D_kHz = 1000*D_MHz;
logD = real(log10(D_kHz));
dtc = real(logR_dtc(logD));
% dtc(fin) = real(logR_dtc(real(log10(1000*D_MHz(fin)))));
R_MHz = D_MHz .* dtc;
no = R_MHz < D_MHz;
R_MHz(no) = D_MHz(no);