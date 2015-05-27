function [good] = madf_span(Io, N, thresh); 
%[good] = MADF_span(Io, N, thresh);  
% Applies an Median Absolute Deviation filter to a collection of values over a span of N points.
% This is distinct from IQF_lang in that there is no reference to time.
% Points are simply taken sequentially, but non-finite points are excluded.
% Returns a boolean vector of length(Io).
if ~exist('thresh','var')
    thresh = 6;
end
good = isfinite(Io);
good_inds = find(good);
UL = floor(length(good_inds)/N)*N;
for UL = floor(length(good_inds)/N)*N : -N:N
   win = [UL-(N-1):UL];
   [goods] = madf(Io(win),thresh);
   good(win) = good(win)&goods;
end   
return
% figure(1); plot([1:length(Io)],Io,'b.',[1:length(Io(good))],Io(good),'go'); datetick('keeplimits')
