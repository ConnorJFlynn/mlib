function [RawSpc] = RawIgm2GrfSpc(RawIgm,zpd_loc);
% Returns the complex raw spectra
% RawIgm is a structure with Header, x and y
if ~exist('zpd_loc','var')
   [zpd_ind,zpd_mag] = find_zpd_edgar(RawIgm);
%    [tmp,zpd_loc] = max(abs(RawIgm.y - mean(RawIgm.y)));
    zpd_loc = zpd_ind - length(RawIgm.x)./2-1;
    zpd_loc = mode(zpd_loc);
end
RawSpc.Header = RawIgm.Header;


% Calibration of the spectral axis
Laser_wl = 632.8e-7;
RawSpc.x = RawIgm.x/Laser_wl/length(RawIgm.x);
RawSpc.y = fft(zpd_circshift(RawIgm.x,RawIgm.y,-zpd_loc),[],2);
RawSpc.y = fftshift(RawSpc.y,2);

% Fourier transform
% RawSpc.y = fftshift(fft(fftshift(RawIgm.y, 2), [], 2), 2);
x_300 = RawSpc.x>=250 & RawSpc.x<=350;
x_460 = RawSpc.x>=440 & RawSpc.x<=480;
x_2000 = RawSpc.x>=1900 & RawSpc.x<=2100;
x_2300 = RawSpc.x>=2200 & RawSpc.x<=2400;
x_2500 = RawSpc.x>=2200 & RawSpc.x<=2700;
x_6000 = RawSpc.x>=5000 & RawSpc.x<=7000;
x_7850 = RawSpc.x>=7800 & RawSpc.x<=7900;
Re_300 = real(mean(RawSpc.y(x_300)));
Re_460 = real(mean(RawSpc.y(x_460)));
Re_2000 = real(mean(RawSpc.y(x_2000)));
Re_2300 = real(mean(RawSpc.y(x_2300)));
Re_2500 = real(mean(RawSpc.y(x_2500)));
Re_6000 = real(mean(RawSpc.y(x_6000)));
Re_7850 = real(mean(RawSpc.y(x_7850)));
Im_300 = imag(mean(RawSpc.y(x_300)));
Im_460 = imag(mean(RawSpc.y(x_460)));
Im_2000 = imag(mean(RawSpc.y(x_2000)));
Im_2300 = imag(mean(RawSpc.y(x_2300)));
Im_2500 = imag(mean(RawSpc.y(x_2500)));
Im_6000 = imag(mean(RawSpc.y(x_6000)));
Im_7850 = imag(mean(RawSpc.y(x_7850)));
a_300 = 2*pi*300/15803;
a_460 = 2*pi*460/15803;
a_2000 = 2*pi*2000/15803;
a_2300 = 2*pi*2300/15803;
a_2500 = 2*pi*2500/15803;
a_6000 = 2*pi*6000/15803;
a_7850 = 2*pi*7850/15803;
% for a < 3950:
%     Re_a = [-1, -cos(a), -cos(-a)] = [-1, -cos(a), -cos(a)]
%     Im_a = [0 , sin(a) + sin(-a)] = [0, sin(a), -sin(a)]

B1 = [-1, -cos(a_300), -cos(a_300); -1, -cos(a_2300), -cos(a_2300); 0, sin(a_2300), -sin(a_2300)]; 
Y1 = [Re_300; Re_2300; Im_2300]; X1 = B1\Y1;

B2 = [-1, -cos(a_300), -cos(a_300); -1, -cos(a_460), -cos(a_460); 0, sin(a_2300), -sin(a_2300)]; 
Y2 = [Re_300; Re_460; Im_2300]; X2 = B2\Y2;

B3 = [-1, -cos(a_300), -cos(a_300); -1, -cos(a_2000), -cos(a_2000); 0, sin(a_300), -sin(a_300)]; 
Y3 = [Re_300; Re_2000; Im_300]; X3 = B3\Y3;

B4 = [-1, -cos(a_2300), -cos(a_2300); -1, -cos(a_2000), -cos(a_2000); 0, sin(a_300), -sin(a_300)]; 
Y4 = [Re_2300; Re_2000; Im_300]; X4 = B4\Y4;

B5 = [-1, -cos(a_2500), -cos(a_2500); -1, -cos(a_2000), -cos(a_2000); 0, sin(a_300), -sin(a_300)]; 
Y5 = [Re_2500; Re_2000; Im_300]; X5 = B5\Y5;

B6 = [-1, -cos(a_300), -cos(a_300); -1, -cos(a_2000), -cos(a_2000); -1, -cos(a_2500),...
   -cos(a_2500); 0, sin(a_300), -sin(a_300)]; 
Y6 = [Re_300; Re_2000; Re_2500; Im_300]; 
X6 = B6\Y6;

% RawIgm.y1 = RawIgm.y;
% RawIgm.y2 = RawIgm.y;
% RawIgm.y3 = RawIgm.y;
% RawIgm.y4 = RawIgm.y;
RawIgm.y5 = RawIgm.y;
RawIgm.y6 = RawIgm.y;
% RawIgm.y1(zpd_ind-1:zpd_ind+1) = RawIgm.y1(zpd_ind-1:zpd_ind+1) + X1';
% RawIgm.y2(zpd_ind-1:zpd_ind+1) = RawIgm.y2(zpd_ind-1:zpd_ind+1) + X2';
% RawIgm.y3(zpd_ind-1:zpd_ind+1) = RawIgm.y3(zpd_ind-1:zpd_ind+1) + X3';
% RawIgm.y4(zpd_ind-1:zpd_ind+1) = RawIgm.y4(zpd_ind-1:zpd_ind+1) + X4';

RawIgm.y5(zpd_ind-1:zpd_ind+1) = RawIgm.y5(zpd_ind-1:zpd_ind+1) + X5';
RawIgm.y6(zpd_ind-1:zpd_ind+1) = RawIgm.y6(zpd_ind-1:zpd_ind+1) + X6';


figure; plot(RawIgm.x, RawIgm.y,'.b-',...
   RawIgm.x(zpd_ind-1:zpd_ind+1), RawIgm.y5(zpd_ind-1:zpd_ind+1),'ro',...
   RawIgm.x(zpd_ind-1:zpd_ind+1), RawIgm.y6(zpd_ind-1:zpd_ind+1),'ko')

%%


% RawSpc.y1 = fftshift(fft(zpd_circshift(RawIgm.x,RawIgm.y1,-zpd_loc),[],2),2);
% RawSpc.y2 = fftshift(fft(zpd_circshift(RawIgm.x,RawIgm.y2,-zpd_loc),[],2),2);
% RawSpc.y3 = fftshift(fft(zpd_circshift(RawIgm.x,RawIgm.y3,-zpd_loc),[],2),2);
% RawSpc.y4 = fftshift(fft(zpd_circshift(RawIgm.x,RawIgm.y4,-zpd_loc),[],2),2);
RawSpc.y5 = fftshift(fft(zpd_circshift(RawIgm.x,RawIgm.y5,-zpd_loc),[],2),2);
RawSpc.y6 = fftshift(fft(zpd_circshift(RawIgm.x,RawIgm.y6,-zpd_loc),[],2),2);

figure; 
s(1) = subplot(2,1,1);
plot(RawSpc.x,real([(RawSpc.y);(RawSpc.y5);(RawSpc.y6)]),'-');
legend('0','5','6');
s(2) = subplot(2,1,2);
plot(RawSpc.x,imag([(RawSpc.y);(RawSpc.y5);(RawSpc.y6)]),'-');
%%
%%
mods5 = zeros(size(RawIgm.y));
mods5(zpd_ind-1:zpd_ind+1)=X5';
mods6 = zeros(size(RawIgm.y));
mods6(zpd_ind-1:zpd_ind+1)=X6';

spc5 = fftshift(fft(zpd_circshift(RawIgm.x,mods5,-zpd_loc),[],2),2);
spc6 = fftshift(fft(zpd_circshift(RawIgm.x,mods6,-zpd_loc),[],2),2);
figure; plot(RawSpc.x,fftshift(abs(spc5)),'k-',RawSpc.x,fftshift(real(spc5)),'b-',...
   RawSpc.x,fftshift(abs(spc6)),'g-',RawSpc.x,fftshift(real(spc6)),'r-');
legend('abs 5','real 5','abs 6','real 6')
%%

figure; plot(RawSpc.x,[abs(RawSpc.y);real(RawSpc.y);imag(RawSpc.y)],'-',...
   RawSpc.x,[abs(RawSpc.y);real(RawSpc.y);imag(RawSpc.y)],'-');
legend('abs','real','imag');
xlim([200,2000]);

return
