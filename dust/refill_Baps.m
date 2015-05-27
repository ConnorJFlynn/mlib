function aip = refill_Baps(aip);
%Mark times between doy 322-332 (inclusive) as NaN due to impactor failure.

[aip.Bap_G_3W_1um,aip.w_G_1um]  = refill_Bap(aip.time, aip.Bap_G_3W_1um, aip.Bsp_G_Dry_1um, aip.w_G_1um);
[aip.Bap_G_3W_10um,aip.w_G_10um] = refill_Bap(aip.time, aip.Bap_G_3W_10um, aip.Bsp_G_Dry_10um, aip.w_G_10um);
[aip.Bap_R_3W_1um ,aip.w_R_1um]= refill_Bap(aip.time, aip.Bap_R_3W_1um, aip.Bsp_R_Dry_1um, aip.w_R_1um);
[aip.Bap_R_3W_10um,aip.w_R_10um] = refill_Bap(aip.time, aip.Bap_R_3W_10um, aip.Bsp_R_Dry_10um, aip.w_R_10um);
[aip.Bap_B_3W_1um ,aip.w_B_1um]= refill_Bap(aip.time, aip.Bap_B_3W_1um, aip.Bsp_B_Dry_1um, aip.w_B_1um);
[aip.Bap_B_3W_10um,aip.w_B_10um] = refill_Bap(aip.time, aip.Bap_B_3W_10um, aip.Bsp_B_Dry_10um, aip.w_B_10um);




