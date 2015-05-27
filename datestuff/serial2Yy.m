function [Yy] = serial2Yy(serial_date);
% [Yy] = serial2Yy(serial_date);
% This function accepts a serial date and returns date in Yy format 
% Yy is the year (AD) and fraction of year.
% See also dateHh, dateJd0, dateJd1

date_axes = serial2axes(serial_date);
Yy = date_axes.Yy;

