function [good, P_bar] = rbifitn(X,Y,M,N,good,fig);
%good = rbifitn(X,Y,M,N,good);
% compute a best line bifit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% N is number of points discarded per loop.

if ~isavar('good')||isempty(good)
   good = true(size(X));
   good = ~isnan(X)&~isnan(Y);
end
if ~isavar('N')||isempty(N)
   N = 1;
end
if ~isavar('M')
   M = 6;
end
if ~isavar('pct')||isempty(pct)
   pct = 1;
end

if isavar('fig')&&isgraphics(fig)
   figure_(fig);
else
   figure; fig = gcf;
end

[P_bar] = bifit(X(good),Y(good));

val = polyval(P_bar,X(good));
[AD,ij] = sort(abs(val - Y(good)));
MAD = mean(AD);
good_ij = find(good);
for n = 0:(N-1)
   good(good_ij(ij(end-n))) = AD(end-n)<(M.*MAD);
end

if sum(good)<length(AD)
   plot(X, Y, 'k.',X(good), Y(good), 'b.',[0,max(X)], [0,max(X)],'k--',  [0,max(X)], polyval(P_bar,[0,max(X)]),'b-');
   [good, P_bar] = rbifitn(X,Y,M,N,good,fig);
end
if isempty(get(get(gca,'title'),'string'))
   title({['Keep =',num2str(sum(good)),', Exclude =', num2str(length(good)-sum(good)),' (',sprintf('%1.0f',(100.*sum(good)./length(good))),'%)'];['Y = ',num2str(P_bar(1)),'*X ',sprintf('%+1.2f',P_bar(2))]});
end


% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return