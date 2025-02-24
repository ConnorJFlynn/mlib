function amice_exp20240725_BC
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)

% PSAP and CLAP == 17.81 mm2
% AE33 % Also according MaGee according to Gunnar...
% AE33 spot size is 10 mm diam ae.spot_area = pi .* 5.^2; = 78.54
% TAP spot area = 30.66 mm2 by manual
% MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2

%% AE33 % AE33 spot size is 10 mm diam ae.spot_area = pi .* 5.^2; = 78.54

SM = 300; % 300-s 5-minute flow smoothing
name_str = 'AE33'; ae33 =  pack_ae33; xap = ae33; 
flow_sm = smooth(xap.Flow1.*(1-xap.zeta_leak)./1000,SM,'moving')
time = xap.time; wl = xap.wl; 
Bap = Bap_ss(xap.time, flow_sm, xap.Tr1, 60, xap.spot_area); ae33.Bap = Bap;
%%
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str, wl(w))};
end
legend(legstr)
zoom('on') 
menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim; xl_ = time>xl(1)&time<xl(2);
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   v(1).t, v(4).retval,'-',v(1).t, v(5).retval,'-',v(1).t, v(6).retval,'-',...
   v(1).t, v(7).retval,'-',vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);
figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx
legend({[name_str, ' AAE fit']});
ae33.v = v; ae33.vAAE = vAAE;

%% CLAP10 % PSAP and CLAP == 17.81 mm2
name_str = 'CLAP10';clap10 = amice_xap_auto; xap = clap10; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60); clap10.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx
legend({[name_str, ' AAE fit']});

clap10.v = v; clap10.vAAE = vAAE;

%% CLAP92 % PSAP and CLAP == 17.81 mm2
name_str = 'CLAP92';clap92 = amice_xap_auto; xap = clap92;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60); clap92.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx;
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx
legend({[name_str, ' AAE fit']});
clap92.v = v; clap92.vAAE = vAAE;

%% TAP12 % TAP spot area = 30.66 mm2 by manual
name_str = 'TAP12';tap12 = amice_xap_auto; xap = tap12;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60,30.66); tap12.Bap = Bap;

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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx;
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx
legend({[name_str, ' AAE fit']});
tap12.v = v; tap12.vAAE = vAAE;

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
menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim;
 xl_ = time>xl(1)&time<xl(2);
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx;
legend({[name_str, ' AAE fit']});
tap13.v = v; tap13.vAAE = vAAE;

% Line "A"
%% PSAP77 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP77';psap77 = amice_pxap_auto; psap77.wl = [470, 522, 660];xap = psap77; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60); psap77.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx;
legend({[name_str, ' AAE fit']});
psap77.v = v; psap77.vAAE = vAAE;

%% PSAP110 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP110';psap110 = amice_pxap_auto; psap110.wl = [470, 522, 660];xap = psap110; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60); psap110.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx;
legend({[name_str, ' AAE fit']});
psap110.v = v; psap110.vAAE = vAAE;

%% PSAP123 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP123';psap123 = amice_pxap_auto; psap123.wl = [470, 522, 660];xap = psap123; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
Bap = Bap_ss(xap.time, flow_sm, xap.Tr, 60); psap123.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);

figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx;
legend({[name_str, ' AAE fit']});
psap123.v = v; psap123.vAAE = vAAE;


%Line "B"

ma492 = amice_ma_auto;
%% MA492 % MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
name_str = 'ma492'; ma492 = amice_ma_auto; ma492.wl = ma492.nm;xap = ma492; 
flow_sm = smooth(xap.flow1_LPM./1000,SM,'moving')
Bap = Bap_ss(xap.time, flow_sm, xap.Tr1, 1,7.0686); ma492.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   v(1).t, v(4).retval,'-',v(1).t, v(5).retval,'-',vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);
figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx;
legend({[name_str, ' AAE fit']});
ma492.v = v; ma492.vAAE = vAAE;

%% MA492 % MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
name_str = 'ma494'; ma494 = amice_ma_auto; ma494.wl = ma494.nm;xap = ma494; 
flow_sm = smooth(xap.flow1_LPM./1000,SM,'moving')
Bap = Bap_ss(xap.time, flow_sm, xap.Tr1, 1,7.0686); ma494.Bap = Bap;
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
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   v(1).t, v(4).retval,'-',v(1).t, v(5).retval,'-',vAAE(1).t,vAAE(1).retval,'--'); logy; logx
legend([legstr, {[name_str, ' fit (500nm)']}]);
figure; plot(vAAE(1).t,vAAE(2).retval,'k--'); logy; logx;
legend({[name_str, ' AAE fit']});
ma494.v = v; ma494.vAAE = vAAE;

end