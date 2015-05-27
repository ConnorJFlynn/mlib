function mfrsr = apply_mfrsr_corrs(mfrsr,corrs)
%mfrsr = apply_mfrsr_corrs(mfrsr,corrs)

if ~exist('mfrsr','var')
    mfrsr = ancload;
    [pname,fstem] = fileparts(mfrsr.fname);
    arg.head_id = deblank(char(mfrsr.atts.head_id.data));
end;
if ~exist('corrs','var')
   corrs = get_head_corrs(arg);
end

% Get proper offset, gain, and cosine correction for head
%mfrsr = get_head_corrs(mfrsr)
% pname = 'C:\case_studies\aot_comparisons\mfr_cal\cal_files_from_Annette_to_Kiedron\';
% fname = 'SolarInfo.sgpmfrsrC1.20030501.0';
% solarfile = [pname, fname];

%[spas.zen_angle, spas.az_angle, spas.r_au, spas.hour_angle, spas.inc_angle, spas.sunrise, spas.suntransit, spas.sunset] = spa(mfrsr.vars.lat.data, mfrsr.vars.lon.data, mfrsr.vars.alt.data, mfrsr.time);
[sun.zen_angle, sun.az_angle, sun.r_au, sun.hour_angle, sun.declination, sun.el, sun.airmass] = sunae(mfrsr.vars.lat.data, mfrsr.vars.lon.data, mfrsr.time);
mfrsr.vars.zen_angle.atts.long_name.data = 'solar zenith angle';
mfrsr.vars.zen_angle.atts.units.data = 'degrees';
mfrsr.vars.zen_angle.data = sun.zen_angle;

mfrsr.vars.az_angle.data = sun.az_angle;
mfrsr.vars.az_angle.atts.long_name.data = 'solar azimuth angle';
mfrsr.vars.az_angle.atts.units.data = 'degrees';
mfrsr.vars.cos_zen.atts.long_name.data = 'cosine solar zenith angle';
mfrsr.vars.cos_zen.atts.units.data = 'unitless';
mfrsr.vars.cos_zen.data = cos(pi*sun.zen_angle/180);
mfrsr.vars.airmass.atts.long_name.data = 'airmass';
mfrsr.vars.airmass.atts.units.data = 'unitless';
mfrsr.vars.airmass.data = 1./cos(pi*sun.zen_angle/180);
sundown = find(sun.zen_angle>=90);
mfrsr.vars.airmass.data(sundown) = NaN;
mfrsr.vars.r_au.atts.long_name.data = 'earth-sun distance';
mfrsr.vars.r_au.atts.units.data = 'Astronomical Units';
mfrsr.vars.r_au.data = sun.r_au;

ch.time = mfrsr.time;
ch.lat = mfrsr.vars.lat.data;
ch.zen_angle = mfrsr.vars.zen_angle.data;
ch.az_angle = mfrsr.vars.az_angle.data;
ch.sundown = sundown;

%for broadband
ch.th = mfrsr.vars.hemisp_broadband.data;
if isfield(mfrsr.vars, 'direct_horizontal_broadband')
   ch.dirhor = mfrsr.vars.direct_horizontal_broadband.data;
 mfrsr.vars.direct_normal_broadband.data = ch.dirhor ./ cos(ch.zen_angle*pi/180);
%    mfrsr.vars.dirhor_broadband = mfrsr.vars.direct_horizontal_broadband;
%    mfrsr.vars.dirnorm_broadband = mfrsr.vars.direct_horizontal_broadband;
%    mfrsr.vars.dirnorm_broadband.atts.long_name.data = 'direct-normal broadband irradiance';
%    mfrsr.vars.direct_horizontal_broadband.keep = false;
elseif isfield(mfrsr.vars, 'direct_normal_broadband')
%    ch.dirnorm = mfrsr.vars.direct_normal_broadband.data;
   ch.dirhor = mfrsr.vars.direct_normal_broadband.data .* cos(ch.zen_angle*pi/180);
   mfrsr.vars.direct_horizontal_broadband.data = ch.dirhor;
%    mfrsr.vars.dirnorm_broadband = mfrsr.vars.direct_normal_broadband;
%    mfrsr.vars.dirhor_broadband = mfrsr.vars.direct_normal_broadband;
%    mfrsr.vars.dirhor_broadband.atts.long_name.data = 'direct-horizontal broadband irradiance';
%    mfrsr.vars.direct_normal_broadband.keep = false;
end
ch = corr_channel(ch, corrs(1));

% mfrsr.vars.th_broadband = mfrsr.vars.hemisp_broadband;
% mfrsr.vars.hemisp_broadband.keep = false;
% mfrsr.vars.dif_broadband = mfrsr.vars.diffuse_hemisp_broadband;
% mfrsr.vars.diffuse_hemisp_broadband.keep = false;

mfrsr.vars.th_broadband.data = ch.th;
mfrsr.vars.dif_broadband.data = ch.dif;
mfrsr.vars.cordirnorm_broadband.data = ch.cordirnorm;
mfrsr.vars.cordirhor_broadband.data = ch.cordirhor;
mfrsr.vars.cordif_broadband.data = ch.cordif;
mfrsr.vars.corth_broadband.data = ch.corth;
mfrsr.vars.dif2dirhor_broadband.data = ch.dif2dirhor;
mfrsr.vars.cosine_correction_broadband.data = ch.cos_corr;
mfrsr.vars.diffuse_correction_broadband.data = ch.diffuse_correction;
mfrsr.vars.diffuse_correction_broadband.dims = mfrsr.vars.base_time.dims;
mfrsr.vars.diff_corr_err_broadband.data = ch.dif_corr_min_error;
mfrsr.vars.diff_corr_err_broadband.dims = mfrsr.vars.base_time.dims;
%For narrowband filters
for i = 2:7
mfrsr.dims.(['filter_',num2str(i-1),'_wavelength']).length = length(corrs(i).trace.nm);   
mfrsr.vars.(['filter_',num2str(i-1),'_wavelength']).data = corrs(i).trace.nm;   
mfrsr.vars.(['filter_',num2str(i-1),'_wavelength']).atts.units.data = 'nm';
mfrsr.vars.(['filter_',num2str(i-1),'_wavelength']).dims = {['filter_',num2str(i-1),'_wavelength']};
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).dims = {['filter_',num2str(i-1),'_wavelength']};
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).data = corrs(i).trace.normed.T;
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.units.data = 'unitless';
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.long_name.data = ['filter_',num2str(i-1),' normalized transmission'];
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.nominal_wavelength.data = corrs(i).trace.nominal;
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.CWL.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.FWHM.data = corrs(i).trace.normed.FWHM;
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.toa_irradiance.data = corrs(i).trace.normed.esr_irradiance;
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.ray_OD.data = corrs(i).trace.normed.tod_ray;
mfrsr.vars.(['filter_',num2str(i-1),'_trace']).atts.OzoneAttnCoef.data = corrs(i).trace.normed.o3_coef;
   
ch.th = mfrsr.vars.(['hemisp_narrowband_filter',num2str(i-1)]).data;
ch.sundown = sundown;
if isfield(mfrsr.vars, ['direct_horizontal_narrowband_filter',num2str(i-1)])
   ch.dirhor = mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(i-1)]).data;
    mfrsr.vars.(['direct_normal_narrowband_filter',num2str(i-1)]).data ... 
       = ch.dirhor ./ cos(ch.zen_angle*pi/180);
%    ch.dirnorm= ch.dirhor ./ cos(ch.zen_angle*pi/180);
%    mfrsr.vars.(['dirhor_filter',num2str(i-1)]) = mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(i-1)]);
%    mfrsr.vars.(['dirnorm_filter',num2str(i-1)]) = mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(i-1)]);
%    mfrsr.vars.(['dirnorm_filter',num2str(i-1)]).atts.long_name.data = 'direct-normal broadband irradiance';
%    mfrsr.vars.(['dirhor_filter',num2str(i-1)]).keep = false;
elseif isfield(mfrsr.vars, ['direct_normal_narrowband_filter',num2str(i-1)])
%    ch.dirnorm = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(i-1)]).data;
   ch.dirhor = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(i-1)]).data .* cos(ch.zen_angle*pi/180);
      mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(i-1)]).data = ch.dirhor;
%    mfrsr.vars.(['dirnorm_filter',num2str(i-1)]) = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(i-1)]);
%    mfrsr.vars.(['dirhor_filter',num2str(i-1)]) = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(i-1)]);
%    mfrsr.vars.(['dirhor_filter',num2str(i-1)]).atts.long_name.data = 'direct-horizontal broadband irradiance';
%    mfrsr.vars.(['dirnorm_filter',num2str(i-1)]).keep = false;
end
ch = corr_channel(ch, corrs(i));
% mfrsr.vars.(['th_filter',num2str(i-1)]) = mfrsr.vars.(['hemisp_narrowband_filter',num2str(i-1)]);
% mfrsr.vars.(['dif_filter',num2str(i-1)]) = mfrsr.vars.(['diffuse_hemisp_narrowband_filter',num2str(i-1)]);
% mfrsr.vars.(['hemisp_narrowband_filter',num2str(i-1)]).keep = false;
% mfrsr.vars.(['diffuse_hemisp_narrowband_filter',num2str(i-1)]).keep = false;

mfrsr.vars.(['th_filter',num2str(i-1)]).data = ch.th;
mfrsr.vars.(['dif_filter',num2str(i-1)]).data = ch.dif;
mfrsr.vars.(['cordirnorm_filter',num2str(i-1)]).data = ch.cordirnorm;
mfrsr.vars.(['cordirhor_filter',num2str(i-1)]).data = ch.cordirhor;
mfrsr.vars.(['cordif_filter',num2str(i-1)]).data = ch.cordif;
mfrsr.vars.(['corth_filter',num2str(i-1)]).data = ch.corth;
mfrsr.vars.(['dif2dirhor_filter',num2str(i-1)]).data = ch.dif2dirhor;
mfrsr.vars.(['cosine_correction_filter',num2str(i-1)]).data = ch.cos_corr;
mfrsr.vars.(['diffuse_correction_filter',num2str(i-1)]).data = ch.diffuse_correction;
mfrsr.vars.(['diffuse_correction_filter',num2str(i-1)]).dims = mfrsr.vars.base_time.dims;
mfrsr.vars.(['diff_corr_err_filter',num2str(i-1)]).data = ch.dif_corr_min_error;
mfrsr.vars.(['diff_corr_err_filter',num2str(i-1)]).dims = mfrsr.vars.base_time.dims;

mfrsr.vars.(['th_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['dif_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['cordirnorm_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['cordirhor_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['cordif_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['corth_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;
mfrsr.vars.(['dif2dirhor_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs(i).trace.normed.cw;

end

mfrsr.dims.bench_angle.length = 181;
mfrsr.vars.bench_angle.data = [0:180];
mfrsr.dims.bench_angle.length = length([0:180]);
mfrsr.vars.bench_angle.dims = {'bench_angle'};
mfrsr.vars.bench_angle.atts.units.data = 'degrees';
mfrsr.vars.SN_response_broadband.data = corrs(1).cos_corrs.SN;
mfrsr.vars.WE_response_broadband.data = corrs(1).cos_corrs.WE;
mfrsr.vars.SN_response_broadband.dims = {'bench_angle'};
mfrsr.vars.WE_response_broadband.dims = {'bench_angle'};
mfrsr.vars.SN_response_filter1.data = corrs(2).cos_corrs.SN;
mfrsr.vars.WE_response_filter1.data = corrs(2).cos_corrs.WE;
mfrsr.vars.SN_response_filter1.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter1.dims = {'bench_angle'};
mfrsr.vars.SN_response_filter2.data = corrs(3).cos_corrs.SN;
mfrsr.vars.WE_response_filter2.data = corrs(3).cos_corrs.WE;
mfrsr.vars.SN_response_filter2.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter2.dims = {'bench_angle'};
mfrsr.vars.SN_response_filter3.data = corrs(4).cos_corrs.SN;
mfrsr.vars.WE_response_filter3.data = corrs(4).cos_corrs.WE;
mfrsr.vars.SN_response_filter3.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter3.dims = {'bench_angle'};
mfrsr.vars.SN_response_filter4.data = corrs(5).cos_corrs.SN;
mfrsr.vars.WE_response_filter4.data = corrs(5).cos_corrs.WE;
mfrsr.vars.SN_response_filter4.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter4.dims = {'bench_angle'};
mfrsr.vars.SN_response_filter5.data = corrs(6).cos_corrs.SN;
mfrsr.vars.WE_response_filter5.data = corrs(6).cos_corrs.WE;
mfrsr.vars.SN_response_filter5.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter5.dims = {'bench_angle'};
mfrsr.vars.SN_response_filter6.data = corrs(7).cos_corrs.SN;
mfrsr.vars.WE_response_filter6.data = corrs(7).cos_corrs.WE;
mfrsr.vars.SN_response_filter6.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter6.dims = {'bench_angle'};
mfrsr.vars.WE_response_filter6.atts.units.data = 'unitless';
mfrsr.vars.WE_response_filter5.atts.units.data = 'unitless';
mfrsr.vars.WE_response_filter4.atts.units.data = 'unitless';
mfrsr.vars.WE_response_filter3.atts.units.data = 'unitless';
mfrsr.vars.WE_response_filter2.atts.units.data = 'unitless';
mfrsr.vars.WE_response_filter1.atts.units.data = 'unitless';
mfrsr.vars.WE_response_broadband.atts.units.data = 'unitless';
mfrsr.vars.SN_response_filter6.atts.units.data = 'unitless';
mfrsr.vars.SN_response_filter5.atts.units.data = 'unitless';
mfrsr.vars.SN_response_filter4.atts.units.data = 'unitless';
mfrsr.vars.SN_response_filter3.atts.units.data = 'unitless';
mfrsr.vars.SN_response_filter2.atts.units.data = 'unitless';
mfrsr.vars.SN_response_filter1.atts.units.data = 'unitless';
mfrsr.vars.SN_response_broadband.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_broadband.atts.long_name.data = 'cosine correction for broadband channel';
mfrsr.vars.cosine_correction_broadband.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_filter1.atts.long_name.data = 'cosine correction for narrowband filter1';
mfrsr.vars.cosine_correction_filter1.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_filter2.atts.long_name.data = 'cosine correction for narrowband filter1';
mfrsr.vars.cosine_correction_filter2.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_filter3.atts.long_name.data = 'cosine correction for narrowband filter1';
mfrsr.vars.cosine_correction_filter3.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_filter4.atts.long_name.data = 'cosine correction for narrowband filter1';
mfrsr.vars.cosine_correction_filter4.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_filter5.atts.long_name.data = 'cosine correction for narrowband filter1';
mfrsr.vars.cosine_correction_filter5.atts.units.data = 'unitless';
mfrsr.vars.cosine_correction_filter6.atts.long_name.data = 'cosine correction for narrowband filter1';
mfrsr.vars.cosine_correction_filter6.atts.units.data = 'unitless';
% 
% mfrsr.dims.channel.length = 7;
% mfrsr.vars.channel.data = [1:7];
% mfrsr.vars.channel.dims = {'channel'};
% mfrsr.vars.channel.atts.units.data = 'unitless';

for f = 1:7
   offset(f) = corrs{f}.det_corrs.offset;
   det_sens(f) = corrs{f}.det_corrs.sens;
   gain(f) = corrs{f}.det_corrs.gain;

   mfrsr.vars.(['channel',num2str(f),'_offset']).data = offset(f);
   mfrsr.vars.(['channel',num2str(f),'_offset']).dims = {''};
   mfrsr.vars.(['channel',num2str(f),'_offset']).atts.units.data = 'mV';
   mfrsr.vars.(['channel',num2str(f),'_detector_sensitivity']).data = det_sens(f);
   mfrsr.vars.(['channel',num2str(f),'_detector_sensitivity']).dims = {''};
   mfrsr.vars.(['channel',num2str(f),'_detector_sensitivity']).atts.units.data = 'mV/W/nm';
   mfrsr.vars.(['channel',num2str(f),'_logger_gain']).data = gain(f);
   mfrsr.vars.(['channel',num2str(f),'_logger_gain']).dims = {''};
   mfrsr.vars.(['channel',num2str(f),'_logger_gain']).atts.units.data = 'counts/mV';
end

mfrsr.vars.callang_flags.keep = false;
mfrsr.dims.numfields.keep = false;

end

