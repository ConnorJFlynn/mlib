function [under_P,rsqr_under,rh_dry] = fitrh_under_2p(rh_for_fit,obs,order);
% generates an nth order polyfit for frh with respect to 1/coRH 
if ~exist('order','var')
   order = 2;
end
XX = 1-rh_for_fit./100;
under_XX = 1./XX;
under_XX = [1,under_XX];
obs = [1,obs];
under_P = polyfit(under_XX,obs,order);
rsqr_under = R_squared(obs,polyval(under_P,under_XX));
P_dry(end) = under_P(end)-1;
under_co_roots = roots(P_dry);
co_roots = 1./under_co_roots;
rh_dry = 100.*(1-co_roots);
         
      