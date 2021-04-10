function [Vo,tau,P] = lang_uw(airmass, V);
% [Vo,tau,P] = lang_uw(airmass, V);
% unweighted langley as per Alder-Golden 2007
   [P] = polyfit(1./airmass, real(log(V))./airmass, 1);
   Vo = exp(P(1));
   y_int = polyval(P, 0);
   tau = -y_int;
return
% 
% % I = Io exp(-tau.*am)
% log(I) = log(Io) - tau*am
% y = log(Io) - tau(x), with x = am
% 
% log(I)/am = log(Io)/am - tau;
% let x = 1./am,  y = log(I)/am
% y = log(Io)*x - tau