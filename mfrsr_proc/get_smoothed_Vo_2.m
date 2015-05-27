function Allc0 = get_smoothed_Vo_c0(Vo, langs, N);
% mfr = get_smoothed_Vo_c0(Vo, langs, N);;
% Provided with a long time series of Langley regressions and a vector of times, this
% function identifies the nearest N (20?) Langley Vos to each time, applies an
% interquartile filter, and then a lowess filter to yield the smoothed
% Vo centered on the given time.

if ~exist('N','var');
   % Define the number of nearest Langley samples to use.
   N = 20;
end

for t = length(Vo.time):-1:1
   in_Vo = ancsift(Vo,Vo.dims.time, t); 
   [before] = anc_sift(langs, langs.dims.time, find(langs.time<Vo.time(t)));
   N_in = min([length(before), N);
   in_Vo = get_smoothed_Vo(in_Vo, before, N_in);
   if ~isfield(Vo, 'c0')
      Allc0 = in_Vo;
   else
      Allc0 = anccat(Allc0, in_Vo);
   end
end