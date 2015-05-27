function [good] = IQF_span(Io, N); 
%[good] = IQF_span(Io, N);   
% This may still have the inherent error of previous IQF in that it
% attempts to report a final boolean vector where none is applicable.
% Rather, it should probably report some weighted value instead of boolean
% flag.
% Applies an interquartile filter to a collection of values over a span of N points.
% This is distinct from IQF_lang in that there is no reference to time.
% Points are simply taken sequentially, but non-finite points are excluded.
% Returns a boolean vector of length(Io).
good = isfinite(Io);
good_inds = find(good);
UL = floor(length(good_inds)/N)*N;
for UL = floor(length(good_inds)/N)*N : -N:N
   win = [UL-(N-1):UL];
   goods = IQ(Io(win));
   good(win) = good(win)&goods;
end   
% figure(1); plot([1:length(Io)],Io,'b.',[1:length(Io(good))],Io(good),'go'); datetick('keeplimits')
