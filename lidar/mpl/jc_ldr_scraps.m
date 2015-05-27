% %%
% load the 16-minute average
m16 = loadinto('E:\case_studies\twpC2\twpmplpolC2.b1\mat\16min\abc_mplpol_3flynn.20090213.doy44.mat')
sonde = ancload(['E:\case_studies\twpC2\twpsondewnpnC2.b1\twpsondewnpnC2.b1.20090213.232800.cdf']);
[attn_prof,tau, altitude, temperature, pressure] = sonde_std_atm_ray_atten(sonde, m16.range);
 tl_16 = (serial2Hh(m16.time)>=15)&(serial2Hh(m16.time)<=16);
 sub_r = m16.range>=10 & m16.range<=11; % Cal point
 sub_svc = m16.range>16&m16.range<17; % sub-visual cirrus
 sub_psl = m16.range>24&m16.range<25; % target psl height
attn_bscat = mean(m16.attn_bscat(:,tl_16),2); 
lidar_C = 1./exp(mean(log(attn_prof(sub_r)))-mean(log(attn_bscat(sub_r)))); 
%Plot lidar and Rayliegh to show collimation
figure; semilogy(m16.range, attn_bscat./lidar_C,'k',m16.range, attn_prof,'r');
title(['MPL attenuated backscatter and sonde-derived Rayleigh, lidar C =',sprintf('%3.1f',lidar_C)]);
xlabel('range [km]')
ylabel('attn. bscat [1/(km-sr)]')
% 15-minute average, 15 meter resolution

scat_rat = (m16.attn_bscat(:,tl_16)./lidar_C)./(attn_prof*ones([1,sum(tl_16)]));
range_10 =downsample(m16.range,10);
ds_10 = downsample(scat_rat,10);
svc = interp1(range_10,ds_10,m16.range(sub_svc),'linear');
scat_rat_2 = scat_rat;
scat_rat_2(sub_psl,:) =scat_rat_2(sub_psl,:).*svc;
figure; plot(downsample(m16.range,10), downsample(scat_rat_2,10)-1,'-');
title('MPL subvis cirrus and simulated PSL')
xlabel('range km')
ylabel('aerosol scattering ratio ');
% 15-minute average, 150 meter resolution

figure; semilogy(downsample(m16.range,10), sqrt(10).*downsample(m16.attn_bscat_snr(:,tl_16),10),'-');
title({['MPL subvis cirrus, attn. bscat SNR'],['15-minute average, 150 meter resolution']})
xlabel('range km')
ylabel('attn_bscat_snr','interp','none');
% 15-minute average, 150 meter resolution

%%
figure; 
ax(1) = subplot(2,1,1); 
plot(downsample(m16.range,10), sqrt(10).*downsample(m16.ldr(:,tl_16),10),'-');
title({['MPL subvis cirrus, ldr'],['15-minute average, 150 meter resolution']})
xlabel('range km')
ylabel('ldr','interp','none');
ax(2) = subplot(2,1,2); 
semilogy(downsample(m16.range,10), sqrt(10).*downsample(m16.ldr_snr(:,tl_16),10),'-');
title({['MPL subvis cirrus, ldr SNR'],['15-minute average, 150 meter resolution']})
xlabel('range km')
ylabel('ldr_snr','interp','none');
linkaxes(ax,'x');
%%
% axis(v)

% compute the particulate scattering ratio
% pick off the range of interest (16-17 km)
% grab scattering ratio
% identify the psl range (24-25 km)
