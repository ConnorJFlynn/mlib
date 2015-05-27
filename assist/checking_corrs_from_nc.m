%%
pname = ['C:\case_studies\assist\200110928_tests\check_corrs\'];

% Load cleanB
clean_B = ancload([pname, 'clean_B.nc']);
ffov_B = ancload([pname, 'ffov_B.nc']);

%%
clean_Cn = ApplyFFOVCorr(clean_B.vars.x_axis.data, clean_B.vars.y_data.data(:,1));
figure; plot(clean_B.vars.x_axis.data, [clean_Cn-clean_B.vars.y_data.data(:,1)], '-')
%%
BB_hot = double(clean_B.vars.HBBRawMeanTime.data)./clean_B.vars.BBTempDivider.data;
BB_amb = double(clean_B.vars.CBBRawMeanTime.data)./clean_B.vars.BBTempDivider.data;
HBB = Blackbody(clean_B.vars.x_axis.data, 273.15+BB_hot);
ABB = Blackbody(clean_B.vars.x_axis.data, 273.15+BB_amb);
%%
HBB_ = ApplyFFOVCorr(clean_B.vars.x_axis.data, HBB);
ABB_ = ApplyFFOVCorr(clean_B.vars.x_axis.data, ABB);
%%
CalSet.Resp = (HBB_ - ABB_)./(HBB - ABB);
CalSet.Offset_ru =   ABB_./CalSet.Resp -ABB;
%%
figure; plot(clean_B.vars.x_axis.data, CalSet.Offset_ru,'-')
%%
clean_B_ffov = clean_Cn./ CalSet.Resp - CalSet.Offset_ru;
%%
figure; plot(clean_B.vars.x_axis.data, [ clean_B.vars.y_data.data(:,1)-clean_B_ffov],'-')
%% Failing FFOV comparison, trying e ~= 1
pname = ['C:\case_studies\assist\200110928_tests\check_corrs\'];
% Load cleanB
ffov_B = ancload([pname, 'ffov_B.nc']);
emis_pname = ['C:\case_studies\assist\200110928_tests\check_corrs\'];
emis_edg = repack_edgar(loadinto([emis_pname, 'LRT_BB_Emiss_FullRes.mat']));

%%
% [assist.chA.cxs.x,assist.chA.cxs.y] = RawIgm2RawSpc(assist.chA.x,assist.chA.y);


% [assist.chA.cxs.y, assist.chA.cxs.y_] = ApplyFFOVCorr(assist.chA.x,assist.chA.y, hfov);
assist = rad_cal_def_M(assist, emis_edg,28.65);
assist_ = rad_cal_def_M(assist, emis_edg, 30);