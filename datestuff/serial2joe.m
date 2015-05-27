function joe = serial2joe(serial)
%joe = serial2joe(serial)
% joe is in fractional days since Jan 1, 1900.
% time is serial time days since Jan 1, 00 AD.
% One day added to agree with Joe Michalsky's "joe-time" which treats
% Jan 1 = 1, so Jan at noon is 1.5. 
joe_base = datenum('Jan 01, 1900', 'mmm dd, yyyy');
% time = joe_base + joe;
joe = serial-joe_base +1;

