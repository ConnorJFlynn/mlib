
function [epoch] = serial2epoch (serial)

% [EPOCH] = SERIAL2EPOCH (SERIAL)
%
%   E = SERIAL2EPOCH(S) converts the input serial date (days since
%   00 AD) to epoch (seconds since 1970).  This acts as a reverse of
%   EPOCH2SERIAL.
%
%   One limitation is that the input date must be between Jan 1, 1970
%   and Jan 1, 2038.
%
%     $Revision: 1.1 $
%     $Date: 2013/12/11 00:49:08 $
%
%   See also EPOCH2SERIAL.
%

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile: serial2epoch.m,v $
%   $Revision: 1.1 $
%   $Date: 2013/12/11 00:49:08 $
%
%   $Log: serial2epoch.m,v $
%   Revision 1.1  2013/12/11 00:49:08  cflynn
%   Committing anctools
%
%   Revision 1.1  2011/04/08 13:49:29  cflynn
%   *** empty log message ***
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

DAYS_TO_1970 = 719529;
DAYS_FROM_1970 = 744384;

epoch = 0;

% Catch invalid input.
if (serial < DAYS_TO_1970 | serial > DAYS_FROM_1970)
   disp('SERIAL2EPOCH: Cannot convert time before 1970 or beyond 2038.');
   return;
end

% Convert to epoch.
epoch = double(serial - DAYS_TO_1970) * 86400.0;

return
