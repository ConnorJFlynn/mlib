function [v, rad] = charts_reader(fname,v1,v2)

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

% Author: Xianglei Huang
% Second Author: Dan Feldman
% Tested on Redhat Linux with pgi-compiler version of LBLRTM
% Usage: charts_reader(fname,800,900);
% arguments: fname = string of filename, i.e. '/home/drf/a2/charts/CHARTS_RAD'
%            v1 = starting wavenumber (cm^-1)
%            v2 = ending wavenumber (cm^-1)

dummy = (v2-v1)*1e4;
v = zeros(1,dummy);
rad = zeros(dummy,1);
opt = 's';

if nargin ~= 3
  disp('wrong number of input parameters, you must specify data type');
  return;
end

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
  change_flag = 1;
  num_panel = 0;
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
    if change_flag == 0
      if v1 ~= v1_comp
	change_flag = 1;
      end
    end
    if change_flag == 1
      v1_comp = v1;
      dummy = [v1:dv:v2+dv];
      if length(dummy)>2400
	dummy = [v1:dv:v2];
      elseif length(dummy)<2400
	break
      end
      rad(num_panel*2400+1:(num_panel+1)*2400) = reshape(tmp,npts,1);
      v(num_panel*2400+1:(num_panel+1)*2400) = dummy;
      num_panel = num_panel + 1;
      change_flag = 0;
    end
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
    
    v = [v; [v1, v2, dv]];
    rad = [rad; reshape(tmp, npts, 1)];
  end
end
rad = rad';

fclose(fid);
