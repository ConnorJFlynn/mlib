function amice_1a_ABCD_purge_sf
% "A" line has all 3 PSAP plus CLAP92
% "B" line has TAP12, CLAP10, and both MA
% "C" line has AE33 (2LPM), TAP13, and CLAP10 or CLAP92
% "D" line has AE33 (4LPM)

% Good test days: 2024_08_10_AB, 


% PSAP and CLAP == 17.81 mm2
% AE33 % Also according MaGee according to Gunnar...
% AE33 spot size is 10 mm diam ae.spot_area = pi .* 5.^2; = 78.54
% TAP spot area = 30.66 mm2 by manual
% MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2

%% AE33 % AE33 spot size is 10 mm diam ae.spot_area = pi .* 5.^2; = 78.54

amice_mat_path = getnamedpath('amice_mats');
scale_factors = load([amice_mat_path,'scale_factors.mat']); scale_factors = scale_factors;
fig_path = getnamedpath('fig_path');
SM = 300; % 300-s 5-minute flow smoothing
alln = [];aln = [];

name_str = 'AE33'; ae33 =  pack_ae33; xap = ae33; 
flow_sm = smooth(xap.Flow1.*(1-xap.zeta_leak)./1000,SM,'moving');
time = xap.time; wl = xap.wl; 
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr1, 64, xap.spot_area); ae33.Bap = Bap;
%%
figure; plot(time, Bap, '.'); dynamicDateTicks; 
for w = length(wl):-1:1
   legstr(w) = {sprintf('%s %1.0d nm',name_str, wl(w))};
end
legend(legstr)
zoom('on') 
menu('Zoom in to desired region and hit OK when done','OK');
xl = xlim; xl_ = time>xl(1) & time<xl(2); dtag = datestr(median(xap.time(xl_)),' mmm dd');
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr1, 1,xap.spot_area); ae33.Bap = Bap;
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; pt = plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   v(1).t, v(4).retval,'-',v(1).t, v(5).retval,'-',v(1).t, v(6).retval,'-',...
   v(1).t, v(7).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'r-', vAAE(1).t,vAAE(2).retval,'k-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.FlowC./1000));
      aln.t = 2.^([0:14]); aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;
   else
      r = length( aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.FlowC./1000));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'AE33_allan_4LPM.mat'],'-struct','alln')
ae33.v = v; ae33.vAAE = vAAE;

%% CLAP10 % PSAP and CLAP == 17.81 mm2
alln = [];aln = [];
name_str = 'CLAP10';clap10 = amice_xap_auto; xap = clap10; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64); clap10.Bap = Bap;
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
xl = xlim;  xl_ = time>xl(1)&time<xl(2);  dtag = datestr(median(xap.time(xl_)),' mmm dd');
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1); clap10.Bap = Bap;
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'-', vAAE(1).t,vAAE(2).retval,'k-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_LPM));
      aln.t = 2.^([0:14]); aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;
   else
      r = length(aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_LPM));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'CLAP10_allan.mat'],'-struct','alln')
clap10.v = v; clap10.vAAE = vAAE;

%% CLAP92 % PSAP and CLAP == 17.81 mm2
alln = [];aln = [];
name_str = 'CLAP92';clap92 = amice_xap_auto; xap = clap92;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64); clap92.Bap = Bap;
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
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1); clap92.Bap = Bap;
xl = xlim;  xl_ = time>xl(1)&time<xl(2); dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx;
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'-', vAAE(1).t,vAAE(2).retval,'k-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if ~isfield(alln,name_str)
      alln.(name_str).time = median(xap.time(xl_));
      alln.(name_str).LPM = round(median(xap.flow_LPM));
      alln.(name_str).t = 2.^([0:14]); alln.(name_str).val = NaN([1,15]);
      
      alln.(name_str).val(1:length(val)) = val;
   else
      r = length( alln.(name_str).time);
      alln.(name_str).time(r+1) = median(xap.time(xl_));
      alln.(name_str).LPM(r+1) = round(median(xap.flow_LPM));
      alln.(name_str).val(r+1,:) = NaN([1,15]);
      alln.(name_str).val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'CLAP92_allan.mat'],'-struct','alln')
clap92.v = v; clap92.vAAE = vAAE;

%% TAP12 % TAP spot area = 30.66 mm2 by manual
alln = [];aln = [];
name_str = 'TAP12';tap12 = amice_xap_auto; xap = tap12;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64, 30.66); tap12.Bap = Bap;

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
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1,30.66); tap12.Bap = Bap;
xl = xlim;  xl_ = time>xl(1)&time<xl(2); dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allanx(wl,time(xl_), 2.*Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx;
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'r-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_LPM));
      aln.t = 2.^([0:14]); aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;
   else
      r = length(aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_LPM));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'TAP12_allanx.mat'],'-struct','alln')
tap12.v = v; tap12.vAAE = vAAE;

%% TAP13 % TAP spot area = 30.66 mm2 by manual
alln = [];aln = [];
name_str = 'TAP13';tap13 = amice_xap_auto; xap = tap13;
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64, 30.66); tap12.Bap = Bap;
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
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1, 30.66); tap12.Bap = Bap;
xl = xlim; xl_ = time>xl(1)&time<xl(2); dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'r-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_LPM));
      aln.t = 2.^([0:14]); aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;
   else
      r = length(aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_LPM));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'TAP13_allan.mat'],'-struct','alln')
tap13.v = v; tap13.vAAE = vAAE;

% Line "A"
%% PSAP77 % PSAP and CLAP == 17.81 mm2
alln = [];aln = [];
name_str = 'PSAP77';psap77 = amice_pxap_auto; psap77.wl = [470, 522, 660];xap = psap77; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str))); if isempty(sf) sf = 1; end
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64); psap77.Bap = Bap;
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
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1); 
xl = xlim;  xl_ = time>xl(1)&time<xl(2);  dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'k-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_LPM));
      aln.t = 2.^([0:14]); aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;
   else
      r = length(aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_LPM));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'PSAP77_allan.mat'],'-struct','alln')
psap77.v = v; psap77.vAAE = vAAE;

alln = []; aln = [];
%% PSAP110 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP110';psap110 = amice_pxap_auto; psap110.wl = [470, 522, 660];xap = psap110; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str))); if isempty(sf) sf = 1; end
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64); psap77.Bap = Bap;
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
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1); 
xl = xlim;  xl_ = time>xl(1)&time<xl(2);  dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'k-', vAAE(1).t,vAAE(2).retval,'-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_LPM));
      aln.t = 2.^([0:14]); aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;

      % 
      % alln.(name_str).LPM = round(median(xap.flow_tot./10))./100;
      % alln.(name_str).t = 2.^([0:14]); alln.(name_str).val = NaN([1,15]);      
      % alln.(name_str).val(1:length(val)) = val;
   else
      r = length(aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_LPM));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
      % r = length( alln.(name_str).time);
      % alln.(name_str).time(r+1) = median(xap.time(xl_));
      % alln.(name_str).LPM(r+1) = round(median(xap.flow_tot./10))./100;
      % alln.(name_str).val(r+1,:) = NaN([1,15]);
      % alln.(name_str).val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'PSAP110_allan.mat'],'-struct','alln')
psap110.v = v; psap110.vAAE = vAAE;

alln = []; aln = [];
%% PSAP123 % PSAP and CLAP == 17.81 mm2
name_str = 'PSAP123';psap123 = amice_pxap_auto; psap123.wl = [470, 522, 660];xap = psap123; 
flow_sm = smooth(xap.flow_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str))); if isempty(sf) sf = 1; end
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 64); psap77.Bap = Bap;
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
Bap = sf.*Bap_ss(xap.time, flow_sm, xap.Tr, 1); 
xl = xlim;  xl_ = time>xl(1)&time<xl(2);  dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'k-', vAAE(1).t,vAAE(2).retval,'-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_LPM));
      aln.t = 2.^([0:14]); 
      aln.val = NaN([1,15]);      
      aln.val(1:length(val)) = val;

      % 
      % alln.(name_str).LPM = round(median(xap.flow_tot./10))./100;
      % alln.(name_str).t = 2.^([0:14]); alln.(name_str).val = NaN([1,15]);      
      % alln.(name_str).val(1:length(val)) = val;
   else
      r = length(aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_LPM));
      aln.val(r+1,:) = NaN([1,15]);
      aln.val(r+1,1:length(val)) = val;
      % r = length( alln.(name_str).time);
      % alln.(name_str).time(r+1) = median(xap.time(xl_));
      % alln.(name_str).LPM(r+1) = round(median(xap.flow_tot./10))./100;
      % alln.(name_str).val(r+1,:) = NaN([1,15]);
      % alln.(name_str).val(r+1,1:length(val)) = val;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'PSAP123_allan.mat'],'-struct','alln')
psap123.v = v; psap123.vAAE = vAAE;


%Line "B"
alln = []; aln = [];
%% MA492 % MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
name_str = 'ma350'; ma492 = amice_ma_auto; ma492.wl = ma492.nm;xap = ma492; 
flow_sm = smooth(xap.flow1_LPM,SM,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.* Bap_ss(xap.time, flow_sm, xap.Tr1, 64,7.0686); ma492.Bap = Bap;
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
xl = xlim;  xl_ = time>xl(1)&time<xl(2);  dtag = datestr(median(xap.time(xl_)),' mmm dd');
Bap = sf.* Bap_ss(xap.time, flow_sm, xap.Tr1, 1,7.0686); ma492.Bap = Bap;
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   v(1).t, v(4).retval,'-',v(1).t, v(5).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if isempty(aln)
      aln.time = median(xap.time(xl_));
      aln.LPM = round(median(xap.flow_tot./10))./100;
      aln.t = vAAE(1).t      
      aln.val =vAAE(1).retval
   else
      r = length( aln.time);
      aln.time(r+1) = median(xap.time(xl_));
      aln.LPM(r+1) = round(median(xap.flow_tot./10))./100;
      aln.t(r+1,:) = v(1).t;
      aln.val(r+1,1:length(val)) = vAAE(1).retval;
   end
end
alln.(name_str) = aln;
save([amice_mat_path,'MA350_allan.mat'],'-struct','alln')

%% MA492 % MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
name_str = 'ma494'; ma494 = amice_ma_auto; ma494.wl = ma494.nm;xap = ma494; 
flow_sm = smooth(xap.flow1_LPM,SM./30,'moving');
sf = scale_factors.scales_filled(foundstr(scale_factors.inst,lower(name_str)));
Bap = sf.* Bap_ss(xap.time, flow_sm, xap.Tr1, 10,7.0686); ma494.Bap = Bap;
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
xl = xlim;  xl_ = time>xl(1)&time<xl(2);  dtag = datestr(median(xap.time(xl_)),' mmm dd');
[v,vAAE] = multi_allan(wl,time(xl_), Bap(xl_,:));
vt = vAAE(1).t; val = vAAE(1).retval;
figure; plot(v(1).t, v(1).retval,'-',v(1).t, v(2).retval,'-',v(1).t, v(3).retval,'-',...
   v(1).t, v(4).retval,'-',v(1).t, v(5).retval,'-'); logy; logx
legend(legstr); sgtitle([name_str, dtag]);
figure; plot(vAAE(1).t,vAAE(1).retval,'-', vAAE(1).t,vAAE(2).retval,'k-'); logy; logx
legend({[name_str,dtag, ' fit(500nm)'],[name_str, dtag, ' AAE fit']});
sgtitle([name_str, ' Allan plot']);
kp = menu('Keep?','No','Yes');
if kp==2
   if ~isfield(alln,name_str)
      alln.(name_str).time = median(xap.time(xl_));
      alln.(name_str).LPM = round(median(xap.flow_tot./10))./100;
      alln.(name_str).t = 2.^([0:14]); alln.(name_str).val = NaN([1,15]);
      
      alln.(name_str).val(1:length(val)) = val;
   else
      r = length( alln.(name_str).time);
      alln.(name_str).time(r+1) = median(xap.time(xl_));
      alln.(name_str).LPM(r+1) = round(median(xap.flow_tot./10))./100;
      alln.(name_str).val(r+1,:) = NaN([1,15]);
      alln.(name_str).val(r+1,1:length(val)) = val;
   end
end
save([amice_mat_path,'MA494_allan.mat'],'-struct','alln')
ma494.v = v; ma494.vAAE = vAAE;

end