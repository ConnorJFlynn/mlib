function [good, P_bar] = rbifitx(X,Y,M,step,good,fig);
%good = rbifitx(X,Y,M,step,good,fig);
% compute a best line bifit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed
if (isrow(X)&&iscolumn(Y))||(isrow(Y)&&iscolumn(X))
   % flip Y? Is there any benefit to havein both row to both column?
   Y = Y';
end

if ~isavar('good')||isempty(good)
   good = true(size(X));
   good = ~isnan(X)&~isnan(Y);
end
   N = 1;
if ~isavar('M')||isempty(M)
   M = 6;
end
if ~isavar('step')||isempty(step)
   step = 1;
end
[P_bar] = bifit(X(good),Y(good));

val = polyval(P_bar,X);
new_good = good;
for x = 1:step
   good_i = find(new_good);
   AD = abs(val - Y); [maxAD,mi] = max(AD(new_good));
   MAD = mean(AD(good));

   new_good(good_i(mi)) = AD(good_i(mi))<(M.*MAD);
end
% new_good = (AD < (M.*MAD))&good;
   if isavar('fig')&&isgraphics(fig)
      figure_(fig);
   elseif isavar('fig')&&isempty(fig)
      figure;
   end
   if isavar('fig')
   plot(X(new_good), Y(new_good), 'k.',X(good), Y(good), 'r.',[0,max(X)], [0,max(X)],'k--',  [0,max(X)], polyval(P_bar,[0,max(X)]),'b-'); 
   end
if sum(good)>sum(new_good)
   if isavar('fig')
   plot(X(new_good), Y(new_good), 'k.',X(good), Y(good), 'r.',[0,max(X)], [0,max(X)],'k--',  [0,max(X)], polyval(P_bar,[0,max(X)]),'b-'); 
   title(['Keep(',num2str(sum(new_good)),'), maxAD/MAD(',sprintf('%2g',maxAD./MAD),')'])
   [good, P_bar] = rbifitx(X,Y,M,step,new_good,fig);
   else
   [good, P_bar] = rbifitx(X,Y,M,step,new_good);   
   end
end

% compute a best line fit
% compute the mean absolute deviation from this best line
% re-compute best line fit excluding points with absolute deviation
% greater than 6 MAD.
% Iterate until no points removed?

return