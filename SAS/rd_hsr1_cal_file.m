function cal = rd_hsr1_cal_file(fname)
% Reads an HSR1 irradiance calibraton file, 

if ~isavar('fname')||~isafile(fname)
   fname = getfullname('*SpectrometerCalibration*','hsr1_raw','Select HSR Baumer calibration file...');
end
fid = fopen(fname, 'r');

A = textscan(fid,['%*s ','%f %f %f %f %f %f %f %f ', '%*[^\n]'],'delimiter','\t','HeaderLines',4);
fclose(fid);
cal.fname = fname;
cal.nm = [300:1100];
cal.nm = A{1}';
% cal.ch1 = A{2}; cal.ch2 = A{3}; cal.ch3 = A{4}; cal.ch4 = A{5}; cal.ch5 = A{6}; cal.ch6 = A{7}; cal.ch7 = A{8}; 
cal.resp = [A{2},A{3},A{4},A{5},A{6},A{7},A{8}]'; 
end