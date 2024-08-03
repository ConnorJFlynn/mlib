function IntVal = hex2two(hexstr)
% function IntVal = hex2two(hexstr)
% usage: Integer = twos('ABCD')
%
% This function returns the twos complement of a 16-bit hex number
% represented by a 4-character string.  
% (NOT case sensitive)
%
%  32767 <---> '7FFF'
%  32766 <---> '7FFE'
%          :
%      0 <---> '0000'
%     -1 <---> 'FFFF'
%     -2 <---> 'FFFE'
%          :
% -32767 <---> '8001'
% -32768 <---> '8000'

IntVal = hex2dec(hexstr) - 16.^(size(hexstr,2))*(hex2dec(hexstr)>=hex2dec('8000'));