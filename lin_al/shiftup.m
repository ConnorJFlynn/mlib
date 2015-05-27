function [N] = shiftup(n);
%usage [N] = shiftup(n);
N = bin2dec([dec2bin(n) '0']);
