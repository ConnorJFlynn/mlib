function [dVdlnr]=dVdlnr_lognorm_remer(radius,coeff)

rmv_array = [0.13 0.21 1.5 13.0];   %Remer volume modal radii for 4 modes
sigma_array = [0.6 0.5 0.3 1.1];	  %Remer sigma values for 4 modes

dVdlnr=zeros(size(radius));
index=find(coeff>0);

for imode = 1:size(index,2),
   
   rmv=rmv_array(index(imode));
   sigma=sigma_array(index(imode));
   
   % Calculate the coefficient
	A = coeff(index(imode))/(sigma.*sqrt(2*pi));
   
   dVdlnr = dVdlnr + A .* exp(-0.5.*((log(radius)-log(rmv))/sigma).^2);	
   
end
