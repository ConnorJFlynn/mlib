function [mpl] = mplprofs(mpl);
%[mpl] = mplprofs(mpl);

[bins,profs] = size(mpl.rawcts);
% The following range-determination has been subsumed into read_mpl and is
% no longer needed here...
%
% disp('Subtracting a preliminary background determination from Profile_bins for range determination.')
% bkgnd = mean(ProfileBins(fix(bins*.87):ceil(bins*.97),:));
% signal = zeros(bins,profs);
% for i = 1:profs
%   signal(:,i) = mpl.rawcts(:,i) - bkgnd(i);
% end;
% earlybins = mean(signal(1:10,:)');
% first_bin = min(find(earlybins > 1));
% offset = input('Enter offset to be subtracted from range (in units of either bins or nanoseconds): ');
% if offset > 10  %  then offset was entered in nanoseconds, so convert to kilometers by multiplying by c*1e-12
%    units = 'nanoseconds';
%    temp = offset * c/2 * 1e-12;
% elseif offset >= 0 % then offset was entered in bins, so convert to kilometers by multiplying by 
%    units = 'bins';
%    temp = (offset - 0.5) * RangeBinTime * c/2 * 1e-12; % the "0.5" centers the specified bin.
% elseif offset == [] % then no offset was entered, so convert first_bin to kilometers.
%    disp('No offset entered, determining offset as first bin of significant signal');
%    temp = (first_bin - 0.5) * RangeBinTime * c/2 * 1e-12; % The "0.5" centers the first bin
%    units = 'first_bin';
% end;
% offset = temp
% clear temp;
% if first_bin ~= fix(0.5+offset / (RangeBinTime*c/2*1e-12))  % then the supplied offset disagrees with the determined first bin value
%    disp(['Hey!  The offset of ' num2str(offset) ,' ', units, ' is not in the first bin with detectable signal.  If this is NOT okay, hit Ctrl-C...']);
%    pause;
% end;
% 
% range = [1:bins]';
% range = range*RangeBinTime*c/2*1e-12 - offset ;
% range(first_bin) = ((first_bin)* RangeBinTime*c/2*1e-12 - offset)/2;

%disp('Range has been determined from ProfileBins with preliminary background subtracted.');
disp('Now the afterpulse is loaded from the saved file for a proper determination of the signal profiles.');
[fid, fname, pname] = getfile('*.ap','aftrpuls');
pause(1)
fclose(fid);
pause(1)
if pname~=0 
ap = load([pname fname], '-mat'); %has two or three columns: range, log_ap, [weights]
%[ap_range] = [ap.ap_range];
%[afterpulse] = [ap.afterpulse];
[ap_range] = [ap.this(:,1)];
[afterpulse] = [ap.this(:,2)];
ap = [ap_range, afterpulse];
clear ap_range afterpulse;
% ap = load([pname fname], '-ascii'); %has two or three columns: range, log_ap, [weights]
%afterpulse_interp = interp1(ap(:,1), exp(ap(:,2)), mpl.range, 'spline');
afterpulse_interp = interp1(ap(:,1), ap(:,2), mpl.range, 'spline');  
% The above section is used when fitting a funtional form to ap.
% It is really the 'best' way but the quick and dirty approach below just uses an 
% averaged afterpulse stored in a .mat file.
%eval(['load ', pname, fname, ' -mat']);
else
  disp('Error!! afterpulse file not found!!')
end;
%figure;
%plot(ap_range,log(afterpulse),'or',range,log(afterpulse_interp),'oc');
%clear ap_range;
%clear afterpulse;
% for i = 1:profs;
%   signal(:,i) = mpl.rawcts(:,i) - afterpulse_interp;
% end;
signal = mpl.rawcts - afterpulse_interp*ones(size(mpl.hk.bg));

bkgnd = mean(signal(fix(bins*.87):ceil(bins*.97),:));
% for i = 1:profs
%   signal(:,i) = signal(:,i) - bkgnd(i);
% end;
signal = signal - ones(size(mpl.range))*bkgnd;
signal_r2 = zeros(bins,profs);

mpl.r.squared = mpl.range.*mpl.range;
pre_laser = find(mpl.range < 0);
mpl.r.squared([pre_laser]) = 0;  
% for i = 1:profs
%   signal_r2(:,i) = signal(:,i).*mpl.r.squared;
% end;
signal_r2 = signal.*((mpl.range.^2)*ones(size(mpl.hk.bg)));
mpl.ap = afterpulse_interp;
mpl.prof = signal;
mpl.prof_r2 = signal_r2;