function prede = prede_sky_scans(prede);
%read a structure containing raw prede scans, convert to ALM, PPL with
%scattering angle

%    prede.(sky_mode).azi(rec) = C{2};
%    prede.(sky_mode).elev(rec) = C{3};

if isfield(prede,'H')
   for scan = length(prede.H):-1:1
   prede.alm(scan).time = prede.H(scan).time;
   [Zen_Sun,Az_Sun, soldst, HA_Sun, Decl_Sun, Elev_Sun, airmass] = sunae(prede.lat, prede.lon, prede.H(scan).time);
   ZA = 90-prede.H(scan).elev;
   Azi = prede.H(scan).azi;
x=(cos(ZA*pi()/180)).^2 + (sin(ZA*pi()/180)).^2.*cos((Azi-Az_Sun)*pi()/180);
SA=acos(x)*180/pi();
    if max(Az_Sun) < 180
        alm_r = (Azi>Az_Sun)&(Azi<(Az_Sun+180));
        alm_l = ~alm_r;
        alm_r = alm_r;
        alm_r = alm_r | ((Azi>Az_Sun));
    else
        alm_l = (Azi<Az_Sun)&(Azi>(Az_Sun-180));
        alm_r = ~alm_l;
        alm_l = alm_l;
        alm_l = alm_l | ((Azi<Az_Sun));
    end
    ii_alm_r = find(alm_r);
    %As the sun moves, but our programmed steps do not sometimes we may see the
    %last point cross legs.  The following code puts it back.
%     [mx,i] = max(diff(time(ii_alm_r)));
%     if mx>0.01
%         time(ii_alm_r(i+1))
%         alm_r(ii_alm_r(i+1))= false;
%         alm_l(ii_alm_r(i+1))= true;
%     end
     SA(alm_l) = -1*SA(alm_l);
   prede.alm(scan).SA = SA;
   prede.alm(scan).alm_l = alm_l;
   prede.alm(scan).alm_r = alm_r;
   prede.alm(scan).Zen_Sun = Zen_Sun;
   prede.alm(scan).Elev_Sun = Zen_Sun - 90;
   prede.alm(scan).Az_Sun = Az_Sun;
   prede.alm(scan).airmass = airmass;
   prede.alm(scan).soldst = mean(soldst);
   for f = prede.numFilters:-1:1
      prede.alm(scan).(['filter_',num2str(f)]) = prede.H(scan).(['filter_',num2str(f)]);
   end
   end
   % [Zen_Sun,Az_Sun, soldst, HA_Sun, Decl_Sun, Elev_Sun, airmass] 
end
if isfield(prede,'V')
   for scan = length(prede.V):-1:1
   prede.ppl(scan).time = prede.V(scan).time;
   [Zen_Sun,Az_Sun, soldst, HA_Sun, Decl_Sun, Elev_Sun, airmass] = sunae(prede.lat, prede.lon, prede.V(scan).time);
   ZA = 90-prede.V(scan).elev;
   Elev = prede.V(scan).elev;
   Azi = prede.V(scan).azi;
   below=(Elev<Elev_Sun);
   above=(Elev>Elev_Sun);
   SA = Elev - Elev_Sun; %scat ang = SZA - ZA(corrected)
   prede.ppl(scan).SA = SA;
   prede.ppl(scan).above = above;
   prede.ppl(scan).below = below;
   prede.ppl(scan).Zen_Sun = Zen_Sun;
   prede.ppl(scan).Elev_Sun = Elev_Sun;
   prede.ppl(scan).Az_Sun = Az_Sun;
   prede.ppl(scan).airmass = airmass;
   prede.ppl(scan).soldst = mean(soldst);
      for f = prede.numFilters:-1:1
      prede.ppl(scan).(['filter_',num2str(f)]) = prede.V(scan).(['filter_',num2str(f)]);
      end
   end
end
