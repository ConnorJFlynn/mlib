function mfr = cat_filt_mfraod;
% cat_filt_mfraod

mfr_files = getfullname('*mfrsr*aod*.cdf');
mfr = anc_load(mfr_files{1});


keep = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1, mfr.vatts.qc_aerosol_optical_depth_filter1)==0; 
keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2, mfr.vatts.qc_aerosol_optical_depth_filter2)==0;
keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3, mfr.vatts.qc_aerosol_optical_depth_filter3)==0;
keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4, mfr.vatts.qc_aerosol_optical_depth_filter4)==0;
keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5, mfr.vatts.qc_aerosol_optical_depth_filter5)==0;
keep = keep & mfr.vdata.aerosol_optical_depth_filter5>0 & mfr.vdata.aerosol_optical_depth_filter1<2;
keep = keep & mfr.vdata.airmass>=1 & mfr.vdata.airmass<=6;sum(keep)
mfr = anc_sift(mfr, keep);
mfr_ = mfr;

for m = 2:length(mfr_files)
   mfr = anc_load(mfr_files{m});
   keep = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1, mfr.vatts.qc_aerosol_optical_depth_filter1)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2, mfr.vatts.qc_aerosol_optical_depth_filter2)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3, mfr.vatts.qc_aerosol_optical_depth_filter3)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4, mfr.vatts.qc_aerosol_optical_depth_filter4)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5, mfr.vatts.qc_aerosol_optical_depth_filter5)==0;
   keep = keep & mfr.vdata.aerosol_optical_depth_filter5>0 & mfr.vdata.aerosol_optical_depth_filter1<2;
   keep = keep & mfr.vdata.airmass>=1 & mfr.vdata.airmass<=6;disp(sum(keep))
   mfr = anc_sift(mfr, keep);
   mfr_ = anc_cat(mfr_, mfr);
   disp(length(mfr_.time))

end

end