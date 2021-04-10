% ASI AAE
% This script was used to identify the source of the wavelength-dependence
% in the Virkkula wavelength-specific corrections.  

asipsap = anc_bundle_files(getfullname('*aosaop*.nc','aosaop','Select AOS AOP files'));

asipsap.vdata.AAE_RB_Bond = ang_exp(asipsap.vdata.Ba_R_BondOgren, asipsap.vdata.Ba_B_BondOgren,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_BondOgren.wavelength,'%f'));
asipsap.vdata.AAE_RG_Bond = ang_exp(asipsap.vdata.Ba_R_BondOgren, asipsap.vdata.Ba_G_BondOgren,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_BondOgren.wavelength,'%f'));
asipsap.vdata.AAE_GB_Bond = ang_exp(asipsap.vdata.Ba_G_Bond, asipsap.vdata.Ba_B_BondOgren,...
   sscanf(asipsap.vatts.Ba_G_BondOgren.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_BondOgren.wavelength,'%f'));

Ba_B_Bond = asipsap.vdata.Ba_B_BondOgren;
Ba_G_Bond = asipsap.vdata.Ba_G_BondOgren;
Ba_R_Bond = asipsap.vdata.Ba_R_BondOgren;

AAE_GB_Bond  = asipsap.vdata.AAE_GB_Bond ;
AAE_RB_Bond  = asipsap.vdata.AAE_RB_Bond ;
AAE_RG_Bond  = asipsap.vdata.AAE_RG_Bond ;

ssa_B_Bond = asipsap.vdata.ssa_B_Bond;
ssa_G_Bond = asipsap.vdata.ssa_G_Bond;
ssa_R_Bond = asipsap.vdata.ssa_R_Bond;

Ba_B_Weiss = asipsap.vdata.Ba_B_Weiss;
Ba_G_Weiss = asipsap.vdata.Ba_G_Weiss;
Ba_R_Weiss = asipsap.vdata.Ba_R_Weiss;

AAE_GB_Weiss = ang_exp(Ba_G_Weiss, Ba_B_Weiss,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RB_Weiss = ang_exp(Ba_R_Weiss, Ba_B_Weiss,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RG_Weiss = ang_exp(Ba_R_Weiss,Ba_G_Weiss,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));



asipsap.ncdef.vars.AAE_RB_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_RG_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_GB_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;

asipsap.vatts.AAE_RB_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_RB_Bond.long_name = ['AAE RB Bond'];
asipsap.vatts.AAE_RG_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_RG_Bond.long_name = ['AAE RG Bond'];
asipsap.vatts.AAE_GB_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_GB_Bond.long_name = ['AAE GB Bond'];

% Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa) .* log(Tr)).*Ba_raw - s.*Bs;

k0_ = [0.377, 0.358, 0.352, .362];
k1_ = [-0.64, -0.64, -0.674, -.651];
h0_ = [1.16, 1.17, 1.14, 1.159];
h1_ = [-0.63, -0.71, -0.72, -0.687];
s_ = [0.015, 0.017, 0.022, 0.018];

(k0_ - * k1_ .* (h0_+ h1_.*ssa) .* log(Tr)).*Ba_raw - s_.*Bs;

dk0_G_pct = 100.*(k0_(2)-k0_(4))/ mean(k0_([2,4])); % pos delta increases Bap
dk1_G_pct = 100.*(k1_(2)-k1_(4))/ mean(k1_([2,4])); % neg delta increases Bap
dh0_G_pct = 100.*(h0_(2)-h0_(4))/ mean(h0_([2,4])); % pos delta increases Bap
dh1_G_pct = 100.*(h1_(2)-h1_(4))/ mean(h1_([2,4])); % pos delta increases Bap
ds_G_pct = 100.*(s_(2)-s_(4))/ mean(h1_([2,4]));

dk0_R_pct = 100.*(k0_(3)-k0_(4))/ mean(k0_([3,4])); % decreases Bap
dk1_R_pct = 100.*(k1_(3)-k1_(4))/ mean(k1_([3,4])); % decreases
dh0_R_pct = 100.*(h0_(3)-h0_(4))/ mean(h0_([3,4])); % decreases
dh1_R_pct = 100.*(h1_(3)-h1_(4))/ mean(h1_([3,4])); % increases
ds_R_pct = 100.*(s_(3)-s_(4))/ mean(h1_([3,4]));

dk0_B_pct = 100.*(k0_(1)-k0_(4))/ mean(k0_([1,4]));
dk1_B_pct = 100.*(k1_(1)-k1_(4))/ mean(k1_([1,4]));
dh0_B_pct = 100.*(h0_(1)-h0_(4))/ mean(h0_([1,4]));
dh1_B_pct = 100.*(h1_(1)-h1_(4))/ mean(h1_([1,4]));
ds_B_pct = 100.*(s_(1)-s_(4))/ mean(h1_([1,4]));

% Now, need to check Virkkula corrections in AOS AOP file
% Checking AOS AOP Ba_B_Virkkula...
[Ba_B_Virk_ave,ii_B,ko_B,k1_B,h0_B,h1_B,s_B, ssa_B_ave] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 4);
[Ba_G_Virk_ave,ii_G,ko_G,k1_G,h0_G,h1_G,s_G, ssa_G_ave] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 4);
[Ba_R_Virk_ave,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_ave]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 4);

[Ba_B_Virk_,ii_B,ko_B,k1_B,h0_B,h1_B,s_B, ssa_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 1);
[Ba_G_Virk,ii_G,ko_G,k1_G,h0_G,h1_G,s_G, ssa_G] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 2);
[Ba_R_Virk,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 3);

[Ba_B_Virk_4x,ii_B,ko_B,k1_B,h0_B,h1_B,s_B, ssa_B_4x] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, [4 4 4 4 1]);
[Ba_G_Virk_4x,ii_G,ko_G,k1_G,h0_G,h1_G,s_G, ssa_G_4x] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw,[4 4 4 4 2]);
[Ba_R_Virk_4x,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_4x]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [4 4 4 4 3]);



AAE_GB_Virk_ave = ang_exp(Ba_G_Virk_ave, Ba_B_Virk_ave,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GB_Virk = ang_exp(Ba_G_Virk, Ba_B_Virk,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_GB_Virk_4x = ang_exp(Ba_G_Virk, Ba_B_Virk_4x,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));

AAE_RB_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_B_Virk_ave,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RB_Virk = ang_exp(Ba_R_Virk, Ba_B_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RB_Virk_4x = ang_exp(Ba_R_Virk, Ba_B_Virk_4x,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));

AAE_RG_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_G_Virk_ave,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
AAE_RG_Virk = ang_exp(Ba_R_Virk, Ba_G_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
AAE_RG_Virk_4x = ang_exp(Ba_R_Virk, Ba_G_Virk_4x,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

AAE_GB_raw = ang_exp(asipsap.vdata.Ba_G_raw, asipsap.vdata.Ba_B_raw,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RB_raw = ang_exp(asipsap.vdata.Ba_R_raw, asipsap.vdata.Ba_B_raw,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RG_raw = ang_exp(asipsap.vdata.Ba_R_raw,asipsap.vdata.Ba_G_raw,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));

Ba_B =(Ba_B_Bond + Ba_B_Virk_ave)./2; 
Ba_G =(Ba_G_Bond + Ba_G_Virk_ave)./2;
Ba_R =(Ba_R_Bond + Ba_R_Virk_ave)./2;

AAE_GB = ang_exp(Ba_G, Ba_B, sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RB = ang_exp(Ba_R, Ba_B, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RG = ang_exp(Ba_R, Ba_G, sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba__Virkkula.wavelength,'%f'));

figure; 
ax(1) = subplot(4,1,1);
plot(asipsap.time, [AAE_GB_Weiss; AAE_RB_Weiss; AAE_RG_Weiss],'+'); legend('AAE GB Weiss','AAE RB Weiss','AAE RG Weiss');
dynamicDateTicks
ax(2) = subplot(4,1,2);
plot(asipsap.time, [AAE_GB_Bond; AAE_RB_Bond; AAE_RG_Bond],'+'); legend('AAE GB Bond','AAE RB Bond','AAE RG Bond');
dynamicDateTicks
ax(3) = subplot(4,1,3);
plot(asipsap.time, [AAE_GB_Virk; AAE_RB_Virk; AAE_RG_Virk],'+'); legend('AAE GB Virk','AAE RB Virk','AAE RG Virk');
dynamicDateTicks
ax(4) = subplot(4,1,4);
plot(asipsap.time, [AAE_GB_Virk_ave; AAE_RB_Virk_ave; AAE_RG_Virk_ave],'+'); legend('AAE GB Virk Ave','AAE RB Virk Ave','AAE RG Virk Ave');
dynamicDateTicks
linkaxes(ax,'xy')
figure; plot(asipsap.time, [Ba_B_Virk;Ba_B_Virk_4x;Ba_B_Virk_ave],'.',...
   asipsap.time, Ba_B_Bond, 'k*');
    legend('Ba_B Virk','Ba_B Virk 4x','Ba_B Virk ave','Ba_B Bond');
dynamicDateTicks; 

figure; plot(asipsap.time, [Ba_R_Virk;Ba_R_Virk_4x;Ba_R_Virk_ave],'.',...
   asipsap.time, Ba_R_Bond, 'k*');
    legend('Ba_R Virk','Ba_R Virk 4x','Ba_R Virk ave','Ba_R Bond');
dynamicDateTicks; 


figure; plot(asipsap.time, [Ba_B_Virk_ave;Ba_G_Virk_ave;Ba_R_Virk_ave],'.'); hold('on');
   plot(asipsap.time, [Ba_B_Bond;Ba_G_Bond;Ba_R_Bond], '*',...
   asipsap.time, [Ba_B_Virk;Ba_G_Virk;Ba_R_Virk],'k.');
   hold('off')
    legend('Ba_B Virk ave','Ba_G Virk ave','Ba_R Virk ave','Ba_B Bond', 'Ba_G Bond', 'Ba_R Bond');
dynamicDateTicks; axis(v);



figure; plot(asipsap.time, [AAE_GB_Virk;AAE_GB_Virk_4x;AAE_GB_Virk_ave],'.',...
   asipsap.time, AAE_GB_Bond,'k*');
    legend('AE GB Virk','AE GB Virk x','AE GB Virk ave', 'AE GB Bond'); xlim(xl);
dynamicDateTicks; 

figure; plot(asipsap.time, [AAE_RG_Virk;AAE_RG_Virk_4x;AAE_RG_Virk_ave],'.',...
   asipsap.time, AAE_RG_Bond,'k*');
    legend('AE RG Virk','AE RG Virk x','AE RG Virk ave', 'AE RG Bond'); xlim(xl);
dynamicDateTicks; 



figure; plot(asipsap.time, [ssa_B;ssa_B_4x;ssa_B_ave],'.', ...
   asipsap.time, ssa_B_Bond, 'k*');
    legend('ssa_B Virk','ssa_B Virk 4x','ssa_B Virk Ave', 'ssa_B Bond'); 
dynamicDateTicks; 

figure; plot(asipsap.time, [ssa_R;ssa_R_4x;ssa_R_ave],'.', ...
   asipsap.time, ssa_R_Bond, 'k*');
    legend('ssa_R Virk','ssa_R Virk 4x','ssa_R Virk Ave', 'ssa_R Bond'); 
dynamicDateTicks; 


% Conclusion so far based on AAE GB and SSA B trends is that Virk_B_ave is
% least subject to filter-loading artifacts.
% Next, examine Virk_R 
[dk0_R_pct, dk1_R_pct, dh0_R_pct, dh1_R_pct, ds_R_pct ];
% Ba_V(stay) = (k0 + k1 .* (h0+ h1.*ssa) .* log(Tr)).*Ba_raw - s.*Bs;
[Ba_R_Virk_34444,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_34444] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 4 4 4 4]);
[Ba_R_Virk_43434,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_43434] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [4 3 4 3 4]);
[Ba_R_Virk_33434,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_33434] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 3 4 3 4]);
[Ba_R_Virk_44434,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_44434] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [4 4 4 3 4]);
[Ba_R_Virk_33344,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_33344] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 3 3 4 4]);

[Ba_R_Virk_33333,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_33333] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 3 3 3 3]);
[Ba_R_Virk_34333,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_34333] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 4 3 3 3]);
[Ba_R_Virk_33433,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_33433] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 3 4 3 3]);
[Ba_R_Virk_33343,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_33343] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 3 3 4 3]);
[Ba_R_Virk_34433,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_34433] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 4 4 3 3]);
[Ba_R_Virk_34343,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_34343] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 4 3 4 3]);
[Ba_R_Virk_33443,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_33443] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 3 4 4 3]);
[Ba_R_Virk_34443,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_34443] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 4 4 4 3]);
[Ba_R_Virk_44443,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_44443] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [4 4 4 4 3]);
[Ba_R_Virk_34444,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_34444] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [3 4 4 4 4]);
[Ba_R_Virk_44444,ii_R,ko_R,k1_R,h0_R,h1_R,s_R, ssa_R_44444] = compute_Virkkula(asipsap.vdata.transmittance_red, ...
   asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, [4 4 4 4 4]);


figure; plot(asipsap.time, [Ba_R_Virk_33333;Ba_R_Virk_34333;Ba_R_Virk_33433;Ba_R_Virk_33343;...
   Ba_R_Virk_34433;Ba_R_Virk_34343;Ba_R_Virk_33443;Ba_R_Virk_34443],'.',...
   asipsap.time,  Ba_R_Bond,'k*', asipsap.time,  [Ba_R_Virk_44443;Ba_R_Virk_34444;Ba_R_Virk_44444],'x');
    legend('Ba_R Virk33333','Ba_R Virk34333','Ba_R Virk33433','Ba_R Virk33343',...
   'Ba_R Virk34433','Ba_R Virk34343','Ba_R Virk33443','Ba_R Virk34443','Ba R Bond','44443','34444','44444'); xlim([v(1),v(2)]);
dynamicDateTicks; axis(rv)
rv = axis;

AAE_RG_Virk = ang_exp(Ba_R_Virk, Ba_G_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
AAE_RG_Virk_34444 = ang_exp(Ba_G_Virk_ave, Ba_R_Virk_34444,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'));
AAE_RG_Virk_43434 = ang_exp(Ba_G_Virk_ave, Ba_R_Virk_43434,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'));
AAE_RG_Virk_33434 = ang_exp(Ba_G_Virk_ave, Ba_R_Virk_33434,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'));
AAE_RG_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_G_Virk_ave,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
AAE_RG_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_G_Virk_ave,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
!!
Ba_R_Bond = asipsap.vdata.Ba_R_Bond;
figure; plot(asipsap.time, [Ba_R_Virk;Ba_R_Virk_34444;Ba_R_Virk_33434;Ba_R_Virk_43434;Ba_R_Virk_ave;Ba_R_Virk_44434;Ba_R_Virk_33344],'.'...
   ,asipsap.time,  Ba_R_Bond,'k*');
    legend('Ba R Virk','Ba R Virk 34444','Ba R Virk 33434','Ba R Virk 43434','Ba R Virk 44434',...
       'Ba R Virk 33344','Ba R Virk ave','Ba R Bond'); xlim([v(1),v(2)]);
dynamicDateTicks; 

AAE_RG_Bond = asipsap.vdata.AAE_RG_Bond;
figure; plot(asipsap.time, [AAE_RG_Virk;AAE_RG_Virk_34444;AAE_RG_Virk_33434;AAE_RG_Virk_43434;AAE_RG_Virk_ave],'o',...
   asipsap.time, AAE_RG_Bond,'k*');
    legend('AAE RG Virk','AAE RG Virk 34444','AAE RG Virk 33434','AAE RG Virk 43434','AAE RG Virk ave','AAE RG Bond'); xlim([v(1),v(2)]);
%     title('AAE RG')
dynamicDateTicks; 

figure; plot(asipsap.time, [ssa_R;ssa_R_34444;ssa_R_33434;ssa_R_43434;ssa_R_ave],'o', ...
   asipsap.time, asipsap.vdata.ssa_R_Bond, 'k*');
    legend('ssa_R Virk','ssa_R Virk 34444','ssa_R 33434','ssa_R 43434','ssa_R ave', 'ssa_R Bond');
%     title('SSA R');
dynamicDateTicks; 

!!

AAE_RB_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_B_Virk_ave,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RG_Virk_ave = ang_exp(Ba_R_Virk_ave, Ba_G_Virk_ave,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
AAE_GB_Virk_ave = ang_exp(Ba_G_Virk_ave, Ba_B_Virk_ave,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));

AAE_RB_Virk = ang_exp(Ba_R_Virk, Ba_B_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));
AAE_RG_Virk = ang_exp(Ba_R_Virk, Ba_G_Virk,...
   sscanf(asipsap.vatts.Ba_R_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'));
AAE_GB_Virk = ang_exp(Ba_G_Virk, Ba_B_Virk,...
   sscanf(asipsap.vatts.Ba_G_Virkkula.wavelength,'%f'), sscanf(asipsap.vatts.Ba_B_Virkkula.wavelength,'%f'));






[Ba_B_Virk,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 1);
[Ba_G_Virk,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, 4);
[Ba_B_Virk,ii_B,ko_B,~,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, [1 4 4 1 4]);
[Ba_B_Virk,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, [1 4 4 1 4]);
[Ba_B_Virk,ii_B,ko_B,k1_B,h0_B,h1_B,s_B] = compute_Virkkula(asipsap.vdata.transmittance_blue, asipsap.vdata.Bs_B, asipsap.vdata.Ba_B_raw, [1 4 4 1 4]);

[Ba_G_Virk,ii_G,ko_G,k1_G,h0_G,h1_G,s_G] = compute_Virkkula(asipsap.vdata.transmittance_green, asipsap.vdata.Bs_G, asipsap.vdata.Ba_G_raw, 2);
[Ba_R_Virk,ii_R,ko_R,k1_R,h0_R,h1_R,s_R]= compute_Virkkula(asipsap.vdata.transmittance_red, asipsap.vdata.Bs_R, asipsap.vdata.Ba_R_raw, 3);
% 


figure; plot(asipsap.time, [asipsap.vdata.transmittance_blue; ...
   asipsap.vdata.transmittance_green;asipsap.vdata.transmittance_red],'x'); legend('Tr B','Tr G','Tr R')
title('Transmittances')

figure; plot(asipsap.time, asipsap.vdata.Ba_B_Bond,'b.',...
   asipsap.time, asipsap.vdata.Ba_G_Bond,'g.',...
   asipsap.time, asipsap.vdata.Ba_R_Bond,'r.'); legend('B Bond','G Bond','R Bond')
dynamicDateTicks; 

figure; plot(asipsap.time, Ba_B_Virk,'b.',...
   asipsap.time, Ba_G_Virk,'g.',...
   asipsap.time, Ba_R_Virk,'r.'); legend('B Virk','G Virk','R Virk')
dynamicDateTicks; 

figure; plot(asipsap.time, Ba_B_Virk_ave,'b.',...
   asipsap.time, Ba_G_Virk_ave,'g.',...
   asipsap.time, Ba_R_Virk_ave,'r.'); legend('B Virk avg','G Virk avg','R Virk avg')
dynamicDateTicks; 

figure; plot(asipsap.time, asipsap.vdata.AAE_GB_Bond, '.',...
   asipsap.time, asipsap.vdata.AAE_RB_Bond, '.',...
   asipsap.time, asipsap.vdata.AAE_RG_Bond, '.'); 
title('Bond')
legend('AAE GB','AAE GR', 'AAE RG'); dynamicDateTicks;   

figure; plot(asipsap.time, AAE_GB_Virk, '.',asipsap.time, AAE_RB_Virk, '.',asipsap.time, AAE_RG_Virk, '.'); 
title('Virk RGB')
legend('AAE GB','AAE RB', 'AAE RG'); dynamicDateTicks;   

figure; plot(asipsap.time, AAE_GB_Virk_ave, '.',asipsap.time, AAE_RG_Virk_ave, '.',asipsap.time, AAE_RB_Virk_ave, '.'); 
title('Virk ave')
legend('AAE GB','AAE RG', 'AAE RB'); dynamicDateTicks; 



 

figure;  plot(asipsap.time, Ba_B_Virk, '.',asipsap.time, Ba_G_Virk, '.',asipsap.time, Ba_R_Virk, '.'); dynamicDateTicks
legend('Ba B Virk_ave','Ba G Virk_ave', 'Ba R Virk_ave'); axis(V); 

asipsap.ncdef.vars.AAE_RB_Virk = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_RG_Virk = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_GB_Virk = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_RB_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_RG_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.ncdef.vars.AAE_GB_Bond = asipsap.ncdef.vars.Ba_B_Virkkula;
asipsap.vatts.AAE_RB_Virk = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_RB_Virk.long_name = ['AAE RB Virk'];
asipsap.vatts.AAE_RG_Virk = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_RG_Virk.long_name = ['AAE RG Virk'];
asipsap.vatts.AAE_GB_Virk = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_GB_Virk.long_name = ['AAE GB Virk'];
asipsap.vatts.AAE_RB_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_RB_Bond.long_name = ['AAE RB Bond'];
asipsap.vatts.AAE_RG_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_RG_Bond.long_name = ['AAE RG Bond'];
asipsap.vatts.AAE_GB_Bond = asipsap.vatts.Ba_B_Virkkula; asipsap.vatts.AAE_GB_Bond.long_name = ['AAE GB Bond'];


[sscanf(asipsap.vatts.Ba_R_Bond.wavelength,'%f'),...
   sscanf(asipsap.vatts.Ba_G_Bond.wavelength,'%f'),sscanf(asipsap.vatts.Ba_B_Bond.wavelength,'%f')]


ARM_display_(asipsap)