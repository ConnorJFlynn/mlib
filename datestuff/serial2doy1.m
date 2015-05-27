function [doy1] = serial2doy1(serial);
%[doy1] = serial2doy1(serial);
%Returns the day of year corresponding to the supplied serial date.  Jan 1 = 1;
% This function is identical to the deprecated serial2jd1
dv = datevec(serial);
year = zeros(size(serial));
year(:) = datenum(dv(:,1),1,0);
%    year = datestr(serial(1),10);  %Returns the year of the serial date
%    year = datenum(str2num(year),1,0);       %Converts the string returned from datestr into a number
doy1 = serial - year;

