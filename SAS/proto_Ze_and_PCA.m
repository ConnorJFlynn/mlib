%%
vis = SAS_read_Albert_csv;

%%

nir = SAS_read_Albert_csv;

%%
ins_dark = (vis.Shuttered_0==0);
for m = length(vis.time):-1:1
     for ii = length(vis.nm):-1:1
             back_ins(ii) = interp1(vis.time(ins_dark)-vis.time(1), vis.spec(ins_dark,ii),vis.time(m)-vis.time(1),'linear','extrap'); 
     end
     vis.spec_sans_dark(m,:) = vis.spec(m,:) - back_ins;
end     

%%
ins_dark = (nir.Shuttered_0==0);
clear back_ins
for m = length(nir.time):-1:1
     for ii = length(nir.nm):-1:1
             back_ins(ii) = interp1(nir.time(ins_dark)-nir.time(1), nir.spec(ins_dark,ii),nir.time(m)-nir.time(1),'linear','extrap'); 
     end
     nir.spec_sans_dark(m,:) = nir.spec(m,:) - back_ins;
end     

%%

figure; 
subplot(2,1,1); 
plot(serial2doy(vis.time(vis.Shuttered_0==0)), mean(vis.spec(vis.Shuttered_0==0,300:1000),2),'-x');
subplot(2,1,2); 
plot(serial2doy(nir.time(nir.Shuttered_0==0)), mean(nir.spec(nir.Shuttered_0==0,30:200),2),'-x');

%%

figure; 
subplot(2,1,2); 
imagegap(serial2doy(vis.time(vis.Shuttered_0==1))',vis.nm(vis.nm>=350&vis.nm<=1050)', vis.spec_sans_dark(vis.Shuttered_0==1,vis.nm>=350&vis.nm<=1050)');
subplot(2,1,1); 
imagegap(serial2doy(nir.time(nir.Shuttered_0==1)),nir.nm(nir.nm>900&nir.nm<1700), nir.spec_sans_dark(nir.Shuttered_0==1,nir.nm>900&nir.nm<1700)');
%%
k = 25;
not_shut = find(vis.Shuttered_0==1);

[nir.U,nir.S,nir.V] = pca(nir.spec_sans_dark(not_shut,:),k);
[vis.U, vis.S, vis.V] = pca(vis.spec_sans_dark(not_shut,:),k);
[nir.Ua,nir.Sa,nir.Va] = pca(nir.spec_sans_dark(not_shut(1:365),:),k);
[vis.Ua, vis.Sa, vis.Va] = pca(vis.spec_sans_dark(not_shut(1:365),:),k);
[nir.Ub,nir.Sb,nir.Vb] = pca(nir.spec_sans_dark(not_shut(366:end),:),k);
[vis.Ub, vis.Sb, vis.Vb] = pca(vis.spec_sans_dark(not_shut(366:end),:),k);

figure; semilogy([1:k],[diag(vis.S),diag(vis.Sa),diag(vis.Sb)],'o',[1:k],[diag(nir.S),diag(nir.Sa),diag(nir.Sb)],'+');
legend('vis','visa','visb','nir','nira','nirb')
%%
kk = [1:12];
nir.spec_gen = nir.U(:,kk)*nir.S(kk,kk)*(nir.V(:,kk)');
vis.spec_gen = vis.U(:,kk)*vis.S(kk,kk)*(vis.V(:,kk)');
vis_sub = vis.nm>300&vis.nm<1000;

nir_sub = nir.nm>1000&nir.nm<1800;
%%
figure;
semilogy([vis.nm(vis_sub),nir.nm(nir_sub)], [vis.spec_gen(1:25:end,vis_sub),nir.spec_gen(1:25:end,nir_sub)],'k-');
title(['black lines generated with ',num2str(max(kk)),' components']);
hold('on');
lines = semilogy([vis.nm(vis_sub),nir.nm(nir_sub)], [vis.spec_sans_dark(1:25:end,vis_sub),nir.spec_sans_dark(1:25:end,nir_sub)],'-');
lines = recolor(lines,serial2doy(vis.time(1:25:end))');colorbar;
hold('off');
%%
vis_sub_ii = find(vis_sub);
nir_sub = nir.nm>900&nir.nm<1800;
nir_sub_ii = find(nir_sub);
figure;
ax(1) = subplot(2,1,1);
lines_vis = semilogy(serial2doy(vis.time(not_shut)), vis.spec_sans_dark(not_shut,[vis_sub_ii(1):100:vis_sub_ii(end)]),'-');
recolor(lines_vis,vis.nm([vis_sub_ii(1):100:vis_sub_ii(end)]));
hold('on');
semilogy(serial2doy(vis.time(not_shut)), vis.spec_gen(not_shut,[vis_sub_ii(1):100:vis_sub_ii(end)]),'k.');
ax(2) = subplot(2,1,2);
lines_nir = semilogy(serial2doy(nir.time(not_shut)), nir.spec_sans_dark(not_shut,[nir_sub_ii(1):25:nir_sub_ii(end)]),'-');
recolor(lines_nir,nir.nm([nir_sub_ii(1):25:nir_sub_ii(end)]));
hold('on');
semilogy(serial2doy(nir.time(not_shut)), nir.spec_gen(not_shut,[nir_sub_ii(1):25:nir_sub_ii(end)]),'k.');
linkaxes(ax,'x')

%%
not_shut = find(vis.Shuttered_0==1);
vis_sb = vis.nm>=975&vis.nm<=990;
vis_mean_spec = mean(vis.spec_sans_dark(vis.Shuttered_0==1,vis_sb),2);
vis_reldev_spec = std(vis.spec_sans_dark(vis.Shuttered_0==1,vis_sb),1,2)./vis_mean_spec;
vis_mean_gen = mean(vis.spec_gen(vis.Shuttered_0==1,vis_sb),2);
vis_reldev_gen = std(vis.spec_gen(vis.Shuttered_0==1,vis_sb),1,2)./vis_mean_gen;

nir_sb = nir.nm>=1360&nir.nm<=1400;
nir_mean_spec = mean(nir.spec_sans_dark(nir.Shuttered_0==1,nir_sb),2);
nir_reldev_spec = std(nir.spec_sans_dark(nir.Shuttered_0==1,nir_sb),1,2)./nir_mean_spec;
nir_mean_gen = mean(nir.spec_gen(nir.Shuttered_0==1,nir_sb),2);
nir_reldev_gen = std(nir.spec_gen(nir.Shuttered_0==1,nir_sb),1,2)./nir_mean_gen;
figure; semilogy(serial2doy(vis.time(vis.Shuttered_0==1)), [vis_reldev_spec, vis_reldev_gen],'.-',...
   serial2doy(nir.time(nir.Shuttered_0==1)), [nir_reldev_spec, nir_reldev_gen],'.-');
legend('vis spec','vis gen','nir spec','nir gen')
