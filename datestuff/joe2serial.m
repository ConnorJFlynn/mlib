function time = joe2serial(joe)
%time = joe2serial(joe)
% joe is in fractional days since Jan 1, 1900.
% time is serial time days since Jan 1, 00 AD.
joe_base = datenum('Jan 01, 1900', 'mmm dd, yyyy');
time = joe_base + joe;

