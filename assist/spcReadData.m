%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spcReadData
% (c) 2007-2009
% Ionetrics, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% See spc.h for details
% This functions assumes evenly spaced xdata (as is the case for raw Edgar igrams)
% This function will read raw igrams in Grams/SPC format generated by Edgar
% Accepted file formats are 16-bit fixed, 32-bit fixed, and 32-bit floating
function SpcData = spcReadData(file, spcHeader, subFileNumber)

%Calculate the xdata
xstep = (spcHeader.flast-spcHeader.ffirst) / (spcHeader.fnpts-1);
SpcData.x = spcHeader.ffirst : xstep : spcHeader.flast;

%Seek to correct subheader position
MAINHEADERSIZE = 512;
SUBHEADERSIZE = 32;
if spcHeader.ftflgs.TSPREC
  bytesPerPoint=2;
else
  bytesPerPoint=4;
end
offset = MAINHEADERSIZE + (spcHeader.fnpts*bytesPerPoint+SUBHEADERSIZE)*(subFileNumber-1);
fseek(file,offset,'bof');

%Read the subheader for this subfile
SpcData.subheader = spcReadSubheader(file);

%Check for valid exponent
%  exponent is related to preamp gain like this:
%    Subheader Exponent    Preamp Gain
%            23                  1
%            22                  2
%            21                  4
%            20                  8
%            19                 16
%            18                 32
%            17                 64
%            16                128
exponent = SpcData.subheader.subexp;
if (exponent ~= 128)
  if (spcHeader.ftflgs.TSPREC)
    if (exponent>23) exponent=16; end
    if (exponent<16) exponent=16; end   
  else
    if (exponent>39) exponent=32; end
    if (exponent<32) exponent=32; end
  end  
end

%Read the ydata for this subfile
if spcHeader.ftflgs.TSPREC
  SpcData.y = fread(file, spcHeader.fnpts, 'int16') * (2^(exponent-16));
elseif exponent==128
  SpcData.y = fread(file, spcHeader.fnpts, 'float32');
else
  SpcData.y = fread(file, spcHeader.fnpts, 'int32') * (2^(exponent-32));
  %SpcData.y = SpcData.y * (2^(exponent-32));
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%