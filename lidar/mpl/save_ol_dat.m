% Usage: save_ol_dat
% This procedure is called to save an ascii file of overlap data after a data file containing
% an overlap measurement has been read (using read_mpl) and corrected for dtc and afterpulse.
% The ascii file generated will be read by tablecurve to generate a smooth functional fit to 
% the measurement.  Then the smoothed data will be read back into Matlab, a linear fit applied 
% to the appropriate region (range > 5km or thereabouts) and a final overlap correction is
% generated and saved. 

bin_width = range(101) - range(100);
norm_range = range / bin_width;
weights = diff2(log(norm_range));

ol_dat = [range, mean(signal_r2')', weights];
disp(['Select a destination and file name for the overlap data.']);
[fname, pname] = putfile('*.dat');
if pname~=0
%  eval(['save ', pname, fname, ' afterpulse ap_range'])
  save([pname fname], 'ol_dat', '-ascii')
end
if exist([pname fname],'file')
    status=1;
else status=0;
end;
