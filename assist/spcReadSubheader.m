%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spcReadSubheader
% (c) 2007
% Ionetrics, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% See spc.h for details
% Read the 32-byte subheader
% Assumes file pointer has already been properly positioned to the start of the subheader
function SpcSubheader = spcReadSubheader(file)

SpcSubheader.subflgs   = fread(file,1,'uint8');   %Flags
SpcSubheader.subexp    = fread(file,1,'uint8');   %Exponent for sub-file's Y values (80h=>float)
SpcSubheader.subindx   = fread(file,1,'uint16');  %Integer index number of trace subfile (0=first)
SpcSubheader.subtime   = fread(file,1,'float32'); %Floating time for trace (Z axis corrdinate)
SpcSubheader.subnext   = fread(file,1,'float32'); %Floating time for next trace (May be same as beg)
SpcSubheader.subnois   = fread(file,1,'float32'); %Floating peak pick noise level if high byte nonzero
SpcSubheader.subnpts   = fread(file,1,'uint32');  %Integer number of subfile points for TXYXYS type
SpcSubheader.subscan   = fread(file,1,'uint32');  %Integer number of co-added scans or 0 (for collect)
SpcSubheader.subwlevel = fread(file,1,'float32'); %Floating W axis value (if fwplanes non-zero)
SpcSubheader.subresv   = fread(file,4,'char');    %Reserved area (must be set to zero)
        
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
