 %trt_snr
%%
clear
lights = loadinto
%%
done = false;
while ~done
   darks = loadinto
   done = (lights.tint==darks.tint && lights.Nsamples==darks.Nsamples && ...
      lights.AdjacentPixels==darks.AdjacentPixels && ...
      strcmp(lights.Spec_desc,darks.Spec_desc)&&(lights.nm(1)==darks.nm(1))&& ...
      (lights.nm(end)==darks.nm(end))&&(length(lights.nm)==length(darks.nm)));
end
%%

lights.sig = (lights.mean_samp - darks.mean_samp);
lights.pct_noise = 100.*abs(lights.std_samp ./ lights.sig);
figure(11); ax(1) = subplot(2,1,1); semilogy(lights.nm, lights.sig./max(lights.sig), '-');
yl = ylim;
ylim([yl(1),5])
title([lights.fname,': max signal was ',sprintf('%3.2f',max(lights.sig))])
ylabel('cts-darks')
ax(2) = subplot(2,1,2); plot(lights.nm, lights.pct_noise)
ylabel('noise %');
title(lights.title);
linkaxes(ax,'x');
saveas(gcf,[lights.pname, lights.fname,'.png'])
save([lights.pname, lights.fname,'.mat'],'lights');

%%