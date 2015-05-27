% ASSIST Check for Dave

% Read the Sky HBB and ABB bookends (combining into complex spectra)
% Then compute calibrated radiances.  
% Then read in Andre's processing and check agreement.
 Dave_dir = ['C:\case_studies\assist\compares\DaveT_ASSIST\DAVE\'];
 
 CH_ABB_real_nc = ancload([Dave_dir, '20110529_150003_chA_CH_ABB.coad.real.nc']);
 CH_ABB_imag_nc = ancload([Dave_dir, '20110529_150003_chA_CH_ABB.coad.imaginary.nc']);
 
 
 
 CH_HBB_real_nc = ancload([Dave_dir, '20110529_150003_chA_CH_HBB.coad.real.nc']);
 CH_HBB_imag_nc = ancload([Dave_dir, '20110529_150003_chA_CH_HBB.coad.imaginary.nc']);

 HC_ABB_real_nc = ancload([Dave_dir, '20110529_150003_chA_HC_ABB.coad.real.nc']);
 HC_ABB_imag_nc = ancload([Dave_dir, '20110529_150003_chA_HC_ABB.coad.imaginary.nc']);
 
 HC_HBB_real_nc = ancload([Dave_dir, '20110529_150003_chA_HC_HBB.coad.real.nc']);
 HC_HBB_imag_nc = ancload([Dave_dir, '20110529_150003_chA_HC_HBB.coad.imaginary.nc']);

 Sky1_real_nc = ancload([Dave_dir, '20110529_150003_chA_Sky1.coad.real.nc']);
 Sky1_imag_nc = ancload([Dave_dir, '20110529_150003_chA_Sky1.coad.imaginary.nc']);

 emis  = loadinto(['C:\case_studies\assist\compares\validationConnorNov2011\RAW\R1\LRT_BB_Emiss_FullRes.mat']);
emis = repack_edgar(emis);
 
 %%
%  figure; 
%  s(1) = subplot(2,1,1);
%  plot(CH_ABB_real_nc.vars.x_axis.data, [CH_ABB_real_nc.vars.y_data.data(:,1),...
%  CH_HBB_real_nc.vars.y_data.data(:,1),...
%  HC_ABB_real_nc.vars.y_data.data(:,1),...
%  HC_HBB_real_nc.vars.y_data.data(:,1),...
%  ],'-'); legend('CH_ABB','CH_HBB','HC_ABB','HC_HBB');
% s(2) = subplot(2,1,2);
%  plot(CH_ABB_real_nc.vars.x_axis.data, [CH_ABB_imag_nc.vars.y_data.data(:,1),...
%  CH_HBB_imag_nc.vars.y_data.data(:,1),...
%  HC_ABB_imag_nc.vars.y_data.data(:,1),...
%  HC_HBB_imag_nc.vars.y_data.data(:,1),...
%  ],'-'); legend('CH_ABB','CH_HBB','HC_ABB','HC_HBB');
% linkaxes(s,'xy');
%%
CH_ABB.x = CH_ABB_real_nc.vars.x_axis.data;
CH_ABB.y = CH_ABB_real_nc.vars.y_data.data + 1i*CH_ABB_imag_nc.vars.y_data.data;
CH_ABB.BB_temp = double(CH_ABB_real_nc.vars.cbbTempRaw.data)./CH_ABB_real_nc.vars.BBTempDivider.data;

CH_HBB.x = CH_ABB_real_nc.vars.x_axis.data;
CH_HBB.y = CH_HBB_real_nc.vars.y_data.data + 1i*CH_HBB_imag_nc.vars.y_data.data;
CH_HBB.BB_temp = double(CH_HBB_real_nc.vars.hbbTempRaw.data)./CH_HBB_real_nc.vars.BBTempDivider.data;

HC_ABB.x = HC_ABB_real_nc.vars.x_axis.data;
HC_ABB.y = HC_ABB_real_nc.vars.y_data.data + 1i*HC_ABB_imag_nc.vars.y_data.data;
HC_ABB.BB_temp = double(HC_ABB_real_nc.vars.cbbTempRaw.data)./HC_ABB_real_nc.vars.BBTempDivider.data;

HC_HBB.x = HC_HBB_real_nc.vars.x_axis.data;
HC_HBB.y = HC_HBB_real_nc.vars.y_data.data + 1i*HC_HBB_imag_nc.vars.y_data.data;
HC_HBB.BB_temp = double(HC_HBB_real_nc.vars.hbbTempRaw.data)./HC_HBB_real_nc.vars.BBTempDivider.data;
%%

Sky1_F.x = Sky1_real_nc.vars.x_axis.data;
Sky1_F.y = Sky1_real_nc.vars.y_data.data(:,1) + 1i*Sky1_imag_nc.vars.y_data.data(:,1);
Sky1_R.x = Sky1_real_nc.vars.x_axis.data;
Sky1_R.y = Sky1_real_nc.vars.y_data.data(:,2) + 1i*Sky1_imag_nc.vars.y_data.data(:,2);

ABB_F.x = HC_ABB.x;
%%
ABB_F.y = mean([HC_ABB.y(:,1),CH_ABB.y(:,1)],2);
%%
ABB_F.BB_temp = mean([HC_ABB.BB_temp(1), CH_ABB.BB_temp(1)]);
%%

HBB_F.x = HC_HBB.x;
HBB_F.y = mean([HC_HBB.y(:,1),CH_HBB.y(:,1)],2);
HBB_F.BB_temp = mean([HC_HBB.BB_temp(1), CH_HBB.BB_temp(1)]);

ABB_R.x = HC_ABB.x;
ABB_R.y = mean([HC_ABB.y(:,2),CH_ABB.y(:,2)],2);
ABB_R.BB_temp = mean([HC_ABB.BB_temp(1), CH_ABB.BB_temp(1)]);

HBB_R.x = HC_HBB.x;
HBB_R.y = mean([HC_HBB.y(:,2),CH_HBB.y(:,2)],2);
HBB_R.BB_temp = mean([HC_HBB.BB_temp(1), CH_HBB.BB_temp(1)]);

[F.CalSet,F.CalSet_, F.CalSet__] = CreateCalibrationFromCXS_(HBB_F, HBB_F.BB_temp+273.15, ABB_F, ABB_F.BB_temp+273.15, ABB_F.BB_temp+273.15,emis);
[R.CalSet,R.CalSet_, R.CalSet__] = CreateCalibrationFromCXS_(HBB_R, HBB_R.BB_temp+273.15, ABB_R, ABB_R.BB_temp+273.15, ABB_R.BB_temp+273.15,emis);
%%
Sky1.x = Sky1_F.x;
Sky1.F_mrad = Sky1_F.y./ F.CalSet.Resp + F.CalSet.Offset_ru;
Sky1.R_mrad = Sky1_R.y./ R.CalSet.Resp + R.CalSet.Offset_ru;
Sky1.mrad = mean([Sky1.F_mrad,Sky1.R_mrad],2);

Sky1.F_mrad_ = Sky1_F.y./ F.CalSet_.Resp + F.CalSet_.Offset_ru;
Sky1.R_mrad_ = Sky1_R.y./ R.CalSet_.Resp + R.CalSet_.Offset_ru;
Sky1.mrad_ = mean([Sky1.F_mrad_,Sky1.R_mrad_],2);

Sky1.F_mrad__ = Sky1_F.y./ F.CalSet__.Resp + F.CalSet__.Offset_ru;
Sky1.R_mrad__ = Sky1_R.y./ R.CalSet__.Resp + R.CalSet__.Offset_ru;
Sky1.mrad__ = mean([Sky1.F_mrad__,Sky1.R_mrad__],2);
%%

Edgar_dat = ['C:\case_studies\assist\compares\DaveT_ASSIST\processing_20111220\20110529_150003_chA_SKY.coad.mrad.coad.merged.truncated.nc'];
Edgar_nc_20 = ancload(Edgar_dat);
tr_20 = interp1(Sky1.x,[1:length(Sky1.x)],[Edgar_nc_20.vars.x_axis.data([1 end])],'nearest');
tr_20 = [tr_20(1):tr_20(2)];

Edgar_dat = ['C:\case_studies\assist\compares\DaveT_ASSIST\processing_20111221\20110529_150003_chA_SKY.coad.mrad.coad.merged.truncated.nc'];
Edgar_nc_21 = ancload(Edgar_dat);
tr_21 = interp1(Sky1.x,[1:length(Sky1.x)],[Edgar_nc_21.vars.x_axis.data([1 end])],'nearest');
tr_21 = [tr_21(1):tr_21(2)];


%%
[rad,c2 ,c4] = ApplyFFOVCorr(Sky1.x,Sky1.mrad,0.0225);
% [rad,wnp] = ffovcmr(Sky1.x,Sky1.mrad,0.0225,0);
% figure; plot(Sky1.x, [Sky1.mrad-rad],'-');

%%

figure; s(1) = subplot(2,1,1);
plot(Sky1.x(tr_21), [real(Sky1.mrad(tr_21)),Edgar_nc_21.vars.y_data.data(:,1)], 'b-');
legend('mine','LR Tech (Dec 21, 2011)');
ylabel('mw/(m^2 sr cm-1)')
s(2) = subplot(2,1,2);
plot(Sky1.x(tr_20), real(Sky1.mrad(tr_20))- Edgar_nc_20.vars.y_data.data(:,1), 'b-',...
    Sky1.x(tr_21), real(Sky1.mrad(tr_21))- Edgar_nc_21.vars.y_data.data(:,1), 'r-',...
    Sky1.x(tr_20), real(rad(tr_20))- Edgar_nc_20.vars.y_data.data(:,1), 'k-');
legend('Mine(noFFOV) - LR(FFOV)', 'Mine(noFFOV) - LR(noFFOV)','Mine(FFOV) - LR(FFOV)')
ylabel('mw/(m^2 sr cm-1)');
xlabel('wavenumber')
linkaxes(s,'x')
axis([600,1400,-2,2]);
% Sky1.mrad = mean(Sky1.F_mrad,Sky1.R_mrad);
