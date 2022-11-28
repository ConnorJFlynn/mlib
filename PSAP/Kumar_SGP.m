function Kumar_SGP
% Select SGP PSAP 1m.b1 data from June27-Sept25
sgppsap = anc_bundle_files(getfullname('sgpaospsap3w1mC1.b1.*','sgppsap'));
qcs = anc_qc_impacts(sgppsap.vdata.qc_Ba_B_Weiss, sgppsap.vatts.qc_Ba_B_Weiss);
qcs = max([qcs;anc_qc_impacts(sgppsap.vdata.qc_Ba_G_Weiss, sgppsap.vatts.qc_Ba_G_Weiss)]);
qcs = max([qcs;anc_qc_impacts(sgppsap.vdata.qc_Ba_R_Weiss, sgppsap.vatts.qc_Ba_R_Weiss)]);
sgppsap = anc_sift(sgppsap,qcs==0); % keep only those with qcs==0

sgpneph = anc_bundle_files(getfullname('sgpaosnephdry1mC1.b1.*','sgpneph'));
qcs = anc_qc_impacts(sgpneph.vdata.qc_Bs_B_Dry_Neph3W, sgpneph.vatts.qc_Bs_B_Dry_Neph3W);
qcs = max([qcs;anc_qc_impacts(sgpneph.vdata.qc_Bs_G_Dry_Neph3W, sgpneph.vatts.qc_Bs_G_Dry_Neph3W)]);
qcs = max([qcs;anc_qc_impacts(sgpneph.vdata.qc_Bs_R_Dry_Neph3W, sgpneph.vatts.qc_Bs_R_Dry_Neph3W)]);
sgpneph = anc_sift(sgpneph,qcs==0); % keep only those with qcs==0

[pinn, ninp] = nearest(sgppsap.time, sgpneph.time, 3./(24*60)); % Identify coincident PSAP and Neph measurements

sgppsap = anc_sift(sgppsap, pinn); %Keep only coincident times
sgpneph = anc_sift(sgpneph,ninp);

% Virkkula 2010 parameters.  4th column is avg.
k0_ = [0.377, 0.358, 0.352, .362];
k1_ = [-0.64, -0.64, -0.674, -.651];
h0_ = [1.16, 1.17, 1.14, 1.159];
h1_ = [-0.63, -0.71, -0.72, -0.687];
s_ = [0.015, 0.017, 0.022, 0.018];

n = 4; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)]; % Form a vector of the average parameters.

Ba_Bv = compute_Virkkula(sgppsap.vdata.transmittance_blue,sgpneph.vdata.Bs_B_Dry_Neph3W,sgppsap.vdata.Ba_B_raw,bkhs);
Ba_Gv = compute_Virkkula(sgppsap.vdata.transmittance_green,sgpneph.vdata.Bs_G_Dry_Neph3W,sgppsap.vdata.Ba_G_raw,bkhs);
Ba_Rv = compute_Virkkula(sgppsap.vdata.transmittance_red,sgpneph.vdata.Bs_R_Dry_Neph3W,sgppsap.vdata.Ba_R_raw,bkhs);

AAE_BGv = ang_exp(Ba_Bv, Ba_Gv, 464,529);
AAE_BRv = ang_exp(Ba_Bv, Ba_Rv, 464,648);
AAE_GRv = ang_exp(Ba_Gv, Ba_Rv, 529,648);

figure; plot(sgppsap.time, sgppsap.vdata.transmittance_green, 'k-', ...
   sgppsap.time, AAE_BGv,'b.', sgppsap.time, AAE_BRv,'g.', sgppsap.time, AAE_GRv,'r.');
dynamicDateTicks; logy; title('SGP Virk Avg'); ax(1) = gca;


% Then try Kumar ARM poster values
k0_ = [0.135, 0.159, 0.145];
k1_ = [-0.086, -0.09, -0.062];
h0_ = [13.018, 1.301, 21.364];
h1_ = [-12.409, -0.312, -21.11];
s_ = [0.015, 0.017, 0.022];

n = 1; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)]; % n=1 for column 1 values, Blue
Ba_Bk = compute_Virkkula(sgppsap.vdata.transmittance_blue,sgpneph.vdata.Bs_B_Dry_Neph3W,sgppsap.vdata.Ba_B_raw,bkhs);
n = 2; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)]; % n=2 for Green
Ba_Gk = compute_Virkkula(sgppsap.vdata.transmittance_green,sgpneph.vdata.Bs_G_Dry_Neph3W,sgppsap.vdata.Ba_G_raw,bkhs);
n = 3; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)]; % n=3 for Red
Ba_Rk = compute_Virkkula(sgppsap.vdata.transmittance_red,sgpneph.vdata.Bs_R_Dry_Neph3W,sgppsap.vdata.Ba_R_raw,bkhs);

AAE_BGk = ang_exp(Ba_Bk, Ba_Gk, 464,529);
AAE_BRk = ang_exp(Ba_Bk, Ba_Rk, 464,648);
AAE_GRk = ang_exp(Ba_Gk, Ba_Rk, 529,648);

figure; plot(sgppsap.time, sgppsap.vdata.transmittance_green, 'k-', ...
   sgppsap.time, AAE_BGk,'b.', sgppsap.time, AAE_BRk,'g.', sgppsap.time, AAE_GRk,'r.'); 
dynamicDateTicks; logy; title('SGP Kumar AMT'); 
ax(2) = gca;

linkaxes(ax,'xy')

figure; yy(1) = subplot(2,1,1); plot(sgppsap.time, [Ba_Bk;Ba_Gk;Ba_Rk],'*'); 
dynamicDateTicks; legend('Ba_B_K ARM','Ba_G_K ARM','Ba_R_K ARM');

% Kumar AMT
   k0_ = [0.141, 0.162, 0.148];
   k1_ = [-0.09, -0.092, -0.064];
   h0_ = [11.043, 0.043, 20.35];
   h1_ = [-10.369, 0.547, -20.059];
   s_ = [0.015, 0.017, 0.022];
   n = 1; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
   Ba_Bk = compute_Virkkula(sgppsap.vdata.transmittance_blue,sgpneph.vdata.Bs_B_Dry_Neph3W,sgppsap.vdata.Ba_B_raw,bkhs);
   n = 2; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
   Ba_Gk = compute_Virkkula(sgppsap.vdata.transmittance_green,sgpneph.vdata.Bs_G_Dry_Neph3W,sgppsap.vdata.Ba_G_raw,bkhs);
   n = 3; bkhs = [k0_(n),k1_(n),h0_(n),h1_(n),s_(n)];
   Ba_Rk = compute_Virkkula(sgppsap.vdata.transmittance_red,sgpneph.vdata.Bs_R_Dry_Neph3W,sgppsap.vdata.Ba_R_raw,bkhs);


AAE_BGk = ang_exp(Ba_Bk, Ba_Gk, 464,529);
AAE_BRk = ang_exp(Ba_Bk, Ba_Rk, 464,648);
AAE_GRk = ang_exp(Ba_Gk, Ba_Rk, 529,648);

yy(2) = subplot(2,1,2); plot(sgppsap.time, [Ba_Bk;Ba_Gk;Ba_Rk],'*'); 
dynamicDateTicks; legend('Ba_B_K AMT','Ba_G_K AMT','Ba_R_K AMT');
linkaxes(yy,'xy');

figure; 
xx(1) = subplot(2,1,1); plot(sgppsap.time, [Ba_Bv; Ba_Gv; Ba_Rv],'*');
dynamicDateTicks; legend('Ba_B_V','Ba_G_V','Ba_R_V');

xx(2) = subplot(2,1,2); plot(sgppsap.time, [Ba_Bk;Ba_Gk;Ba_Rk],'*'); 
dynamicDateTicks; legend('Ba_B_K ARM','Ba_G_K ARM','Ba_R_K ARM');
linkaxes(xx,'xy');

xl = xlim;
figure; plot(sgpneph.time, sgpneph.vdata.Bs_B_Dry_Neph3W,'*'); xlim(xl);legend('SGP Bs B');
dynamicDateTicks
end