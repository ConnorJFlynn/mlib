function cts_tester

% We need to load psap1s, neph3w, and aop1m.
% Find a time with a filter change and sift with respect to Tr
% interpolate neph values to psap times

% compute sample length as psap flow (LPM) / spot_size to get meters/sec
psap = anc_bundle_files;
neph = anc_bundle_files;
aop  = anc_bundle_files;

L/min = 1000 cm^3/60s = psap.vdata.    1e3(cm^3/L)/1e6(cm^3/m^3)/60s / (17.5e-6 m^2)
sample_length = (psap.vdata.sample_flow_rate./psap.vdata.spot_size_area).*(1e3/1e6/60/1e-6);
goodP = psap.sample_flow_rate>0;
goodN = anc_qc_impacts(neph.vdata.qc_Bs_B_Dry_Neph3W, neph.vatts.qc_Bs_B_Dry_Neph3W)==0;
Bs_B_m = interp1(neph.time(goodN), neph.vdata.Bs_B_Dry_Neph3W(goodN), psap.time,'linear')./1e6;
Bs_B_od = Bs_B_m .* sample_length;
figure; plot(psap.time, psap.vdata.transmittance_blue, '.'); dynamicDateTicks
figure; plot(aop.time, aop.vdata.g_B,'k.'); logy; yl = ylim; liny; ylim(yl)
good_aop = anc_qc_impacts(aop.vdata.qc_g_B, aop.vatts.qc_g_B)==0;
g_B = interp1(aop.time(good_aop), aop.vdata.g_B(good_aop), psap.time,'linear');

xl = xlim;
xl_ii = find(psap.time>xl(1) & psap.time<xl(2));

for ii = 1:length(xl_ii)
   ij = xl_ii(ii);
[delta_a_, status] = cts_solver(delta_f_meas(ij), delta_s_meas(ij), g_meas(ij), delta_a_start);
end


end