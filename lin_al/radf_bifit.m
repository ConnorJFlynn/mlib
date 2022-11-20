function [good, P_bar] = radf_bifit(X,Y,M,pct,good);
% [good, P_bar] = radf_bifit(X,Y,M,pct,good);
% compute a best line bifit
% compute the absolute deviation from this best line
% test the top highest "pct" fraction deviants with a MAD factor M
% lower M factors exclude more points
% re-compute best line fit excluding points with absolute deviation
% Iterate until no points removed?
if ~isavar('good')
   good = true(size(X));
end
   N = 1;
if ~isavar('M')||isempty(M)
   M = 6;
end
if ~isavar('pct')||isempty(pct)
   pct = .1;
end
[P_bar] = bifit(X(good),Y(good));

val = polyval(P_bar,X);
AD = abs(val - Y);
[AD_, ij] = sort(AD); 
nd = floor(length(AD).*(1-pct./100));
keep = true(size(X)); keep(ij(nd:end)) = false;
MAD = mean(AD(good>0));
new_good = (AD < (M.*MAD))|keep;
if (sum(good)-sum(new_good))>0
   figure_(17); plot(X(good), Y(good), 'rx',X(new_good), Y(new_good), 'k.' ,[0,max(X)], polyval(P_bar,[0,max(X)]),'b--'); 
   title(['Keep(',num2str(sum(new_good)),'), Remove(',sprintf('%2.1g%%',100.*(sum(good)-sum(new_good))./sum(good)),')'])
   [good(new_good),P_bar] = radf_bifit(X(new_good),Y(new_good),M,pct,good(new_good));
end
figure_(17); clf(17); plot(X(good), Y(good), '.b' );hold('on');
axis('square'); v = axis; mx = max(v); xlim([0,mx]); ylim([0,mx]);
plot([0,mx], polyval(P_bar,[0,mx]),'r--')
plot([0,mx], [0,mx],':','color',[.5, .5,.5]); 
[P,stats] = bifit(X(good), Y(good));
   ttl =title({[sprintf('Slope=%1.2f, ',P_bar(1)),sprintf('Y_i_n_t=%1.2f',P_bar(2))]; [sprintf('Bias=%1.2f, ',stats.bias), sprintf('RMSE=%1.2f',stats.RMSE)]}); set(ttl, 'interp','tex')
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return