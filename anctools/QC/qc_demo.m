%%
plots_ppt
%%
% QC demo
anc = ancload(['C:\case_studies\mfrsr_aod_qc_help\c1\from_archive\nimfrC1\sgpnimfraod1michC1.c1.20090308.000000.cdf']);

% anc = plot_qcs_ii(anc);
%
anc.vars.qc_aerosol_optical_depth_filter2 = vqc_delete_test(anc.vars.qc_aerosol_optical_depth_filter2,11);
anc.vars.qc_aerosol_optical_depth_filter2 = vqc_delete_test(anc.vars.qc_aerosol_optical_depth_filter2,10);
anc.vars.qc_aerosol_optical_depth_filter2 = vqc_delete_test(anc.vars.qc_aerosol_optical_depth_filter2,9);
anc.vars.qc_aerosol_optical_depth_filter2 = vqc_delete_test(anc.vars.qc_aerosol_optical_depth_filter2,8);
anc.vars.qc_aerosol_optical_depth_filter2 = vqc_delete_test(anc.vars.qc_aerosol_optical_depth_filter2,5);
anc.vars.qc_aerosol_optical_depth_filter2 = vqc_delete_test(anc.vars.qc_aerosol_optical_depth_filter2,1);
anc = plot_qcs_ii(anc);
%%
