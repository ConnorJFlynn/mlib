function [Vo, tau,P,good] = rlang(airmass, V);
%[Vo, tau,P,fit_test] = rlang(airmass, V);
% robust (weighted) langley
% [P,fit_test,cf_] = fit(airmass',real(log(V')),fittype('poly1'));
% tau = -P.p1;
% Vo = exp(feval(P, 0));
good = true(size(airmass));
goods = sum(good);
stdev_mult=2.5;
done = false;
logV = real(log(V));
while ~done
   [P] = polyfit(airmass(good)',logV(good)',1);
   dev(good) =  (logV(good) - polyval(P, airmass(good)));
   sdev = std(dev(good));
   tau = -P(1);
   Vo = exp(polyval(P,0));
   mad = max(abs(dev(good)));
   figure(1001);
   scatter(airmass(good), V(good), 5,abs(dev(good))/sdev);colorbar;
   logy;
   title(['goods=',num2str(goods),' std=',num2str(sdev),' Vo=',num2str(Vo),' tau=',num2str(tau)]);
   % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
   hold('on');
   plot( airmass(good), exp(polyval(P, airmass(good))),'r')
   hold('off');
   done = max(abs(dev(good)))<(stdev_mult*sdev);    
   good(good) = abs(dev(good))<mad;
   goods = sum(good); 
end
return
