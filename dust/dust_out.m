function [foutname, txt_out] =dust_out(aip);
% This creates a text output file of the Niamey dust metric from an input
% aip file.  The output will be column-separated.
out_dir = 'C:\case_studies\dust\dust_metric\';
if (aip.time(2)-aip.time(1))>.5
   fname = 'niamey_daily_dust.txt';
else
   fname = 'niamey_hourly_dust.txt';
end
%%
meta_str1 = ['This composite data set includes local, surface,and column aerosol properties at the Niamey ARM ARM site '];
meta_str2 = ['during times judged to be dominated by dust.  Questions can be addressed to Connor.Flynn@pnl.gov.'];
meta_str3 = ['Niamey, Niger, Africa. Lon = 2.172 N, Lat = 13.481 E, Elev =205 meters'];
%%
header_str = ' year, month, day, Hh_UTC, jday_UTC, dust_event, ';%6
header_str = [header_str, 'Bsp_R_1um,  Bsp_G_1um, Bsp_B_1um,  Bsp_R_10um,  Bsp_G_10um, Bsp_B_10um, '];%6
header_str = [header_str, 'Bbsp_R_1um,  Bbsp_G_1um, Bbsp_B_1um,  Bbsp_R_10um,  Bbsp_G_10um, Bbsp_B_10um, '];%6
header_str = [header_str, 'Bap_R_1um,  Bap_G_1um, Bap_B_1um,  Bap_R_10um,  Bap_G_10um, Bap_B_10um, '];%6
header_str = [header_str, 'SSA_R_1um,  SSA_G_1um, SSA_B_1um,  SSA_R_10um,  SSA_G_10um, SSA_B_10um, '];%6
header_str = [header_str, 'bsf_R_1um,  bsf_G_1um, bsf_B_1um,  bsf_R_10um,  bsf_G_10um, bsf_B_10um, '];%6
header_str = [header_str, 'g_R_1um,  g_G_1um, g_B_1um,  g_R_10um,  g_G_10um, g_B_10um, '];%6
header_str = [header_str, 'Ang_Bs_BG_1um, Ang_Bs_BR_1um, Ang_Bs_GR_1um, Ang_Bs_BG_10um, Ang_Bs_BR_10um, Ang_Bs_GR_10um,' ];%6
header_str = [header_str, ' Ang_Ba_BG_1um, Ang_Ba_BR_1um, Ang_Ba_GR_1um, Ang_Ba_BG_10um, Ang_Ba_BR_10um, Ang_Ba_GR_10um, '];%6
header_str = [header_str, ' subfrac_Bs_R, subfrac_Bs_G, subfrac_Bs_B, subfrac_Ba_R, subfrac_Ba_G, subfrac_Ba_B, '];%6
header_str = [header_str, ' CN_frac_ss_p5, CN_frac_ss_p7, CN_frac_ss_p9, CN_frac_ss_1p2, '];%4
header_str = [header_str, ' aod_415nm, aod_500nm, aod_615nm, aod_673nm, aod_870nm, Ang_aod_500_870, ' ];%6
header_str = [header_str, ' twr_vis_10min, wind_spd, wind_dir, wind_N, wind_E, '];%5
header_str = [header_str, ' T_amb, RH_amb, atmos_pres ' ];%3
% 78 fields
%%

V = datevec(aip.time);
yyyy = V(:,1);
% txt_out needs to be composed of data oriented as column vectors.
txt_out = [V(:,1), V(:,2),V(:,3),V(:,4),serial2doy(aip.time), single(aip.dust),...
   aip.Bsp_R_Dry_1um, aip.Bsp_G_Dry_1um, aip.Bsp_B_Dry_1um, aip.Bsp_R_Dry_10um, aip.Bsp_G_Dry_10um, aip.Bsp_B_Dry_10um,...
   aip.Bbsp_R_Dry_1um, aip.Bbsp_G_Dry_1um, aip.Bbsp_B_Dry_1um, aip.Bbsp_R_Dry_10um, aip.Bbsp_G_Dry_10um, aip.Bbsp_B_Dry_10um,...
   aip.Bap_R_3W_1um, aip.Bap_G_3W_1um, aip.Bap_B_3W_1um, aip.Bap_R_3W_10um, aip.Bap_G_3W_10um, aip.Bap_B_3W_10um,...
   aip.w_R_1um, aip.w_G_1um, aip.w_B_1um, aip.w_R_10um, aip.w_G_10um, aip.w_B_10um, ...   
   aip.bsf_R_1um, aip.bsf_G_1um, aip.bsf_B_1um, aip.bsf_R_10um, aip.bsf_G_10um, aip.bsf_B_10um, ...   
   aip.g_R_1um, aip.g_G_1um, aip.g_B_1um, aip.g_R_10um, aip.g_G_10um, aip.g_B_10um, ...     
   aip.Ang_Bs_B_G_1um, aip.Ang_Bs_B_R_1um, aip.Ang_Bs_G_R_1um, aip.Ang_Bs_B_G_10um, aip.Ang_Bs_B_R_10um, aip.Ang_Bs_G_R_10um, ...     
   aip.Ang_Ba_B_G_1um, aip.Ang_Ba_B_R_1um, aip.Ang_Ba_G_R_1um, aip.Ang_Ba_B_G_10um, aip.Ang_Ba_B_R_10um, aip.Ang_Ba_G_R_10um, ...        
   aip.subfrac_Bs_R, aip.subfrac_Bs_G, aip.subfrac_Bs_B, aip.subfrac_Ba_R, aip.subfrac_Ba_G, aip.subfrac_Ba_B, ...
   aip.CN_frac_gtp5, aip.CN_frac_gtp7, aip.CN_frac_gtp9, aip.CN_frac_gt1p2, ...
   aip.aod_415nm, aip.aod_500nm, aip.aod_615nm, aip.aod_673nm, aip.aod_870nm, aip.ang_500_870_MFRSR, ...
   aip.pwd_avg_vis_10_min, aip.wind_spd, aip.wind_dir, aip.wind_N, aip.wind_E, ...
   aip.T_Ambient, aip.RH_Ambient, aip.P_Ambient];

%%



foutname = [[out_dir fname]];
fid = fopen(foutname,'w+');

fprintf(fid,'%s \n',meta_str1 );
fprintf(fid,'%s \n',meta_str2 );
fprintf(fid,'%s \n',meta_str3 );
fprintf(fid,'%s \n',header_str );
format_str = ['%d,  %d,  %d,  %d,  %2.5f,  %d, ']; % 5
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 Bsp
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 Bbsp
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 Bap
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 SSA
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 bsf
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 g
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 ang_Bs
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 ang_Ba
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 subfrac
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f, ']; % 4 CN_fracs
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f,  %2.5f, %2.5f, ']; % 6 aod
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f, %2.5f, %2.5f, ']; % 5 vis and winds
format_str = [format_str, '%2.5f,  %2.5f,  %2.5f \n']; % 3 ambient
fprintf(fid,format_str,txt_out');
fclose(fid);
