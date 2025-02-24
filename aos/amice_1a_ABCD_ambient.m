function amice_1a_ABCD_ambient
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)

% Ambient tests include finding aerosol near beginning of exp
% Comparing TS
% Comparing means on angstrom plot (screen low and high values, then nanmean)
% Good ambient days...
% Good test days: 2024_08_03_AD, first 3 hours: PSAPS, ?, AE33
% Good test days: 2024_08_05_AB , first 16-23: PSAPs, CLAPs, TAP12, bad MAs (MAs and CLAP92 out)
% Good test days: 2024_08_13_AB
% Good test days: 2024_08_19_AD
% Good test days: 2024_08_29_AB
% 2024_09_01_AC_1hr_purge
% 2024_09_05_AB no clap92 or tap12 plots, nans only
% 2024_09_09_AD
% try
% PSAP and CLAP == 17.81 mm2
% AE33 % Also according MaGee according to Gunnar...
% AE33 spot size is 10 mm diam ae.spot_area = pi .* 5.^2; = 78.54
% TAP spot area = 30.66 mm2 by manual
% MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
% AE33 % AE33 spot size is 10 mm diam ae.spot_area = pi .* 5.^2; = 78.54

mat.time = NaN;
mat.psap110to77 = NaN;
mat.psap123to77 = NaN;
mat.clap10to77 = NaN;
mat.clap92to77 = NaN;
mat.tap12to77 = NaN;
mat.tap13to77 = NaN;
mat.ma492to77 = NaN;
mat.ma494to77 = NaN;
mat.ae33to77 = NaN;
mat.fname = NaN;

amice_mat_path = getnamedpath('amice_mats');
fig_path = getnamedpath('fig_path');
SM = 300; % 300-s 5-minute flow smoothing
log_fig = figure_(7); close(log_fig);log_fig = figure_(7);
ang_fig = figure_(8); close(ang_fig);ang_fig = figure_(8); 

%% Line "A" has all 3 PSAP plus CLAP92
%% PSAP77 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP77';psap77 = amice_pxap_auto; psap77.wl = [470, 522, 660];xap = psap77; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 300); psap77.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim;
 xl_ = time>xl(1)&time<xl(2); 
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;

P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b77_550 = exp(polyval(P_ang,log(550)))
dstr = datestr(median(xap.time(xl_)),'yyyymmdd_HH_UTC');
mat.fname = [dstr(1:end-4),'.mat'];
mat.time = nanmean(xap.time(xl_));

figure_(log_fig);
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend(name_str); hold('on');
sgtitle(dstr)
figure_(ang_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend(name_str); hold('on');
sgtitle(dstr)

%% PSAP110 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP110';psap110 = amice_pxap_auto; psap110.wl = [470, 522, 660];xap = psap110; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 300); psap110.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;

P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b110_550 = exp(polyval(P_ang,log(550)));
scale_110to77 = b77_550./b110_550;
mat.psap110to77 = scale_110to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_110to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);


%% PSAP123 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP123';psap123 = amice_pxap_auto; psap123.wl = [470, 522, 660];xap = psap123; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 300); psap123.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b123_550 = exp(polyval(P_ang,log(550)));
scale_123to77 = b77_550./b123_550;
mat.psap123to77 = scale_123to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_123to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);

%% CLAP92 % PSAP and CLAP == 17.81 mm2
name_str = 'CLAP92';clap92 = amice_xap_auto; xap = clap92;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 300); clap92.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b92_550 = exp(polyval(P_ang,log(550)));
scale_92to77 = b77_550./b92_550;
mat.clap92to77 = scale_92to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_92to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);


%% Line "B" has TAP12, CLAP10, and both MA

%% MA492 % MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
name_str = 'ma492'; ma492 = amice_ma_auto; ma492.wl = ma492.nm;xap = ma492; 
flow_sm = smooth(xap.flow1_LPM./1000,SM,'moving')
Bap = Bap_ss(xap.time, flow_sm, xap.Tr1, 300,7.0686); ma492.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>1000) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b492_550 = exp(polyval(P_ang,log(550)));
scale_492to77 = b77_550./b492_550;
mat.ma492to77 = scale_492to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_492to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);


%% MA494 % MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
name_str = 'ma494'; ma494 = amice_ma_auto; ma494.wl = ma494.nm;xap = ma494; 
flow_sm = smooth(xap.flow1_LPM./1000,SM,'moving')
Bap = Bap_ss(xap.time, flow_sm, xap.Tr1, 300,7.0686); ma494.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b494_550 = exp(polyval(P_ang,log(550)));
scale_494to77 = b77_550./b494_550;
mat.ma494to77 = scale_494to77;

figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_494to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);

%% CLAP10 % PSAP and CLAP == 17.81 mm2
name_str = 'CLAP10';clap10 = amice_xap_auto; xap = clap10; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 300); clap10.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b10_550 = exp(polyval(P_ang,log(550)));
scale_10to77 = b77_550./b10_550;
mat.clap10to77 = scale_10to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_10to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);


%% TAP12 % TAP spot area = 30.66 mm2 by manual
name_str = 'TAP12';tap12 = amice_xap_auto; xap = tap12;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 300,30.66); tap12.Bap = Bap;

%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
 xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b12_550 = exp(polyval(P_ang,log(550)));
scale_12to77 = b77_550./b12_550;
mat.tap12to77 = scale_12to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_12to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);


%% Line C has AE33 (2LPM), TAP13, and CLAP10 or CLAP92

name_str = 'AE33'; ae33 =  pack_ae33; xap = ae33; 
flow_sm = smooth(xap.Flow1.*(1-xap.zeta_leak)./1000,SM,'moving')
time = xap.time; wl = xap.wl; 
Bap = Bap_ss(xap.time, flow_sm, xap.Tr1, 300, xap.spot_area); ae33.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b33_550 = exp(polyval(P_ang,log(550)));
scale_33to77 = b77_550./b33_550;
mat.ae33to77 = scale_33to77;
figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_33to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);

%% TAP13 % TAP spot area = 30.66 mm2 by manual
name_str = 'TAP13';tap13 = amice_xap_auto; xap = tap13;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60,30.66); tap13.Bap = Bap;
%%
time = xap.time;wl = xap.wl; 
clear Bap_plog P_AAE legstr v vAAE 
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str,wl(w))};
end
legend(legstr)
zoom('on') 
xlim(xl);
xl_ = time>xl(1)&time<xl(2);
Bap(Bap<0) = NaN; Bap(Bap>100) = NaN;
P_ang = polyfit(log(xap.wl), log(nanmean(Bap(xl_,:))),1);
b13_550 = exp(polyval(P_ang,log(550)));
scale_13to77 = b77_550./b13_550;
mat.tap13to77 = scale_13to77;

figure_(log_fig); 
plot(xap.wl, nanmean(Bap(xl_,:)),'-o');logy; logx; lg = legend([lg.String, name_str]);
figure_(ang_fig); 
plot(xap.wl,scale_13to77.* nanmean(Bap(xl_,:)),'-');logy; logx; lg = legend([lg.String, name_str]);


save([amice_mat_path, mat.fname],'-v7.3','-struct','mat')
% menu('Adjust figures for saving.  Click OK when done','OK');
saveas(log_fig,[fig_path,'polylog_',dstr,'.png']);
saveas(log_fig,[fig_path,'polylog_',dstr,'.fig']);
saveas(ang_fig,[fig_path,'angs_',dstr,'.png']);
saveas(ang_fig,[fig_path,'angs_',dstr,'.fig']);

end