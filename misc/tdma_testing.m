%%
hyg = ancload(getfullname('*.cdf','tdma','select hyg file'));
%%
[tdma_dir,fname] = fileparts(hyg.fname);
%%
figure; plot(hyg.vars.growthfactors.data, squeeze(hyg.vars.hyg_distributions.data(:,:,1)))

%%
figure; plot(hyg.vars.growthfactors.data, squeeze(hyg.vars.hyg_distributions.data(:,1,:)))
%%

%%
bit = bit + 1;
%
b = bit-1;
mask = bitand(uint32(hyg.vars.qc_hyg_distributions.data),uint32(2.^b));
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)],double(mask)); 
axis('xy');
title({['Test #',num2str(bit),': ',hyg.vars.qc_hyg_distributions.atts.(['bit_',num2str(bit),'_description']).data],...
   ['Assessment:',hyg.vars.qc_hyg_distributions.atts.(['bit_',num2str(bit),'_assessment']).data]});
xlabel('time (Hh)')
ylabel('size bin')
colormap(ryg); colorbar;
%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], hyg.vars.size_peak_lowest.data<.98); axis('xy'); 
colorbar;colormap(ryg) ;

%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], ((hyg.vars.RH_interDMA.data>78)&(hyg.vars.RH_interDMA.data<83))|((hyg.vars.max_tail.data>93)&(hyg.vars.max_tail.data<96))); axis('xy'); 
colorbar;colormap(ryg) ;
%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], (hyg.vars.RH_interDMA.data)); axis('xy'); 
colorbar;colormap(ryg) ;
%%
%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], hyg.vars.correlation_up_down.data<0); axis('xy'); 
colorbar
%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], hyg.vars.n_total.data<5); axis('xy'); 
colorbar; colormap(ryg)
%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], hyg.vars.n_peaks.data>9); axis('xy'); 
colorbar; colormap(ryg)
%%
figure; imagesc([1:length(hyg.time)-1], [1:length(hyg.vars.size_bins.data)], (hyg.vars.max_tail.data>15)); axis('xy'); 
colorbar;colormap(ryg) 
%%

figure; imagesc(serial2Hh(hyg.time), hyg.vars.size_bins.data, (hyg.vars.max_tail.data)); axis('xy'); 
colorbar; 
%%
aqc = 0;
%%
aqc_str{1} = 'poor correlation';
aqc_str{2} = 'insufficient N';
aqc_str{3} = 'excessive peaks';
aqc_str{4} = 'tails too high';
aqc_str{5} = 'rh out of range';
aqc_str{6} = 'Growth factor of at least one peak too low flag';
aqc_str{7} = 'Growth factor of at least one peak too high flag'; 
%%

aqc = aqc+1;
figure; imagesc(serial2Hh(hyg.time), [1:length(hyg.vars.size_bins.data)], real(squeeze(double(hyg.vars.aqc_hyg_distributions.data(aqc,:,:))))); axis('xy'); 
colormap(ryg);cb = colorbar;
xlabel('time (Hh)')
ylabel('size bin')
title(aqc_str{aqc})
 set(get(cb,'title'),'string',{'QC bits set'})
 %%
 figure; imagesc(serial2Hh(hyg.time), [1:length(hyg.vars.size_bins.data)], real((hyg.vars.max_tail.data))); axis('xy'); 
title('max_tail');colorbar
%%
yspot = hyg.vars.size_peak_lowest.data(1,:)<=0.9800001;
rspot = hyg.vars.size_peak_lowest.data(1,:)<=0.93;
 figure; plot(serial2Hh(hyg.time), real((hyg.vars.size_peak_lowest.data(1,:))),'g.',...
    serial2Hh(hyg.time(yspot)), real((hyg.vars.size_peak_lowest.data(1,yspot))),'ko',...
        serial2Hh(hyg.time(rspot)), real((hyg.vars.size_peak_lowest.data(1,rspot))),'ro'); axis('xy'); 
title('size peak lowest');colorbar
%%
d = 0;
%%
d = d+1
figure; imagesc(serial2Hh(hyg.time), hyg.vars.growthfactors.data,  squeeze(hyg.vars.hyg_distributions.data(:,d,:))); axis('xy'); colorbar
xlabel('time (hh)')
ylabel('growth factor')
title(['Distribution of growth factors vs time for ',sprintf('%g',hyg.vars.size_bins.data(d)), ' micron size'])
% print('-dpng',[tdma_dir,'hyg_for_size_bin_',num2str(d),'.png'])
%%
%%
t = 0;
%%
t = t+1
figure; imagesc(hyg.vars.size_bins.data, hyg.vars.growthfactors.data,  squeeze(hyg.vars.hyg_distributions.data(:,:,t))); axis('xy'); colorbar
xlabel('size (um)')
ylabel('growth factor');
title(['Distribution of growth factors vs size bin for ',sprintf('%02.0f',round(serial2Hh(hyg.time(t)))), ':00 UTC average'])
% print('-dpng',[tdma_dir,'hyg_for_',sprintf('%02.0f',round(serial2Hh(hyg.time(t)))),'UTC.png'])
%%
ccn = ancload;


%%
sz_dist = ancload;
%%

bit = 0;
%%
figure; 
ax(1) = subplot(3,1,1); imagesc(serial2doy(sz_dist.time), sz_dist.vars.diameters.data, sz_dist.vars.size_res_n_conc.data); 
colormap('jet');
%%

ax(2) = subplot(3,1,2);
bit = bit + 1;

b = bit-1;
mask = bitand(uint32(sz_dist.vars.qc_size_res_n_conc.data),uint32(2.^b));
plot(serial2doy(sz_dist.time),double(mask)); 
axis('xy');
title({['Test #',num2str(bit),': ',sz_dist.vars.qc_size_res_n_conc.atts.(['bit_',num2str(bit),'_description']).data],...
   ['Assessment:',sz_dist.vars.qc_size_res_n_conc.atts.(['bit_',num2str(bit),'_assessment']).data]});
xlabel('time (Hh)')
ylabel('size bin')

%%
ax(3) = subplot(3,1,3);
plot(serial2doy(sz_dist.time), sz_dist.vars.volume_conc.data,'.')