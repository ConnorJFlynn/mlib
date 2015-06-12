function assist = assist_annew_9(pname)% ASSIST annew
% Apply processing without NLC
% Review derived products
% Fine details to address:
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
pname = 'C:\case_studies\assist\200110928_tests\check_derived\RAW\R1\';
while ~exist('pname','var')||~exist(pname, 'dir')
   [pname] = getdir('assist');
end

B4_mat = loadinto([pname, '20110529_145924_chA_HC.mat']);
sky_mat = loadinto([pname, '20110529_150003_chA_SKY.mat']);
Ftr_mat = loadinto([pname, '20110529_150138_chA_CH.mat']);


B4_edg = repack_edgar(B4_mat);
Ftr_edg = repack_edgar(Ftr_mat);
sky_edg = repack_edgar(sky_mat);
%%
combo_edg = B4_edg;
combo_edg = stitch_mats(combo_edg, Ftr_edg);
combo_edg = stitch_mats(combo_edg, sky_edg);

assist.chA = combo_edg;
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
dim_n = find(size(assist.chA.y)==length(assist.chA.x));
if sum(assist.logi.F&assist.logi.H)>1
   unflipped = mean(assist.chA.y(assist.logi.F&assist.logi.H,:));
else
   unflipped = assist.chA.y(assist.logi.F&assist.logi.H,:);
end
zpd_shift_F = find_zpd_xcorr(unflipped);
assist.chA.y(assist.logi.F,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.F,:), zpd_shift_F);
assist.chA.y(assist.logi.F,:) = fftshift(assist.chA.y(assist.logi.F,:),dim_n);
if sum(assist.logi.R&assist.logi.H)>1
   unflipped = mean(assist.chA.y(assist.logi.R&assist.logi.H,:));
else
   unflipped = assist.chA.y(assist.logi.R&assist.logi.H,:);
end
zpd_shift_R = find_zpd_xcorr(unflipped);
assist.chA.y(assist.logi.R,:) =  sideshift(assist.chA.x, assist.chA.y(assist.logi.R,:), zpd_shift_R);
assist.chA.y(assist.logi.R,:) = fftshift(assist.chA.y(assist.logi.R,:),dim_n);

abb_F.x = assist.chA.x;
hbb_F.x = assist.chA.x;
sky_F.x = assist.chA.x;
abb_F.y = mean(assist.chA.y(logi.ABB_F,:),1);
hbb_F.y = mean(assist.chA.y(logi.HBB_F,:),1);
sky_F.y =mean(assist.chA.y(logi.Sky_F,:),1);

[ABB_F.x,ABB_F.y] = RawIgm2RawSpc(abb_F.x,abb_F.y);
[HBB_F.x,HBB_F.y] = RawIgm2RawSpc(hbb_F.x,hbb_F.y);
[SKY_F.x,SKY_F.y] = RawIgm2RawSpc(sky_F.x,sky_F.y);

%%
% figure; plot(ABB_F.x, [real(ABB_F.y);real(HBB_F.y);real(SKY_F.y);],'-');
% legend('ABB','HBB','SKY')
%%
ABB_F_FFOV.y = ApplyFFOVCorr(ABB_F.x,ABB_F.y, 0.0225);
HBB_F_FFOV.y = ApplyFFOVCorr(HBB_F.x,HBB_F.y, 0.0225);
SKY_F_FFOV.y = ApplyFFOVCorr(SKY_F.x,SKY_F.y, 0.0225);
ABB_F_FFOV.x = ABB_F.x;
HBB_F_FFOV.x = HBB_F.x;
SKY_F_FFOV.x = SKY_F.x;
%%
T_ABB_F = mean(assist.ABB_C(assist.logi.ABB_F));
T_HBB_F = mean(assist.HBB_C(assist.logi.HBB_F));
% [CalSet,CalSet_, CalSet__] = CreateCalibrationFromCXS_(HBB, T_hot, CBB, T_cold,T_mirror, emis);
cal_F      = CreateCalibrationFromCXS_(HBB_F,  273.15+T_HBB_F, ABB_F,  273.15+T_ABB_F);
cal_F_FFOV = CreateCalibrationFromCXS_(HBB_F_FFOV,  273.15+T_HBB_F, ABB_F_FFOV,  273.15+T_ABB_F);
%%
Sky_rad_F.y = RadiometricCalibration_4(SKY_F.y, cal_F);
Sky_rad_F_FFOV.y = RadiometricCalibration_4(SKY_F_FFOV.y, cal_F_FFOV);

HBB_rad_F.y = RadiometricCalibration_4(HBB_F.y, cal_F);
HBB_rad_F_FFOV.y = RadiometricCalibration_4(HBB_F_FFOV.y, cal_F_FFOV);

ABB_rad_F.y = RadiometricCalibration_4(ABB_F.y, cal_F);
ABB_rad_F_FFOV.y = RadiometricCalibration_4(ABB_F_FFOV.y, cal_F_FFOV);

%%
figure; 
ss(1) = subplot(2,1,1);
plot(SKY_F.x, real([Sky_rad_F.y;Sky_rad_F_FFOV.y]), '-');
legend('no FFOV','wi FFOV')
ss(2) = subplot(2,1,2);
plot(SKY_F.x, [real(Sky_rad_F.y)-real(Sky_rad_F_FFOV.y)], 'r-');
grid('on')
linkaxes(ss,'x')
%%
figure; 
ss(1) = subplot(2,1,1);
plot(SKY_F.x, [ABB_rad_F.y;ABB_rad_F_FFOV.y], '-');
legend('ABB no FFOV','ABB wi FFOV')
ss(2) = subplot(2,1,2);
plot(SKY_F.x, [ABB_rad_F.y-ABB_rad_F_FFOV.y], 'r-');
linkaxes(ss,'x')
%%
figure; 
ss(1) = subplot(2,1,1);
plot(SKY_F.x, [HBB_rad_F.y;HBB_rad_F_FFOV.y], '-');
legend('HBB no FFOV','HBB wi FFOV')
ss(2) = subplot(2,1,2);
plot(SKY_F.x, [HBB_rad_F.y-HBB_rad_F_FFOV.y], 'r-');
linkaxes(ss,'x')
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

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans

return

function assist = rad_cal_def_no_ref(assist)
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

assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_cold_F-10);
assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_cold_R-10);

return

function assist = rad_cal_def_no_ref_FFOV(assist)
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
in_spec.y = assist.chA.cxs.y_(assist.logi.H&assist.logi.F,:);
HBB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y_(assist.logi.H&assist.logi.R,:);
HBB_R = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y_(assist.logi.A&assist.logi.F,:);
ABB_F = CoaddData(in_spec);
 
in_spec.x = assist.chA.cxs.x;
in_spec.y = assist.chA.cxs.y_(assist.logi.A&assist.logi.R,:);
ABB_R = CoaddData(in_spec);

assist.chA.cal_F_ = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_cold_F-10);
assist.chA.cal_R_ = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_cold_R-10);

return


% function [y, y_] = ApplyFFOVCorr(x,y, hfov)
% %%
% % 22.5 mrad FFOV (45 full-angle)
% dim_n = find(size(y)==length(x));
% Cnu = fft(y,[],dim_n);
% 
% laser_wl = 632.8e-7;    % He-Ne wavelength in cm
% laser_wn = 1./laser_wl; % wavenumber in 1/cm
% 
% nu = (double(x).*laser_wn./length(x))./2;
% x_ = x.*laser_wl;
% % nu = nu ./ 100;
% % x_ = x_ ./100;
% k2 = (((pi.*hfov.^2./2).^2)./6);
% k4 = -(((pi.*hfov.^2./2).^4)./120);
% c2_ = fft(Cnu.*(ones([size(y,1),1])*nu.^2),[],dim_n);
% c2 = fft(c2_.*(ones([size(y,1),1])*x_.^2),[],dim_n);
% c4_ = fft(Cnu.*(ones([size(y,1),1])*nu.^4),[],dim_n);
% c4 = fft(c4_.*(ones([size(y,1),1])*x_.^4),[],dim_n);
% 
% %%
% y = y_+ c2 + c4;
% 
% return


return 