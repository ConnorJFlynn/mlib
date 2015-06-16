function pe = read_pe_raw;
% Reads a pulse-echo binary data file, 2048 bins as 8-byte "double"
pe.bins = 2048;
pe.us = 20e-3; %In us, 20 ns per bin
[filename] = getfullname('*.bin','echo','Select an echopulse file.');
fid = fopen(filename);
if fid>0
   pe.fname = filename;
   status = fseek(fid,0,1);
   pe.profs = ftell(fid)/(8*pe.bins);
   status = fseek(fid,0,-1);
   pe.trace = fread(fid,[pe.bins,pe.profs],'double');
   fclose(fid);
end

% pe.t_ns = 40*([1:bins]-1); % 40 ns bins.


