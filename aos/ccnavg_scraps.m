good = ccnavg.vars.supersaturation_setpoint.data>0 &ccnavg.vars.supersaturation_setpoint.data<2;
ss_sets = unique(ccnavg.vars.supersaturation_setpoint.data(good));
%%
for s = length(ss_sets):-1:1
    ss_set_N(s) = sum(ccnavg.vars.supersaturation_setpoint.data == ss_sets(s));
end
figure; plot(ss_sets, ss_set_N,'o-')

%%
ss_sets(ss_set_N<mean(ss_set_N)) = [];

%%
ss = ccnavg.vars.supersaturation_calculated.data;
sss = ccnavg.vars.supersaturation_setpoint.data;
CCN_by_CPC = ccnavg.vars.N_CCN.data./ccnavg.vars.N_CPC.data;
%%

figure;those = plot(serial2doy(ccnavg.time(abs(sss-ss_sets(1))<.02)),CCN_by_CPC(abs(sss-ss_sets(1))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(2))<.02)),CCN_by_CPC(abs(sss-ss_sets(2))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(3))<.02)),CCN_by_CPC(abs(sss-ss_sets(3))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(4))<.02)),CCN_by_CPC(abs(sss-ss_sets(4))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(5))<.02)),CCN_by_CPC(abs(sss-ss_sets(5))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(6))<.02)),CCN_by_CPC(abs(sss-ss_sets(6))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(7))<.02)),CCN_by_CPC(abs(sss-ss_sets(7))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(8))<.02)),CCN_by_CPC(abs(sss-ss_sets(8))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(9))<.02)),CCN_by_CPC(abs(sss-ss_sets(9))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(10))<.02)),CCN_by_CPC(abs(sss-ss_sets(10))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(11))<.02)),CCN_by_CPC(abs(sss-ss_sets(11))<.02), '-',...
serial2doy(ccnavg.time(abs(sss-ss_sets(12))<.02)),CCN_by_CPC(abs(sss-ss_sets(12))<.02), '-');
recolor(those,ss_sets); colorbar
%%
 figure; scatter(ccnavg.vars.supersaturation_calculated.data, (100.*CCN_by_CPC), 32,serial2doy(ccnavg.time),'filled');
 title('N_CCN by N_CPC', 'interp','none'); ylabel('% activated'); xlabel('percent supersaturation');
 cb = colorbar;  set(get(cb,'title'),'string','time (doy)');
 axis([0,1.25,0,120]);
 
 %%
  N_dN_by_CPC = ccnavg.vars.N_CCN_dN.data ./ (ones(size(ccnavg.vars.droplet_size.data))*ccnavg.vars.N_CPC.data);
figure; these = plot(ccnavg.vars.droplet_size.data, N_dN_by_CPC(:,1:10),'-'); 
recolor(these, ccnavg.vars.supersaturation_calculated.data(1:10)); 
xlabel('droplet size [um]');
ylabel('percent of CPC');
 cb = colorbar;  set(get(cb,'title'),'string','ss%');

 %%
 figure
 imagesc(serial2doy(ccnavg.time), ccnavg.vars.droplet_size.data, N_dN_by_CPC); 
 axis('xy');
 colorbar
 
 %%
 figure; scatter(serial2doy(ccnavg.time), 100 .* CCN_by_CPC, 10, ss,'filled');
 cb = colorbar; caxis([min(ss_sets),max(ss_sets)]); 
 set(get(cb,'title'),'string','ss%')
title('N_CCN by N_CPC', 'interp','none'); ylabel('% activated'); xlabel('time [day of year]');

