function [y,nlc] = NLC_SSEC(assist, nlc);
% [y,nlc] = NLC_SSEC(cxs, nlc);
% nlc contains fields
%   .a2
%   .IHLAB
%   .ICLAB  

%Need to modify to include quadratic NLC term!

nlc.MF=(0.7);
nlc.fBACK=(1.0);

%For forward
IHatZPD_F = mean(assist.chA.y(assist.logi.HBB_F,1));
static_shift_F = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_F);
IMatZPD_F = assist.chA.y(assist.logi.F,1);
nlc.Vdc_F = (1./(-nlc.MF)).*(static_shift_F + IMatZPD_F);
nlc.nonlinearity_factor_F = 1+ 2.*nlc.a2.*nlc.Vdc_F;

IHatZPD_R = mean(assist.chA.y(assist.logi.HBB_R,1));
static_shift_R = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_R);
IMatZPD_R = assist.chA.y(assist.logi.R,1);
nlc.Vdc_R = (1./(-nlc.MF)).*(static_shift_R + IMatZPD_R);
nlc.nonlinearity_factor_R = 1+ 2.*nlc.a2.*nlc.Vdc_R 

%%
% AA(:,1) = IMatZPD;
% AA(:,2) = nlc.Vdc;
% AA(:,3) = nlc.nonlinearity_factor;
% Aa = downsample(AA(assist.logi.F,:),6);
%%
% RawIgm2RawSpc(assist.chB.x,assist.chB.y,assist.chB.laser_wl);
y = zeros(size(assist.chA.cxs.y));
y(assist.logi.F,:) = (assist.chA.cxs.y(assist.logi.F,:) .* (nlc.nonlinearity_factor_F*ones(size(assist.chA.cxs.x)))) + ...
    nlc.a2.*fft(assist.chA.y(assist.logi.F,:).^2);
y(assist.logi.R,:) = (assist.chA.cxs.y(assist.logi.R,:) .* (nlc.nonlinearity_factor_R*ones(size(assist.chA.cxs.x)))) + ...
    nlc.a2.*fft(assist.chA.y(assist.logi.R,:).^2);
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