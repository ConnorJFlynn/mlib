function [X_,Y_, ZPD,ZPD_raw] = ShiftIgm2RawSpc(x,y,laser_wl,laser_wn);
% [X_,Y_, ZPD,ZPD_raw] = ShiftRawIgm2RawSpc(x,y,laser_wl,laser_wn);
% ShiftIgm2RawSpc expects centered zpd and then applies fftshift to yield ZPD at 0th index.
% Returns the complex raw spectra and ZPD computed as the zeroth indice of
% the ingram (ZPD_raw) and as sign-preserved ifft(abs(fft(ingram)))
%Calibration of the spectral axis
% Applied DT magnitude spectra computation of ZPD
if ~exist('laser_wl', 'var')
   laser_wl = 632.8e-7;    % He-Ne wavelength in cm
   laser_wn = 1./laser_wl; % wavenumber in 1/cm
end
if ~exist('laser_wn', 'var')
   laser_wn = 1./laser_wl;
end
x = fftshift(x);
pos = x>=0;
X = double(x).*laser_wn./length(x);
X_ = X(pos);
dim_n = find(size(y)==length(x));
y = fftshift(y,dim_n);

% Fourier transform
% y = fftshift(y,dim_n); 
ZPD_raw = y(:,1);
y_sign = y(:,1)./abs(y(:,1)); 
Y_ = fft(y,[],dim_n);
ZPD = ifft(abs(Y_),[],dim_n);
ZPD = ZPD(:,1).*y_sign;
Y_ = Y_(:,pos);
return
