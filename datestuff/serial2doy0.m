function [doy0] = serial2doy0(serial);
%[doy0] = serial2doy0(serial);
%Returns the day of year corresponding to the supplied serial date.  Jan 1 = 0;
% This convention appears to be at odds with prevailing practice.
% This function is identical to the deprecated serial2jd0
disp(['serial2doy0 appears to be at odds with established convention.  Recommend serial2doy1.'])

dv = datevec(serial);
year = datenum(dv(:,1),1,1);
%    year = datestr(serial(1),10);  %Returns the year of the serial date
%    year = datenum(str2num(year),1,0);       %Converts the string returned from datestr into a number
doy0 = serial - year';

