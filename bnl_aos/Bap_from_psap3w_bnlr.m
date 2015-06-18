psapR = anc_load;
%     'blue_signal_sum'
%     'blue_reference_sum'
%     'blue_sample_count'
%     'blue_overflow_count'
%     'green_signal_sum'
%     'green_reference_sum'
%     'green_sample_count'
%     'green_overflow_count'
%     'red_signal_sum'
%     'red_reference_sum'
%     'red_sample_count'
%     'red_overflow_count'
%     'dark_signal_sum'
%     'dark_reference_sum'
%     'dark_sample_count'
%     'dark_overflow_count'
%     'mass_flow_output'
%     'mass_flow'
%     'flags'
B_sig = double(psapR.vdata.blue_signal_sum - psapR.vdata.dark_signal_sum);
B_ref = double(psapR.vdata.blue_reference_sum - psapR.vdata.dark_reference_sum);
Tr_B = B_sig./B_ref;
figure; plot(serial2hs(psapR.time), Tr_B,'b.');
rat30 = ratioN(Tr_B,30);
rat8 = ratioN(Tr_B,8);
rat20 = ratioN(Tr_B,20);
figure; plot(serial2hs(psapR.time), real(-log(rat8)./8),'b.')

figure; plot(serial2hs(psapR.time), psapR.vdata.mass_flow,'.')

V = 1./60000; A = 2e-5;
L = V./A

psap = anc_load;
figure; plot(serial2hs(psap.time),psap.vdata.Ba_B_PSAP3W./1e6,'k.')
