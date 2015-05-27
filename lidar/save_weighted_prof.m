function [status, fname, pname] = save_weighted_prof(range, profile)
% Usage: [status, fname, pname] = save_weighted_prof(range, mean(profile')')
% This procedure is called to save an ascii file containing a range vector, a profile, and a 
% column of weights where the weights are determined by the log of the ratio of adjacent ranges.
% This is done in preparation of sending the file to tablecurve for fitting.
% The ascii file generated will be read by tablecurve to generate a smooth functional fit to 
% the measurement.  Then the smoothed data will be read back into Matlab, a linear fit applied 
% to the appropriate region (range > 5km or thereabouts) and a final overlap correction is
% generated and saved. 

bin_width = range(101) - range(100);
norm_range = range / bin_width;
weights = diff2(log(norm_range));

weighted_data = [range, profile, weights];
disp(['Select a destination and file name for the ascii file with weighted profile.']);
[fname, pname] = putfile('*.dat');
if pname~=0
%  eval(['save ', pname, fname, ' afterpulse ap_range'])
  save([pname fname], 'weighted_data', '-ascii')
end
if exist([pname fname],'file')
    status=1;
else status=0;
end;
