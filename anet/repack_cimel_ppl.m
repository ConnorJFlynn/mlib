function ppl = repack_cimel_ppl(ppl)
% ppl = repack_cimel_ppl(ppl)
% Packs a PPL scan into a struct with "rad" of dimension time x dEl
% And returns the interpolated zenith radiance for each scan.

wl = unique(ppl.Wavelength_um_);ppl.wl = wl;
flds = fieldnames(ppl);
dEl = [];rad = [];
for f = 1:length(flds)
   fld = flds{f};
   if length(fld)>2
      if strcmp('neg',fld(1:3))
         dEl_str = strrep(strrep(fld,'neg_','-'),'pt','.');
         dEl = [dEl,sscanf(dEl_str,'%f')];
         rad = [rad,ppl.(fld)];
         ppl = rmfield(ppl,fld);
      end
      if strcmp('pos',fld(1:3))
         dEl_str = strrep(strrep(fld,'pos',''),'pt','.');
         dEl = [dEl,sscanf(dEl_str,'%f')];
         rad = [rad,ppl.(fld)];
         ppl = rmfield(ppl,fld);
      end
   end
end
rad(rad<-90) = NaN;
for t = length(ppl.time):-1:1
   if sum(~isNaN(rad(t,:)))<2
      ppl.time(t) = [];
      ppl.Wavelength_um_(t) = [];
      ppl.SolarZenithAngle_degrees_(t) = [];
      rad(t,:) = [];
   else
      El = 90 - ppl.SolarZenithAngle_degrees_(t) + dEl;
      zen_rad(t) = interp1(El, rad(t,:),90,'pchip','extrap');
   end
   ppl.rad = rad;
   ppl.dEl = dEl;
   ppl.zen_rad = zen_rad';
   
   % figure;
   % t = t+1;
   % subplot(2,1,1);
   % plot(dEl, rad(t,:),'-o',ppl.SolarZenithAngle_degrees_(t),zen_rad(t),'rx')
   %
   % subplot(2,1,2);
   % plot(90 - ppl.SolarZenithAngle_degrees_(t) + dEl, rad(t,:),'-o',90,zen_rad(t),'rx')
   
end



