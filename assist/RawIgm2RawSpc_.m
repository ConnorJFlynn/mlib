function [RawSpc] = RawIgm2RawSpc(RawIgm);
% Returns the complex raw spectra
% RawIgm is a structure with Header, x and y
if isfield(RawIgm,'Header')
RawSpc.Header = RawIgm.Header;
end
% Calibration of the spectral axis
% Laser_wl = 632.8e-7;
% % RawSpc.x = RawIgm.x/Laser_wl/length(RawIgm.x);
% 
% % Laser_wn = 15799.7;
% Laser_wn = RawIgm.laser_wn;
% Laser_wl_cm = 1/Laser_wn;
% 
% % RawSpc.x = double(RawIgm.x)./Laser_wl./length(RawIgm.x);
% RawSpc.x = double(RawIgm.x)./Laser_wl_cm./length(RawIgm.x);
if ~exist('laser_wn','var')
laser_wn = 1.580278e4;
laser_wn = laser_wn./1.00011659;
laser_wn = 15800.9378;
end
if ~isfield(RawIgm,'laser_wn')
   RawIgm.laser_wn = laser_wn;
end
% laser_wn = 1.57987e4;
% RawSpc.x = (0.5+double(RawIgm.x)).*RawIgm.laser_wn./length(RawIgm.x);
RawSpc.x = double(RawIgm.x).*RawIgm.laser_wn./length(RawIgm.x);
% RawSpc.x = double(RawIgm.x).*laser_wn./length(RawIgm.x);
pos = RawIgm.x>=0;
RawSpc.x = RawSpc.x(pos);
% Fourier transform
[rows,cols] = size(RawIgm.y);
for r = rows:-1:1
   RawSpc.y(r,:) = fftshift(fft(ifftshift(RawIgm.y(r,:), 2), [], 2), 2);
   
   
end   
% RawSpc.y = fftshift(fft(fftshift(RawIgm.y, 2), [], 2), 2);
%%

RawSpc.y = RawSpc.y(:,pos);
