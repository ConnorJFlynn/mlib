while 1,
[fid, fname, pname] = getfile;
unit = num2str(fread(fid,1));
disp([pname fname ' ' unit]);
fclose(fid);
end;