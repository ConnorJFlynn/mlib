function [under_P,rsqr_under,rh_dry] = fitrh_under_corh(rh_for_fit,obs,order);
% [under_P,rsqr_under,rh_dry] = fitrh_under_corh(rh_for_fit,obs,order);
% generates an nth order polyfit for frh with respect to 1/coRH 
% Use this returned polyfit to yield frh = polyval(under_P,1./(1-rh/100));
% Also returns r-squared and effective dry RH.
if ~exist('order','var')
   order = 2;
end
XX = 1-rh_for_fit./100;
under_XX = 1./XX;
under_XX = [under_XX];
obs = [obs];
under_P = polyfit(under_XX,obs,order);
rsqr_under = R_squared(obs,polyval(under_P,under_XX));
P_dry = under_P;
P_dry(end) = P_dry(end)-1;
under_co_roots = roots(P_dry);
co_roots = 1./under_co_roots;
rh_dry = 100.*(1-co_roots);
rh_dry = min(rh_dry(rh_dry>0&rh_dry<100));
         
      