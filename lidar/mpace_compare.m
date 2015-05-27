hsrl = ancload;
%
ray_dpr = 0.02;
%
[ray_alpha, ray_beta] = ray_a_b(hsrl.vars.temperature_profile.data(:,1),hsrl.vars.pressure_profile.data(:,1),532e-9);
ray_beta = ray_beta/1000; %convert to inverse meter instead of inverse km
% figure; semilogy(hsrl.vars.altitude.data, ray_beta+mean(hsrl.vars.beta_a_backscat.data(:,t_sub),2),'r');
goods = (hsrl.vars.depol.data >= 0);
hsrl.pdpr = zeros(size(hsrl.vars.depol.data));
%Convert from circ dpr to ldpr
hsrl.pdpr(goods) = hsrl.vars.depol.data(goods)./(hsrl.vars.depol.data(goods) +2);
%

a_par = hsrl.vars.beta_a_backscat.data./(1+hsrl.pdpr);
a_perp = hsrl.vars.beta_a_backscat.data - a_par;
ray_par = ray_beta ./(1+ray_dpr);
ray_perp= ray_beta - ray_par;
%
tot_par = ray_par*ones(size(hsrl.time)) + a_par;
tot_perp = ray_perp*ones(size(hsrl.time)) + a_perp;
goods = (tot_par > 0);
vdpr = zeros(size(hsrl.pdpr));
vdpr = tot_perp ./ tot_par;
%
%%
figure; 
ax1(1) = subplot(3,1,1); 
imagegap(serial2Hh(hsrl.time), hsrl.vars.altitude.data./1000, real(log10(tot_par))); 
caxis([-6,-2]); colorbar; 
title({['Total elastic backscatter ( + Rayleigh)'],['Starting at ',datestr(hsrl.time(1),'yyyy-mm-dd HH:MM')]})
ylabel('range (km)')
ax1(2) = subplot(3,1,2); 
imagegap(serial2Hh(hsrl.time), hsrl.vars.altitude.data./1000, real((vdpr))); 
colorbar; caxis([0,1]);
ylabel('range (km)')
title({['volume dpr from hsrl, assumed molecular of ',num2str(100*ray_dpr),'%']})
ax1(3)= subplot(3,1,3); 
imagegap(serial2Hh(hsrl.time), hsrl.vars.altitude.data./1000, real(log10(vdpr))); 
colorbar; caxis([-2,0]);
ylabel('range (km)')
title('log10(volume dpr)')
xlabel('time (UTC hours)');
linkaxes(ax1, 'xy')
xlim([0,5]);ylim([0,6]);% These limits are for Oct 18 comparison
%%
mpl = ancload(['C:\case_studies\MPACE\nsamplps_etc\c1\nsamplpsC1.c1.20041018.000000.cdf']);
figure; 
ax1(1) = subplot(3,1,1); 
imagegap(serial2Hh(mpl.time), mpl.vars.range.data, real(log10(mpl.vars.total_prof.data))); 
caxis([-4,2]); colorbar; 
title({['attenutated backscatter'],['Starting at ',datestr(mpl.time(1),'yyyy-mm-dd HH:MM')]})
ylabel('range (km)')
ax1(2) = subplot(3,1,2); 
imagegap(serial2Hh(mpl.time), mpl.vars.range.data, mpl.vars.depolarization.data); 
colorbar; caxis([0,1]);
ylabel('range (km)')
title(['Linear dpr from mpl'])
ax1(3)= subplot(3,1,3); 
imagegap(serial2Hh(mpl.time), mpl.vars.range.data,real(log10(mpl.vars.depolarization.data))); 
colorbar; caxis([-2,0]);
ylabel('range (km)')
title('log10(volume dpr)')
xlabel('time (UTC hours)');
linkaxes(ax1, 'xy')
xlim([0,5]);ylim([0,6]);% These limits are for Oct 18 comparison

%%

pdl = loadinto(getfullname_('*.mat','pdl_down','Select downsampled pdl file.'));
%%
%Why do the following?  Correcting for wrong background subraction?
% pdl.vis_v = pdl.vis_v + 10;
%
figure; 
%%
semilogy(pdl.range, pdl.vis_ratio*(mean(pdl.vis_v,2)+10).*pdl.range.^2,'b', pdl.range, (mean(pdl.vis_p,2)).*pdl.range.^2,'r')
legend('vis_v','vis_p')
%%
figure; imagegap(serial2Hh(pdl.time), pdl.range, real(log10(pdl.vis_p))); axis('xy'); colormap('bone'); colorbar;
% caxis([8.5,12.5])
figure; imagegap(serial2Hh(pdl.time), pdl.range, real(log10(pdl.vis_v))); axis('xy'); colormap('bone'); colorbar;
% caxis([8.5,12.5])
%%

figure; 
ax4(1) = subplot(2,1,1); 
imagegap(serial2Hh(pdl.time), pdl.range, real((pdl.vis_dpr))); axis('xy'); colormap('jet'); colorbar;
caxis([0,1])
ax4(2) = subplot(2,1,2);
imagegap(serial2Hh(pdl.time), pdl.range, real(log10(pdl.vis_dpr))); axis('xy'); colormap('jet'); colorbar;
caxis([-2,0])
linkaxes(ax4,'xy');


