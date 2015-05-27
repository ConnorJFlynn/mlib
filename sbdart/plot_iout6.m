function [phi, uzen, sa, full_sa,pp] = plot_iout6(w,input)
rows = find(w==10);
%First several rows are useless to us
% Fourth row has nphi, nuzen
str = w(rows(4):rows(5));
[nphi, count, errmsg, nextindex] = sscanf(str,'%d',1);
[nuzen, count, errmsg, nextindex] = sscanf(str(nextindex:end),'%d',1);
str = w(rows(5):end);
[phi, count, errmsg, nextindex] = sscanf(str,'%e',nphi);
str = str(nextindex:end);
[uzen, count, errmsg,nextindex] = sscanf(str, '%e', nuzen);
str = str(nextindex:end);
uurs = zeros([nphi, nuzen]);
[temp, count, errmsg,nextindex] = sscanf(str, '%e', nphi*nuzen);
uurs(:) = temp;
uurs = uurs';
SZA = sscanf(input.SZA, '%g');
tau = sscanf(input.tbaer, '%g');
zen = (180 - uzen)
sa = SZA - zen;

full_sa = [sa; sa + 90];
pp = [uurs(:,1); flipud(uurs(:,2))];
figure; semilogy(full_sa, pp);
xlabel('scattering angle');
ylabel('radiance W/m^2/nm/sr');
title(['Wavelength = 453 nm, SZA = ',num2str(SZA), ' tau = ', sprintf('%g',tau)])

figure; semilogy(abs(full_sa), pp);
xlabel('scattering angle');
ylabel('radiance W/m^2/nm/sr');
title(['Wavelength = 453 nm, SZA = ',num2str(SZA), ' tau = ', sprintf('%g',tau)])
