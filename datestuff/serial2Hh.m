function [Hh] = serial2Hh(serial_date);
% [Jd] = serial2Hh(serial_date);
% This function accepts a serial date and returns date in Hh format 
% Hh is the hour of the day (00 - 23) plus the decimal fraction of an hour
% See also dateJd0, dateJd1, dateYy
if ~exist('serial_date','var')
    serial_date = [];
end
if ~all(size(serial_date))
    serial_date = [];
end
date_axes = serial2axes(serial_date);
Hh = date_axes.Hh;
