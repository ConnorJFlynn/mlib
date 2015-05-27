function aip = aos_aip(aos);

% Compute intensive properties
% aos = flag_bads_(aos);
aip = aos_aip_(aos);

% For missing Bap values, interpolate across gaps with SSA and then fill in
% Bap values correspsonding to good measured Bsp and interpolated SSA.
  aip = refill_Baps(aip);
% Test  
  aip = aos_aip_2(aip);


return

function aos = flag_bads_(aos);
bad_time = (serial2doy(aos.time)>321.3)&(serial2doy(aos.time)<332.5);

aos.Bap_G_3W_1um(bad_time)=NaN;
aos.Bap_G_3W_1um(bad_time)=NaN;
aos.Bsp_G_Dry_1um(bad_time)=NaN;
aos.Bbsp_G_Dry_1um(bad_time)=NaN;

aos.Bap_G_3W_10um(bad_time)=NaN;
aos.Bsp_G_Dry_10um(bad_time)=NaN;
aos.Bbsp_G_Dry_10um(bad_time)=NaN;

aos.Bap_R_3W_1um(bad_time)=NaN;
aos.Bsp_R_Dry_1um(bad_time)=NaN;
aos.Bbsp_R_Dry_1um(bad_time)=NaN;

aos.Bap_R_3W_10um(bad_time)=NaN;
aos.Bsp_R_Dry_10um(bad_time)=NaN;
aos.Bbsp_R_Dry_10um(bad_time)=NaN;

aos.Bap_B_3W_1um(bad_time)=NaN;
aos.Bsp_B_Dry_1um(bad_time)=NaN;
aos.Bbsp_B_Dry_1um(bad_time)=NaN;

aos.Bap_B_3W_10um(bad_time)=NaN;
aos.Bsp_B_Dry_10um(bad_time)=NaN;
aos.Bbsp_B_Dry_10um(bad_time)=NaN;
