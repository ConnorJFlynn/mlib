function goods = inner(t,f);
% goods = inner(t,f)
% Applies a inner quartile screen or arbitrary fraction f
if ~exist('f','var')
    f = 0.25;
end
goods = false(size(t));
Q = max([1,floor(length(t).*f);]);
[ts,ind] = sort(t);
goods((ind(Q:(end-Q)))) = true;
% figure; plot(t,Io,'r.',t(goods),Io(goods),'go'); datetick('keeplimits')