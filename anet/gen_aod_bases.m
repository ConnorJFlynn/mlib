function gen_aod_bases
% Connor, 2020-08-??
% This code develops the basis set of log(OD) of monomodal
% lognormal spheres from Mie scattering intended to provide a best-fit of
% supplied AODs at arbitrary wavelengths. 
%These vmr and std span the observed PDFs from SGP from 2017-2020.  
% We'll try 7 basis vectors from log-normal PSDs computed with
% Using vmr_F = [0.1200 0.1756 0.2569 0.3759 0.5500 0.9000] with std [0.3750 0.4500 0.5000 0.5000 0.5500 0.5000]
% Using vmr_C = [1.5030 2.5100 4.1916 7] with std_C = [0.5500 0.5500 0.5500 0.5000]

% Here is how the basis set of aods were computed. Looks like I used the
% bin_radius values from aeronet *.siz file t
% bin_radius(1) = 0.05 um = 50 nm.  bin_radius(end) = 15 um.
% bin_rad is defined in logspace from 25nm to 30 um.
error('Deprecated.  Use gen_naod_bases instead.')
lambda=[441, 673, 873, 1022];
n_i = [1.5,1.5,1.5,1.5] + j.*[0.022,0.022,0.022,0.022];
% Would be interesting to see how much this varies in Aeronet retrievals
% out to 1.6 um and for different sites.
% Hypothetically, the actual index of refraction it shouldn't mattter too much since we're only trying to
% fit the AOD shape
% But this might be good to test using a more "aqueous" aerosol with n
% ~1.33 as well as with a variety of k values.

wl = logspace(log10(325), log10(1700),75);
ni = interp1(lambda, n_i, wl, 'linear','extrap');
% siz = rd_anet_siz_v3(getfullname('*.siz','cimel','Select anet ".siz" file'));
% bin_rad = logspace(log10(.050), log10(5),30); %
vmr = [.12, .16, .22, 1.5, 2.75, 5]; 
vmr = [logspace(log10(.12),log10(.55),5),logspace(log10(.9),log10(7),5)]
vmr = [logspace(log10(.08),log10(.65),7),logspace(log10(.85),log10(5),5)];
v_std = [.375,.45, .5, .5, .5, .55, .5, .55, .55, .55,.55, .5];
% cen = [4:3:length(bin_rad)-4];  % Define 18 modes
dev = exp(v_std);
tic
figure_(14);
cen = [1:length(vmr)];
for ci = length(cen):-1:1
    bin_rad = logspace(log10(vmr(ci)./4),log10(vmr(ci)*3),30);
    PSD = LnNormal(bin_rad, vmr(ci), dev(ci));    
    ss(1) = subplot(1,2,1);
    %     plot(bin_rad, PSD(ci,:),'-',bins, PSD2(ci,:),'-');hold('on');logx;
    plot(bin_rad, PSD,'-');hold('on');logx;
    [aod_md(ci,:)] = anet_mie(wl,ni, bin_rad, PSD);
    ss(2) = subplot(1,2,2);
    %     plot(wl, aod_md(ci,:),'-', wl, aod_md2(ci,:),'-'); hold('on');logx; logy
    plot(wl, aod_md(ci,:),'-'); hold('on');logx; logy
%     plot(wl, aod_md2(ci,:)./max(aod_md2(ci,:)),'-'); hold('on');logx; logy
    pause(0.2)
    toc
end
toc
% Did not work to add Rayleigh
% Based on the figure 12 generated above, it does not appear that bin_rad >
% 5 um add much value to the fit. Could even get by with 2.5 um cen=15;
% Likewise unclear if bins < 50 nm add much(cen = 1:3, maybe)
% um = wl./1000;
% ray_tod = (0.008569 .* (um .^(-4))) .* (1.0 + (0.0113 .* (um.^(-2))) + (0.00013 .* (um.^(-4)))) ;
% aod_md = [ray_tod;aod_md];% Add Rayleigh OD in front of AODs

% figure; plot(wl, aod_md2(1:6,:), '-', wl, aod_md2(7:12,:), '--'); logx; logy
% legend('Ray',num2str([1e3.*bin_rad(cen(1)),1e3.*bin_rad(cen(2)), 1e3.*bin_rad(cen(3)),...
%     1e3.*bin_rad(cen(4)),1e3.*bin_rad(cen(5)),1e3.*bin_rad(cen(6)),...
%     1e3.*bin_rad(cen(7)),1e3.*bin_rad(cen(8)),1e3.*bin_rad(cen(9)),...
%     1e3.*bin_rad(cen(10)),1e3.*bin_rad(cen(11))]'));
%Based on this plot we probaby don't need aod_md with PSD centers
% Okay, now we want to fit "aod" computed above with anet_mie above from the bin-wise aeronet ASD
% with aod_mode as a basis set.
clear aod_mode

aod_mode.vmr = vmr;
aod_mode.std = v_std;
aod_mode.log_wl = log(wl');
aod_mode.log_modes = log(aod_md');
% log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl'),'linear','extrap');
% Ks = fit_it_2(log(wl'), log(aod'), log_modes);
% log_aod_fit = aod_mode.log_modes*Ks'; aod_fit = exp(log_aod_fit);
aod_mode.usage = ["First, interp log_aod to desired wl (in log-space)";...
    "Second, compute fitting Ks with fit_it_2"; ...
    "Lastly, evaluate as exponentiation of log_aod*Ks'"];
aod_mode.interp_log_modes = "log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl'),'linear','extrap')";
aod_mode.fit_Ks = "Ks[1xN] = fit_it_2(log(wl[Mx1]), log(aod[Mx1]), log_modes[MxN])";
aod_mode.use_Ks = "log_AOD[Mx1] = aod_mode.log_modes[MxN]*Ks')";
save([strrep(which('anet_mie'),'anet_mie.m','aod_SD_mode.mat')],'-struct','aod_mode');

clear aod_mode; aod_SD_mode = load([strrep(which('anet_mie'),'anet_mie.m','aod_SD_mode.mat')]);

figure; plot(exp(aod_SD_mode.log_wl), (exp(aod_SD_mode.log_modes)), '-'); logx; logy
legend([string(round(1e4.*(aod_SD_mode.vmr))/10)]);

return

