 
function [serial] = igor2serial (igor_time)

% Converts epoch time to serial time.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: epoch2serial.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: epoch2serial.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
%
%   Revision 1.2  2008/10/20 17:08:50  cflynn
%   Force serial time as double irrespective of incoming time fields in netcdf file.  This was done to get around data type limitation of datenum.  Seems that there is no reason datanum shouldn't eat other numeric data types, but there ya go.
%
%   Revision 1.1  2007/11/09 01:24:20  cflynn
%   This repository is for Matlab m-files
%
%   Revision 1.1  2007/09/05 08:08:56  cflynn
%   Creating Matlab Library for central ARM distribution of matlab scripts and functions
%
%   Revision 1.5  2006/06/19 18:43:01  sbeus
%   Added back CVS log information.
%
%
%-------------------------------------------------------------------
 
DAYS_TO_1904 =  695422; % =datenum(1904,0,0) + 1
SEC_PER_DAY  = 86400;

index = (igor_time) ./ SEC_PER_DAY;
serial = double(index + DAYS_TO_1904);
disp(' igor2serial does not quite work.  Seems to be off by ~15 minutes')
return
