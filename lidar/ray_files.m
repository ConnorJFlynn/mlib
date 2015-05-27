% Rayleigh profile m-files:
% Primitives: 
%    std_atm: returns T(K) and P(hPa=mB) for a standard atm
%    ray_a_b: returns Rayleigh ext and bscat coefs
%    atten_prof: returns attenuated bscat and tau profiles
% 
% Compound functions:   
%    ray_a_b_stp: returns a and b for STP at the sea level 
%       uses: ray_a_b
%    ray_atten_profs(range, T, P, wavelength)
%       uses: ray_a_b
%             atten_prof
%    std_ray_atten(range)   
%       uses: std_atm
%             ray_a_b_lenoble
%             atten_prof
%    get_sonde_ray_atten
%       uses: sonde_ray_atten
%             ray_a_b
%             atten_prof
%    sonde_std_atm_ray_atten
%       uses: ray_a_b
%             atten_prof
%       
% ray_a_b: Multiple versions implemented, currently uses ray_a_b_measures
%    ray_a_b_DP(T, P, wavelength);
%    ray_a_b_lenoble(T, P, wavelength);
%    ray_a_b_measures(T, P, wavelength);
%    ray_a_b_Ferrare_Turner(T, P, wavelength);