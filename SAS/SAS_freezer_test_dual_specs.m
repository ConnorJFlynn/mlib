function mono = SAS_temp_test_interp_dk_with_headers(indir)
% Now reading new data format with 1 file per spectrometer, each file has a
% header row identifying the measurements in underlying columns.
nir_tmp = getfullname('*.csv;*.mat','ava','Select NIR spectrometer 46');
[p,f,x] = fileparts(nir_tmp);
[A,~] = strtok(f,'_');
vis_tmp = getfullname([A,'*.csv;',A,'*.mat'],'ava','Select VIS spectrometer 47');
trh_tmp = getfullname([A,'*T_RH.csv;',A,'*T_RH.mat'],'ava','Select trh file');

if strcmp(nir_tmp(end-2:end),'mat')
   NIR_spec = loadinto(nir_tmp);
else
   NIR_spec = SAS_read_Albert_csv(nir_tmp);
end
[pname, fname, ext] = fileparts(nir_tmp);
NIR_spec.pname = pname;
NIR_spec.fname = [fname, ext];
[dmp, sn] = strtok(fname,'_');
NIR_spec.sn = sn(2:end);

if strcmp(vis_tmp(end-2:end),'mat')
   VIS_spec = loadinto(vis_tmp);
else
   VIS_spec = SAS_read_Albert_csv(vis_tmp);
end
[pname, fname, ext] = fileparts(vis_tmp);
VIS_spec.pname = pname;
VIS_spec.fname = [fname, ext];
[dmp, sn] = strtok(fname,'_');
VIS_spec.sn = sn(2:end);



if strcmp(trh_tmp(end-2:end),'mat')
   trh = loadinto(trh_tmp);
else
trh = SAS_read_trh(trh_tmp);
end
[pname, fname, ext] = fileparts(trh_tmp);
trh.pname = pname;
trh.fname = [fname, ext];

%Minor (but unexplained) difference between Albert and my computation of
%Humirel temperatures
%More significant (and unexplained) differences between precon and humirel
%RH measurements
%%
if ~isfield(NIR_spec,'spec_sans_dark')
%%
tic
darks = zeros(size(NIR_spec.spec));
dark_times = (NIR_spec.Shuttered_0==0);
dark_ii = find(dark_times);
dk_r = [1:dark_ii(1)]';
darks(dk_r,:) = ones(size(dk_r))*NIR_spec.spec(dark_ii(1),:);
for dd = 1:length(dark_ii)-1
   dk_r = [dark_ii(dd):dark_ii(dd+1)]';
   w = (NIR_spec.time(dk_r)-NIR_spec.time(dark_ii(dd)))./(NIR_spec.time(dark_ii(dd+1))-NIR_spec.time(dark_ii(dd)));
   darks(dk_r,:) = (1-w)*NIR_spec.spec(dark_ii(dd),:) + w*NIR_spec.spec(dark_ii(dd+1),:);
end
dk_r = [dark_ii(end):length(dark_times)]';
darks(dk_r,:) = ones(size(dk_r))*NIR_spec.spec(dark_ii(end),:);
NIR_spec.spec_sans_dark = NIR_spec.spec - darks;

toc
%%
tic
darks = zeros(size(VIS_spec.spec));
dark_times = (VIS_spec.Shuttered_0==0);
dark_ii = find(dark_times);
dk_r = [1:dark_ii(1)]';
darks(dk_r,:) = ones(size(dk_r))*VIS_spec.spec(dark_ii(1),:);
for dd = 1:length(dark_ii)-1
   dk_r = [dark_ii(dd):dark_ii(dd+1)]';
   w = (VIS_spec.time(dk_r)-VIS_spec.time(dark_ii(dd)))./(VIS_spec.time(dark_ii(dd+1))-VIS_spec.time(dark_ii(dd)));
   darks(dk_r,:) = (1-w)*VIS_spec.spec(dark_ii(dd),:) + w*VIS_spec.spec(dark_ii(dd+1),:);
end
dk_r = [dark_ii(end):length(dark_times)]';
darks(dk_r,:) = ones(size(dk_r))*VIS_spec.spec(dark_ii(end),:);
VIS_spec.spec_sans_dark = VIS_spec.spec - darks;
clear darks
toc
%%
end
%%
if isfield(NIR_spec, 'Temp')
   NIR_spec.Temp1 = NIR_spec.Temp;
end
if isfield(VIS_spec, 'Temp')
   VIS_spec.Temp1 = VIS_spec.Temp;
end
%%
if ~exist([VIS_spec.pname,filesep,'vis_spec_',datestr(VIS_spec.time(1),'yyyymmdd'),'.mat'],'file')
save([VIS_spec.pname,filesep,'vis_spec_',datestr(VIS_spec.time(1),'yyyymmdd'),'.mat'],'VIS_spec');
save([NIR_spec.pname,filesep,'nir_spec_',datestr(VIS_spec.time(1),'yyyymmdd'),'.mat'],'NIR_spec');
save([trh.pname,filesep,'trh_',datestr(VIS_spec.time(1),'yyyymmdd'),'.mat'],'trh');
end
%%

%%
figure; s(1) = subplot(2,1,1); 
plot(serial2Hh(trh.time), 100.*(1-trh.V_Temp1./max(trh.V_Temp1)),...
'r',serial2Hh(NIR_spec.time), NIR_spec.Temp1, 'go', serial2Hh(NIR_spec.time),NIR_spec.Temp2, 'gx',serial2Hh(VIS_spec.time), VIS_spec.Temp1, 'bo',serial2Hh(VIS_spec.time), VIS_spec.Temp2, 'bx'  )
% plot(serial2Hh(NIR_spec.time), NIR_spec.Temp1, 'go', serial2Hh(NIR_spec.time),NIR_spec.Temp2, 'gx',serial2Hh(VIS_spec.time), VIS_spec.Temp1, 'bo',serial2Hh(VIS_spec.time), VIS_spec.Temp2, 'bx'  )
legend('temp','nir temp1','nir temp2','vis temp1','vis temp2');
xlabel('hours');
ylabel('deg C');
s(2) = subplot(2,1,2);
plot(serial2Hh(VIS_spec.time(VIS_spec.Shuttered_0==1)), mean(VIS_spec.spec_sans_dark((VIS_spec.Shuttered_0==1),740:770),2)./max(mean(VIS_spec.spec_sans_dark((VIS_spec.Shuttered_0==1),740:770),2)),'b.',...
   serial2Hh(NIR_spec.time((NIR_spec.Shuttered_0==1))), mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,102:110),2)./max(mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,102:110),2)),'k.',...
   serial2Hh(NIR_spec.time(NIR_spec.Shuttered_0==1)), mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,189:199),2)./max(mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,189:199),2)),'r.');
legend('vis 700 nm','nir 1300 nm','nir 1600 nm')
xlabel('hours');
ylabel('variation')
linkaxes(s,'x')
% figure; lines = plot(NIR_spec.nm, NIR_spec.spec_sans_dark./VIS_spec.spec, '-');
% lines = recolor(lines, NIR_spec.Temp');colorbar
%%

figure; s(1) = subplot(2,1,1); 
plot(serial2Hh(trh.time), 100.*(1-trh.Temp1./max(trh.Temp1)),...
'r',serial2Hh(NIR_spec.time), NIR_spec.Temp1, 'go', serial2Hh(NIR_spec.time),2.*NIR_spec.Temp2, 'gx')
% plot(serial2Hh(NIR_spec.time), NIR_spec.Temp1, 'go', serial2Hh(NIR_spec.time),NIR_spec.Temp2, 'gx',serial2Hh(VIS_spec.time), VIS_spec.Temp1, 'bo',serial2Hh(VIS_spec.time), VIS_spec.Temp2, 'bx'  )
legend('temp','nir temp1','nir temp2');
xlabel('hours');
ylabel('deg C');
s(2) = subplot(2,1,2);
plot(serial2Hh(NIR_spec.time((NIR_spec.Shuttered_0==1))), mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,102:110),2)./max(mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,102:110),2)),'k.',...
   serial2Hh(NIR_spec.time(NIR_spec.Shuttered_0==1)), mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,189:199),2)./max(mean(NIR_spec.spec_sans_dark(NIR_spec.Shuttered_0==1,189:199),2)),'r.');
legend('nir 1300 nm','nir 1600 nm')
xlabel('hours');
ylabel('variation')
linkaxes(s,'x')
% figure; lines = plot(NIR_spec.nm, NIR_spec.spec_sans_dark./VIS_spec.spec, '-');
% lines = recolor(lines, NIR_spec.Temp');colorbar

%%
figure; plot(VIS_spec.nm, VIS_spec.spec_sans_dark(704,:), 'k.',...
   NIR_spec.nm, NIR_spec.spec_sans_dark(704,:),'r.');
%%
figure; 
subplot(2,1,1);
lines_n = plot(NIR_spec.nm, NIR_spec.spec_sans_dark, '-');

lines_n = recolor(lines_n, NIR_spec.Temp2',[5,8]);colorbar
subplot(2,1,2);
lines_v = plot(VIS_spec.nm, VIS_spec.spec_sans_dark, '-');

lines_v = recolor(lines_v, VIS_spec.Temp2',[5,8]);colorbar

%%
 plot([1:length(NIR_spec.nm)],NIR_spec.nm,'.')

%%
NIR_spec.dif_spec = diff(NIR_spec.spec_sans_dark);
NIR_spec.normdif_spec = NIR_spec.dif_spec./NIR_spec.spec_sans_dark(2:end,:);
NIR_spec.dif_temp = diff(NIR_spec.Temp2);
NIR_spec.normdif_spec_dT = NIR_spec.normdif_spec./(NIR_spec.dif_temp*ones(size(NIR_spec.nm)));

%%
figure; lines3 = semilogy(NIR_spec.nm, abs(NIR_spec.normdif_spec), '-');
lines3 = recolor(lines3,NIR_spec.Temp2(2:end)',[-5,10]);
colorbar
title({['Pixel-by-pixel temporal stability of NIR  under changing temperature'],NIR_spec.sn})

%%
figure; plot(NIR_spec.Temp2(1:400), sum(abs(diff(NIR_spec.spec_sans_dark(1:400,:),[],2)),2),'o');
title({['Pixel-to-pixel variability of NIR under changing temperature'],NIR_spec.sn})
xlabel('Temperature [deg C]');
ylabel('sum(abs(diff(mono.spec_nir)))','interp','none')
%%
ii = find(NIR_spec.Shuttered_0(1:250)==0);
figure; plot(NIR_spec.Temp2(ii), mean(NIR_spec.spec(ii,:),2),'o')
title('Sum of dark counts vs Temp')
%%
ii = find(VIS_spec.Shuttered_0(1:250)==0);
figure; plot(VIS_spec.Temp2(ii), mean(VIS_spec.spec(ii,:),2),'o')
title('Sum of dark counts vs Temp')

%%
return
     