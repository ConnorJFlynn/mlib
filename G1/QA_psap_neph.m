% Want to generate QA flags for PSAP & Neph. 
% Still trying to understand PSAP issues associated with ramps or pressure
% changes. Intend to load PSAP_raw.txt (for precision absorption), PSAP.txt
% (for associated HK fields including temp and RH at PSAP exhaust), Neph
% (for correlation between Bs and Ba), and probably IWG1 file.
% Use a scan of these to 
% 1. Get a sense of the reliability
% 2. Define some automated tests
% 3. Configure visi-screen for flagging this data set.

clear; close('all');
disp('Getting psap_raw')
[psapo_grid,~,psapi] = rd_psapi_g1;

disp('Getting psap panel')
[psap_txt] = rd_psap_txt_g1([psapo_grid.pname, strrep(psapo_grid.fname, 'psap_raw','psap')]);

disp('Getting neph')
[neph_grid] = rd_nephD_g1([strrep(psapo_grid.pname,'PSAP','Neph'), strrep(psapo_grid.fname, 'psap_raw','nephD')]);

close('all'); clear ax

figure; plot(serial2hs(psapo_grid.time), [psapo_grid.trans_B_sm,psapo_grid.trans_G_sm,psapo_grid.trans_R_sm],'-');dynamicDateTicks
legend('Tr_B raw','Tr B raw','Tr R raw','Tr B smooth', 'Tr G smooth', 'Tr R smooth');
title('PSAP transmittances, full precision');
zoom('on');
ax(1)=gca;

% figure; plot(serial2hs(psapo_grid.time), [psapo_grid.Ba_B_sm_Weiss,psapo_grid.Ba_G_sm_Weiss, psapo_grid.Ba_R_sm_Weiss],'-', ...
%     serial2hs(psapi.time + (15./(24*60*60))), [smooth(psapi.Ba_B,60),smooth(psapi.Ba_G,60), smooth(psapi.Ba_R,60)],'o'); 
figure; plot(serial2hs(psapo_grid.time), [psapo_grid.Ba_B_sm_Weiss,psapo_grid.Ba_G_sm_Weiss, psapo_grid.Ba_R_sm_Weiss],'-'); 
zoom('on')
% legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T', 'Ba B 60s in Ba','Ba G 60s in Ba', 'Ba R 60s in Ba');
legend('Ba B 32s in T','Ba G 32s in T', 'Ba R 32s in T');
title(['Absorption coeffs ',strtok(psapi.fname,'.')]);
ylabel('1/Mm')
ax(end+1) = gca;
figure; plot(serial2hs(psapo_grid.time), psapo_grid.mass_flow_last, '-x');
ax(end+1) = gca;  
legend('mass flow'); title(['PSAP Mass flow ',strtok(psapi.fname,'.')]);
figure; ax(end+1) = subplot(2,1,1); plot(serial2hs(psap_txt.time), psap_txt.T_post_PSAP, '-x');
legend('T after'); title(['PSAP Mass flow ',strtok(psapi.fname,'.')]);
ax(end+1) = subplot(2,1,2);
plot(serial2hs(psap_txt.time), psap_txt.RH_post_PSAP, '-o');
legend('RH after');

figure; plot(serial2hs(neph_grid.time), [neph_grid.Bs_B_sm,neph_grid.Bs_G_sm,neph_grid.Bs_R_sm].*1e6, '-');
legend('Bs B','Bs G', 'Bs R'); 
ylabel('1/Mm')
ax(end+1) = gca;

figure; plot(serial2hs(neph_grid.time), [neph_grid.T_stat-273,neph_grid.T_vol-273], 'o-');
legend('T s', 'Neph T_v_o_l'); 
ax(end+1) = gca;

figure; plot(serial2hs(neph_grid.time), [neph_grid.P], 'o-');
legend('Neph P'); 
ax(end+1) = gca;

figure; plot(serial2hs(neph_grid.time), [neph_grid.RH], 'o-');
legend('Neph RH'); 
ax(end+1) = gca;

linkaxes(ax,'x');
disp('hi')