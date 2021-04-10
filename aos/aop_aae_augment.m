asipsap = anc_bundle_files(getfullname('*aosaop*.nc','aosaop','Select AOS AOP files'));

[Ba_B_Virk,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 1);
[Ba_G_Virk,ii_G,ko_G,k1_G,h0_G,h1_G,s_G] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 2);
[Ba_R_Virk,ii_R,ko_R,k1_R,h0_R,h1_R,s_R]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 3);

[Ba_B_Virk_ave,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 4);
[Ba_G_Virk_ave,ii_G,ko_G,k1_G,h0_G,h1_G,s_G] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 4);
[Ba_R_Virk_ave,ii_R,ko_R,k1_R,h0_R,h1_R,s_R]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 4);

[Ba_B_Virk_static_S,ii_B_sS,ko_B_sS,k1_B_sS,h0_B_sS,h1_B_sS,s_B_sS] = compute_Virkkula_static_S(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 1);
[Ba_G_Virk_static_S,ii_G_sS,ko_G_sS,k1_G_sS,h0_G_sS,h1_G_sS,s_G_sS] = compute_Virkkula_static_S(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 2);
[Ba_R_Virk_static_S,ii_R_sS,ko_R_sS,k1_R_sS,h0_R_sS,h1_R_sS,s_R_sS] = compute_Virkkula_static_S(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 3);

[Ba_B_Virk_var_S,ii_B_vS,ko_B_vS,k1_B_vS,h0_B_vS,h1_B_vS,s_B_vS] = compute_Virkkula_var_S(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 1);
[Ba_G_Virk_var_S,ii_G_vS,ko_G_vS,k1_G_vS,h0_G_vS,h1_G_vS,s_G_vS] = compute_Virkkula_var_S(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 2);
[Ba_R_Virk_var_S,ii_R_vS,ko_R_vS,k1_R_vS,h0_R_vS,h1_R_vS,s_R_vS] = compute_Virkkula_var_S(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 3);

Bs_B = asipsap.vdata.Bs_B; Bs_G = asipsap.vdata.Bs_G; Bs_R = asipsap.vdata.Bs_R;
Ba_B_Wirk = Ba_B_Virk + s_B_vS.*Bs_B; 
Ba_G_Wirk = Ba_G_Virk + s_G_vS.*Bs_G ; 
Ba_R_Wirk = Ba_R_Virk + s_R_vS.*Bs_R;

Ba_B_Wirk_ave = Ba_B_Virk_ave + s_B_sS.*Bs_B; 
Ba_G_Wirk_ave = Ba_G_Virk_ave + s_G_sS.*Bs_G ; 
Ba_R_Wirk_ave = Ba_R_Virk_ave + s_R_sS.*Bs_R;

Ba_B_Wirk_ss = Ba_B_Virk_static_S + s_B_sS.*Bs_B; 
Ba_G_Wirk_ss = Ba_G_Virk_static_S + s_G_sS.*Bs_G ; 
Ba_R_Wirk_ss = Ba_R_Virk_static_S + s_R_sS.*Bs_R;

Ba_B_Wirk_vs = Ba_B_Virk_var_S + s_B_vS.*Bs_B; 
Ba_G_Wirk_vs = Ba_G_Virk_var_S + s_G_vS.*Bs_G ; 
Ba_R_Wirk_vs = Ba_R_Virk_var_S + s_R_vS.*Bs_R;


AAE_BG_Weiss = ang_exp(asipsap.vdata.Ba_G_Weiss, asipsap.vdata.Ba_B_Weiss,...
   sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
AAE_BR_Weiss = ang_exp(asipsap.vdata.Ba_R_Weiss, asipsap.vdata.Ba_B_Weiss,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
AAE_GR_Weiss = ang_exp(asipsap.vdata.Ba_R_Weiss, asipsap.vdata.Ba_G_Weiss,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'));


AAE_BG_Bond = ang_exp(asipsap.vdata.Ba_G_Bond, asipsap.vdata.Ba_B_Bond,...
   sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
AAE_BR_Bond = ang_exp(asipsap.vdata.Ba_R_Bond, asipsap.vdata.Ba_B_Bond,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
AAE_GR_Bond = ang_exp(asipsap.vdata.Ba_R_Bond, asipsap.vdata.Ba_G_Bond,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'));

AAE_BG_Virk = ang_exp(Ba_G_Virk, Ba_B_Virk, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk = ang_exp(Ba_R_Virk, Ba_B_Virk, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Virk = ang_exp(Ba_R_Virk, Ba_G_Virk, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Virk_ave = ang_exp(Ba_G_Virk_ave, Ba_B_Virk_ave, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_B_Virk_ave, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_G_Virk_ave, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Virk_ss = ang_exp(Ba_G_Virk_static_S, Ba_B_Virk_static_S, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk_ss = ang_exp(Ba_R_Virk_static_S, Ba_B_Virk_static_S, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Virk_ss = ang_exp(Ba_R_Virk_static_S, Ba_G_Virk_static_S, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Virk_vs = ang_exp(Ba_G_Virk_var_S, Ba_B_Virk_var_S, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk_vs = ang_exp(Ba_R_Virk_var_S, Ba_B_Virk_var_S, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Virk_vs = ang_exp(Ba_R_Virk_var_S, Ba_G_Virk_var_S, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Wirk = ang_exp(Ba_G_Wirk, Ba_B_Wirk, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Wirk = ang_exp(Ba_R_Wirk, Ba_B_Wirk, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Wirk = ang_exp(Ba_R_Wirk, Ba_G_Wirk, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Wirk_ave = ang_exp(Ba_G_Wirk_ave, Ba_B_Wirk_ave, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Wirk_ave = ang_exp(Ba_R_Wirk_ave, Ba_B_Wirk_ave, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Wirk_ave = ang_exp(Ba_R_Wirk_ave, Ba_G_Wirk_ave, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Wirk_ss = ang_exp(Ba_G_Wirk_ss, Ba_B_Wirk_ss, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Wirk_ss = ang_exp(Ba_R_Wirk_ss, Ba_B_Wirk_ss, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Wirk_ss = ang_exp(Ba_R_Wirk_ss, Ba_G_Wirk_ss, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_BG_Wirk_vs = ang_exp(Ba_G_Wirk_vs, Ba_B_Wirk_vs, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Wirk_vs = ang_exp(Ba_R_Wirk_vs, Ba_B_Wirk_vs, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GR_Wirk_vs = ang_exp(Ba_R_Wirk_vs, Ba_G_Wirk_vs, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));



% figure_(51); plot(asipsap.time, AAE_BG_Weiss, '.',asipsap.time, AAE_BR_Weiss, '.',asipsap.time, AAE_GR_Weiss, '.');
% legend('AAE BG Weiss','AAE BR Weiss', 'AAE GR Weiss'); 
% ax(1) = gca; dynamicDateTicks;  
figure_(52); plot(asipsap.time, AAE_BG_Bond, '.',asipsap.time, AAE_BR_Bond, '.',asipsap.time, AAE_GR_Bond, '.');
legend('AAE BG Bond','AAE BR Bond', 'AAE GR Bond'); 
ax(1) = gca; dynamicDateTicks;  
figure_(53); plot(asipsap.time, AAE_BG_Virk, '.',asipsap.time, AAE_BR_Virk, '.',asipsap.time, AAE_GR_Virk, '.');
legend('AAE BG Virk','AAE BR Virk', 'AAE GR Virk'); 
ax(end+1) = gca; dynamicDateTicks;  
figure_(54); plot(asipsap.time, AAE_BG_Virk_ave, '.',asipsap.time, AAE_BR_Virk_ave, '.',asipsap.time, AAE_GR_Virk_ave, '.');
legend('AAE BG Virk ave','AAE BR Virk ave', 'AAE GR Virk ave'); 
ax(4) = gca; dynamicDateTicks;  
linkaxes(ax,'xy')

figure_(55); plot(asipsap.time, asipsap.vdata.transmittance_green,'gx'); 
ax(end+1) = gca; dynamicDateTicks; 
figure_(56); plot(asipsap.time, [Ba_B_Virk_ave; Ba_G_Virk_ave; Ba_R_Virk_ave],'.'); legend('Ba_B V_a_v_e','Ba_G V_a_v_e','Ba_R V_a_v_e');
ax(end+1) = gca; dynamicDateTicks;
figure_(57); plot(asipsap.time, [asipsap.vdata.Ba_B_Bond;asipsap.vdata.Ba_G_Bond;asipsap.vdata.Ba_R_Bond],'.'); legend('Ba_B Bond','Ba_G Bond','Ba_R Bond');
ax(end+1) = gca; dynamicDateTicks;

linkaxes(ax,'x')


figure_(55); plot(asipsap.time, AAE_BG_Virk_ss, '.',asipsap.time, AAE_BR_Virk_ss, '.',asipsap.time, AAE_GR_Virk_ss, '.');
legend('AAE BG Virk static S','AAE BR Virk  static S', 'AAE GR Virk  static S'); 
ax(5) = gca; dynamicDateTicks;  
figure_(56); plot(asipsap.time, AAE_BG_Virk_vs, '.',asipsap.time, AAE_BR_Virk_vs, '.',asipsap.time, AAE_GR_Virk_vs, '.');
legend('AAE BG Virk var S','AAE BR Virk var S', 'AAE GR Virk var S'); 
ax(6) = gca; dynamicDateTicks;  

figure_(57); plot(asipsap.time, AAE_BG_Wirk, '.',asipsap.time, AAE_BR_Wirk, '.',asipsap.time, AAE_GR_Wirk, '.');
legend('AAE BG Wirk','AAE BR Wirk', 'AAE GR Wirk'); 
ax(7) = gca; dynamicDateTicks;  
figure_(58); plot(asipsap.time, AAE_BG_Wirk_ave, '.',asipsap.time, AAE_BR_Wirk_ave, '.',asipsap.time, AAE_GR_Wirk_ave, '.');
legend('AAE BG Wirk ave','AAE BR Wirk ave', 'AAE GR Wirk ave'); 
ax(8) = gca; dynamicDateTicks;  
figure_(59); plot(asipsap.time, AAE_BG_Wirk_ss, '.',asipsap.time, AAE_BR_Wirk_ss, '.',asipsap.time, AAE_GR_Wirk_ss, '.');
legend('AAE BG Wirk static S','AAE BR Wirk  static S', 'AAE GR Wirk  static S'); 
ax(9) = gca; dynamicDateTicks;  
figure_(60); plot(asipsap.time, AAE_BG_Wirk_vs, '.',asipsap.time, AAE_BR_Wirk_vs, '.',asipsap.time, AAE_GR_Wirk_vs, '.');
legend('AAE BG Wirk var S','AAE BR Wirk var S', 'AAE GR Wirk var S'); 
ax(10) = gca; dynamicDateTicks;  




figure; plot(asipsap.time, asipsap.vdata.Ba_R_Virkkula,'o',asipsap.time, Ba_R_Virk,'.'); dynamicDateTicks
ax(1)=gca;
figure; plot(asipsap.time, asipsap.vdata.Ba_R_Virkkula -Ba_R_Virk,'x'); dynamicDateTicks
ax(2)=gca;
linkaxes(ax,'x');

asipsap.vdata.AAE_BG_Virk = ang_exp(asipsap.vdata.Ba_G_Virkkula, asipsap.vdata.Ba_B_Virkkula,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
asipsap.vdata.AAE_BR_Virk = ang_exp(asipsap.vdata.Ba_R_Virkkula, asipsap.vdata.Ba_B_Virkkula,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
asipsap.vdata.AAE_GR_Virk = ang_exp(asipsap.vdata.Ba_R_Virkkula, asipsap.vdata.Ba_G_Virkkula,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

asipsap.vdata.AAE_BG_Bond = ang_exp(asipsap.vdata.Ba_G_Bond, asipsap.vdata.Ba_B_Bond,...
   sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
asipsap.vdata.AAE_BR_Bond = ang_exp(asipsap.vdata.Ba_R_Bond, asipsap.vdata.Ba_B_Bond,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
asipsap.vdata.AAE_GR_Bond = ang_exp(asipsap.vdata.Ba_R_Bond, asipsap.vdata.Ba_G_Bond,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'));

asipsap.ncdef.vars.AAE_BR_Virk = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_GR_Virk = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_BG_Virk = asipsap.ncdef.vars.Ba_B_Virkkula;

asipsap.ncdef.vars.AAE_BR_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_GR_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_BG_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;

asipsap.vatts.AAE_BG_Virk = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_BG_Virk.long_name = ['AAE BG Virk'];
asipsap.vatts.AAE_BR_Virk = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_BR_Virk.long_name = ['AAE BR Virk'];
asipsap.vatts.AAE_GR_Virk = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_GR_Virk.long_name = ['AAE GR Virk'];

asipsap.vatts.AAE_BG_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_BG_Bond.long_name = ['AAE BG Bond'];
asipsap.vatts.AAE_BR_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_BR_Bond.long_name = ['AAE BR Bond'];
asipsap.vatts.AAE_GR_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_GR_Bond.long_name = ['AAE GR Bond'];


AAE_BG_Virk = ang_exp(Ba_G_Virk, Ba_B_Virk,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_BR_Virk = ang_exp(Ba_R_Virk, Ba_B_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));  
AAE_GR_Virk = ang_exp(Ba_R_Virk, Ba_G_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

V = axis;
figure;  plot(asipsap.time, Ba_B_Virk, '.',asipsap.time, Ba_G_Virk, '.',asipsap.time, Ba_R_Virk, '.'); dynamicDateTicks
legend('Ba B Virk_ave','Ba G Virk_ave', 'Ba R Virk_ave'); axis(V);
v = axis;
figure; plot(asipsap.time, AAE_BG_Virk, '.',asipsap.time, AAE_BR_Virk, '.',asipsap.time, AAE_GR_Virk, '.');
legend('AAE BG','AAE BR', 'AAE GR'); dynamicDateTicks;   axis(v);


AAE_BG_Weiss = ang_exp(asipsap.vdata.Ba_G_Weiss, asipsap.vdata.Ba_B_Weiss,...
   sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
AAE_BR_Weiss = ang_exp(asipsap.vdata.Ba_R_Weiss, asipsap.vdata.Ba_B_Weiss,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f'));
AAE_GR_Weiss = ang_exp(asipsap.vdata.Ba_R_Weiss, asipsap.vdata.Ba_G_Weiss,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'));

figure; plot(asipsap.time, AAE_BG_Weiss, '.',asipsap.time, AAE_BR_Weiss, '.',asipsap.time, AAE_GR_Weiss, '.');
legend('AAE BG Weiss','AAE BR Weiss', 'AAE GR Weiss'); dynamicDateTicks;  