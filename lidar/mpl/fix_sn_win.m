function status = fix_sn_win(sn, fname, pname);
% Reads an entire mpl file in New NASA format and writes it out again with the 
% supplied UnitSN
status = -1;
if nargin < 2 
    [fname, pname] = file_path('*.??W');
end
fid = fopen([pname fname], 'r+');
fidstart = ftell(fid);
fseek(fid,0,1);
fidend = ftell(fid);
fseek(fid,0,-1);
FileLength = fidend - fidstart;

%Make sure file is at least 825 bytes long, then read first byte
if((fidend-fidstart)>824);
  [A] = fread(fid,1);
  %if first byte is between 80 and 99, then it is YEAR and format is MPL00
  %else then it is UnitSN folded with FileFormat
  if (A(1)>49)&(A(1)<150);
    FileFormat = 'NASA_Win';
    UnitSN = 50 + sn;
    disp([FileFormat]);
  % With the 'Win' format, the size of the profile is variable, so it
    % must be determined before reading in the data.
    clear temp;
    fseek(fid,0,-1);
    temp = fread(fid,44);
    fseek(fid,0,-1);
    RangeBinTime= temp(37)*256^3 + temp(38)*256^2 + temp(39)*256 + temp(40);
    MaxAltitude = temp(41)*256 + temp(42);
    c =  2.99792458e8;   % speed of light in meters / second
    NumBins = round( 2* (MaxAltitude/RangeBinTime) / (c*1e-12) );
    PacketSize = 44 + 4*NumBins;
    NumPackets = FileLength/PacketSize;
    if NumPackets == fix(NumPackets);
      disp('File appears to be valid.  Reading packets...')
      bigarray = zeros(PacketSize,NumPackets);
      bigarray(:) = fread(fid,PacketSize*NumPackets);
      bigarray(1,:) = UnitSN;
      fseek(fid,0,-1);
      status = (fwrite(fid, bigarray)>0)*(UnitSN-50);
    end;
  else
    FileFormat = 'Unknown format';
    disp([FileFormat]);
  end;
else disp(['This file is too small to contain any profiles: ' pname, fname]);
end; %of minimum file length check.
fclose(fid);


