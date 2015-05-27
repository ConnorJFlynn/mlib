function assist = assist_annew_8(pname)% ASSIST annew
% Apply processing without NLC
% Review derived products
% Fine details to address:
% Apply NLC
% Refine effective wavenumber for chA and chB
% Cavity effect on emissivity
% Back-reflected radiance
% FFOV effects on line shape


%%
while ~exist('pname','var')||~exist(pname, 'dir')
   [pname] = getdir([],'assist');
end

ann_ls = dir([pname, '*ann*.xls']);
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
end

chA_ls = dir([pname, '*_chA_*.mat']);
for chA = length(chA_ls):-1:1
   fname = chA_ls(chA).name;
   edgar_mat = loadinto([pname,fname]);
   flynn_mat = repack_edgar(edgar_mat);
   if ~isfield(assist,'chA')
      assist.chA = flynn_mat;
   else
      assist.chA = stitch_mats(assist.chA,flynn_mat);
   end
end

assist.pname = pname;
assist.time = assist.chA.time;

chB_ls = dir([pname, '*_chB_*.mat']);
for chB = length(chB_ls):-1:1
   fname = chB_ls(chB).name;
   edgar_mat = loadinto([pname,fname]);
   flynn_mat = repack_edgar(edgar_mat);
   if ~isfield(assist,'chB')
      assist.chB = flynn_mat;
   else
      assist.chB = stitch_mats(assist.chB,flynn_mat);
   end
end

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
HBB_off = 0;
ABB_off = 0;
assist.HBB_C = HBB_off+double(assist.chA.HBBRawTemp)./500;
assist.ABB_C = ABB_off+double(assist.chA.CBBRawTemp)./500;
assist.chA.laser_wl = 632.8e-7;    % He-Ne wavelength in cm
assist.chA.laser_wn = 1./assist.chA.laser_wl; % wavenumber in 1/cm
assist = flip_reverse_scans(assist);

%%


% [zpd_loc,zpd_mag] = find_zpd_edgar(assist.chB.y(assist.logi.F&assist.logi.H,:)); 
% zpd_loc = mode(zpd_loc); zpd_shift_F_H = length(assist.chB.x)./2 +1 - zpd_loc;

% %%
% new_zpd = sideshift(assist.chB.x, assist.chB.y(assist.logi.F&assist.logi.H,:), zpd_shift_F);
% [old_spc.x, old_spc.y] = RawIgm2RawSpc(assist.chB.x,fftshift(old_zpd));
% [new_spc.x, new_spc.y] = RawIgm2RawSpc(assist.chB.x,fftshift(new_zpd));
% %%
% figure; 
% ss(1) = subplot(2,1,1);
% plot(old_spc.x,[real(old_spc.y(1,:));imag(old_spc.y(1,:))],'-');
% legend('real','imag');
% ss(2) = subplot(2,1,2); 
% plot(old_spc.x,[real(new_spc.y(1,:));imag(new_spc.y(1,:))],'-');
% linkaxes(ss,'x');
% legend('real','imag');
%%

unflipped = mean(assist.chA.y(assist.logi.F&assist.logi.H,:));
zpd_shift_F = find_zpd_xcorr(unflipped);
assist.chA.y(assist.logi.F,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.F,:), zpd_shift_F);
assist.chA.y(assist.logi.F,:) = fftshift(assist.chA.y(assist.logi.F,:));
% [zpd_loc,zpd_mag] = find_zpd_edgar(assist.chA.y(assist.logi.R,:)); 
% zpd_loc = mode(zpd_loc); zpd_shift_R = length(assist.chA.x)./2 +1 - zpd_loc;
unflipped = mean(assist.chA.y(assist.logi.R&assist.logi.H,:));
% flipped = fliplr(unflipped);
% [R,lags] = xcorr(unflipped,flipped,100);
% [~,ind] = max(R); 
zpd_shift_R = find_zpd_xcorr(unflipped);
% assist.chA.y(assist.logi.R,:) =  zpd_circshift(assist.chA.x,
% assist.chA.y(assist.logi.R,:), zpd_shift_R);
assist.chA.y(assist.logi.R,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.R,:), zpd_shift_R);
assist.chA.y(assist.logi.R,:) = fftshift(assist.chA.y(assist.logi.R,:));
% [zpd_loc,zpd_mag] = find_zpd_edgar(assist.chB.y(assist.logi.F,:)); 
% zpd_loc = mode(zpd_loc); zpd_shift_F = length(assist.chB.x)./2 +1 - zpd_loc;
unflipped = mean(assist.chB.y(assist.logi.F&assist.logi.H,:));
% flipped = fliplr(unflipped);
% [R,lags] = xcorr(unflipped,flipped,100);
% [~,ind] = max(R); 
zpd_shift_F = find_zpd_xcorr(unflipped);;
assist.chB.y(assist.logi.F,:) =  sideshift(assist.chB.x, assist.chB.y(assist.logi.F,:), zpd_shift_F);
assist.chB.y(assist.logi.F,:) = fftshift(assist.chB.y(assist.logi.F,:));
% [zpd_loc,zpd_mag] = find_zpd_edgar(assist.chB.y(assist.logi.R,:)); 
% zpd_loc = mode(zpd_loc); zpd_shift_R = length(assist.chB.x)./2 +1 - zpd_loc;
unflipped = mean(assist.chB.y(assist.logi.R&assist.logi.H,:));
% flipped = fliplr(unflipped);
% [R,lags] = xcorr(unflipped,flipped,100);
% [~,ind] = max(R); 
zpd_shift_R = find_zpd_xcorr(unflipped);;
assist.chB.y(assist.logi.R,:) =  sideshift(assist.chB.x, assist.chB.y(assist.logi.R,:), zpd_shift_R);
assist.chB.y(assist.logi.R,:) = fftshift(assist.chB.y(assist.logi.R,:));


[assist.chA.cxs.x,assist.chA.cxs.y] = RawIgm2RawSpc(assist.chA.x,assist.chA.y);

[assist.chB.cxs.x,assist.chB.cxs.y] = RawIgm2RawSpc(assist.chB.x,assist.chB.y);

nlc.a2 = (4.6828e-008);
nlc.IHLAB=(-80443);
nlc.ICLAB=(96455);
[assist.chA.cxs.y,assist.chA.nlc] = NLC_SSEC(assist,nlc);
%%

assist = rad_cal_def_M(assist);
%%
assist.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F);
assist.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R);
assist.chB.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.F,:), assist.chB.cal_F);
assist.chB.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.R,:), assist.chB.cal_R);

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
assist.down.chA.cxs.F = downsample(assist.chA.cxs.y(assist.logi.F,:),N);
assist.down.chA.mrad.F = downsample(assist.chA.spc.y(assist.logi.F,:),N);
assist.down.chA.var.F = downvariance(assist.chA.spc.y(assist.logi.F,:),N);
assist.down.chA.mrad.R = downsample(assist.chA.spc.y(assist.logi.R,:),N);
assist.down.chA.var.R = downvariance(assist.chA.spc.y(assist.logi.R,:),N);
assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
assist.down.chA.var.y = (assist.down.chA.var.F  + assist.down.chA.var.R);
assist.down.chA.T_bt = BrightnessTemperature(assist.chA.cxs.x, real(assist.down.chA.mrad.y));

assist.down.chB.mrad.x = assist.chB.cxs.x;
assist.down.chB.cxs.F = downsample(assist.chB.cxs.y(assist.logi.F,:),N);
assist.down.chB.mrad.F = downsample(assist.chB.spc.y(assist.logi.F,:),N);
assist.down.chB.var.F = downvariance(assist.chB.spc.y(assist.logi.F,:),N);
assist.down.chB.mrad.R = downsample(assist.chB.spc.y(assist.logi.R,:),N);
assist.down.chB.var.R = downvariance(assist.chB.spc.y(assist.logi.R,:),N);
assist.down.chB.mrad.y = (assist.down.chB.mrad.F + assist.down.chB.mrad.R)./2;
assist.down.chB.var.y = (assist.down.chB.var.F + assist.down.chB.var.R);
assist.down.chB.T_bt = BrightnessTemperature(assist.chB.cxs.x, real(assist.down.chA.mrad.y));
%%
assist.degraded.chA.NEN1.F = downsample(sqrt(assist.down.chA.var.F),50,2).*(sqrt(15./120));
assist.degraded.chB.NEN1.F = downsample(sqrt(assist.down.chB.var.F),50,2).*(sqrt(15./120));
%% 

assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);
assist.degraded.chA.Resp_F = downsample(assist.chA.cal_F.Resp,50,2);
assist.degraded.chA.Offset_ru_F = downsample(assist.chA.cal_F.Offset_ru,50,2);
assist.degraded.chA.Resp_R = downsample(assist.chA.cal_R.Resp,50,2);
assist.degraded.chA.Offset_ru_R = downsample(assist.chA.cal_R.Offset_ru,50,2);
assist.degraded.chA.T_bt = BrightnessTemperature(assist.degraded.chA.mrad.x, ...
   real(assist.degraded.chA.mrad.F ));

assist.degraded.chB.mrad.x = downsample(assist.chB.cxs.x,50);
assist.degraded.chB.mrad.F = downsample(assist.down.chB.mrad.F,50,2);
assist.degraded.chB.Resp_F = downsample(assist.chB.cal_F.Resp,50,2);
assist.degraded.chB.Offset_ru_F = downsample(assist.chB.cal_F.Offset_ru,50,2);
assist.degraded.chB.Resp_R = downsample(assist.chB.cal_R.Resp,50,2);
assist.degraded.chB.Offset_ru_R = downsample(assist.chB.cal_R.Offset_ru,50,2);

assist.degraded.chB.T_bt = BrightnessTemperature(assist.degraded.chB.mrad.x, ...
   real(assist.degraded.chB.mrad.F ));
%%
NEN2_cxs_std = sqrt(downvariance(real(assist.down.chA.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chA.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chA.NEN2 = abs(NEN2_cxs_std./assist.degraded.chA.Resp_F);

NEN2_cxs_std = sqrt(downvariance(real(assist.down.chB.cxs.F(assist.down.HBB_ii(1),:)...
   -assist.down.chB.cxs.F(assist.down.HBB_ii(2),:)),50,2));
assist.degraded.chB.NEN2 = abs(NEN2_cxs_std./assist.degraded.chB.Resp_F);
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
  %%
  % So, first compare the spectral quantities
  
  % Then, define the different sub-bands and compute related quantities
  % Then, load each mat file and check content.
proc_pname = ['C:\case_studies\assist\data\post_Feb_repair\20110210_202919\one_sequence\PROCESSED'];
infileA = getfullname_('*_chA_BTemp_SKY*.mat','edgar_mat','Select ch A Brightness temperature')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
posA = assist.degraded.chA.mrad.x>=min(matA.x)&assist.degraded.chA.mrad.x<=max(matA.x);
posB = assist.degraded.chB.mrad.x>=min(matB.x)&assist.degraded.chB.mrad.x<=max(matB.x);

figure; 
plot(matA.x,matA.y(1,:)-273.15, 'k.',...
   assist.degraded.chA.mrad.x(posA), assist.degraded.chA.T_bt(assist.down.isSky,posA)-273.15,'ro',...
   matA.x,matA.y -273.15, 'k.',...
   assist.degraded.chB.mrad.x(posB), assist.degraded.chB.T_bt(assist.down.isSky,posB)-273.15,'ro',...
   matB.x,matB.y -273.15, 'k.')
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

%
infileA = getfullname_('*_chA_SKY.coad.mrad.coad.merged.truncated.mat','edgar_mat','Select ch A truncated mrad')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
posA = assist.down.chA.mrad.x>=min(matA.x)&assist.down.chA.mrad.x<=max(matA.x);
posB = assist.down.chB.mrad.x>=min(matB.x)&assist.down.chB.mrad.x<=max(matB.x);
%%

figure; 
plot(matA.x,matA.y(1,:), 'k.',...
   assist.down.chA.mrad.x(posA), assist.down.chA.mrad.F(assist.down.isSky,posA),'ro',...
   matA.x,matA.y, 'k.',...
   assist.down.chB.mrad.x(posB), assist.down.chB.mrad.F(assist.down.isSky,posB),'ro',...
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
plot(Re_matA.x,Re_matA.y(1,:), 'k.',...
   Im_matA.x,Im_matA.y(1,:), 'r.',...
   Re_matB.x,Re_matB.y(1,:), 'k.',...
   Im_matB.x,Im_matB.y(1,:), 'r.')
legend('Re','Im')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
subplot(2,1,2);
%%
figure
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
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
subplot(2,1,2);
figure;
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
title('forward scan responsivity and offsets','interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');

%%
figure;
subplot(2,1,1);
plot(Re_matA.x,Re_matA.y(2,:), 'k.',...
   Im_matA.x,Im_matA.y(2,:), 'r.',...
   Re_matB.x,Re_matB.y(2,:), 'k.',...
   Im_matB.x,Im_matB.y(2,:), 'r.')
legend('Re','Im')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
subplot(2,1,2);
plot(Re_offA.x,-Re_offA.y(2,:)./(1000.*Re_matA.y(2,:)), 'k.',...
   Im_offA.x,-Im_offA.y(2,:)./(1000.*Im_matA.y(2,:)), 'r.',...
   Re_offB.x,-Re_offB.y(2,:)./(1000.*Re_matB.y(2,:)), 'k.',...
   Im_offB.x,-Im_offB.y(2,:)./(1000.*Im_matB.y(2,:)), 'r.',...
   assist.degraded.chA.mrad.x(posA), -real(assist.degraded.chA.Offset_ru_R(posA)),'k-',...
   assist.degraded.chB.mrad.x(posB), -real(assist.degraded.chB.Offset_ru_R(posB)),'k-',...
   assist.degraded.chA.mrad.x(posA), -imag(assist.degraded.chA.Offset_ru_R(posA)),'r-',...
   assist.degraded.chB.mrad.x(posB), -imag(assist.degraded.chB.Offset_ru_R(posB)),'r-')
legend('Re','Im')
xlim([550,3000]);
title('reverse scan responsivity and offsets','interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');

%%
figure; 
s(1) = subplot(2,1,1);
plot(assist.degraded.chA.mrad.x(posA), real(assist.degraded.chA.Resp_F(posA)),'k.',...
   assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Resp_F(posA)),'r.',...
assist.degraded.chB.mrad.x(posB), real(assist.degraded.chB.Resp_F(posB)),'k.',...
assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Resp_F(posB)),'r.');
legend('real','imag')
xlim([550,3000]);
title('Flynn');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');

s(2) = subplot(2,1,2);
plot(Re_matA.x,Re_matA.y(1,:), 'k.',...
   Im_matA.x,Im_matA.y(1,:), 'r.',...
   Re_matA.x,Re_matA.y(1,:), 'k.',...
   Re_matB.x,Re_matB.y(1,:), 'k.',...
   Im_matB.x,Im_matB.y(1,:), 'r.')
legend('Re','Im')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
linkaxes(s,'x');
%%
p = 1;
png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
while exist(png_file,'file')
   p = p +1;
   png_file = [mat_pname,filesep,mat_fname,'.',num2str(p), '.png'];
end
saveas(gcf,png_file);

%%
infileA = getfullname_('*_chA_SKY_RESP_IMA_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN1')
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
   assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Resp_F(posA)),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Resp_F(posB)),'ro',...
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
infileA = getfullname_('*_chA_SKY_OFF_REAL_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN1')
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
   assist.degraded.chA.mrad.x(posA), real(assist.degraded.chA.Offset_ru_F(posA)),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), real(assist.degraded.chB.Offset_ru_F(posB)),'ro',...
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
infileA = getfullname_('*_chA_SKY_OFF_IMA_SKY.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN1')
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
   assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Offset_ru_F(posA)),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Offset_ru_F(posB)),'ro',...
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
infileA = getfullname_('*_SKYNen.coad.mrad.pro.truncated.degraded.mat','edgar_mat','Select ch A NEN1')
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
   assist.degraded.chA.mrad.x(posA), imag(assist.degraded.chA.Offset_ru_F(posA)),'ro',...
   matA.x,matA.y, 'k.',...
   assist.degraded.chB.mrad.x(posB), imag(assist.degraded.chB.Offset_ru_F(posB)),'ro',...
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

function mat = repack_edgar(edgar)
if ~exist('edgar','var')
   edgar =loadinto(getfullname_('*.mat','edgar_mat','Select an Edgar mat file.'));
end
if ~isstruct(edgar)&&exist(edgar,'file')
   edgar =loadinto(edgar);
end
V = double([edgar.mainHeaderBlock.date.year,edgar.mainHeaderBlock.date.month,...
   edgar.mainHeaderBlock.date.day,edgar.mainHeaderBlock.date.hours,...
   edgar.mainHeaderBlock.date.minutes,edgar.mainHeaderBlock.date.seconds]);
nbPoints = edgar.mainHeaderBlock.nbPoints;
% xStep = (edgar.mainHeaderBlock.lastX-edgar.mainHeaderBlock.firstX)./(nbPoints-1);
mat.x = linspace(edgar.mainHeaderBlock.firstX, (edgar.mainHeaderBlock.lastX), double(nbPoints)); 
if isfield(edgar.mainHeaderBlock,'laserFrequency')
mat.laserFrequency = edgar.mainHeaderBlock.laserFrequency;
end
base_time = datenum(V);
subs = length(edgar.subfiles);
for s = subs:-1:1
mat.time(s) = base_time +  double(edgar.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
mat.flags(s) = edgar.subfiles{s}.subfileHeader.subFlags;
if isfield(edgar.subfiles{s}.subfileHeader,'nbCoaddedScans')
   mat.coads(s) = edgar.subfiles{s}.subfileHeader.nbCoaddedScans;
end
mat.subIndex(s) = edgar.subfiles{s}.subfileHeader.subIndex;
mat.scanNb(s) = edgar.subfiles{s}.subfileHeader.scanNb;
mat.HBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subHBBRawTemp;
mat.CBBRawTemp(s) = edgar.subfiles{s}.subfileHeader.subCBBRawTemp;
if isfield(edgar.subfiles{s}.subfileHeader,'zpdLocation')
mat.zpdLocation(s) = edgar.subfiles{s}.subfileHeader.zpdLocation;
end
if isfield(edgar.subfiles{s}.subfileHeader,'zpdValue')
mat.zpdValue(s) = edgar.subfiles{s}.subfileHeader.zpdValue;
end
mat.y(s,:) = edgar.subfiles{s}.subfileData;
end
mat.flags = uint8(mat.flags);
return

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

function assist = rad_cal_def_M(assist)
% Just looking at chA right now to assess calibration from pre-merged data 
% simplest, use mean temperatures and BB spectra over entire measurement
% Determines seperate calibrations from F, R, and premerged data set.
T_hot_F = mean(assist.HBB_C(assist.logi.HBB_F));
T_cold_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_hot_R = mean(assist.HBB_C(assist.logi.HBB_R));
T_cold_R = mean(assist.ABB_C(assist.logi.ABB_R));

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

assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);

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

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
if isfield(assist,'chB')
   in_spec.x = assist.chB.cxs.x;
   in_spec.y = assist.chB.cxs.y(assist.logi.H&assist.logi.F,:);
   HBB_F = CoaddData(in_spec);
   
   in_spec.x = assist.chB.cxs.x;
   in_spec.y = assist.chB.cxs.y(assist.logi.H&assist.logi.R,:);
   HBB_R = CoaddData(in_spec);
   
   in_spec.x = assist.chB.cxs.x;
   in_spec.y = assist.chB.cxs.y(assist.logi.A&assist.logi.F,:);;
   ABB_F = CoaddData(in_spec);
   
   in_spec.x = assist.chB.cxs.x;
   in_spec.y = assist.chB.cxs.y(assist.logi.A&assist.logi.R,:);
   ABB_R = CoaddData(in_spec);
   
   assist.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
   assist.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
end
return