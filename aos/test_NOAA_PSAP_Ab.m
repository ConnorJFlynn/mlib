function test_NOAA_PSAP_Ab
% Load psap.a1 and psap.b1.
% Confirm that I can reproduce a1 absorption coefficients from absorbance
% measurements
psapa1 = anc_bundle_files(getfullname('*.*','psapa1','Select psap a1'));
psapb1 = anc_bundle_files(getfullname('*.*','psapb1','Select psap b1'));

% Ok, something strange.  
% The file for Feb 7 here: D:\case_studies\aos\harmony_summary\PSAP\Ab\maoaospsap3wM1.b1
% and here: D:\case_studies\aos\harmony_summary\data\mao\psap\maoaospsap3wM1.b1\maoaospsap3wM1.b1.20140207.000000.nc

% Confirm that I can reproduce a1 absorption coefficients from absorbance
% measurements

% a1
%     'Ba_B_PSAP3W'
%     'Ba_G_PSAP3W'
%     'Ba_R_PSAP3W'
%     'transmittance_B'
%     'transmittance_G'
%     'transmittance_R'
%     'sample_length'
%     'psap_flow_rate'
%     'impactor_setting'
%     'filter_id'

% b1
%     'transmittance_blue'
%     'transmittance_green'
%     'transmittance_red'
%     'absorbance_blue'
%     'absorbance_green'
%     'absorbance_red'
%     'sample_flow_rate'
%     'seconds_after_transition'
%     'impactor_state'
%     'dilution_correction_factor'

% ,A=0.814;B=1.237;Area=17.81 
% "00,e1,296916be,d4e1,141211002400,B1999:ba=b0/(k1*Tr+k0)"
% "01,06b006669b,c4d6a9b48f,a4fab0,a9,K0=0.866,K1=1.317"
% "02,6d087b63fe,7b199a8541,a49280,2c,area=17.81"

k1=1.317; ko=0.866; 
% or A=0.814;B=1.237;
% k1 = 1.237; k0 = .814;
% kf = 1./(k1.*psap.A11a.IrB_A11 + ko);
kf = 1./(k1.*psapb1.vdata.transmittance_green + ko);
sample_flow = psapb1.vdata.sample_flow_rate ; %liter/min
T = 2;
dt = diffN(psapb1.time,T).*24.*60.*60; dt(1:T-1) = dt(T); dt(end-T+1:end) = dt(end-T);
dL = (1000.*1000.*sample_flow)./(60.*17.81); % mm/sec
dL = dL ./ (1000); %m per 60-sec average
dL = dL.*dt;


bo = psapb1.vdata.absorbance_green./dL;

Bab_1s = smooth_Tr_Bab(psapb1.time, sample_flow, psapb1.vdata.transmittance_green,1);
figure; plot(serial2doys(psapb1.time), 1e6.*bo,'ko', serial2doys(psapa1.time), Bab_1s,'rx');
legend('b1 (derived)','a1 (reported)')


figure; plot(serial2doys(psapb1.time), 1e6.*bo.*kf,'ko', serial2doys(psapa1.time), psapa1.vdata.Ba_G_PSAP3W,'rx');
legend('b1 (derived)','a1 (reported)')

figure; plot(serial2hs(psapb1.time), 1e6.*bo.*kf,'ko');
legend('PSAP M1 (derived)')


% figure; plot(serial2hs(psapb1.time), kf.*Bap_G*1e6,'r.', serial2hs(psapa1.time), psapa1.Ba_G_PSAP3W,'kx' );
% above copied from test_BNL_PSAP_Ab
%Not a match, but similar.  
% The below was copied back from test_BNL_PSAP_Ab where it works and shows
% yields and acceptable match to the a1 values.
% aeth = ARM_nc_display;
% 
% figure; these = plot(serial2hs(aeth.time), Ab1(1,:),'.',serial2hs(aeth.time), Ab2(1,:),'o');
% recolor(these,aeth.vdata.nm); colorbar
% 
% Tr = (aeth.vdata.sample_intensity-aeth.vdata.sample_dark)./(aeth.vdata.reference_intensity-aeth.vdata.reference_dark);
% 
% ATN = -100 * log ( Tr  );
% 
% % Ab = -ln(transmittance[t]/transmittance[t-1]) = ln(Tr(t-1)) - ln(Tr(t)) = 
% 
% Ab1__ = diffN(ATN./100,1,1);
% 
% 
% Ab1_(1,:) = diffN(ATN(1,:)./100,1);
% Ab1_(2,:) = diffN(ATN(2,:)./100,1);
% Ab1_(3,:) = diffN(ATN(3,:)./100,1);
% Ab1_(4,:) = diffN(ATN(4,:)./100,1);
% Ab1_(5,:) = diffN(ATN(5,:)./100,1);
% Ab1_(6,:) = diffN(ATN(6,:)./100,1);
% Ab1_(7,:) = diffN(ATN(7,:)./100,1);
% 
% Ab2_(1,:) = -log(ratioN(Tr(1,:),1));
% 
% Ab1 = zeros(size(aeth.time));
% Ab1(2:end) = diff(ATN(1,:))./100;
% 
% Ab2 = zeros(size(aeth.time));
% Ab2(2:end) = -log(Tr(1,2:end)./Tr(1,1:end-1));
% 
% figure; plot(serial2hs(aeth.time), Ab1, 'o',serial2hs(aeth.time), Ab1_(1,:), 'r.'); legend('diff','diffN')
% 
% figure; plot(serial2hs(aeth.time), Ab1, 'o',serial2hs(aeth.time), Ab2_, 'r.'); legend('diff','ratioN')
% % Ab = ln(transmittance[t]/transmittance[t-1]) = ln(Tr(t)) - ln(Tr(t-1))

%%
return