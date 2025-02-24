function mat = make_amicec_exp_mat

% 
% 2024-12-23: 
% Exp 1
% PSAP with Pall E70. TAP with E70. CLAPs with Azumi
% 03:00 UT. Close and restart IN102 VI for fresh start,preparing to start all VIs with HEPA and then switch to bag of AS.
% 03:10 UT Switching to bag
% 03:38 UT, Switching back to HEPA, refilling bag.  Advancing TAP & CLAP spots. Closing PSAP_VI and changing PSAP filter after seeing where it plateaus.
% Interesting that red is dropping slower in Ba on PSAP.
% 
% read IN_102


IN_102 = rd_in102_vi; IN_102 = ap_cal(IN_102); 
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\IN_102.mat'],'-struct','IN_102'); toc
figure_(5);
plot(IN_102.time, [IN_102.Bs_B, IN_102.Bs_G, IN_102.Bs_R],'o'); 
dynamicDateTicks
xl = xlim; 
in_xl = IN_102.time>xl(1) & IN_102.time<xl(2);
Bs_B = mean(IN_102.Bs_B(in_xl)); Bs_G = mean(IN_102.Bs_G(in_xl)); Bs_R = mean(IN_102.Bs_R(in_xl));

% read PSAP
pxap = amicec_pxap_auto; 
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\pxap.mat'],'-struct','pxap'); toc
figure; plot(pxap.time, pxap.AAE,'.', pxap.time, pxap.AAE_500,'k.'); 
figure; plot(pxap.time, pxap.Bap_raw./Bs_G,'x'); dynamicDateTicks; xlim(xl);
figure; plot(pxap.time, pxap.Bap_raw(:,1)./Bs_G./.112,'x',...
pxap.time, pxap.Bap_raw(:,2)./Bs_G./.095,'x',...
pxap.time, pxap.Bap_raw(:,3)./Bs_G./.07,'x'); dynamicDateTicks; xlim(xl);

figure; plot(pxap.Tr(:,1), pxap.Bap_raw(:,1)./Bs_G./.112,'x',...
pxap.Tr(:,2), pxap.Bap_raw(:,2)./Bs_G./.095,'x',...
pxap.Tr(:,3), pxap.Bap_raw(:,3)./Bs_G./.07,'x'); 


tap = amicec_xap_auto; xlim(xl); 
tap.Tr(tap.Tr<0)= NaN; figure; plot(tap.time, tap.Tr,'-');dynamicDateTicks;
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\tap.mat'],'-struct','tap'); toc
dynamicDateTicks; xlim(xl);
clap10 = amicec_xap_auto; 
clap10.Tr(clap10.Tr<0)= NaN; figure; plot(clap10.time,clap10.Tr,'-');dynamicDateTicks;
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\clap10.mat'],'-struct','clap10'); toc
 xlim(xl); 

clap92 = amicec_xap_auto; 
clap92.Tr(clap92.Tr<0)= NaN; figure; plot(clap92.time,clap92.Tr,'-');dynamicDateTicks;
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\clap92.mat'],'-struct','clap92'); toc

ma492 = amicec_ma_auto; 
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\ma492.mat'],'-struct','ma492'); toc


figure; plot(ma492.time, ma492.Bap1_raw,'-'); dynamicDateTicks;xlim(xl);
figure; plot(ma492.time, ma492.AAE1,'-'); dynamicDateTicks;xlim(xl);
figure; plot(ma492.time, ma492.AAE1_,'-'); dynamicDateTicks;xlim(xl);

ma494 = amicec_ma_auto; 
tic; save(['C:\case_studies\AMICE\AMICE1c_data\mat_dat\ma494.mat'],'-struct','ma494'); toc

ma494 = amicec_ma_auto; %xlim(xl); 
figure; plot(ma494.time, ma494.Bap1_raw,'.'); dynamicDateTicks;xlim(xl);
figure; plot(ma494.time, ma494.AAE1,'.'); dynamicDateTicks;xlim(xl);




% 
% 2024-12-22: 
% Instruments/filters
% PSAP/E70
% TAP/E70
% CLAP10/AZUMI
% CLAP92/AZUMI start on spot 2 to avoid potential leak from solenoid 1
% 
% Initially sample HEPA air until all systems optimized.
% Then switch to filtered air from homemade mega mylar bag.
% switching from HEPA to mylar at 23:20
% 
% Noticed a purtubation, probably related to the mylar bag covering the tube inlet.  Modified to incorporate two copper woven pads  around the tubing inlet.
% 
% Have run distilled water directly from nebulizer and obtained scattering ~50 1/Mm. 
% 
% Then ran distilled water past desiccant column to obtain ~0 scattering.
% 
% 7:25 local, 01:25 UT now running dilute ammonium nitrate solution.
% 
% 0.08g / 32 into a 1 Liter bottle. 0.0025 g / L, 
% 7:32 starting to see increased scattering, low level ~10  Bab B
% tried increasing flow rate, not much change.
% Tried full 0.08 g into 1 L at 01:40. Obtained Bs_B of about 1500 Mm-1.  Good.  
% 
% Now, filling MegaMylar bag from nebulizer with same solution, while all instruments sample HEPA
% takes a bit over an hour to fill mylar bag.
% 
% Exp 1
% PSAP with Pall E70. TAP with E70. CLAPs with Azumi
% 03:00 UT. Close and restart IN102 VI for fresh start,preparing to start all VIs with HEPA and then switch to bag of AS.
% 03:10 UT Switching to bag
% 03:38 UT, Switching back to HEPA, refilling bag.  Advancing TAP & CLAP spots. Closing PSAP_VI and changing PSAP filter after seeing where it plateaus.
% Interesting that red is dropping slower in Ba on PSAP.
% 
% I'll run a repeat of this experiment with identical solution and filters.
% Exp 2
% 04:30, Advanced MA350 tapes, reset Tr==1 for 
% 05:00 Switching to Bag
% 5:30 (or earlier, forgot to note time) bag exhausted, switch to HEPA
% 
% Exp 3, TAP now with Azumi,PSAP with Emfab, CLAP spots advanced to 5
% This experiment will be critical for determining whether E70, EMFAB, and Azumi have different scattering corrections.
% 06:30 switching to Bag
% 
% Exp 4 ~1/16 diluted AS with Cabojet solution with Ba > 200 1/Mm  Bs ~60 1/Mm. 
% 07:45, started filling Bag, replacing filters, advancing spots.
% switching to bag 08:40
% 
% Exp 5, same solution, TAP with E70, PSAP with E70, fresh filters around. 
% switching to bag 9:40 UT
% 
% Exp 6, Nigrosin + AS
% Initially too strong scattering, diluted soln, and airflow to fill bag.
% New filters, spots
% switched to Bag 16:12 or so
% stopped at 16:45 or so
% 






