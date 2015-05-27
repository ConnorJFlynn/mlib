% ASSIST_mat_cal:

% read ASSIST A and B mat files.
% Populate a structure for each incoming channel 
% Assume a complete run with chA and chB and annot all with same length.
 noad.time
      time with logicals Sky ABB HBB F R
      igm.(raw interferograms, one per single-sided igm)
          (Sky|ABB|HBB)_ch(A|B)(F|R)
      spc.(uncalibrated complex spectra, one per singe-direction igm)
         (Sky|ABB|HBB)_ch(A|B)(F|R)
      rad.(radiance calibrated complex spectra, one per single-direction sky igm)
         Sky_ch(A|B){F|R)
coadN.time(single-directional scans in groups of 6)
      time with logicals Sky ABB HBB F R
      spc.(uncalibrated complex BB spectra coadded single-direction in groups of 6)
         (ABB|HBB)ch(A|B)(F|R)
      rad.(radiance calibrated complex sky spectra single-direction coadded in groups of 6)
         Sky_ch(A|B)
      var.(radiance calibrated complex variance spectra single-direction in groups of 6)
         (Sky|ABB|HBB)_ch(A|B)(F|R) (calibration applied to ABB|HBB variances, variance computed from calibrated Sky noads.
      css.(radiance calibrated
         (ABB|HBB|Sky)ch(A|B)(F|R)         
         
diravg.         
% assist.uvs_FR.
% assist.


clear
close('all')
[pname] = getdir;
% pname ='C:\case_studies\assist\integration\data_integration\at_SGP\MG Sky
% run11math 21mai2010\';
A_list = dir([pname, '*A.igm']);
chA_fname = A_list(1).name;
B_list = dir([pname, '*B.igm']);
chB_fname = B_list(1).name;
ann_list = dir([pname, '*.xls']);
annot_fname = ann_list(1).name;

% pname = 'C:\case_studies\assist\integration\data_integration\at_SGP\2010_05_23 9to10UTC Runs\SKY_RUN_270\';
% annot_fname = 'D23May10_09_55_30_N_ANN.xls';
% chA_fname = 'D23May10_09_55_30_A_A.igm';
% chB_fname = 'D23May10_09_55_30_B_B.igm';

[xl_num, xl_txt]= xlsread([pname, annot_fname]);
annot.scanNb = xl_num(:,1);
annot.HBB_C = xl_num(:,19);
annot.CBB_C = xl_num(:,24);

assist.chA.edgar_mat = loadinto([pname,chA_fname]);
assist.chB.edgar_mat = loadinto([pname,chB_fname]);
% Populate a structure with each scene and direction separated 
% 
% assist.edg_mat_B = loadinto([pname,'D21May10_23_41_19_B_B.igm']);
V = double([assist.chA.edgar_mat.mainHeaderBlock.date.year,assist.chA.edgar_mat.mainHeaderBlock.date.month,...
   assist.chA.edgar_mat.mainHeaderBlock.date.day,assist.chA.edgar_mat.mainHeaderBlock.date.hours,...
   assist.chA.edgar_mat.mainHeaderBlock.date.minutes,assist.chA.edgar_mat.mainHeaderBlock.date.seconds]);
nbPoints = assist.chA.edgar_mat.mainHeaderBlock.nbPoints;
% xStep = (assist.chA.edgar_mat.mainHeaderBlock.lastX-assist.chA.edgar_mat.mainHeaderBlock.firstX)./(nbPoints-1);
assist.chA.flynn_mat.x = linspace(assist.chA.edgar_mat.mainHeaderBlock.firstX, (assist.chA.edgar_mat.mainHeaderBlock.lastX-1), double(nbPoints)); 
assist.chA.flynn_mat.base_time = datenum(V);
subs = length(assist.chA.edgar_mat.subfiles);
for s = subs:-1:1
assist.chA.flynn_mat.time(s) = assist.chA.flynn_mat.base_time +  double(assist.chA.edgar_mat.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
assist.chA.flynn_mat.flags(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.subFlags;
assist.chA.flynn_mat.coads(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.nbCoaddedScans;
assist.chA.flynn_mat.subIndex(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.subIndex;
assist.chA.flynn_mat.scanNb(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.scanNb;
assist.chA.flynn_mat.HBBRawTemp(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.subHBBRawTemp;
assist.chA.flynn_mat.CBBRawTemp(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.subCBBRawTemp;
if isfield(assist.chA.edgar_mat.subfiles{s}.subfileHeader,'zpdLocation')
assist.chA.flynn_mat.zpdLocation(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.zpdLocation;
end
if isfield(assist.chA.edgar_mat.subfiles{s}.subfileHeader,'zpdValue')
assist.chA.flynn_mat.zpdValue(s) = assist.chA.edgar_mat.subfiles{s}.subfileHeader.zpdValue;
end
assist.chA.flynn_mat.y(s,:) = assist.chA.edgar_mat.subfiles{s}.subfileData;
end
assist.time = assist.chA.flynn_mat.time;
assist.chA.flynn_mat.flags = uint8(assist.chA.flynn_mat.flags);
HBB_F = bitget(assist.chA.flynn_mat.flags,2)&bitget(assist.chA.flynn_mat.flags,5);
HBB_R = bitget(assist.chA.flynn_mat.flags,3)&bitget(assist.chA.flynn_mat.flags,5);
CBB_F = bitget(assist.chA.flynn_mat.flags,2)&bitget(assist.chA.flynn_mat.flags,6);
CBB_R = bitget(assist.chA.flynn_mat.flags,3)&bitget(assist.chA.flynn_mat.flags,6);
Sky_F = bitget(assist.chA.flynn_mat.flags,2)& ~(bitget(assist.chA.flynn_mat.flags,5)|bitget(assist.chA.flynn_mat.flags,6));
Sky_R = bitget(assist.chA.flynn_mat.flags,3)& ~(bitget(assist.chA.flynn_mat.flags,5)|bitget(assist.chA.flynn_mat.flags,6));

assist.chA.HBB_F = annot.HBB_C(HBB_F);
assist.chA.HBB_R = annot.HBB_C(HBB_R);
assist.chA.CBB_F = annot.CBB_C(CBB_F);
assist.chA.CBB_R = annot.CBB_C(CBB_R);

assist.chA.igm.HBB_F.x = assist.chA.flynn_mat.x;
assist.chA.igm.CBB_F.x= assist.chA.flynn_mat.x;
assist.chA.igm.Sky_F.x= assist.chA.flynn_mat.x;
assist.chA.igm.HBB_R.x= assist.chA.flynn_mat.x;
assist.chA.igm.CBB_R.x= assist.chA.flynn_mat.x;
assist.chA.igm.Sky_R.x= assist.chA.flynn_mat.x;

assist.chA.igm.HBB_F.y = assist.chA.flynn_mat.y(HBB_F,:);
assist.chA.igm.CBB_F.y = assist.chA.flynn_mat.y(CBB_F,:);
assist.chA.igm.Sky_F.y = assist.chA.flynn_mat.y(Sky_F,:);
assist.chA.igm.HBB_R.y = assist.chA.flynn_mat.y(HBB_R,:);
assist.chA.igm.CBB_R.y = assist.chA.flynn_mat.y(CBB_R,:);
assist.chA.igm.Sky_R.y = assist.chA.flynn_mat.y(Sky_R,:);

assist.chA.cxs.HBB_F = RawIgm2RawSpc(assist.chA.igm.HBB_F);
assist.chA.cxs.HBB_R = RawIgm2RawSpc(assist.chA.igm.HBB_R);
assist.chA.cxs.CBB_F = RawIgm2RawSpc(assist.chA.igm.CBB_F);
assist.chA.cxs.CBB_R = RawIgm2RawSpc(assist.chA.igm.CBB_R);
assist.chA.cxs.Sky_F = RawIgm2RawSpc(assist.chA.igm.Sky_F);
assist.chA.cxs.Sky_R = RawIgm2RawSpc(assist.chA.igm.Sky_R);

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
assist.chA.coad.HBB_F = CoaddData(assist.chA.cxs.HBB_F);
assist.chA.coad.HBB_R = CoaddData(assist.chA.cxs.HBB_R);
assist.chA.coad.CBB_F = CoaddData(assist.chA.cxs.CBB_F);
assist.chA.coad.CBB_R = CoaddData(assist.chA.cxs.CBB_R);

assist.chA.uvs.HBB_F = VarianceData(assist.chA.cxs.HBB_F);
assist.chA.uvs.HBB_R = VarianceData(assist.chA.cxs.HBB_R);
assist.chA.uvs.CBB_F = VarianceData(assist.chA.cxs.CBB_F);
assist.chA.uvs.CBB_R = VarianceData(assist.chA.cxs.CBB_R);

%Determine radiance calibration for mono-directional scans
T_hot = mean(assist.chA.HBB_F);
T_cold = mean(assist.chA.CBB_F);
assist.chA.cal_F = CreateCalibrationFromCXS(assist.chA.coad.HBB_F,  273.15+T_hot, assist.chA.coad.CBB_F,  273.15+T_cold);
T_hot = mean(assist.chA.HBB_R);
T_cold = mean(assist.chA.CBB_R);
assist.chA.cal_R = CreateCalibrationFromCXS(assist.chA.coad.HBB_R,  273.15+T_hot, assist.chA.coad.CBB_R,  273.15+T_cold);

% Apply radiance calibration to BB UVS
assist.chA.csv.HBB_F = RadiometricCalibration(assist.chA.cxs.HBB_F, assist.chA.cal_F);
assist.chA.csv.HBB_R = RadiometricCalibration(assist.chA.cxs.HBB_R, assist.chA.cal_R);
assist.chA.csv.CBB_F = RadiometricCalibration(assist.chA.cxs.CBB_F, assist.chA.cal_F);
assist.chA.csv.CBB_R = RadiometricCalibration(assist.chA.cxs.CBB_R, assist.chA.cal_R);

%Apply radiance calibration to sky spectra
%[RadianceSpc] = RadiometricCalibration(RawSpc, CalSet)
assist.chA.rad.Sky_F = RadiometricCalibration(assist.chA.cxs.Sky_F, assist.chA.cal_F);
assist.chA.rad.Sky_R = RadiometricCalibration(assist.chA.cxs.Sky_R, assist.chA.cal_R);

% downsample to N mono-directional scans
N = 6; % downsample over 6 
assist.chA.mrad.Sky_F.x = assist.chA.rad.Sky_F.x;
assist.chA.mrad.Sky_F.y = downsample(assist.chA.rad.Sky_F.y,N);
assist.chA.mrad.Sky_R.x = assist.chA.rad.Sky_R.x;
assist.chA.mrad.Sky_R.y = downsample(assist.chA.rad.Sky_R.y,N);
% downvariance over N mono-directional scans
assist.chA.csv.Sky_F.x = assist.chA.rad.Sky_F.x;
assist.chA.csv.Sky_F.y = downvariance(assist.chA.rad.Sky_F.y,N);
assist.chA.csv.Sky_R.x = assist.chA.rad.Sky_R.x;
assist.chA.csv.Sky_R.y = downvariance(assist.chA.rad.Sky_R.y,N);

%Compute scan directional averages
assist.chA.mrad.Sky.x = assist.chA.mrad.Sky_F.x;
assist.chA.mrad.Sky.y = (assist.chA.mrad.Sky_F.y+assist.chA.mrad.Sky_R.y)./2;
assist.chA.good_wn = assist.chA.mrad.Sky.x>500 &assist.chA.mrad.Sky.x<1800;

%Compute brightness temperatures
assist.chA.mrad.Sky.x = assist.chA.mrad.Sky_F.x;
assist.chA.mrad.Sky.y = (assist.chA.mrad.Sky_F.y+assist.chA.mrad.Sky_R.y)./2;
assist.chA.good_wn = assist.chA.mrad.Sky.x>500 &assist.chA.mrad.Sky.x<1800;


%%
assist.downtime = downsample(assist.time(Sky_F|Sky_R),12);
%%
figure;  ax(1) = subplot(3,1,1); 
plot(assist.chA.rad.Sky_F.x, assist.chA.rad.Sky_F.y,'-');
title('Ch A, forward scans')
ax(2) = subplot(3,1,2); 
plot(assist.chA.mrad.Sky_F.x, assist.chA.mrad.Sky_F.y,'-');
ax(3) = subplot(3,1,3); 
plot(assist.chA.mrad.Sky.x, assist.chA.mrad.Sky.y,'-');

linkaxes(ax,'xy');zoom('on')
xlim([500,1800]);
ylim('auto');
%%

disp('Done with ch A, starting ch B')
% Now do ChB 

V = double([assist.chB.edgar_mat.mainHeaderBlock.date.year,assist.chB.edgar_mat.mainHeaderBlock.date.month,...
   assist.chB.edgar_mat.mainHeaderBlock.date.day,assist.chB.edgar_mat.mainHeaderBlock.date.hours,...
   assist.chB.edgar_mat.mainHeaderBlock.date.minutes,assist.chB.edgar_mat.mainHeaderBlock.date.seconds]);
nbPoints = assist.chB.edgar_mat.mainHeaderBlock.nbPoints;
assist.chB.flynn_mat.x = linspace(assist.chB.edgar_mat.mainHeaderBlock.firstX, (assist.chB.edgar_mat.mainHeaderBlock.lastX-1), double(nbPoints)); 
assist.chB.flynn_mat.base_time = datenum(V);
subs = length(assist.chB.edgar_mat.subfiles);
for s = subs:-1:1
assist.chB.flynn_mat.time(s) = assist.chB.flynn_mat.base_time +  double(assist.chB.edgar_mat.subfiles{s}.subfileHeader.subStartingZ)./(24*60*60);
assist.chB.flynn_mat.flags(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.subFlags;
assist.chB.flynn_mat.coads(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.nbCoaddedScans;
assist.chB.flynn_mat.subIndex(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.subIndex;
assist.chB.flynn_mat.HBBRawTemp(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.subHBBRawTemp;
assist.chB.flynn_mat.CBBRawTemp(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.subCBBRawTemp;
if isfield(assist.chB.edgar_mat.subfiles{s}.subfileHeader,'zpdLocation')
assist.chB.flynn_mat.zpdLocation(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.zpdLocation;
end
if isfield(assist.chB.edgar_mat.subfiles{s}.subfileHeader,'zpdValue')
assist.chB.flynn_mat.zpdValue(s) = assist.chB.edgar_mat.subfiles{s}.subfileHeader.zpdValue;
end
assist.chB.flynn_mat.y(s,:) = assist.chB.edgar_mat.subfiles{s}.subfileData;
end
assist.chB.flynn_mat.flags = uint8(assist.chB.flynn_mat.flags);
HBB_F = bitget(assist.chB.flynn_mat.flags,2)&bitget(assist.chB.flynn_mat.flags,5);
HBB_R = bitget(assist.chB.flynn_mat.flags,3)&bitget(assist.chB.flynn_mat.flags,5);
CBB_F = bitget(assist.chB.flynn_mat.flags,2)&bitget(assist.chB.flynn_mat.flags,6);
CBB_R = bitget(assist.chB.flynn_mat.flags,3)&bitget(assist.chB.flynn_mat.flags,6);
Sky_F = bitget(assist.chB.flynn_mat.flags,2)& ~(bitget(assist.chB.flynn_mat.flags,5)|bitget(assist.chB.flynn_mat.flags,6));
Sky_R = bitget(assist.chB.flynn_mat.flags,3)& ~(bitget(assist.chB.flynn_mat.flags,5)|bitget(assist.chB.flynn_mat.flags,6));

assist.chB.HBB_F = annot.HBB_C(HBB_F);
assist.chB.HBB_R = annot.HBB_C(HBB_R);
assist.chB.CBB_F = annot.CBB_C(CBB_F);
assist.chB.CBB_R = annot.CBB_C(CBB_R);

assist.chB.igm.HBB_F.x = assist.chB.flynn_mat.x;
assist.chB.igm.CBB_F.x= assist.chB.flynn_mat.x;
assist.chB.igm.Sky_F.x= assist.chB.flynn_mat.x;
assist.chB.igm.HBB_R.x= assist.chB.flynn_mat.x;
assist.chB.igm.CBB_R.x= assist.chB.flynn_mat.x;
assist.chB.igm.Sky_R.x= assist.chB.flynn_mat.x;

assist.chB.igm.HBB_F.y = assist.chB.flynn_mat.y(HBB_F,:);
assist.chB.igm.CBB_F.y = assist.chB.flynn_mat.y(CBB_F,:);
assist.chB.igm.Sky_F.y = assist.chB.flynn_mat.y(Sky_F,:);
assist.chB.igm.HBB_R.y = assist.chB.flynn_mat.y(HBB_R,:);
assist.chB.igm.CBB_R.y = assist.chB.flynn_mat.y(CBB_R,:);
assist.chB.igm.Sky_R.y = assist.chB.flynn_mat.y(Sky_R,:);

assist.chB.cxs.HBB_F = RawIgm2RawSpc(assist.chB.igm.HBB_F);
assist.chB.cxs.HBB_R = RawIgm2RawSpc(assist.chB.igm.HBB_R);
assist.chB.cxs.CBB_F = RawIgm2RawSpc(assist.chB.igm.CBB_F);
assist.chB.cxs.CBB_R = RawIgm2RawSpc(assist.chB.igm.CBB_R);
assist.chB.cxs.Sky_F = RawIgm2RawSpc(assist.chB.igm.Sky_F);
assist.chB.cxs.Sky_R = RawIgm2RawSpc(assist.chB.igm.Sky_R);

% Coad the mono-directional BB spectra to improve robustness of calibration
% Compute uncalibrated variance spectra of BB mono-scans
assist.chB.coad.HBB_F = CoaddData(assist.chB.cxs.HBB_F);
assist.chB.coad.HBB_R = CoaddData(assist.chB.cxs.HBB_R);
assist.chB.coad.CBB_F = CoaddData(assist.chB.cxs.CBB_F);
assist.chB.coad.CBB_R = CoaddData(assist.chB.cxs.CBB_R);

assist.chB.uvs.HBB_F = VarianceData(assist.chB.cxs.HBB_F);
assist.chB.uvs.HBB_R = VarianceData(assist.chB.cxs.HBB_R);
assist.chB.uvs.CBB_F = VarianceData(assist.chB.cxs.CBB_F);
assist.chB.uvs.CBB_R = VarianceData(assist.chB.cxs.CBB_R);

%Determine radiance calibration for mono-directional scans
T_hot = mean(assist.chB.HBB_F);
T_cold = mean(assist.chB.CBB_F);
assist.chB.cal_F = CreateCalibrationFromCXS(assist.chB.coad.HBB_F,  273.15+T_hot, assist.chB.coad.CBB_F,  273.15+T_cold);
T_hot = mean(assist.chB.HBB_R);
T_cold = mean(assist.chB.CBB_R);
assist.chB.cal_R = CreateCalibrationFromCXS(assist.chB.coad.HBB_R,  273.15+T_hot, assist.chB.coad.CBB_R,  273.15+T_cold);

%Apply radiance calibration to cxs spectra
%[RadianceSpc] = RadiometricCalibration(RawSpc, CalSet)
assist.chB.rad.Sky_F = RadiometricCalibration(assist.chB.cxs.Sky_F, assist.chB.cal_F);
assist.chB.rad.Sky_R = RadiometricCalibration(assist.chB.cxs.Sky_R, assist.chB.cal_R);

% downsample to N mono-directional scans
N = 6; % downsample over 6 
assist.chB.mrad.Sky_F.x = assist.chB.rad.Sky_F.x;
assist.chB.mrad.Sky_F.y = downsample(assist.chB.rad.Sky_F.y,N);
assist.chB.mrad.Sky_R.x = assist.chB.rad.Sky_R.x;
assist.chB.mrad.Sky_R.y = downsample(assist.chB.rad.Sky_R.y,N);
% downvariance over N mono-directional scans
assist.chB.csv.Sky_F.x = assist.chB.rad.Sky_F.x;
assist.chB.csv.Sky_F.y = downvariance(assist.chB.rad.Sky_F.y,N);
assist.chB.csv.Sky_R.x = assist.chB.rad.Sky_R.x;
assist.chB.csv.Sky_R.y = downvariance(assist.chB.rad.Sky_R.y,N);
% Apply radiance calibration to BB UVS
assist.chB.csv.HBB_F = RadiometricCalibration(assist.chB.cxs.HBB_F, assist.chB.cal_F);
assist.chB.csv.HBB_R = RadiometricCalibration(assist.chB.cxs.HBB_R, assist.chB.cal_R);
assist.chB.csv.CBB_F = RadiometricCalibration(assist.chB.cxs.CBB_F, assist.chB.cal_F);
assist.chB.csv.CBB_R = RadiometricCalibration(assist.chB.cxs.CBB_R, assist.chB.cal_R);
assist.chB.mrad.Sky.x = assist.chB.mrad.Sky_F.x;
assist.chB.mrad.Sky.y = (assist.chB.mrad.Sky_F.y+assist.chB.mrad.Sky_R.y)./2;
assist.chB.good_wn = assist.chB.mrad.Sky.x>1700 & assist.chB.mrad.Sky.x<3000;

figure;  ax(1) = subplot(3,1,1); 
plot(assist.chB.rad.Sky_F.x, assist.chB.rad.Sky_F.y,'-');
title('Ch B, forward scans')
ax(2) = subplot(3,1,2); 
plot(assist.chB.mrad.Sky_F.x, assist.chB.mrad.Sky_F.y,'-');
ax(3) = subplot(3,1,3); 
plot(assist.chB.mrad.Sky.x, assist.chB.mrad.Sky.y,'-');

linkaxes(ax,'xy');zoom('on')
xlim([1800,3000]);
ylim('auto');
%%
