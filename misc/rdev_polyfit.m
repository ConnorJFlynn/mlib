function [P, S, mu, w] = rdev_polyfit(X,Y,O,limits);
% in progress Jan 20, 2010
% robust filtered polyfit
% Observation on Jan 27 2011: this seems to only remove points falling
% below the fit line, leaving positive outliers intact.  Possibly this was
% desired?  rmad_polyfit removes both positive and negative outliers.
if ~exist('limits','var')
   limits.stdev_mult=2.75;
   limits.std_max=0.025;
   limits.steps = 1;
end
limits.Ntimes = ceil(length(X)./10);
good = isfinite(Y)&(Y>0)&(~isNaN(Y));
goods = sum(good);
done = false;
while ~done
   [P,S,mu] = polyfit(X(good),Y(good),O);
   dev(good) =  (polyval(P, X(good),S,mu)-Y(good));
   mad = mean(abs(dev(good)));
   sdev = std(dev(good));
   val = max(abs(dev(good)))/sdev;
   N_test =  sum(good) < limits.Ntimes ; % This is the abort condition
   std_test = sdev<limits.std_max;
   val_test = val<limits.stdev_mult;
   done = N_test || (std_test&&val_test);
   
   figure(1001);
   scatter(X(good),Y(good),50,abs(dev(good)),'filled');
   hold('on');
   plot(X,polyval(P,X,[],mu),'r-');
   hold('off');
   if ~done
      for s = 1:limits.steps
         good(good) = (dev(good))<mad;
         goods = sum(good);
         mad = max((dev(good)));
      end
      done = isempty(good(good));
      N_test = true;
   end
end


