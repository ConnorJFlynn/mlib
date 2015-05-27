function [status] = isdac_ingest(mat_dir);
% Processes mplpol_avg data into netcdf files
status = 0;
if ~exist('mat_dir','var')||~exist(mat_dir,'dir')
   [mat_dir] = getdir([],'mpl_data','Select directory containing MPL raw data');
end
% Okay, so we need to "get" the dod file and read it in.

% Then get dirlisting of MPL mat files.
% Load each mat file
% Ingest by copying relevant fields to copy of DOD.
% Copy dod file from original location and name to output location with new
% name.
% Use ancwrite to populate that file.

dod_dir = 'C:\case_studies\ISDAC\MPL\MPL_corrs\';
dod_fname = 'nsamplpsC1.a1.20031207.000000.dod.cdf';
dod_fname = 'nsamplps2flynnC1.c1.20080301_000032.nc';
dod_fname = 'nsamplps2flynnC1.c1.20080301_000032.0.nc';
cdf_dir = [dod_dir, '..\cdf\'];

dod_tmp = ancload([dod_dir, dod_fname]);
% tmp_out = ancstaticdod([dod_dir, dod_fname]);
mats = dir([mat_dir, '*.mat']);
for m = 1:length(mats)
   clear mat dod
   mat = loadinto([mat_dir, mats(m).name]);
   out_stem = 'nsamplps2flynnC1.c1.';
   dstr = datestr(mat.time(1),'yyyymmdd_HHMMSS.');
   copyfile([dod_dir,dod_fname],[cdf_dir,out_stem,dstr,'nc']);
   dod = ingest_mat_(dod_tmp, mat);
   dod.fname = [cdf_dir,out_stem,dstr,'nc'];
   dod = timesync(dod);
   dod = anccheck(dod);
   status = ancwrite(dod);
   %construct output name
   %Copy dod_fname to the output location.
   %write dod to this new output location.
end
return

function dod = ingest_mat_(dod, mat);
%%
dod.time = mat.time;
dod.vars.range.data = single(mat.range);
dod.dims.range.length = length(dod.vars.range.data);
dod.vars.julian_day.data = serial2doy(dod.time);
% dod.vars = rmfield(dod.vars,'copol_afterpulse');
% dod.vars = rmfield(dod.vars,'depol_afterpulse');
% dod.vars = rmfield(dod.vars,'deadtime_corrected');
dod.vars.energyMonitor.data=mat.cop_energy_monitor;
% dod.vars = rmfield(dod.vars,'copol_samples');
% dod.vars = rmfield(dod.vars,'depol_samples');
% dod.vars = rmfield(dod.vars,'depol_zerobin');
% dod.vars = rmfield(dod.vars,'copol_zerobin');
dod.vars.depol_bg.data=mat.crs_bg;
dod.vars.copol_bg.data=mat.cop_bg;
dod.vars.depolarization.data=mat.ldr;
% dod.vars = rmfield(dod.vars,'copol_cts');
% dod.vars = rmfield(dod.vars,'copol_std');
dod.vars.copol_noise.data=mat.cop_noise;
dod.vars.copol_prof.data=mat.cop;
% dod.vars = rmfield(dod.vars,'depol_cts');
% dod.vars = rmfield(dod.vars,'depol_std');
dod.vars.depol_noise.data=mat.crs_noise;
dod.vars.depol_prof.data=mat.crs;
% dod.vars = rmfield(dod.vars,'total_cts');
dod.vars.total_prof.data=mat.attn_bscat;
% dod.vars = rmfield(dod.vars,'total_noise');
% dod.vars = rmfield(dod.vars,'total_std');
% dod.vars = rmfield(dod.vars,'sample_stability');

dod.clobber = true;


%%

return