function [assist,nlc] = NLC_split_det_scandir(assist, nlc,zpd,logi);
% [C_corr,nlc] = NLC_split_det_scandir(cxs, nlc, zpd,logi);
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
nlc.Vdc = zeros(size(logi))';
C_corr = zeros(size(assist.chA.cxs.y));

%For forward
IHatZPD = mean(zpd(assist.logi.H&logi));
static_shift = (2+nlc.fBACK).*(nlc.IHLAB-nlc.ICLAB -IHatZPD);
IMatZPD = zpd(logi);
disp('Yeah Baby, found good relationship between modeled and measured Vdc.')
disp('Someday implement this in LN2 calibration.')
% The following line may require a sign change for sandwich detector
% Oh heck. Where is the factor of 8 below coming from?! Was this empirical just to get the split det to work? CJF 2016-0210
% nlc.Vdc(logi) = (0.125/(nlc.MF)).*(static_shift + IMatZPD);
% nlc.Vdc(logi) = (1./(nlc.MF)).*(static_shift + IMatZPD);
nlc.Vdc(logi) = (0.75/(nlc.MF)).*(static_shift + IMatZPD);
[I_plus_V_sqrd.x,I_plus_V_sqrd.y] = RawIgm2RawSpc(assist.chA.x, (assist.chA.y(logi,:) ...
   +nlc.Vdc(logi)*ones(size(assist.chA.x))).^2 ); 

C_corr(logi,:) = assist.chA.cxs.y(logi,:) + nlc.a2 .* I_plus_V_sqrd.y;
assist.chA.cxs.y(logi,:) = C_corr(logi,:);
%% end NLC code
return