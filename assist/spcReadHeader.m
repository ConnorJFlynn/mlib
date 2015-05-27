%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% spcReadHeader
% (c) 2007
% Ionetrics, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% See spc.h for details
function SpcHeader = spcReadHeader(file)

ftflgs = fread(file,8,'ubit1');
SpcHeader.ftflgs.TSPREC = ftflgs(1);        %Single precision (16 bit) Y data if set
SpcHeader.ftflgs.TCGRAM = ftflgs(2);        %Enables fexper in older software (CGM if fexper=0)
SpcHeader.ftflgs.TMULTI = ftflgs(3);        %Multiple traces format (set if more than one subfile)
SpcHeader.ftflgs.TRANDM = ftflgs(4);        %If TMULTI and TRANDM=1 then arbitrary time (Z) values
SpcHeader.ftflgs.TORDRD = ftflgs(5);        %If TMULTI abd TORDRD=1 then ordered but uneven subtimes
SpcHeader.ftflgs.TALABS = ftflgs(6);        %Set if should use fcatxt axis labels, not fxtype etc.
SpcHeader.ftflgs.TXYXYS = ftflgs(7);        %If TXVALS and multifile, then each subfile has own X's
SpcHeader.ftflgs.TXVALS = ftflgs(8);        %Floating X value array preceeds Y's  (New format only)

SpcHeader.fversn = fread(file,1,'uchar');   %0x4B=> new LSB 1st, 0x4C=> new MSB 1st, 0x4D=> old format
if (SpcHeader.fversn ~= hex2dec('4B'))
  return;  %unsupported header version
end

SpcHeader.fexper = fread(file,1,'uint8');   %Instrument technique code
SpcHeader.fexp = fread(file,1,'uint8');     %Fraction scaling exponent integer (80h=>float)
SpcHeader.fnpts = fread(file,1,'uint32');   %Integer number of points (or TXYXYS directory position)
SpcHeader.ffirst = fread(file,1,'float64'); %Floating X coordinate of first point
SpcHeader.flast = fread(file,1,'float64');  %Floating X coordinate of last point
SpcHeader.fnsub = fread(file,1,'uint32');   %Integer number of subfiles (1 if not TMULTI)
SpcHeader.fxtype = fread(file,1,'uint8');   %Type of X axis units
SpcHeader.fytype = fread(file,1,'uint8');   %Type of Y axis units
SpcHeader.fztype = fread(file,1,'uint8');   %Type of Z axis units
SpcHeader.fpost = fread(file,1,'uint8');    %Posting disposition (see GRAMSDDE.H)

SpcHeader.fdate = spcUncompressDate(fread(file,32,'ubit1')); %Date/Time LSB: min=6b,hour=5b,day=5b,month=4b,year=12b
        
SpcHeader.fres = fread(file,9,'char');      %Resolution description text (null terminated)
SpcHeader.fsource = fread(file,9,'char');   %Source instrument description text (null terminated)
SpcHeader.fpeakpt = fread(file,1,'uint16'); %Peak point number for interferograms (0=not known)
SpcHeader.fspare = fread(file,8,'float32');
SpcHeader.fcmnt = fread(file,130,'char');   %Null terminated comment ASCII text string

tmp = fread(file,30,'char');                %X,Y,Z axis label strings if ftflgs=TALABS
i = find(tmp==0);
SpcHeader.fcatxt.x = char(tmp(1:i(1)-1)');
SpcHeader.fcatxt.y = char(tmp(i(1)+1:i(2)-1)');
SpcHeader.fcatxt.z = char(tmp(i(2):length(tmp))');

SpcHeader.flogoff = fread(file,1,'uint32'); %File offset to log block or 0 (see above)
SpcHeader.fmods = fread(file,1,'uint32');   %File Modification Flags (see below: 1=A,2=B,4=C,8=D..)
SpcHeader.fprocs = fread(file,1,'char');    %Processing code (see GRAMSDDE.H)

SpcHeader.flevel = fread(file,1,'char');    %Calibration level plus one (1 = not calibration data)
SpcHeader.fsampin = fread(file,1,'uint16'); %Sub-method sample injection number (1 = first or only )
SpcHeader.ffactor = fread(file,1,'float32');%Floating data multiplier concentration factor (IEEE-32)
SpcHeader.fmethod = fread(file,48,'char');  %Method/program/data filename w/extensions comma list
SpcHeader.fzinc = fread(file,1,'float32');  %Z subfile increment (0 = use 1st subnext-subfirst)
SpcHeader.fwplanes = fread(file,1,'uint32');%Number of planes for 4D with W dimension (0=normal)
SpcHeader.fwinc = fread(file,1,'float32');  %W plane increment (only if fwplanes is not 0)
SpcHeader.fwtype = fread(file,1,'char');    %Type of W axis units (see definitions below)
SpcHeader.freserv = fread(file,187,'char'); %Reserved (must be set to zero)
        
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compressed date has 6-bits for minute, 5-bits for hour, 5-bits for day, 4-bits for month, 12-bits for year
function fdate2 = spcUncompressDate(fdate)

tmp = fdate(6:-1:1);
fdate2.minute = tmp(1)*32 + tmp(2)*16 + tmp(3)*8 + tmp(4)*4 + tmp(5)*2 + tmp(6);

tmp = fdate(11:-1:7);
fdate2.hour   = tmp(1)*16 + tmp(2)*8 + tmp(3)*4 + tmp(4)*2 + tmp(5);

tmp = fdate(16:-1:12);
fdate2.day    = tmp(1)*16 + tmp(2)*8 + tmp(3)*4 + tmp(4)*2 + tmp(5);

tmp = fdate(20:-1:17);
fdate2.month  = tmp(1)*8 + tmp(2)*4 + tmp(3)*2+ tmp(4);

tmp = fdate(32:-1:21);
fdate2.year   = tmp(1)*2048 + tmp(2)*1024 + tmp(3)*512 + tmp(4)*256 + tmp(5)*128+ tmp(6)*64 + tmp(7)*32 + tmp(8)*16 + tmp(9)*8 +tmp(10)*4 + tmp(11)*2 + tmp(12);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
