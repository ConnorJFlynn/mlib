function mfr = get_daily_Vo(mfr, langs, N);
% mfr = get_daily_Vo(mfr, langs);
% Provided with a daily mfr file and long time series of Langley regressions, this 
% function identifies the nearest N Langley Vos, applies an
% interquartile filter, and then a lowess filter.
% N defaults to 20

% applies a sliding window interquartile filter to the Vo values from 500 nm
% to identify a robust subset of available Vo values.  
% and lowess smoothing to yield the smoothed Vo for that day.  Could
% even do a sliding one over the day if desired.

if ~exist('N','var');
   % Define the number of nearest Langley samples to use.
   N = 20;
end

% Ray_OD is currently unused but could be used to help screen Vo
% if corresponding tau was less than Rayleigh...
Ray_OD = [ 0.0 , 415.00 , 500.00 ,615.00 ,673.00 ,870.00 ,940.00;
0.03, 0.309115, 0.143586, 0.0617444, 0.0428391 ,0.0151840 ,0.0111175]';

center_time = mean(mfr.time);
[dmp, proximity] = sort(abs(langs.time - center_time));

closest.time = langs.time(sort(proximity(1:N)));
for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
   chan = char(ch);
   closest.(['Vo_',chan]) = langs.vars.(['Vo_',chan]).data(sort(proximity(1:N)));
end
% Form interquartile only with Filter 2 since it is most immune to
% interferences.  
[sorted_Vo, ind] = sort(closest.Vo_filter2);
mark = floor(length(ind)/4)+1;
Q = ind(mark:(end-mark));
Q = sort(ind(mark:(end-mark)));
robust.time = closest.time(sort(ind(Q:(end-Q))));
for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
   chan = char(ch);
   robust.(['Vo_',chan]) = closest.(['Vo_',chan])(sort(ind(Q:(end-Q))));
   y.(chan) = smooth(serial2doy0(robust.time),robust.(['Vo_',chan]),.99, 'lowess')';
   y_interp.(chan) = interp1(robust.time, y.(chan), mfr.time,'spline', 'extrap')';
   mfr.vars.(['Vo_',chan]) = mfr.vars.(['cordirnorm_',chan]);
   mfr.vars.(['Vo_',chan]).data = y_interp.(chan)';
   mfr.vars.(['Vo_',chan]).atts = langs.vars.(['Vo_',chan]).atts;
   mfr.vars.(['Vo_',chan]).id = ceil(max(id_list(mfr.vars))+1);
end

% 
