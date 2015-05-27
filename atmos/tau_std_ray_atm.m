function tau = tau_std_ray_atm(um);
% tau = tau_ray(um);
% Returns Rayleigh optical depth for standard atmosphere versus lambda in
% um. 
% Hansen and Travis, 1974
tau = 0.008569 * um.^(-4) .* (1.0 + (0.0113 .* um.^(-2)) + (0.00013 .* um.^(-4)));