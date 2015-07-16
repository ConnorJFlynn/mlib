 
function [serial] = igor2serial (igor_time)

% Converts igor time (seconds since Jan 1, 1904) to serial time (days since Jan 1, 0 AD).
%
%-------------------------------------------------------------------
 
DAYS_TO_1904 =  695422; % =datenum(1904,0,0) + 1
SEC_PER_DAY  = 86400;

index = (igor_time) ./ SEC_PER_DAY;
serial = double(index + DAYS_TO_1904);
return
