%compute multi-modal log-normal size distribution dN(r)/dr according to 
%Hansen, J. E., and L. D. Travis, Light scattering in planetary atmospheres, Space Sci. Rev., 16, 527-610, 1974.

function [dNdr]=lognorm(r,N,r_mode,sigma,n_modes);

for i_mode=n_modes:-1:1
dNdr(i_mode,:)=N(i_mode)./(r*sigma(i_mode)*sqrt(2*pi)).*exp(-0.5*((log(r)-log(r_mode(i_mode)))/sigma(i_mode)).^2);
sigma_test=(trapz(r,(log(r)-log(r_mode(i_mode))).^2.*dNdr(i_mode,:))./N(i_mode)).^0.5
N_test=trapz(r,dNdr(i_mode,:))
end
dNdr=sum(dNdr,1);

 
figure(3)
loglog(r,dNdr,'.-')
axis([.1 1 1e-4 inf])

return

% for i_mode=n_modes:-1:1
%  dNdr(i_mode,:) =N(i_mode)./(r*log(sigma(i_mode))*sqrt(2*pi)).*exp(-0.5*((log(r)-log(r_mode(i_mode)))/log(sigma(i_mode))).^2);
% %  dNdr_(i_mode,:)=N(i_mode).*exp(-0.5*((log(r./r_mode(i_mode)))/sigma(i_mode)).^2)./(r*sigma(i_mode)*sqrt(2*pi));
%  % df_ =                   exp(-0.5.*((log10(diam/mu)./loggsd).^2)) ./ (sqrt(2*pi) * loggsd);
%  sigma_test=(trapz(r,(log(r)-log(r_mode(i_mode))).^2.*dNdr(i_mode,:))./N(i_mode)).^0.5
%  N_test=trapz(r,dNdr(i_mode,:))
% end
% dNdr=sum(dNdr,1);
% 
% % 
% % figure
% % plot(r,r.*dNdr,'r-')
% % % axis([.1 1 1e-4 inf])
% 


