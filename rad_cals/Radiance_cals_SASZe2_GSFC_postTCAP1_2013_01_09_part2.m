% This procedure calls Radiance_cals_SASZe2_GSFC_postTCAP1_2013_01_09 for
% each lamp settting (2,5,8) and instrument configuration (pre-clean, post-clean)
% 
% This procedure should be followed by 
% "Radiance_cals_SASZe1_GSFC_postTCAP1_2013_01_09_part3"
% to evaluate the different responsivities for each lamp
% and integration time to determine "best" responsivities for each
% integration time.

%%
[vis_precal_8, nir_precal_8] = Radiance_cals_SASZe2_GSFC_postTCAP1_2013_01_09;

%%
[vis_precal_5, nir_precal_5] = Radiance_cals_SASZe2_GSFC_postTCAP1_2013_01_09;

%%
[vis_postcal_8, nir_postcal_8] = Radiance_cals_SASZe2_GSFC_postTCAP1_2013_01_09;
%%
[vis_postcal_5, nir_postcal_5] = Radiance_cals_SASZe2_GSFC_postTCAP1_2013_01_09;
%%
[vis_postcal_2, nir_postcal_2] = Radiance_cals_SASZe2_GSFC_postTCAP1_2013_01_09;

%%
figure; plot(vis_postcal_8.lambda, [vis_postcal_8.resp_2_ms;;vis_postcal_5.resp_2_ms;vis_postcal_5.resp_6_ms], 'x-');
legend('2 ms, 8 lamps','2 ms, 5 lamps','6 ms, 5 lamps')
hold('on');
plot(nir_postcal_8.lambda, [nir_postcal_8.resp_100_ms;;nir_postcal_5.resp_200_ms;nir_postcal_5.resp_500_ms], 'x-');
legend('100 ms, 8 lamps', '200 ms, 8 lamps','500 ms, 5 lamps')
hold('off');
%%

figure; plot(vis_postcal_8.lambda, vis_postcal_8.rate_3_ms,'-');