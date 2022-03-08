function test_aod_fitting
% Connor, 2020-08-??
% Connor, 2020-11-23, expanded to permit up to three log-normal modes
% This code tests my mods of Feng Xu's Mie_AERONET in ==>> anet_mie
% which permit use of aeronet intensive property retrievals V3 for 
% refractive index (*.rin) and ASD as either PSD in dVdlnr in (*.size)
% or as log-normal modes in (*.vol)
% Compares Mie-computed AOD against aeronet aod, cad

% Reproduce Aeronet SD from Aeronet lognormal

lambda=[441, 673, 873, 1022];
n_i = [1.581700,1.584500,1.600000,1.600000] + j.*[0.025597,0.021507,0.020917,0.020566];
mr_arr(1:length(lambda))= [1.33	1.3557	1.3692	1.3702];%real refractive index 
mi_arr(1:length(lambda))= [0.00187	0.001825	0.001824	0.001823];% imaginary refractive index 
n_i = mr_arr + j.*mi_arr;
rm=[0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000];
dVdlnr = [0.000321,0.002708,0.010422,0.018989,0.018266,0.011193,0.005670,0.003155,0.002377,0.002548,0.003535,0.005525,0.008811,0.013720,0.020467,0.028187,0.032764,0.028586,0.017028,0.006553,0.001587,0.000240];
dVdlnr= [0.000799	0.000783	0.001214	0.00283	0.008527	0.025265	0.052488	0.056106	0.03332	0.017428	0.011672	0.010808	0.012044	0.01447	0.017286	0.018461	0.017036	0.013154	0.008418	0.004531	0.002083	0.000823];

%specifying a larger/different WL range compared to aeronet provides the
%ability to extend AOD from their specific wavelengths. 
wl = [325:25:1700 2000:100:4000 4500:500:10000];
ni = interp1(lambda, n_i, wl, 'linear','extrap');
 
% eaod = rd_anetaip_v3;
cad = rd_anetaip_v3;
% aod_lev1p5 = rd_anetaod_v3;
% aod_lev2 = rd_anetaod_v3;
rin = rd_anet_rin_v3;
siz = rd_anet_siz_v3;
vol = rd_anetaip_v3;

good = all(rin.Refractive_Index_Real_Part>0,2)&all(rin.Refractive_Index_Imaginary_Part>0,2);
goods = find(good);

bin_rad = logspace(log10(siz.bin_radius(1)./2), log10(2.*siz.bin_radius(end)),4.*length(siz.bin_radius));
figure_(99);
kk = 0; kk = kk + 1;
for ks = 1:length(goods)
    kk = goods(ks);
    n_i = rin.Refractive_Index_Real_Part(kk,:)+j.*rin.Refractive_Index_Imaginary_Part(kk,:);
    na = real(n_i)<0; 
    n_i(na) = mr_arr(na)+j.*mi_arr(na);
    ni = interp1(lambda, n_i, wl, 'linear','extrap');
%     bin_rad = logspace(log10(siz.bin_radius(1)./2), log10(2.*siz.bin_radius(end)),4.*length(siz.bin_radius));
    dVdlnr = vol.VolC_F(kk).*LnNormal(bin_rad, vol.VMR_F(kk), exp(vol.Std_F(kk)))+...
        vol.VolC_C(kk).*LnNormal(bin_rad, vol.VMR_C(kk), exp(vol.Std_C(kk)));
    M1.VolC = vol.VolC_F(kk); M1.vmr = vol.VMR_F(kk); M1.std = vol.Std_F(kk);
    M2.VolC = vol.VolC_C(kk); M2.vmr = vol.VMR_C(kk); M2.std = vol.Std_C(kk);
%     [aod_bm,ssa_bm] = anet_mie(wl,ni, bin_rad, M1, M2);
[aod, ssa] = anet_mie(wl,ni, siz.bin_radius, siz.dV_dlnr(kk,:));
     sb(1) =subplot(1,2,1);  hold('on'); 
 plot(siz.bin_radius, siz.dV_dlnr(kk,:),'k-o',bin_rad, dVdlnr,'rx'); xlabel('radius [um]'); ylabel('dV/dlnr'); logx
 title(['ASD dV/dlnr bins from ARM SGP.siz ',datestr(siz.time(kk),'mmm dd HH:MM:SS')]);
 hold('on'); set(sb(1),'pos',[ 0.0859    0.1145    0.3956    0.8105]);
tic
[aod, ssa] = anet_mie(wl,ni, siz.bin_radius, siz.dV_dlnr(kk,:));
toc
[aod_lg, ssa_lg] = anet_mie(wl,ni, bin_rad, dVdlnr);
toc
aod2 = [cad.AOD_Coincident_Input_440nm_(kk),cad.AOD_Coincident_Input_675nm_(kk), ...
    cad.AOD_Coincident_Input_870nm_(kk), cad.AOD_Coincident_Input_1020nm_(kk)];

 sb(2) = subplot(1,2,2); hold('on'); 
 plot(wl, aod, '-b',lambda, aod2,'rx',wl, aod_lg,'k*'); logy; logx; 
 legend('Mie','Ext AOD v2','Mie log-normal')
xlabel('wavelength [nm]');ylabel('Optical depth [unitless]')
title(['AOD from .aod, .cad, and Mie:',datestr(siz.time(kk),'mmm dd, HH:MM:SS')]);
hold('on');set(sb(2),'pos',[0.5703    0.1100    0.3805    0.8150]);
end

return