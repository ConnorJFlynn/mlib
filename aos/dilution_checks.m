% NOAA dilcor checks
dilcor = anc_bundle_files(getfullname('*.nc','mao_dlc','Select dilution correction files.'));
% Dilution_correction_factor = Sum_of_sample_flows / (Sum_of_sample_flows – dilution_flow) where
% Sum_of_sample_flows = Q_Q12 + Q_N11 + Q_A11 + Q_A12 + Q_cnc_cc_s(convert to lpm) with:
% Q_Q12 found in X2a file: flow through impactors about 29 lpm
% Q_N11 found in N11a file: flow through CCN about 0.5 lpm
% Q_A11 found in A11a file: flow through psap about 0.8 lpm
% Q_A12 found in A12a file: flow through Clap about 1.0 lpm
% Q_cnc_cc_s found in header of N61a file: CPC flow, 16.6 cc/sec or 0.996 lpm
% Sum_of_sample_flows = 29+0.5+0.8+1.0+0.996 = 32.296

%     'dilution_flow'
%     'nephelometer_flow'
%     'ccn100_sample_flow'
%     'ccn100_sheath_flow'
%     'sample_flows'
%     'psap_flow'
%     'clap_flow'
%     'cpc_flow'
%     'dilution_correction_factor'

sam = dilcor.vdata.psap_flow + dilcor.vdata.clap_flow + dilcor.vdata.ccn100_sample_flow + dilcor.vdata.ccn100_sheath_flow ...
    + dilcor.vdata.cpc_flow*60/1000 + dilcor.vdata.nephelometer_flow;
 figure; plot(serial2doys(dilcor.time), dilcor.vdata.dilution_flow,'x');legend('dil flow')
 figure; plot(serial2doys(dilcor.time), sam, 'co', serial2doys(dilcor.time), dilcor.vdata.sample_flows,'kx');
figure; plot(serial2doys(dilcor.time), sam./(sam-dilcor.vdata.dilution_flow), 'k.',serial2doys(dilcor.time), dilcor.vdata.dilution_correction_factor,'ro')

% Dry neph NOT OK
nepha1 = anc_bundle_files(getfullname('*.cdf','mao_nepha1','Select nephdry a1 files.'));
nephb1 = anc_bundle_files(getfullname('*.cdf','mao_nephb1','Select nephdry b1 files.'));
figure; plot(serial2doys(nephb1.time), nephb1.vdata.dilution_correction_factor,'o');

figure; plot(serial2doys(nepha1.time), nepha1.vdata.Bs_B_Dry_Neph3W, 'b.',serial2doys(nephb1.time), nephb1.vdata.Bs_B_Dry_Neph3W./nephb1.vdata.dilution_correction_factor,'go')
figure; plot(serial2doys(nepha1.time), nepha1.vdata.Bs_R_Dry_Neph3W, 'b.',serial2doys(nephb1.time), nephb1.vdata.Bs_R_Dry_Neph3W./nephb1.vdata.dilution_correction_factor,'go')
figure; plot(serial2doys(nepha1.time), nepha1.vdata.Bbs_B_Dry_Neph3W, 'b.',serial2doys(nephb1.time), nephb1.vdata.Bbs_B_Dry_Neph3W./nephb1.vdata.dilution_correction_factor,'go')
figure; plot(serial2doys(nepha1.time), nepha1.vdata.Bbs_R_Dry_Neph3W, 'b.',serial2doys(nephb1.time), nephb1.vdata.Bbs_R_Dry_Neph3W./nephb1.vdata.dilution_correction_factor,'go')

figure; plot(serial2doys(nepha1.time), nepha1.vdata.Bs_G_Dry_Neph3W, 'b.',serial2doys(nephb1.time), nephb1.vdata.Bs_G_Dry_Neph3W./nephb1.vdata.dilution_correction_factor,'go')
figure; plot(serial2doys(nepha1.time), nepha1.vdata.Bbs_G_Dry_Neph3W, 'b.',serial2doys(nephb1.time), nephb1.vdata.Bbs_G_Dry_Neph3W./nephb1.vdata.dilution_correction_factor,'go')


% dcf not populated in nephdryM1.b1
% dilution correction looks like the wrong direction, b1 values are less
% than a1 values.

% PSAP checks out OK except not applied when Ba < 0?
psapa1 = anc_bundle_files(getfullname('*.cdf','maopsapa1','Select psap a1 files.'));
psapb1 = anc_bundle_files(getfullname('*.cdf','maopsapb1','Select psap b1 files.'));
figure; plot(serial2doys(psapb1.time), psapb1.vdata.dilution_correction_factor,'o');legend('psap dcf')
figure; plot(serial2doys(psapa1.time), psapa1.vdata.Ba_G_PSAP3W, 'b.', serial2doys(psapb1.time), psapb1.vdata.Ba_G_PSAP3W./psapb1.vdata.dilution_correction_factor,'go')

% CLAP checks out OK except not applied when Ba < 0?
clapa1 = anc_bundle_files(getfullname('*.cdf','maoclapa1','Select clap a1 files.'));
clapb1 = anc_bundle_files(getfullname('*.cdf','maoclapb1','Select clap b1 files.'));
figure; plot(serial2doys(clapb1.time), clapb1.vdata.dilution_correction_factor,'o');legend('clap dcf')
figure; plot(serial2doys(clapa1.time), clapa1.vdata.Ba_G_CLAP3W, 'b.', serial2doys(clapb1.time), clapb1.vdata.Ba_G_CLAP3W./clapb1.vdata.dilution_correction_factor,'go')

% cpc dilution_correction_factor is populated but not applied to b1
% concentration?
cpca1 = anc_bundle_files(getfullname('*.cdf','mao','Select cpc a1 files.'));
cpcb1 = anc_bundle_files(getfullname('*.cdf','mao','Select cpc b1 files.'));
figure; plot(serial2doys(cpcb1.time), cpcb1.vdata.dilution_correction_factor,'o');legend('cpc dcf')
figure; plot(serial2doys(cpca1.time), cpca1.vdata.concentration, 'b.', serial2doys(cpcb1.time), cpcb1.vdata.concentration./cpcb1.vdata.dilution_correction_factor,'go')

% ccn dilution_correction_factor is populated but not applied to b1
% concentration?
ccna1 = anc_bundle_files(getfullname('*.cdf','mao','Select ccn a1 files.'));
ccnb1 = anc_bundle_files(getfullname('*.cdf','mao','Select ccn a1 files.'));
figure; plot(serial2doys(ccnb1.time), ccnb1.vdata.dilution_correction_factor,'o');legend('ccn dcf')
figure; plot(serial2doys(ccna1.time), ccna1.vdata.N_CCN_dN(3,:), 'b.', serial2doys(ccnb1.time), ccnb1.vdata.N_CCN_dN(3,:)./ccnb1.vdata.dilution_correction_factor,'go')


cpcfa1 = anc_bundle_files(getfullname('*.cdf','maocpcf_a1','Select cpcf a1 files.'));
cpcfb1 = anc_bundle_files(getfullname('*.cdf','maocpcf_b1','Select cpcf b1 files.'));

dcf = ones(size(cpcfb1.time));
pos = cpcfb1.vdata.dilution_valve_position==1;
dilflow = cpcfb1.vdata.dilution_flow_setpoint * cpcfb1.vdata.dilution_slope - cpcfb1.vdata.dilution_intercept;
dcf(pos) = 970./(970-dilflow(pos));
figure; plot(cpcfb1.time, cpcfb1.vdata.dilution_flow_reading ,'go', cpcfb1.time, dilflow, 'rx'); dynamicDateTicks

