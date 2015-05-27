function [RawSpc] = RawIgm2RawSpc(RawIgm);
% Returns the complex raw spectra
% RawIgm is a structure with Header, x and y
if isfield(RawIgm,'Header')
RawSpc.Header = RawIgm.Header;
end
% Calibration of the spectral axis
%laser_freq 15799.7 1/cm
Laser_wn = 15799.7;
Laser_wl_cm = 1/laser_wn;
Laser_wl = Laser_wl_cm/100;
RawSpc.x = double(RawIgm.x)./Laser_wl./length(RawIgm.x);

% Fourier transform
RawSpc.y = fftshift(RawIgm.y, 2);
RawSpc.y = fft(RawSpc.y, [], 2);
RawSpc.y = fftshift(RawSpc.y, 2);