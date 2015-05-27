function [phi, uzen, sa, full_sa,pp] = plot_iout21(w)
rows = find(w==10);
%First several rows are useless to us
% Fourth row has nphi, nuzen
str = w(rows(1):rows(2));
[nphi, count, errmsg, nextindex] = sscanf(str,'%d',1);
[nuzen, count, errmsg, nextindex] = sscanf(str(nextindex:end),'%d',1);
str = w(rows(2):end);
[phi, count, errmsg, nextindex] = sscanf(str,'%e',nphi);
str = str(nextindex:end);
[uzen, count, errmsg,nextindex] = sscanf(str, '%e', nuzen);
str = str(nextindex:end);
uurs = zeros([nphi, nuzen]);
[temp, count, errmsg,nextindex] = sscanf(str, '%e', nphi*nuzen);
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