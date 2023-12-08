function out = plot_iout6(input,w,fig)
rows = find(w==10);
%First several rows are useless to us
% Fourth row has nphi, nuzen



A = textscan(w(rows(3):rows(4)),'%f'); A = A{1};
out.wl =A(1); out.ffv = A(2);
out.BOTDN = A(6); out.BOTDIR = A(8);
out.BOTDIF = out.BOTDN-out.BOTDIR; out.DIRN2DIF = out.BOTDIR./out.BOTDIF;

str = w(rows(4):rows(5));
[nphi, count, errmsg, nextindex] = sscanf(str,'%d',1);
[nuzen, count, errmsg, nextindex] = sscanf(str(nextindex:end),'%d',1);
str = w(rows(5):end);
[phi, count, errmsg, nextindex] = sscanf(str,'%e',nphi);
str = str(nextindex:end);
[uzen, count, errmsg,nextindex] = sscanf(str, '%e', nuzen);
out.zen =(180 - uzen); out.zen = [out.zen; -flipud(out.zen)];
str = str(nextindex:end);
uurs = zeros([nphi, nuzen]);
[temp, count, errmsg,nextindex] = sscanf(str, '%e', nphi*nuzen);
uurs(:) = temp;
uurs = uurs';
out.SZA = input.SZA;
if isfield(input,'TBAER')
   out.aod = input.TBAER;
elseif isfield(input,'QBAER')
   out.aod = input.QBAER;
end
if ~isfield(input,'ABAER')
   if isfield(input,'QBAER')&&length(input.QBAER)>1
      input.ABAER = ang_exp(input.QBAER(1), input.QBAER(2),input.WLBAER(1),input.WLBAER(2));
   elseif isfield(input,'TBAER')&&length(input.TBAER)>1
      input.ABAER = ang_exp(input.TBAER(1), input.TBAER(2),input.WLBAER(1),input.WLBAER(2));
   else
      input.ABAER = 1;
   end
end
out.aod = ang_coef(input.QBAER(1), input.ABAER, input.WLBAER(1), out.wl);
if length(input.WLBAER)>1 & length(input.WBAER)>1
   out.ssa = polyval(polyfit(input.WLBAER, input.WBAER, 1),out.wl);
else
   out.ssa = input.WBAER;
end
if nphi < nuzen % then it is PPL?
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

elseif nuzen>nphi % then is is ALM?
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

elseif nuzen==1
   zen = (180 - uzen);
   PHI = [phi(phi>=180)-360;phi(phi<180)];
   rad = [uurs(phi>=180),uurs(phi<180)]';
   SA = scat_ang_degs(out.SZA, 0, zen.*ones(size(PHI)),PHI);
   out.zen = zen;
   out.PHI = PHI;
   out.SA = SA;
   out.rad = rad;
end

end