% for impactor:
% April 29
% June 19, Impactor state corrected by BNL on June 19
% 
% 8/19: new cpc data for M1
% 
% 8/19: nephwet.M1.  CLAP having trouble?
% 
% ignore impactor state in BNL b1 for psap and nephdry and nephwet.
% 
% Koontz waiting for me for QC for aethelometer
% 
% review QC for perspective, end-user or DQO.
% In particular, settting transitions to red.  
% 
% ASSESS impactor operation and data files:
% `
% Check April 29 for weirdness
% Check June 19 during which impactor state reporting was fixed by BNL.
% Examine M1 and S1 neph dry data, pressure, dP, etc.

impa1 = anc_bundle_files(getfullname__('*.nc','mao','Select impactor a1 files.'));
impa1_ = anc_downsample_nomiss(impa1,60);
impb1 = anc_bundle_files(getfullname__('*.nc','mao','Select impactor b1 files.'));
impb1_ = anc_downsample_nomiss(impb1,60);

nephS1 = anc_bundle_files(getfullname__('*.nc','nephb1S1','Select neph dry S1 files'));
[ainb, bina] = nearest(impb1.time, nephS1.time);
impb = anc_sift(impb1, ainb);
% nephS.vdata.impactor_state = impb.vdata.impactor_state;
% nephS.vatts.impactor_state = impb.vatts.impactor_state;
% nephS.ncdef.vars.impactor_state = impb.ncdef.vars.impactor_state;

% anc_plot_qcs(nephS);

nephS1_ = anc_downsample_nomiss(nephS1,60);
wetS1 = anc_bundle_files(getfullname__('*.cdf','mao','Select neph wet S1 files'));
wetS1_ = anc_downsample_nomiss(wetS1, 60);
nephM1 = anc_bundle_files(getfullname__('*.cdf','mao','Select neph dry M1 files')); %b-level
aosmet = anc_bundle_files(getfullname__('*.cdf','mao','Select aos met files'));
aosmet_ = anc_downsample_nomiss(aosmet,60);
t_1 = datenum(2014,4,20);t_2 = datenum(2014,5,10);
t_a = impA1.time>t_1 & impA1.time<t_2;
t_b = impb1.time>t_1 & impb1.time<t_2;

figure; 
s(1) = subplot(2,1,1);
plot(serial2doys(impb1_.time), impb1_.vdata.impactor_state, 'gx',...
    serial2doys(impa1_.time), double(impa1_.vdata.impactor_state)-double(impb1_.vdata.impactor_state), 'r.'); 
legend('b1 state', 'diff')
s(2) = subplot(2,1,2);
plot(serial2doys(nephS1_.time), nephS1_.vdata.P_Neph_Dry, 'kx', serial2doys(aosmet_.time), aosmet_.vdata.P_Ambient,'g.'); ylim([985,1010])
linkaxes(s,'x');

figure; 
semilogy(serial2doys(nephS1_.time), nephS1_.vdata.Bs_G_Dry_Neph3W_1, 'b.', ...
serial2doys(nephM1.time(nephM1.vdata.impactor_setting==1)), nephM1.vdata.Bs_G_Dry_Neph3W_1(nephM1.vdata.impactor_setting==1), 'r.',...
serial2doys(nephM1.time(nephM1.vdata.impactor_setting==10)), nephM1.vdata.Bs_G_Dry_Neph3W_1(nephM1.vdata.impactor_setting==10), 'g.'); 
legend('S1','M1 1um','M1 10um');
yl = ylim; ylim([.1,yl(2)])
s(3) = gca;
linkaxes(s,'x');

cpcf = anc_plot_qcs;
cpcf.vdata.delta = diff2(cpcf.vdata.concentration);
cpcf.vatts.delta = cpcf.vatts.concentration;
cpcf.vatts.delta.long_name
cpcf.vatts.delta.long_name = 'delta concentration';
cpcf.vdata.delta = abs(diff2(cpcf.vdata.concentration));
cpcf.ncdef.vars.delta = cpcf.ncdef.vars.concentration;

cpcf.ncdef.vars.qc_delta = cpcf.ncdef.vars.qc_concentration;
cpcf.vdata.qc_delta = cpcf.vdata.qc_concentration;
cpcf.vatts.qc_delta = cpcf.vatts.qc_concentration;
cpcf.vatts.qc_delta.long_name = 'qc for delta';
anc_plot_qcs(cpcf);

cpcf.vatts.qc_concentration.bit_10_description = 'delta > delta_max_warning';
cpcf.vatts.qc_concentration.bit_11_description = 'delta > delta_max_alarm';
cpcf.vatts.qc_concentration.bit_10_assessment = 'Indeterminate';
cpcf.vatts.qc_concentration.bit_11_assessment = 'Bad';
cpcf.vatts.qc_concentration.delta_max_warning = 150;
cpcf.vatts.qc_concentration.delta_max_alarm = 200;
qc_test = cpcf.vdata.delta > cpcf.vatts.qc_concentration.delta_max_warning;
cpcf.vdata.qc_concentration = bitset(cpcf.vdata.qc_concentration,10,qc_test);
qc_test = cpcf.vdata.delta > cpcf.vatts.qc_concentration.delta_max_alarm;
cpcf.vdata.qc_concentration = bitset(cpcf.vdata.qc_concentration,11,qc_test);
anc_plot_qcs(cpcf);
