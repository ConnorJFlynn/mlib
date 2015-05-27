function P = ccn_dT_cal(ccn1)

ccn1 = ARM_nc_display;
xl = xlim;
qc = ccn1.vdata.qc_N_CCN;
qc = bitset(qc,17,0);
qc = bitset(qc,19,0);
ccn1_ = ccn1;
ccn1_.vdata.qc_N_CCN =qc;
qc_imp = anc_qc_impacts(qc, ccn1.vatts.qc_N_CCN); 
xl_ = serial2hs(ccn1.time)>=xl(1) & serial2hs(ccn1.time)<=xl(2);
[P] = polyfit(ccn1_.vdata.reported_temperature_gradient(qc_imp==0&xl_), ccn1_.vdata.supersaturation_set_point(qc_imp==0&xl_),1)


return