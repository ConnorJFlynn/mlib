% Prepare PSAP data set for testing Machine Learning "ML" algorithms

spring = rd_bnl_tsv3;
psap_b1 = anc_bundle_files(getfullname('*.cdf','psapb1'));
Tr_tmp = psap_b1.vdata.transmittance_blue;
psap_b1.vdata.transmittance_blue = interp1(spring.time+30./(24*60*60), spring.BlueAbs, psap_b1.time, 'nearest');
sample_flow = psap_b1.vdata.sample_flow_rate./psap_b1.vdata.dilution_correction_factor;
tic
psap_s1.vdata.Ba_B_raw = smooth_Tr_Bab(psap_b1.time, sample_flow , psap_b1.vdata.transmittance_blue,60);
k1=1.317; ko=0.866; 
kf = 1./(k1.*psap_b1.vdata.transmittance_blue + ko)';toc
psap_s1.vdata.Ba_B_Weiss =  psap_s1.vdata.Ba_B_raw .* kf;
psap_s1.vdata.qc_Ba_B_Weiss = bitset(psap_s1.vdata.qc_Ba_B_Weiss, 1, 0);






psap_s1 = anc_bundle_files(getfullname('*.nc','psaps1'));


ARM_ds_display(psap_s1);
psap = anc_mesh(psap_b1, psap_s1,'time');

% Here's the plan.
% read in psap_b1, _s1, and spring
% Replace psap_s1 transmittance with spring. 
% Re-compute Ba_RBG
% clear "missing" flag. 
% set qc_Ba as missing when spring absorption missing.
figure; plot(serial2doys(psap_b1.time), psap_b1.vdata.sample_flow_rate,'kx')
figure; plot(serial2doys(psap_s1.time), psap_s1.vdata.sample_flow_rate,'g.',...
         serial2doys(psap_s1.time(isNaN(spring.InstrumentFlow)|isNaN(spring.DilutionFlow)|isNaN(spring.BlueAbs))), ...
   psap_s1.vdata.sample_flow_rate(isNaN(spring.InstrumentFlow)|isNaN(spring.DilutionFlow)|isNaN(spring.BlueAbs)),'b.',...
   serial2doys(psap_s1.time(isNaN(spring.InstrumentFlow)|isNaN(spring.DilutionFlow))), ...
   psap_s1.vdata.sample_flow_rate(isNaN(spring.InstrumentFlow)|isNaN(spring.DilutionFlow)),'r.')
figure; plot(serial2doys(psap_s1.time), psap_s1.vdata.sample_flow_rate, 'o', serial2doys(spring.time), spring.InstrumentFlow./(spring.InstrumentFlow./(spring.InstrumentFlow-spring.DilutionFlow./1000)),'x')

figure; plot(serial2hs(spring.time), spring.InstrumentFlow,'r.',serial2hs(spring.time), spring.DilutionFlow./1000,'b.' )

figure;
a3(1) = subplot(3,1,1); plot(serial2doys(psap_b1.time), psap_b1.vdata.transmittance_blue_raw, 'k.',...
   serial2doys(psap_b1.time), psap_b1.vdata.tr_blue, 'b.'); legend('raw','tr');
a3(2) = subplot(3,1,2); plot(serial2doys(psap_b1.time), psap_b1.vdata.transmittance_blue, 'b.',...
   serial2doys(psap_s1.time), psap_s1.vdata.transmittance_blue, 'g.'); legend('b1','s1');
a3(3) = subplot(3,1,3);
plot(serial2doys(spring.time), spring.BlueTransmittance, 'b.'); legend('spring Tr');
linkaxes(a3,'xy');

figure;
a2(1) = subplot(2,1,1); plot(serial2doys(psap_b1.time), 1.031.*psap_s1.vdata.Ba_B_Weiss, 'G.',...
   serial2doys(psap_b1.time(isNaN(spring.BlueAbs))), 1.031.*psap_s1.vdata.Ba_B_Weiss(isNaN(spring.BlueAbs)), 'r.'); legend('s1');
a2(2) = subplot(2,1,2);plot(serial2doys(spring.time), spring.BlueAbs, 'b.'); legend('spring Ba');
linkaxes(a2,'xy');

linkaxes([a2,a3],'x')

[~, ax] = anc_plot_vap_qcd(psap_b1, 'transmittance_blue');
linkaxes(ax,'x'); dynamicDateTicks(ax,'linked')

[~, ax] = anc_plot_vap_qcd(psap_s1, 'Ba_B_Weiss');
hold(ax(1),'on'); plot(ax(1),spring.time-1./(24*60), spring.BlueAbs,'b.')

linkaxes(ax,'x'); dynamicDateTicks(ax,'linked')
figure; plot(psap_s1.time, psap_s1
% what to plot...
% psap_b1: tr_front_panel, tr_raw, sample_flow_rate, dilution flow,
% dilution_correction, impactor

% psap_s1: renormalized transmittance, absorbance, sample_volume,
% absorption_coefficient

% spring: renormalized_transmittance, 

