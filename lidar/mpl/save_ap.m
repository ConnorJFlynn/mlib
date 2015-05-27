function [status] = save_ap;
% [status] = save_ap;
% Reads an MPL binary file of darkcounts and an MPL binary file of afterpulse to generate a 
% darkcounts and background-subtracted afterpulse profile.  
% Tweak ap profile to be positive definite.
% Convert ap to log(ap) resulting in log(cpus)
% Determine range-offset and generate ap_range
% Determine range-dependent weighting
% output file with ap_range, log(ap), and weights

disp('Select a pre-saved darkcounts ascii file.')
[fid, fname, pname] = getfile('*.dk','darkcnts')
fclose(fid);
pause(1)
darkcounts = load([pname fname], '-ascii');
pause(1)
disp('Select an MPL packed-binary file of an afterpulse measurement. ');
read_mpl;
[bins,profs] = size(ProfileBins);
%subtract darkcounts from the afterpulse measurement
afterpulse = mean(ProfileBins')' - darkcounts ;
%subtract the minimum afterpulse to force afterpulse positive semi-definite
afterpulse = afterpulse - min(afterpulse);
%identify all zero values 
min_ap = find(afterpulse==0);
%set zero values to preceding afterpulse value.  
while any(min_ap)
    disp('Getting rid of zero ap values...');
    afterpulse(min_ap) = afterpulse(min_ap-1);
    min_ap = find(afterpulse==0);
end;
%this approach fails if the first bin has zeros cts.
%afterpulse is now positive definite (except with first bin is zero...)
afterpulse = log(afterpulse);

%determine range_offset and generate ap_range 
earlybins = afterpulse(1:10);
first_bin = min(find(earlybins > 1));
offset = (first_bin - 0.5) * RangeBinTime * c/2 * 1e-12 ; % The "0.5" centers the first bin
ap_range = [1:bins]';
ap_range = ap_range*RangeBinTime*c/2*1e-12 - offset ;
ap_range(first_bin) = ((first_bin)* RangeBinTime*c/2*1e-12 - offset)/2;

%determine bin_width and generate weighting 
bin_width = ap_range(101) - ap_range(100);
norm_range = ap_range / bin_width;
weights = diff2(log(norm_range));
ap_asc = [ap_range, afterpulse, weights];
disp(['Afterpulse has been calculated.']);
disp(['Select a destination and file name for the afterpulse results.']);
[fname, pname] = putfile('*.ap','aftrpuls');
if pname~=0
%  eval(['save ', pname, fname, ' afterpulse ap_range'])
  save([pname fname], 'ap_asc', '-ascii')
end
if exist([pname fname],'file')
    status=1;
else status=0;
end;
