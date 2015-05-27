[sasvis he_vis_1,he_vis_2] = proc_sashe_hisun_cdf(getfullname_('sgpsashe*.cdf','sashevis'));
%%
[sasnir, he_nir_1,he_nir_2] = proc_sashe_hisun_cdf(getfullname_(['sgpsashe*',datestr(sasvis.time(1),'yyyymmdd'),'*.cdf'],'sashenir'));
%%
nim = ancload(getfullname_(['sgpnimfr*',datestr(sasvis.time(1),'yyyymmdd'),'*.cdf'],'nimfr'));
%%
nim_base = interp1(nim.time, nim.vars.direct_normal_narrowband_filter2.data, sasvis.time,'pchip');

pix = interp1(sasvis.vars.wavelength.data, [1:length(sasvis.vars.wavelength.data)],[415,500,615,870], 'nearest','extrap');
% figure; ss(1) = subplot(2,1,1); plot(serial2doy(nim.time), (1020./1060).*8e2.* nim.vars.direct_normal_narrowband_filter2.data,'r-', ...
%     serial2doy(he_nir_1.time), 1.8.*he_nir_1.dirn(24,:),'k-', ...
%     serial2doy(he_vis_1.time), he_vis_1.dirn(pix,:),'-');
% legend('NIMFR 500 nm', 'SAS-He NIR 990 nm', 'SAS-He Vis 500 nm')
% grid('on');
% ss(2) = subplot(2,1,2); plot(serial2doy(sasvis.time), smooth(sasvis.vars.avantes_ad_temperature.data,50,'sgolay',2),'.-',...
%    serial2doy(sasnir.time), smooth(sasnir.vars.avantes_ad_temperature.data,50,'sgolay',2)-1.5,'.-' )
% legend('VIS A/D temp','NIR A/D Temp')
% grid('on');
% linkaxes(ss,'x')

%%
nim_base = interp1(nim.time(nim.vars.direct_normal_narrowband_filter2.data>0), ...
    nim.vars.direct_normal_narrowband_filter2.data(nim.vars.direct_normal_narrowband_filter2.data>0),...
    he_vis_1.time,'pchip');

figure; sx(1) = subplot(3,1,1);
plot(serial2doy(he_vis_1.time), he_vis_1.dirn(pix(2),:)./nim_base, '.');
title(['SASHe dirn/nimfr dirn 500 nm, ',datestr(he_vis_1.time(1),'yyyy-mm-dd')]);
grid('on');
sx(2) = subplot(3,1,2);
plot(serial2doy(sasvis.time(sasvis.vars.shutter_state.data==0)), sum(sasvis.vars.spectra.data(:,sasvis.vars.shutter_state.data==0),1),'-');
legend('sum vis darks');
title('Sum of background');
grid('on');
sx(3) = subplot(3,1,3);
plot(serial2doy(sasvis.time), smooth(sasvis.vars.avantes_ad_temperature.data,50,'sgolay',2),'.-')
legend('VIS A/D temp')
title('Avantes spectrometers temperature')
grid('on');
linkaxes(sx,'x')
%%
nim_base_to_vis = interp1(he_vis_1.time, he_vis_1.dirn(pix(2),:)./nim_base, sasvis.time,'pchip');
figure; plot(smooth(sum(sasvis.vars.spectra.data(:,sasvis.vars.shutter_state.data==0),1)./mean(sum(sasvis.vars.spectra.data(:,sasvis.vars.shutter_state.data==0),1)),50,'sgolay'), nim_base_to_vis(sasvis.vars.shutter_state.data==0), 'o')

%%
figure; lines= plot(serial2doy(he_nir_1.time), he_nir_1.dirn, '-'); recolor(lines, sasnir.vars.wavelength.data); colorbar

%%
[m_val, nm] = max(he_nir_1.dirn(:,120))