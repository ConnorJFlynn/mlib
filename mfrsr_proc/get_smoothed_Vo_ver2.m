function Vo = get_smoothed_Vo_ver2(time, langs, N);
% mfr = get_daily_Vo(time, langs);
% Provided with a vector of times and time series of Langley regressions, this
% function identifies the nearest N (default 20) Langley Vos to each time, applies an
% interquartile filter, and then a lowess filter to yield the smoothed
% Vo centered on the given time.

if ~exist('N','var');
   % Define the number of nearest Langley samples to use.
   N = 20;
end

% Ray_OD is currently unused but could be used to help screen Vo
% if corresponding tau was less than Rayleigh...
Ray_OD = [ 0.0 , 415.00 , 500.00 ,615.00 ,673.00 ,870.00 ,940.00;
   0.03, 0.309115, 0.143586, 0.0617444, 0.0428391 ,0.0151840 ,0.0111175]';
Vo.dims = langs.dims;
Vo.recdim = langs.recdim;
Vo.time = time;

for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
   chan = char(ch);
   Vo.vars.(chan).dims = {'time'};
end
Vo.vars.(chan).dims = {'time'};

% Find good langleys from entire time series.
good = find(~isnan(langs.vars.michalsky_solar_constant_sdist_filter2.data) ...
   &~isnan(langs.vars.michalsky_solar_constant_sdist_filter5.data) ...
   &(langs.vars.michalsky_solar_constant_sdist_filter2.data>0) ...
   &(langs.vars.michalsky_solar_constant_sdist_filter5.data>0) ...
   &(langs.vars.michalsky_optical_depth_filter2.data>Ray_OD(3,2)) ...
   &(langs.vars.michalsky_optical_depth_filter5.data>Ray_OD(6,2)));
Vo_2 = langs.vars.michalsky_solar_constant_sdist_filter2.data(good);
tic
for t = length(Vo.time):-1:1;
   [dmp, nearest] = sort(abs(time(t) - langs.time(good)));
   % Identify closest N langleys
   % Sort them chronologically (Lowess needs this)
   nearby = sort(nearest(1:N));
   closest.time = langs.time(good(nearby));
   for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
      chan = char(ch);
      closest.(['Vo_',chan]) = langs.vars.(['michalsky_solar_constant_sdist_',chan]).data(good(nearby));
   end
   closest.Vo_2 = Vo_2(nearby);
   % Form interquartile of Filter 2 / Filter 5 ratio since these
   % channels are most robust and ratio removes some variability

   %    [sorted_Vo, ind] = sort(closest.Vo_filter2);
   [sorted_Vo, ind] = sort(closest.Vo_2);
   mark = floor(length(ind)/6)+1;
   Q = ind(mark:(end-(2*mark)));
   Q = sort(Q);
   robust.time = closest.time(Q);
   for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
      chan = char(ch);
      robust.(['Vo_',chan]) = closest.(['Vo_',chan])(Q);
      y.(chan) = smooth(serial2doy0(robust.time),robust.(['Vo_',chan]),.5, 'rlowess')';
      Vo.vars.(chan).data(t) = interp1(robust.time, y.(chan), Vo.time(t),'spline', 'extrap')';
   end
end
   for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
      chan = char(ch);
      Vo.vars.(chan).data = smooth(Vo.time,Vo.vars.(chan).data,.1,'lowess')';
   end
%    for ch = {'broadband', 'filter1', 'filter2', 'filter3', 'filter4', 'filter5', 'filter6'}
%       chan = char(ch);
%       Vo.vars.(chan).data = smooth(serial2doy0(Vo.time),Vo.vars.(chan).data,.1, 'lowess')';
%    end
%
