function [frh, rh_dry] = fitrh_3p(rh,a,b,c);
% computes frh for 3 parameter fit bsp(RH%)/bsp(~40%)=a[1+b(RH%/100)^c] 
% also returns corresponding rh_dry where fRH == 1
if any(rh>1)
   rh = rh./100;
end
frh = a .* (1 + b .* (rh.^c));
rh_dry = 100.*(((((1./a)-1)./b).^(1./c)));