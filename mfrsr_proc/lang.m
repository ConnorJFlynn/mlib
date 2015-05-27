function [Vo, tau,P,S,Mu,delta] = lang(airmass, V);
%[Vo, tau,P,S,Mu,delta] = lang(airmass, V);
% normal (weighted) langley
   [P,S,Mu] = polyfit(airmass',real(log(V')),1);
   tau = -P(1);
   [lnVo, lndelta] = polyval(P,0,S,Mu);
   Vo = exp(lnVo);
   delta = exp(lndelta);
%    disp([   lndelta ./ lnVo , delta./Vo, (lndelta.*Vo)./(delta.*lnVo)])
%    disp('%')
return
