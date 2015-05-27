function ger = rd_jh_ger
% Reads raw gerber file from Hubbe (I think it is from Hubbe.  I got it
% from Berg
[fid, fname, pname] = getfile('*.*','chaps');
fclose(fid);
fid = fopen([pname, fname]);
yy = 2000 + sscanf(fname(1:2),'%d');
mm = sscanf(fname(3:4),'%d');
dd = sscanf(fname(5:6),'%d');
format = '%2d:%2d:%f %f %f %f %*[^\n]';
format = '%2d : %2d : %f %f %f %f %*[^\n]';
C = textscan(fid, format, 'headerlines',1,'delimiter',',');
fclose(fid)
len = size(C{1});

ger.time = datenum(double([yy*ones(len),mm*ones(len),dd*ones(len),C{1}, C{2}, C{3}]));
ger.psa = double(C{4});
ger.lwc = double(C{5});
ger.Re = double(C{6});