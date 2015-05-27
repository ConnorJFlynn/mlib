function [y] = shift_x(y,L);
% Usage: [y] = shift_x(y,L)
% Similar to sideshift except values shifted off the end are not rotated 
% to the other end.  Zeros are added to the opposite end. 
% shift_x([1 2 3 4], 2) yields [3 4 0 0]
% Could/should be generalized to handle matrices, and to select dim

L = abs(L);
yi = zeros(size(x));
if L>0
   yi(1+L:end) = y(1:end-L);
else
   L = abs(L);
   yi(1:end-L) = y[1+L:end];
end

return
