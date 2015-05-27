function [P, S, mu, good] = rmad_polyfit(X,Y,O,limits);
% in progress Jan 20, 2010
% robust filtered polyfit
if ~exist('limits','var')
   limits.thresh = 4;
   limits.stdev_mult=2.75;
   limits.std_max=2;

end
limits.Ntimes = max([4,ceil(length(X)./10)]);
good = isfinite(Y)&(Y>0)&(~isNaN(Y));
dev = zeros(size(good));
done = false;
figure(1001);
while ~done
   goods = sum(good);
   [P,S,mu] = polyfit(X(good),Y(good),O);
   dev(good) =  (polyval(P, X(good),S,mu)-Y(good));
   mad = mean(abs(dev(good)));
   sdev = std(dev(good));
   maxd = max(abs(dev(good)));
   val = maxd/sdev;

   std_test = sdev<limits.std_max;
   val_test = val<limits.stdev_mult;


   scatter(X(good),Y(good),48,abs(dev(good)),'filled');
   title({['Goal: stdev<',sprintf('%2.3f',limits.std_max),' max_by_std<',sprintf('%2.3f',limits.stdev_mult)],...
      [' Now: stdev=',sprintf('%2.3f',sdev),' max_by_std=',sprintf('%2.3f',val)],...
      [num2str(goods), ' points left.']},'interp','none');
   hold('on')
   plot(X(~good),Y(~good),'kx',X(good),polyval(P,X(good),[],mu),'r-');
   hold('off');
%    


   good(good) = abs(dev(good))<(limits.thresh.*mad);
   goods_ = sum(good);
   if (goods_==goods)&&(~std_test||~val_test)
         good(good) = abs(dev(good))<maxd;
            goods_ = sum(good);
            done = isempty(good(good));
         N_test = true;
      end
      
   done = goods_==goods || goods_<limits.Ntimes;
end
return

