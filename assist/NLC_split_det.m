function [C_corr,nlc] = NLC_split_det(assist, nlc,zpd);
% [C_corr,nlc] = NLC_split_det(cxs, nlc, zpd);
% C_corr is NLC corrected complex spectra via SSEC modeled V_dc
% nlc contains fields
%   .a2
%   .IHLAB
%   .ICLAB  
% This routine is the same form whether the raw ifg zpd or the
% phase-shifted zpd have been supplied, but the user must make sure that
% the nlc and zpd methods match. 

% Need to modify to swap polarity of zpd terms.
nlc.MF=(0.7);
nlc.fBACK=(1.0);
C_corr = zeros(size(assist.chA.cxs.y));

%For forward
IHatZPD_F = mean(zpd(assist.logi.HBB_F));
static_shift_F = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_F);
IMatZPD_F = zpd(assist.logi.F);
% The following line may require a sign change for sandwich detector
nlc.Vdc_F = (1./(nlc.MF)).*(static_shift_F + IMatZPD_F);
[I_plus_V_sqrd.x,I_plus_V_sqrd.y] = RawIgm2RawSpc(assist.chA.x, (assist.chA.y(assist.logi.F,:) ...
   +nlc.Vdc_F*ones(size(assist.chA.x))).^2 ); 
C_corr(assist.logi.F,:) = assist.chA.cxs.y(assist.logi.F,:) + nlc.a2 .* I_plus_V_sqrd.y;

IHatZPD_R = mean(zpd(assist.logi.HBB_R));
static_shift_R = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD_R);
IMatZPD_R = zpd(assist.logi.R);
nlc.Vdc_R = (1./(nlc.MF)).*(static_shift_R + IMatZPD_R);
[I_plus_V_sqrd.x,I_plus_V_sqrd.y] = RawIgm2RawSpc(assist.chA.x, (assist.chA.y(assist.logi.R,:) +nlc.Vdc_R*ones(size(assist.chA.x))).^2 ); 
C_corr(assist.logi.R,:) = assist.chA.cxs.y(assist.logi.R,:) + nlc.a2 .* I_plus_V_sqrd.y;


%% end NLC code
return