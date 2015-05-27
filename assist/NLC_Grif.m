function [y_,A] = NLC_Grif(x,y_,laser_wl,laser_wn);
% [y,A] = NLC_Grif(x,y_,laser_wl,laser_wn);
% y_ is raw ifg
% x is 
% y is complex spectra with Griffith's NLC applied
% A is 3-component vector adjustments to zpd, zpd+/-1 igram values
if ~exist('laser_wl', 'var')
   laser_wl = 632.8e-7;
   laser_wn = 1./laser_wl;
end
if ~exist('laser_wn', 'var')
   laser_wn = 1./laser_wl;
end
wn = double(x).*laser_wn./length(x);
tmp = y_;
y = fft(y_,[],2);
y = fftshift(y,2);

% Fourier transform
% y = fftshift(fft(fftshift(RawIgm.y, 2), [], 2), 2);
x_300 = wn>=250 & wn<=350;
x_2000 = wn>=1900 & wn<=2100;
x_2500 = wn>=2200 & wn<=2700;
Re_300 = real(mean(y(:,x_300),2));
Re_2000 = real(mean(y(:,x_2000),2));
Re_2500 = real(mean(y(:,x_2500),2));
Im_300 = imag(mean(y(:,x_300),2));
Im_2000 = imag(mean(y(:,x_2000),2));
Im_2500 = imag(mean(y(:,x_2500),2));
a_300 = 2*pi*300/15803;
a_2000 = 2*pi*2000/15803;
a_2500 = 2*pi*2500/15803;
% for a < 3950:

B = [-1, -cos(a_2500), -cos(a_2500); -1, -cos(a_2000), -cos(a_2000); 0, sin(a_300), -sin(a_300)]; 
Y = [Re_2500, Re_2000, Im_300]'; 
A = (B\Y)';

y_(:,1:2) = y_(:,1:2) + A(:,2:3);
y_(:,end) = y_(:,end) + A(:,1);
%%
f = A ./ y_(:,[1,2,end]);
%%

% figure; plot(x, y,'.b-',...
%    x(zpd_ind-1:zpd_ind+1), y_(zpd_ind-1:zpd_ind+1),'ro')

return
