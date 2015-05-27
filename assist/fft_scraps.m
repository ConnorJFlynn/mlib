% Examining FFT zero-pad and truncation
% Effect on real/imag components, ringing, resolution
% Also, looking at meaning of zpd location 

% start with a pure cosine function.  Take FFT
N = 50;
x = [-180:179];
pure_cos = cos(N.*x.*pi./180)+.5;
shifted_cos = fftshift(pure_cos);

fft_shifted_cos = fft(shifted_cos);
reshifted = fftshift(fft_shifted_cos);

figure; subplot(2,1,1);
plot(x,pure_cos,'b',x,shifted_cos,'r');
subplot(2,1,2);
pos = x>=0;
plot(x(pos),real(reshifted(pos)),'-ko',x(pos),imag(reshifted(pos)),'c-');
title({'Demonstrates that first element is for zeroth frequency so the x-axis';...
   'should be scaled to integer values, not half-integer values'})

%%
recover = fftshift(fft(fft_shifted_cos));
subset = [1:60,length(x)-60+1:length(x)];
recover_truncd = fftshift(fft(fft_shifted_cos(subset)));
recover_degraded = fftshift(fft(fft_shifted_cos.*([ones([1,60]),zeros([1,240]),ones([1,60])])));
%%

figure; plot(x,real(recover)./length(x),'b',x,pure_cos,'r.',...
    x(1:3:end),recover_truncd./length(x),'-gx', ...
    x,recover_degraded./length(x), '--mo');
legend('real(recover)','pure cosine','recover truncd','recover degraded')
%Next, play with zeropadding.
% Hmm... It's not clear that truncating the igram yield any different
% effect than simply subsampling the spectra.  Not as good as averaging in
% the spectral domain since averaging benefits from incoherent cancellation
% of noise.  But possibly won't introduce biases.
%%
figure; plot(x,real(recover)./length(x)-recover_degraded./length(x), '--mo');
legend('real(recover) - recover degraded')
%%
% Re-examine effect of shifting zeropadded igram.  Is there any benefit at
% all?  
% Take fft of igm, zero pad the result, and then take fft again to get an
% oversampled igm.  
% unflipped is our original igm
% zpd_shift_F is our anticipated best shift
%shift_0 is the complex spectra of unflipped computed after unflipped is
%shifted to place the zpd a the first (zeroth) index.
shift_0_ifft = ifft(fftshift(sideshift(assist.chA.x,unflipped,0))).*sqrt(length(assist.chA.x));
shift_0_fft = fft(fftshift(sideshift(assist.chA.x,unflipped,0)))./sqrt(length(assist.chA.x));
figure; plot(assist.chA.x,real(shift_0_fft),'.r-',assist.chA.x,real(shift_0_ifft),'-ko');
legend('fft','ifft')
%%
all_fft = [ifft(shift_0_fft).*sqrt(length(assist.chA.x));...
   fliplr(fft(shift_0_fft)./sqrt(length(assist.chA.x)))];
figure; plot(assist.chA.x,all_fft ,'-',assist.chA.x,fftshift(unflipped),'.');
legend('1','2','fftshifted(unflipped)');

%Conclusion is to use ifft in tandem with fft to avoid one-element offset.
%Real parts are identical, imaginary parts have opposite sign

%%

M = 0;
padded_0 = [shift_0(1:length(shift_0)/2),repmat(zeros(size(shift_0)),1,M),shift_0([1+(length(shift_0)/2):end])];
padded.igm = fliplr(fftshift(fft(padded_0)));
padded.x = ([1:length(padded.igm)]-length(padded.igm)./2)./(M+1);
figure; plot(assist.chA.x,unflipped,'.r-',padded.x,padded.igm./length(assist.chA.x),'-ko');
%%
disp(['old shift:',num2str(zpd_shift_F)]);
pad_shift = find_zpd_xcorr(padded.igm);
disp(['Padded shift:',num2str(pad_shift)]);
%%
comp_rat_0 = imag(shift_0)./real(shift_0);

padshift_0 = fft(fftshift(sideshift(padded.x,padded.igm,pad_shift)));
comp_padrat_0 = imag(padshift_0)./real(padshift_0);


%%
padshift_n2 = fft(fftshift(sideshift(padded.x,padded.igm,pad_shift-2)));
padshift_n1 = fft(fftshift(sideshift(padded.x,padded.igm,pad_shift-1)));

padshift_p1 = fft(fftshift(sideshift(padded.x,padded.igm,pad_shift+1)));
padshift_p2 = fft(fftshift(sideshift(padded.x,padded.igm,pad_shift+2)));

comp_padrat_n2 = imag(padshift_n2)./real(padshift_n2);
comp_padrat_n1 = imag(padshift_n1)./real(padshift_n1);
comp_padrat_p1 = imag(padshift_p1)./real(padshift_p1);
comp_padrat_p2 = imag(padshift_p2)./real(padshift_p2);

%%
figure; s(1) = subplot(2,1,1);
lines = plot(assist.chA.x,[comp_rat_0;comp_rat_4;comp_rat_5;comp_rat_6],'-');
recolor(lines,[0,4,5,6]);colorbar
s(2) = subplot(2,1,2);
lines = plot(padded.x,[comp_padrat_n2;comp_padrat_n1;comp_padrat_0;...
   comp_padrat_p1;comp_padrat_p2],'-');
recolor(lines,[-2:2]);colorbar
linkaxes(s,'x')
%%

shift_4 = fft(fftshift(sideshift( assist.chA.x,unflipped,4)));
shift_5 = fft(fftshift(sideshift( assist.chA.x,unflipped,5)));
shift_6 = fft(fftshift(sideshift( assist.chA.x,unflipped,6)));
comp_rat_4 = imag(shift_4)./real(shift_4);
comp_rat_5 = imag(shift_5)./real(shift_5);
comp_rat_6 = imag(shift_6)./real(shift_6);
%%
figure; lines = plot(assist.chA.x,[comp_rat_0;comp_rat_4;comp_rat_5;comp_rat_6],'-');
recolor(lines,[0,4,5,6]);
colorbar;
axis(v);
