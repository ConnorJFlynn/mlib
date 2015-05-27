%%
if strcmp(CARL,'No')
    disp('CARL was not run last so exiting.')
    return
end
CARL_Altitude = Altitude;
AATS_ext353_carl = AATS_ext353_all;
AATS_AOD353_carl = AATS_AOD353_all;
CARL_ext_all_ = CARL_ext_all;
CARL_aod_all_ = CARL_aod_all;
bias_CARL_ext = CARL_ext_all_ - AATS_ext353_carl;
bias_CARL_aod = CARL_aod_all_ - AATS_AOD353_carl;
%%
sum_CARL_bias = 0;
num_CARL_good = 0;
abs_CARL_bias = 0;
sum_CARL_bias_aod = 0;
abs_CARL_bias_aod = 0;
num_CARL_good_aod = 0;
for a = length(CARL_Altitude):-1:1
    good = ~isNaN(bias_CARL_ext(:,a))&(bias_CARL_ext(:,a)<.5);
    mean_good_CARL(a) = mean(CARL_ext_all(good,a));
    bias_good_CARL_ext(a) = mean(bias_CARL_ext(good,a));
    sum_CARL_bias = sum_CARL_bias + sum(bias_CARL_ext(good,a));
    abs_CARL_bias = abs_CARL_bias + sum(abs(bias_CARL_ext(good,a)));
    num_CARL_good(a) = sum(good);
    std_good_CARL_ext(a) = std(bias_CARL_ext(good,a));
    
    good_aod = ~isNaN(bias_CARL_aod(:,a))&(abs(bias_CARL_aod(:,a)<.2));
%     mean_good_CARL_aod(a) = mean(CARL_aod_all_(good_aod,a));
    bias_good_CARL_aod(a) = mean(bias_CARL_aod(good_aod,a));
    sum_CARL_bias_aod = sum_CARL_bias_aod + sum(bias_CARL_ext(good_aod,a));
    abs_CARL_bias_aod = abs_CARL_bias_aod + sum(abs(bias_CARL_aod(good_aod,a)));
    num_CARL_good_aod(a) = sum(good_aod);
    std_good_CARL_aod(a) = std(bias_CARL_aod(good_aod,a));
end
mean_CARL_bias = sum_CARL_bias/sum(num_CARL_good);
abs_CARL_bias = abs_CARL_bias/sum(num_CARL_good);
mean_CARL_bias_aod = sum_CARL_bias_aod/sum(num_CARL_good);
abs_CARL_bias_aod = abs_CARL_bias_aod/sum(num_CARL_good);
%%
