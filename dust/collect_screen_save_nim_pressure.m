% Collect, screen, and save Niamey pressure from nimmet

part1 = ancload('C:\case_studies\dust\nimmetM1.b1\bundle\nimmetM1.b1.20060106.000000.cdf');

pres1.time = part1.time; pres1.pres = part1.vars.atmos_pressure.data; clear part1
%%

figure; 

plot(pres1.time, pres1.pres,'.')
%%
NaNs = (pres1.pres<500 & pres1.time < 732750)|pres1.pres<90 | pres1.pres > 1100;
pres1.pres(NaNs) = NaN;
% Bad values removed, now fix units.
%
hpa = pres1.pres>500;
pres1.pres(hpa) = pres1.pres(hpa)./10
plot(pres1.time, pres1.pres,'.');
%%
[pres1.time, i] = unique(pres1.time);
pres1.pres = pres1.pres(i);
plot(pres1.time, pres1.pres,'.');
%%

part2 = ancload('C:\case_studies\dust\nimmetM1.b1\bundle\nimmetM1.b1.20060911.200000.cdf');
pres2.time = part2.time; pres2.pres = part2.vars.atmos_pressure.data; clear part2
figure; 
plot(pres2.time, pres2.pres,'.');
%%
[pres2.time, i] = unique(pres2.time);
pres2.pres = pres2.pres(i);
plot(pres2.time, pres2.pres,'.');

%%
[pres.time,i] = unique([pres1.time, pres2.time]);
atm_pres = [pres1.pres, pres2.pres];
pres.pres = atm_pres(i);
figure; plot(pres.time, pres.pres, '.'); datetick('keeplimits');
xlabel('time'); ylabel('pressure kPa')
%%
save nim_pres.mat pres
