function [Vo,tau,P,good] = rlang_uw(airmass, V);
% [Vo,tau,P,fit_test] = rlang_uw(airmass, V);
% robust unweighted langley
good = true(size(airmass));
goods = sum(good);
stdev_mult=2.5;
done = false;
logV = real(log(V));
while ~done
   [P] = polyfit(1./airmass(good), real(logV(good))./airmass(good), 1);
   dev(good) =  (real(logV(good))./airmass(good) - polyval(P, 1./airmass(good)));
   sdev = std(dev(good));
   Vo = exp(P(1));
   y_int = polyval(P, 0);
   tau = -y_int;
   mad = max(abs(dev(good)))
   figure(1000);
   scatter(1./airmass(good), real(logV(good))./airmass(good), 6,abs(dev(good))./sdev);colorbar;
   title(['goods=',num2str(goods),' std=',num2str(sdev),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
   hold('on');
   plot( 1./airmass(good), polyval(P, 1./airmass(good)),'r');
   hold('off');
   done = max(abs(dev(good)))<(stdev_mult*sdev);    
   good(good) = abs(dev(good))<mad;
   goods = sum(good);  
end

return
