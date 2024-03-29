function W = tungsten_spectral_emissivity_vs_temperature
% Map color temperature (derived from wavelength of maximum radiation) to
% filament temperature based on CRC tabled values 10-283.
% Then use this filament temperature to interpolate the spectral emissivity of
% tungsten as a function temperature CRC table 10-284
%%
W.T1_color = [1007,1108,1210,1312,1414,1516,1619,1722,1825,1928,2032,2136,2241,...
    2345,2451,2556,2662,2769,2876,2984,3092,3200,3310,3420,3530,3642,3754];
W.T1_K = [1000:100:3600];
% figure;plot(W.T1_K, W.T1_color./W.T1_K,'o-'); xlabel('Temp');ylabel('color temp')
W.T2_K = [1600:200:2800];
W.P_T_Tc = polyfit(W.T1_color, W.T1_K,2);
W.um = [.25,.3,.35,.4,.5,.6, .7, .8, .9, 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.8, 2.0, 2.2, 2.4, 2.6]';
W.emis = [.448,.442, .436,.429,.422, .418,.411;...
    .482,.478,.474,.470,.465, .461, .456;...
    .478,.476,.473,.470,.466,.464,.461;...
    .481,.477,.474,.471,.468,.464,.461;...
    .469,.465,.462,.458,.455,.451,.448;...
    .455,.452,.448,.445,.441,.437,.434;...
    .444,.440,.436,.431,.427,.423,.419;...
    .431,.425,.419,.415,.408,.404,.400;...
    .413,.407,.401,.396,.391,.386,.383;...
    .390,.385,.381,.378,.372,.369,.367;...
    .366,.364,.361,.359,.355,.352,.352;...
    .345,.344,.343,.342,.340,.338,.337;...
    .322,.323,.323,.324,.324,.325,.325;...
    .300,.302,.305,.306,.309,.310,.313;...
    .279,.282,.288,.291,.296,.299,.302;...
    .263,.267,.273,.278,.283,.288,.292;...
    .234,.241,.247,.254,.262,.269,.274;...
    .210,.218,.227,.235,.244,.251,.259;...
    .190,.200,.209,.218,.228,.236,.245;...
    .175,.182,.197,.205,.215,.224,.233;...
    .164,.174,.175,.194,.205,.214,.224];% still need 
%  figure; imagesc(W.um, W.T2_K, W.emis'); colorbar; axis('xy')
% ii = interp1(W.T2_K,[1:length(W.T2_K)],2600,'nearest');
%%
% Interpolate between measured points
% Use polyfit to extrapolate beyond measured points.
T_ = (W.T1_K < min(W.T2_K))|(W.T1_K>max(W.T2_K));
for wl = length(W.um):-1:1
W.emis_v_T1(wl,:) = interp1(W.T2_K,W.emis(wl,:),W.T1_K,'cubic');
[W.P(wl,:),W.S(wl,:)] = polyfit(W.T2_K./1000,W.emis(wl,:),1);
W.emis_v_T1(wl,T_) = polyval(W.P(wl,:),W.T1_K(T_)./1000,W.S(wl));
end
%     
% %%     
% figure; plot(W.T2_K, W.emis,'o-',W.T1_K, W.emis_v_T1,'-k.')
% %%
% figure; these = plot(W.um, W.emis_v_T1,'-');xlabel('wavelength');recolor(these,W.T1_K); colorbar;
%%
return
%%