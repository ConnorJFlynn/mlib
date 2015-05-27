function ap_out = ap_isdac2(range);
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