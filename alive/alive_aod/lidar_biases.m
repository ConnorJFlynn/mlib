figure; plot(AATS_ext519_all, AATS_ext353_all, '.');
%%
[profs,heights] = size(AATS_ext519_all);
for h = heights:-1:1
good = ~isNaN(AATS_ext519_all(:,h))&~isNaN(AATS_ext353_all(:,h));
ext519(h) = mean(AATS_ext519_all(good,h));
ext353(h) = mean(AATS_ext353_all(good,h));
rat_h1(h) = mean(AATS_ext519_all(good,h)./AATS_ext353_all(good,h));
end
rat_h2 = ext519./ext353;
%%
ext519 = AATS_ext519_all(:);
ext353 = AATS_ext353_all(:);
good = ~isNaN(ext519)&~isNaN(ext353);
[P,S] = polyfit(ext353(good), ext519(good),1);
stats = fit_stat(ext353(good), ext519(good),P,S);
figure; plot(ext353(good), ext519(good),'.',[0,max(ext353(good))],polyval(P,[0,max(ext353(good))]),'r');
xlabel('AATS ext353');
ylabel('AATS ext519');
txt = {['N = ', num2str(stats.N)],...
    ['slope = ',sprintf('%g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.4f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.4f',stats.RMSE)]};
gtext(txt);
%
