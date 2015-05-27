function [dt_struct] = date_struct(serial_date);
% [dt_struct] = date_struct(serial_date);
% This function accepts a serial date number and returns a 
% structure containing the following components:
% .Y Year AD
% .M Month
% .D day of Month
% .h hour of day
% .m minute of hour
% .s second of minute

[dt_struct.Y, dt_struct.M, dt_struct.D, dt_struct.h, dt_struct.m, dt_struct.s] = datevec(serial_date);
