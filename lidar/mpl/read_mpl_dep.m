% This procedure is usded by depol_MPL, but should be replaced by read_MPL
% which uses the lidar struct.  2004-08-02 CJF
% Reads an entire raw MPL files in entirety
% Converts bin-time to range using the speed of light

c =  2.99792458e8;   % speed of light in meters / second
[fid, fname, pname] = getfile('*.??W', 'data')
%fid = fopen([pname fname])
disp(['filename: ',fname]);
fidstart = ftell(fid);
fseek(fid,0,1);
fidend = ftell(fid);
fseek(fid,0,-1);
%Make sure file is at least 44 bytes long, then read first two bytes
if((fidend-fidstart)>43);
  [A] = fread(fid,2);
  %if first byte is between 80 and 99, then it is YEAR and format is MPL00
  %else then it is UnitSN folded with FileFormat
  if (A(1)>80)&(A(1)<99); 
    FileFormat = 'NASA_825';
    UnitSN = 0; %Only MPL00 produce 825-byte profiles
    disp([FileFormat]);
  elseif (A(1)>-1)&(A(1) < 50);
    FileFormat = 'NASA_836';
    disp([FileFormat]);
    UnitSN = A(1);
    Year = 1900 + A(2);
elseif (A(1)>49)&(A(1)<150);
    FileFormat = 'NASA_Win';
    disp([FileFormat]);
    UnitSN = A(1)-50;
    Year = 1900 + A(2);
  elseif (A(1)>149)&(A(1)<256);
    FileFormat = 'SESI_Win';
    disp([FileFormat]);
    UnitSN = A(1)-150;
    Year = 1900 + A(2);
  else
    FileFormat = 'Unknown format';
    disp([FileFormat]);
    UnitSN = -1;
    Year = 1900 + A(2);
  end;
  clear A;
  fseek(fid,0,-1);
  disp(['Unit Serial Number: ', num2str(UnitSN)])
  % In this first version, assume that the files are not corrupt.
  % That is, assume FileLength = NumPackets * PacketSize
  FileLength = fidend - fidstart;
  if FileFormat == 'NASA_825';    
	Rd_825;
  elseif FileFormat == 'NASA_836';
	Rd_836;
  elseif FileFormat == 'NASA_Win';
	Rd_Win;
  elseif FileFormat == 'SESI_Win';
  	Rd_SESI;
  end;
else disp(['This file is too small to contain any profiles: ' pname, fname]);
end; %of minimum file length check.
fclose(fid);

[bins,profs] = size(ProfileBins);
disp('Subtracting a preliminary background determination from Profile_bins for range determination.')
bkgnd = mean(ProfileBins(fix(bins*.77):ceil(bins*.97),:));
signal = zeros(bins,profs);
for i = 1:profs
  signal(:,i) = ProfileBins(:,i) - bkgnd(i);
end;
earlybins = mean(signal(1:10,:)');
if any(find(earlybins > 1))
    first_bin = min(find(earlybins > 1));
else 
    first_bin = 1;
end;
range_offset = (first_bin - 0.5) * RangeBinTime * c/2 * 1e-12; % The "0.5" centers the first bin
units = 'first_bin';
%end;
range = [1:bins]';
range = range*RangeBinTime*c/2*1e-12 - range_offset ;
range(first_bin) = ((first_bin)* RangeBinTime*c/2*1e-12 - range_offset)/2;
r_lte_5 = find((range>.03)&(range<=5));
r_lte_10 = find((range>.03)&(range<=10));
r_lte_15 = find((range>.03)&(range<=15));
r_lte_20 = find((range>.03)&(range<=20));

% ProfileBins is averaged over ShotSummed shots and is in units of cts/microsecond.
%To get the original shots per bin, multiply ProfileBins by ShotsSummed and by BinTime in microseconds
% ProfileBins = ProfileBins * ShotsSummmed/(BinTime/1000);
%To get ProfileBins in cts/km divide by the speed of light in km/microsecond: 2.99792458e-1 
% ProfileBins = ProfileBins/(c*1e-9);