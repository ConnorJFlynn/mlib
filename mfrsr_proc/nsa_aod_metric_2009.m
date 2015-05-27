% NSA AOD metric

% try out improved screen based on low direct normal signal plus high
% uniformity

% so load an mfrsr or nimfr file that we know has some bogus aods.
%%
in_nim = ['C:\case_studies\2009_metric\nsamfrsraod1michC1.c1',filesep];
out_nim = [in_nim,'T_screen',filesep];
if ~exist(out_nim,'dir')
   mkdir(out_nim);
end
nims = dir([in_nim,'*.cdf']);
for n = 1:length(nims)
%%
nimfr = ancload([in_nim,nims(n).name]); 
%%
nimfr.vars.direct_normal_transmittance_filter1 = nimfr.vars.direct_normal_narrowband_filter1;
nimfr.vars.direct_normal_transmittance_filter2 = nimfr.vars.direct_normal_narrowband_filter2;
nimfr.vars.direct_normal_transmittance_filter3 = nimfr.vars.direct_normal_narrowband_filter3;
nimfr.vars.direct_normal_transmittance_filter4 = nimfr.vars.direct_normal_narrowband_filter4;
nimfr.vars.direct_normal_transmittance_filter5 = nimfr.vars.direct_normal_narrowband_filter5;
nimfr.vars.qc_direct_normal_transmittance_filter1 = nimfr.vars.qc_direct_normal_narrowband_filter1;
nimfr.vars.qc_direct_normal_transmittance_filter2 = nimfr.vars.qc_direct_normal_narrowband_filter2;
nimfr.vars.qc_direct_normal_transmittance_filter3 = nimfr.vars.qc_direct_normal_narrowband_filter3;
nimfr.vars.qc_direct_normal_transmittance_filter4 = nimfr.vars.qc_direct_normal_narrowband_filter4;
nimfr.vars.qc_direct_normal_transmittance_filter5 = nimfr.vars.qc_direct_normal_narrowband_filter5;
nimfr.vars.direct_normal_transmittance_filter1.atts.long_name.data = 'Direct Normal Transmittance, filter 1';
nimfr.vars.direct_normal_transmittance_filter2.atts.long_name.data = 'Direct Normal Transmittance, filter 2';
nimfr.vars.direct_normal_transmittance_filter3.atts.long_name.data = 'Direct Normal Transmittance, filter 3';
nimfr.vars.direct_normal_transmittance_filter4.atts.long_name.data = 'Direct Normal Transmittance, filter 4';
nimfr.vars.direct_normal_transmittance_filter5.atts.long_name.data = 'Direct Normal Transmittance, filter 5';
nimfr.vars.direct_normal_transmittance_filter1.atts.units.data = 'unitless';
nimfr.vars.direct_normal_transmittance_filter2.atts.units.data = 'unitless';
nimfr.vars.direct_normal_transmittance_filter3.atts.units.data = 'unitless';
nimfr.vars.direct_normal_transmittance_filter4.atts.units.data = 'unitless';
nimfr.vars.direct_normal_transmittance_filter5.atts.units.data = 'unitless';
nimfr.vars.qc_direct_normal_transmittance_filter1.atts.long_name.data = 'Quality check results on field: Direct Normal Transmittance, filter 1';
nimfr.vars.qc_direct_normal_transmittance_filter2.atts.long_name.data = 'Quality check results on field: Direct Normal Transmittance, filter 2';
nimfr.vars.qc_direct_normal_transmittance_filter3.atts.long_name.data = 'Quality check results on field: Direct Normal Transmittance, filter 3';
nimfr.vars.qc_direct_normal_transmittance_filter4.atts.long_name.data = 'Quality check results on field: Direct Normal Transmittance, filter 4';
nimfr.vars.qc_direct_normal_transmittance_filter5.atts.long_name.data = 'Quality check results on field: Direct Normal Transmittance, filter 5';
nimfr.vars.direct_normal_transmittance_filter1.atts.valid_max.data = '1.0f';
nimfr.vars.direct_normal_transmittance_filter2.atts.valid_max.data = '1.0f';
nimfr.vars.direct_normal_transmittance_filter3.atts.valid_max.data = '1.0f';
nimfr.vars.direct_normal_transmittance_filter4.atts.valid_max.data = '1.0f';
nimfr.vars.direct_normal_transmittance_filter5.atts.valid_max.data = '1.0f';



T_filter1 = nimfr.vars.direct_normal_narrowband_filter1.data ./ sscanf(nimfr.atts.filter1_TOA_direct_normal.data,'%f');
T_filter2 = nimfr.vars.direct_normal_narrowband_filter2.data ./ sscanf(nimfr.atts.filter2_TOA_direct_normal.data,'%f');
T_filter3 = nimfr.vars.direct_normal_narrowband_filter3.data ./ sscanf(nimfr.atts.filter3_TOA_direct_normal.data,'%f');
T_filter4 = nimfr.vars.direct_normal_narrowband_filter4.data ./ sscanf(nimfr.atts.filter4_TOA_direct_normal.data,'%f');
T_filter5 = nimfr.vars.direct_normal_narrowband_filter5.data ./ sscanf(nimfr.atts.filter5_TOA_direct_normal.data,'%f');

nimfr.vars.direct_normal_transmittance_filter1.data = T_filter1;
nimfr.vars.direct_normal_transmittance_filter2.data = T_filter2;
nimfr.vars.direct_normal_transmittance_filter3.data = T_filter3;
nimfr.vars.direct_normal_transmittance_filter4.data = T_filter4;
nimfr.vars.direct_normal_transmittance_filter5.data = T_filter5;

nimfr.vars.T_variability = nimfr.vars.variability_flag;
nimfr.vars.T_variability.atts.long_name.data = 'variability of direct normal transmittance filter 5';
%%

 baseline = 1;
 [tmp, T_eps] = eps_screen(nimfr.time,T_filter5,5,1e-5,baseline);
 nimfr.vars.T_variability.data = T_eps;
% figure; semilogy([1:length(nimfr.time)], T_eps,'k.');
% title(['base line:',num2str(baseline)])
% xlim(xl)
%%
% T_eps = nimfr.vars.variability_flag.data;
qc_test.description = '(T_filter5 < 1e-3 & T_variability < 1e-4)|(T_variability<5e-8): (overcast)';
qc_test.assessment = 'bad';
qc_test.bit = 12;
qc_test.value = ((T_filter5 < 5e-3) &(T_eps<1e-4))|(T_eps<5e-8);
[nimfr.vars.qc_aerosol_optical_depth_filter1,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter1,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter2,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter2,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter3,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter3,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter4,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter4,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter5,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter5,qc_test);

qc_test.description = 'variability=0';
qc_test.assessment = 'bad';
qc_test.bit = 13;
qc_test.value = (nimfr.vars.variability_flag.data==0);
[nimfr.vars.qc_aerosol_optical_depth_filter1,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter1,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter2,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter2,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter3,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter3,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter4,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter4,qc_test);
[nimfr.vars.qc_aerosol_optical_depth_filter5,bit] = vqc_addtest(nimfr.vars.qc_aerosol_optical_depth_filter5,qc_test);


nimfr = anccheck(nimfr);
[ptmp,out_name,ext] = fileparts(nimfr.fname);
nimfr.fname = [out_nim,out_name,ext];
nimfr.clobber = true;
nimfr.quiet = true;
disp(['saving ',out_name])
ancsave(nimfr);
end
%
