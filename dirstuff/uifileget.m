function fullfilename = uifileget;
[fname, pname] = uigetfile;
fullfilename = fullfile(pname, fname);