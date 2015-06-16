function test2

%%
vis = rd_spc_TCAP_v2(getfullname('*_VIS_*.dat','STAR_MLO'));
nir = rd_spc_TCAP_v2([vis.pname, strrep(vis.fname,'_VIS_','_NIR_')]);
%%
darks = vis.spectra(vis.t.shutter==0,:);
darks_nir = nir.spectra(nir.t.shutter==0,:);

% figure; 
% ax(1) = subplot(2,1,1); 
% plot(vis.nm, mean(darks),'-');
% ax(2) = subplot(2,1,2);
% lines = plot(vis.nm, darks - ones(size(vis.time(vis.t.shutter==0)))*mean(darks),'-');
% recolor(lines,[1:length(lines)]);
% title('Darks')
% 
% figure; 
% ax2(1) = subplot(2,1,1); 
% plot(nir.nm, mean(darks_nir),'-');
% ax2(2) = subplot(2,1,2);
% lines = plot(nir.nm, darks_nir - ones(size(nir.time(nir.t.shutter==0)))*mean(darks_nir),'-');
% recolor(lines,[1:length(lines)]);
% title('Darks NIR')


%%
lights = vis.spectra(vis.t.shutter==1,:);
led = lights - ones(size(vis.time(vis.t.shutter==1)))*mean(darks);
led_less_mean = led - ones(size(vis.time(vis.t.shutter==1)))*mean(led);

lights_nir = nir.spectra(nir.t.shutter==1,:);
led_nir = lights_nir - ones(size(nir.time(nir.t.shutter==1)))*mean(darks_nir);
led_nir_less_mean = led_nir - ones(size(nir.time(nir.t.shutter==1)))*mean(led_nir);
%%
figure; 
ax0(1) = subplot(2,1,1);
lines = plot([1:size(led_less_mean,1)], led_less_mean(:,100:100:end),'-'); recolor(lines,vis.nm(100:100:end))
ax0(2) = subplot(2,1,2);
plot([1:size(led_nir_less_mean,1)], led_nir_less_mean(:,100:100:end),'-');
linkaxes(ax0,'x');

%%
figure; 
ax3(1) = subplot(2,1,1); 
plot(vis.nm, mean(led),'-');
title(['mean lights: ', vis.fname],'interp','none');
ax3(2) = subplot(2,1,2);
lines = plot(vis.nm, led - ones(size(vis.time(vis.t.shutter==1)))*mean(led),'-');
recolor(lines,[1:length(lines)]);
linkaxes(ax3,'x');

%%

figure; 
ax4(1) = subplot(2,1,1); 
plot(nir.nm, mean(led_nir),'-');
title(['mean nir lights: ',nir.fname],'interp','none');
ax4(2) = subplot(2,1,2);
lines = plot(nir.nm, led_nir - ones(size(nir.time(nir.t.shutter==1)))*mean(led_nir),'-');
recolor(lines,[1:length(lines)]);
linkaxes(ax4,'x');

%%


return