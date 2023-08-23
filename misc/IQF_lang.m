function [Io_new] = IQF_lang(t,Io, W);
%[Io_new] = IQF_lang(t,Io, W);
% Applies an interquartile filter to a time series of values over a window of width W days
% Follows the IQ with a gaussian filter of width W
full_range = [1:length(t)];
Io_new = NaN(size(Io));
good = isfinite(Io);
hold('on');
for ti = length(t):-1:1
   window = (t<=(t(ti)+W/2))&(t>=(t(ti)-W/2));
   %    good = useful;
   %    lowest = max(1,ti-floor(W/2));
   %    highest = min(length(t),lowest+W);
   %    lowest = max(1,highest - W);
   %    subrange = [lowest:highest];
   %    good(setdiff(full_range, subrange)) = false;
   ts = t(window&good);
   Is = Io(window&good);
   goods = IQ(Is);
   if sum(goods)>1
      P = gaussian(ts(goods),t(ti),W);
      Io_new(ti) = trapz(ts(goods),Is(goods).*P)./trapz(ts(goods),P);
   elseif sum(goods)==1
      Io_new(ti) = Is(goods);
   end
   plot(t,Io,'r.',ts,Is,'b.',ts(goods),Is(goods),'g.',t,Io_new,'k.');
%    pause(.05);
end
NaNs = isNaN(Io_new);
Io_new(NaNs) = interp1(t(~NaNs),Io_new(~NaNs), t(NaNs),'linear','extrap');
hold('off');
plot(t,Io,'r.',t(good),Io(good),'b.',t,Io_new,'k.');
return
