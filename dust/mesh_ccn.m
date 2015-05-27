function ccn = mesh_ccn;
ccn_raw_pct = read_ds_2006;
cpc_ccn = read_cpcCCN_2006;
[AinB,BinA] = nearest(ccn_raw_pct.time, cpc_ccn.time);
ccn.time = cpc_ccn.time(BinA);
ccn.hex_flags = cpc_ccn.hex_flags(BinA);
ccn.flags = cpc_ccn.flags(BinA);
ccn.cpc_corr = cpc_ccn.cpc_corr(BinA);
ccn.ccn_corr = cpc_ccn.ccn(BinA);
ccn.cnc_raw = ccn_raw_pct.N_ccn_raw(AinB);
ccn.SS_pct = ccn_raw_pct.supersat_calc(AinB);
clear ccn_raw_pct cpc_ccn
save nim_ccn.mat ccn
% gte_1 = ccn.SS_pct>1;
% scatter(serial2doy(ccn.time(gte_1)), ccn.ccn_corr(gte_1) ./ ccn.cpc_corr(gte_1), 2, ccn.SS_pct(gte_1))
% figure; scatter(serial2doy(ccn.time(gte_1)), ccn.ccn_corr(gte_1) ./ ccn.cpc_corr(gte_1), 4, ccn.SS_pct(gte_1)); colorbar

%From direct comparison, these ccn_corr and cpc_corr values are the same as
%those originally in the h_eX.amf file from Anne Jefferson so I'll open each of the monthly
%files, insert these (SS_pct?) values, and delete the size-cut differentiated fields
%since they aren't in the impactor stream. 

%Then we'll fix each month onto a hard 1 min grid, compute aip, and
%downsample.
