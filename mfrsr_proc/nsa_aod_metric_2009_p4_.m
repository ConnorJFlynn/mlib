   keep_fields =  {'base_time'
    'time_offset'
    'time'
    'be_aod_500'
    'be_aod_355'
    'be_angst_exp'
    'mean_aod_nimfr_filter1'
    'sdev_aod_nimfr_filter1'
    'mean_aod_nimfr_filter2'
    'sdev_aod_nimfr_filter2'
    'mean_aod_nimfr_filter3'
    'sdev_aod_nimfr_filter3'
    'mean_aod_nimfr_filter4'
    'sdev_aod_nimfr_filter4'
    'mean_aod_nimfr_filter5'
    'sdev_aod_nimfr_filter5'
    'mean_angst_exponent_nimfr'
    'interpolated_angst_exponent_nimfr'
    'mean_aod_mfrsr_filter1'
    'sdev_aod_mfrsr_filter1'
    'mean_aod_mfrsr_filter2'
    'sdev_aod_mfrsr_filter2'
    'mean_aod_mfrsr_filter3'
    'sdev_aod_mfrsr_filter3'
    'mean_aod_mfrsr_filter4'
    'sdev_aod_mfrsr_filter4'
    'mean_aod_mfrsr_filter5'
    'sdev_aod_mfrsr_filter5'
    'mean_angst_exponent_mfrsr'
    'interpolated_angst_exponent_mfrsr'
    'angst_exponent_mfrsr_filter2'
    'aod_source_flag'
    'predicted_aod'}
 %%
 abe_pname = ['C:\case_studies\2009_metric\nsaaerosolbe1turnC1.c1\'];
 abes = dir([abe_pname,'*.cdf']);
 for f = 1:length(abes)
    abe = ancload([abe_pname,abes(f).name]);
 
    subabe.atts = abe.atts;
    subabe.recdim = abe.recdim;
    subabe.dims = abe.dims;
    subabe.time = abe.time;

 for sf = 1:length(keep_fields)
    subabe.vars.(keep_fields{sf}) = abe.vars.(keep_fields{sf});
 end    
 [pname, fname, ext] = fileparts(abe.fname);
 pname = [pname, filesep,'abe_sub',filesep];
 subabe.fname = [pname,fname,ext];
 subabe = anccheck(subabe);
 subabe.clobber = true;
 subabe.quiet = true;
 disp(['Saving ', subabe.fname]);
 ancsave(subabe);
 end