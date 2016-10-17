anne = rd_noaa_psap_cleaned;
arm_psap = anc_load;
good_arm = arm_psap.vdata.qc_Ba_B_Weiss==0 & arm_psap.vdata.impactor_state==1;
a11 = read_noaa_a11;
a11_2 = a11; a11_2.time = a11.time +30./(24*60*60);
[ainb, bina] = nearest(arm_psap.time, a11_2.time);
% Confirm spot-size in A11 by demonstrating ocnsistency between sample flow
% and integrated length
[a11.L(3)-a11.L(2),a11.flow_rate(5)*1000*1000/18.74/1000]
% So reported flows in a11 are already corrected
% And if so presumably so are the reported absorption coefficients?

% The below compares A11 Weiss to Anne Bond.
% figure; plot(anne.time, anne.Ba_G_1um_psap,'k.',a11.time, a11.Ba_G,'go');


good_arm = arm_psap.vdata.qc_Ba_G_Bond==0&arm_psap.vdata.impactor_state==1;
figure; plot(arm_psap.time(good_arm), arm_psap.vdata.Ba_G_Bond(good_arm),'gx',  anne.time, anne.Ba_G_1um_psap, 'k*')
% This looks OK, compares ARM Bond to Anne Bond.

a11_2.Ba_G_adj = a11_2.Ba_G .*(18.74./17.81);
figure; plot(serial2hs(arm_psap.time(ainb)), arm_psap.vdata.Ba_G_Weiss(ainb),'bx', serial2hs(a11_2.time(bina)), a11_2.Ba_G(bina),'ko',serial2hs(a11_2.time(bina)), a11_2.Ba_G_adj(bina),'ms')

(a11_2.flow_rate./a11_2.flow_rate_new)
adj = (a11_2.flow_rate./a11_2.flow_rate_new).* (18.74./17.81);
figure; plot(serial2hs(arm_psap.time(ainb)), arm_psap.vdata.Bs_B_raw(ainb).*double(arm_psap.vdata.impactor_state(ainb)==1),'b*'); legend('Bs raw')
figure; plot(serial2hs(arm_psap.time(ainb)), arm_psap.vdata.Bs_B_raw(ainb).*double(arm_psap.vdata.impactor_state(ainb)==1).*arm_psap.vdata.K1_G(ainb)./(1.22.*1.031),'b*'); legend('Bs subtraction')
% anne_clean = load(['H:\case_studies\AOS\Dubey\anne_clean.serialtime.mat'])
figure; plot(serial2doys(arm_psap.time(ainb)), arm_psap.vdata.Ba_G_Weiss(ainb).*double(arm_psap.vdata.impactor_state(ainb)==1),'bx', serial2doys(a11_2.time(bina)), a11_2.Ba_G(bina),'ko',serial2doys(a11_2.time(bina)), a11_2.Ba_G_adj(bina),'ms'); legend('arm','A11','A11 adj')
% legend('Anne 1 um','Anne all')
title('ARM and NOAA "Weiss-corrected" Absorption Coefficients');

a11_2.Ba_B_raw = a11_2.Ba_B;
a11_2.Ba_B_raw(1) = NaN;
a11_2.Ba_B_raw(2:end) = 1e6.*log(a11_2.Tr_B(1:end-1)./a11_2.Tr_B(2:end))./(a11_2.L(2:end)-a11_2.L(1:end-1));
a11_2.Ba_B_raw_adj = (18.74./17.81).* a11_2.Ba_B_raw;
f_w = 1 ./ (1.3579.*a11_2.Tr_B + 0.8931);
a11_2.Ba_B_weiss = a11_2.Ba_B_raw .* f_w;

a11_2.Ba_G_raw = a11_2.Ba_G;
a11_2.Ba_G_raw(1) = NaN;
a11_2.Ba_G_raw(2:end) = 1e6.*log(a11_2.Tr_G(1:end-1)./a11_2.Tr_G(2:end))./(a11_2.L(2:end)-a11_2.L(1:end-1));
f_w = 1 ./ (1.3579.*a11_2.Tr_G + 0.8931);
a11_2.Ba_G_weiss = a11_2.Ba_G_raw .* f_w;

a11_2.Ba_R_raw = a11_2.Ba_R;
a11_2.Ba_R_raw(1) = NaN;
a11_2.Ba_R_raw(2:end) = 1e6.*log(a11_2.Tr_R(1:end-1)./a11_2.Tr_R(2:end))./(a11_2.L(2:end)-a11_2.L(1:end-1));
f_w = 1 ./ (1.3579.*a11_2.Tr_R + 0.8931);
a11_2.Ba_R_weiss = a11_2.Ba_R_raw .* f_w;

figure; plot(serial2doys(arm_psap.time(ainb)), arm_psap.vdata.Ba_G_Weiss(ainb).*double(arm_psap.vdata.impactor_state(ainb)==1),'bx', ...
    serial2doys(a11_2.time(bina)), a11_2.Ba_G(bina),'ko',...
    serial2doys(a11_2.time(bina)), adj(bina).*a11_2.Ba_G_weiss(bina),'r.'); 
legend('ARM Weiss','A11','A11 Weiss adj')
axis(v)

