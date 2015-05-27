function ap_out = ap_isdac_(range,in_time);
% ap_out = ap_isdac_(range,in_time);
% The ap functions return elements of cop, crs, or prof of length(range)

% ap_time = datenum('2008-04-07_2338','yyyy-mm-dd_HHMM');
% if polavg.time(1)<ap_time
%    disp('Applying pre-April 7 afterpulse corrections for ISDAC')
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-03_2300.dat');
% else
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-07_2338.dat');
%    disp('Applying post-April 7 afterpulse corrections for ISDAC')
% end
%  polavg.cop = polavg.cop - ap.cop_smooth'*ones(size(polavg.time));
%  polavg.crs = polavg.crs - ap.crs_smooth'*ones(size(polavg.time));

ap.time(1) = [inf];
ap.ap{1} = @ap_none;

ap.time(2) = datenum('2008-01-01_0000','yyyy-mm-dd_HHMM');
ap.ap{2} = @ap_preApr7_2008;

ap.time(3) = datenum('2008-04-07_2338','yyyy-mm-dd_HHMM');
ap.ap{3} = @ap_postApr7_2008;
if ~exist('in_time','var')||isempty(in_time)
   in = 1;
else
   last = find(in_time>ap.time,1,'last');
end
last = max([1,last]);
ap_out = ap.ap{last}(range);
return

function ap = ap_none(range);
ap.cop = zeros(size(range));
ap.crs = ap.cop;
ap.prof = ap.cop;
return

function ap_out = ap_preApr7_2008(range);
ap = loadinto('afterpulse.isdac.20080403_2300.mat');


% ap_time = datenum('2008-04-07_2338','yyyy-mm-dd_HHMM');
% if polavg.time(1)<ap_time
%    disp('Applying pre-April 7 afterpulse corrections for ISDAC')
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-03_2300.dat');
% else
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-07_2338.dat');
%    disp('Applying post-April 7 afterpulse corrections for ISDAC')
% end
%  polavg.cop = polavg.cop - ap.cop_smooth'*ones(size(polavg.time));
%  polavg.crs = polavg.crs - ap.crs_smooth'*ones(size(polavg.time));

ap_out.cop =  interp1(ap.range, ap.cop_smooth', range,'nearest','extrap');
ap_out.crs =  interp1(ap.range, ap.crs_smooth', range,'nearest','extrap');


function ap_out = ap_postApr7_2008(range);
ap = loadinto('afterpulse.isdac.20080407_2338.mat');


% ap_time = datenum('2008-04-07_2338','yyyy-mm-dd_HHMM');
% if polavg.time(1)<ap_time
%    disp('Applying pre-April 7 afterpulse corrections for ISDAC')
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-03_2300.dat');
% else
% ap = loadinto('C:\case_studies\ISDAC\MPL\MPL_corrs\afterpulse.isdac.2008-04-07_2338.dat');
%    disp('Applying post-April 7 afterpulse corrections for ISDAC')
% end
%  polavg.cop = polavg.cop - ap.cop_smooth'*ones(size(polavg.time));
%  polavg.crs = polavg.crs - ap.crs_smooth'*ones(size(polavg.time));

ap_out.cop =  interp1(ap.range, ap.cop_smooth', range,'nearest','extrap');
ap_out.crs =  interp1(ap.range, ap.crs_smooth', range,'nearest','extrap');