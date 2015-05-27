function [v, rad] = lblrtm_od_reader(fname, opt,v1,v2)

% File format illustration
% for single precision
% shift 266*4 bytes
% LOOP
% 1 int        , 24 (block of v1, v2, dv, npts)
% 2 double vars, for v1, and v2
% 1 float      , for dv
% 1 int        , for npts
% 1 int        , 24
% 1 int        , 9600 or npts*4 (beg of block output)
% NPTs float   , rad
% 1 int        , 9600 or npts*4 (end of block of output)
% LOOP ENDS

% for double precision
% shift 356*4 bytes
% LOOP
% 1 int        , 32 (v1, v2, dv and npts, extra 0)
% 3 double vars, for v1, v2, and dv
% 1 long int   , for npts
% 1 int        , 32   
% 1 int        , 19200 or npts*8 (beg of block of output)
% NPTS double  , rad
% 1 int        , 19200 or npts*8 (end of block of output)
% LOOP ENDS

% Author: Xianglei Huang
% Tested on Redhat Linux with pgi-compiler version of LBLRTM
% Usage: lblrtm_TAPE11_reader(fname,0);
% Revised by Dan Feldman in order to read in optical depth files

total_length = abs(v2-v1)*1e4;  %default resolution of 0.0001
output_length = abs(v2-v1)*1e2; %0.01 cm^-1
averaging_matrix = zeros(1e4,1e2);
for i=1:1e2
  averaging_matrix(1+1e2*(i-1):1e2*i,i) = 1/1e2;
end
averaging_matrix2 = zeros(2400,24);
for i=1:24
  averaging_matrix2(1+1e2*(i-1):1e2*i,i) = 1/1e2;
end

v = zeros(1,output_length);
rad = zeros(1,output_length);
index = 1;

fid = fopen(fname, 'rb', 'l');

if lower(opt(1)) == 'f' | lower(opt(1)) == 's'
	shift = 266;
	itype   = 1;
else
	shift = 356;
	itype = 2;
end

fseek(fid, shift*4, -1);

% decide whether need to open as big-endian file
test = fread(fid, 1, 'int');

fclose(fid);

if (itype == 1 & test == 24) | (itype ==2 & test == 32)
fid = fopen(fname, 'rb', 'l');
fseek(fid, shift*4, -1);
else
fid = fopen(fname, 'rb', 'b');
fseek(fid, shift*4, -1);
end

endflg = 0;

panel = 0;

if itype == 1
while (endflg == 0)
  panel = panel + 1;
  %disp(['read panel ', int2str(panel)]);
  fread(fid, 1, 'int');
  v1 = fread(fid, 1, 'double');
  if isnan(v1) 
    break;
  end
  v2 = fread(fid, 1, 'double');
  dv = fread(fid, 1, 'float');
  npts = fread(fid, 1, 'int');
  fread(fid, 1, 'int');
  
  LEN = fread(fid, 1, 'int');
  if (LEN ~= 4*npts)
    disp('internal file inconsistency');
    endflg = 1;
  end
  tmp = fread(fid, npts, 'float');
  LEN2 = fread(fid, 1, 'int');
  if (LEN ~= LEN2)
    disp('internal file inconsistency');
    endflg = 1;
  end
  %v = [v; [v1, v2, dv]];
  %rad = [rad; reshape(tmp, npts, 1)];
end
else
  while(endflg == 0)
    panel = panel + 1;
    %disp(['read panel ', int2str(panel)]);
    fread(fid, 1, 'int');
    tmp = fread(fid, 3, 'double');
    v1 = tmp(1); v2 = tmp(2); dv = tmp(3);
    if isnan(v1) 
      break;
    end
    npts = fread(fid, 1, 'int64');
    
    if npts ~= 2400
      endflg = 1;
    end
    
    fread(fid, 1, 'int');
    LEN = fread(fid, 1, 'int');
    if (LEN ~= 8*npts)
      disp('internal file inconsistency');
      endflg = 1;
    end
    tmp = fread(fid, npts, 'double');
    LEN2 = fread(fid, 1, 'int');
    if (LEN ~= LEN2)
      disp('internal file inconsistency');
      endflg = 1;
    end
    
    %v = [v; [v1, v2, dv]];
    if endflg == 0
      dummy = [0:2399];
      dv2 = 100*dv;
      dummy2 = [0:23]; 
      v(index:index+24-1) = v1 + dv2*dummy2;
      %Convert monochromatic optical depth to polychromatic optical depth
      tau_poly = -log(exp(-tmp')*averaging_matrix2); %doesn't work at very high optical depth
      rad(index:index+24-1) = tau_poly;
      index = index + 24;
    end
    %rad = [rad; reshape(tmp, npts, 1)];
    
  end
end

v = v(1:index-24);
rad = rad(1:index-24);
%v = v1:dv:v2;
%v = reshape(v, length(v), 1);
%rad = tmp;
%rad = reshape(rad, length(v), 1);

fclose(fid);
