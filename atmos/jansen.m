function ray_tau = jansen(lambda_um);
% ray_tau = jansen(lamda_um);
% returns Rayleigh optical depth for atmos column as a function of
% lambda in microns
if ~exist('lambda_um', 'var')
   lambda_um = .523;
end
l2 = lambda_um .^2;
l4 = l2 .^2;
ray_tau = ( 0.008569 ./ l4 .* (1.0 + 0.0113 ./ l2 + 0.00013 ./ l4 ) );
