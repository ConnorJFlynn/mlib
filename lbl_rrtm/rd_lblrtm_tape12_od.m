function [spec] = rd_lblrtm_tape12_od(fname, prec)
%  [spec] = rd_lblrtm_tape12_od(fname, prec)
% fname: name a LBLRTM TAPE12 file containing ODs
% prec: precision of data ('d' for double, 's' or 'f' for single)
if ~isavar('fname')||~isafile(fname)
    fname = getfullname(getfullname('TAPE12*.*','tape12'));
end
if ~isavar('prec')
    prec = 'd';
end


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
% 1 int        , 9600 or npts*4 (beg of block output)
% NPTs float   , trans
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
% 1 int        , 19200 or npts*8 (beg of block of output)
% NPTS double  , trans
% 1 int        , 19200 or npts*8 (end of block of output)
% LOOP ENDS

% Author: Xianglei Huang
% Tested on Redhat Linux with pgi-compiler version of LBLRTM
% Modified by Connor Flynn, OU, tested on Win10

v = [];
od = [];
spec.v = v; spec.od = od;

fid = fopen(fname, 'rb');

if lower(prec(1)) == 'f' | lower(prec(1)) == 's'
	shift = 266;
	itype   = 1;
else
	shift = 356;
	itype = 2;
end

fseek(fid, shift*4, -1);
% decide whether need to open as big-endian file
test = fread(fid, 1, 'int');
if (itype == 1 & test == 24) | (itype ==2 & test == 32)
    % little endian, no need to reopen
    fseek(fid, -4, 0);
else
    fclose(fid);
    fid = fopen(fname, 'rb', 'b');
    fseek(fid, shift*4, -1);
end


endflg = 0;

panel = 0;

if itype == 1
while (endflg == 0)
	panel = panel + 1;
	disp(['read panel ', int2str(panel)]);
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
if length([v1:dv:v2])==npts
    v_ = [v1:dv:v2]';
else 
    v_ = linspace(v1,v2,npts)';
end
spec.v = [spec.v; v_(:)];
spec.od = [spec.od; tmp(:)];

end
else
while(endflg == 0)
        panel = panel + 1;
       
fp = ftell(fid);	tmp0 = fread(fid, 1, 'int'); ftell(fid)-fp;
fp = ftell(fid);		tmp = fread(fid, 3, 'double'); ftell(fid)-fp;
	v1 = tmp(1); v2 = tmp(2); dv = tmp(3);
	if isnan(v1) 
		break;
	end
fp = ftell(fid);	npts = fread(fid, 1, 'int64'); ftell(fid)-fp;

	if npts ~= 2400
		endflg = 1;
	end

fp = ftell(fid);	fread(fid, 1, 'int'); ftell(fid)-fp;
	LEN = fread(fid, 1, 'int');
	if (LEN ~= 8*npts)
		disp('internal file inconsistency');
		endflg = 1;
	end
	tmp = fread(fid, npts, 'double');
fp = ftell(fid);	LEN2 = fread(fid, 1, 'int'); ftell(fid)-fp;
	if (LEN ~= LEN2)
		 disp('internal file inconsistency');
                endflg = 1;
        end
if length([v1:dv:v2])==npts
    v_ = [v1:dv:v2]';
else 
    v_ = linspace(v1,v2,npts)';
end
spec.v = [spec.v; v_(:)];
spec.od = [spec.od; tmp(:)];
 disp(['Complete panel ', int2str(panel)]);
end
end

%v = v1:dv:v2;
%v = reshape(v, length(v), 1);
%rad = tmp;
%rad = reshape(rad, length(v), 1);
spec.nm = 1e7./spec.v;
fclose(fid);
