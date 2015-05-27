function [Io_new] = IQF_lang(t,Io, W); 
%[good] = IQF_lang(t,Io, W);  
% Applies an interquartile filter to a time series of values over a window of width W days 
% Follows the IQ with a gaussian filter of width W
full_range = [1:length(t)];
Io_new = NaN(size(Io));
useful = isfinite(Io);
for ti = length(t):-1:1
   good = useful;
   lowest = max(1,ti-floor(W/2));
   highest = min(length(t),lowest+W);
   lowest = max(1,highest - W);
   subrange = [lowest:highest];
   good(setdiff(full_range, subrange)) = false;
   ts = t(good);
   Is = Io(good);
   goods = IQ(Is);
   P = gaussian(ts(goods),t(ti),W);
   Io_new(ti) = trapz(ts(goods),Is(goods).*P)./trapz(ts(goods),P);
%   plot(t,Io,'k.',t(good),Io(good),'r.',ts(goods),Is(goods),'g.',t,Io_new,'bo')
end   
