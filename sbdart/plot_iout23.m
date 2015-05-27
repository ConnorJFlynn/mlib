function [phi, uzen, sa, full_sa,pp] = plot_iout23(w)
rows = find(w==10);
str = w(rows(1):rows(2));
[row1, count, errmsg, nextindex] = sscanf(str,'%d',4);
if count==4
   nphi = row1(1);
   nzen = row1(2);
   nz = row1(3);
   ffew = row1(4);
end
% [nphi, count, errmsg, nextindex] = sscanf(str,'%d',1);
% [nuzen, count, errmsg, nextindex] = sscanf(str(nextindex:end),'%d',1);
str = w(rows(2):end);
[phi, count, errmsg, nextindex] = sscanf(str,'%e',nphi);
str = str(nextindex:end);
[uzen, count, errmsg,nextindex] = sscanf(str, '%e', nuzen);
str = str(nextindex:end);
[z, count, errmsg,nextindex] = sscanf(str, '%e', nz);
str = str(nextindex:end);
[fxdn, count, errmsg,nextindex] = sscanf(str, '%e', nz);
str = str(nextindex:end);
[fxup, count, errmsg,nextindex] = sscanf(str, '%e', nz);
str = str(nextindex:end);
[fxdir, count, errmsg,nextindex] = sscanf(str, '%e', nz);
str = str(nextindex:end);
uurs = zeros([nphi, nuzen,nz]);
[temp, count, errmsg,nextindex] = sscanf(str, '%e', nphi*nuzen*nz);
uurs(:) = temp;
uurs = uurs';

zen = (180 - uzen)
sa = 45 - zen;

full_sa = [sa; sa + 90];
pp = [uurs(:,1); flipud(uurs(:,2))];
figure; semilogy(full_sa, pp);
xlabel('scattering angle')
ylabel('radiance mW/m^2')
title('SZA = 45')