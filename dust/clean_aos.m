% Duplicate Anne Jefferson's results from Niamey...
% 
% clean_aos - path to a finished aos metric
% % Read or load year-long AOS file
% [aos] = read_aos_h;
% aos = rmfield(aos,'Bap_G');
% %%
aos = loadinto('C:\case_studies\dust\nimaosM1.noaa\from_Anne\h_eX.mat');
% %%
aos = add_ccn(aos); % Reads in ccn data from mesh_data and adds to aos data above.
% The values read in by add_ccn correspond to screened values of
% CN_amb and CN_contr.  Specifically, CN_amb == CCN_corr and CN_contr ==
% CPC_corr, except some negative values remained and have been removed.  
% The field SS_pct is the supersaturation value for the CCN.
%%
% Add in barn aod
aos = add_aod(aos);
%%
% Add in met 
% save 'C:\case_studies\dust\nimaosM1.noaa\from_Anne\h_eX.mat' 'aos'
aos = add_met(aos);
%%

save 'C:\case_studies\dust\nimaosM1.noaa\from_Anne\h_eX.mat' 'aos'
% Divide year-long file into months
%%
% aos = loadinto('C:\case_studies\dust\nimaosM1.noaa\from_Anne\h_eX.mat');
aos2monthly(aos);
%%
 %Then process each monthly file...
aos_mon_proc;
   % grid_aos_1min
   % impact_aos_h_
   % aos_aip_
   % grid_1h
   %%

   dust = (aip_1h.Bsp_G_Dry_10um > 200)&(aip_1h.Ang_Bs_B_G_10um<0.5)&...
(aip_1h.Ang_Bs_G_R_1um<1)& ...
((aip_1h.subfrac_Bs_G<0.25)|...
((aip_1h.subfrac_Bs_G>0.25)&(aip_1h.subfrac_Bs_G<0.7)&(aip_1h.w_G_10um>0.89)));



%Now let's see if this incorporates or misses any of the initially
%indicated tests, and if it looks at wavelenght response of dust
%absorption.
   
% 
% get_aos_flags - used only initially to recover the size-cut flags from the raw time series to patch/repair the NOAA edited data.
% aux = auxcat
% read_aos_h.m - used to read the entire year of NOAA edited h_e files.
% read_aos_aH.m -used to read the hourly a data of NOAA edited data.
% anctimegrid - used to push the aos data onto a fixed time grid.  Will need to adapt for non-netcdf output of read_aos_h
% aoscorr.m - don't use for now.
% impact_aos_h - insert size-cut flag, separate data according to size cut, catch missings, linearly interpolate
% aos_aip.m - adapt for use with non-cdf output of impact_aos_h
%    aos_grid = loadinto([aos_1h_pname, mats(m).name]);
%    aip = aos_aip(aos_grid);
%    aip = grid_1h(aip);
%%
% This block for 1hr aip data...
%%
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.Ang_Bs_B_G_10um,aip_1h.Ang_Bs_B_R_10um,aip_1h.Ang_Bs_G_R_10um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, scattering, 10 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.Ang_Bs_B_G_1um,aip_1h.Ang_Bs_B_R_1um,aip_1h.Ang_Bs_G_R_1um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, scattering, 1 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.Ang_Ba_B_G_10um,aip_1h.Ang_Ba_B_R_10um,aip_1h.Ang_Ba_G_R_10um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, absorption, 10 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.Ang_Ba_B_G_1um,aip_1h.Ang_Ba_B_R_1um,aip_1h.Ang_Ba_G_R_1um],'.')
legend('blue-green','blue-red','green-red');
title('Angstrom exponents, absorption, 1 um impactor')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.subfrac_Bs_B,aip_1h.subfrac_Bs_G,aip_1h.subfrac_Bs_R],'.')
legend('blue','green','red');
title('Submicron scattering fraction')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.subfrac_Ba_B,aip_1h.subfrac_Ba_G,aip_1h.subfrac_Ba_R],'.')
legend('blue','green','red');
title('Submicron absorption fraction')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.w_B_1um,aip_1h.w_G_1um,aip_1h.w_R_1um],'.');
legend('blue','green','red');
title('SSA 1um')
ax(axi) =gca; axi = axi+1;
%
figure; plot(serial2doy(aip_1h.time), [aip_1h.w_B_10um,aip_1h.w_G_10um,aip_1h.w_R_10um],'.');
legend('blue','green','red');
title('SSA 10um')
ax(axi) =gca; axi = axi+1;
linkaxes(ax,'x')
%%
   


%
% ccn_pname = ['C:\case_studies\dust\nimaosccnM1.a1\'];
% wet_ccn = ancload([ccn_pname, 'nimaosccnM1.a1.20060812.000000.cdf']);
% %%
% 
% figure; plot(serial2doy(wet_soot.time), wet_ccn.vars.N_CCN.data ./ wet_soot.vars.N_CPC_1.data, '.')
% Wet soot, Aug 22-25
pname = ['C:\case_studies\dust\nimaosM1.a1\'];
wet_soot = ancload([pname, 'nimaosM1.a1.20060822.000000.cdf']);
wet_soot = anccat(wet_soot,ancload([pname, 'nimaosM1.a1.20060823.000000.cdf']));
wet_soot = anccat(wet_soot,ancload([pname, 'nimaosM1.a1.20060824.000000.cdf']));
wet_soot = anccat(wet_soot,ancload([pname, 'nimaosM1.a1.20060825.000000.cdf']));
% wet_soot = anccat(wet_soot,ancload([pname, 'nimaosM1.a1.20060826.000000.cdf']));
% Check flags
% Reject flagged values and missings (and negatives?)
% Run a regression over adjacent size cuts and interpolate to fill between.
%
%
%%
wet_soot = aoscorr(wet_soot);
wet_soot = interleave_aos(wet_soot);
wet_soot = anctimegrid(wet_soot,1./(60*24),floor(wet_soot.time(1)),ceil(wet_soot.time(end)),-9999);
wet_soot = aos_aip(wet_soot);
wet_soot.vars = rmfield(wet_soot.vars,'flags_NOAA');
wet_soot_30 = ancdownsample(wet_soot,30);
%%

dry_dust = ancload([pname, 'nimaosM1.a1.20060217.000000.cdf']);
dry_dust = anccat(dry_dust,ancload([pname, 'nimaosM1.a1.20060218.000000.cdf']));
dry_dust = aoscorr(dry_dust);
dry_dust = anctimegrid(dry_dust, 1./(60*24),floor(dry_dust.time(1)),ceil(dry_dust.time(end)),-9999);
dry_dust = aos_aip(dry_dust);
%%
dry_dust.vars = rmfield(dry_dust.vars, 'flags_NOAA');
dry_dust_30 = ancdownsample(dry_dust,30);
%%

