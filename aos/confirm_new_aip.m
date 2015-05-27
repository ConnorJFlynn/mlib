% Check aip with angstrom adjustement of neph R B and 3W psap G
aip_old = ancload;
%%

aip_new = ancload;
%%

R_neph = 700;
G_neph = 550;
B_neph = 450;
R_psap3W = 660;
G_psap3W = 530;
B_psap3W = 467;

% First check that the angstrom exponents are properly computed.
%
%%

Bs_ang_BG_1um = ang_exp(aip_old.vars.Bs_B_Dry_1um_Neph3W_1.data, aip_old.vars.Bs_G_Dry_1um_Neph3W_1.data, B_neph, G_neph);
Bs_ang_BR_1um = ang_exp(aip_old.vars.Bs_B_Dry_1um_Neph3W_1.data, aip_old.vars.Bs_R_Dry_1um_Neph3W_1.data, B_neph,R_neph);
Bs_ang_GR_1um = ang_exp(aip_old.vars.Bs_G_Dry_1um_Neph3W_1.data, aip_old.vars.Bs_R_Dry_1um_Neph3W_1.data, G_neph, R_neph);
Bs_ang_BG_10um = ang_exp(aip_old.vars.Bs_B_Dry_10um_Neph3W_1.data, aip_old.vars.Bs_G_Dry_10um_Neph3W_1.data, B_neph, G_neph);
Bs_ang_BR_10um = ang_exp(aip_old.vars.Bs_B_Dry_10um_Neph3W_1.data, aip_old.vars.Bs_R_Dry_10um_Neph3W_1.data, B_neph,R_neph);
Bs_ang_GR_10um = ang_exp(aip_old.vars.Bs_G_Dry_10um_Neph3W_1.data, aip_old.vars.Bs_R_Dry_10um_Neph3W_1.data, G_neph, R_neph);

Bbs_ang_BG_1um = ang_exp(aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data, aip_new.vars.Bbs_G_Dry_1um_Neph3W_1.data, B_psap3W, G_neph);
Bbs_ang_BR_1um = ang_exp(aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data, aip_new.vars.Bbs_R_Dry_1um_Neph3W_1.data, B_psap3W,R_psap3W);
Bbs_ang_GR_1um = ang_exp(aip_new.vars.Bbs_G_Dry_1um_Neph3W_1.data, aip_new.vars.Bbs_R_Dry_1um_Neph3W_1.data, G_neph, R_psap3W);
Bbs_ang_BG_10um = ang_exp(aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data, aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data, B_psap3W, G_neph);
Bbs_ang_BR_10um = ang_exp(aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data, aip_new.vars.Bbs_R_Dry_10um_Neph3W_1.data, B_psap3W,R_psap3W);
Bbs_ang_GR_10um = ang_exp(aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data, aip_new.vars.Bbs_R_Dry_10um_Neph3W_1.data, G_neph, R_psap3W);

Ba_ang_BG_1um = ang_exp(aip_old.vars.Ba_B_Dry_1um_PSAP3W_1.data, aip_old.vars.Ba_G_Dry_1um_PSAP3W_1.data, B_psap3W, G_psap3W);
Ba_ang_BR_1um = ang_exp(aip_old.vars.Ba_B_Dry_1um_PSAP3W_1.data, aip_old.vars.Ba_R_Dry_1um_PSAP3W_1.data, B_psap3W,R_psap3W);
Ba_ang_GR_1um = ang_exp(aip_old.vars.Ba_G_Dry_1um_PSAP3W_1.data, aip_old.vars.Ba_R_Dry_1um_PSAP3W_1.data, G_psap3W, R_psap3W);
Ba_ang_BG_10um = ang_exp(aip_old.vars.Ba_B_Dry_10um_PSAP3W_1.data, aip_old.vars.Ba_G_Dry_10um_PSAP3W_1.data, B_psap3W, G_psap3W);
Ba_ang_BR_10um = ang_exp(aip_old.vars.Ba_B_Dry_10um_PSAP3W_1.data, aip_old.vars.Ba_R_Dry_10um_PSAP3W_1.data, B_psap3W,R_psap3W);
Ba_ang_GR_10um = ang_exp(aip_old.vars.Ba_G_Dry_10um_PSAP3W_1.data, aip_old.vars.Ba_R_Dry_10um_PSAP3W_1.data, G_psap3W, R_psap3W);

Bs_B_Dry_1um = ang_coef(aip_old.vars.Bs_B_Dry_1um_Neph3W_1.data, Bs_ang_BG_1um, B_neph, B_psap3W);
Bs_G_Dry_1um = ang_coef(aip_old.vars.Bs_G_Dry_1um_Neph3W_1.data, Bs_ang_BG_1um, G_neph, G_neph);
Bs_R_Dry_1um = ang_coef(aip_old.vars.Bs_R_Dry_1um_Neph3W_1.data, Bs_ang_GR_1um, R_neph, R_psap3W);
Bs_B_Dry_10um = ang_coef(aip_old.vars.Bs_B_Dry_10um_Neph3W_1.data, Bs_ang_BG_10um, B_neph, B_psap3W);
Bs_G_Dry_10um = ang_coef(aip_old.vars.Bs_G_Dry_10um_Neph3W_1.data, Bs_ang_BG_10um, G_neph, G_neph);
Bs_R_Dry_10um = ang_coef(aip_old.vars.Bs_R_Dry_10um_Neph3W_1.data, Bs_ang_GR_10um, R_neph, R_psap3W);

Bbs_B_Dry_1um = ang_coef(aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data, Bbs_ang_BG_1um,B_psap3W, B_psap3W);
Bbs_G_Dry_1um = ang_coef(aip_new.vars.Bbs_G_Dry_1um_Neph3W_1.data, Bbs_ang_BG_1um, G_neph, G_neph);
Bbs_R_Dry_1um = ang_coef(aip_new.vars.Bbs_R_Dry_1um_Neph3W_1.data, Bbs_ang_GR_1um, R_psap3W, R_psap3W);
Bbs_B_Dry_10um = ang_coef(aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data, Bbs_ang_BG_10um, B_psap3W, B_psap3W);
Bbs_G_Dry_10um = ang_coef(aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data, Bbs_ang_BG_10um, G_neph, G_neph);
Bbs_R_Dry_10um = ang_coef(aip_new.vars.Bbs_R_Dry_10um_Neph3W_1.data, Bbs_ang_GR_10um,R_psap3W, R_psap3W);

Ba_B_Dry_1um = ang_coef(aip_old.vars.Ba_B_Dry_1um_PSAP3W_1.data, Ba_ang_BG_1um, B_psap3W, B_psap3W);
Ba_G_Dry_1um = ang_coef(aip_old.vars.Ba_G_Dry_1um_PSAP3W_1.data, Ba_ang_BG_1um, G_psap3W, G_neph);
Ba_R_Dry_1um = ang_coef(aip_old.vars.Ba_R_Dry_1um_PSAP3W_1.data, Ba_ang_GR_1um, R_psap3W, R_psap3W);
Ba_B_Dry_10um = ang_coef(aip_old.vars.Ba_B_Dry_10um_PSAP3W_1.data, Ba_ang_BG_10um, B_psap3W, B_psap3W);
Ba_G_Dry_10um = ang_coef(aip_old.vars.Ba_G_Dry_10um_PSAP3W_1.data, Ba_ang_BG_10um, G_psap3W, G_neph);
Ba_R_Dry_10um = ang_coef(aip_old.vars.Ba_R_Dry_10um_PSAP3W_1.data, Ba_ang_GR_10um, R_psap3W, R_psap3W);
%%
figure;
ax(1) = subplot(2,1,1); 
plot(serial2Hh(aip_old.time), [Bs_B_Dry_1um; Bs_G_Dry_1um; Bs_R_Dry_1um], 'o', ...
   serial2Hh(aip_new.time), [aip_new.vars.Bs_B_Dry_1um_Neph3W_1.data;aip_new.vars.Bs_G_Dry_1um_Neph3W_1.data;aip_new.vars.Bs_R_Dry_1um_Neph3W_1.data ], '.')
title('Bs 1 um')
ax(2) = subplot(2,1,2); 
plot(serial2Hh(aip_old.time), [Bs_B_Dry_10um; Bs_G_Dry_10um; Bs_R_Dry_10um], 'o', ...
   serial2Hh(aip_new.time), [aip_new.vars.Bs_B_Dry_10um_Neph3W_1.data;aip_new.vars.Bs_G_Dry_10um_Neph3W_1.data;aip_new.vars.Bs_R_Dry_10um_Neph3W_1.data ], '.')
title('Bs 10 um')
linkaxes(ax,'xy');
%%

figure;
ax(1) = subplot(2,1,1); 
plot(serial2Hh(aip_old.time), [Bbs_B_Dry_1um; Bbs_G_Dry_1um; Bbs_R_Dry_1um], 'o', ...
   serial2Hh(aip_new.time), [aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data;aip_new.vars.Bbs_G_Dry_1um_Neph3W_1.data;aip_new.vars.Bbs_R_Dry_1um_Neph3W_1.data ], '.')
title('Bbs 1 um')
ax(2) = subplot(2,1,2); 
plot(serial2Hh(aip_old.time), [Bbs_B_Dry_10um; Bbs_G_Dry_10um; Bbs_R_Dry_10um], 'o', ...
   serial2Hh(aip_new.time), [aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data;aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data;aip_new.vars.Bbs_R_Dry_10um_Neph3W_1.data ], '.')
title('Bbs 10 um')
linkaxes(ax,'xy');
%%

figure;
ax(1) = subplot(2,1,1); 
plot(serial2Hh(aip_old.time), [Ba_B_Dry_1um; Ba_G_Dry_1um; Ba_R_Dry_1um], 'o', ...
   serial2Hh(aip_new.time), [aip_new.vars.Ba_B_Dry_1um_PSAP3W_1.data;aip_new.vars.Ba_G_Dry_1um_PSAP3W_1.data;aip_new.vars.Ba_R_Dry_1um_PSAP3W_1.data ], '.')
title('Ba 1 um')
ax(2) = subplot(2,1,2); 
plot(serial2Hh(aip_old.time), [Ba_B_Dry_10um; Ba_G_Dry_10um; Ba_R_Dry_10um], 'o', ...
   serial2Hh(aip_new.time), [aip_new.vars.Ba_B_Dry_10um_PSAP3W_1.data;aip_new.vars.Ba_G_Dry_10um_PSAP3W_1.data;aip_new.vars.Ba_R_Dry_10um_PSAP3W_1.data ], '.')
title('Ba 10 um')
linkaxes(ax,'xy');
% axis(v)

%%

figure; ax(1) = subplot(3,1,1); plot(serial2Hh(aip_old.time), aip_old.vars.angstrom_exponent_BG_Dry_1um.data, 'bo', ...
   serial2Hh(aip_old.time), Bs_ang_BG_1um, 'bx', ...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BG_Dry_1um.data, 'b.');
title('Bs 1um angstrom exponent')
legend('old','me','new')

ax(2) = subplot(3,1,2); 
plot(serial2Hh(aip_old.time), aip_old.vars.angstrom_exponent_BR_Dry_1um.data, 'go', ...
   serial2Hh(aip_old.time), Bs_ang_BR_1um, 'gx', ...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BR_Dry_1um.data, 'g.');

ax(3) = subplot(3,1,3);
plot(serial2Hh(aip_old.time), aip_old.vars.angstrom_exponent_GR_Dry_1um.data, 'ro', ...
   serial2Hh(aip_old.time), Bs_ang_GR_1um, 'rx', ...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_GR_Dry_1um.data, 'r.');

figure; ax(4) = subplot(3,1,1); plot(serial2Hh(aip_old.time), aip_old.vars.angstrom_exponent_BG_Dry_10um.data, 'bo', ...
   serial2Hh(aip_old.time), Bs_ang_BG_10um, 'bx', ...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BG_Dry_10um.data, 'b.');
title('Bs 10 um angstrom exponent')
legend('old','me','new')

ax(5) = subplot(3,1,2); 
plot(serial2Hh(aip_old.time), aip_old.vars.angstrom_exponent_BR_Dry_10um.data, 'go', ...
   serial2Hh(aip_old.time), Bs_ang_BR_10um, 'gx', ...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BR_Dry_10um.data, 'g.');

ax(6) = subplot(3,1,3);
plot(serial2Hh(aip_old.time), aip_old.vars.angstrom_exponent_GR_Dry_10um.data, 'ro', ...
   serial2Hh(aip_old.time), Bs_ang_GR_10um, 'rx', ...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_GR_Dry_10um.data, 'r.');
linkaxes(ax,'xy');

ylim([0,3])


%%

figure; ax(1) = subplot(3,1,1); plot(serial2Hh(aip_old.time), Bbs_ang_BG_1um, 'bo', ...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BG_Dry_1um.data, 'b.');
title('Bbs 1um angstrom exponent')
legend('me','new')

ax(2) = subplot(3,1,2); 
plot(serial2Hh(aip_old.time), Bbs_ang_BR_1um, 'go', ...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BR_Dry_1um.data, 'g.');

ax(3) = subplot(3,1,3);
plot(serial2Hh(aip_old.time), Bbs_ang_GR_1um, 'ro', ...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_GR_Dry_1um.data, 'r.');

figure; ax(4) = subplot(3,1,1); plot(serial2Hh(aip_old.time), Bbs_ang_BG_10um, 'bo', ...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BG_Dry_10um.data, 'b.');
title('Bbs 10um angstrom exponent')
legend('me','new')

ax(5) = subplot(3,1,2); 
plot(serial2Hh(aip_old.time), Bbs_ang_BR_10um, 'go', ...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BR_Dry_10um.data, 'g.');

ax(6) = subplot(3,1,3);
plot(serial2Hh(aip_old.time), Bbs_ang_GR_10um, 'ro', ...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_GR_Dry_10um.data, 'r.');
linkaxes(ax,'xy');

ylim([-3,3])

%%
clear ax
figure; ax(1) = subplot(3,1,1); plot(serial2Hh(aip_old.time), Ba_ang_BG_1um, 'bo', ...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BG_Dry_1um.data, 'b.');
title('Ba 1um angstrom exponent')
legend('me','new')

ax(2) = subplot(3,1,2); 
plot(serial2Hh(aip_old.time), Ba_ang_BR_1um, 'go', ...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BR_Dry_1um.data, 'g.');

ax(3) = subplot(3,1,3);
plot(serial2Hh(aip_old.time), Ba_ang_GR_1um, 'ro', ...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_GR_Dry_1um.data, 'r.');
linkaxes(ax,'xy');

ylim([0,3])

figure; ax(4) = subplot(3,1,1); plot(serial2Hh(aip_old.time), Ba_ang_BG_10um, 'bo', ...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BG_Dry_10um.data, 'b.');
title('Ba 10um angstrom exponent')
legend('me','new')

ax(5) = subplot(3,1,2); 
plot(serial2Hh(aip_old.time), Ba_ang_BR_10um, 'go', ...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BR_Dry_10um.data, 'g.');

ax(6) = subplot(3,1,3);
plot(serial2Hh(aip_old.time), Ba_ang_GR_10um, 'ro', ...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_GR_Dry_10um.data, 'r.');
linkaxes(ax,'xy');

ylim([0,3])

%%
figure; 
ax(1) = subplot(2,1,1);
plot(...
   serial2Hh(aip_old.time), aip_old.vars.Bs_R_Dry_1um_Neph3W_1.data, 'ro',...
   serial2Hh(aip_old.time), aip_old.vars.Bs_G_Dry_1um_Neph3W_1.data, 'go',...
   serial2Hh(aip_old.time), aip_old.vars.Bs_B_Dry_1um_Neph3W_1.data, 'bo',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_R_Dry_1um_Neph3W_1.data, 'r.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_G_Dry_1um_Neph3W_1.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_B_Dry_1um_Neph3W_1.data, 'b.')
title('Neph Bs 1 um values and angstrom exponents')
legend(['old R =' num2str(R_neph)], ['old G = ' num2str(G_neph)], ['old B = ' num2str(B_neph)], ...
   ['new R = ' num2str(R_psap3W)], ['new G = ' num2str(G_neph)], ['new B = ' num2str(B_psap3W)]);

ax(2) = subplot(2,1,2);
plot(...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BG_Dry_1um.data, 'b.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BR_Dry_1um.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_GR_Dry_1um.data, 'r.')
linkaxes(ax,'x')
ylim([0,3])
%%
clear ax
figure; 
ax(1) = subplot(2,1,1);
plot(...
   serial2Hh(aip_old.time), aip_old.vars.Bs_R_Dry_10um_Neph3W_1.data, 'ro',...
   serial2Hh(aip_old.time), aip_old.vars.Bs_G_Dry_10um_Neph3W_1.data, 'go',...
   serial2Hh(aip_old.time), aip_old.vars.Bs_B_Dry_10um_Neph3W_1.data, 'bo',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_R_Dry_10um_Neph3W_1.data, 'r.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_G_Dry_10um_Neph3W_1.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_B_Dry_10um_Neph3W_1.data, 'b.')
title('Neph Bs 10 um values and angstrom exponents')

legend(['old R =' num2str(R_neph)], ['old G = ' num2str(G_neph)], ['old B = ' num2str(B_neph)], ...
   ['new R = ' num2str(R_psap3W)], ['new G = ' num2str(G_neph)], ['new B = ' num2str(B_psap3W)]);

ax(2) = subplot(2,1,2);
plot(...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BG_Dry_10um.data, 'b.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_BR_Dry_10um.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bs_angstrom_exponent_GR_Dry_10um.data, 'r.')

linkaxes(ax,'x')

%%
clear ax
figure; 
ax(1) = subplot(2,1,1);
plot(...
   serial2Hh(aip_old.time), aip_old.vars.Bbs_R_Dry_1um_Neph3W_1.data, 'ro',...
   serial2Hh(aip_old.time), aip_old.vars.Bbs_G_Dry_1um_Neph3W_1.data, 'go',...
   serial2Hh(aip_old.time), aip_old.vars.Bbs_B_Dry_1um_Neph3W_1.data, 'bo',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_R_Dry_1um_Neph3W_1.data, 'r.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_G_Dry_1um_Neph3W_1.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data, 'b.')
title('Neph Bbs 1 um values and angstrom exponents')
legend(['old R =' num2str(R_neph)], ['old G = ' num2str(G_neph)], ['old B = ' num2str(B_neph)], ...
   ['new R = ' num2str(R_psap3W)], ['new G = ' num2str(G_neph)], ['new B = ' num2str(B_psap3W)]);

ax(2) = subplot(2,1,2);
plot(...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BG_Dry_1um.data, 'b.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BR_Dry_1um.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_GR_Dry_1um.data, 'r.')
linkaxes(ax,'x')
ylim([0,3])
%%
figure; 
ax(1) = subplot(2,1,1);
plot(...
   serial2Hh(aip_old.time), aip_old.vars.Bbs_R_Dry_10um_Neph3W_1.data, 'ro',...
   serial2Hh(aip_old.time), aip_old.vars.Bbs_G_Dry_10um_Neph3W_1.data, 'go',...
   serial2Hh(aip_old.time), aip_old.vars.Bbs_B_Dry_10um_Neph3W_1.data, 'bo',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_R_Dry_10um_Neph3W_1.data, 'r.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data, 'b.')
title('Neph Bbs 10 um values and angstrom exponents')
legend(['old R =' num2str(R_neph)], ['old G = ' num2str(G_neph)], ['old B = ' num2str(B_neph)], ...
   ['new R = ' num2str(R_psap3W)], ['new G = ' num2str(G_neph)], ['new B = ' num2str(B_psap3W)]);

ax(2) = subplot(2,1,2);
plot(...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BG_Dry_10um.data, 'b.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BR_Dry_10um.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_GR_Dry_10um.data, 'r.')
linkaxes(ax,'x')
%%
figure; 
ax(1) = subplot(2,1,1);
plot(...
   serial2Hh(aip_old.time), aip_old.vars.Ba_R_Dry_1um_PSAP3W_1.data, 'ro',...
   serial2Hh(aip_old.time), aip_old.vars.Ba_G_Dry_1um_PSAP3W_1.data, 'go',...
   serial2Hh(aip_old.time), aip_old.vars.Ba_B_Dry_1um_PSAP3W_1.data, 'bo',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_R_Dry_1um_PSAP3W_1.data, 'r.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_G_Dry_1um_PSAP3W_1.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_B_Dry_1um_PSAP3W_1.data, 'b.')
title('1 um PSAP values')
legend(['old R =' num2str(R_psap3W)], ['old G = ' num2str(G_psap3W)], ['old B = ' num2str(B_psap3W)], ...
   ['new R = ' num2str(R_psap3W)], ['new G = ' num2str(G_neph)], ['new B = ' num2str(B_psap3W)]);


ax(2) = subplot(2,1,2);
plot(...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BG_Dry_1um.data, 'b.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BR_Dry_1um.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_GR_Dry_1um.data, 'r.')

linkaxes(ax,'x')

%%
figure; 
ax(1) = subplot(2,1,1);
plot(...
   serial2Hh(aip_old.time), aip_old.vars.Ba_R_Dry_10um_PSAP3W_1.data, 'ro',...
   serial2Hh(aip_old.time), aip_old.vars.Ba_G_Dry_10um_PSAP3W_1.data, 'go',...
   serial2Hh(aip_old.time), aip_old.vars.Ba_B_Dry_10um_PSAP3W_1.data, 'bo',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_R_Dry_10um_PSAP3W_1.data, 'r.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_G_Dry_10um_PSAP3W_1.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_B_Dry_10um_PSAP3W_1.data, 'b.')
title('10 um PSAP values')
legend(['old R =' num2str(R_psap3W)], ['old G = ' num2str(G_psap3W)], ['old B = ' num2str(B_psap3W)], ...
   ['new R = ' num2str(R_psap3W)], ['new G = ' num2str(G_neph)], ['new B = ' num2str(B_psap3W)]);


ax(2) = subplot(2,1,2);
plot(...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BG_Dry_10um.data, 'b.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_BR_Dry_10um.data, 'g.',...
   serial2Hh(aip_new.time), aip_new.vars.Ba_angstrom_exponent_GR_Dry_10um.data, 'r.')

linkaxes(ax,'x')
%%
!! 
%Check 1 min file from here on out.
%%
% Test for inf.
fields = fieldnames(aip_new.vars);
for f = 1:length(fields)
   not_good = sum(~isfinite(aip_new.vars.(fields{f}).data));
   if not_good>0
      disp([num2str(not_good), ' values of ',fields{f}, ' are not finite.']);
   end
end
%%

% Have compared extensive and angstrom for Bs, Bbs, and Ba for both size
% cuts.  Now verify computation of ssa, bsf, usf, and g.

ssa_1um_B = Bs_B_Dry_1um ./ (Bs_B_Dry_1um + Ba_B_Dry_1um);
ssa_1um_G = Bs_G_Dry_1um ./ (Bs_G_Dry_1um + Ba_G_Dry_1um);
ssa_1um_R = Bs_R_Dry_1um ./ (Bs_R_Dry_1um + Ba_R_Dry_1um);
ssa_10um_B = Bs_B_Dry_10um ./ (Bs_B_Dry_10um + Ba_B_Dry_10um);
ssa_10um_G = Bs_G_Dry_10um ./ (Bs_G_Dry_10um + Ba_G_Dry_10um);
ssa_10um_R = Bs_R_Dry_10um ./ (Bs_R_Dry_10um + Ba_R_Dry_10um);

%%

figure;
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_new.time), [aip_new.vars.ssa_B_Dry_1um.data;aip_new.vars.ssa_G_Dry_1um.data;aip_new.vars.ssa_R_Dry_1um.data],'o',...
   serial2Hh(aip_old.time), [ssa_1um_B; ssa_1um_G; ssa_1um_R], '.');
title('1 um SSA');
legend('B','G','R')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_new.time), [aip_new.vars.ssa_B_Dry_10um.data;aip_new.vars.ssa_G_Dry_10um.data;aip_new.vars.ssa_R_Dry_10um.data],'o',...
   serial2Hh(aip_old.time), [ssa_10um_B; ssa_10um_G; ssa_10um_R], '.');
title('10 um SSA');
linkaxes(ax,'xy')
disp(['Difference in green SSA, both size cuts.'])
%%
bsf_1um_B = Bbs_B_Dry_1um ./ Bs_B_Dry_1um;
bsf_1um_G = Bbs_G_Dry_1um ./ Bs_G_Dry_1um;
bsf_1um_R = Bbs_R_Dry_1um ./ Bs_R_Dry_1um;
bsf_10um_B = Bbs_B_Dry_10um ./ Bs_B_Dry_10um;
bsf_10um_G = Bbs_G_Dry_10um ./ Bs_G_Dry_10um;
bsf_10um_R = Bbs_R_Dry_10um ./ Bs_R_Dry_10um;

usf_1um_B = usf_v_bsf(bsf_1um_B);
usf_1um_G = usf_v_bsf(bsf_1um_G);
usf_1um_R = usf_v_bsf(bsf_1um_R);
usf_10um_B = usf_v_bsf(bsf_10um_B);
usf_10um_G = usf_v_bsf(bsf_10um_G);
usf_10um_R = usf_v_bsf(bsf_10um_R);

g_1um_B = g_v_usf(usf_1um_B);
g_1um_G = g_v_usf(usf_1um_G);
g_1um_R = g_v_usf(usf_1um_R);
g_10um_B = g_v_usf(usf_10um_B);
g_10um_G = g_v_usf(usf_10um_G);
g_10um_R = g_v_usf(usf_10um_R);


figure;
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_new.time), [aip_new.vars.bsf_B_Dry_1um.data;aip_new.vars.bsf_G_Dry_1um.data;aip_new.vars.bsf_R_Dry_1um.data],'o',...
   serial2Hh(aip_old.time), [bsf_1um_B; bsf_1um_G; bsf_1um_R], '.');
title('1 um BSF');
legend('B','G','R')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_new.time), [aip_new.vars.bsf_B_Dry_10um.data;aip_new.vars.bsf_G_Dry_10um.data;aip_new.vars.bsf_R_Dry_10um.data],'o',...
   serial2Hh(aip_old.time), [bsf_10um_B; bsf_10um_G; bsf_10um_R], '.');
title('10 um BSF');
linkaxes(ax,'xy')
%%
figure;
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_new.time), [aip_new.vars.usf_B_Dry_1um.data;aip_new.vars.usf_G_Dry_1um.data;aip_new.vars.usf_R_Dry_1um.data],'o',...
   serial2Hh(aip_old.time), [usf_1um_B; usf_1um_G; usf_1um_R], '.');
title('1 um USF');
legend('B','G','R')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_new.time), [aip_new.vars.usf_B_Dry_10um.data;aip_new.vars.usf_G_Dry_10um.data;aip_new.vars.usf_R_Dry_10um.data],'o',...
   serial2Hh(aip_old.time), [usf_10um_B; usf_10um_G; usf_10um_R], '.');
title('10 um USF');
linkaxes(ax,'xy')
%%
figure;
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_new.time), [aip_new.vars.asymmetry_parameter_B_Dry_1um.data;aip_new.vars.asymmetry_parameter_G_Dry_1um.data;aip_new.vars.asymmetry_parameter_R_Dry_1um.data],'o',...
   serial2Hh(aip_old.time), [g_1um_B; g_1um_G; g_1um_R], '.');
title('1 um g');
legend('B','G','R')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_new.time), [aip_new.vars.asymmetry_parameter_B_Dry_10um.data;aip_new.vars.asymmetry_parameter_G_Dry_10um.data;aip_new.vars.asymmetry_parameter_R_Dry_10um.data],'o',...
   serial2Hh(aip_old.time), [g_10um_B; g_10um_G; g_10um_R], '.');
title('10 um g');
linkaxes(ax,'xy')
%%
% Need to compare new aip to new aipavg

aip_new = ancload;
%%
aip_avg = ancload;
%%
noaa = ancload;
noaa_avg =ancload;
%%


figure; 

plot(serial2Hh(aip_new.time), [aip_new.vars.Ba_G_Dry_1um_PSAP1W_1.data; aip_new.vars.Ba_G_Dry_10um_PSAP1W_1.data], '.', ...
   serial2Hh(aip_avg.time), [aip_avg.vars.Ba_G_Dry_1um_PSAP1W_1.data;aip_avg.vars.Ba_G_Dry_10um_PSAP1W_1.data], 'o')
title('Compare aip vs aip_avg Ba_G 1 and 10 um', 'interpreter','none')
%%

figure; 
plot(serial2Hh(aip_new.time), [aip_new.vars.Bs_G_Dry_1um_Neph3W_1.data; aip_new.vars.Bs_G_Dry_10um_Neph3W_1.data], '.', ...
   serial2Hh(aip_avg.time), [aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data;aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data], 'o')
title('Compare aip vs aip_avg Bs_G 1 and 10 um', 'interpreter','none');
ylim([0,1.5*max(aip_new.vars.Bs_G_Dry_10um_Neph3W_1.data)]);

%%
clear ax
figure; 
ax(1) = subplot(3,1,1); 
plot(serial2doy(aip_new.time), [aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data], 'g.', ...
   serial2doy(noaa.time), [noaa.vars.Bbs_G_Dry_10um_Neph3W_1.data], 'go')
title('10 um, dots are us, circles are NOAA')
ax(2) = subplot(3,1,2);
plot(serial2doy(aip_new.time), [aip_new.vars.Bbs_G_Dry_1um_Neph3W_1.data], 'g.', ...
   serial2doy(noaa.time), [noaa.vars.Bbs_G_Dry_1um_Neph3W_1.data], 'go')
title('1 um, dots are us, circles are NOAA')
ax(3) = subplot(3,1,3); 
% plot(minutely.doy, 1e6*minutely.bbsp(:,2), 'g.')
title('Compare Bbs_G aip vs noaa ', 'interpreter','none');
linkaxes(ax,'xy')
ylim([0,1.5*max(aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data)]);
%%
clear ax
figure; 
ax(1) = subplot(2,1,1); 
plot(serial2doy(aip_avg.time), [aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data], 'g.', ...
   serial2doy(noaa_avg.time), [noaa_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data], 'go')
title('10 um, dots are us, circles are NOAA')
ax(2) = subplot(2,1,2);
plot(serial2doy(aip_avg.time), [aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data], 'g.', ...
   serial2doy(noaa_avg.time), [noaa_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data],'go')
title('1 um, dots are us, circles are NOAA')
linkaxes(ax,'xy')
ylim([0,1.5*max(aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data)]);

%%
clear ax
figure; 
ax(1) = subplot(2,1,1); 
plot(serial2doy(aip_new.time), [aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data], 'b.', ...
   serial2doy(noaa.time), [noaa.vars.Bbs_B_Dry_10um_Neph3W_1.data], 'bo')
title('10 um, dots are us, circles are NOAA')
ax(2) = subplot(2,1,2);
plot(serial2doy(aip_new.time), [aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data], 'b.', ...
   serial2doy(noaa.time), [noaa.vars.Bbs_B_Dry_1um_Neph3W_1.data], 'bo')
title('1 um, dots are us, circles are NOAA')

title('Compare Bbs_B aip vs noaa ', 'interpreter','none');
linkaxes(ax,'xy')
ylim([0,1.5*max(aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data)]);
%%
%%
clear ax
figure; 
ax(1) = subplot(3,1,1); 
plot(serial2Hh(aip_new.time), [aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data], 'b.', ...
   serial2Hh(aip_avg.time), [aip_avg.vars.Bbs_B_Dry_10um_Neph3W_1.data], 'bo')
ax(2) = subplot(3,1,2);
plot(serial2Hh(aip_new.time), [aip_new.vars.Bbs_G_Dry_10um_Neph3W_1.data], 'g.', ...
   serial2Hh(aip_avg.time), [aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data], 'go')
ax(3) = subplot(3,1,3); 
plot(serial2Hh(aip_new.time), [aip_new.vars.Bbs_B_Dry_10um_Neph3W_1.data], 'r.', ...
   serial2Hh(aip_avg.time), [aip_avg.vars.Bbs_B_Dry_10um_Neph3W_1.data], 'ro')
title('Compare Bbs aip vs aip_avg 10 um', 'interpreter','none');
linkaxes(ax,'xy')
ylim([0,1.5*max(aip_new.vars.Bbs_B_Dry_1um_Neph3W_1.data)]);
%%
figure; plot(serial2Hh(aip_avg.time), [aip_avg.vars.Bbs_B_Dry_1um_Neph3W_1.data;aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data;aip_avg.vars.Bbs_R_Dry_1um_Neph3W_1.data],'o') 
%%
clear ax
figure;
ax(1) = subplot(3,1,1); 
plot(serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BG_Dry_1um.data, 'b.',...
serial2Hh(aip_avg.time), aip_avg.vars.Bbs_angstrom_exponent_BG_Dry_1um.data,'bo'); 
ax(2) = subplot(3,1,2); 
plot(serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BR_Dry_1um.data, 'g.',...
serial2Hh(aip_avg.time), aip_avg.vars.Bbs_angstrom_exponent_BR_Dry_1um.data,'go'); 
ax(3) = subplot(3,1,3); 
plot(serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_GR_Dry_1um.data, 'r.',...
serial2Hh(aip_avg.time), aip_avg.vars.Bbs_angstrom_exponent_GR_Dry_1um.data,'ro'); 
linkaxes(ax,'xy');
ylim([-3,3])
%%
Bbs_ang_BG_1um = ang_exp(aip_avg.vars.Bbs_B_Dry_1um_Neph3W_1.data, aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data, B_neph, G_neph);
Bbs_ang_BR_1um = ang_exp(aip_avg.vars.Bbs_B_Dry_1um_Neph3W_1.data, aip_avg.vars.Bbs_R_Dry_1um_Neph3W_1.data, B_neph,R_neph);
Bbs_ang_GR_1um = ang_exp(aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data, aip_avg.vars.Bbs_R_Dry_1um_Neph3W_1.data, G_neph, R_neph);
Bbs_ang_BG_10um = ang_exp(aip_avg.vars.Bbs_B_Dry_10um_Neph3W_1.data, aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data, B_neph, G_neph);
Bbs_ang_BR_10um = ang_exp(aip_avg.vars.Bbs_B_Dry_10um_Neph3W_1.data, aip_avg.vars.Bbs_R_Dry_10um_Neph3W_1.data, B_neph,R_neph);
Bbs_ang_GR_10um = ang_exp(aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data, aip_avg.vars.Bbs_R_Dry_10um_Neph3W_1.data, G_neph, R_neph);

clear ax
figure;
ax(1) = subplot(3,1,1); 
plot(serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BG_Dry_10um.data, 'b.',...
serial2Hh(aip_avg.time), Bbs_ang_BG_1um,'bx',...
serial2Hh(aip_avg.time), aip_avg.vars.Bbs_angstrom_exponent_BG_Dry_10um.data,'bo'); 
ax(2) = subplot(3,1,2); 
plot(serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_BR_Dry_10um.data, 'g.',...
serial2Hh(aip_avg.time), Bbs_ang_BR_1um,'gx',...   
serial2Hh(aip_avg.time), aip_avg.vars.Bbs_angstrom_exponent_BR_Dry_10um.data,'go'); 
ax(3) = subplot(3,1,3); 
plot(serial2Hh(aip_new.time), aip_new.vars.Bbs_angstrom_exponent_GR_Dry_10um.data, 'r.',...
serial2Hh(aip_avg.time), Bbs_ang_GR_1um,'rx',...
serial2Hh(aip_avg.time), aip_avg.vars.Bbs_angstrom_exponent_GR_Dry_10um.data,'ro'); 
linkaxes(ax,'xy');
ylim([-3,3])
%%
figure; 
plot(serial2Hh(aip_new.time), [aip_new.vars.Bs_R_Dry_1um_Neph3W_1.data; aip_new.vars.Bs_R_Dry_10um_Neph3W_1.data], '.', ...
   serial2Hh(aip_avg.time), [aip_avg.vars.Bs_R_Dry_1um_Neph3W_1.data;aip_avg.vars.Bs_R_Dry_10um_Neph3W_1.data], 'o')
title('Compare aip vs aip_avg Bs_R 1 and 10 um', 'interpreter','none');
ylim([0,1.5*max(aip_new.vars.Bs_R_Dry_10um_Neph3W_1.data)]);

%% 
good = aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data>0 &aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data>0 ...
   & aip_avg.vars.Ba_G_Dry_1um_PSAP1W_1.data>0 & aip_avg.vars.Ba_G_Dry_10um_PSAP1W_1.data> 0;

ssa_G_1um = aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data ./ (aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data + aip_avg.vars.Ba_G_Dry_1um_PSAP1W_1.data);
ssa_G_10um = aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data ./ (aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data + aip_avg.vars.Ba_G_Dry_10um_PSAP1W_1.data);

figure;  plot(serial2Hh(aip_new.time), [aip_new.vars.ssa_G_Dry_1um.data; aip_new.vars.ssa_G_Dry_10um.data],'x',...
serial2Hh(aip_avg.time),[aip_avg.vars.ssa_G_Dry_1um.data;aip_avg.vars.ssa_G_Dry_10um.data], '.', ...
   serial2Hh(aip_avg.time(good)),[ssa_G_1um(good); ssa_G_10um(good)], 'o')

%% 

bsf_B_1um = aip_avg.vars.Bbs_B_Dry_1um_Neph3W_1.data ./ (aip_avg.vars.Bs_B_Dry_1um_Neph3W_1.data);
bsf_B_10um = aip_avg.vars.Bbs_B_Dry_10um_Neph3W_1.data ./ (aip_avg.vars.Bs_B_Dry_10um_Neph3W_1.data);
bsf_G_1um = aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data ./ (aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data);
bsf_G_10um = aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data ./ (aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data);
bsf_R_1um = aip_avg.vars.Bbs_R_Dry_1um_Neph3W_1.data ./ (aip_avg.vars.Bs_R_Dry_1um_Neph3W_1.data);
bsf_R_10um = aip_avg.vars.Bbs_R_Dry_10um_Neph3W_1.data ./ (aip_avg.vars.Bs_R_Dry_10um_Neph3W_1.data);

usf_B_1um = usf_v_bsf(bsf_B_1um);
usf_B_10um = usf_v_bsf(bsf_B_10um);
usf_G_1um = usf_v_bsf(bsf_G_1um);
usf_G_10um = usf_v_bsf(bsf_G_10um);
usf_R_1um = usf_v_bsf(bsf_R_1um);
usf_R_10um = usf_v_bsf(bsf_R_10um);

g_B_1um = g_v_usf(usf_B_1um);
g_B_10um = g_v_usf(usf_B_10um);
g_G_1um = g_v_usf(usf_G_1um);
g_G_10um = g_v_usf(usf_G_10um);
g_R_1um = g_v_usf(usf_R_1um);
g_R_10um = g_v_usf(usf_R_10um);

sub_Bs_B = aip_avg.vars.Bs_B_Dry_1um_Neph3W_1.data ./ aip_avg.vars.Bs_B_Dry_10um_Neph3W_1.data;
sub_Bs_G = aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data ./ aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data;
sub_Bs_R = aip_avg.vars.Bs_R_Dry_1um_Neph3W_1.data ./ aip_avg.vars.Bs_R_Dry_10um_Neph3W_1.data;

sub_Bbs_B = aip_avg.vars.Bbs_B_Dry_1um_Neph3W_1.data ./ aip_avg.vars.Bbs_B_Dry_10um_Neph3W_1.data;
sub_Bbs_G = aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data ./ aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data;
sub_Bbs_B = aip_avg.vars.Bbs_R_Dry_1um_Neph3W_1.data ./ aip_avg.vars.Bbs_R_Dry_10um_Neph3W_1.data;

sub_abs_B = aip_avg.vars.Ba_B_Dry_1um_PSAP3W_1.data ./ aip_avg.vars.Ba_B_Dry_10um_PSAP3W_1.data;
sub_abs_G1 = aip_avg.vars.Ba_G_Dry_1um_PSAP1W_1.data ./ aip_avg.vars.Ba_G_Dry_10um_PSAP1W_1.data;
sub_abs_G3 = aip_avg.vars.Ba_G_Dry_1um_PSAP3W_1.data ./ aip_avg.vars.Ba_G_Dry_10um_PSAP3W_1.data;
sub_abs_R = aip_avg.vars.Ba_R_Dry_1um_PSAP3W_1.data ./ aip_avg.vars.Ba_R_Dry_10um_PSAP3W_1.data;


%%
good = aip_avg.vars.Bs_G_Dry_1um_Neph3W_1.data>0 &aip_avg.vars.Bs_G_Dry_10um_Neph3W_1.data>0 ...
 & aip_avg.vars.Bbs_G_Dry_1um_Neph3W_1.data>0 &aip_avg.vars.Bbs_G_Dry_10um_Neph3W_1.data>0;
%%
figure; 
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_avg.time),aip_avg.vars.bsf_B_Dry_1um.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),bsf_B_1um(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.bsf_G_Dry_1um.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),bsf_G_1um(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.bsf_R_Dry_1um.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),bsf_R_1um(good), 'ro')
%
title('backscatter fraction')
legend('new','me')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_avg.time),aip_avg.vars.bsf_B_Dry_10um.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),bsf_B_10um(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.bsf_G_Dry_10um.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),bsf_G_10um(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.bsf_R_Dry_10um.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),bsf_R_10um(good), 'ro')

%%

figure; 
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_avg.time),aip_avg.vars.usf_B_Dry_1um.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),usf_B_1um(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.usf_G_Dry_1um.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),usf_G_1um(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.usf_R_Dry_1um.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),usf_R_1um(good), 'ro')
%
title('Upscatter fraction')
legend('new','me')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_avg.time),aip_avg.vars.usf_B_Dry_10um.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),usf_B_10um(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.usf_G_Dry_10um.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),usf_G_10um(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.usf_R_Dry_10um.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),usf_R_10um(good), 'ro')

%%

figure; 
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_avg.time),aip_avg.vars.asymmetry_parameter_B_Dry_1um.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),g_B_1um(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.asymmetry_parameter_G_Dry_1um.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),g_G_1um(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.asymmetry_parameter_R_Dry_1um.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),g_R_1um(good), 'ro')
%
title('asymmetry parameter')
legend('new','me')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_avg.time),aip_avg.vars.asymmetry_parameter_B_Dry_10um.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),g_B_10um(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.asymmetry_parameter_G_Dry_10um.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),g_G_10um(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.asymmetry_parameter_R_Dry_10um.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),g_R_10um(good), 'ro')

%%
figure; 
ax(1) = subplot(2,1,1);
plot(serial2Hh(aip_avg.time),aip_avg.vars.submicron_fraction_scattering_B.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),sub_Bs_B(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.submicron_fraction_scattering_G.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),sub_Bs_G(good), 'go', ...
   serial2Hh(aip_avg.time),aip_avg.vars.submicron_fraction_scattering_R.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),sub_Bs_R(good), 'ro')
%
title('submicrons')
legend('new','me')
ax(2) = subplot(2,1,2);
plot(serial2Hh(aip_avg.time),aip_avg.vars.submicron_fraction_absorption_B.data, 'b.', ...
   serial2Hh(aip_avg.time(good)),sub_abs_B(good), 'bo', ...
   serial2Hh(aip_avg.time),aip_avg.vars.submicron_fraction_absorption_G.data, 'g.', ...
   serial2Hh(aip_avg.time(good)),sub_abs_G1(good), 'go', ...
      serial2Hh(aip_avg.time(good)),sub_abs_G3(good), 'gx', ...
   serial2Hh(aip_avg.time),aip_avg.vars.submicron_fraction_absorption_R.data, 'r.', ...
   serial2Hh(aip_avg.time(good)),sub_abs_R(good), 'ro')

%%