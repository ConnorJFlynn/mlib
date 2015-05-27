function [anc_mplps] = mplps_bat2anc(mat_dir);
% Processes mplpol averaged mat files into AM/PM files and images
% persistent polavg;
status = 0;
if ~exist('mat_dir','var')||~exist(mat_dir,'dir')
   [mat_dir] = getdir([],'mpl_data','Select directory containing processed/averaged MPLpol mat files');
end
% mpl_inarg.Nsamples = 10;
mpl_inarg.fstem = 'ISDAC_mplpol_1flynn.';
% mpl_inarg.fstem = 'fastpol_3flynn.';
% out_dir = [in_dir, 'out',filesep];
png_dir = [mat_dir, '..',filesep,'png',filesep];
cdfout_dir = [mat_dir, '..',filesep,'cdf_out',filesep];
if ~exist(png_dir, 'dir')
   mkdir(png_dir);
end
if ~exist(cdfout_dir, 'dir')
   mkdir(cdfout_dir);
end
mat_files = dir([mat_dir,'*.mat']);
for m = length(mat_files):-1:1
    polavg = loadinto([mat_dir mat_files(m).name]);
    
               disp(['Starting ingest for ',num2str(m), ' : ',mat_files(m).name]);
               anc_mplps = mplps_mat2anc(polavg);
               anc_mplps.fname = [cdfout_dir,anc_mplps.fname];
               anc_mplps.clobber = true;
               anc_mplps.quiet = true;
               ancsave(anc_mplps);
               disp(['Finished ingest for ',num2str(m), ' : ',mat_files(m).name]);
end
