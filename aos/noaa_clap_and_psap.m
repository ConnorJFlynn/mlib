clap = rd_noaa_cpd_('*A12*');
Area_m2 = ones(size(clap.A12a.time)).*([clap.Area_m2(clap.A12a.Fn_A12)]);
figure; plot(serial2hs(clap.A12a.time(1:end-1)), diff(clap.A12a.L_A12).*Area_m2(1:end-1),'.',...
   serial2hs(clap.A12m.time), clap.A12m.Q_A12./1e3,'x')
% this demonstrates that we can compute the sample_length from the flow and
% area for the CLAP




figure; plot(serial2hs(clap.A12a.time), -diff2(log(clap.A12a.IrB_A12))./diff2(clap.A12a.L_A12),'o', serial2hs(clap.A12a.time), 1e-6.*clap.A12a.BaB_A12,'rx')
title('mostly good for CLAP');

% ,A=0.814;B=1.237;Area=17.81 
% "00,e1,296916be,d4e1,141211002400,B1999:ba=b0/(k1*Tr+k0)"
% "01,06b006669b,c4d6a9b48f,a4fab0,a9,K0=0.866,K1=1.317"
% "02,6d087b63fe,7b199a8541,a49280,2c,area=17.81"

k1=1.317; ko=0.866; Tr = 0.66;
% or A=0.814;B=1.237;
% k1 = 1.237; k0 = .814;
kf = 1./(k1.*psap.A11a.IrB_A11 + ko);
bo = -diff2(log(psap.A11a.IrB_A11))./diff2(psap.A11a.L_A11);
figure; plot(serial2hs(psap.A11a.time), bo.*kf,'o', serial2hs(psap.A11a.time), 1e-6.*psap.A11a.BaB_A11,'rx');



figure; plot(serial2hs(clap.A12m.time), (diff2(clap.A12m.Qt_A12).*100)./clap.A12m.Q_A12,'x')

open NOAA psap a1

clap = anc_load;
psap = anc_load;
%  'Ba_B_CLAP3W'
%  'Ba_G_CLAP3W'
%  'Ba_R_CLAP3W'
%  'transmittance_B'
%  'transmittance_G'
%  'transmittance_R'
%  'sample_length'
%  'clap_flow_rate'
%  'impactor_setting'

figure; plot(serial2hs(clap.time), clap.vdata.sample_length,'.');legend('sample length');

figure; plot(serial2hs(clap.time), clap.vdata.psap_flow_rate*.001/1.9e-5,'o', serial2hs(clap.time(2:end)), diff(clap.vdata.sample_length),'rx'); legend('flow rate','diff(sample length)')




figure; plot(serial2hs(psap.time), psap.vdata.psap_flow_rate,'ro'); legend('psap flow')
