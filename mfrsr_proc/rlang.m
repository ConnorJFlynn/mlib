function [Vo, tau,P,good] = rlang(airmass, V, stdev_mult,display_Nth);
%[Vo, tau,P,fit_test] = rlang(airmass, V, stdev_mult,display_Nth);;
% robust (weighted) langley
% [P,fit_test,cf_] = fit(airmass',real(log(V')),fittype('poly1'));
% tau = -P.p1;
% Vo = exp(feval(P, 0));
if ~exist('stdev_mult','var')
   stdev_mult=2.5;
end
if ~exist('display_Nth','var')
   N = 0;
else
   N = floor(double(display_Nth+(1)));
end
good = true(size(airmass));
goods = sum(good);

done = false;
logV = real(log(V));
nn = 0;
   [P] = polyfit(airmass(good)',logV(good)',1);
   dev(good) =  (logV(good) - polyval(P, airmass(good)));
   sdev = std(dev(good));
   tau = -P(1);
   Vo = exp(polyval(P,0));
   mad = max(abs(dev(good)));
   
   figure_(1001);
   scatter(airmass(good), V(good), 5,abs(dev(good))/sdev);colorbar;
   logy;
   title(['goods=',num2str(goods),' std=',num2str(sdev),' Vo=',num2str(Vo),...
      ', Loop until ',sprintf('%2.1e',max(abs(dev(good)))), '<',sprintf('%2.1e',stdev_mult*sdev)]);
   % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
   hold('on');
   plot( airmass(good), exp(polyval(P, airmass(good))),'r')
   hold('off');
   

while ~done 
   nn = nn+1;
   [P] = polyfit(airmass(good)',logV(good)',1);
   dev(good) =  (logV(good) - polyval(P, airmass(good)));
   sdev = std(dev(good));
   tau = -P(1);
   Vo = exp(polyval(P,0));
   mad = max(abs(dev(good)));
   quiet = mod(nn,N)~=0;
   if ~quiet
      figure_(1001);
      scatter(airmass(good), V(good), 5,abs(dev(good))/sdev);colorbar;
      logy;
      title(['goods=',num2str(goods),' std=',num2str(sdev),' Vo=',num2str(Vo),...
         ', Loop until ',sprintf('%2.1e',max(abs(dev(good)))), '<',sprintf('%2.1e',stdev_mult*sdev)]);
      % semilogy(airmass(good), V(good), 'g.',airmass(~good), V(~good), 'rx', airmass, exp(polyval(P, airmass)),'b');
      hold('on');
      plot( airmass(good), exp(polyval(P, airmass(good))),'r')
      hold('off');
   end
   done = max(abs(dev(good)))<(stdev_mult*sdev);    
   good(good) = abs(dev(good))<mad;
   goods = sum(good); 
end
return
