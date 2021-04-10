function test_aod_fitting
% Connor, 2020-08-??
% This code develops the basis set of log(OD) of monomodal
% lognormal spheres from Mie scattering intended to provide a best-fit of
% supplied AODs at arbitrary wavelengths.

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

% It looks like maybe permitting these basis sets to be too monomodal is
% permitting to highly structured AOD with poor extrapolation 

wl = [325:25:1700];
ni = interp1(lambda, n_i, wl, 'linear','extrap');
% siz = rd_anet_siz_v3(getfullname('*.siz','cimel','Select anet ".siz" file'));
bin_rad = logspace(log10(.050), log10(5),10); %

% cen = [4:3:length(bin_rad)-4];  % Define 18 modes
cen = [1:length(bin_rad)];
dev = 1.5;
binz = logspace(log10(bin_rad(1)./(1.5*dev)),log10(bin_rad(1).*(1.5*dev)),41);
PSD = LnNormal(binz, bin_rad(1), dev);
figure_(14);
for ci = length(cen):-1:1
    tic

    %     PSD(ci,:) = LnNormal(bin_rad, bin_rad(cen(ci)), dev);
    %     [aod_md(ci,:), ssa_md(ci,:)] = anet_mie(wl,ni, bin_rad, PSD(ci,:));
    %     toc
    bins(ci,:) = logspace(log10(bin_rad(cen(ci))./(1.5*dev)),log10(bin_rad(cen(ci)).*(1.5*dev)),41);
    [aod_md2(ci,:), ssa_md(ci,:)] = anet_mie(wl,ni, bins(ci,:), PSD);
    ss(1) = subplot(1,2,1);
    %     plot(bin_rad, PSD(ci,:),'-',bins, PSD2(ci,:),'-');hold('on');logx;
    plot(bins(ci,:), PSD,'-');hold('on');logx;
    ss(2) = subplot(1,2,2);
    %     plot(wl, aod_md(ci,:),'-', wl, aod_md2(ci,:),'-'); hold('on');logx; logy
    plot(wl, aod_md2(ci,:),'-'); hold('on');logx; logy
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

aod_mode.bin_radius = bin_rad;
aod_mode.bins = bins;
aod_mode.PSD = PSD;
aod_mode.log_wl = log(wl');
aod_mode.log_modes = log(aod_md2');
log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl'),'linear','extrap');
% Ks = fit_it_2(log(wl'), log(aod'), log_modes);
% log_aod_fit = aod_mode.log_modes*Ks'; aod_fit = exp(log_aod_fit);
aod_mode.usage = ["First, interp log_aod to desired wl (in log-space)";...
    "Second, compute fitting Ks with fit_it_2"; ...
    "Lastly, evaluate as exponentiation of log_aod*Ks'"];
aod_mode.interp_log_modes = "log_modes = interp1(aod_mode.log_wl, aod_mode.log_modes,log(wl'),'linear','extrap')";
aod_mode.fit_Ks = "Ks[1xN] = fit_it_2(log(wl[Mx1]), log(aod[Mx1]), log_modes[MxN])";
aod_mode.use_Ks = "log_AOD[Mx1] = aod_mode.log_modes[MxN]*Ks')";
save([strrep(which('anet_mie'),'anet_mie.m','aod_mode.mat')],'-struct','aod_mode');

clear aod_mode; aod_mode = load([strrep(which('anet_mie'),'anet_mie.m','aod_mode.mat')]);

figure; plot(exp(aod_mode.log_wl), fliplr(exp(aod_mode.log_modes)), '-'); logx; logy
legend([string(round(1e4.*bin_rad)/10)]);

return

