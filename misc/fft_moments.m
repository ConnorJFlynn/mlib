function mom = fft_moments(t_axis, M);
% mom = fft_moments(t_axis, M);
% Returns a sorted list of moments from the FFT of M over the t_axis.
% t_axis is expected to be a serial date. Moments are reported in Hz.
% mom.f = frequency in Hz
% mom.sorted_amp = sorted FFT amplitudes
% mom.abs_amp = FFT absolute magnitudes
% mom.freq_sorted_amp = frequency of sorted amplitudes
% mom.fft_M
fft_M = fft(M);
dt = diff(t_axis([1 end]))*24*60*60;
intv = [2:(length(t_axis)/2 -1)];
fft_M = fft_M(intv);

f = intv./dt;
[mom.abs_amp,ind] = sort(abs(fft_M),2,'descend');
mom.f = f;
mom.sorted_amp = fft_M(ind);
mom.freq_sorted_amp = f(ind);
mom.fft_M = fft_M;
mom.P = 1./f;

%%
%  figure; plot(1./f, abs(fft_M), '-b.');xlabel('Period [s]');
 %%

return