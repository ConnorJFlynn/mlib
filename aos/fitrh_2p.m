function [frh, rh_dry] = fitrh_2p(rh,a,b);
% computes frh for 2 parameter fit bsp(RH%)/bsp(~40%)=a*[1-(RH%/100)]^-b 
% also returns corresponding dry RH where fRH == 1;
if any(rh>1)
   rh = rh./100;
end
frh = a.*((1-rh).^(-b));
rh_dry = (1-((1./a).^(-1./b)))*100;