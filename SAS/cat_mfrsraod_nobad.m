function mfr = cat_mfrsraod_nobad;
% cat_filt_sasaod
% outputs only vis wl values from MFRSR and Cimel>=380

mfr_files = getfullname('*mfrsr*aod*.nc;*mfrsr*aod*.cdf');
mfr = anc_load(mfr_files{1});
nobad = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1 , mfr.vatts.qc_aerosol_optical_depth_filter1)<2;
nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2 , mfr.vatts.qc_aerosol_optical_depth_filter2)<2;
nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3 , mfr.vatts.qc_aerosol_optical_depth_filter3)<2;
nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4 , mfr.vatts.qc_aerosol_optical_depth_filter4)<2;
nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5 , mfr.vatts.qc_aerosol_optical_depth_filter5)<2;
mfr_ = anc_sift(mfr, nobad);
for m = 2:length(mfr_files)
   mfr = anc_load(mfr_files{m});
   nobad = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1 , mfr.vatts.qc_aerosol_optical_depth_filter1)<2;
   nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2 , mfr.vatts.qc_aerosol_optical_depth_filter2)<2;
   nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3 , mfr.vatts.qc_aerosol_optical_depth_filter3)<2;
   nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4 , mfr.vatts.qc_aerosol_optical_depth_filter4)<2;
   nobad = nobad & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5 , mfr.vatts.qc_aerosol_optical_depth_filter5)<2;
   mfr_ = anc_cat(mfr_, mfr);
   disp(['file: ',num2str(length(mfr_files)-m)])
end

mfr = mfr_; clear mfr_
save(['D:\aodfit_be\pvc\pvcmfrsraodM1.c1.filt.mat'],'-struct','mfr')
end