function good = radf_bifit(X,Y,M,pct,good);
%good = radf_bifit(X,Y,M,pct,good);
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
if ~isavar('M')
   M = 6;
end
if ~isavar('pct')||isempty(pct)
   pct = 1;
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
   good(new_good) = radf_bifit(X(new_good),Y(new_good),M,pct,good(new_good));
end
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return