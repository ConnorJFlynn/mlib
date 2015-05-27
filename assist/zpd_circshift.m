function [y] = zpd_circshift(x,y,shift_zpd);
% Usage: [y] = zpd_circshift(x,y,shift_zpd)
% Similar to fftshift except:
% 1. Centers the supplied igm.y by shifting by shift_zpd
% 2. Swap the centered igm about the center

dim_n = find(size(y)==length(x));
shift_ind = zeros(size(size(y)));
shift_ind(dim_n) = shift_zpd;
y = circshift(y,shift_ind);
y = fftshift(y,dim_n);

return
