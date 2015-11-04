% ForcEff(vac_bscat[m2/cm3], vac_abs[m2/cm3], surface_alb, cloud_frac)
% Returns forcing efficiency in watts/(cm3 aerosol)
function feff= ForcEff(vac_bscat, vac_abs, surf_alb, cloud_frac)

    if nargin<1
        help ForcEff;
        return;
    end
    
    if nargin<3
        surf_alb = 0.16;
    end;
    if nargin<4
          cloud_frac = 0.6;
    end

   atrans = 0.79;
   s0=1370;
      
   smult = -(s0/4) * atrans^2 * (1-cloud_frac); 
   feff = smult * ((1-surf_alb)^2 * 2 * vac_bscat - 4 * surf_alb * vac_abs) ;      
return
