barn = read_nimbarncor1;
mfr0 = ancload;
%%
mfr = mfr0;
fields = fieldnames(mfr.vars);

for f = length(fields):-1:1
   if ~isempty(findstr(fields{f},'qc_'))||~isempty(findstr(fields{f},'diffuse'))||~isempty(findstr(fields{f},'hemisp'))||~isempty(findstr(fields{f},'direct'))
      mfr.vars = rmfield(mfr.vars, fields{f});
      fields(f) = [];
   end
   if ~isempty(findstr(fields{f},'temp'))||~isempty(findstr(fields{f},'logger'))||~isempty(findstr(fields{f},'sn_filt'))||~isempty(findstr(fields{f},'we_filt'))
      mfr.vars = rmfield(mfr.vars, fields{f});
            fields(f) = [];

   end
   if ~isempty(findstr(fields{f},'broadband'))||~isempty(findstr(fields{f},'bench'))||~isempty(findstr(fields{f},'offset'))
      mfr.vars = rmfield(mfr.vars, fields{f});
            fields(f) = [];

   end
   if ~isempty(findstr(fields{f},'computed'))||~isempty(findstr(fields{f},'TOA_'))||~isempty(findstr(fields{f},'normalized'))
      mfr.vars = rmfield(mfr.vars, fields{f});
            fields(f) = [];

   end
   if ~isempty(findstr(fields{f},'total_'))||~isempty(findstr(fields{f},'Rayleigh'))||~isempty(findstr(fields{f},'nominal'))
      mfr.vars = rmfield(mfr.vars, fields{f});
            fields(f) = [];

   end
   if ~isempty(findstr(fields{f},'wavelength'))||~isempty(findstr(fields{f},'Io_'))||~isempty(findstr(fields{f},'variability'))
      mfr.vars = rmfield(mfr.vars, fields{f});
            fields(f) = [];
   end
   if ~isempty(findstr(fields{f},'elevation'))||~isempty(findstr(fields{f},'airmass'))||~isempty(findstr(fields{f},'azimuth'))||~isempty(findstr(fields{f},'Ozone'))
      mfr.vars = rmfield(mfr.vars, fields{f});
                  fields(f) = [];
   end
   %%
if ~isempty(findstr(fields{f},'aerosol_optical_depth'))
   filter = fields{f};
   if isfield(mfr.vars.(fields{f}).atts,['Gueymard_TOA_filter',filter(end)])
      mfr.vars.(fields{f}).atts = rmfield(mfr.vars.(fields{f}).atts,['Gueymard_TOA_filter',filter(end)]);
   end
   if isfield(mfr.vars.(fields{f}).atts,'explanation_of_aerosol_optical_depth');
      mfr.vars.(fields{f}).atts = rmfield(mfr.vars.(fields{f}).atts,'explanation_of_aerosol_optical_depth');
   end
end

end
%
mfr.vars = rmfield(mfr.vars, 'solar_zenith_angle');
mfr.vars = rmfield(mfr.vars, 'surface_pressure');
mfr.vars = rmfield(mfr.vars, 'sun_to_earth_distance');
mfr.vars.aod_415nm = mfr.vars.aerosol_optical_depth_filter1;
mfr.vars.aod_500nm = mfr.vars.aerosol_optical_depth_filter2;
mfr.vars.aod_615nm = mfr.vars.aerosol_optical_depth_filter3;
mfr.vars.aod_673nm = mfr.vars.aerosol_optical_depth_filter4;
mfr.vars.aod_870nm = mfr.vars.aerosol_optical_depth_filter5;
mfr.vars = rmfield(mfr.vars, 'aerosol_optical_depth_filter1');
mfr.vars = rmfield(mfr.vars, 'aerosol_optical_depth_filter2');
mfr.vars = rmfield(mfr.vars, 'aerosol_optical_depth_filter3');
mfr.vars = rmfield(mfr.vars, 'aerosol_optical_depth_filter4');
mfr.vars = rmfield(mfr.vars, 'aerosol_optical_depth_filter5');

mfr.vars.forward_scattering_correction_415nm = mfr.vars.aod_415nm;
mfr.vars.forward_scattering_correction_500nm = mfr.vars.aod_500nm;
mfr.vars.forward_scattering_correction_615nm = mfr.vars.aod_615nm;
mfr.vars.forward_scattering_correction_673nm = mfr.vars.aod_673nm;
mfr.vars.forward_scattering_correction_870nm = mfr.vars.aod_870nm;

mfr.dims = rmfield(mfr.dims,'bench_angle');
mfr.dims = rmfield(mfr.dims, 'wavelength');

fields = fieldnames(mfr.vars);
%
mfr.time = barn.time';
mfr.vars.cosine_solar_zenith_angle.data = barn.csza';
mfr.vars.aod_415nm.data = barn.aod_415';
mfr.vars.aod_415nm.atts.long_name.data = 'aerosol optical depth 415 nm';
mfr.vars.aod_415nm.atts.comment = mfr.vars.aod_415nm.atts.long_name;
mfr.vars.aod_415nm.atts.comment.data = 'Extrapolated from aod_500nm with angstrom exponent';
mfr.vars.aod_500nm.data = barn.aod_500';
mfr.vars.aod_500nm.atts.long_name.data = 'aerosol optical depth 500 nm';
mfr.vars.aod_615nm.data = barn.aod_615';
mfr.vars.aod_615nm.atts.long_name.data = 'aerosol optical depth 615 nm';
mfr.vars.aod_673nm.data = barn.aod_673';
mfr.vars.aod_673nm.atts.long_name.data = 'aerosol optical depth 673 nm';
mfr.vars.aod_870nm.data = barn.aod_870';
mfr.vars.aod_870nm.atts.long_name.data = 'aerosol optical depth 870 nm';
mfr.vars.angstrom_exponent.data = barn.ang';
mfr.vars.angstrom_exponent.atts = rmfield(mfr.vars.angstrom_exponent.atts,'comment2');

mfr.vars.day_of_year_UTC.data = barn.doy_utc';
mfr.vars.day_of_year_UTC.datatype = 5;
mfr.vars.day_of_year_UTC.dims = mfr.vars.aod_415nm.dims;
mfr.vars.day_of_year_UTC.atts = mfr.vars.aod_415nm.atts;
mfr.vars.day_of_year_UTC.atts.long_name.data = 'Day of year, UTC (Jan 1 = 1)';
mfr.vars.day_of_year_LST = mfr.vars.day_of_year_UTC;
mfr.vars.day_of_year_LST.data = barn.doy_lst';
mfr.vars.day_of_year_LST.atts.long_name.data = 'Day of year, LST (Jan 1 = 1)';

mfr.vars.forward_scattering_correction_415nm.data = barn.cor_415';
mfr.vars.forward_scattering_correction_415nm.atts.long_name.data = 'Forward scattering correction for 415 nm';
mfr.vars.forward_scattering_correction_500nm.data = barn.cor_500';
mfr.vars.forward_scattering_correction_500nm.atts.long_name.data = 'Forward scattering correction for 500 nm';
mfr.vars.forward_scattering_correction_615nm.data = barn.cor_615';
mfr.vars.forward_scattering_correction_615nm.atts.long_name.data = 'Forward scattering correction for 615 nm';
mfr.vars.forward_scattering_correction_673nm.data = barn.cor_673';
mfr.vars.forward_scattering_correction_673nm.atts.long_name.data = 'Forward scattering correction for 673 nm';
mfr.vars.forward_scattering_correction_870nm.data = barn.cor_870';
mfr.vars.forward_scattering_correction_870nm.atts.long_name.data = 'Forward scattering correction for 870 nm';

mfr.atts = rmfield(mfr.atts,'Command_Line');
mfr.atts = rmfield(mfr.atts,'comment');
mfr.atts = rmfield(mfr.atts,'averaging_int');
mfr.atts = rmfield(mfr.atts,'BW_Version');
mfr.atts = rmfield(mfr.atts,'total_optical_depth_computation');
mfr.atts.aerosol_optical_depth_computation.data = 'aod = forward_scattering_correction * (total_OD - Rayleigh_OD - Ozone_column_amount*Ozone_absorption_coef)';
mfr.atts = rmfield(mfr.atts,'hemispheric_computation');
mfr.atts = rmfield(mfr.atts,'diffuse_hemispheric_computation');
mfr.atts = rmfield(mfr.atts,'direct_normal_computation');
mfr.atts = rmfield(mfr.atts,'ingest_software');
mfr.atts = rmfield(mfr.atts,'Filter_information');
mfr.atts = rmfield(mfr.atts,'shadowband_timing');
mfr.atts = rmfield(mfr.atts,'input_source');
mfr.atts = rmfield(mfr.atts,'cosine_correction_source');
mfr.atts = rmfield(mfr.atts,'diffuse_correction_source');
mfr.atts = rmfield(mfr.atts,'filter_trace_source');
mfr.atts = rmfield(mfr.atts,'nominal_calibration_source');
mfr.atts = rmfield(mfr.atts,'offset_correction_source');

mfr.atts = rmfield(mfr.atts,'logger_software_version');
mfr.atts = rmfield(mfr.atts,'serial_number');
mfr.atts = rmfield(mfr.atts,'history');
mfr.atts = rmfield(mfr.atts,'qc_standards_version');
mfr.atts = rmfield(mfr.atts,'Langley_data_used');
mfr.atts = rmfield(mfr.atts,'pressure_fraction_for_Rayleigh_calculation');
mfr.atts = rmfield(mfr.atts,'Forgan_StartDate');
mfr.atts = rmfield(mfr.atts,'Forgan_EndDate');
mfr.atts = rmfield(mfr.atts,'Input_data_used');
mfr.atts = rmfield(mfr.atts,'Input_Datastream_Descriptions');
mfr.atts = rmfield(mfr.atts,'Input_Datastreams_Num');
mfr.atts = rmfield(mfr.atts,'Input_Datastreams');
mfr.atts.Date.data = datestr(now, 'ddd mmm dd HH:MM:SS yyyy');
mfr.atts.Version.data = 'Barnard-Flynn v1.0';

% out_dir = ['C:\case_studies\dust\MFRSR_forward_scat_corrs\nim_out_cdf\'];
out_dir = ['C:\case_studies\dust\aod_metric_stuff\MFRSR_forward_scat_corrs\aod_metric\'];
out_name = ['niamey_corrected_aod.cdf'];
%
mfr.fname = [out_dir, out_name];
mfr.dims.time.length = length(mfr.time)
mfr = timesync(mfr);
mfr = anccheck(mfr);
mfr.clobber = true;
ancsave(mfr)

