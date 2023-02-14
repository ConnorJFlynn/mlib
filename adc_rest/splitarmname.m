function [site, dstem, fac, dlevel, ddate] = splitarmname(fname);
%[site, dstem, fac, dlevel, ddate] = splitarmname(fname);
[fpath, filename, ext] = fileparts(fname);
[dsname, rest] = strtok(filename, '.');
[dlevel,rest] = strtok(rest, '.');
[dstr, rest] = strtok(rest,'.');
[tstr, rest] = strtok(rest,'.');
ddate = datenum([dstr,'.',tstr],'yyyymmdd.hhMMss');
site = dsname(1:3);
dsname(1:3)=[];
ch = length(dsname);
done = false;
while findstr('123456789',dsname(ch))&ch>4
   ch = ch -1;
end
fac = dsname(ch:end);
dsname(ch:end) = []; 
dstem = dsname;   