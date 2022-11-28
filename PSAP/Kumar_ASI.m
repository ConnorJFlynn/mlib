function Kumar_ASI

aop = anc_bundle_files;

% Then repeat the normal averaged Virkula and compare to file to confirm
% V 2010
   k0_ = [0.377, 0.358, 0.352, .362];
   k1_ = [-0.64, -0.64, -0.674, -.651];
   h0_ = [1.16, 1.17, 1.14, 1.159];
   h1_ = [-0.63, -0.71, -0.72, -0.687];
   s_ = [0.015, 0.017, 0.022, 0.018];

   n = 4; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Bv = compute_Virkkula(aop.vdata.transmittance_blue,aop.vdata.Bs_B,aop.vdata.Ba_B_raw,bkhs);
Ba_Gv = compute_Virkkula(aop.vdata.transmittance_green,aop.vdata.Bs_G,aop.vdata.Ba_G_raw,bkhs);
Ba_Rv = compute_Virkkula(aop.vdata.transmittance_red,aop.vdata.Bs_R,aop.vdata.Ba_R_raw,bkhs);
AAE_BGv = ang_exp(Ba_Bv, Ba_Gv, 464,529);
AAE_BRv = ang_exp(Ba_Bv, Ba_Rv, 464,648);
AAE_GRv = ang_exp(Ba_Gv, Ba_Rv, 529,648);

figure; plot(aop.time, aop.vdata.transmittance_green, 'k_', ...
   aop.time, AAE_BGv,'b.', aop.time, AAE_BRv,'g.', aop.time, AAE_GRv,'r.'); 
dynamicDateTicks; logy; title('ASI Virk wl_avg')
ax(1) = gca;


% Then 
% Kumar ARM
   k0_ = [0.135, 0.159, 0.145];
   k1_ = [-0.086, -0.09, -0.062];
   h0_ = [13.018, 1.301, 21.364];
   h1_ = [-12.409, -0.312, -21.11];
   s_ = [0.015, 0.017, 0.022];

   n = 1; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Bk = compute_Virkkula(aop.vdata.transmittance_blue,aop.vdata.Bs_B,aop.vdata.Ba_B_raw,bkhs);

   n = 2; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Gk = compute_Virkkula(aop.vdata.transmittance_green,aop.vdata.Bs_G,aop.vdata.Ba_G_raw,bkhs);

   n = 3; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Rk = compute_Virkkula(aop.vdata.transmittance_red,aop.vdata.Bs_R,aop.vdata.Ba_R_raw,bkhs);

AAE_BGk = ang_exp(Ba_Bk, Ba_Gk, 464,529);
AAE_BRk = ang_exp(Ba_Bk, Ba_Rk, 464,648);
AAE_GRk = ang_exp(Ba_Gk, Ba_Rk, 529,648);

figure; plot(aop.time, aop.vdata.transmittance_green, 'k-',...
   aop.time, AAE_BGk,'b.',aop.time, AAE_BRk,'g.',aop.time, AAE_GRk,'r.'); dynamicDateTicks; logy; title('Kumar ARM')
ax(2) = gca;
linkaxes(ax,'xy');

figure; yy(1) = subplot(2,1,1); plot(aop.time, [Ba_Bk;Ba_Gk;Ba_Rk],'*'); 
dynamicDateTicks; legend('Ba_B_K ARM','Ba_G_K ARM','Ba_R_K ARM');

% Kumar AMT
   k0_ = [0.141, 0.162, 0.148];
   k1_ = [-0.09, -0.092, -0.064];
   h0_ = [11.043, 0.043, 20.35];
   h1_ = [-10.369, 0.547, -20.059];
   s_ = [0.015, 0.017, 0.022];

   n = 1; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Bk = compute_Virkkula(aop.vdata.transmittance_blue,aop.vdata.Bs_B,aop.vdata.Ba_B_raw,bkhs);

   n = 2; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Gk = compute_Virkkula(aop.vdata.transmittance_green,aop.vdata.Bs_G,aop.vdata.Ba_G_raw,bkhs);

   n = 3; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
Ba_Rk = compute_Virkkula(aop.vdata.transmittance_red,aop.vdata.Bs_R,aop.vdata.Ba_R_raw,bkhs);

AAE_BGk = ang_exp(Ba_Bk, Ba_Gk, 464,529);
AAE_BRk = ang_exp(Ba_Bk, Ba_Rk, 464,648);
AAE_GRk = ang_exp(Ba_Gk, Ba_Rk, 529,648);

yy(2) = subplot(2,1,2); plot(aop.time, [Ba_Bk;Ba_Gk;Ba_Rk],'*'); 
dynamicDateTicks; legend('Ba_B_K AMT','Ba_G_K AMT','Ba_R_K AMT');
linkaxes(yy,'xy');

figure; plot(aop.time, aop.vdata.transmittance_green, 'k-',...
   aop.time, AAE_BGk,'b.',aop.time, AAE_BRk,'g.',aop.time, AAE_GRk,'r.'); 
dynamicDateTicks; logy; title('ASI Kumar AMT')
ax(2) = gca;
linkaxes(ax,'xy');

figure; 
xx(1) = subplot(2,1,1); plot(aop.time, [Ba_Bv; Ba_Gv; Ba_Rv],'*');
dynamicDateTicks; legend('Ba_B_V','Ba_G_V','Ba_R_V');

xx(2) = subplot(2,1,2); plot(aop.time, [Ba_Bk;Ba_Gk;Ba_Rk],'*'); 
dynamicDateTicks; legend('Ba_B_K ARM','Ba_G_K ARM','Ba_R_K ARM');
linkaxes(xx,'xy');

return