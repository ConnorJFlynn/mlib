function [good] = IQF(t,Io, W); 
%[good] = IQF(langs, W); 
% deprecated, use IQF_lang instead
% Applies an interquartile filter over a window of width W days to the
% supplied time series of langleys. Returns a boolean vector of length(langs).
disp(['IQF is deprecated. Use IQF_lang']);
good = isfinite(Io);
good_inds = find(good);
old_win = [good_inds(1),good_inds(end)];
for UL = ceil(t(good_inds(end))):-1:(floor(t(good_inds(1)))+W)
   LL = UL-W;
   win = find((t>=LL) &( t<=UL)&isfinite(Io));
   if any(old_win~=[win(1) win(end)])&&length(win)>12
   old_win = [win(1) win(end)];
   goods = IQ(t(win),Io(win));
   good(win) = good(win)&goods;
%    figure(1); plot(t,Io,'r.',t(win),Io(win),'b.',t(good),Io(good),'go'); datetick('keeplimits')
   end
end
% figure(1); plot(t,Io,'b.',t(good),Io(good),'go'); datetick('keeplimits')

function goods = IQ(t,Io);
goods = false(size(t));
Q = floor(length(t)/4);
[Is,ind] = sort(Io);
goods((ind(Q:(3*Q)))) = true;
% figure; plot(t,Io,'r.',t(goods),Io(goods),'go'); datetick('keeplimits')