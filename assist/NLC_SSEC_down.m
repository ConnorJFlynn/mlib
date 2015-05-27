function [cxs,nlc] = NLC_SSEC_down(assist, nlc);
% [y,nlc] = NLC_SSEC(cxs, nlc);
% nlc.a2 = 1.2276e-6;
a2_str = sprintf('%2.5g',nlc.a2);
a2_str = strrep(a2_str,'-0','-');a2_str = strrep(a2_str,'-0','-');

nlc.MF=(0.7);
nlc.fBACK=(1.0);
% nlc.IHLAB=(-80443);
% nlc.ICLAB=(96455);     
     %%
IHatZPD_F = mean(assist.chA.F(assist.isHBB,1));
IHatZPD_R = mean(assist.chA.R(assist.isHBB,1));
%%
% figure; plot(assist.chA.x, fftshift(mean(assist.chA.F(assist.isHBB,:))),'r',...
%    assist.chA.x, fftshift(mean(assist.chA.R(assist.isHBB,:))),'b' );
% legend('Forward','Reverse')
%%
static_shift_F = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_F);
static_shift_R = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_R);

IMatZPD_F = assist.chA.F(:,1);
IMatZPD_R = assist.chA.R(:,1);

nlc.Vdc_F = (IMatZPD_F+(2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_F))./(-nlc.MF);
nlc.Vdc_R = (IMatZPD_R+(2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_R))./(-nlc.MF);
nlc.Vdc_F = (IMatZPD_F+static_shift_F)./(-nlc.MF);
nlc.Vdc_R = (IMatZPD_R+static_shift_R)./(-nlc.MF);

% IHatZPD = mean(assist.chA.y(assist.logi.HBB_F|assist.logi.HBB_R,1));
% IMatZPD = assist.chA.y(:,1);
% nlc.Vdc = (1./(-nlc.MF)).*((2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD) + IMatZPD);

nlc.nonlinearity_factor_F = 1+ 2.*nlc.a2.*nlc.Vdc_F;
nlc.nonlinearity_factor_R = 1+ 2.*nlc.a2.*nlc.Vdc_R;
nlc.nonlinearity_factor_F = 2.*nlc.a2.*nlc.Vdc_F;
nlc.nonlinearity_factor_R = 2.*nlc.a2.*nlc.Vdc_R;
cxs.x = assist.chA.cxs.x;
cxs.F = (assist.chA.cxs.F .* (1+nlc.nonlinearity_factor_F*ones(size(assist.chA.cxs.x))));
cxs.R = (assist.chA.cxs.R .* (1+nlc.nonlinearity_factor_R*ones(size(assist.chA.cxs.x))));
% [tmp.x,tmp.y] = RawIgm2RawSpc(assist.chA.x,assist.chA.y.^2);
% nlc.nonlinearity_offset = nlc.a2.*tmp.y;
 %%
  figure; 
 subplot(2,1,1);
 plot([1:length(assist.time)],nlc.Vdc_R,'-x');
 title('DC voltage computed as V_D_C (also called V_m)');
 ylabel('V');
 subplot(2,1,2);
plot([1:length(assist.time)],nlc.nonlinearity_factor_R,'-o');
 title('NLC = 1+ 2*a2*V_m');
 ylabel('unitless factor');
 xlabel('record number');
 v = axis;
 txt_nlc = text(0.7.*mean(v(1:2)),mean(v(3:4)),{['a2 = ',a2_str]});
% y = (assist.chA.cxs.F .* (nlc.nonlinearity_factor_F*ones(size(assist.chA.cxs.x))));
% assist.chA.nlc.y = assist.chA.nlc.y + assist.chA.nlc.nonlinearity_offset_F;
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