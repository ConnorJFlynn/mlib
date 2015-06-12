function assist = assist_annew_4(pname)% ASSIST annew
% First load the entire calibration sequence
% Assess difference between a2 Vm model and Griffith's 3-point 
  %%
infileA = getfullname_('*_chA_SKY.coad.mrad.coad.merged.truncated*.mat','edgar_mat','Select degraded sky')
chA_sky = repack_edgar(infileA); 
IRT = irt_rel_resp;

%%
chA_sky.IRT_resp = interp1(IRT.wn, IRT.rel_resp_wn, chA_sky.x, 'cubic');
chA_sky.IRT_resp(chA_sky.x<min(IRT.wn)|chA_sky.x>max(IRT.wn)) =0;
chA_sky.IRT_resp = chA_sky.IRT_resp./trapz(chA_sky.x, chA_sky.IRT_resp);
figure; plot(IRT.wn, IRT.rel_resp_wn, 'ko', chA_sky.x, chA_sky.IRT_resp, '.');

[pname, fname, ext] = fileparts(infileA);
fid = fopen([pname,filesep, 'IRT_resp_for_ASSIST_wn_scale.dat'], 'w');
fprintf(fid, '%s \n', 'wavenumber responsivity') 
fprintf(fid, '%f %2.4e \n',[chA_sky.x; chA_sky.IRT_resp]);
fclose(fid)

%%
while ~exist('pname','var')||~exist(pname, 'dir')
   [pname] = getdir('assist');
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

logi.F = bitget(assist.chA.flags,2)>0;
logi.R = bitget(assist.chA.flags,3)>0;
logi.H = bitget(assist.chA.flags,5)>0;
logi.A = bitget(assist.chA.flags,6)>0;
logi.Sky = ~(logi.H|logi.A); sky_ii = find(logi.Sky);
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

[zpd_loc,zpd_mag] = find_zpd_edgar(assist.chA.y(assist.logi.F,:)); 
zpd_loc = mode(zpd_loc); zpd_shift_F = length(assist.chA.x)./2 +1 - zpd_loc;
assist.chA.y(assist.logi.F,:) =  zpd_circshift(assist.chA.x, assist.chA.y(assist.logi.F,:), zpd_shift_F);

[zpd_loc,zpd_mag] = find_zpd_edgar(assist.chA.y(assist.logi.R,:)); 
zpd_loc = mode(zpd_loc); zpd_shift_R = length(assist.chA.x)./2 +1 - zpd_loc;
assist.chA.y(assist.logi.R,:) =  zpd_circshift(assist.chA.x, assist.chA.y(assist.logi.R,:), zpd_shift_R);

[assist.chA.cxs.x,assist.chA.cxs.y] = RawIgm2RawSpc(assist.chA.x,assist.chA.y);
assist_NLC = assist;
assist_grf = assist;


assist = rad_cal_def_M(assist);
assist.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F);
assist.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R);

nlc.a2 = (4.6828e-008);
nlc.IHLAB=(-80443);
nlc.ICLAB=(96455);
[assist_NLC.chA.cxs.y,assist_NLC.chA.nlc] = NLC_SSEC(assist,nlc);
assist_NLC = rad_cal_def_M(assist_NLC);
assist_NLC.chA.spc.y(assist_NLC.logi.F,:) = RadiometricCalibration_4(assist_NLC.chA.cxs.y(assist_NLC.logi.F,:), assist_NLC.chA.cal_F);
assist_NLC.chA.spc.y(assist_NLC.logi.R,:) = RadiometricCalibration_4(assist_NLC.chA.cxs.y(assist_NLC.logi.R,:), assist_NLC.chA.cal_R);

[assist_grf.chA.y(assist_grf.logi.F,:),A_F] = NLC_Grif(assist_grf.chA.x,assist_grf.chA.y(assist_grf.logi.F,:));
[assist_grf.chA.y(assist_grf.logi.R,:),A_R] = NLC_Grif(assist_grf.chA.x,assist_grf.chA.y(assist_grf.logi.R,:));
[assist_grf.chA.cxs.x,assist_grf.chA.cxs.y] = RawIgm2RawSpc(assist_grf.chA.x,assist_grf.chA.y);
assist_grf = rad_cal_def_M(assist_grf);
assist_grf.chA.spc.y(assist_grf.logi.F,:) = RadiometricCalibration_4(assist_grf.chA.cxs.y(assist_grf.logi.F,:), assist_grf.chA.cal_F);
assist_grf.chA.spc.y(assist_grf.logi.R,:) = RadiometricCalibration_4(assist_grf.chA.cxs.y(assist_grf.logi.R,:), assist_grf.chA.cal_R);

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
assist.down.Sky_ii = find(assist.down.isSky);
assist.down.chA.mrad.x = assist.chA.cxs.x;
assist.down.chA.mrad.F = downsample(assist.chA.spc.y(assist.logi.F,:),N);
assist.down.chA.var.F = downvariance(assist.chA.spc.y(assist.logi.F,:),N);
assist.down.chA.mrad.R = downsample(assist.chA.spc.y(assist.logi.R,:),N);
assist.down.chA.var.R = downvariance(assist.chA.spc.y(assist.logi.R,:),N);
assist.down.chA.mrad.y = (assist.down.chA.mrad.F + assist.down.chA.mrad.R)./2;
assist.down.chA.var.y = (assist.down.chA.var.F  + assist.down.chA.var.R);

%% 
assist.degraded.chA.mrad.x = downsample(assist.chA.cxs.x,50);
assist.degraded.chA.mrad.F = downsample(assist.down.chA.mrad.F,50,2);

%%
figure; 
plot(assist.degraded.chA.cal_F.x,NEN1.F([2],:).*(sqrt(19./120)),'r.',...
   assist.degraded.chA.cal_F.x,abs(NEN2),'b.');
legend('NEN1','NEN2');
xlabel('wavenumber')
ylabel('mW(m^2 sr cm^-1)')
xlim([600,1700]);
grid('on')
%%
figure; yy(1) = subplot(2,1,1);
semilogy(assist.degraded.chA.mrad.x ,assist.degraded.chA.mrad.F(3,:),'r.',...
   assist.degraded.chA.cal_F.x,abs(NEN2),'b.');
legend('Sky','NEN2');
xlabel('wavenumber')
ylabel('mW(m^2 sr cm^-1)');
yy(2) = subplot(2,1,2);
semilogy(assist.degraded.chA.mrad.x,assist.degraded.chA.mrad.F(3,:)./abs(NEN2) ,'k.');
legend('SNR');
linkaxes(yy,'x');
xlim([600,1700]);

%%
infileA = getfullname_('*_chA_HBBNen1*.mat','edgar_mat','Select Re Resp')
chA_NEN1 = repack_edgar(infileA); 
%
infileA = getfullname_('*_chA_HBBNen2*.mat','edgar_mat','Select Im Resp.');
chA_NEN2 = repack_edgar(infileA); 
%%
figure; 
plot(chA_NEN1.x, chA_NEN1.y(1,:),'ro',...
   chA_NEN2.x, chA_NEN2.y(1,:),'bo');
legend('NEN1','NEN2')

%%
infileA = getfullname_('*_chA_SKY.coad.mrad.coad.merged.truncated.degraded*.mat','edgar_mat','Select degraded sky')
chA_sky = repack_edgar(infileA); 
%%
figure; yx(1) = subplot(2,1,1);
semilogy(chA_sky.x ,chA_sky.y(1,:),'r.',...
   chA_NEN1.x,chA_NEN1.y(1,:),'b.');
title('Andre')
legend('Sky','NEN1');
xlabel('wavenumber')
ylabel('mW(m^2 sr cm^-1)');
yx(2) = subplot(2,1,2);
semilogy(chA_sky.x,chA_sky.y(1,:)./abs(chA_NEN1.y(1,:)) ,'k.');
legend('SNR');
linkaxes(yx,'x');
xlim([600,1700]);

%%
figure;
s(1) = subplot(2,1,1);
plot(assist.chA.cxs.x,[real(assist.down.chA.mrad.F(assist.down.Sky_ii(1),:)); sqrt(assist.down.chA.var.F(assist.down.Sky_ii(1),:)) ],'-');
legend('radF','sqrt');
s(2) = subplot(2,1,2);
semilogy(assist.chA.cxs.x,[real(assist.down.chA.mrad.F(assist.down.Sky_ii(1),:))./ sqrt(assist.down.chA.var.F(assist.down.Sky_ii(1),:)) ],'-');
legend('F sky snr')
linkaxes(s,'x')
%%
figure;
s(1) = subplot(2,1,1);
plot(assist.chA.cxs.x,[real(assist.down.chA.mrad.R(assist.down.Sky_ii(1),:)); sqrt(assist.down.chA.var.R(assist.down.Sky_ii(1),:)) ],'-');
legend('radR','sqrt');
s(2) = subplot(2,1,2);
semilogy(assist.chA.cxs.x,[real(assist.down.chA.mrad.R(assist.down.Sky_ii(1),:))./ sqrt(assist.down.chA.var.R(assist.down.Sky_ii(1),:)) ],'-');
legend('R sky snr')
linkaxes(s,'x')
%%
figure;
s(1) = subplot(2,1,1);
plot(assist.chA.cxs.x,[real(assist.down.chA.mrad.y(assist.down.Sky_ii(1),:)); sqrt(assist.down.chA.var.y(assist.down.Sky_ii(1),:)) ],'-');
legend('rad','sqrt');
s(2) = subplot(2,1,2);
plot(assist.chA.cxs.x,[real(assist.down.chA.mrad.y(assist.down.Sky_ii(1),:))./ sqrt(assist.down.chA.var.y(assist.down.Sky_ii(1),:)) ],'-');
legend('sky snr')
linkaxes(s,'x');
% axis(v)
%%
IRT = irt_rel_resp;
%%
IRT_assist_wn = interp1(IRT.wn, IRT.rel_resp_wn,assist.chA.cxs.x);
IRT_assist_wn(isNaN(IRT_assist_wn)) = 0;
IRT_rad = trapz(assist.chA.cxs.x, real(assist.down.chA.mrad.y(assist.down.Sky_ii(1),:)).*IRT_assist_wn);
T_irt_K = BrightnessTemperature(IRT.cwn, IRT_rad);
T_irt_C = T_irt_K-273.17;
% Or compute the brightness temperature spectra and integrate it over the 
% brt = BrightnessTemperature(assist.chA.cxs.x, real(assist.down.chA.mrad.y(assist.down.Sky_ii(1),:)));
% brt_irt = trapz(assist.chA.cxs.x(IRT_assist_wn>0), IRT_assist_wn(IRT_assist_wn>0).*brt(IRT_assist_wn>0))
%%
figure;
plot(assist.chA.cxs.x,[assist.chA.spc.y(sky_ii(1),:);assist_NLC.chA.spc.y(sky_ii(1),:);assist_grf.chA.spc.y(sky_ii(1),:)],'-');
legend('cxs','nlc','grif')
figure;
plot(assist.chA.cxs.x,[mean(assist.chA.spc.y(sky_ii(1),:),1)-mean(assist_NLC.chA.spc.y(sky_ii(1),:),1);...
mean(assist.chA.spc.y(sky_ii(1),:),1)-mean(assist_grf.chA.spc.y(sky_ii(1),:),1)],'-');
%%
infileA = getfullname_('*_chA_*.mat','edgar_mat','Select an Edgar mat file.');
[pname, fname, ext] = fileparts(infileA);
matA = repack_edgar(infileA); 
plot(assist.chA.cxs.x,real(assist.down.chA.mrad.y(assist.down.Sky_ii(1),:)),' b-',matA.x, 1000.*matA.y(1,:),'k-');

% Okay, I've demonstrated reasonable agreement between ch A calibrated
% spectra (no NLC) except for wavelength registration and negligible calibration (floating point) discrepancies.
 % Next, compare variances...

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