function mfr = corr_mfr_236(mfr);
% pname = 'D:\case_studies\new_xmfrx_proc\PNNL_Annex_data\236\';
% fname = 'BCEE.040828.mtm';
% Annex MFRSR: 
%  logger ID: BCEE
%  head ID: F7F
%  lat: 119.278564
%  lon: 46.334839
                 
%
if nargin==0
   mfr = read_rsr_v2;
else
   mfr = read_rsr_v2(mfr);
end
save mfr.mat mfr

% load mfr
[sun.zen_angle, sun.az_angle, sun.r_au, sun.hour_angle, sun.declination, sun.el, sun.airmass] = sunae(mfr.vars.lat.data, mfr.vars.lon.data, mfr.time);

sunup = find(sun.el > 0);
sundown = find(sun.el < 0);
mfr.vars.zen_angle.atts.long_name.data = 'solar zenith angle';
mfr.vars.zen_angle.atts.units.data = 'degrees';
mfr.vars.zen_angle.data = sun.zen_angle';

mfr.vars.dirhor_ch1.data(sundown) = NaN;
mfr.vars.dirhor_ch2.data(sundown) = NaN;
mfr.vars.dirhor_ch3.data(sundown) = NaN;
mfr.vars.dirhor_ch4.data(sundown) = NaN;
mfr.vars.dirhor_ch5.data(sundown) = NaN;
mfr.vars.dirhor_ch6.data(sundown) = NaN;
mfr.vars.dirhor_ch7.data(sundown) = NaN;

%%

%%

%  mfr.vars.dirhor_ch1.data = mfr.vars.direct_horizontal_broadband.data;
%  mfr.vars.dirhor_ch2.data = mfr.vars.direct_horizontal_narrowband_filter1.data;
%  mfr.vars.dirhor_ch3.data = mfr.vars.direct_horizontal_narrowband_filter2.data;
%  mfr.vars.dirhor_ch4.data = mfr.vars.direct_horizontal_narrowband_filter3.data;
%  mfr.vars.dirhor_ch5.data = mfr.vars.direct_horizontal_narrowband_filter4.data;
%  mfr.vars.dirhor_ch6.data = mfr.vars.direct_horizontal_narrowband_filter5.data;
%  mfr.vars.dirhor_ch7.data = mfr.vars.direct_horizontal_narrowband_filter6.data;

 mfr.vars.dirnorm_ch1.data = mfr.vars.dirhor_ch1.data ./ cos(sun.zen_angle'*pi/180);
 mfr.vars.dirnorm_ch2.data = mfr.vars.dirhor_ch2.data ./ cos(sun.zen_angle'*pi/180);
 mfr.vars.dirnorm_ch3.data = mfr.vars.dirhor_ch3.data ./ cos(sun.zen_angle'*pi/180);
 mfr.vars.dirnorm_ch4.data = mfr.vars.dirhor_ch4.data ./ cos(sun.zen_angle'*pi/180);
 mfr.vars.dirnorm_ch5.data = mfr.vars.dirhor_ch5.data ./ cos(sun.zen_angle'*pi/180);
 mfr.vars.dirnorm_ch6.data = mfr.vars.dirhor_ch6.data ./ cos(sun.zen_angle'*pi/180);
 mfr.vars.dirnorm_ch7.data = mfr.vars.dirhor_ch7.data ./ cos(sun.zen_angle'*pi/180);

%%
darkV = [+0.000012, -0.000016, -0.000153, +0.000030, -0.000410, -0.000466, -0.000395];
logger_gains = -[5.479452055, 8.032128514, 2.424242424, 1.428571429, 2, 1.538461538, 2.424242424];
offset = 1000* darkV .* logger_gains;
%visual inspection of allsky data indicates these offsets are a tad
%high, but generally insignificant.
mfr.vars.dif_ch1.data = mfr.vars.dif_ch1.data  - offset(1);
mfr.vars.dif_ch2.data = mfr.vars.dif_ch2.data  - offset(2);
mfr.vars.dif_ch3.data = mfr.vars.dif_ch3.data  - offset(3);
mfr.vars.dif_ch4.data = mfr.vars.dif_ch4.data  - offset(4);
mfr.vars.dif_ch5.data = mfr.vars.dif_ch5.data  - offset(5);
mfr.vars.dif_ch6.data = mfr.vars.dif_ch6.data  - offset(6);
mfr.vars.dif_ch7.data = mfr.vars.dif_ch7.data  - offset(7);


dif_corr = [ 0.993,  0.973 , 0.984 , 0.987 , 0.989 , 0.991 , 0.991 ];

mfr.vars.cordif_ch1.data = mfr.vars.dif_ch1.data  / dif_corr(1);
mfr.vars.cordif_ch2.data = mfr.vars.dif_ch2.data  / dif_corr(2);
mfr.vars.cordif_ch3.data = mfr.vars.dif_ch3.data  / dif_corr(3);
mfr.vars.cordif_ch4.data = mfr.vars.dif_ch4.data  / dif_corr(4);
mfr.vars.cordif_ch5.data = mfr.vars.dif_ch5.data  / dif_corr(5);
mfr.vars.cordif_ch6.data = mfr.vars.dif_ch6.data  / dif_corr(6);
mfr.vars.cordif_ch7.data = mfr.vars.dif_ch7.data  / dif_corr(7);

%%
infile= (['D:\case_studies\new_xmfrx_proc\PNNL_Annex_data\236\broadband_scale_factor\CosCorr.MP236.0F7F.20040803135.i']);
cos_corrs = read_solarfile(infile);
 
%%
mfr.vars.cosine_correction_ch1.data = cos_correction(cos_corrs(1), sun.az_angle, sun.zen_angle)';
mfr.vars.cosine_correction_ch2.data = cos_correction(cos_corrs(2), sun.az_angle, sun.zen_angle)';
mfr.vars.cosine_correction_ch3.data = cos_correction(cos_corrs(3), sun.az_angle, sun.zen_angle)';
mfr.vars.cosine_correction_ch4.data = cos_correction(cos_corrs(4), sun.az_angle, sun.zen_angle)';
mfr.vars.cosine_correction_ch5.data = cos_correction(cos_corrs(5), sun.az_angle, sun.zen_angle)';
mfr.vars.cosine_correction_ch6.data = cos_correction(cos_corrs(6), sun.az_angle, sun.zen_angle)';
mfr.vars.cosine_correction_ch7.data = cos_correction(cos_corrs(7), sun.az_angle, sun.zen_angle)';
%%

mfr.vars.cordirhor_ch1.data = mfr.vars.dirhor_ch1.data .* mfr.vars.cosine_correction_ch1.data;
mfr.vars.cordirhor_ch2.data = mfr.vars.dirhor_ch2.data .* mfr.vars.cosine_correction_ch2.data;
mfr.vars.cordirhor_ch3.data = mfr.vars.dirhor_ch3.data .* mfr.vars.cosine_correction_ch3.data;
mfr.vars.cordirhor_ch4.data = mfr.vars.dirhor_ch4.data .* mfr.vars.cosine_correction_ch4.data;
mfr.vars.cordirhor_ch5.data = mfr.vars.dirhor_ch5.data .* mfr.vars.cosine_correction_ch5.data;
mfr.vars.cordirhor_ch6.data = mfr.vars.dirhor_ch6.data .* mfr.vars.cosine_correction_ch6.data;
mfr.vars.cordirhor_ch7.data = mfr.vars.dirhor_ch7.data .* mfr.vars.cosine_correction_ch7.data;
%%

mfr.vars.cordirnorm_ch1.data = mfr.vars.dirnorm_ch1.data .* mfr.vars.cosine_correction_ch1.data;
mfr.vars.cordirnorm_ch2.data = mfr.vars.dirnorm_ch2.data .* mfr.vars.cosine_correction_ch2.data;
mfr.vars.cordirnorm_ch3.data = mfr.vars.dirnorm_ch3.data .* mfr.vars.cosine_correction_ch3.data;
mfr.vars.cordirnorm_ch4.data = mfr.vars.dirnorm_ch4.data .* mfr.vars.cosine_correction_ch4.data;
mfr.vars.cordirnorm_ch5.data = mfr.vars.dirnorm_ch5.data .* mfr.vars.cosine_correction_ch5.data;
mfr.vars.cordirnorm_ch6.data = mfr.vars.dirnorm_ch6.data .* mfr.vars.cosine_correction_ch6.data;
mfr.vars.cordirnorm_ch7.data = mfr.vars.dirnorm_ch7.data .* mfr.vars.cosine_correction_ch7.data;

%%
mfr.vars.corth_ch1.data = mfr.vars.cordif_ch1.data + mfr.vars.cordirhor_ch1.data;
mfr.vars.corth_ch2.data = mfr.vars.cordif_ch2.data + mfr.vars.cordirhor_ch2.data;
mfr.vars.corth_ch3.data = mfr.vars.cordif_ch3.data + mfr.vars.cordirhor_ch3.data;
mfr.vars.corth_ch4.data = mfr.vars.cordif_ch4.data + mfr.vars.cordirhor_ch4.data;
mfr.vars.corth_ch5.data = mfr.vars.cordif_ch5.data + mfr.vars.cordirhor_ch5.data;
mfr.vars.corth_ch6.data = mfr.vars.cordif_ch6.data + mfr.vars.cordirhor_ch6.data;
mfr.vars.corth_ch7.data = mfr.vars.cordif_ch7.data + mfr.vars.cordirhor_ch7.data;


%%

%%Now get skyrad
% pname = ['D:\case_studies\new_xmfrx_proc\PNNL_Annex_data\skyrad\Jim_data\'];
% fname = ['SKYRAD_20041029.DAT'];
% skyrad = pnlsky([pname, fname]);
% skyrad.time = skyrad.time + 7/24;
% save skyrad.mat skyrad
%%
load skyrad

skytime = find(skyrad.time>=min(mfr.time(sunup)) & skyrad.time<=max(mfr.time(sunup)));

%%
figure; subplot(2,1,1); plot(serial2doy0(mfr.time), mfr.vars.cordirnorm_ch1.data, 'b.', ...
   serial2doy0(skyrad.time(skytime)), skyrad.dirn(skytime), 'g')
subplot(2,1,2); plot(serial2doy0(mfr.time), mfr.vars.solar_elevation.data, 'b.');


% Plotting corrected diffuse + cor dir hor = cor th
% 
% figure; plot(serial2doy0(mfr.time), [mfr.vars.cordif_ch3.data + mfr.vars.cordirhor_ch3.data], '.',...
%    serial2doy0(mfr.time),mfr.vars.corth_ch3.data, 'b');

%figure; plot(serial2doy0(mfr.time),  mfr.vars.dif_ch2.data ./ mfr.vars.cordif_ch2.data, 'b.')
   
figure; plot(serial2doy0(mfr.time),  b1.vars.direct_normal_narrowband_filter1.data - mfr.vars.cordirnorm_ch2.data, 'b.')

figure; plot(serial2doy0(b1.time), cos(b1.vars.solar_zenith_angle.data)-b1.vars.cosine_solar_zenith_angle.data,'g.')
%%
figure; plot(serial2doy0(b1.time), 1./cos(b1.vars.solar_zenith_angle.data), 'r.',...
serial2doy0(b1.time), b1.vars.airmass.data,'g.')


%%
figure; plot(serial2Hh(mfr.time(2:end)), mfr.vars.diffuse_hemisp_narrowband_filter2.data(2:end), 'b.')

%%
figure; plot(serial2Hh(mfr.time(2:end)), [mfr.vars.diffuse_hemisp_narrowband_filter2.data(2:end);mfr.vars.hemisp_narrowband_filter2.data(2:end);mfr.vars.direct_horizontal_narrowband_filter2.data(2:end)], '.')
%%
figure; plot(serial2Hh(a1.time(2:end)), [a1.vars.diffuse_hemisp_narrowband_filter2.data(2:end);a1.vars.hemisp_narrowband_filter2.data(2:end);a1.vars.direct_horizontal_narrowband_filter2.data(2:end)], '.')
legend('diffuse', 'total', 'direct_horiz')

%%
figure; plot(serial2Hh(b1.time(2:end)), [b1.vars.diffuse_hemisp_narrowband_filter2.data(2:end);b1.vars.hemisp_narrowband_filter2.data(2:end);b1.vars.direct_normal_narrowband_filter2.data(2:end)./b1.vars.airmass.data(2:end)], '.')
%%
figure; plot(serial2Hh(b1.time(2:end)), [b1.vars.diffuse_hemisp_narrowband_filter2.data(2:end);b1.vars.hemisp_narrowband_filter2.data(2:end);b1.vars.direct_normal_narrowband_filter2.data(2:end)], '.')
%%
figure; plot(serial2Hh(b1.time(2:end)), [b1.vars.diffuse_hemisp_narrowband_filter2.data(2:end);b1.vars.hemisp_narrowband_filter2.data(2:end);b1.vars.direct_normal_narrowband_filter2.data(2:end)./b1.vars.airmass.data(2:end)], '.')
%%
figure; plot(serial2Hh(mfr.time), mfr.vars.hemisp_narrowband_filter2.data, 'r.', ... 
   serial2Hh(b1_2.time), b1_2.vars.total_hemisp_narrowband_filter2.data, 'c.');
legend('a0', 'b1')
title('hemispheric narrowband filter2')
%%
%%
figure; plot(serial2Hh(mfr.time), mfr.vars.hemisp_narrowband_filter2.data, 'r.', ...
   serial2Hh(a1.time), a1.vars.hemisp_narrowband_filter2.data, 'b.', ...
   serial2Hh(b1.time), b1.vars.total_hemisp_narrowband_filter2.data, 'g.');
legend('a0', 'a1', 'b1')
title('total hemispheric narrowband filter2')
%%
%%
figure; plot(serial2Hh(mfr.time), mfr.vars.direct_horizontal_narrowband_filter2.data, 'r.', ...
   serial2Hh(a1.time), a1.vars.direct_horizontal_narrowband_filter2.data, 'b.', ...
   serial2Hh(b1.time), b1.vars.direct_normal_narrowband_filter2.data./b1.vars.airmass.data, 'g.')

legend('a0', 'a1', 'b1')
title('direct horizontal narrowband filter2')
%%
%%
figure; plot(serial2Hh(b1.time), b1.vars.direct_normal_narrowband_filter2.data./b1.vars.airmass.data, 'g.', ...
   serial2Hh(b1.time), b1.vars.direct_normal_narrowband_filter2.data, 'k.');
legend('b1_direct_horiz', 'b1_direct_normal')
title('direct horizontal narrowband filter2')
%%
figure;
plot(serial2Hh(b1.time), b1.vars.airmass.data, 'b');
legend('airmass')
%%
figure; plot(b1.vars.bench_angle.data, [b1.vars.cosine_correction_sn_broadband.data, ...
   b1.vars.cosine_correction_sn_filter1.data, b1.vars.cosine_correction_sn_filter2.data,... 
   b1.vars.cosine_correction_sn_filter3.data, b1.vars.cosine_correction_sn_filter4.data,...
      b1.vars.cosine_correction_sn_filter5.data, b1.vars.cosine_correction_sn_filter6.data,...
   ],'.')
%%
figure; plot(b1.vars.wavelength_filter1.data, [b1.vars.normalized_transmittance_filter1.data],...
   b1.vars.wavelength_filter2.data, b1.vars.normalized_transmittance_filter2.data, ...
   b1.vars.wavelength_filter3.data,b1.vars.normalized_transmittance_filter3.data, ...
   b1.vars.wavelength_filter4.data, b1.vars.normalized_transmittance_filter4.data,...
   b1.vars.wavelength_filter5.data,b1.vars.normalized_transmittance_filter5.data, ...
   b1.vars.wavelength_filter6.data,  b1.vars.normalized_transmittance_filter6.data)

%%
%%
% figure; plot(serial2Hh(b1.time), b1.vars.direct_normal_narrowband_filter2.data, 'b.', ...
% serial2Hh(b1.time), b1.vars.direct_normal_narrowband_filter2.data,./b1.vars.airmass.data, 'g.', ...
% serial2Hh(b1.time), b1.vars.airmass.data,'r.');
% %%
% legend('normal', 'dir_horiz', 'airmass')
% title('direct horizontal narrowband filter2')
%%

%%