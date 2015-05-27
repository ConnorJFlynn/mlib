function [Io_new] = IQF_madf_span(t,Io, W); 
%[good] = IQF_madf_span(t,Io, W);   
% Applies a madf filter and an interquartile filter to a time series of values over a window of width W days 
% Follows the IQ with a gaussian filter of width W
full_range = [1:length(t)];
Io_new = NaN(size(Io));
useful = isfinite(Io);
for ti = length(t):-1:1
   span = t>=(t(ti)-floor(W/2)) & t<=(t(ti)+floor(W/2));
%    good = useful;
%    lowest = max(1,ti-floor(W/2));
%    highest = min(length(t),lowest+W);
%    lowest = max(1,highest - W);
%    subrange = [lowest:highest];
%    good(setdiff(full_range, subrange)) = false;

   ts = t(span);
   Is = Io(span);
   w = madf(Is,2); ts = ts(w);Is = Is(w);
%    gw = gmadf(Is);
   goods = IQ(Is);
   P = gaussian(ts(goods),t(ti),W);
   if length(P)>1
   Io_new(ti) = trapz(ts(goods),Is(goods).*P)./trapz(ts(goods),P);
   else
      Io_new(ti) = 0;
   end
   disp(ti)
%    plot(serial2doy(t),Io,'k.',serial2doy(t(span)),Io(span),'r.',serial2doy(ts(goods)),Is(goods),'g.',serial2doy(t),Io_new,'bo')
end   
