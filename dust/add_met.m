function aos = add_met(aos);
% aos_met = add_met(aos);
met_dir = 'C:\case_studies\dust\nimmetM1.b1\bundle\';

met = ancload_coords([met_dir 'nimmetM1.b1.20060106.000000.cdf']);
[ainb, bina] = nearest(aos.time', met.time);

met.vars.relh_mean.data = ancgetdata(met, 'relh_mean');
met.vars.temp_mean.data = ancgetdata(met, 'temp_mean');
met.vars.atmos_pressure.data = ancgetdata(met, 'atmos_pressure');
met.vars.wind_dir_vec_avg.data = ancgetdata(met, 'wind_dir_vec_avg');
met.vars.wind_spd_vec_avg.data = ancgetdata(met, 'wind_spd_vec_avg');
met.vars.pwd_avg_vis_1_min.data = ancgetdata(met, 'pwd_avg_vis_1_min');
met.vars.pwd_avg_vis_10_min.data = ancgetdata(met, 'pwd_avg_vis_10_min');


aos.RH_Ambient(ainb) = met.vars.relh_mean.data(bina);
aos.T_Ambient(ainb) = met.vars.temp_mean.data(bina);
aos.P_Ambient(ainb) = met.vars.atmos_pressure.data(bina);
aos.wind_dir(ainb) = met.vars.wind_dir_vec_avg.data(bina);
aos.wind_spd(ainb) = met.vars.wind_spd_vec_avg.data(bina);
aos.pwd_avg_vis_1_min(ainb) = met.vars.pwd_avg_vis_1_min.data(bina);
aos.pwd_avg_vis_10_min(ainb) = met.vars.pwd_avg_vis_10_min.data(bina);
aos.pwd_avg_vis_1_min = aos.pwd_avg_vis_1_min';
aos.pwd_avg_vis_10_min = aos.pwd_avg_vis_10_min';
% fix pressure for part 1
NaNs = (aos.P_Ambient<500 & aos.time < 732750)|...
   aos.P_Ambient<90 | aos.P_Ambient > 1100;
aos.P_Ambient(NaNs) = NaN;
% Bad values removed, now fix units.
%
hpa = aos.P_Ambient>500;
aos.P_Ambient(hpa) = aos.P_Ambient(hpa)./10;



met = ancload_coords([met_dir 'nimmetM1.b1.20060911.200000.cdf']);
[met.time, inds] = unique(met.time);
met.dims.time.length = length(met.time);
met.vars.relh_mean.data = ancgetdata(met, 'relh_mean');
met.vars.temp_mean.data = ancgetdata(met, 'temp_mean');
met.vars.atmos_pressure.data = ancgetdata(met, 'atmos_pressure');
met.vars.wind_dir_vec_avg.data = ancgetdata(met, 'wind_dir_vec_avg');
met.vars.wind_spd_vec_avg.data = ancgetdata(met, 'wind_spd_vec_avg');
met.vars.pwd_avg_vis_1_min.data = ancgetdata(met, 'pwd_avg_vis_1_min');
met.vars.pwd_avg_vis_10_min.data = ancgetdata(met, 'pwd_avg_vis_10_min');

met.vars.relh_mean.data = met.vars.relh_mean.data(inds);
met.vars.temp_mean.data = met.vars.temp_mean.data(inds);
met.vars.atmos_pressure.data = met.vars.atmos_pressure.data(inds);
met.vars.wind_dir_vec_avg.data = met.vars.wind_dir_vec_avg.data(inds);
met.vars.wind_spd_vec_avg.data = met.vars.wind_spd_vec_avg.data(inds);
met.vars.pwd_avg_vis_1_min.data = met.vars.pwd_avg_vis_1_min.data(inds);
met.vars.pwd_avg_vis_10_min.data = met.vars.pwd_avg_vis_10_min.data(inds);

[ainb, bina] = nearest(aos.time', met.time);

aos.RH_Ambient(ainb) = met.vars.relh_mean.data(bina);
aos.T_Ambient(ainb) = met.vars.temp_mean.data(bina);
aos.P_Ambient(ainb) = met.vars.atmos_pressure.data(bina);
aos.wind_dir(ainb) = met.vars.wind_dir_vec_avg.data(bina);
aos.wind_spd(ainb) = met.vars.wind_spd_vec_avg.data(bina);
aos.pwd_avg_vis_1_min(ainb) = met.vars.pwd_avg_vis_1_min.data(bina);
aos.pwd_avg_vis_10_min(ainb) = met.vars.pwd_avg_vis_10_min.data(bina);

NaNs = aos.RH_Ambient<=1;
aos.RH_Ambient(NaNs) = NaN;
% aos.wind_N = aos.wind_spd .* cos(aos.wind_dir*pi/180);
% aos.wind_E = aos.wind_spd .* cos(aos.wind_dir*pi/180);


%    inds = interp1(ccn.time, [1:length(ccn.time)],aos_mon.time, 'nearest');
%    if isfield(aos_mon,'fname')
%       aos_mon = rmfield(aos_mon,'fname');
%    end


