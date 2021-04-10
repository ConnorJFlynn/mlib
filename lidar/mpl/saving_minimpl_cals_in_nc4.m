% This script contains scraps that save a modified minimpl netcdf4
% calibration file as a *.mat file and also as a .nc file but to save the
% .nc we need to strip fields that use "string" type data.

% Cloud-blocked cases, excluding 7/20 as outlier

aps_copol_cld = [ap_719.vdata.ap_copol,ap_721.vdata.ap_copol,ap_722.vdata.ap_copol,ap_726.vdata.ap_copol,ap_811.vdata.ap_copol,ap_823.vdata.ap_copol];
aps_crosspol_cld = [ap_719.vdata.ap_crosspol,ap_721.vdata.ap_crosspol,ap_722.vdata.ap_crosspol,ap_726.vdata.ap_crosspol,ap_811.vdata.ap_crosspol,ap_823.vdata.ap_crosspol];
ap_cjf.vdata.ap_copol = gmean(aps_copol_cld')';
ap_cjf.vdata.ap_crosspol = gmean(aps_crosspol_cld')';

save(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cloudblocked.mat'],'-struct','ap_cjf')

% Lid-on cases
ap_801 = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cjf.20190801.mat']);
ap_805 = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cjf.20190805.mat']);
ap_806 = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cjf.20190806.mat']);
ap_807 = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cjf.20190807.mat']);
ap_808 = load(['E:\mmpl\ER2019\calibration_uc\calibration_uc.cjf.20190808.mat']);

aps_copol_lid = [ap_801.vdata.ap_copol,ap_805.vdata.ap_copol,ap_806.vdata.ap_copol,ap_807.vdata.ap_copol,ap_808.vdata.ap_copol];
aps_crosspol_lid = [ap_801.vdata.ap_crosspol,ap_805.vdata.ap_crosspol,ap_806.vdata.ap_crosspol,ap_807.vdata.ap_crosspol,ap_808.vdata.ap_crosspol];
ap_cjf.vdata.ap_copol = gmean(aps_copol_lid')';
ap_cjf.vdata.ap_crosspol = gmean(aps_crosspol_lid')';

full_ol = 10.^interp1(log10(MPL_cals.vdata.ol_range(2:end)), log10(MPL_cals.vdata.ol_overlap(2:end)), log10(MPL_cals.vdata.ap_range),'linear','extrap');


save(['E:\mmpl\ER2019\calibration_uc\calibration_uc.lid_on_ray_full_ol.mat'],'-struct','ap_cjf')
ap_cjf.fname = 'E:\mmpl\ER2019\calibration_uc\calibration_uc.lid_on_ray_ol.nc';
ap_cjf.vdata.ol_range = ap_cjf.vdata.ap_range;
ap_cjf.vdata.ol_overlap = full_ol;
ap_cjf.ncdef.dims.ol_range.length = ap_cjf.ncdef.dims.ap_range.length;
ap_cjf.clobber = true;

ap_cjf.ncdef.dims.range
ap_cjf.ncdef.dims = rmfield(ap_cjf.ncdef.dims,'range');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'ap_header'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'ap_header');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'dt_number_coeff'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'dt_number_coeff');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'dt_coeff_degree'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'dt_coeff_degree');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'ap_number_bins'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'ap_number_bins');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'ol_number_bins'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'ol_number_bins');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'ap_file_version'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'ap_file_version');
ap_cjf.vdata = rmfield(ap_cjf.vdata,'ap_number_channels'); ap_cjf.ncdef.vars = rmfield(ap_cjf.ncdef.vars, 'ap_number_channels');
anc_check(ap_cjf)
anc_save(ap_cjf, 'E:\mmpl\ER2019\calibration_uc\calibration_uc.lid_on_ray_full_ol.nc')
figure; plot(ap_801.vdata.ap_range, gmean(aps_copol_cld')','-',ap_801.vdata.ap_range, gmean(aps_copol_lid')','r-',...
    ap_801.vdata.ap_range, gmean(aps_crosspol_cld')','-', ap_801.vdata.ap_range, gmean(aps_crosspol_lid')','k-'); logy; logx;