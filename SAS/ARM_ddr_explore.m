function ARM_ddr_explore % Current situation with HOU comparisons:
% There seemed to be a notable difference in DDR agrreement between 
% MFR and SAS 
% Want to use a clear sky case with diffuse hemisp from 0-3 airmass to set a factor
% between MFRSR and SAS, then apply this factor to the direct beam to see how
% different they are.  Perhaps draw in Cimel direct_transmittance 

cim = rd_anetaod_v3;
if foundstr(cim.site,'High')
   mfr = load('D:\aodfit_be\pvc\pvcmfrsraodM1.c1.filt.mat'); % save('D:\aodfit_be\pvc\pvcmfrsraodM1.c1.filt.mat','-struct','mfr')
   sasv = load('D:\aodfit_be\pvc\pvcsashevisaodM1.c1.filt.mat');
   sasn = load('D:\aodfit_be\pvc\pvcsasheniraodM1.c1.filt.mat');
   iop ='TCAP '; tla = 'pvc';
elseif foundstr(cim.site,'Jolla')
   mfr = load('D:\epc\epcmfrsr7nchM1.b1.filtered.mat'); %save('D:\epc\epcmfrsr7nchM1.b1.filtered.mat','-struct','mfr');
   % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter1>0);
   % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter2>0);
   % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter3>0);
   % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter4>0);
   % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter5>0);
   % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter7>0);
   sasv = load('D:\epc\epcsashevisaodM1.c1.filt.mat');
   sasn = load('D:\epc\epcsasheniraodM1.c1.filt.mat');
   iop = 'EPCAPE '; tla = 'epc';
else
   mfr = load('D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.filtered.mat');
     % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter1>0);
     % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter2>0);
     % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter3>0);
     % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter4>0);
     % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter5>0);
     % mfr = anc_sift(mfr, mfr.vdata.direct_normal_narrowband_filter7>0);
     % save('D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.filtered.mat','-struct','mfr')
   sasv = load('D:\aodfit_be\hou\housashevisaodM1.c1.filt.mat');
   sasn = load('D:\aodfit_be\hou\housasheniraodM1.c1.filt.mat');
   iop = 'TRACER '; tla = 'hou';
end
fig_path = [fileparts(cim.pname), filesep,'figs',filesep];
if ~isadir(fig_path)
   mkdir(fig_path)
end

sasv = anc_sift(sasv, sasv.vdata.airmass>=1&sasv.vdata.airmass<=6);  
sasn = anc_sift(sasn, sasn.vdata.airmass>=1&sasn.vdata.airmass<=6);
[mins, sinm] = nearest(mfr.time, sasv.time);

figure; ss(1) = subplot(3,1,3);plot(mfr.time(mins), mfr.vdata.diffuse_hemisp_narrowband_filter2(mins),'.',...
   sasv.time(sinm), 2.2*sasv.vdata.diffuse_transmittance(4,sinm),'r.'); dynamicDateTicks; zoom('on'); logy; 
menu('Zoom into desired time range and click OK','OK');
xl = xlim; 
xl_ = mfr.time>=xl(1)&mfr.time<=xl(2)&mfr.vdata.airmass<=3; 
xl_s = sasv.time>=xl(1) & sasv.time<=xl(2)& sasv.vdata.airmass<=3;
xl_n = sasn.time>=xl(1) & sasn.time<=xl(2)& sasn.vdata.airmass<=3;
% Next section
nm_str = '415 nm';
mi = 1; ms =2;
sdn = sasv.vdata.direct_normal_transmittance(ms,:); 
sdh = sasv.vdata.diffuse_transmittance(ms,:);
mdn = mfr.vdata.direct_normal_narrowband_filter1; 
mdh = mfr.vdata.diffuse_hemisp_narrowband_filter1;
top_str = [iop, 'MFRSR and SAS direct normal to diffuse ratio: ',nm_str]
poss = sdn>0 & sdh>0; posm = mdn>0 & mdh>0;
sddr(mi) = mean(sdn(poss&xl_s))./mean(sdh(poss&xl_s));
mddr(mi) = mean(mdn(posm&xl_))./mean(mdh(posm&xl_));
SFN(mi) = mean(sdn(poss&xl_s))./mean(mdn(posm&xl_));
SFD(mi) = mean(sdh(poss&xl_s))./mean(mdh(posm&xl_));
bot_str = sprintf(['SASHe DDR / MFRSR DDR = %2.2f'],sddr(mi)./mddr(mi));

figure
ss(1) = subplot(3,1,1); plot(mfr.time, mdn./mdh,'.',...
   sasv.time, sdn./sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title({top_str;bot_str}); legend('mfr, scaled','sas')
ss(2) = subplot(3,1,2); plot(mfr.time, SFN(mi).*mdn,'.',...
   sasv.time, sdn,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Direct normal, Scale Factor = %2.2f',SFN(1)));legend('mfr, scaled','sas')
ss(3) = subplot(3,1,3); plot(mfr.time, SFD(mi).*mdh,'.',...
   sasv.time, sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Diffuse hemispheric, Scale Factor = %2.2f',SFD(mi)));legend('mfr, scaled','sas');
linkaxes(ss,'x'); xlim(xl);
ok = menu('Click OK when ready to save figure:','OK');
nm = strrep(nm_str,' ','');
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.png'],' ','_'));
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.fig'],' ','_'));

% Next section
nm_str = ['500 nm']
mi = 2; ms =4;
mdn = mfr.vdata.direct_normal_narrowband_filter2; 
mdh = mfr.vdata.diffuse_hemisp_narrowband_filter2;
sdn = sasv.vdata.direct_normal_transmittance(ms,:); 
sdh = sasv.vdata.diffuse_transmittance(ms,:);
top_str = [iop, 'MFRSR and SAS direct normal to diffuse ratio: ',nm_str]
poss = sdn>0 & sdh>0; posm = mdn>0 & mdh>0;
sddr(mi) = mean(sdn(poss&xl_s))./mean(sdh(poss&xl_s));
mddr(mi) = mean(mdn(posm&xl_))./mean(mdh(posm&xl_));
SFN(mi) = mean(sdn(poss&xl_s))./mean(mdn(posm&xl_));
SFD(mi) = mean(sdh(poss&xl_s))./mean(mdh(posm&xl_));
bot_str = sprintf(['SASHe DDR / MFRSR DDR = %2.2f'],sddr(mi)./mddr(mi));

figure
ss(1) = subplot(3,1,1); plot(mfr.time, mdn./mdh,'.',...
   sasv.time, sdn./sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title({top_str;bot_str}); legend('mfr, scaled','sas')
ss(2) = subplot(3,1,2); plot(mfr.time, SFN(mi).*mdn,'.',...
   sasv.time, sdn,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Direct normal, Scale Factor = %2.2f',SFN(1)));legend('mfr, scaled','sas')
ss(3) = subplot(3,1,3); plot(mfr.time, SFD(mi).*mdh,'.',...
   sasv.time, sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Diffuse hemispheric, Scale Factor = %2.2f',SFD(mi)));legend('mfr, scaled','sas');
linkaxes(ss,'x'); xlim(xl);
ok = menu('Click OK when ready to save figure:','OK');
nm = strrep(nm_str,' ','');
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.png'],' ','_'));
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.fig'],' ','_'));

% Next section
nm_str = '615 nm';
mi = 3; ms =5;
mdn = mfr.vdata.direct_normal_narrowband_filter3; 
mdh = mfr.vdata.diffuse_hemisp_narrowband_filter3;
sdn = sasv.vdata.direct_normal_transmittance(ms,:); 
sdh = sasv.vdata.diffuse_transmittance(ms,:);
top_str = [iop, 'MFRSR and SAS direct normal to diffuse ratio: ',nm_str]
poss = sdn>0 & sdh>0; posm = mdn>0 & mdh>0;
sddr(mi) = mean(sdn(poss&xl_s))./mean(sdh(poss&xl_s));
mddr(mi) = mean(mdn(posm&xl_))./mean(mdh(posm&xl_));
SFN(mi) = mean(sdn(poss&xl_s))./mean(mdn(posm&xl_));
SFD(mi) = mean(sdh(poss&xl_s))./mean(mdh(posm&xl_));
bot_str = sprintf(['SASHe DDR / MFRSR DDR = %2.2f'],sddr(mi)./mddr(mi));

figure
ss(1) = subplot(3,1,1); plot(mfr.time, mdn./mdh,'.',...
   sasv.time, sdn./sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title({top_str;bot_str}); legend('mfr, scaled','sas')
ss(2) = subplot(3,1,2); plot(mfr.time, SFN(mi).*mdn,'.',...
   sasv.time, sdn,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Direct normal, Scale Factor = %2.2f',SFN(1)));legend('mfr, scaled','sas')
ss(3) = subplot(3,1,3); plot(mfr.time, SFD(mi).*mdh,'.',...
   sasv.time, sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Diffuse hemispheric, Scale Factor = %2.2f',SFD(mi)));legend('mfr, scaled','sas');
linkaxes(ss,'x'); xlim(xl);
ok = menu('Click OK when ready to save figure:','OK');
nm = strrep(nm_str,' ','');
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.png'],' ','_'));
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.fig'],' ','_'));

% Next section
nm_str = ' 675 nm';
mi = 4; ms =6;
mdn = mfr.vdata.direct_normal_narrowband_filter3; 
mdh = mfr.vdata.diffuse_hemisp_narrowband_filter3;
sdn = sasv.vdata.direct_normal_transmittance(ms,:); 
sdh = sasv.vdata.diffuse_transmittance(ms,:);
top_str = [iop, 'MFRSR and SAS direct normal to diffuse ratio: ',nm_str]
poss = sdn>0 & sdh>0; posm = mdn>0 & mdh>0;
sddr(mi) = mean(sdn(poss&xl_s))./mean(sdh(poss&xl_s));
mddr(mi) = mean(mdn(posm&xl_))./mean(mdh(posm&xl_));
SFN(mi) = mean(sdn(poss&xl_s))./mean(mdn(posm&xl_));
SFD(mi) = mean(sdh(poss&xl_s))./mean(mdh(posm&xl_));
bot_str = sprintf(['SASHe DDR / MFRSR DDR = %2.2f'],sddr(mi)./mddr(mi));

figure
ss(1) = subplot(3,1,1); plot(mfr.time, mdn./mdh,'.',...
   sasv.time, sdn./sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title({top_str;bot_str}); legend('mfr, scaled','sas')
ss(2) = subplot(3,1,2); plot(mfr.time, SFN(mi).*mdn,'.',...
   sasv.time, sdn,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Direct normal, Scale Factor = %2.2f',SFN(1)));legend('mfr, scaled','sas')
ss(3) = subplot(3,1,3); plot(mfr.time, SFD(mi).*mdh,'.',...
   sasv.time, sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Diffuse hemispheric, Scale Factor = %2.2f',SFD(mi)));legend('mfr, scaled','sas');
linkaxes(ss,'x'); xlim(xl);
ok = menu('Click OK when ready to save figure:','OK');
nm = strrep(nm_str,' ','');
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.png'],' ','_'));
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.fig'],' ','_'));

% Next section
nm_str = ['870 nm']
mi = 5; ms =7;
mdn = mfr.vdata.direct_normal_narrowband_filter5; 
mdh = mfr.vdata.diffuse_hemisp_narrowband_filter5;
sdn = sasv.vdata.direct_normal_transmittance(ms,:); 
sdh = sasv.vdata.diffuse_transmittance(ms,:);
top_str = [iop, 'MFRSR and SAS direct normal to diffuse ratio: ',nm_str]
poss = sdn>0 & sdh>0; posm = mdn>0 & mdh>0;
sddr(mi) = mean(sdn(poss&xl_s))./mean(sdh(poss&xl_s));
mddr(mi) = mean(mdn(posm&xl_))./mean(mdh(posm&xl_));
SFN(mi) = mean(sdn(poss&xl_s))./mean(mdn(posm&xl_));
SFD(mi) = mean(sdh(poss&xl_s))./mean(mdh(posm&xl_));
bot_str = sprintf(['SASHe DDR / MFRSR DDR = %2.2f'],sddr(mi)./mddr(mi));

figure
ss(1) = subplot(3,1,1); plot(mfr.time, mdn./mdh,'.',...
   sasv.time, sdn./sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title({top_str;bot_str}); legend('mfr, scaled','sas')
ss(2) = subplot(3,1,2); plot(mfr.time, SFN(mi).*mdn,'.',...
   sasv.time, sdn,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Direct normal, Scale Factor = %2.2f',SFN(1)));legend('mfr, scaled','sas')
ss(3) = subplot(3,1,3); plot(mfr.time, SFD(mi).*mdh,'.',...
   sasv.time, sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
title(sprintf('Diffuse hemispheric, Scale Factor = %2.2f',SFD(mi)));legend('mfr, scaled','sas');
linkaxes(ss,'x'); xlim(xl);
ok = menu('Click OK when ready to save figure:','OK');
nm = strrep(nm_str,' ','');
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.png'],' ','_'));
saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.fig'],' ','_'));

% Next section
if isfield(mfr.vdata, 'direct_normal_narrowband_filter7')
   nm_str = ['1625 nm']
   mi = 7; ms =2; xl_s = xl_n;
   mdn = mfr.vdata.direct_normal_narrowband_filter7;
   mdh = mfr.vdata.diffuse_hemisp_narrowband_filter7;
   sdn = sasn.vdata.direct_normal_transmittance(ms,:);
   sdh = sasn.vdata.diffuse_transmittance(ms,:);
   top_str = [iop, 'MFRSR and SAS direct normal to diffuse ratio: ',nm_str]
   poss = sdn>0 & sdh>0; posm = mdn>0 & mdh>0;
   sddr(mi) = mean(sdn(poss&xl_s))./mean(sdh(poss&xl_s));
   mddr(mi) = mean(mdn(posm&xl_))./mean(mdh(posm&xl_));
   SFN(mi) = mean(sdn(poss&xl_s))./mean(mdn(posm&xl_));
   SFD(mi) = mean(sdh(poss&xl_s))./mean(mdh(posm&xl_));
   bot_str = sprintf(['SASHe DDR / MFRSR DDR = %2.2f'],sddr(mi)./mddr(mi));

   figure
   ss(1) = subplot(3,1,1); plot(mfr.time, mdn./mdh,'.',...
      sasn.time, sdn./sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
   title({top_str;bot_str}); legend('mfr, scaled','sas')
   ss(2) = subplot(3,1,2); plot(mfr.time, SFN(mi).*mdn,'.',...
      sasn.time, sdn,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
   title(sprintf('Direct normal, Scale Factor = %2.2f',SFN(1)));legend('mfr, scaled','sas')
   ss(3) = subplot(3,1,3); plot(mfr.time, SFD(mi).*mdh,'.',...
      sasn.time, sdh,'r.'); dynamicDateTicks; zoom('on'); logy; xlim(xl)
   title(sprintf('Diffuse hemispheric, Scale Factor = %2.2f',SFD(mi)));legend('mfr, scaled','sas');
   linkaxes(ss,'x'); xlim(xl);
   ok = menu('Click OK when ready to save figure:','OK');
   nm = strrep(nm_str,' ','');
   saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.png'],' ','_'));
   saveas(gcf,strrep([fig_path, filesep,tla, '_DDR_',nm,'.fig'],' ','_'));

end


return