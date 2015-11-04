% LogNormal(diam, cmd, gsd) returns dN/dlogD given range of diam.
% Note that gsd will be transformed to log(gsd) 
function df=LogNormal(diam, mu, gsd)

if nargin<1
    help LogNormal
    return
end
loggsd = log10(gsd);

df = exp(- ((log10(diam/mu)).^2)./(2*loggsd^2)) / (sqrt(2*pi) * loggsd);
% Co = cip.vars.aerosol_particle_volume_concentration.data(good);
% Ro = cip.vars.volume_median_radius.data(good);
% sigma_o  = .7;
%  dVdlnr_o = exp( -((log(r./Ro(n))).^2)./(2*sigma_o.^2)) .* (Co(n)./(sqrt(2*pi).*sigma_o)).*;
return

