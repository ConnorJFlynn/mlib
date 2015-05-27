function [hs] = serial2hs(serial_date);
% [Jd] = serial2hs(serial_date);
% This function accepts a serial date and returns date in hs format 
% hs is the hour of the day (00 - 23) plus the decimal fraction of an hour
% See also dateJd0, dateJd1, dateYy
if ~exist('serial_date','var')
    serial_date = [];
end
if ~all(size(serial_date))
    serial_date = [];
end
date_axes = serial2axes(serial_date);

hs = date_axes.Hh + 24.*(floor(date_axes.doy0)-floor(date_axes.doy0(1)));
