asipsap = anc_bundle_files(getfullname('*aop*.nc','aosaop','Select AOS AOP files'));

[Ba_B_Virk,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 1);
[Ba_G_Virk,ii_G,ko_G,k1_G,h0_G,h1_G,s_G] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 2);
[Ba_R_Virk,ii_R,ko_R,k1_R,h0_R,h1_R,s_R]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 3);

[Ba_B_Virk_ave,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 4);
[Ba_G_Virk_ave,ii_G,ko_G,k1_G,h0_G,h1_G,s_G] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 4);
[Ba_R_Virk_ave,ii_R,ko_R,k1_R,h0_R,h1_R,s_R]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 4);

AAE_BG_Bond = ang_exp(asipsap.vdata.Ba_G_BondOgren, asipsap.vdata.Ba_B_BondOgren,...
   sscanf(asipsap.vatts.Ba_G_BondOgren.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_BondOgren.wavelength,'%f'));
AAE_BR_Bond = ang_exp(asipsap.vdata.Ba_R_BondOgren, asipsap.vdata.Ba_B_BondOgren,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_BondOgren.wavelength,'%f'));
AAE_GR_Bond = ang_exp(asipsap.vdata.Ba_R_BondOgren, asipsap.vdata.Ba_G_BondOgren,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_BondOgren.wavelength,'%f'));

AAE_BG_Virk = ang_exp(Ba_G_Virk, Ba_B_Virk, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk = ang_exp(Ba_R_Virk, Ba_B_Virk, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Virk = ang_exp(Ba_R_Virk, Ba_G_Virk, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Virk_ave = ang_exp(Ba_G_Virk_ave, Ba_B_Virk_ave, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_B_Virk_ave, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_G_Virk_ave, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));


figure_(52); plot(asipsap.time, AAE_BG_Bond, '.',asipsap.time, AAE_BR_Bond, '.',asipsap.time, AAE_GR_Bond, '.');
legend('AAE BG Bond','AAE BR Bond', 'AAE GR Bond'); 
ax(1) = gca; dynamicDateTicks;  
figure_(53); plot(asipsap.time, AAE_BG_Virk_ave, '.',asipsap.time, AAE_BR_Virk_ave, '.',asipsap.time, AAE_GR_Virk_ave, '.');
legend('AAE BG Virk ave','AAE BR Virk ave', 'AAE GR Virk ave'); 
ax(end+1) = gca; dynamicDateTicks;  
figure_(54); plot(asipsap.time, asipsap.vdata.AAE_BG, '.',asipsap.time, asipsap.vdata.AAE_BR, '.',asipsap.time, asipsap.vdata.AAE_GR, '.');
legend('AAE BG comb','AAE BR comb', 'AAE GR comb'); 
ax(end+1) = gca; dynamicDateTicks;  
% linkaxes(ax,'xy')

figure_(55); plot(asipsap.time, asipsap.vdata.transmittance_green,'gx'); 
ax(end+1) = gca; dynamicDateTicks; 
figure_(56); plot(asipsap.time, [Ba_B_Virk_ave; Ba_G_Virk_ave; Ba_R_Virk_ave],'.'); legend('Ba_B V_a_v_e','Ba_G V_a_v_e','Ba_R V_a_v_e');
ax(end+1) = gca; dynamicDateTicks;
figure_(57); plot(asipsap.time, [asipsap.vdata.Ba_B_BondOgren;asipsap.vdata.Ba_G_BondOgren;asipsap.vdata.Ba_R_BondOgren],'.'); legend('Ba_B BondOgren','Ba_G BondOgren','Ba_R BondOgren');
ax(end+1) = gca; dynamicDateTicks;

% linkaxes(ax,'xy')

linkaxes(ax,'x')


figure; plot(asipsap.time, asipsap.vdata.Ba_R_Virkkula,'o',asipsap.time, Ba_R_Virk_ave,'.'); dynamicDateTicks
ax(1)=gca;
figure; plot(asipsap.time, asipsap.vdata.Ba_R_Virkkula -Ba_R_Virk_ave,'rx'); dynamicDateTicks
ax(2)=gca;
linkaxes(ax,'x');



V = axis;
figure;  plot(asipsap.time, Ba_B_Virk, '.',asipsap.time, Ba_G_Virk, '.',asipsap.time, Ba_R_Virk, '.'); dynamicDateTicks
legend('Ba B Virk_ave','Ba G Virk_ave', 'Ba R Virk_ave'); axis(V);
v = axis;
figure; plot(asipsap.time, AAE_BG_Virk, '.',asipsap.time, AAE_BR_Virk, '.',asipsap.time, AAE_GR_Virk, '.');
legend('AAE BG','AAE BR', 'AAE GR'); dynamicDateTicks;   axis(v);

