function [RawSpc] = RawIgm2RawSpc2(RawIgm,F)
% Usage: [RawSpc] = RawIgm2RawSpc2(RawIgm,F)
% Requires raw igram
% Optional boolean F 
% Returns the complex raw spectra
% RawIgm is a structure with Header, x and y
% Shifts spectra to place detected zpd peak at beginning (and end).
if ~exist('F','var')
   F = true([size(RawIgm.y,1),1]);
end
if ~islogical(F)
   tmp = F;
   F = false(size(Rawigm.x));
   F(tmp) = true;
end
if isfield(RawIgm,'Header')
RawSpc.Header = RawIgm.Header;
end
% Calibration of the spectral axis
if ~isfield(RawIgm,'laser_wn')
   Laser_wl = 632.8e-7;
   RawIgm.laser_wn = 1./Laser_wl;
end
% Laser_wl = 632.8e-7;
% Laser_wl_cm = 1/Laser_wn;
% RawSpc.x = RawIgm.x ./ Laser_wl ./ length(RawIgm.x);
% RawSpc.x = RawIgm.x .* laser_wn ./ length(RawIgm.x);

% I think the 1/2 index offset is erroneous
% RawSpc.x = (0.5+double(RawIgm.x)).*RawIgm.laser_wn./length(RawIgm.x);
RawSpc.x = double(RawIgm.x).*RawIgm.laser_wn./length(RawIgm.x);
% RawSpc.x = double(RawIgm.x).*laser_wn./length(RawIgm.x);
pos = RawIgm.x>=0;
RawSpc.x = RawSpc.x(pos);
% Fourier transform
[rows,cols] = size(RawIgm.y);
%Modification below was necessary to use 1-D fftshift rather than 2-D
%matrix version.
if ~isfield(RawIgm, 'zpd_loc')
   no_loc = true;
   RawIgm.zpd_loc = ones(size(RawIgm.y,1)).*(length(RawIgm.x)./2);
Igm_F.x = RawIgm.x; 
Igm_F.y = RawIgm.y(F,:);
RawIgm.zpd_loc(F) = find_zpd(Igm_F);
end
zpd_F = mode(RawIgm.zpd_loc(F));
for r = fliplr(find(F))
ingram = RawIgm.y(r,:);
[ingram_] = zpd2end(ingram,zpd_F);
% M = min([zpd-1, (length(ingram)-zpd)]);
% ingram_ = zeros(size(ingram)); %holder for shifted igram
% ingram_(1:M+1) = ingram(zpd:zpd+M);
% ingram_(end-M:end) = ingram(zpd-M:zpd);
% ingram = [ingram(zpd:end),ingram(1:zpd-1)];
RawSpc.y(r,:) = fftshift(fft(ingram_, [], 2), 2);
% The apodization window is applied over a range defined by ZPD+-M, 
% where M is the minimum of R and L. R is the number of points on Right 
% side of ZPD, and L is the number of points on Left side of ZPD. 
% L is just equal to ZPD, and R is the igram length minus the ZPD position. 
% RawSpc.y(r,:) = fftshift(fft(fftshift(RawIgm.y(r,:), 2), [], 2), 2);
%%
% RawSpc.y(r,:) = fftshift(fft(fftshift(ingram,2), [], 2), 2);
% figure(1);
% ax(1) = subplot(2,1,1);
% plot(RawSpc.x, [abs(RawSpc.y(r,pos));real(RawSpc.y(r,pos));imag(RawSpc.y(r,pos))],'-');
% legend('abs','real','imag');
% ax(2) = subplot(2,1,2);
% plot(RawSpc.x, [100.*imag(RawSpc.y(r,pos))./abs(RawSpc.y(r,pos)); mod(180.*(angle(RawSpc.y(r,pos)))./pi,90)],'.');
% legend('% imag','degrees');
% linkaxes(ax,'x');
%%
% figure(2);
% axx(1) = subplot(2,1,1);
% plot(RawSpc.x, [abs(RawSpc.y_(r,pos));real(RawSpc.y_(r,pos));imag(RawSpc.y_(r,pos))],'-');
% legend('abs','real','imag');
% axx(2) = subplot(2,1,2);
% % plot(RawSpc.x, [100.*imag(RawSpc.y_(r,pos))./abs(RawSpc.y_(r,pos)); mod(180.*(angle(RawSpc.y_(r,pos)))./pi,90)],'.');
% % legend('% imag','degrees');
% plot(RawSpc.x, [100.*imag(RawSpc.y_(r,pos))./abs(RawSpc.y_(r,pos))],'.');
% legend('% imag');
% 
% linkaxes(axx,'x');

%%
end

notF = fliplr(find(~F));
if ~isempty(notF)
   if no_loc
   Igm_R.x = RawIgm.x;
   Igm_R.y = RawIgm.y(~F,:);
   RawIgm.zpd_loc(~F) = find_zpd(Igm_R);
end
zpd_R = mode(RawIgm.zpd_loc(~F));
   for r = notF
      ingram = RawIgm.y(r,:);
      [ingram_] = zpd2end(ingram,zpd_R);
      RawSpc.y(r,:) = fftshift(fft(ingram_, [], 2), 2);
      %%
      % % RawSpc.y(r,:) = fftshift(fft(fftshift(ingram,2), [], 2), 2);
      % figure(1);
      % ax(1) = subplot(2,1,1);
      % plot(RawSpc.x, [abs(RawSpc.y(r,pos));real(RawSpc.y(r,pos));imag(RawSpc.y(r,pos))],'-');
      % legend('abs','real','imag');
      % ax(2) = subplot(2,1,2);
      % plot(RawSpc.x, [100.*imag(RawSpc.y(r,pos))./abs(RawSpc.y(r,pos)); mod(180.*(angle(RawSpc.y(r,pos)))./pi,90)],'.');
      % legend('% imag','degrees');
      % linkaxes(ax,'x');
      %%
   end
end
% close(gcf);
% RawSpc.y = fftshift(fft(fftshift(RawIgm.y, 2), [], 2), 2);
%%
RawSpc.y = RawSpc.y(:,pos);
