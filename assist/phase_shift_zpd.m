function zpd_ii = phase_shift_zpd(test_igm)
% [zpd_ii, zpd] = phase_shift_zpd(test_igm)
% finds phase shift that maximizes the integrated magnitude of real
% spectral component

len = length(test_igm); half = len./2;

% figure; plot([1:len]-half, abs(test_igm), '-'); 
win = half + [-127:128];
for ii = 32:-1:-31
   xx = ii+32;
   igm = test_igm(win+ii);   
   spc = real(fft(igm));
   sum_spc(xx) = sum(abs(spc));
end
[~,zpd_ii] = find(sum_spc==max(sum_spc)); zpd_ii = zpd_ii -32;
% figure; plot([1:64]-32,sum_spc,'r-',zpd,sum_spc(zpd+32),'ko')  
% figure;plot(fftshift(sideshift([1:len]-half,test_igm,zpd)),'-'); 
%  
% igm_shifted = sideshift([1:len]-half,test_igm,zpd);
% figure; plot(fftshift(igm_shifted),'-')
% abs_igm = abs(ifft(abs(fft(fftshift(igm_shifted)))));

return