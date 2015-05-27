function B = hexNtwo(hexmat)
% function B = hexNtwo(hexmat)
% usage: B = hexNtwo(A)
% A is matrix of dimension [row,col]
% B is generated of dimension [row,1]
% This function returns the twos complement of a 16-bit hex number
% represented by an n-character string.  
% (NOT case sensitive)
% Example for 4-character string:
%  32767 <---> '7FFF'
%  32766 <---> '7FFE'
%          :
%      0 <---> '0000'
%     -1 <---> 'FFFF'
%     -2 <---> 'FFFE'
%          :
% -32767 <---> '8001'
% -32768 <---> '8000'
if ~iscell(hexmat)
  [row,col] = size(hexmat);
else
    [row,col] = size(hexmat{1});
end
span = 16^col;

B = hex2dec(hexmat);
B(B>=span./2) = B(B>=span./2) - span ; 

return