function [x_,y_,Idc_pc] = RawIgm2RawSpc(x,y,laser_wl,laser_wn);
%  [x_,y_,Idc_pc] = RawIgm2RawSpc(x,y,laser_wl,laser_wn);
% RawIgm2RawSpc expects igms with zpd at 0th index
% Returns the complex raw spectra and Idc_pc, the zpd intensity computed 
% with phase correction (inverse fft of abs magnitude spectrum)


%  (a) capture the sign of the Vdc value at ZPD,
%  (b) convert the interf to a spectrum,
%  (c) transform the complex spectrum into a magnitude spectrum,
%  (d) convert the magnitude spectrum back to an interf,
%  (e) determine the magnitude of the Vdc at ZPD, and
%  (f) assign the magnitude the sign of the value determined in step (a).


% assist.chB.laser_wl = 1./1.579990e4;    % from Andre
% 
% assist.chA.laser_wn = 1./assist.chA.laser_wl; % wavenumber in 1/cm

% [x_,y_,x,y] = RawIgm2RawSpc(x,y,laser_wl,laser_wn);
if ~exist('laser_wl', 'var')
   laser_wl = 632.8e-7;    % He-Ne wavelength in cm
   laser_wn = 1./laser_wl; % wavenumber in 1/cm
end
if ~exist('laser_wn', 'var')
   laser_wn = 1./laser_wl;
end
dim_n = find(size(y)==length(x));
RawSpc.x = double(x).*laser_wn./length(x);

% Fourier transform
RawSpc.y = fft(y,[],dim_n);
y_sign = y(:,1)./abs(y(:,1)); 
Idc_pc = ifft(abs(RawSpc.y),[],dim_n);
Idc_pc = Idc_pc(:,1).*y_sign;

pos = x>=0;
x_ = RawSpc.x(pos);
% x = RawSpc.x;
y_ = RawSpc.y(:,pos);
% y = RawSpc.y;
%  (a) capture the sign of the Idc value at ZPD, 
%  (b) convert the interf to a spectrum,
%  (c) transform the complex spectrum into a magnitude spectrum, 
%  (d) convert the magnitude spectrum back to an interf, 
%  (e) determine the magnitude of the Idc at ZPD, and 
%  (f) assign the magnitude the sign of the value determined in step (a).  
return
