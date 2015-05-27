% NSA AOD metric, part 2

% load nimfr files (with new T_screen) and screen out bad values.

%%
in_nim = ['C:\case_studies\2009_metric\nsamfrsraod1michC1.c1\T_screen',filesep];
out_nim = [in_nim,'screened',filesep];
if ~exist(out_nim,'dir')
   mkdir(out_nim);
end
nims = dir([in_nim,'*.cdf']);
for n = 1:length(nims)
%%
nimfr = ancload([in_nim,nims(n).name]); 
keep = qc_impacts(nimfr.vars.qc_aerosol_optical_depth_filter2)~=2 & qc_impacts(nimfr.vars.qc_aerosol_optical_depth_filter5)~=2;
nimfr = ancsift(nimfr,nimfr.dims.time, keep);
nimfr = anccheck(nimfr);
[ptmp,out_name,ext] = fileparts(nimfr.fname);
nimfr.fname = [out_nim,out_name,ext];
nimfr.clobber = true;
nimfr.quiet = true;
disp(['Saving ',out_name]);
ancsave(nimfr);
end