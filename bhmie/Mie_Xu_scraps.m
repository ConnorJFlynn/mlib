function test_aod_fitting
% Connor, 2020-08-??
% This code tests my mods of Feng Xu's Mie_AERONET in ==>> anet_mie
% which permit use of aeronet intensive property retrievals V3 for
% refractive index (*.rin) and ASD as either PSD in dVdlnr in (*.size)
% or as log-normal modes in (*.vol)
% Compares Mie-computed AOD against aeronet aod, eaod, or cod.
% It then generates a basis set of ODs representing Rayleigh and various
% monomodal lognormal ASDs.
%
% Reproduce Aeronet SD from Aeronet lognormal

%testing my mods to Feng Xu's Mie_AERONET ==> anet_mie
lambda=[441, 673, 873, 1022];
n_i = [1.581700,1.584500,1.600000,1.600000] + j.*[0.025597,0.021507,0.020917,0.020566];
mr_arr(1:length(lambda))= [1.33	1.3557	1.3692	1.3702];%real refractive index
mi_arr(1:length(lambda))= [0.00187	0.001825	0.001824	0.001823];% imaginary refractive index
n_i = mr_arr + j.*mi_arr;
rm=[0.050000,0.065604,0.086077,0.112939,0.148184,0.194429,0.255105,0.334716,0.439173,0.576227,0.756052,0.991996,1.301571,1.707757,2.240702,2.939966,3.857452,5.061260,6.640745,8.713145,11.432287,15.000000];
dVdlnr = [0.000321,0.002708,0.010422,0.018989,0.018266,0.011193,0.005670,0.003155,0.002377,0.002548,0.003535,0.005525,0.008811,0.013720,0.020467,0.028187,0.032764,0.028586,0.017028,0.006553,0.001587,0.000240];
dVdlnr= [0.000799	0.000783	0.001214	0.00283	0.008527	0.025265	0.052488	0.056106	0.03332	0.017428	0.011672	0.010808	0.012044	0.01447	0.017286	0.018461	0.017036	0.013154	0.008418	0.004531	0.002083	0.000823];

wl = [325:25:1700];
ni = interp1(lambda, n_i, wl, 'linear','extrap');
% tic
% [aod, ssa] = anet_mie(wl,ni, rm, dVdlnr); figure_(99);
% plot(wl, aod, '-'); logy; logx
% toc



eaod = rd_anetaip_v3;
cod = rd_anetaip_v3;
% aod_lev1p5 = rd_anetaod_v3;
% aod_lev2 = rd_anetaod_v3;
rin = rd_anet_rin_v3;
siz = rd_anet_siz_v3;
vol = rd_anetaip_v3;

% bins = fieldnames(siz);
%
% for f = length(bins):-1:1
%     if ~startsWith(bins{f},'pos')
%         bins(f) = [];
%     end
% end
% SD = NaN([length(siz.time),length(bins)]);
% for f = length(bins):-1:1
%     radius(1,f) = sscanf(strrep(strrep(bins{f},'pos',''),'d','.'),'%f');
%     SD(:,f) = siz.(bins{f});
% end
% [radius,ij] = sort(radius); SD = SD(ij,:);
% siz.bin_radius = radius;
% siz.bin_diam = radius./2;
% siz.dV_dlnr = SD;
% dV/dlnr = (4pi/3)r^3 .* dN/dlnr
% dV/dlogDp = pi/5.*D^3 .* dN/dlogDp
% siz.dN_dlnr = siz.dV_dlnr .*3 ./(4.*pi.*siz.bin_radius.^3);
% siz.dN_dlnD = siz.dN_dlnr ./2;

bin_rad = logspace(log10(siz.bin_radius(1)./2), log10(2.*siz.bin_radius(end)),4.*length(siz.bin_radius));
figure_(99);
kk = 0; kk = kk + 1;
for kk = 2:22
    n_i = rin.Refractive_Index_Real_Part(kk,:)+j.*rin.Refractive_Index_Imaginary_Part(kk,:);
    na = real(n_i)<0;
    n_i(na) = mr_arr(na)+j.*mi_arr(na);
    ni = interp1(lambda, n_i, wl, 'linear','extrap');
    bin_rad = logspace(log10(siz.bin_radius(1)./2), log10(2.*siz.bin_radius(end)),4.*length(siz.bin_radius));
    dVdlnr = vol.VolC_F(kk).*LnNormal(bin_rad, vol.VMR_F(kk), exp(vol.Std_F(kk)))+...
        vol.VolC_C(kk).*LnNormal(bin_rad, vol.VMR_C(kk), exp(vol.Std_C(kk)));
    
    sb(1) =subplot(1,2,1);  hold('on');
    plot(siz.bin_radius, siz.dV_dlnr(kk,:),'k-o',bin_rad, dVdlnr,'rx'); xlabel('radius [um]'); ylabel('dV/dlnr'); logx
    title(['ASD dV/dlnr bins from ARM SGP.siz ',datestr(siz.time(kk),'mmm dd HH:MM:SS')]);
    hold('on'); set(sb(1),'pos',[ 0.0859    0.1145    0.3956    0.8105]);
    tic
    [aod, ssa] = anet_mie(wl,ni, siz.bin_radius, siz.dV_dlnr(kk,:));
    toc
    [aod_lg, ssa_lg] = anet_mie(wl,ni, bin_rad, dVdlnr);
    toc
    aod2 = [eaod.AOD_Extinction_Total_440nm_(kk),eaod.AOD_Extinction_Total_675nm_(kk),...
        eaod.AOD_Extinction_Total_870nm_(kk),eaod.AOD_Extinction_Total_1020nm_(kk)];        
    sb(2) = subplot(1,2,2); hold('on');
    plot(wl, aod, '-b',lambda, aod2,'rx',wl, aod_lg,'k*'); logy; logx;
    legend('Mie','Ext AOD v2','Mie log-normal')
    xlabel('wavelength [nm]');ylabel('Optical depth [unitless]')
    title(['AOD from .aod, .cad, and Mie:',datestr(siz.time(kk),'mmm dd, HH:MM:SS')]);
    hold('on');set(sb(2),'pos',[0.5703    0.1100    0.3805    0.8150]);
end

fit_aod_basis(wl, aod);


% Here is how the basis set of aods were computed. Looks like I used the
% bin_radius values from aeronet *.siz file t
% bin_radius(1) = 0.05 um = 50 nm.  bin_radius(end) = 15 um.  
% bin_rad is defined in logspace from 25nm to 30 um. 
lambda=[441, 673, 873, 1022];
n_i = [1.581700,1.584500,1.600000,1.600000] + j.*[0.025597,0.021507,0.020917,0.020566];
% Would be interesting to see how much this varies in Aeronet retrievals
% out to 1.6 um and for different sites.  
% Hypothetically, the actual index of refraction it shouldn't mattter too much since we're only trying to
% fit the AOD shape
% But this might be good to test using a more "aqueous" aerosol with n
% ~1.33 as well as with a variety of k values.

wl = [325:25:1700];
ni = interp1(lambda, n_i, wl, 'linear','extrap');

bin_rad = logspace(log10(siz.bin_radius(1)./2), log10(2.*siz.bin_radius(end)),4.*length(siz.bin_radius)); % 88 bins
cen = [5:5:length(bin_rad)-5];  % Define 16 modes 
tic
for ci = length(cen):-1:1
    PSD(ci,:) = LnNormal(bin_rad, bin_rad(cen(ci)), 1.4);
    [aod_md(ci,:), ssa_md(ci,:)] = anet_mie(wl,ni, bin_rad, PSD(ci,:));
    toc
end
    toc

    figure; plot(wl, aod_md2(1:6,:), '-', wl, aod_md2(7:12,:), '--'); logx; logy
    legend(num2str([ray, 1e3.*bin_rad(cen(1)),1e3.*bin_rad(cen(2)), 1e3.*bin_rad(cen(3)),...
        1e3.*bin_rad(cen(4)),1e3.*bin_rad(cen(5)),1e3.*bin_rad(cen(6)),...
        1e3.*bin_rad(cen(7)),1e3.*bin_rad(cen(8)),1e3.*bin_rad(cen(9)),...
        1e3.*bin_rad(cen(10)),1e3.*bin_rad(cen(11))]'));
   %Based on this plot we probaby don't need aod_md with PSD centers 
    % Okay, now we want to fit "aod" computed above with anet_mie above from the bin-wise aeronet ASD
    % with aod_mode as a basis set.
    um = wl./1000;
   ray_tod = (0.008569 .* (um .^(-4))) .* (1.0 + (0.0113 .* (um.^(-2))) + (0.00013 .* (um.^(-4)))) ;
   aod_md = [ray_tod;aod_md];
    aod_mode.bin_radius = bin_rad;
    aod_mode.PSD = PSD;
    aod_mode.log_wl = log(wl'); 
    aod_mode.log_modes = log(aod_md'); 
    log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl'),'linear','extrap');
    Ks = fit_it_2(log(wl'), log(aod'), log_modes); 
    log_aod_fit = aod_mode.log_modes*Ks'; aod_fit = exp(log_aod_fit);
    aod_mode.usage = ["First, interp log_aod to desired wl (in log-space)";"Second, compute fitting Ks with fit_it_2"; "Lastly, evaluate as exponentiation of log_aod*Ks'"]
    aod_mode.interp_log_modes = "log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl'),'linear','extrap')";
    aod_mode.fit_Ks = "Ks = fit_it_2(log(wl'), log(aod'), log_modes)";
    aod_mode.use_Ks = "log_AOD = aod_mode.log_modes*Ks')";
  save([strrep(which('anet_mie'),'anet_mie.m','aod_mode.mat')],'-struct','aod_mode');
  
  
  return
  
  clear aod_mode
  aod_mode = load('aod_mode.mat')
    K = fit_it_2(log(wl'),log(aod'), log(aod_md'));
    figure; plot(wl, log(aod),'-', wl,K*log(aod_md),'x',wl,Ks*aod_mode.log_aod','r.')
% % X and Y must be Mx1 column vectors.  Array V is MxN with N-columns of length Mx1. 

wl_ = wl>430 & wl<1000;
aod_fit2 = fit_aod_basis(wl(wl_), [aod(wl_),2.*aod(wl_)],wl);
figure; plot(wl(wl_), [aod(wl_),2.*aod(wl_)], 'x', wl, aod_fit2,'-');
    
    
kk = 0; kk = kk + 1; 
for kk = 2:22

aod2 = [eaod.AOD_Extinction_Total_440nm_(kk),eaod.AOD_Extinction_Total_675nm_(kk),...
    eaod.AOD_Extinction_Total_870nm_(kk),eaod.AOD_Extinction_Total_1020nm_(kk)];
aod3 = [cod.AOD_Coincident_Input_440nm_(kk),cod.AOD_Coincident_Input_675nm_(kk),...
    cod.AOD_Coincident_Input_870nm_(kk),cod.AOD_Coincident_Input_1020nm_(kk)];
 figure_(98);

 plot(lambda, aod2,'-rx',lambda, aod3,'-k*'); logy; logx; 
 legend('Ext AOD v2','Coin. AOD v2')
xlabel('wavelength [nm]');ylabel('Optical depth [unitless]')
title(['AOD from .aod, .cad, and Mie:',datestr(siz.time(kk),'mmm dd, HH:MM:SS')]);
end



figure; plot(aod_lev2.time, aod_lev2.AOD_675nm, '-o',eaod.time, eaod.AOD_Extinction_Total_675nm_, 'rx', cod.time, cod.AOD_Coincident_Input_675nm_,'k*'); dynamicDateTicks
figure; plot(aod_lev2.time, aod_lev2.AOD_675nm-aod_lev1p5.AOD_675nm, '-x');dynamicDateTicks

figure; plot(siz.bin_radius, siz.dV_dlnr(1,1:end)','-bx'); logx; % Confirmed, plot looks fine
xlabel('radius [um]'); legend('from .siz')

%property of log-normal
% log(vol.VMR_F) = log(vol.Nmr) + 3.*(log(std)^2) ==>
% log(vol.Nmr) = log(vol.VMR_F)- 3.*(log(std)^2)
Nmr_F = exp(log(vol.VMR_F) - 3.*log(vol.Std_F).^2);
Nmr_C = exp(log(vol.VMR_C) - 3.*log(vol.Std_C).^2);

Nmr = exp(log(4.2) - 3.*log(2).^2);

% SizeDist_Optics(1.55+0.001i, 150, 1.5, 550, 'density',1, 'nephscats',true)

% Reading data in fine, still trying to sort out what to provide
% SizeDist_optics from the aeronet retrievals.  Aeronet seems to be in
% dV/dln(r), but SizeDist_optics wants dN/dlogDp and geom std dev.

siz.bin_radius(2:end)./siz.bin_radius(1:end-1)
SD = [siz.pos0d05, siz.pos0d065604,siz.pos0d086077,siz.pos0d112939,...
    siz.pos0d148184,siz.pos0d194429, siz.pos0d255105, siz.pos0d334716,...
    siz.pos0d439173, siz.pos0d576227, siz.pos0d756052, siz.pos0d991996,...
    siz.pos1d30157, siz.pos1d70776, siz.pos2d2407,...
    siz.pos2d93997, siz.pos3d85745, siz.pos5d06126, siz.pos6d64074, siz.pos8d71315,...
    siz.pos11d4323, siz.pos15];
diam = [0.05, 0.065604,0.086077,0.112939,...
    0.148184,0.194429, 0.255105, 0.334716,...
    0.439173, 0.576227, 0.756052, 0.991996,...
    1.30157, 1.70776, 2.2407,...
    2.93997, 3.85745, 5.06126, 6.64074, 8.71315,...
    11.4323, 15];
figure; plot(1000.*diam, SD,'o-')

anet_wl = [440,675,870,1020];
n = [rin.Refractive_Index_Real_Part_440nm_+j.*rin.Refractive_Index_Imaginary_Part_440nm_, ...
    rin.Refractive_Index_Real_Part_675nm_+j.*rin.Refractive_Index_Imaginary_Part_675nm_, ...
    rin.Refractive_Index_Real_Part_870nm_+j.*rin.Refractive_Index_Imaginary_Part_870nm_, ...
    rin.Refractive_Index_Real_Part_1020nm_+j.*rin.Refractive_Index_Imaginary_Part_1020nm_];

for wl = length(anet_wl):-1:1
opts = SizeDist_Optics(n(1,wl), 1000.*vol.VMR_F(1), vol.Std_F(1), anet_wl(wl),'nobackscat',true);
ext_F(wl) = opts.extinction;
opts = SizeDist_Optics(n(1,wl), vol.VMR_C(1), vol.Std_C(1), anet_wl(wl),'nobackscat',true);
ext_C(wl) = opts.extinction;
end
tau_F = ext_F.*vol.VolC_F(1);
tau_C = ext_C.*vol.VolC_C(1);
tau_ext = tau_F + tau_C;

ext_aod = [eaod.AOD_Extinction_Total_440nm_,eaod.AOD_Extinction_Total_675nm_,...
    eaod.AOD_Extinction_Total_870nm_,eaod.AOD_Extinction_Total_1020nm_];
figure; plot(anet_wl, ext_aod(1,:),'-o',anet_wl, 20.*tau_ext,'kx-');
