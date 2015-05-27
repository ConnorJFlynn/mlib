function nimfr = read_barn_nimfr_cosnorm(filename);
%This should read barnard nimfr cos_normal files
% Time is in LST. 
if ~exist('filename', 'var')
   filename= getfullname_('*.txt','barn_nimfr');
   [pname, fname,ext] = fileparts(filename);
   fname = [fname,ext];
end
% No header, just columns of space-delimited ascii data
% First column appears to be time in HH. 
% Successive columns are probably direct normal for each of 7 detectors
% Determine date from filename...
% Use fileparts to strip extension, Flip left-to-right, skip to first non-numeric, flip
% back
[dmp, tmp,ext] = fileparts(filename);
pmt = fliplr(tmp);
[etad, rest] = strtok(pmt,'_');
date_str = fliplr(etad);
fid = fopen(filename);
if fid>0
   nimfr.filename = filename;
   done = false; header_rows = 0;
   C = textscan(fid,'%f %f %f %f %f %f %f %f');
   nimfr.time_LST = datenum(date_str,'yyyymmdd') + C{1}./24;
   nimfr.filter_Si = C{2};
   nimfr.filter_415 = C{3};
   nimfr.filter_500 = C{4};
   nimfr.filter_615 = C{5};
   nimfr.filter_673 = C{6};
   nimfr.filter_870 = C{7};
   nimfr.filter_940 = C{8};      
end

