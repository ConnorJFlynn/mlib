function [v, rad] = lblrtm_TAPE11_reader(fname, opt,length_file)
%
%    Disclaimer of Warranty. DANIEL FELDMAN PROVIDES THE SOFTWARE AND THE SERVICES "AS IS" WITHOUT WARRANTY 
%    OF ANY KIND EITHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
%    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. ALL RISK OF QUALITY AND PERFORMANCE OF THE 
%    SOFTWARE OR SERVICES REMAINS WITH YOU. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL PART OF THIS AGREEMENT.
%
%    Limitation of Remedies. IN NO EVENT WILL DANIEL FELDMAN, DISTRIBUTORS, DIRECTORS OR AGENTS BE LIABLE 
%    FOR ANY INDIRECT DAMAGES OR OTHER RELIEF ARISING OUT OF YOUR USE OR INABILITY TO USE THE SOFTWARE OR 
%    SERVICES INCLUDING, BY WAY OF ILLUSTRATION AND NOT LIMITATION, LOST PROFITS, LOST BUSINESS OR LOST  
%    OPPORTUNITY, OR ANY INDIRECT, SPECIAL, INCIDENTAL OR CONSEQUENTIAL OR EXEMPLARY DAMAGES,  
%    INCLUDING LEGAL FEES, ARISING OUT OF SUCH USE OR INABILITY TO USE THE PROGRAM, EVEN IF DANIEL FELDMAN 
%    OR AN AUTHORIZED LICENSOR DEALER, DISTRIBUTOR OR SUPPLIER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES, 
%    OR FOR ANY CLAIM BY ANY OTHER PARTY. BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR THE  
%    LIMITATION OF LIABILITY FOR CONSEQUENTIAL OR INCIDENTAL DAMAGES, IN SUCH STATES OR JURISDICTIONS, 
%    DANIEL FELDMAN'S LIABILITY SHALL BE LIMITED TO THE EXTENT PERMITTED BY LAW.
%
%    Daniel Feldman's Liability. Daniel Feldman assumes no liability hereunder for, 
%    and shall have no obligation to defend you or to pay costs, damages or attorney's fees for, 
%    any claim based upon: (i) any method or process in which the Software or Services may be used by you; 
%    (ii) any results of using the Software or Services; 
%    (iii) any use of other than a current unaltered release of the Software; or 
%    (iv) the combination, operation or use of any of the Software or Services furnished hereunder 
%    with other programs or data if such infringement would have been avoided by the combination, 
%    operation, or use of the Software or Services with other programs or data. 
%
%    If you do not agree to these terms, discontinue use of this software immediately.
%
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

v = zeros(1,length_file);
rad = zeros(1,length_file);
index = 1;
if nargin ~= 3
	disp('wrong number of input parameters, you must specify data type');
	return;
end
fname
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

  
  dummy = [0:length(tmp)-1];
  figure(1)
  plot(v1 + dv*dummy,tmp)
  hold on
  if v1>700
    keyboard
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
    
    %v = [v; [v1, v2, dv]];
    if endflg == 0
    dummy = [0:2399];
    v(index:index+2400-1) = v1 + dv*dummy;    
    rad(index:index+2400-1) = tmp;
    index = index + 2400;
    end
    %rad = [rad; reshape(tmp, npts, 1)];
  end
end

v = v(1:index-2400);
rad = rad(1:index-2400);
%v = v1:dv:v2;
%v = reshape(v, length(v), 1);
%rad = tmp;
%rad = reshape(rad, length(v), 1);

fclose(fid);
