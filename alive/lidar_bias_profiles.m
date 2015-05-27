function [bias_good_ext, bias_good_aod,mean_ext_bias, abs_ext_bias, mean_aod_bias, abs_aod_bias,mean_ext_MPL, mean_ext_CARL, CARLtoMPL_ext, CARLtoMPL_aod] = lidar_bias_profiles(MPL_Altitude,MPL_ext_all_, MPL_aod_all_,CARL_Altitude, CARL_ext_all_, AATS_ext519_all)
%[bias_good_ext, bias_good_aod,mean_ext_bias, abs_ext_bias, mean_aod_bias,
%abs_aod_bias,mean_ext_MPL, mean_ext_CARL, CARLtoMPL_ext, CARLtoMPL_aod] =
%lidar_bias_profiles(MPL_Altitude,MPL_ext_all_, MPL_aod_all_,CARL_Altitude,
%CARL_ext_all_)
%%
Altitude = MPL_Altitude;
good_CARL = ~isNaN(CARL_ext_all_)&(CARL_ext_all_>(-0.02))&(CARL_ext_all_<(0.3));
CARL_ext_all = NaN(size(CARL_ext_all_));
CARL_ext_all(good_CARL) = CARL_ext_all_(good_CARL);
aod_ratio = 0.609; %From plot of AATS 353 vs AATS 519
for p = 30:-1:1;
    CARLtoMPL_ext(p,:) = interp1(CARL_Altitude, CARL_ext_all(p,:),Altitude);
     CARLtoMPL_ext(p,:) = CARLtoMPL_ext(p,:) * 0.609;
%     figure(5);scatter(MPL_ext_all_(p,:), CARLtoMPL_ext(p,:),20, Altitude); colorbar
%     title(num2str(p));
    pause(0.05)
end
%  figure; plot(CARLtoMPL_ext,MPL_ext_all_,'.')

CARLtoMPL_aod = NaN(size(CARLtoMPL_ext));
for p = 30:-1:1;
    notNaN = ~isNaN(CARLtoMPL_ext(p,:));
    CARLtoMPL_aod(p,notNaN) = cumtrapz(Altitude(notNaN),CARLtoMPL_ext(p,notNaN));
    CARLtoMPL_aod(p,notNaN) = max(CARLtoMPL_aod(p,notNaN)) - CARLtoMPL_aod(p,notNaN);
end
% bias_ext = NaN(size(MPL_ext_all_));
% good_ext = ~isNaN(MPL_ext_all_)&~isNaN(CARLtoMPL_ext);
bias_ext = MPL_ext_all_ - CARLtoMPL_ext;
bias_aod = MPL_aod_all_ - CARLtoMPL_aod;
sum_ext_bias = 0;
num_good_ext = 0;
abs_ext_bias = 0;
sum_aod_bias = 0;
abs_aod_bias = 0;
num_good_aod = 0;

for a = length(Altitude):-1:1
    good_ext = ~isNaN(bias_ext(:,a))&(abs(bias_ext(:,a)<.07));
    good_ext = ~isNaN(bias_ext(:,a));
    mean_ext_MPL(a) = mean(MPL_ext_all_(good_ext,a));
    mean_ext_CARL(a) = mean(CARLtoMPL_ext(good_ext,a));
    bias_good_ext(a) = mean(bias_ext(good_ext,a));
    sum_ext_bias = sum_ext_bias+sum(bias_ext(good_ext,a));
    abs_ext_bias = abs_ext_bias + sum(abs(bias_ext(good_ext,a)));
    num_good_ext =num_good_ext + sum(good_ext);
    std_good_ext(a) = std(bias_ext(good_ext,a));

    good_aod = ~isNaN(bias_aod(:,a))&(abs(bias_aod(:,a)<.2));
    good_aod = ~isNaN(bias_aod(:,a));
    bias_good_aod(a) = mean(bias_aod(good_aod,a));
    sum_aod_bias = sum_aod_bias + sum(bias_aod(good_aod,a));
    abs_aod_bias = abs_aod_bias + sum(abs(bias_aod(good_aod,a)));
    num_good_aod = num_good_aod + sum(good_aod);
    std_good_aod(a) = std(bias_aod(good_aod,a));
    good_AATS = ~isNaN(AATS_ext519_all(:,a));
    mean_aats519(a) = mean(AATS_ext519_all(good_AATS,a));

end

mean_ext_bias = sum_ext_bias/num_good_ext;
abs_ext_bias = abs_ext_bias/num_good_ext;
mean_aod_bias = sum_aod_bias/num_good_aod;
abs_aod_bias = abs_aod_bias/num_good_aod;
%%
%
plots_ppt

X = CARLtoMPL_ext(:); Y = MPL_ext_all_(:);
good_ext = ~isNaN(X)&~isNaN(Y);
X = X(good_ext); Y = Y(good_ext);
[P,S] = polyfit(X, Y,1);
stats = fit_stat(X, Y,P,S);
figure; plot(CARLtoMPL_ext, MPL_ext_all_,'.',[0,max(CARLtoMPL_ext)],polyval(P,[0,max(CARLtoMPL_ext)]),'r');
axis('square');
xl = xlim; line(xl,xl,'color','black','linestyle','- -');
ylim([-0.02    0.20]);
xlim([-0.02    0.20]);
xlabel('CARL Extinction (1/km)');
ylabel('MPL Extinction (1/km)');
title(['Aerosol Extinction adjusted to 523 nm']);
txt = {['N = ', num2str(stats.N)],...
    ['slope = ',sprintf('%1.2g',P(1))], ...
    ['Y\_int = ', sprintf('%0.02g',P(2))],...
    ['R^2 = ',sprintf('%1.2f',stats.R_sqrd)],...
    ['RMSE = ',sprintf('%1.2f',stats.RMSE)]};
gt = gtext(txt);
set(gt,'fontsize',14)
%%

figure; plot(mean_aats519,Altitude,'k',mean_ext_CARL, Altitude,'b', mean_ext_MPL, Altitude, 'g');
line([0,0], [0,8], 'color','black','linestyle','--');
xlabel('extinction (1/km)')
ylabel('range (km)');
legend('AATS (519nm)', 'CARL (523nm)','MPL (523');
title(['Mean of coincident extinction profiles']);



%% 
plots_default