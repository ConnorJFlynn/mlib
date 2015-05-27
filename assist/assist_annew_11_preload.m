function assist = assist_annew_11(pname)% ASSIST annew
% Apply processing step by step, confirming most recent LR Tech processing
%
% Review derived products
% Fine details to address:
% Apply NLC
% Refine effective wavenumber for chA and chB
% Cavity effect on emissivity
% Back-reflected radiance
% FFOV effects on line shape

% % Sept 28, 2011
% ASSIST corrections:
% 1. determination of ZPD
% 2. Flip shift, etc.
% 3. Wavenumber definition MUST be based on ZPD being centered within a cell
% 4. NLC
% 5. FFOV
% 6. non-unity emit
% 7. self-emit
% 8. derived products
% 9. LBLRTM: find effective laser WL to reduce skew in difference plots
% 10. LBLRTM: adjust FFOV to reduce residuals near sharp lines
% 11. Repeat/validate all derived products

%%

% emis  = loadinto(['C:\case_studies\assist\compares\LRT_BB_Emiss_FullRes.mat']);
% emis = repack_edgar(emis);
% while ~exist('pname','var')||~exist(pname, 'dir')
%    [pname] = getdir([],'assist');
% end
% raw_files = dir([pname, '*_ann_*.csv']);
% N = length(raw_files);
% n = 1;
% while n<=N-2
% [~,fstem,ext] = fileparts(raw_files(n).name);
% [tok,metsf] = strtok(fliplr(fstem),'_');[tok,metsf] = strtok(metsf,'_');
% dstem{1} = fliplr(metsf);
% [~,fstem,ext] = fileparts(raw_files(n+1).name);
% [tok,metsf] = strtok(fliplr(fstem),'_');[tok,metsf] = strtok(metsf,'_');
% dstem{2} = fliplr(metsf);
% [~,fstem,ext] = fileparts(raw_files(n+2).name);
% [tok,metsf] = strtok(fliplr(fstem),'_');[tok,metsf] = strtok(metsf,'_');
% dstem{3} = fliplr(metsf);
% disp([num2str(N-n), ' files to be read...'])
% if (~exist([pname, dstem{1},'ann_HC.csv'],'file')&&~exist([pname, dstem{1},'chA_HC.mat'],'file')&&~exist([pname, dstem{1},'chB_HC.mat'],'file')&&...
% ~exist([pname, dstem{2},'ann_SCENE.csv'],'file')&&~exist([pname, dstem{2},'chA_SCENE.mat'],'file')&&~exist([pname, dstem{2},'chB_SCENE.mat'],'file')&&...
% ~exist([pname, dstem{3},'ann_CH.csv'],'file')&&~exist([pname, dstem{3},'chA_CH.mat'],'file')&&~exist([pname, dstem{3},'chB_CH.mat'],'file'))||...
% (~exist([pname, dstem{1},'ann_CH.csv'],'file')&&~exist([pname, dstem{1},'chA_CH.mat'],'file')&&~exist([pname, dstem{1},'chB_CH.mat'],'file')&&...
% ~exist([pname, dstem{2},'ann_SCENE.csv'],'file')&&~exist([pname, dstem{2},'chA_SCENE.mat'],'file')&&~exist([pname, dstem{2},'chB_SCENE.mat'],'file')&&...
% ~exist([pname, dstem{3},'ann_HC.csv'],'file')&&~exist([pname, dstem{3},'chA_HC.mat'],'file')&&~exist([pname, dstem{3},'chB_HC.mat'],'file'))
%     n = n + 1;
%     disp(['Not a cal sequence, checking next triplet.']);
% else
% 
%     if exist([pname, dstem{1},'ann_HC.csv'],'file')
%         disp(['HC _ Scene _ CH calibration sequence']);
%         disp([dstem{1},'*_HC.*']);
%         disp([dstem{2},'*_SCENE.*']);
%         disp([dstem{3},'*_CH.*']);
%     else
%         disp(['CH _ Scene _ HC calibration sequence']);
%         disp([dstem{1},'*_CH.*']);
%         disp([dstem{2},'*_SCENE.*']);
%         disp([dstem{3},'*_HC.*']);        
%     end
%     disp([' '])
%       % Calibrate this sequence...
%       seq = load_cal_sequence(pname, dstem);
%       seq.emis = emis;
%       seq = proc_cal_sequence(seq);
%       seq = cut_seq(seq);
%       if exist('assist','var')
% %           assist.degraded = cat_ntimes(assist.degraded, seq.degraded, assist.down.time, seq.down.time);
% %           assist.down = cat_ntimes(assist.down, seq.down);
%           assist = cat_ntimes(assist,seq);
%       else
%           assist = seq;
%           clear seq
%       end
%   n  = n + 2;
% end    
% 
% 
% end

% save([pname, filesep,'assist_degraded.mat'],'-struct','assist');
assist = load(getfullname_('*.mat','assist_compare'));
chA = assist.chA.mrad.x>550 & assist.chA.mrad.x<1830;
chB = assist.chB.mrad.x>1800&assist.chB.mrad.x<3200;
sky = assist.isSky;

aeri = ancload(getfullname_('*sgpaerisummaryC1*.cdf','aeri'));
xl = aeri.time>assist.time(1)&aeri.time<assist.time(end);
aericha = ancload(getfullname_('*sgpaeri*.cdf','aeri'));
aericha = ancsift(aericha, aericha.dims.time, xl);
%%
figure; plot(aericha.vars.wnum.data, mean(aericha.vars.mean_rad.data,2),'k-',(1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-'); 
title(['AERI and ASSIST sky radiances: ',datestr(aericha.time(1),'mmm dd yyyy')]);
legend('AERI','ASSIST')
%%
chA_lbl_fname = getfullname_('*lbl*.csv','eli_lbl');
fid1 = fopen(chA_lbl_fname);
chA_lbl = textscan(fid1,'%f %f %*[^\n]','delimiter',',','headerlines',1);
fclose(fid1);
lbl.chA.x = chA_lbl{1};
lbl.chA.rad = chA_lbl{2};
% units: (W/(cm^2-sr-cm^-1)
% ASSIST units: mW/(m^2 sr cm^-1)
%%
figure; plot(lbl.chA.x, 1e7.*lbl.chA.rad,'b-', assist.chA.mrad.x(chA), assist.chA.mrad.y(sky,chA),'r-'); legend('lbl','assist');
!! We're right here, getting ready to compute lag to maximize correlation between ASSIST and LBL
m = menu('zoom in to select a region to fit over for ch A then select OK','OK')
xl = xlim;
lbl_x = lbl.chA.x>= xl(1) & lbl.chA.x<xl(2);
assist_x =assist.chA.mrad.x>xl(1) & assist.chA.mrad.x< xl(2);
%%
xrange = [min([min(lbl.chA.x(lbl_x)),min(assist.chA.mrad.x(assist_x))]),...
   max([max(lbl.chA.x(lbl_x)),max(assist.chA.mrad.x(assist_x))])];
%%
xrange = [xrange(1):0.1*(diff(lbl.chA.x(1:2))):xrange(2)];
lbl_in = interp1(lbl.chA.x,lbl.chA.y,xrange,'linear');
assist_in = interp1(assist.chA.mrad.x,real(assist.chA.mrad.y(assist.down.Sky_ii(bina(1)),:))',xrange,'linear');
figure; plot(xrange, lbl_in,'.r-',xrange,assist_in,'.k-');
%%
[R,lags] = xcorr(aeri_in',assist_in',100);
figure; plot(lags, R,'.r-');
wn_offset = lags(find(R==max(R))).*diff(xrange(1:2));
title(['xcorr max for lag=',num2str(lags(R==max(R))), ' gives offset of ',num2str(wn_offset), ' 1/cm'])
%%

figure; plot(aeri.vars.wnumsum11.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh1.data(:,xl),2),'b-',...
    aeri.vars.wnumsum12.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh2.data(:,xl),2),'k-'); 
title('AERI degraded radiances')
%%

figure;lines = plot((1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-',...
    (2259.34./2259.63).*assist.chB.mrad.x(chB), mean(assist.chB.mrad.y(sky,chB)),'b-');
%%
figure;lines = plot((1329.76./1329.93).*assist.chA.mrad.x(chA), mean(assist.chA.T_bt(sky,chA)),'r-',...
    (2259.34./2259.63).*assist.chB.mrad.x(chB), mean(assist.chB.T_bt(sky,chB)),'b-');
%%
figure; plot(aeri.vars.wnumsum11.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh1.data(:,xl),2),'b-',...
    aeri.vars.wnumsum12.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh2.data(:,xl),2),'k-'); 
title('AERI degraded radiances')
%%
figure; plot(aeri.vars.wnumsum13.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh1.data(:,xl),2),'b-',...
    aeri.vars.wnumsum14.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh2.data(:,xl),2),'k-'); 
title('AERI degraded brightness temperatures')

%%
figure;lines = plot(assist.chA.mrad.x(chA), mean(assist.chA.mrad.y(sky,chA)),'r-',aeri.vars.wnumsum11.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh1.data(:,xl),2),'b-');
legend('ASSIST','AERI')
%%
figure;lines = plot(assist.chB.mrad.x(chB), mean(assist.chB.mrad.y(sky,chB)),'g-',aeri.vars.wnumsum12.data, mean(aeri.vars.SkyRadianceSpectralAveragesCh2.data(:,xl),2),'k-');
legend('ASSIST','AERI')
%%
figure;lines = plot(assist.chA.mrad.x(chA), mean(assist.chA.T_bt(sky,chA)),'r-',aeri.vars.wnumsum13.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh1.data(:,xl),2),'b-');
legend('ASSIST','AERI')
title('Brightness temperatures')
%%
figure;lines = plot(assist.chB.mrad.x(chB), mean(assist.chB.T_bt(sky,chB)),'g-',aeri.vars.wnumsum14.data, mean(aeri.vars.SkyBrightnessTempSpectralAveragesCh2.data(:,xl),2),'k-');
legend('ASSIST','AERI')
title('brightess temperatures')
%%
% assist.chA.spc.y = assist.chA.spc__.y;
% assist.chB.spc.y = assist.chB.spc__.y;
% 
% figure; plot(assist.chA.cxs.x, [mean(assist.chA.spc.y(assist.logi.A,:));mean(assist.chA.spc_.y(assist.logi.A,:));...
%     mean(assist.chA.spc__.y(assist.logi.A,:));],'-');
% 
% assist.chA.mrad.y = assist.chA.spc.y;
% assist.chB.mrad.y = assist.chB.spc.y;

% in = find(assist.logi.Sky_F);
% [Cnu_,c2 ,c4] = ApplyFFOVCorr(assist.chA.cxs.x, assist.chA.spc.y(in,:),0.0225);

%%
% [rad,wnp,deltaC1,deltaC2] = ffovcmr(nu,Cm,fovHalfAngle,flagFFOVerr,XMAX,WNB); 
% 
% figure; 
% sx(1) = subplot(2,1,1);
% plot(assist.chA.cxs.x, mean(assist.chA.spc.y(assist.logi.Sky_F,:)),'-',assist.chA.cxs.x, mean(assist.chA.mrad.y(assist.logi.Sky_F,:)),'-')
% sx(2) = subplot(2,1,2);
% plot(assist.chA.cxs.x, mean(assist.chA.spc.y(assist.logi.Sky_F,:))-mean(assist.chA.mrad.y(assist.logi.Sky_F,:)),'-')
% linkaxes(sx,'x');
% zoom('on')
%%


% downsample to N mono-directional scans
N = 6; % downsample over 6 
%
[rows,cols]= size(assist.time);
retime = zeros([2.*N.*rows,cols./(2.*N)]);
retime(:) = assist.time;
%
   % retime = 
assist.down.time = retime(1,:);
assist.down.isSky = downsample(assist.logi.Sky,2.*N)>0;
assist.down.isHBB = downsample(assist.logi.H,2.*N)>0;
assist.down.isABB = downsample(assist.logi.A,2.*N)>0;

assist.down.Sky_ii = find(assist.down.isSky);
assist.down.HBB_ii = find(assist.down.isHBB);
assist.down.ABB_ii = find(assist.down.isABB);

assist.down.chA.mrad.x = assist.chA.cxs.x;
assist.down.chB.mrad.x = assist.chB.cxs.x;
%Forward
% Ch A
assist.down.chA.ifg.F = downsample(assist.chA.y(assist.logi.F,:),N);
assist.down.chA.cxs.F = downsample(assist.chA.cxs.y(assist.logi.F,:),N);
assist.down.chA.mrad.F = downsample(assist.chA.mrad.y(assist.logi.F,:),N);
assist.down.chA.var.F = downvariance(assist.chA.mrad.y(assist.logi.F,:),N);
% Ch B
assist.down.chB.ifg.F = downsample(assist.chB.y(assist.logi.F,:),N);
assist.down.chB.cxs.F = downsample(assist.chB.cxs.y(assist.logi.F,:),N);
assist.down.chB.mrad.F = downsample(assist.chB.mrad.y(assist.logi.F,:),N);
assist.down.chB.var.F = downvariance(assist.chB.mrad.y(assist.logi.F,:),N);

% Reverse
% Ch A
assist.down.chA.ifg.R = downsample(assist.chA.y(assist.logi.R,:),N);
assist.down.chA.cxs.R = downsample(assist.chA.cxs.y(assist.logi.R,:),N);
assist.down.chA.mrad.R = downsample(assist.chA.mrad.y(assist.logi.R,:),N);
assist.down.chA.var.R = downvariance(assist.chA.mrad.y(assist.logi.R,:),N);
% Ch B
assist.down.chB.ifg.R = downsample(assist.chB.y(assist.logi.R,:),N);
assist.down.chB.cxs.R = downsample(assist.chB.cxs.y(assist.logi.R,:),N);
assist.down.chB.mrad.R = downsample(assist.chB.mrad.y(assist.logi.R,:),N);
assist.down.chB.var.R = downvariance(assist.chB.mrad.y(assist.logi.R,:),N);

% Combine F and R
assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
assist.down.chA.var.y = (assist.down.chA.var.F  + assist.down.chA.var.R);
assist.down.chA.T_bt = BrightnessTemperature(assist.chA.cxs.x, real(assist.down.chA.mrad.y));

assist.down.chB.mrad.y = (assist.down.chB.mrad.F + assist.down.chB.mrad.R)./2;
assist.down.chB.var.y = (assist.down.chB.var.F  + assist.down.chB.var.R);
assist.down.chB.T_bt = BrightnessTemperature(assist.chB.cxs.x, real(assist.down.chB.mrad.y));
%%
assist.degraded.chA.NEN1.F = downsample(sqrt(assist.down.chA.var.F),50,2).*(sqrt(15./120));
assist.degraded.chB.NEN1.F = downsample(sqrt(assist.down.chB.var.F),50,2).*(sqrt(15./120));
%% 

assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);
assist.degraded.chA.Resp_F = downsample(assist.chA.cal_F.Resp,50,2);
assist.degraded.chA.Offset_ru_F = downsample(assist.chA.cal_F.Offset_ru,50,2);
assist.degraded.chA.mrad.R = downsample(assist.down.chA.mrad.R,50,2);
assist.degraded.chA.Resp_R = downsample(assist.chA.cal_R.Resp,50,2);
assist.degraded.chA.Offset_ru_R = downsample(assist.chA.cal_R.Offset_ru,50,2);
assist.degraded.chA.mrad.y = downsample(assist.down.chA.mrad.y,50,2);
assist.degraded.chA.T_bt = BrightnessTemperature(assist.degraded.chA.mrad.x, ...
   real(assist.degraded.chA.mrad.y));

assist.degraded.chB.mrad.x = downsample(assist.chB.cxs.x,50);
assist.degraded.chB.mrad.F = downsample(assist.down.chB.mrad.F,50,2);
assist.degraded.chB.Resp_F = downsample(assist.chB.cal_F.Resp,50,2);
assist.degraded.chB.Offset_ru_F = downsample(assist.chB.cal_F.Offset_ru,50,2);
assist.degraded.chB.mrad.R = downsample(assist.down.chB.mrad.R,50,2);
assist.degraded.chB.Resp_R = downsample(assist.chB.cal_R.Resp,50,2);
assist.degraded.chB.Offset_ru_R = downsample(assist.chB.cal_R.Offset_ru,50,2);
assist.degraded.chB.mrad.y = downsample(assist.down.chB.mrad.y,50,2);
assist.degraded.chB.T_bt = BrightnessTemperature(assist.degraded.chB.mrad.x, ...
   real(assist.degraded.chB.mrad.y ));
%%
NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chA.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.R(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.R(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chA.Resp_R);


NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chB.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.R(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.R(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chB.Resp_R);


assist.degraded.chA.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.F(3:8,:))),50,2))./sqrt(2);
assist.degraded.chB.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.F(3:8,:))),50,2))./sqrt(2);
assist.degraded.chA.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.R(3:8,:))),50,2))./sqrt(2);
assist.degraded.chB.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.R(3:8,:))),50,2))./sqrt(2);

%%
IRT = irt_rel_resp;
assist.IRT_resp = interp1(IRT.wn, IRT.rel_resp_wn,assist.chA.cxs.x,'cubic');
assist.IRT_resp(assist.chA.cxs.x<min(IRT.wn)|assist.chA.cxs.x>max(IRT.wn))=0;
assist.IRT_resp = assist.IRT_resp./trapz(assist.chA.cxs.x, assist.IRT_resp);
assist.IRT_cwn = IRT.cwn;
% figure; plot(IRT.wn, IRT.rel_resp_wn, 'ko', assist.chA.cxs.x, assist.IRT_resp, '.');
assist.IRT_rad = trapz(assist.chA.cxs.x, (real(assist.down.chA.mrad.y.*...
   (ones([size(assist.down.chA.mrad.y,1),1])*assist.IRT_resp)))');
assist.IRT_K = BrightnessTemperature(assist.IRT_cwn, assist.IRT_rad);
assist.IRT_C = assist.IRT_K-273.17;


% Assess difference between Andre' and my derived products
[pname_A] = getdir([],'assist_proc','Select location of Andre''s results');
  %%
  % So, first compare the spectral quantities
% %%
% % 20110324_051618_chA_HBBNen1.coad.mrad.pro.degraded.truncated.mat
% infileA = getfullname_([pname_A,'20110324_051618_chA_Nen.coad.mrad.pro.degraded.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
% matA = repack_edgar(infileA); 
% [mat_pname, mat_fname, ext] = fileparts(infileA);
% [fname_a,fname_b]=strtok(mat_fname,'.');
% infileB = strrep(infileA,'_chA_','_chB_');
% matB = repack_edgar(infileB); 
% %
% %%
% posA = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
% posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
% %
% 
% figure; 
% plot(matA.x,matA.y(1,:), 'k.',...
%    assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN1.F(assist.down.isSky,posA),'-ro',...
%    matA.x,matA.y, 'k.',...
%    assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN1.F(assist.down.isSky,posB),'bo',...
%    matB.x,matB.y , 'g.')
% legend('Andre','Flynn')
% xlim([550,3000]);
% title({fname_a;[fname_b(2:end) ext]},'interp','none');
% xlabel('wavenumber [1/cm]');
% ylabel('radiance [RU]');
%%

infileA = getfullname_([pname_A,'*_chA_SKY.coad.mrad.coad.merged.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 

posA = assist.down.chA.mrad.x>=min(matA.x)&assist.down.chA.mrad.x<=max(matA.x);
posB = assist.down.chB.mrad.x>=min(matB.x)&assist.down.chB.mrad.x<=max(matB.x);

posAd = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
posBd = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);

%%
[meinaA, ainmeA] = nearest(assist.down.chA.mrad.x,matA.x);
figure; plot(assist.down.chA.mrad.x(meinaA), min(assist.down.chA.mrad.y(3:8,meinaA)),'k-'); grid('on');zoom('on');
title(['NLC A2 = ',sprintf('%2.4g',assist.chA.nlc.a2)]);
axis([750,1000,-.5,3]);
xl = xlim;
%%

figure; 
plot(assist.down.chA.mrad.x(meinaA), mean(assist.down.chA.T_bt(3:8,meinaA)),'b-'); grid('on');zoom('on');
title(['NLC A2 = ',sprintf('%2.4g',assist.chA.nlc.a2)]);
ylabel('brightness T');
xlim(xl);
%%
figure; 
sb3(1) = subplot(2,1,1);
plot(assist.down.chA.mrad.x(meinaA), assist.down.chA.mrad.y(3,meinaA),'k-', matA.x(ainmeA), matA.y(1,ainmeA),'r-');
legend('mine','Andre''s')
title('ch A comparisons');
grid('on');
sb3(2) = subplot(2,1,2);
plot(assist.down.chA.mrad.x(meinaA), (assist.down.chA.mrad.y(3,meinaA) - matA.y(1,ainmeA)),'r-');
legend('mine - Andre''s')
grid('on');
linkaxes(sb3,'x');
title(['NLC A2 = ',sprintf('%2.4g',assist.chA.nlc.a2)]);
%%

[meinaB, ainmeB] = nearest(assist.down.chB.mrad.x,matB.x);

figure; 
sb4(1) = subplot(2,1,1);
plot(assist.down.chB.mrad.x(meinaB), assist.down.chB.mrad.y(3,meinaB),'k-', matB.x(ainmeB), matB.y(1,ainmeB),'r-');
legend('mine','Andre''s');
title('ch B comparisons')
sb4(2) = subplot(2,1,2);
plot(assist.down.chB.mrad.x(meinaB), (assist.down.chB.mrad.y(3,meinaB) - matB.y(1,ainmeB)),'r-');
legend('mine - Andre''s')
linkaxes(sb4,'x');



%%

infileA = getfullname_([pname_A,'20110324_051618_chA_HBBNen2.coad.mrad.pro.degraded.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 


posA = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%

figure; 
plot(assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN2.F(posA), 'r.',...
   assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN1.F(assist.down.isHBB,posA),'-ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN2.F(posB),'b.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN1.F(assist.down.isHBB,posB),'bo',...
   matB.x,matB.y , 'g.')
legend('NEN2','NEN1')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
%%
%%

infileA = getfullname_([pname_A,'20110324_051618_chA_Nen.coad.mrad.pro.degraded.truncated.mat'],'edgar_mat','Select ch A truncated mrad')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 


posA = assist.degraded.chA.mrad.x>=500&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%

figure; 
plot(assist.degraded.chA.mrad.x(posA), assist.degraded.chA.sky_NEN.F(posA), 'r.',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.sky_NEN.F(posB),'b.',...
   matB.x,matB.y , 'g.')
legend('NEN2','NEN1')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
%%
figure; 
plot(matB.x,matB.y , '-')
legend('1','2','3','4','5','6')
xlim([1700,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
%%
p = 1;
png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
while exist(png_file,'file')
   p = p +1;
   png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
end
saveas(gcf,png_file);

%%
  
  % Then, define the different sub-bands and compute related quantities
  % Then, load each mat file and check content.
proc_pname = ['C:\case_studies\assist\data\post_Feb_repair\20110222_1157\one_sequence\processed'];
infileA = getfullname_('*_chA_BTemp_SKY*.mat','edgar_mat','Select ch A Brightness temperature')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);
%
posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=2000;
posB = assist.degraded.chB.mrad.x>=1700&assist.degraded.chB.mrad.x<=max(matB.x);

figure; 
plot(matA.x,matA.y(1,:)-273.15, 'k.',...
   assist.degraded.chA.mrad.x(posA), assist.degraded.chA.T_bt(assist.down.isSky,posA)-273.15,'ro',...
   matA.x,matA.y -273.15, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.T_bt(assist.down.isSky,posB)-273.15,'bo',...
   matB.x,matB.y -273.15, 'g.')
legend('Andre','Flynn')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('brightness temperature [C]');
%%
p = 1;
png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
while exist(png_file,'file')
   p = p +1;
   png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
end
saveas(gcf,png_file);
%%
infileA = getfullname_('*_chA_HBBNen1.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN1')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);

figure; 
plot(matA.x,matA.y(1,:), 'k.',...
   assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN1.F(assist.down.isSky,posA),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN1.F(assist.down.isSky,posB),'ro',...
   matB.x,matB.y , 'k.')
legend('Andre','Flynn')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('noise-equivalent radiance [RU]');
%%
p = 1;
png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
while exist(png_file,'file')
   p = p +1;
   png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
end
saveas(gcf,png_file);
%%
infileA = getfullname_('*_chA_HBBNen2.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN2')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);

figure; 
plot(matA.x,matA.y(1,:), 'k.',...
   assist.degraded.chA.mrad.x(posA), assist.degraded.chA.NEN2(posA),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.NEN2(posB),'ro',...
   matB.x,matB.y , 'k.')
legend('Andre','Flynn')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('noise-equivalent radiance [RU]');
%%
p = 1;
png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
while exist(png_file,'file')
   p = p +1;
   png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
end
saveas(gcf,png_file);
%%
infileA = getfullname_('*_chA_SKY.coad.mrad.coad.merged.truncated.degraded.mat','edgar_mat','Select ch A degraded mrad')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);

figure; 
plot(matA.x,matA.y(1,:), 'k.',...
   assist.degraded.chA.mrad.x(posA), assist.degraded.chA.mrad.F(assist.down.isSky,posA),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.mrad.F(assist.down.isSky,posB),'ro',...
   matB.x,matB.y , 'k.')
legend('Andre','Flynn')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
%%
p = 1;
png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
while exist(png_file,'file')
   p = p +1;
   png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
end
saveas(gcf,png_file);

%%
% Load real and imaginary responsivity for Ch A and Ch B
infileA = getfullname_('*_chA_SKY_RESP_REAL_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A real responsivity')
Re_matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
Re_matB = repack_edgar(infileB); 
infileA = getfullname_('*_chA_SKY_RESP_IMA_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A imag responsivity')
Im_matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
Im_matB = repack_edgar(infileB); 

infileA = getfullname_('*_chA_SKY_OFF_REAL_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A real offset')
Re_offA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
Re_offB = repack_edgar(infileB); 
infileA = getfullname_('*_chA_SKY_OFF_IMA_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A imag offset')
Im_offA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
Im_offB = repack_edgar(infileB); 
%
posA = assist.degraded.chA.mrad.x>=min(Re_matA.x)&assist.degraded.chA.mrad.x<=max(Re_matA.x);
posB = assist.degraded.chB.mrad.x>=min(Re_matB.x)&assist.degraded.chB.mrad.x<=max(Re_matB.x);
%%
figure;
subplot(2,1,1);
plot(Re_matA.x,Re_matA.y(1:2:end,:), 'k.',...
   Im_matA.x,Im_matA.y(1:2:end,:), 'r.',...
      assist.degraded.chA.mrad.x(posA), real(assist.degraded.chA.Resp_F(posA)),'k-',...
      assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Resp_F(posA)),'r-',...
   Re_matB.x,Re_matB.y(1:2:end,:), 'k.',...
   Im_matB.x,Im_matB.y(1:2:end,:), 'r.',...
      assist.degraded.chB.mrad.x(posB), real(assist.degraded.chB.Resp_F(posB)),'k-',...
      assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Resp_F(posB)),'r-')
legend('Re','Im')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
subplot(2,1,2);

plot(Re_offA.x,Re_offA.y(1,:), 'k.',...
   Im_offA.x,Im_offA.y(1,:), 'r.',...
   assist.degraded.chA.mrad.x(posA), real(assist.degraded.chA.Offset_ru_F(posA)),'k-',...
      assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Offset_ru_F(posA)),'r-',...
   Re_offB.x,Re_offB.y(1,:), 'k.',...
   Im_offB.x,Im_offB.y(1,:), 'r.',...
   assist.degraded.chB.mrad.x(posB), real(assist.degraded.chB.Offset_ru_F(posB)),'k-',...
   assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Offset_ru_F(posB)),'r-')
legend('Edgar Re','Edgar Im', 'Flynn Re','Flynn Im')
xlim([550,3000]);
title('Calibration offsets','interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');

%%
figure;
subplot(2,1,1);
plot(Re_matA.x,Re_matA.y(1,:), 'k.',...
   Im_matA.x,Im_matA.y(1,:), 'r.',...
   Re_matB.x,Re_matB.y(1,:), 'k.',...
   Im_matB.x,Im_matB.y(1,:), 'r.')
legend('Re','Im')
xlim([550,3000]);
title('forward scan responsivity and offsets','interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
subplot(2,1,2);

plot(Re_offA.x,-Re_offA.y(1,:)./(1000.*Re_matA.y(1,:)), 'k.',...
   Im_offA.x,-Im_offA.y(1,:)./(1000.*Im_matA.y(1,:)), 'r.',...
      assist.degraded.chA.mrad.x(posA), -real(assist.degraded.chA.Offset_ru_F(posA)),'k-',...
         assist.degraded.chA.mrad.x(posA), -imag(assist.degraded.chA.Offset_ru_F(posA)),'r-',...
   Re_offB.x,-Re_offB.y(1,:)./(1000.*Re_matB.y(1,:)), 'k.',...
   Im_offB.x,-Im_offB.y(1,:)./(1000.*Im_matB.y(1,:)), 'r.',...
   assist.degraded.chB.mrad.x(posB), -real(assist.degraded.chB.Offset_ru_F(posB)),'k-',...
   assist.degraded.chB.mrad.x(posB), -imag(assist.degraded.chB.Offset_ru_F(posB)),'r-')
legend('Edgar Re','Edgar Im', 'Flynn Re','Flynn Im')
xlim([550,3000]);
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');

return



% 
% 
% [zpd_loc,zpd_mag] = find_zpd_edgar(RawIgm);
% %    [tmp,zpd_loc] = max(abs(RawIgm.y - mean(RawIgm.y)));
%     zpd_loc = zpd_loc - length(RawIgm.x)./2-1;
%     zpd_loc = mode(zpd_loc);
% 
% RawSpc.y = fft(zpd_circshift(RawIgm.x,RawIgm.y,-zpd_loc),[],2);
% RawSpc.y = fftshift(RawSpc.y,2);
return

function lab = legalize(lab)
lab = strrep(lab,' ','');
lab = strrep(lab,'-','');
lab = strrep(lab,'.','');
lab = strrep(lab,'(°)','');
return

% function mat = repack_edgar(edgar)
% if ~exist('edgar','var')
%    edgar =loadinto(getfullname_('*.mat','edgar_mat','Select an Edgar mat file.'));
% end
% if ~isstruct(edgar)&&exist(edgar,'file')
%    edgar =loadinto(edgar);
% end
% if isfield(edgar,'mainHeaderBlock')
%     V = double([edgar.mainHeaderBlock.date.year,edgar.mainHeaderBlock.date.month,...
%         edgar.mainHeaderBlock.date.day,edgar.mainHeaderBlock.date.hours,...
%         edgar.mainHeaderBlock.date.minutes,edgar.mainHeaderBlock.date.seconds]);
%     nbPoints = edgar.mainHeaderBlock.nbPoints;
%     % xStep = (edgar.mainHeaderBlock.lastX-edgar.mainHeaderBlock.firstX)./(nbPoints-1);
%     mat.x = linspace(edgar.mainHeaderBlock.firstX, (edgar.mainHeaderBlock.lastX), double(nbPoints));
%     if isfield(edgar.mainHeaderBlock,'laserFrequency')
%         mat.laserFrequency = edgar.mainHeaderBlock.laserFrequency;
%     end
%     
%     base_time = datenum(V);
% end
% if ~isfield(edgar,'subfiles')&isfield(edgar,'subfileData')
%     edgar.subfiles{1}.subfileHeader = edgar.subfileHeader;
%     edgar.subfiles{1}.subfileData = edgar.subfileData;
%     edgar = rmfield(edgar, 'subfileHeader');
%     edgar = rmfield(edgar, 'subfileData');
% end
% subs = length(edgar.subfiles);
% for s = subs:-1:1
% if exist('base_time','var')
% mat.time(s) = base_time +  double(edgar.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
% end
% mat.flags(s) = edgar.subfiles{s}.subfileHeader.subFlags;
% if isfield(edgar.subfiles{s}.subfileHeader,'nbCoaddedScans')
%    mat.coads(s) = edgar.subfiles{s}.subfileHeader.nbCoaddedScans;
% end
% mat.subIndex(s) = edgar.subfiles{s}.subfileHeader.subIndex;
% mat.scanNb(s) = edgar.subfiles{s}.subfileHeader.scanNb;
% mat.HBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subHBBRawTemp;
% mat.CBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subCBBRawTemp;
% if isfield(edgar.subfiles{s}.subfileHeader,'zpdLocation')
% mat.zpdLocation(s) = edgar.subfiles{s}.subfileHeader.zpdLocation;
% end
% if isfield(edgar.subfiles{s}.subfileHeader,'zpdValue')
% mat.zpdValue(s) = edgar.subfiles{s}.subfileHeader.zpdValue;
% end
% mat.y(s,:) = edgar.subfiles{s}.subfileData;
% end
% mat.flags = uint8(mat.flags);
% return

function mat1 = stitch_mats(mat1, mat2)
time_len = length(mat1.time);
[~, ii] = sort([mat1.scanNb,mat2.scanNb]);
mat_fields = (fieldnames(mat1));

for f = length(mat_fields):-1:1
   jj = find(size(mat1.(mat_fields{f}))==time_len);
   if jj==1
      X = [mat1.(mat_fields{f});mat2.(mat_fields{f})];
      mat1.(mat_fields{f}) = X(ii,:);
   elseif jj==2
      X = [mat1.(mat_fields{f}),mat2.(mat_fields{f})];
      mat1.(mat_fields{f}) = X(ii);
   end
end

return

function assist = flip_reverse_scans(assist)
% I flip the reverse scans to put both scans on the same physical frame.
assist.chA.y(assist.logi.R,:) = fliplr(assist.chA.y(assist.logi.R,:));
if isfield(assist,'chB');
  assist.chB.y(assist.logi.R,:) = fliplr(assist.chB.y(assist.logi.R,:));
end
  
return

function assist = select_scan_dir(assist,strip);
fields = fieldnames(assist);
for f = length(fields):-1:1
   scan_dim = find(size(assist.(fields{f}))==length(strip),1,'first')-1;
   if ~isempty(scan_dim)
      tmp = shiftdim(assist.(fields{f}),scan_dim);
      assist.(fields{f}) = shiftdim(tmp(strip,:),-scan_dim);
   elseif isstruct(assist.(fields{f}))
      assist.(fields{f}) = select_scan_dir(assist.(fields{f}),strip);
   end
end

return

function assist = rad_cal_def_M(assist, emis, T_ref)
% Just looking at chA right now to assess calibration from pre-merged data 
% simplest, use mean temperatures and BB spectra over entire measurement
% Determines seperate calibrations from F, R, and premerged data set.

T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));
if ~exist('T_ref','var')
    T_ref =273.15+T_cold_F ;
end

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.H&assist.logi.F,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.H&assist.logi.R,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.A&assist.logi.F,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y(assist.logi.A&assist.logi.R,:);
ABB_R = CoaddData(in_spec);

if ~exist('emis','var')
    assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
    assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
else
%     Tr = 28.65;
    %%
    [assist.chA.cal_F, assist.chA.cal_F_,assist.chA.cal_F__] = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_ref, emis);
   
    %%
    
    [assist.chA.cal_R, assist.chA.cal_R_, assist.chA.cal_R__] = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_ref, emis);
end

%%
% pos = in_spec.x>450&in_spec.x<2000;
% figure; 
% sb3(1)= subplot(2,1,1); 
% plot(in_spec.x(pos), real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)]), '-')
% title('real(Resp)')
% legend('F','R', 'M');
% sb3(2)= subplot(2,1,2); 
% plot(in_spec.x(pos), real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)])...
%    - ones([3,1])*mean(real([assist.chA.cal_F.Resp(pos);assist.chA.cal_R.Resp(pos);assist.chA.cal_M.Resp(pos)]),1), '-')
% title('real(Resp)-mean(Resp)')
% legend('F','R', 'M');
% linkaxes(sb3,'x');
%%
% And now we do chB

in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.H&assist.logi.F,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.H&assist.logi.R,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.A&assist.logi.F,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chB.cxs.x;
in_spec.y = assist.chB.cxs.y(assist.logi.A&assist.logi.R,:);
ABB_R = CoaddData(in_spec);

if ~exist('emis','var')
    assist.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
    assist.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
else
%     Tr = 28.65;
    %%
    [assist.chB.cal_F, assist.chB.cal_F_,assist.chB.cal_F__] = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_ref, emis);
   
    %%
    
    [assist.chB.cal_R, assist.chB.cal_R_, assist.chB.cal_R__] = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_ref, emis);
end

return

function assist = load_cal_sequence(pname, dstem)
for ds = 1:length(dstem)
    ann_ls = dir([pname, dstem{ds},'*ann*.csv']);
    chA_ls = dir([pname, dstem{ds},'*chA_*.mat']);
    chB_ls = dir([pname, dstem{ds},'*chB_*.mat']);
    for a = length(ann_ls):-1:1
        fname = ann_ls(a).name;
        [xl_num, xl_txt]= xlsread([pname, fname]);
        xl_len = min([length(xl_txt(2,:)),length(xl_num(2,:))]);
        for n = xl_len:-1:1
            if any(isnumeric(xl_num(:,n)))
                lab = legalize(xl_txt{2,n});
                ann.(lab) = xl_num(:,n);
            end
        end
        if ~exist('assist','var')
            assist.ann = ann;
        else
            [scan_nm, ii] = sort([assist.ann.ScanNumber;ann.ScanNumber]);
            ann_fields = (fieldnames(assist.ann));
            for f = length(ann_fields):-1:1
                X = [assist.ann.(ann_fields{f});ann.(ann_fields{f})];
                assist.ann.(ann_fields{f}) = X(ii);
            end
        end
        
        fname = chA_ls(a).name;
        edgar_mat = loadinto([pname,fname]);
        flynn_mat = repack_edgar(edgar_mat);
        if ~isempty(strfind(fname,'_HC.mat'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true);
        end
        if ~isempty(strfind(fname,'_CH.mat'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
        end
        if ~exist('assist','var')||~isfield(assist,'chA')
            assist.chA = flynn_mat;
        else
            assist.chA = stitch_mats(assist.chA,flynn_mat);
        end
        
        fname = chB_ls(a).name;
        edgar_mat = loadinto([pname,fname]);
        flynn_mat = repack_edgar(edgar_mat);
        if ~isempty(strfind(fname,'_HC.mat'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true);
        end
        if ~isempty(strfind(fname,'_CH.mat'))
            flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
            flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
        end
        if ~isfield(assist,'chB')
            assist.chB = flynn_mat;
        else
            assist.chB = stitch_mats(assist.chB,flynn_mat);
        end
    end % next "a"
end %next "ds"
% for ds = 1:length(dstem)
% % chA_ls = dir([pname, dstem{ds},'*chA_*.mat']);
% for chA = length(chA_ls):-1:1
%    fname = chA_ls(chA).name;
%    edgar_mat = loadinto([pname,fname]);
%    flynn_mat = repack_edgar(edgar_mat);
%    if ~isempty(strfind(fname,'_HC.mat'))
%        flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);
%        flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true);
%    end
%    if ~isempty(strfind(fname,'_CH.mat'))
%        flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
%        flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
%    end
%    if ~exist('assist','var')||~isfield(assist,'chA')
%       assist.chA = flynn_mat;
%    else
%       assist.chA = stitch_mats(assist.chA,flynn_mat);
%    end
% end
% end
%
% assist.pname = pname;
% assist.time = assist.chA.time;
%
% for ds = 1:length(dstem)
% chB_ls = dir([pname, dstem{ds},'*chB_*.mat']);
% for chB = length(chB_ls):-1:1
%    fname = chB_ls(chB).name;
%    edgar_mat = loadinto([pname,fname]);
%    flynn_mat = repack_edgar(edgar_mat);
%    if ~isempty(strfind(fname,'_HC.mat'))
%        flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 5,true);
%        flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 6,true);
%    end
%    if ~isempty(strfind(fname,'_CH.mat'))
%        flynn_mat.flags(1:12) = bitset(flynn_mat.flags(1:12), 6,true);
%        flynn_mat.flags(13:end) = bitset(flynn_mat.flags(13:end), 5,true);
%    end
%    if ~isfield(assist,'chB')
%       assist.chB = flynn_mat;
%    else
%       assist.chB = stitch_mats(assist.chB,flynn_mat);
%    end
% end
% end
logi.F = bitget(assist.chA.flags,2)>0;
logi.R = bitget(assist.chA.flags,3)>0;
logi.H = bitget(assist.chA.flags,5)>0;
logi.A = bitget(assist.chA.flags,6)>0;
logi.Sky = ~(logi.H|logi.A);
sky_ii = find(logi.Sky);
logi.HBB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,5);
logi.HBB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,5);
logi.ABB_F = bitget(assist.chA.flags,2)&bitget(assist.chA.flags,6);
logi.ABB_R = bitget(assist.chA.flags,3)&bitget(assist.chA.flags,6);
logi.Sky_F = bitget(assist.chA.flags,2)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));
logi.Sky_R = bitget(assist.chA.flags,3)& ~(bitget(assist.chA.flags,5)|bitget(assist.chA.flags,6));

assist.logi = logi;
assist.time = assist.chA.time;

return

function assist = proc_cal_sequence(assist);
HBB_off = 0;
ABB_off = 0;
assist.HBB_C = HBB_off+double(assist.chA.HBBRawTemp)./500;
assist.ABB_C = ABB_off+double(assist.chA.CBBRawTemp)./500;
% %#Laser frequency used for channel A (MCT)
% A_LASER_FREQUENCY = 1.580098e4
% #Laser frequency used for channel B (InSB)
% B_LASER_FREQUENCY = 1.579990e4
assist.chA.laser_wl = 632.8e-7;    % He-Ne wavelength in cm
assist.chA.laser_wl = 1./1.580098e4;    % from Andre
assist.chB.laser_wl = 1./1.579990e4;    % from Andre
assist.chA.laser_wn = 1./assist.chA.laser_wl; % wavenumber in 1/cm
assist.chB.laser_wn = 1./assist.chB.laser_wl; % wavenumber in 1/cm

% assist = flip_reverse_scans(assist);
dim_n = find(size(assist.chA.y)==length(assist.chA.x));

% ZPD Values:
%%
logi = assist.logi;
[AFmaxv,AFmaxi] = max(abs(mean(assist.chA.y(logi.F&logi.H,:),1)));
[ARmaxv,ARmaxi] = max(abs(mean(assist.chA.y(logi.R&logi.H,:),1)));
[BFmaxv,BFmaxi] = max(abs(mean(assist.chB.y(logi.F&logi.H,:),1)));
[BRmaxv,BRmaxi] =max(abs(mean(assist.chB.y(logi.R&logi.H,:),1)));

chA_zpd_shift_F = AFmaxi-length(assist.chA.x)./2 -1;
chA_zpd_shift_R = ARmaxi-length(assist.chA.x)./2 -1;
chB_zpd_shift_F = BFmaxi-length(assist.chB.x)./2 -1;
chB_zpd_shift_R = BRmaxi-length(assist.chB.x)./2 -1;

maxv = max(abs([AFmaxv, ARmaxv, BFmaxv, BRmaxv])); % Used only to set scale of plot
%%
% figure
% s(1) = subplot(2,2,1);
% plot(assist.chA.x, assist.chA.y(logi.F&logi.H,:),'.-r',[assist.chA.x(AFmaxi),assist.chA.x(AFmaxi)],[-maxv,maxv],'r--');
% title(['ChA (MCT), HBB, Forward, max(abs)=',num2str(chA_zpd_shift_F)]);
% grid('on');
% s(2) = subplot(2,2,3);
% plot(assist.chA.x, assist.chA.y(logi.R&logi.H,:),'.-b',[assist.chA.x(ARmaxi),assist.chA.x(ARmaxi)],[-maxv,maxv],'r--');
% title(['ChA (MCT), HBB, Reverse, max(abs)=',num2str(chA_zpd_shift_R)]);
% grid('on');
% s(3) = subplot(2,2,2);
%
% plot(assist.chB.x, assist.chB.y(logi.F&logi.H,:),'.-g',[assist.chB.x(BFmaxi),assist.chB.x(BFmaxi)],[-maxv,maxv],'r--');
% title(['ChB (InSb), HBB, Forward, max(abs)=',num2str(chB_zpd_shift_F)]);
% grid('on');
% s(4) = subplot(2,2,4);
% plot(assist.chB.x, assist.chB.y(logi.R&logi.H,:),'.-c',[assist.chB.x(BRmaxi),assist.chB.x(BRmaxi)],[-maxv,maxv],'r--');
% title(['ChB (InSb), HBB, Reverse, max(abs)=',num2str(chB_zpd_shift_R)]);
% grid('on');
%
% linkaxes(s,'xy')
%%

assist.chA.y(assist.logi.F,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.F,:), chA_zpd_shift_F);
assist.chA.y(assist.logi.R,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.R,:), chA_zpd_shift_R);
assist.chB.y(assist.logi.F,:) =  sideshift(assist.chB.x, assist.chB.y(assist.logi.F,:), chB_zpd_shift_F);
assist.chB.y(assist.logi.R,:) =  sideshift(assist.chB.x, assist.chB.y(assist.logi.R,:), chB_zpd_shift_R);

assist.chA.y(assist.logi.F,:) = fftshift(assist.chA.y(assist.logi.F,:),dim_n);
assist.chA.y(assist.logi.R,:) = fftshift(assist.chA.y(assist.logi.R,:),dim_n);
assist.chB.y(assist.logi.F,:) = fftshift(assist.chB.y(assist.logi.F,:),dim_n);
assist.chB.y(assist.logi.R,:) = fftshift(assist.chB.y(assist.logi.R,:),dim_n);
%%
[assist.chA.cxs.x,assist.chA.cxs.y] = RawIgm2RawSpc(assist.chA.x,assist.chA.y,assist.chA.laser_wl);
[assist.chB.cxs.x,assist.chB.cxs.y] = RawIgm2RawSpc(assist.chB.x,assist.chB.y,assist.chA.laser_wl);

%%
% [AFmaxv,AFmaxi] = max(abs(mean(assist.chA.y(logi.F&logi.H,:),1)));
% [ARmaxv,ARmaxi] = max(abs(mean(assist.chA.y(logi.R&logi.H,:),1)));
% [BFmaxv,BFmaxi] = max(abs(mean(assist.chB.y(logi.F&logi.H,:),1)));
% [BRmaxv,BRmaxi] =max(abs(mean(assist.chB.y(logi.R&logi.H,:),1)));
% maxv = max(abs([AFmaxv, ARmaxv, BFmaxv, BRmaxv]));
% %
% figure
% s(1) = subplot(2,2,1);
% plot(assist.chA.x, assist.chA.y(logi.F&logi.H,:),'.-r',[assist.chA.x(AFmaxi),assist.chA.x(AFmaxi)],[-maxv,maxv],'r--');
% title(['ChA (MCT), HBB, Forward, max(abs)=',num2str(AFmaxi)]);
% grid('on');
% s(2) = subplot(2,2,3);
% plot(assist.chA.x, assist.chA.y(logi.R&logi.H,:),'.-b',[assist.chA.x(ARmaxi),assist.chA.x(ARmaxi)],[-maxv,maxv],'r--');
% title(['ChA (MCT), HBB, Reverse, max(abs)=',num2str(ARmaxi)]);
% grid('on');
% s(3) = subplot(2,2,2);
%
% plot(assist.chB.x, assist.chB.y(logi.F&logi.H,:),'.-g',[assist.chB.x(BFmaxi),assist.chB.x(BFmaxi)],[-maxv,maxv],'r--');
% title(['ChB (InSb), HBB, Forward, max(abs)=',num2str(BFmaxi)]);
% grid('on');
% s(4) = subplot(2,2,4);
% plot(assist.chB.x, assist.chB.y(logi.R&logi.H,:),'.-c',[assist.chB.x(BRmaxi),assist.chB.x(BRmaxi)],[-maxv,maxv],'r--');
% title(['ChB (InSb), HBB, Reverse, max(abs)=',num2str(BRmaxi)]);
% grid('on');
%
% linkaxes(s,'xy')
%%

% I have confirmed (with the final_end_to_end_comparisons script) that
% these uncalibrated spectra agree with Andre's
% (20110324_051618_chA_CH_HBB.coad.uncal.mat) to within floating point
% error.  So now proceed to apply the NLC, emissivity, and self-reflection
% corrections and FFOV corrections and check the final radiances.
% %%
% figure;
% s(1) = subplot(2,1,1);
% plot(assist.chA.cxs.x,real(assist.chA.cxs.y(assist.logi.H,:)),'k-',assist.chA.cxs.x,imag(assist.chA.cxs.y(assist.logi.H,:)),'b-');
% s(2) = subplot(2,1,2);
% plot(assist.chA.cxs.x,real(assist.chA.cxs.y(assist.logi.A,:)),'k-',assist.chA.cxs.x,imag(assist.chA.cxs.y(assist.logi.A,:)),'b-')



%From Michel pre-MAGIC2
nlc.a2 = 8.0e-08;
nlc.IHLAB = -46690.6549;
nlc.ICLAB = 80012.4172;

assist.chA.nlc.a2 = 0;
assist_noNLC = assist;
[assist.chA.cxs.y,assist.chA.nlc] = NLC_SSEC(assist,nlc);
%
% Temperature to be used for reflected emission.
% 3.5C (276.65k)

% assist = rad_cal_def_M(assist, emis, T_ref)
emis = assist.emis;
assist = rad_cal_def_M(assist, emis, 3.5);

assist_noNLC = rad_cal_def_M(assist_noNLC, emis, 3.5);
assist_noNLC.chA.spc__.y(assist.logi.F,:) = RadiometricCalibration_4(assist_noNLC.chA.cxs.y(assist.logi.F,:), assist_noNLC.chA.cal_F__);
assist_noNLC.chA.spc__.y(assist.logi.R,:) = RadiometricCalibration_4(assist_noNLC.chA.cxs.y(assist.logi.R,:), assist_noNLC.chA.cal_R__);

%
assist.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F);
assist.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R);
assist.chB.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.F,:), assist.chB.cal_F);
assist.chB.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.R,:), assist.chB.cal_R);

assist.chA.spc_.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F_);
assist.chA.spc_.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R_);
assist.chB.spc_.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.F,:), assist.chB.cal_F_);
assist.chB.spc_.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.R,:), assist.chB.cal_R_);

assist.chA.spc__.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F__);
assist.chA.spc__.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R__);
assist.chB.spc__.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.F,:), assist.chB.cal_F__);
assist.chB.spc__.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.R,:), assist.chB.cal_R__);

% assist_0.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist_0.chA.cal_F);
% assist_0.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist_0.chA.cal_R);
%
%%
% figure; plot(assist.chA.cxs.x, [mean(assist.chA.cxs.y(assist.logi.ABB_F,:));mean(assist_noNLC.chA.cxs.y(assist.logi.ABB_F,:))],'-')
%%

% Half-angle FOV to be used for FFOV correction.
% 0.0225; mrad
%
sky_fi = find(assist.logi.Sky_F);
sky_ri = find(assist.logi.Sky_R);
chA = assist.chA.cxs.x>350&assist.chA.cxs.x<1830;
chB = assist.chB.cxs.x>1750&assist.chB.cxs.x<3000;
assist.chA.mrad.y = ApplyFFOVCorr(assist.chA.cxs.x, assist.chA.spc.y,0.0225);
assist.chB.mrad.y = ApplyFFOVCorr(assist.chB.cxs.x, assist.chB.spc.y,0.0225);
%%
% figure(50); sp(1) = subplot(2,1,1);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_fi(1),chA);assist.chA.spc_.y(sky_fi(1),chA);assist.chA.spc__.y(sky_fi(1),chA)]),'-', ...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_fi(1),chB);assist.chB.spc_.y(sky_fi(1),chB);assist.chB.spc__.y(sky_fi(1),chB)]),'-');
% grid('on');
% legend('both','emis','none');
% title('Forward scans');
% sp(2) = subplot(2,1,2);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_ri(1),chA);assist.chA.spc_.y(sky_ri(1),chA);assist.chA.spc__.y(sky_ri(1),chA)]),'-',...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_ri(1),chB);assist.chB.spc_.y(sky_ri(1),chB);assist.chB.spc__.y(sky_ri(1),chB)]),'-');
% grid('on');
% legend('both','emis','none');
% title('Reverse scans');
% linkaxes(sp,'xy');
% if exist('v','var')
%     axis(v);
% end

% figure(51); spp(1) = subplot(2,1,1);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_fi(1),chA);assist.chA.mrad.y(sky_fi(1),chA)]),'-', ...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_fi(1),chB);assist.chB.mrad.y(sky_fi(1),chB)]),'-');
% grid('on');
% legend('both','FFOV');
% title('Forward scans');
% spp(2) = subplot(2,1,2);
% plot(assist.chA.cxs.x(chA), real([assist.chA.spc.y(sky_ri(1),chA);assist.chA.mrad.y(sky_ri(1),chA)]),'-',...
%     assist.chB.cxs.x(chB), real([assist.chB.spc.y(sky_ri(1),chB);assist.chB.mrad.y(sky_ri(1),chB)]),'-');
% grid('on');
% legend('both','FFOV');
% title('Reverse scans');
% linkaxes(spp,'xy');
% if exist('v','var')
%     axis(v);
% end

N = 6; % downsample over 6 
%
[rows,cols]= size(assist.time);
retime = zeros([2.*N.*rows,cols./(2.*N)]);
retime(:) = assist.time;
%
   % retime = 
assist.down.time = retime(1,:);
assist.down.isSky = downsample(assist.logi.Sky,2.*N)>0;
assist.down.isHBB = downsample(assist.logi.H,2.*N)>0;
assist.down.isABB = downsample(assist.logi.A,2.*N)>0;

assist.down.Sky_ii = find(assist.down.isSky);
assist.down.HBB_ii = find(assist.down.isHBB);
assist.down.ABB_ii = find(assist.down.isABB);

assist.down.chA.mrad.x = assist.chA.cxs.x;
assist.down.chB.mrad.x = assist.chB.cxs.x;
%Forward
% Ch A
assist.down.chA.ifg.F = downsample(assist.chA.y(assist.logi.F,:),N);
assist.down.chA.cxs.F = downsample(assist.chA.cxs.y(assist.logi.F,:),N);
assist.down.chA.mrad.F = downsample(assist.chA.mrad.y(assist.logi.F,:),N);
assist.down.chA.var.F = downvariance(assist.chA.mrad.y(assist.logi.F,:),N);
% Ch B
assist.down.chB.ifg.F = downsample(assist.chB.y(assist.logi.F,:),N);
assist.down.chB.cxs.F = downsample(assist.chB.cxs.y(assist.logi.F,:),N);
assist.down.chB.mrad.F = downsample(assist.chB.mrad.y(assist.logi.F,:),N);
assist.down.chB.var.F = downvariance(assist.chB.mrad.y(assist.logi.F,:),N);

% Reverse
% Ch A
assist.down.chA.ifg.R = downsample(assist.chA.y(assist.logi.R,:),N);
assist.down.chA.cxs.R = downsample(assist.chA.cxs.y(assist.logi.R,:),N);
assist.down.chA.mrad.R = downsample(assist.chA.mrad.y(assist.logi.R,:),N);
assist.down.chA.var.R = downvariance(assist.chA.mrad.y(assist.logi.R,:),N);
% Ch B
assist.down.chB.ifg.R = downsample(assist.chB.y(assist.logi.R,:),N);
assist.down.chB.cxs.R = downsample(assist.chB.cxs.y(assist.logi.R,:),N);
assist.down.chB.mrad.R = downsample(assist.chB.mrad.y(assist.logi.R,:),N);
assist.down.chB.var.R = downvariance(assist.chB.mrad.y(assist.logi.R,:),N);

% Combine F and R
assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
assist.down.chA.var.y = (assist.down.chA.var.F  + assist.down.chA.var.R);
assist.down.chA.T_bt = BrightnessTemperature(assist.chA.cxs.x, real(assist.down.chA.mrad.y));

assist.down.chB.mrad.y = (assist.down.chB.mrad.F + assist.down.chB.mrad.R)./2;
assist.down.chB.var.y = (assist.down.chB.var.F  + assist.down.chB.var.R);
assist.down.chB.T_bt = BrightnessTemperature(assist.chB.cxs.x, real(assist.down.chB.mrad.y));
%%
assist.degraded.chA.NEN1.F = downsample(sqrt(assist.down.chA.var.F),50,2).*(sqrt(15./120));
assist.degraded.chB.NEN1.F = downsample(sqrt(assist.down.chB.var.F),50,2).*(sqrt(15./120));
%% 

assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);
assist.degraded.chA.Resp_F = downsample(assist.chA.cal_F.Resp,50,2);
assist.degraded.chA.Offset_ru_F = downsample(assist.chA.cal_F.Offset_ru,50,2);
assist.degraded.chA.mrad.R = downsample(assist.down.chA.mrad.R,50,2);
assist.degraded.chA.Resp_R = downsample(assist.chA.cal_R.Resp,50,2);
assist.degraded.chA.Offset_ru_R = downsample(assist.chA.cal_R.Offset_ru,50,2);
assist.degraded.chA.mrad.y = downsample(assist.down.chA.mrad.y,50,2);
assist.degraded.chA.T_bt = BrightnessTemperature(assist.degraded.chA.mrad.x, ...
   real(assist.degraded.chA.mrad.y));

assist.degraded.chB.mrad.x = downsample(assist.chB.cxs.x,50);
assist.degraded.chB.mrad.F = downsample(assist.down.chB.mrad.F,50,2);
assist.degraded.chB.Resp_F = downsample(assist.chB.cal_F.Resp,50,2);
assist.degraded.chB.Offset_ru_F = downsample(assist.chB.cal_F.Offset_ru,50,2);
assist.degraded.chB.mrad.R = downsample(assist.down.chB.mrad.R,50,2);
assist.degraded.chB.Resp_R = downsample(assist.chB.cal_R.Resp,50,2);
assist.degraded.chB.Offset_ru_R = downsample(assist.chB.cal_R.Offset_ru,50,2);
assist.degraded.chB.mrad.y = downsample(assist.down.chB.mrad.y,50,2);
assist.degraded.chB.T_bt = BrightnessTemperature(assist.degraded.chB.mrad.x, ...
   real(assist.degraded.chB.mrad.y ));
%%
NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chA.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.R(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.R(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chA.Resp_R);


NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2.F = abs(NEN2_cxs_std./assist.degraded.chB.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.R(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.R(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2.R = abs(NEN2_cxs_std./assist.degraded.chB.Resp_R);


assist.degraded.chA.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.F(3:8,:))),50,2))./sqrt(2);
assist.degraded.chB.sky_NEN.F =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.F(3:8,:))),50,2))./sqrt(2);
assist.degraded.chA.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chA.mrad.R(3:8,:))),50,2))./sqrt(2);
assist.degraded.chB.sky_NEN.R =  sqrt(downvariance(mean(imag(assist.down.chB.mrad.R(3:8,:))),50,2))./sqrt(2);

%%
IRT = irt_rel_resp;
assist.IRT_resp = interp1(IRT.wn, IRT.rel_resp_wn,assist.chA.cxs.x,'cubic');
assist.IRT_resp(assist.chA.cxs.x<min(IRT.wn)|assist.chA.cxs.x>max(IRT.wn))=0;
assist.IRT_resp = assist.IRT_resp./trapz(assist.chA.cxs.x, assist.IRT_resp);
assist.IRT_cwn = IRT.cwn;
% figure; plot(IRT.wn, IRT.rel_resp_wn, 'ko', assist.chA.cxs.x, assist.IRT_resp, '.');
assist.down.IRT_rad = trapz(assist.chA.cxs.x, (real(assist.down.chA.mrad.y.*...
   (ones([size(assist.down.chA.mrad.y,1),1])*assist.IRT_resp)))');
assist.down.IRT_K = BrightnessTemperature(assist.IRT_cwn, assist.down.IRT_rad);
assist.down.IRT_C = assist.down.IRT_K-273.17;


return

function seq = cut_seq(seq)
deg = seq.degraded;
seq = seq.down;
seq.chA = deg.chA;
seq.chB = deg.chB;

return