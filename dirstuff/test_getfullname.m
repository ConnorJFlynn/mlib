function test_getfullname;

fname = getfullname;
disp(fname);
[pname,filename,ext] = fileparts(fname);
disp(pname)
disp(filename)
disp(ext)
figure;