function chem = rd_chem_srs
% Reads raw srs file from Steven 
[fid, fname, pname] = getfile('*.txt','chem');
fclose(fid);
fid = fopen([pname, fname]);
yy = 2000 + sscanf(fname(1:2),'%d');
mm = sscanf(fname(3:4),'%d');
dd = sscanf(fname(5:6),'%d');
format = '%s %2d : %2d : %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f  %f %f %f %*[^\n]';
C = textscan(fid, format, 'headerlines',40,'delimiter','\t','emptyvalue',NaN);
fclose(fid)
len = size(C{1});
chem.time = datenum(double([yy*ones(len),mm*ones(len),dd*ones(len),C{2}, C{3}, C{4}]));
chem.ger_lwc = double(C{33});
chem.lwc = double(C{34});
