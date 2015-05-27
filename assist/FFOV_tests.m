%% Working with AERI FFOV correction...
xx = x.*laser_wl;
df = 1./(laser_wl.*length(x))
ff = x.*df; 
FF = fftshift(ff); % freq with zpd at i=1
XX = fftshift(xx);  %zpd at i=1
yy = y(5,:); % igm with zpd at i = 1.
%%
figure; plot(XX,real(yy))
%%
YY = fft(yy); % spectra with zero ff at i = 1
% ff = (x).*laser_wn./length(x);
figure; 
subplot(2,1,1); 
plot(real(YY));
subplot(2,1,2);
plot(FF,real(YY));

CC = YY;
%%
C1_v = fft((FF.^2).*CC);
C1_x = ifft(XX.^2 .* C1_v);
k1 = ((2.*pi.*((.016.^2)./4)).^2) ./6;
C1 = k1.*(C1_x);
C2_v = fft((FF.^4).*CC);
C2_x = ifft(XX.^4 .* C2_v);
k2 = ((2.*pi.*((.016.^2)./4)).^4) ./720;
C2 = k2.*(C2_x);
figure;
s(1)=subplot(3,1,1);
plot(FF,real(CC))
s(2)=subplot(3,1,2)
plot(FF,100.*real(C1)./real(CC),'m-')
s(3)=subplot(3,1,3)
plot(FF,100.*real(C2)./real(CC),'m-')

linkaxes(s,'x');

%%
