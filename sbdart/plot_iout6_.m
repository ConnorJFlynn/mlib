function out = plot_iout6_(out,QRY,fig)
rows = find(w==10);
%First several rows are useless to us
% Fourth row has nphi, nuzen

if (nphi > 1)&&(nuzen==1) % then it is PPL?
   zen = (180 - uzen);
   PHI = [zeros(size(zen))+phi(1); zeros(size(zen))+phi(2)];
   ZEN = [zen; flipud(zen)];
   pp = [uurs(:,1); flipud(uurs(:,2))];
   SA = scat_ang_degs(out.SZA, 0, ZEN,PHI);
   sa = out.SZA - zen;
   full_sa = [sa; sa + 90];
   above = full_sa>0;
   out.SA = SA;
   out.above = above;
   out.rad = pp;
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig); semilogy(SA(above), pp(above),'-',-SA(~above), pp(~above), '-');
      legend('above','below')
      xlabel('scattering angle');
      ylabel('radiance W/m^2/nm/sr');
      title({['Principal Plane Scan: ',sprintf('SZA = %2.1f deg',out.SZA)];...
         [sprintf('Wavelength = %1.0f nm,',1e3.*out.wl), sprintf(' AOD = %1.2f',out.aod), sprintf(', SSA = %1.2f',out.ssa)]})

      figure_(fig.Number+1); semilogy(SA(above), pp(above),'-',SA(~above), pp(~above), '-');
      xlabel('scattering angle');legend('above','below')
      ylabel('radiance W/m^2/nm/sr');
      title({['Principal Plane Scan: ',sprintf('SZA = %2.1f deg',out.SZA)];...
         [sprintf('Wavelength = %1.0f nm,',1e3.*out.wl), sprintf(' AOD = %1.2f',out.aod), sprintf(', SSA = %1.2f',out.ssa)]})
   end

elseif nuzen>1 & nphi==1 % then is is ALM?
   zen = (180 - uzen);
   PHI = [phi(phi>=180)-360;phi(phi<180)];
   rad = [uurs(phi>=180),uurs(phi<180)]';
   SA = scat_ang_degs(out.SZA, 0, zen.*ones(size(PHI)),PHI);
   if isavar('fig')&&~isempty(fig)&&isgraphics(fig)
      figure_(fig); plot(PHI(PHI>=0), rad(PHI>=0),'-');
      xlabel('scattering angle');
      ylabel('radiance W/m^2/nm/sr');
      title({['Almucantar Scan: ',sprintf('SZA = %2.1f deg',out.SZA)];...
         [sprintf('Wavelength = %1.0f nm,',1e3.*out.wl), sprintf(' AOD = %1.2f',out.aod), sprintf(', SSA = %1.2f',out.ssa)]})
   end
   out.zen = zen;
   out.PHI = PHI;
   out.SA = SA;
   out.rad = rad;

elseif nuzen==1 & nphi==1 % Single point, often zenith
   zen = (180 - uzen);
   PHI = [phi(phi>=180)-360;phi(phi<180)];
   rad = [uurs(phi>=180),uurs(phi<180)]';
   SA = scat_ang_degs(out.SZA, 0, zen.*ones(size(PHI)),PHI);
   out.zen = zen;
   out.PHI = PHI;
   out.SA = SA;
   out.rad = rad;
else nphi>1 & nuzen>1 % hybrid or hemispheric
zen = (180 - uzen);
for z = length(zen):-1:1
   out.SA(z,:) = scat_ang_degs(out.SZA, 0, zen(z).*ones(size(phi)),phi);
end
% figure; lines = plot(phi,uurs','-'); recolor(lines,zen);
% figure; lines = plot([phi(phi<=180); phi(phi>180)-360],uurs','-'); recolor(lines,zen)
end
   PHI = [phi(phi>=180)-360;phi(phi<180)];
   rad = [uurs(phi>=180),uurs(phi<180)]';
   out.phi = phi;
   out.zen = zen;
   out.PHI = PHI;
   out.uurs = uurs;
   out.rad = rad;
end