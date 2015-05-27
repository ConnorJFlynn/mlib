function tod_ray = tod_Rayleigh(wavelength);
% tod_ray = tod_Rayleigh(wavelength);
% returns tod_ray (total Rayleigh optical depth) computed as:
% ! Rayleigh optical thickness (tau_r) computed from Equation 7 of Gordon et al. 
% !	
% !	Gordon, H.R., J.W. Brown and R.H. Evans, 1998, "Exact Rayleigh 
% !		Scattering calculations for use with the Nimbus 7 Coastal 
% !		Zone Color Scanner", Applied Optics, 27, 862-871
% !
% ! tau_r = 0.008569 * um^(-4) * (1.0 + (0.0113 * um^(-2)) + (0.00013 * um^(-4))) 
% !   where um = wavelength in micrometers
% !

if nargin<1
   wavelength = 523e-9;
end
   if wavelength > 1 %Wavelength is probably in nm
      wavelength = 1e-9 * wavelength; % Convert from nm to m
   end

um = wavelength*1e6;
% par = (1 + (0.0113*(um.^-2)) + (.00013 * (um.^-4)));
% t_ray = (0.008569*(um.^-4)).*par;
tod_ray = (0.008569 .* (um .^(-4))) .* (1.0 + (0.0113 .* (um.^(-2))) + (0.00013 .* (um.^(-4)))) ;
% figure; plot(um, t_ray-tod_ray,'o-');
