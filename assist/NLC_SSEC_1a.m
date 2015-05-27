function [y,nlc] = NLC_SSEC_1a(assist, nlc);
% [y,nlc] = NLC_SSEC(cxs, nlc);
% nlc contains fields
%   .a2
%   .IHLAB
%   .ICLAB  

%Need to modify to include quadratic NLC term!
% Don't use this until you've determined IHLAB and ICLAB from
% phase/magnitude approach ala Turner.  
% I compared the two corrections in terms of the a2 coefficients and they
% were similar to 3 or 4 digits. So, currently using old zpd determination
% to be consistent with Michel's NLC test in Finland, which I've checked.

nlc.MF=(0.7);
nlc.fBACK=(1.0);
C_Corr = zeros(size(assist.chA.cxs.y));

%For forward
% IHatZPD_F = mean(assist.chA.y(assist.logi.HBB_F,1));
IHatZPD_F = mean(assist.chA.cxs.zpd(assist.logi.HBB_F));
static_shift_F = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_F);
% IMatZPD_F = assist.chA.y(assist.logi.F,1);
IMatZPD_F = assist.chA.cxs.zpd(assist.logi.F);
nlc.Vdc_F = (1./(-nlc.MF)).*(static_shift_F + IMatZPD_F);
% syntax of RawIgm2RawSpc:;
% [assist.chA.cxs.x,assist.chA.cxs.y,assist.chA.cxs.zpd,assist.chA.cxs.zpd_raw] = RawIgm2RawSpc(assist.chA.x,assist.chA.y,assist.chA.laser_wl);
[I_plus_V_sqrd.x,I_plus_V_sqrd.y] = RawIgm2RawSpc(assist.chA.x, (assist.chA.y(assist.logi.F,:) +nlc.Vdc_F*ones(size(assist.chA.x))).^2 ); 
C_corr(assist.logi.F,:) = assist.chA.cxs.y(assist.logi.F,:) + nlc.a2 .* I_plus_V_sqrd.y;

% nlc.nonlinearity_factor_F = 1+ 2.*nlc.a2.*nlc.Vdc_F;
% [I_sqrd.x, I_sqrd.y] = RawIgm2RawSpc(assist.chA.x, assist.chA.y(assist.logi.F,:).^2 ); 
% C_corr2_a = assist.chA.cxs.y(assist.logi.F,:).*(nlc.nonlinearity_factor_F*ones(size(assist.chA.cxs.x)));
% C_corr2_b =  nlc.a2.*(I_sqrd.y);
% C_corr2 = C_corr2_a + C_corr2_b;

% figure; plot(assist.chA.cxs.x, assist.chA.cxs.y(1,:),'-',I_plus_V_sqrd.x, C_corr1(1,:),'r-',I_sqrd.x, C_corr2(1,:),'.k');
% figure; plot(I_plus_V_sqrd.x, C_corr2_a(1,:),'b-',I_sqrd.x, C_corr2_b(1,:),'r-');

%old

% IHatZPD_R = mean(assist.chA.y(assist.logi.HBB_R,1));
% static_shift_R = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_R);
% IMatZPD_R = assist.chA.y(assist.logi.R,1);
% nlc.Vdc_R = (1./(-nlc.MF)).*(static_shift_R + IMatZPD_R);
% nlc.nonlinearity_factor_R = 1+ 2.*nlc.a2.*nlc.Vdc_R 
%new
IHatZPD_R = mean(assist.chA.cxs.zpd(assist.logi.HBB_R));
static_shift_R = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_R);
% IMatZPD_F = assist.chA.y(assist.logi.F,1);
IMatZPD_R = assist.chA.cxs.zpd(assist.logi.R);
nlc.Vdc_R = (1./(-nlc.MF)).*(static_shift_R + IMatZPD_R);
% syntax of RawIgm2RawSpc:;
% [assist.chA.cxs.x,assist.chA.cxs.y,assist.chA.cxs.zpd,assist.chA.cxs.zpd_raw] = RawIgm2RawSpc(assist.chA.x,assist.chA.y,assist.chA.laser_wl);
[I_plus_V_sqrd.x,I_plus_V_sqrd.y] = RawIgm2RawSpc(assist.chA.x, (assist.chA.y(assist.logi.R,:) +nlc.Vdc_R*ones(size(assist.chA.x))).^2 ); 
C_corr(assist.logi.R,:) = assist.chA.cxs.y(assist.logi.R,:) + nlc.a2 .* I_plus_V_sqrd.y;

%%
% AA(:,1) = IMatZPD;
% AA(:,2) = nlc.Vdc;
% AA(:,3) = nlc.nonlinearity_factor;
% Aa = downsample(AA(assist.logi.F,:),6);
%%
% RawIgm2RawSpc(assist.chB.x,assist.chB.y,assist.chB.laser_wl);
% y = zeros(size(assist.chA.cxs.y));
% y(assist.logi.F,:) = (assist.chA.cxs.y(assist.logi.F,:) .* (nlc.nonlinearity_factor_F*ones(size(assist.chA.cxs.x)))) + ...
%     nlc.a2.*fft(assist.chA.y(assist.logi.F,:).^2);
% y(assist.logi.R,:) = (assist.chA.cxs.y(assist.logi.R,:) .* (nlc.nonlinearity_factor_R*ones(size(assist.chA.cxs.x)))) + ...
%     nlc.a2.*fft(assist.chA.y(assist.logi.R,:).^2);
a2_str = sprintf('%2.5g',nlc.a2);
a2_str = strrep(a2_str,'-0','-');a2_str = strrep(a2_str,'-0','-');

% [tmp.x,tmp.y] = RawIgm2RawSpc(assist.chA.x,assist.chA.y.^2);
% nlc.nonlinearity_offset = nlc.a2.*tmp.y;
 %%
% %  figure; 
%  subplot(2,1,1);
%  plot([1:length(assist.time)],nlc.Vdc,'-x');
%  title('DC voltage computed as V_D_C (also called V_m)');
%  ylabel('V');
%  subplot(2,1,2);
% plot([1:length(assist.time)],nlc.nonlinearity_factor,'-o');
%  title('NLC = 1+ 2*a2*V_m');
%  ylabel('unitless factor');
%  xlabel('record number');
%  v = axis;
%  txt_nlc = text(0.7.*mean(v(1:2)),mean(v(3:4)),{['a2 = ',a2_str]});

% assist.chA.nlc.y = assist.chA.nlc.y + assist.chA.nlc.nonlinearity_offset;
%%
% figure; 
% plot(assist.chA.cxs.x,assist.chA.nlc.nonlinearity_offset(assist.logi.H,:) ./assist.chA.cxs.y(assist.logi.H,:),'r-',...
%    assist.chA.cxs.x,assist.chA.nlc.nonlinearity_offset(assist.logi.A,:)./assist.chA.cxs.y(assist.logi.A,:),'b-',...
%    assist.chA.cxs.x,assist.chA.nlc.nonlinearity_offset(assist.logi.Sky,:) ./assist.chA.cxs.y(assist.logi.Sky,:),'g-');
% xlabel('wavenumber [1/cm]');
% ylabel('non-linear correction offset')
% lg = legend('red is HBB','blue is ABB','green is Sky');
% xlim([650,1450]);
% ylim([-1e-3,1.5e-3]);

%% end NLC code
return