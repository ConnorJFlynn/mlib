function check_aop
% Checking new aop files which include Ba_*_combined

aop = ARM_display_beta(aop);
aop_1h = ARM_display_beta;

good = aop.vdata.qc_Ba_B_combined==0&aop.vdata.qc_Ba_G_combined==0&aop.vdata.qc_Ba_R_combined==0;
B = sscanf(aop.vatts.transmittance_blue.wavelength,'%f');
G = sscanf(aop.vatts.transmittance_green.wavelength,'%f');
R = sscanf(aop.vatts.transmittance_red.wavelength,'%f');
BGg = gmean([B,G]); 
BRg = gmean([B,R]); 
GRg = gmean([R,G]); 

Ba_B_Bond = aop.vdata.Ba_B_BondOgren;
Ba_G_Bond = aop.vdata.Ba_G_BondOgren;
Ba_R_Bond = aop.vdata.Ba_R_BondOgren;
AAE_BG_Bond = ang_exp(Ba_B_Bond, Ba_G_Bond, B, G);
AAE_BR_Bond = ang_exp(Ba_B_Bond, Ba_R_Bond, B, R);
AAE_GR_Bond = ang_exp(Ba_G_Bond, Ba_R_Bond, G, R);

Ba_B_Vavg = aop.vdata.Ba_B_Virkkula;
Ba_G_Vavg = aop.vdata.Ba_G_Virkkula;
Ba_R_Vavg = aop.vdata.Ba_R_Virkkula;
AAE_BG_Vavg = ang_exp(Ba_B_Vavg, Ba_G_Vavg, B, G);
AAE_BR_Vavg = ang_exp(Ba_B_Vavg, Ba_R_Vavg, B, R);
AAE_GR_Vavg = ang_exp(Ba_G_Vavg, Ba_R_Vavg, G, R);

[Ba_B_Virk,~, ~, ~, ~, ~,~, SSA_V_B] = compute_Virkkula(aop.vdata.transmittance_blue, aop.vdata.Bs_B, aop.vdata.Ba_B_raw, 1);
[Ba_G_Virk,~, ~, ~, ~, ~,~, SSA_V_G] = compute_Virkkula(aop.vdata.transmittance_green, aop.vdata.Bs_G, aop.vdata.Ba_G_raw, 2);
[Ba_R_Virk,~, ~, ~, ~, ~,~, SSA_V_R] = compute_Virkkula(aop.vdata.transmittance_red, aop.vdata.Bs_R, aop.vdata.Ba_R_raw, 3);
AAE_BG_Virk = ang_exp(Ba_B_Virk, Ba_G_Virk, B, G);
AAE_BR_Virk = ang_exp(Ba_B_Virk, Ba_R_Virk, B, R);
AAE_GR_Virk = ang_exp(Ba_G_Virk, Ba_R_Virk, G, R);




figure; 
s3(1) = subplot(2,1,1);
plot(aop.time(good), [AAE_BG_Bond(good);AAE_BR_Bond(good);AAE_GR_Bond(good)], 'o'); dynamicDateTicks
ylabel('unitless');legend('AAE Bond')
s3(2) = subplot(2,1,2);
plot(aop.time(good), [AAE_BG_Virk(good);AAE_BR_Virk(good);AAE_GR_Virk(good)], '*'); dynamicDateTicks
ylabel('unitless');legend('AAE Virkkula')
dynamicDateTicks
linkaxes(s3,'x');

figure; 
s4(1) = subplot(2,1,1);
plot(aop.time(good), [Ba_B_Bond(good);Ba_G_Bond(good);Ba_R_Bond(good)], 'o'); dynamicDateTicks
ylabel('1/Mm');legend('B_a_p Bond')
s4(2) = subplot(2,1,2);
plot(aop.time(good), [Ba_B_Virk(good);Ba_G_Virk(good);Ba_R_Virk(good)], '*'); dynamicDateTicks
ylabel('1/Mm');legend('B_a_p Virkkula')
dynamicDateTicks
linkaxes([s3,s4],'x');

figure; 
s2(1) = subplot(2,1,1);
plot(aop.time(good), aop.vdata.transmittance_red(good), 'rx'); dynamicDateTicks
s2(2) = subplot(2,1,2);
plot(aop.time(good), AAE_BG_Bond(good), 'x-',...
   aop.time(good), AAE_BG_Virk(good), 'o-',...
   aop.time(good), AAE_BG_Vavg(good), '+-'); 
dynamicDateTicks
legend('Bond AAE','Virk AAE', 'Vavg AAE');
linkaxes(s2,'x');




xlt = xlim;
xlt_ = aop.time>=xlt(1)&aop.time<=xlt(2)&aop.vdata.transmittance_blue<.99;
xlt_ = aop.time>=xlt(1)&aop.time<=xlt(2);
figure; plot(aop.vdata.transmittance_blue(good&xlt_),AAE_BG_Bond(good&xlt_),'b.',...
   aop.vdata.transmittance_blue(good&xlt_),AAE_BG_Virk(good&xlt_),'b*',...
   aop.vdata.transmittance_blue(good&xlt_),AAE_BG_Vavg(good&xlt_),'k.');axis('square')
axis(v)
figure; plot(aop.vdata.transmittance_blue(good&xlt_),AAE_BR_Bond(good&xlt_),'g.',...
   aop.vdata.transmittance_blue(good&xlt_),AAE_BR_Virk(good&xlt_),'g*',...
   aop.vdata.transmittance_blue(good&xlt_),AAE_BR_Vavg(good&xlt_),'k.');axis('square')
axis(v)
figure; plot(aop.vdata.transmittance_blue(good&xlt_),AAE_GR_Bond(good&xlt_),'r.',...
   aop.vdata.transmittance_blue(good&xlt_),AAE_GR_Virk(good&xlt_),'r*',...
   aop.vdata.transmittance_blue(good&xlt_),AAE_GR_Vavg(good&xlt_),'k.');axis('square');
axis(v)
% Zoom into a region with high loading, quasi-constant loading.
xl = xlim; 
xl_ = aop.time>=xl(1)&aop.time<=(xl(2));
% Compute averages, plot vs WL

[Ba_B_Virk,~, ~, ~, ~, ~,~, SSA_V_B]  = compute_Virkkula(aop.vdata.transmittance_blue, aop.vdata.Bs_B, aop.vdata.Ba_B_raw, 1);
Ba_B_Virk = mean(Ba_B_Virk(xl_&good));
[Ba_G_Virk,~, ~, ~, ~, ~,~, SSA_V_G] = compute_Virkkula(aop.vdata.transmittance_green, aop.vdata.Bs_G, aop.vdata.Ba_G_raw, 2);
Ba_G_Virk = mean(Ba_G_Virk(xl_&good));
[Ba_R_Virk,~, ~, ~, ~, ~,~, SSA_V_R] = compute_Virkkula(aop.vdata.transmittance_red, aop.vdata.Bs_R, aop.vdata.Ba_R_raw, 3);
Ba_R_Virk = mean(Ba_R_Virk(xl_&good));
AAE_BG_Virk = ang_exp(Ba_B_Virk, Ba_G_Virk, B, G);
AAE_BR_Virk = ang_exp(Ba_B_Virk, Ba_R_Virk, B, R);
AAE_GR_Virk = ang_exp(Ba_G_Virk, Ba_R_Virk, G, R);

Ba_B_Bond = mean(aop.vdata.Ba_B_BondOgren(xl_&good));
Ba_G_Bond = mean(aop.vdata.Ba_G_BondOgren(xl_&good));
Ba_R_Bond = mean(aop.vdata.Ba_R_BondOgren(xl_&good));
AAE_BG_Bond = ang_exp(Ba_B_Bond, Ba_G_Bond, B, G);
AAE_BR_Bond = ang_exp(Ba_B_Bond, Ba_R_Bond, B, R);
AAE_GR_Bond = ang_exp(Ba_G_Bond, Ba_R_Bond, G, R);

Ba_B_Vavg = mean(aop.vdata.Ba_B_Virkkula(xl_&good));
Ba_G_Vavg = mean(aop.vdata.Ba_G_Virkkula(xl_&good));
Ba_R_Vavg = mean(aop.vdata.Ba_R_Virkkula(xl_&good));
AAE_BG_Vavg = ang_exp(Ba_B_Vavg, Ba_G_Vavg, B, G);
AAE_BR_Vavg = ang_exp(Ba_B_Vavg, Ba_R_Vavg, B, R);
AAE_GR_Vavg = ang_exp(Ba_G_Vavg, Ba_R_Vavg, G, R);



Ba_B = mean(aop.vdata.Ba_B_combined(good&xl_));
Ba_G = mean(aop.vdata.Ba_G_combined(good&xl_));
Ba_R = mean(aop.vdata.Ba_R_combined(good&xl_));
AAE_BG = mean(aop.vdata.AAE_BG(good&xl_));
AAE_BR = mean(aop.vdata.AAE_BR(good&xl_));
AAE_GR = mean(aop.vdata.AAE_GR(good&xl_));


figure; 
sb(1) = subplot(2,1,1); 
plot([B,G,R],[Ba_B, Ba_G, Ba_R],'-o',...
   [B,G,R],[Ba_B_Vavg, Ba_G_Vavg, Ba_R_Vavg],'-o',...
   [B,G,R],[Ba_B_Bond, Ba_G_Bond, Ba_R_Bond],'-o',...
   [B,G,R],[Ba_B_Virk, Ba_G_Virk, Ba_R_Virk],'-o'); logy;logx;
ylabel('B_a_p')
legend('Combined','Vavg4', 'Bond', 'Virk123')
title(['B_a_p and AAE at ASI:',datestr(mean(aop.time(xl_)),'yyyy-mm-dd HH:MM')])
sb(2) =subplot(2,1,2);
plot([BGg, BRg, GRg], [AAE_BG, AAE_BR, AAE_GR],'-x',...
   [BGg, BRg, GRg], [AAE_BG_Vavg, AAE_BR_Vavg, AAE_GR_Vavg],'-x',...
   [BGg, BRg, GRg], [AAE_BG_Bond, AAE_BR_Bond, AAE_GR_Bond],'-x',...
   [BGg, BRg, GRg], [AAE_BG_Virk, AAE_BR_Virk, AAE_GR_Virk],'-x')
legend('Combined','Vavg', 'Bond', 'Virk123');
xlabel('wavelength [nm]');
ylabel('AAE')
logx;
linkaxes(sb,'x')



figure; plot(aop.time, aop.vdata.Ba_B_Virkkula, 'o',aop.time, aop.vdata.Ba_G_Virkkula, 'o',...
   aop.time, aop.vdata.Ba_R_Virkkula, 'o'); dynamicDateTicks;
hold('on'); title('Ba Virkkula Ave')

plot(aop.time, Ba_B_Virk,'.',aop.time, Ba_G_Virk,'.',aop.time, Ba_R_Virk,'k.'); dynamicDateTicks

figure; plot(aop.time, aop.vdata.ssa_B, 'o',aop.time, aop.vdata.ssa_G, 'o',...
   aop.time, aop.vdata.ssa_R, 'o'); dynamicDateTicks;
hold('on'); title('Ba Virkkula Ave')
plot(aop.time, SSA_V_B,'.',aop.time, SSA_V_G,'.',aop.time, SSA_V_R,'k.'); dynamicDateTicks

AAE_BG = ang_exp(Ba_B_Virk, Ba_G_Virk, ...
   sscanf(aop.vatts.Ba_B_combined.wavelength,'%f'),sscanf(aop.vatts.Ba_G_combined.wavelength,'%f'));
AAE_BR = ang_exp(Ba_B_Virk, Ba_R_Virk, ...
   sscanf(aop.vatts.Ba_B_combined.wavelength,'%f'),sscanf(aop.vatts.Ba_R_combined.wavelength,'%f'));
AAE_GR = ang_exp(Ba_G_Virk, Ba_R_Virk, ...
   sscanf(aop.vatts.Ba_G_combined.wavelength,'%f'),sscanf(aop.vatts.Ba_R_combined.wavelength,'%f'));

% Then zoom into a region to select xl_
% Plot averages a fnt of WL
B_nm = sscanf(aop.vatts.Ba_B_combined.wavelength,'%f');G_nm = sscanf(aop.vatts.Ba_G_combined.wavelength,'%f');
R_nm = sscanf(aop.vatts.Ba_R_combined.wavelength,'%f');
xl = xlim; xl_ = aop.time>=xl(1)&aop.time<=xl(2)&Ba_B_Virk>0&Ba_G_Virk>0&Ba_R_Virk>0&...
  aop.vdata.Ba_B_combined>0& aop.vdata.Ba_G_combined>0&aop.vdata.Ba_R_combined>0&...
  SSA_V_B>0&SSA_V_G>0&SSA_V_R>0&aop.vdata.ssa_B>0&aop.vdata.ssa_G>0&aop.vdata.ssa_R>0;
figure; plot([B_nm, G_nm, R_nm],...
    [mean(aop.vdata.Ba_B_combined(xl_)),mean(aop.vdata.Ba_G_combined(xl_)),mean(aop.vdata.Ba_R_combined(xl_))],'-o',...
    [B_nm, G_nm, R_nm],...
    [mean(Ba_B_Virk(xl_)),mean(Ba_G_Virk(xl_)),mean(Ba_R_Virk(xl_))], '-x') 
xlabel('wavelength [nm]');
ylabel('B_a_p');
title('Wavelength dependence of Absorption Coefs');
legend('Ba Combined','Ba Virk');
logx; logy

figure; plot([B_nm, G_nm, R_nm],...
    [mean(aop.vdata.ssa_B(xl_)),mean(aop.vdata.ssa_G(xl_)),mean(aop.vdata.ssa_R(xl_))],'-o',...
    [B_nm, G_nm, R_nm],...
    [mean(SSA_V_B(xl_)),mean(SSA_V_G(xl_)),mean(SSA_V_R(xl_))], '-x') 
xlabel('wavelength [nm]');
ylabel('SSA');
title('Wavelength dependence of SSA');
legend('SSA Combined','SSA Virk');
logx; logy

figure; plot([B_nm, G_nm, R_nm],...
    1-[mean(aop.vdata.ssa_B(xl_)),mean(aop.vdata.ssa_G(xl_)),mean(aop.vdata.ssa_R(xl_))],'-o',...
    [B_nm, G_nm, R_nm],...
    1-[mean(SSA_V_B(xl_)),mean(SSA_V_G(xl_)),mean(SSA_V_R(xl_))], '-x') 
xlabel('wavelength [nm]');
ylabel('COA');
title('Wavelength dependence of COA');
legend('COA Combined','COA Virk');
logx; logy

figure; plot([mean([B_nm, G_nm]), mean([B_nm, R_nm]), mean([G_nm, R_nm])],...
    [mean(aop.vdata.AAE_BG(xl_)),mean(aop.vdata.AAE_BR(xl_)),mean(aop.vdata.AAE_GR(xl_))],'-o',...
    [mean([B_nm, G_nm]), mean([B_nm, R_nm]), mean([G_nm, R_nm])],...
    [mean(AAE_BG(xl_)),mean(AAE_BR(xl_)),mean(AAE_GR(xl_))], '-x') 
xlabel('wavelength [nm]');
ylabel('AAE');
title('Wavelength dependence of AAE');
legend('AAE Combined','AAE Virk');
logx; logy


Ba_B_BondOgren = aop.vdata.Ba_B_Weiss - aop.vdata.Bs_B_uncorrected.*aop.vdata.K1_B./1.22;
Ba_G_BondOgren = aop.vdata.Ba_G_Weiss - aop.vdata.Bs_G_uncorrected.*aop.vdata.K1_G./1.22;
Ba_R_BondOgren = aop.vdata.Ba_R_Weiss - aop.vdata.Bs_R_uncorrected.*aop.vdata.K1_R./1.22;
figure; plot(aop.time, [aop.vdata.Ba_B_BondOgren;aop.vdata.Ba_G_BondOgren;aop.vdata.Ba_R_BondOgren], 'o');
hold('on');title('Ba BondOgren')
plot(aop.time, [Ba_B_BondOgren;Ba_G_BondOgren;Ba_R_BondOgren], 'k.');

Ba_B_combined = (Ba_B_Virk_ave + Ba_B_BondOgren)./2;
Ba_G_combined = (Ba_G_Virk_ave + Ba_G_BondOgren)./2;
Ba_R_combined = (Ba_R_Virk_ave + Ba_R_BondOgren)./2;

figure; plot(aop.time, [aop.vdata.Ba_B_combined;aop.vdata.Ba_G_combined;aop.vdata.Ba_R_combined], 'o');
hold('on');title('Ba combined')
plot(aop.time, [Ba_B_combined;Ba_G_combined;Ba_R_combined], 'k.');

AAE_BG = ang_exp(aop.vdata.Ba_B_combined, aop.vdata.Ba_G_combined, ...
   sscanf(aop.vatts.Ba_B_combined.wavelength,'%f'),sscanf(aop.vatts.Ba_G_combined.wavelength,'%f'));
AAE_BR = ang_exp(aop.vdata.Ba_B_combined, aop.vdata.Ba_R_combined, ...
   sscanf(aop.vatts.Ba_B_combined.wavelength,'%f'),sscanf(aop.vatts.Ba_R_combined.wavelength,'%f'));
AAE_GR = ang_exp(aop.vdata.Ba_R_combined, aop.vdata.Ba_G_combined, ...
   sscanf(aop.vatts.Ba_R_combined.wavelength,'%f'),sscanf(aop.vatts.Ba_G_combined.wavelength,'%f'));

figure; plot(aop.time, [aop.vdata.AAE_BG;aop.vdata.AAE_BR;aop.vdata.AAE_GR],'o');dynamicDateTicks
hold('on'); title('AAE')
plot(aop.time,[AAE_BG; AAE_BR; AAE_GR] ,'k.')
!! Problem identified 2017/07/18.  
!! Inconsistent AAE_BG.  Turns out they were being computed from the Virkkula Ba and with adjusted for Neph wls.


SSA_B = aop.vdata.Bs_B ./ (aop.vdata.Bs_B + aop.vdata.Ba_B_combined); 
SSA_G = aop.vdata.Bs_G ./ (aop.vdata.Bs_G + aop.vdata.Ba_G_combined); 
SSA_R = aop.vdata.Bs_R ./ (aop.vdata.Bs_R + aop.vdata.Ba_R_combined); 
figure; plot(aop.time, [aop.vdata.ssa_B; aop.vdata.ssa_G; aop.vdata.ssa_R],'o'); dynamicDateTicks
title('SSA');
hold('on'); xlim(xl)
plot(aop.time, [SSA_B; SSA_G; SSA_R],'k.');

figure; plot(aop.time, [aop.vdata.ssa_B_Virkkula; aop.vdata.ssa_G_Virkkula; aop.vdata.ssa_R_Virkkula],'o'); dynamicDateTicks
title('SSA V');
hold('on');xlim(xl)
plot(aop.time, [SSA_V_B; SSA_V_G; SSA_V_R],'k.');

AE_BG = ang_exp(aop.vdata.Bs_B, aop.vdata.Bs_G, ...
   sscanf(aop.vatts.Bs_B.wavelength,'%f'),sscanf(aop.vatts.Bs_G.wavelength,'%f'));
AE_BR = ang_exp(aop.vdata.Bs_B, aop.vdata.Bs_R, ...
   sscanf(aop.vatts.Bs_B.wavelength,'%f'),sscanf(aop.vatts.Bs_R.wavelength,'%f'));
AE_GR = ang_exp(aop.vdata.Bs_R, aop.vdata.Bs_G, ...
   sscanf(aop.vatts.Bs_R.wavelength,'%f'),sscanf(aop.vatts.Bs_G.wavelength,'%f'));

figure; plot(aop.time, [aop.vdata.AE_BG;aop.vdata.AE_BR;aop.vdata.AE_GR],'o');dynamicDateTicks
title('AE at PSAP wls');hold('on'); plot(aop.time,[AE_BG; AE_BR; AE_GR] ,'k.')

AE_BG_ = ang_exp(aop.vdata.Bs_B_Dry_Neph3W, aop.vdata.Bs_G_Dry_Neph3W, ...
   sscanf(aop.vatts.Bs_B_Dry_Neph3W.wavelength,'%f'),sscanf(aop.vatts.Bs_G_Dry_Neph3W.wavelength,'%f'));
AE_BR_ = ang_exp(aop.vdata.Bs_B_Dry_Neph3W, aop.vdata.Bs_R_Dry_Neph3W, ...
   sscanf(aop.vatts.Bs_B_Dry_Neph3W.wavelength,'%f'),sscanf(aop.vatts.Bs_R_Dry_Neph3W.wavelength,'%f'));
AE_GR_ = ang_exp(aop.vdata.Bs_R_Dry_Neph3W, aop.vdata.Bs_G_Dry_Neph3W, ...
   sscanf(aop.vatts.Bs_R_Dry_Neph3W.wavelength,'%f'),sscanf(aop.vatts.Bs_G_Dry_Neph3W.wavelength,'%f'));
figure; plot(aop.time, [aop.vdata.AE_BG;aop.vdata.AE_BR;aop.vdata.AE_GR],'o');dynamicDateTicks
title('AE at Neph wls');hold('on'); plot(aop.time,[AE_BG_; AE_BR_; AE_GR_] ,'k.'); xlim(xl)

Bs_B = ang_coef(aop.vdata.Bs_B_Dry_Neph3W, AE_BG_,sscanf(aop.vatts.Bs_B_Dry_Neph3W.wavelength,'%f'), sscanf(aop.vatts.Bs_B.wavelength,'%f'));
Bs_G = ang_coef(aop.vdata.Bs_G_Dry_Neph3W, AE_BG_,sscanf(aop.vatts.Bs_G_Dry_Neph3W.wavelength,'%f'), sscanf(aop.vatts.Bs_G.wavelength,'%f'));
Bs_R = ang_coef(aop.vdata.Bs_R_Dry_Neph3W, AE_GR_,sscanf(aop.vatts.Bs_R_Dry_Neph3W.wavelength,'%f'), sscanf(aop.vatts.Bs_R.wavelength,'%f'));

figure; plot(aop.time, [aop.vdata.Bs_B; aop.vdata.Bs_G; aop.vdata.Bs_R],'o'); dynamicDateTicks;
title('Bs at PSAP wls');
hold('on'); plot(aop.time, [Bs_B; Bs_G; Bs_R],'k.'); xlim(xl);
!! Minor differences noted on 2017/07/18.  Seem to be due to computational differences associated with  
!! the fact that the WLs are different and the AAEs are non-constant.
!! But no apparent computational error and the docs are consistent.

return