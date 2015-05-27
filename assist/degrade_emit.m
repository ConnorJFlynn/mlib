function degrade_emit
pname = 'C:\case_studies\assist\issues\self_light\';
HBB_mat = loadinto([pname, 'HBB.mat']);
HBB_edg = repack_edgar(HBB_mat);

[HBB_edg.cxs.x,HBB_edg.cxs.y] = RawIgm2RawSpc(HBB_edg.x,HBB_edg.y);

emis_mat = loadinto([pname, 'LRT_BB_Emiss_FullRes.mat']);
emis_edg = repack_edgar(emis_mat);
%%
rat = length(emis_igm)./length(HBB_edg.x);
mean_emis = mean(emis_edg.y);
emis_igm = ifft([emis_edg.y, fliplr(emis_edg.y)]-mean_emis);
emis_degr = fft([emis_igm(1:length(emis_igm)/(2.*rat)), emis_igm(end+1-length(emis_igm)/(2.*rat):end)])+mean_emis;
emis_interp.y = interp1(emis_edg.x, emis_edg.y, HBB_edg.cxs.x,'pchip','extrap');

figure; plot(emis_edg.x, emis_edg.y,'-ro',emis_edg.x(1:rat:end),emis_degr(1:end./2),'.k-', HBB_edg.cxs.x, emis_interp.y,'b-');
%%
figure; plot(emis_edg.x(1:rat:end),emis_degr(1:end./2)-  emis_interp.y,'b-');

%%
return