function Allc0 = get_smoothed_Vo_c0(time, langs, N);
% Allc0 = get_smoothed_Vo_c0(time, langs, N);
% This has an error in that it only draws from point occuring 'before'
% the time of interest.  Instead it should take the N nearest.
% Provided with a long time series of Langley regressions and a vector of times, this
% function identifies the nearest N (20?) Langley Vos to each time, applies an
% interquartile filter, and then a lowess filter to yield the smoothed
% Vo centered on the given time.

if ~exist('N','var');
   % Define the number of nearest Langley samples to use.
   N = 20;
end

for t = length(time):-1:1
   [dmp, ind] = sort(abs(langs.time - time(t)));
   [nearest] = ancsift(langs, langs.dims.time, ind(1:N));
   N_in = min([length(nearest.time), N]);
   disp(['length(nearest)= ',num2str(length(nearest.time))])
   if length(nearest.time)>4
   c0 = get_smoothed_Vo(time(t), nearest, N_in);
   if ~exist('Allc0','var')
      Allc0 = c0;
      Allc0.quiet = true;
   else
      Allc0 = anccat(Allc0, c0);
   end
   end
end