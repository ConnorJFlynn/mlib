function assist = assist_annew_10(pname)% ASSIST annew
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
while ~exist('pname','var')||~exist(pname, 'dir')
   [pname] = getdir('assist');
end
emis  = loadinto(['C:\case_studies\assist\compares\validationConnorNov2011\RAW\R1\LRT_BB_Emiss_FullRes.mat']);
emis = repack_edgar(emis);
% emis.y = ones(size(emis.x));
ann_ls = dir([pname, '*ann*.csv']);
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
   if ~exist('assist','var')||~isfield(assist,'chA')
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

% downsample to N mono-directional scans
N = 6; % downsample over 6 
%
[rows,cols]= size(assist.time);
retime = zeros([2.*N.*rows,cols./(2.*N)]);
retime(:) = assist.time;
%
   % retime = 
down.time = retime(1,:);
down.isSky = downsample(assist.logi.Sky,2.*N)>0;
down.isHBB = downsample(assist.logi.H,2.*N)>0;
down.isABB = downsample(assist.logi.A,2.*N)>0;
down.Sky_ii = find(down.isSky);
down.HBB_ii = find(down.isHBB);
down.ABB_ii = find(down.isABB);
down.HBB_F = downsample(assist.HBB_C(logi.F),N);
down.HBB_R = downsample(assist.HBB_C(logi.R),N);
down.ABB_F = downsample(assist.ABB_C(logi.F),N);
down.ABB_R = downsample(assist.ABB_C(logi.R),N);

down.chA.x = assist.chA.x;
down.chA.F = downsample(assist.chA.y(assist.logi.F,:),N);
down.chA.R = downsample(assist.chA.y(assist.logi.R,:),N);

down.chB.x = assist.chB.x;
down.chB.F = downsample(assist.chB.y(assist.logi.F,:),N);
down.chB.R = downsample(assist.chB.y(assist.logi.R,:),N);

if sum(down.isHBB)>1
   chA_F_unflipped = mean(down.chA.F(down.isHBB,:));
   chA_R_unflipped = mean(down.chA.R(down.isHBB,:));
   chB_F_unflipped = mean(down.chB.F(down.isHBB,:));
   chB_R_unflipped = mean(down.chB.R(down.isHBB,:));
else
   chA_F_unflipped =  down.chA.F(down.isHBB,:);
   chA_R_unflipped =  down.chA.R(down.isHBB,:);
   chB_F_unflipped =  down.chB.F(down.isHBB,:);
   chB_R_unflipped =  down.chB.R(down.isHBB,:);
end
%%
[AFmaxv,AFmaxi] = max(abs(chA_F_unflipped));
chA_zpd_shift_F = AFmaxi-length(down.chA.x)./2 -1;
[ARmaxv,ARmaxi] = max(abs(chA_R_unflipped));
chA_zpd_shift_R = ARmaxi-length(down.chA.x)./2 -1;

[BFmaxv,BFmaxi] = max(abs(chB_F_unflipped));
chB_zpd_shift_F = BFmaxi-length(down.chB.x)./2 -1;
[BRmaxv,BRmaxi] = max(abs(chB_R_unflipped));
chB_zpd_shift_R = BRmaxi-length(down.chB.x)./2 -1;

maxv = max(abs([AFmaxv, ARmaxv, BFmaxv, BRmaxv]));

% figure
% s(1) = subplot(2,2,1);
% plot(down.chA.x, down.chA.F(down.isHBB,:),'.-r',[down.chA.x(AFmaxi),down.chA.x(AFmaxi)],[-maxv,maxv],'r--');
% title(['ChA (MCT), HBB, Forward, max(abs)=',num2str(chA_zpd_shift_F)]);
% grid('on');
% s(2) = subplot(2,2,3);
% plot(down.chA.x, down.chA.R(down.isHBB,:),'.-b',[down.chA.x(ARmaxi),down.chA.x(ARmaxi)],[-maxv,maxv],'r--');
% title(['ChA (MCT), HBB, Reverse, max(abs)=',num2str(chA_zpd_shift_R)]);
% grid('on');
% s(3) = subplot(2,2,2);
% 
% plot(down.chB.x, down.chB.F(down.isHBB,:),'.-g',[down.chB.x(BFmaxi),down.chB.x(BFmaxi)],[-maxv,maxv],'r--');
% title(['ChB (InSb), HBB, Forward, max(abs)=',num2str(chB_zpd_shift_F)]);
% grid('on');
% s(4) = subplot(2,2,4);
% plot(down.chB.x, down.chB.R(down.isHBB,:),'.-c',[down.chB.x(BRmaxi),down.chB.x(BRmaxi)],[-maxv,maxv],'r--');
% title(['ChB (InSb), HBB, Reverse, max(abs)=',num2str(chB_zpd_shift_R)]);
% grid('on');
% 
% linkaxes(s,'xy')
%%
% chA_zpd_shift_F = find_zpd_xcorr(unflipped);


down.chA.F =  sideshift(down.chA.x, down.chA.F, chA_zpd_shift_F);
down.chA.F = fftshift(down.chA.F,dim_n);
down.chA.R =  sideshift(down.chA.x, down.chA.R, chA_zpd_shift_R);
down.chA.R = fftshift(down.chA.R,dim_n);

% down.chA.F = NLC_Grif(down.chA.x, down.chA.F, assist.chA.laser_wl);
% down.chA.R = NLC_Grif(down.chA.x, down.chA.R, assist.chA.laser_wl);

down.chB.F =  sideshift(down.chB.x, down.chB.F, chB_zpd_shift_F);
down.chB.F = fftshift(down.chB.F,dim_n);
down.chB.R =  sideshift(down.chB.x, down.chB.R, chB_zpd_shift_R);
down.chB.R = fftshift(down.chB.R,dim_n);

%%
% figure
% s(1) = subplot(2,2,1);
% plot(down.chA.x, down.chA.F(down.isHBB,:),'.-r');
% title(['ChA (MCT), HBB, Forward, max(abs)=',num2str(chA_zpd_shift_F)]);
% grid('on');
% s(2) = subplot(2,2,3);
% plot(down.chA.x, down.chA.R(down.isHBB,:),'.-b');
% title(['ChA (MCT), HBB, Reverse, max(abs)=',num2str(chA_zpd_shift_R)]);
% grid('on');
% s(3) = subplot(2,2,2);
% 
% plot(down.chB.x, down.chB.F(down.isHBB,:),'.-g');
% title(['ChB (InSb), HBB, Forward, max(abs)=',num2str(chB_zpd_shift_F)]);
% grid('on');
% s(4) = subplot(2,2,4);
% plot(down.chB.x, down.chB.R(down.isHBB,:),'.-c');
% title(['ChB (InSb), HBB, Reverse, max(abs)=',num2str(chB_zpd_shift_R)]);
% grid('on');
% 
% linkaxes(s,'xy')
%%

[down.chA.cxs.x,down.chA.cxs.F] = RawIgm2RawSpc(down.chA.x,down.chA.F,assist.chA.laser_wl);
[down.chA.cxs.x,down.chA.cxs.R] = RawIgm2RawSpc(down.chA.x,down.chA.R,assist.chA.laser_wl);
[down.chB.cxs.x,down.chB.cxs.F] = RawIgm2RawSpc(down.chB.x,down.chB.F,assist.chB.laser_wl);
[down.chB.cxs.x,down.chB.cxs.R] = RawIgm2RawSpc(down.chB.x,down.chB.R,assist.chB.laser_wl);


[pname_A] = getdir('assist_int','Select location of Andre''s results');
% Sky_cal_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.calibrated.preFFOV.real.mat'];
% Sky_cal_edgar = loadinto(Sky_cal_file);
% Sky_cal_pre  = repack_edgar(Sky_cal_edgar); 
%%

% S1_file = [pname_A, '20110324_051618_chB_SKY1.coad.mrad.mat.uncalibrated.real.mat']
% S1_edgar = loadinto(S1_file);
% S1  = repack_edgar(S1_edgar);
% % Uncalibrated spectra confirmed to 6 digits, except for factor of 1000
%  figure; s(1) = subplot(2,1,1);
%  plot(down.chB.cxs.x,[real((down.chB.cxs.F(down.Sky_ii(1),:)));1.*S1.y(1,:)],'-');
%  legend('mine','yours');
%  s(2) = subplot(2,1,2); 
%  plot(down.chB.cxs.x,[real((down.chB.cxs.F(down.Sky_ii(1),:)))-1.*S1.y(1,:)],'-');
%  linkaxes(s,'x')
 %%
 
%   figure; plot(down.chA.cxs.x,real(mean(down.chA.cxs.F(down.isABB,:)))-1000.*CA.y,'r-');
% figure; plot(down.chA.cxs.x,[real(down.chA.cxs.F(down.Sky_ii(1),:))-S1.y(1,:)],'r-');
%%

% #Parameters used to calculate the NLC for channel A (MCT)
% From Connor's NLC fit of SBS, Feb LN2 bath
% nlc.IHLAB = -7.820867e+004;
% nlc.ICLAB = 8.707437e+004; % Big difference?
% nlc.a2 = 5.501874e-008;

%From Andre
nlc.a2 = (4.033475e-008);
nlc.IHLAB=(-7.736925e004);
nlc.ICLAB=(3.831425e003);
nlc.ICLAB = 8.707437e+004;
nlc.IHLAB = -7.820867e+004;
nlc.ICLAB = 8.707437e+004; % Big difference?
nlc.a2 = 5.501874e-008;
[down.chA.cxs,down.chA.nlc] = NLC_SSEC_down(down,nlc);
% assist = rad_cal_def_M(assist, emis, T_ref)
down = rad_cal_def_down(down, emis, 3.5);
% assist.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist.chA.cal_F);
% assist.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist.chA.cal_R);
down.chA.spc.F = RadiometricCalibration_4(down.chA.cxs.F, down.chA.cal_F);
down.chA.spc.R = RadiometricCalibration_4(down.chA.cxs.R, down.chA.cal_R);
down.chB.spc.F = RadiometricCalibration_4(down.chB.cxs.F, down.chB.cal_F);
down.chB.spc.R = RadiometricCalibration_4(down.chB.cxs.R, down.chB.cal_R);
%%
down.chA.spc_.F = RadiometricCalibration_4(down.chA.cxs.F, down.chA.cal_F_);
down.chA.spc_.R = RadiometricCalibration_4(down.chA.cxs.R, down.chA.cal_R_);
down.chB.spc_.F = RadiometricCalibration_4(down.chB.cxs.F, down.chB.cal_F_);
down.chB.spc_.R = RadiometricCalibration_4(down.chB.cxs.R, down.chB.cal_R_);

down.chA.spc__.F = RadiometricCalibration_4(down.chA.cxs.F, down.chA.cal_F__);
down.chA.spc__.R = RadiometricCalibration_4(down.chA.cxs.R, down.chA.cal_R__);
down.chB.spc__.F = RadiometricCalibration_4(down.chB.cxs.F, down.chB.cal_F__);
down.chB.spc__.R = RadiometricCalibration_4(down.chB.cxs.R, down.chB.cal_R__);
%%
%

% CH_file = getfullname_('*.mat','assist_int', 'Select Andre''s file');

%%

% [pname_A,~,~] = fileparts(CH_file);
CH_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.CH.real..mat']
CH_edgar = loadinto(CH_file);
CH  = repack_edgar(CH_edgar);

CH_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.CH.ima..mat']
CH_edgar = loadinto(CH_file);
CH_  = repack_edgar(CH_edgar);

CA_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.CA.real..mat']
CA_edgar = loadinto(CA_file);
CA  = repack_edgar(CA_edgar);

CA_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.CA.ima..mat']
CA_edgar = loadinto(CA_file);
CA_  = repack_edgar(CA_edgar);
%%
% 
% S1_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.uncalibrated.real.mat']
% S1_edgar = loadinto(S1_file);
% S1  = repack_edgar(S1_edgar);
%%
% Here we match Hot Scene complex spectra
figure; 
s(1) = subplot(2,1,1);
plot(down.chA.cxs.x,real(mean(down.chA.cxs.F([2 9],:)))-[CH.y(1,:)], '-');
 legend('Mine','Andre');
 title('real C_H') 
s(2) = subplot(2,1,2);
plot(down.chA.cxs.x,imag(mean(down.chA.cxs.F([2 9],:)))- [CH_.y(1,:)], '-');
 legend('Mine','Andre');
 title('imag C_H') 
%%
%%
% Here we match Ambient BB Scene complex spectra
figure; 
s(1) = subplot(2,1,1);
plot(down.chA.cxs.x,real(mean(down.chA.cxs.F([1 10],:)))-[CA.y(1,:)], '-');
 legend('Mine','Andre');
 title('real C_A') 
s(2) = subplot(2,1,2);
plot(down.chA.cxs.x,imag(mean(down.chA.cxs.F([1 10],:)))-[CA_.y(1,:)], '-');
 legend('Mine','Andre');
 title('imag C_A') 
 linkaxes(s,'x');
%%
CA.y = CA.y + 1i*CA_.y;
CH.y = CH.y + 1i*CH_.y;


%%
LA_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.LA.real..mat']
LA_edgar_real = loadinto(LA_file);
LA  = repack_edgar(LA_edgar_real);

LA_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.LA.ima..mat']
LA_edgar_imag = loadinto(LA_file);
LA_imag  = repack_edgar(LA_edgar_imag);

LH_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.LH.real..mat']
LH_edgar_real = loadinto(LH_file);
LH  = repack_edgar(LH_edgar_real);

LH_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.LH.ima..mat']
LH_edgar_imag = loadinto(LH_file);
LH_imag  = repack_edgar(LH_edgar_imag);

T_amb = 273.82399;
T_hot = 333.15;
my_LA = Blackbody(LH.x, T_amb)./1e6;
my_LH = Blackbody(LH.x, T_hot)./1e6;

% 
% figure(50); 
% ss(1) = subplot(2,1,1);
% plot(LA_real.x, [LA_real.y; LH_real.y],'-',...a
%     LA_real.x, [my_LA; my_LH], '.');
% title('real L_A and L_H');
% legend('L_A','L_H', 'My LA','My LH');
% ss(2) = subplot(2,1,2);
% plot(LA_real.x, [(LA_real.y-my_LA)./my_LA; (LH_real.y-my_LH)./my_LH],'-');
% title('L_A and L_H differences');
% legend('L_A - myLA','L_H-myLH');
% 
% linkaxes(ss,'x')



%
%%
% Gains_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.gains.mat'];
% Gains_edgar = loadinto(Gains_file);
% Gains  = repack_edgar(Gains_edgar);
% 
% Offset_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat.offsets.mat'];
% Offset_edgar = loadinto(Offset_file);
% Offset  = repack_edgar(Offset_edgar);
% 
% 
% wn_1000 = floor(interp1(CA.x, [1:length(CA.x)], 1000))
% offs = (LA.y.*CH.y-LH.y.*CA.y)./(CH.y-CA.y);
% offs(wn_1000)
% down.chA.cal_F__.Offset_ru(wn_1000)
%  Offset.y(1,wn_1000)
% 
% gain = (LH.y-LA.y)./(CH.y-CA.y);
% 1./gain(wn_1000)
% down.chA.cal_F__.Resp(wn_1000)
% 1./Gains.y(1,wn_1000)
%%

% figure; plot(down.chA.cal_F.x,[real(1./down.chA.cal_F.Resp); imag(1./down.chA.cal_F.Resp)],'-',...
%   Gains.x, 1./Gains.y(1,:),'.' ); 
% xlim([800,1700]);
% legend('my real resp','my imag resp','1/gain')
% %%
% figure; plot(down.chA.cxs.x,[real(down.chA.cal_F__.Resp); imag(down.chA.cal_F__.Resp)],'-'); 
% xlim([800,1700]);
% legend('my real(Resp)','my imag(Resp)');
% 
% %%
% figure; plot(Gains.x, Gains.y(1,:),'.',Offset.x,Offset.y(1,:),'o');
% xlim([800,1700]);
% legend('Gains','Offset')
%%
S1_mrad_file = [pname_A, '20110324_051618_chA_SKY1.coad.mrad.mat']
S1_mrad_edgar = loadinto(S1_mrad_file);
S1_mrad  = repack_edgar(S1_mrad_edgar);

%%

%%
% assist_0.chA.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.F,:), assist_0.chA.cal_F);
% assist_0.chA.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chA.cxs.y(assist.logi.R,:), assist_0.chA.cal_R);
%%
% Half-angle FOV to be used for FFOV correction.
% 0.0225; mrad
%%
% figure; fx(1) = subplot(2,1,1); plot(S1.x, real(down.chA.spc_.F(1:3,:)),'-');
% grid('on');
% fx(2) = subplot(2,1,2); plot(down.chA.cxs.x, real([down.chA.spc.F(3,:);down.chA.spc_.F(3,:);down.chA.spc__.F(3,:)]),'-');
% grid('on');
% legend('both','emis','none')
% linkaxes(fx,'xy')
%%

%%
% in = find(assist.logi.Sky_F);
[Cnu_,c2 ,c4] = ApplyFFOVCorr(down.chA.cxs.x, down.chA.spc.F(down.isSky,:),0.0225);
%%
% [rad,wnp,deltaC1,deltaC2] = ffovcmr(nu,Cm,fovHalfAngle,flagFFOVerr,XMAX,WNB); 
% figure; plot(down.chA.cxs.x, down.chA.spc.y(assist.logi.Sky_F,:),'-')

%%

% assist.chB.spc.y(assist.logi.F,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.F,:), assist.chB.cal_F);
% assist.chB.spc.y(assist.logi.R,:) = RadiometricCalibration_4(assist.chB.cxs.y(assist.logi.R,:), assist.chB.cal_R);

%%
pname_A_proc = [pname_A,'\..\..\PRO\R1\'];
% pname_A_proc = ['C:\case_studies\assist\compares\validationConnorNov2011_10_CLEAN_DEBUG_7\PRO\R1\'];
A_file = [pname_A_proc, '20110324_051618_chA_RESP_REAL_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
A_edgar = loadinto(A_file);
Andre  = repack_edgar(A_edgar);
B_file = [pname_A_proc, '20110324_051618_chA_RESP_IMA_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
B_edgar = loadinto(B_file);
Bndre  = repack_edgar(B_edgar);
figure; 
ss(1) = subplot(2,1,1);
plot(Andre.x, Andre.y(1,:),'r.',down.chA.cxs.x, real(down.chA.cal_F__.Resp),'b.');
title('Real component of Responsivity');
legend('1./yours','mine')
% plot(Andre.x, 1./Andre.y(1,:),'r.');
ss(2) = subplot(2,1,2);
plot(Bndre.x, (Bndre.y(1,:)),'r.',down.chA.cxs.x, imag(down.chA.cal_F__.Resp),'b.');
% plot(Bndre.x, 1./Bndre.y(1,:),'r.');
legend('1e8.*yours','mine')
title('Imag component of Responsivity')
linkaxes(ss,'x');
xlim([800,1700]);
%%
A_file = [pname_A_proc, '20110324_051618_chB_RESP_REAL_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
A_edgar = loadinto(A_file);
Andre  = repack_edgar(A_edgar);
B_file = [pname_A_proc, '20110324_051618_chB_RESP_IMA_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
B_edgar = loadinto(B_file);
Bndre  = repack_edgar(B_edgar);
figure; 
ss(1) = subplot(2,1,1);
plot(Andre.x, Andre.y(1,:),'ro',down.chB.cxs.x, real(down.chB.cal_F__.Resp),'b.');
% plot(down.chB.cxs.x, real(down.chB.cal_F__.Resp),'b.');
title('Real component of Responsivity');
legend('yours','mine')
% plot(Andre.x, 1./Andre.y(1,:),'r.');
ss(2) = subplot(2,1,2);
plot(Bndre.x, (Bndre.y(1,:)),'ro',down.chB.cxs.x, imag(down.chB.cal_F__.Resp),'b.');
% plot(down.chB.cxs.x, imag(down.chB.cal_F__.Resp),'b.');
% plot(Bndre.x, 1./Bndre.y(1,:),'r.');
legend('yours','mine')
title('Imag component of Responsivity')
linkaxes(ss,'x');
xlim([1800,2700]);
%%

A_file = [pname_A_proc, '20110324_051618_chA_OFF_REAL_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
A_edgar = loadinto(A_file);
Andre  = repack_edgar(A_edgar);
B_file = [pname_A_proc, '20110324_051618_chA_OFF_IMA_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
B_edgar = loadinto(B_file);
Bndre  = repack_edgar(B_edgar);
figure; 
ss(1) = subplot(2,1,1);
plot(down.chA.cxs.x, real(down.chA.cal_F__.Offset_ru),'b.',Andre.x, Andre.y(1,:),'-ro');
title('Real component of Offset');
legend('mine','yours')
% plot(Andre.x, 1./Andre.y(1,:),'r.');
ss(2) = subplot(2,1,2);
plot(down.chA.cxs.x, imag(down.chA.cal_F__.Offset_ru),'b.',Bndre.x, (Bndre.y(1,:)),'or-');
% plot(Bndre.x, 1./Bndre.y(1,:),'r.');
legend('mine','yours')
title('Imag component of Offset')
linkaxes(ss,'x');
xlim([800,1700]);
%%
A_file = [pname_A_proc, '20110324_051618_chB_OFF_REAL_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
A_edgar = loadinto(A_file);
Andre  = repack_edgar(A_edgar);
B_file = [pname_A_proc, '20110324_051618_chB_OFF_IMA_SKY.coad.mrad.pro.merged.degraded.truncated.mat']
B_edgar = loadinto(B_file);
Bndre  = repack_edgar(B_edgar);
figure; 
ss(1) = subplot(2,1,1);
plot(down.chB.cxs.x, real(down.chB.cal_F__.Offset_ru),'b.',Andre.x, Andre.y(1,:),'-ro');
title('Real component of Offset');
legend('mine','yours')
% plot(Andre.x, 1./Andre.y(1,:),'r.');
ss(2) = subplot(2,1,2);
plot(down.chB.cxs.x, imag(down.chB.cal_F__.Offset_ru),'b.',Bndre.x, (Bndre.y(1,:)),'or-');
% plot(Bndre.x, 1./Bndre.y(1,:),'r.');
legend('mine','yours')
title('Imag component of Offset')
linkaxes(ss,'x');
xlim([800,1700]);
%%
% down.chA.T_bt = BrightnessTemperature(down.chA.cxs.x, mean([real(down.chA.spc.F(3,:));real(down.chA.spc.R(3,:))]));
down.chA.T_bt = BrightnessTemperature(down.chA.cxs.x, mean([real(down.chA.spc.F(3,:));real(down.chA.spc.R(3,:))]));
BT_file = [pname_A_proc, '20110324_051618_chA_BTemp_SKY.coad.mrad.coad.merged.truncated.mat']
BT_edgar = loadinto(BT_file);
BT  = repack_edgar(BT_edgar);
BTb_file = [pname_A_proc, '20110324_051618_chA_BTemp_SKY.coad.mrad.coad.merged.degraded.truncated.mat']
BTb_edgar = loadinto(BTb_file);
BTb  = repack_edgar(BTb_edgar);
figure; plot(down.chA.cxs.x, down.chA.T_bt-273.15, 'bx',BT.x,BT.y(1,:)-273.15,'g.',BTb.x,BTb.y(1,:)-273.15,'ro')
%%
[CHinBT, BtinLH] = nearest(CH.x, BT.x);


%%
A_file = [pname_A_proc, '20110324_051618_chB_SKY.coad.mrad.coad.merged.truncated.mat']
A_edgar = loadinto(A_file);
Andre  = repack_edgar(A_edgar);
B_file = [pname_A_proc, '20110324_051618_chB_SKY.coad.mrad.coad.merged.degraded.truncated.mat']
B_edgar = loadinto(B_file);
Bndre  = repack_edgar(B_edgar);

figure; plot(down.chB.cxs.x,down.chB.spc.F(3,:), 'bx',Andre.x,Andre.y(1,:),'g.',Bndre.x,Bndre.y(1,:),'ro')

%%
ChAF_var  = (std(down.chA.spc.F(3:8,:))).^2
ChA_var = (std([down.chA.spc.R(3:8,:)])).^2
var_file = [pname_A_proc, '20110324_051618_chA_varRad_SKY.coad.mrad.coad.truncated.pro.mat']
var_edgar = loadinto(var_file);
varAndre  = repack_edgar(var_edgar);
 figure; plot(down.chA.cxs.x, ChA_var, '-',varAndre.x, varAndre.y,'-');
 title('variance of sky radiances');
 legend('mine','Andre''s');
 
 %%
  down.chA.T_bt = BrightnessTemperature(down.chA.cxs.x, mean([real(down.chA.spc.F(3,:));real(down.chA.spc.R(3,:))]));
 down.chB.T_bt = BrightnessTemperature(down.chB.cxs.x, mean([real(down.chB.spc.F(3,:));real(down.chB.spc.R(3,:))]));
 figure; 
 plot(down.chA.cxs.x,down.chA.T_bt,'-')
 grid('on'); zoom('on')
 
%%
% downsample to N mono-directional scans
%%
assist.degraded.chA.NEN1.F = downsample(sqrt(assist.down.chA.var.F),50,2).*(sqrt(15./120));
assist.degraded.chB.NEN1.F = downsample(sqrt(assist.down.chB.var.F),50,2).*(sqrt(15./120));
%% 

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
%%
infileA = getfullname_('*_chA_SKY.coad.mrad.coad.merged.truncated.mat','edgar_mat','Select ch A truncated mrad')
matA = repack_edgar(infileA); 
[mat_pname, mat_fname, ext] = fileparts(infileA);
[fname_a,fname_b]=strtok(mat_fname,'.');
infileB = strrep(infileA,'_chA_','_chB_');
matB = repack_edgar(infileB); 
%
%%
posA = assist.down.chA.mrad.x>=500&assist.down.chA.mrad.x<=max(matA.x);
posB = assist.down.chB.mrad.x>=min(matB.x)&assist.down.chB.mrad.x<=max(matB.x);
%

figure; 
plot(matA.x,matA.y(1,:), 'k.',...
   assist.down.chA.mrad.x(posA), assist.down.chA.mrad.F(assist.down.isSky,posA),'-ro',...
   matA.x,matA.y, 'k.',...
   assist.down.chB.mrad.x(posB), assist.down.chB.mrad.F(assist.down.isSky,posB),'bo',...
   matB.x,matB.y , 'g.')
legend('Andre','Flynn')
xlim([550,3000]);
title({fname_a;[fname_b(2:end) ext]},'interp','none');
xlabel('wavenumber [1/cm]');
ylabel('radiance [RU]');
xlim([800,1700]);
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

function assist = rad_cal_def_down(assist, emis, T_ref)

T_hot_F = mean(assist.HBB_F(assist.isHBB));
T_cold_F = mean(assist.ABB_F(assist.isABB));
T_hot_R = mean(assist.HBB_R(assist.isHBB));
T_cold_R = mean(assist.ABB_R(assist.isABB));

% The HBB temperature I am using is 333.15 K
% The ABB temperature I am using is 273.82399 K

if ~exist('T_ref','var')
    T_ref =273.15+T_cold_F ;
end

HBB_F.x = assist.chA.cxs.x;
HBB_F.y = mean(assist.chA.cxs.F(assist.isHBB,:),1);
HBB_R.x = assist.chA.cxs.x;
HBB_R.y = mean(assist.chA.cxs.R(assist.isHBB,:),1);
ABB_F.x = assist.chA.cxs.x;
ABB_F.y = mean(assist.chA.cxs.F(assist.isABB,:),1);
ABB_R.x = assist.chA.cxs.x;
ABB_R.y = mean(assist.chA.cxs.R(assist.isABB,:),1);



if ~exist('emis','var')
    assist.chA.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
    assist.chA.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
else
    [assist.chA.cal_F, assist.chA.cal_F_,assist.chA.cal_F__] = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_ref, emis);
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

HBB_F.x = assist.chB.cxs.x;
HBB_F.y = mean(assist.chB.cxs.F(assist.isHBB,:),1);
HBB_R.x = assist.chB.cxs.x;
HBB_R.y = mean(assist.chB.cxs.R(assist.isHBB,:),1);
ABB_F.x = assist.chB.cxs.x;
ABB_F.y = mean(assist.chB.cxs.F(assist.isABB,:),1);
ABB_R.x = assist.chB.cxs.x;
ABB_R.y = mean(assist.chB.cxs.R(assist.isABB,:),1);
if ~exist('emis','var')
    assist.chB.cal_F = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F);
    assist.chB.cal_R = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R);
else
  [assist.chB.cal_F, assist.chB.cal_F_,assist.chB.cal_F__] = CreateCalibrationFromCXS_(HBB_F,  273.15+T_hot_F, ABB_F,  273.15+T_cold_F,273.15+T_ref, emis);
  [assist.chB.cal_R, assist.chB.cal_R_, assist.chB.cal_R__] = CreateCalibrationFromCXS_(HBB_R,  273.15+T_hot_R, ABB_R,  273.15+T_cold_R,273.15+T_ref, emis);
end

return
