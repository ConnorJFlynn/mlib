%%
if strcmp(MPL,'No')
    disp('MPL was not run last so exiting.')
    return
end
%%
MPL_Altitude = Altitude;
AATS_ext519_mpl = AATS_ext519_all;
AATS_aod519_mpl = AATS_AOD519_all;
MPL_ext_all_ = MPL_ext_all;
MPL_aod_all_ = MPL_aod_all;
%%
bias_MPL_ext = MPL_ext_all_ - AATS_ext519_mpl;
bias_MPL_aod = MPL_aod_all_ - AATS_aod519_mpl;
%%
sum_MPL_bias = 0;
num_MPL_good = 0;
abs_MPL_bias = 0;
sum_MPL_bias_aod = 0;
abs_MPL_bias_aod = 0;
num_MPL_good_aod = 0;
%%

for a = length(MPL_Altitude):-1:1
    good = ~isNaN(bias_MPL_ext(:,a));
    mean_good_MPL(a) = mean(MPL_ext_all_(good,a));
    bias_good_MPL_ext(a) = mean(bias_MPL_ext(good,a));
    sum_MPL_bias = sum_MPL_bias+sum(bias_MPL_ext(good,a));
    abs_MPL_bias = abs_MPL_bias + sum(abs(bias_MPL_ext(good,a)));
    num_MPL_good(a) = sum(good);
    std_good_MPL_ext(a) = std(bias_MPL_ext(good,a));

    good_aod = ~isNaN(bias_MPL_aod(:,a))&(abs(bias_MPL_aod(:,a)<.2));
    bias_good_MPL_aod(a) = mean(bias_MPL_aod(good_aod,a));
    sum_MPL_bias_aod = sum_MPL_bias_aod + sum(bias_MPL_aod(good_aod,a));
    abs_MPL_bias_aod = abs_MPL_bias_aod + sum(abs(bias_MPL_aod(good_aod,a)));
    num_MPL_good_aod(a) = sum(good_aod);
    std_good_MPL_aod(a) = std(bias_MPL_aod(good_aod,a));

end

mean_MPL_bias = sum_MPL_bias/sum(num_MPL_good);
abs_MPL_bias = abs_MPL_bias/sum(num_MPL_good);
mean_MPL_bias_aod = sum_MPL_bias_aod/sum(num_MPL_good_aod);
abs_MPL_bias_aod = abs_MPL_bias_aod/sum(num_MPL_good_aod);
%%