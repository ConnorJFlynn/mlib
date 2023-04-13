function [good, P_bar] = rbifit(X,Y,M,pct,good,fig);
%good = rbifit(X,Y,M,pct,good);
% compute a best line bifit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?
if ~isavar('good')
   good = true(size(X));
   good = ~isnan(X)&~isnan(Y);
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
MAD = mean(AD(good>0));
new_good = (AD < (M.*MAD))&good;
   if isavar('fig')&&isgraphics(fig)
      figure_(fig);
   else
      figure;
   end
   plot(X(new_good), Y(new_good), 'k.',X(good), Y(good), 'rx',[0,max(X)], [0,max(X)],'k--',  [0,max(X)], polyval(P_bar,[0,max(X)]),'b-'); 
 
if abs(sum(good)-sum(new_good))/sum(good) > (pct./100)
   plot(X(new_good), Y(new_good), 'k.',X(good), Y(good), 'rx',[0,max(X)], [0,max(X)],'k--',  [0,max(X)], polyval(P_bar,[0,max(X)]),'b-'); 
   title(['Keep(',num2str(sum(new_good)),'), Remove(',sprintf('%2.1g%%',100.*(sum(good)-sum(new_good))./sum(good)),')'])
   good = rbifit(X,Y,M,pct,new_good,gcf);
end
% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return