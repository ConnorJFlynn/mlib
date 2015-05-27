function status = mfrsr_a0tob1(arg)
%20060424 Modified cosine correction to carry out flip on initial read
%%
if exist('arg','var')
    basepath = arg.basepath;
    fmask = arg.fmask;
else
    basepath = uigetdir(['D:\case_studies\new_xmfrx_proc\'],'Select base path below the data directory');
    fmask = fliplr(strtok(fliplr(basepath),'\'));
    basepath = [basepath, '\'];
    arg.basepath = basepath;
    arg.fmask = fmask;
end
a0_path = [basepath,'a0\'];
outpath = [basepath,'b1\'];
corr_matpath = [basepath,'corr_mat\'];
raw_corrpath = [basepath,'corrs\'];
filter_trace_path = [raw_corrpath, 'filter_traces\'];
arg.a0_path = a0_path;
arg.b1_path = outpath;
arg.corr_matpath = corr_matpath;
arg.raw_corrpath = raw_corrpath;
arg.filter_trace_path = filter_trace_path;

if ~exist(a0_path,'dir')
    a0_path = [uigetdir(basepath,'Select location of a0 files'),filesep];
end
if ~exist(outpath,'dir')
    outpath = [a0_path, filesep,'my_b1'];
    if ~exist(outpath,'dir')
        mkdir(outpath);
    end
end


D = ls([a0_path, fmask, '*.cdf']);

% Read the first netcdf file
% Use it to load a pre-saved set of corrs based on the head id,
% or to generate this same set of corrs if a mat file isn't found.
mfrsr = ancload([a0_path, char(D(1,:))]);
mfrsr.atts.missing_value.data = -9999;
mfrsr.atts.missing_value.datatype = 5;
mfrsr = missing2nan(mfrsr);
head_id = deblank(char(mfrsr.atts.head_id.data));
arg.head_id = head_id;
arg.lat = mfrsr.vars.lat.data;
if exist([corr_matpath,fmask,'.',head_id,'.mat'],'file')
    load([corr_matpath,fmask,'.',head_id,'.mat']);
else
    corrs = get_head_corrs(arg);
    uisave([corr_matpath,fmask,'.',head_id,'.mat'], 'corrs');
end

% mfrsr.clobber = true;
% mfrsr.fname = [arg.b1_path, outname];

for f = 1:size(D,1);
    disp(['Processing file #',num2str(f), ' of ', num2str(size(D,1)), ': ',char(D(f,:))]);
    fname = char(D(f,:));
    mfrsr = ancload([a0_path, fname]);
    mfrsr.atts.missing_value.data = -9999;
    mfrsr.atts.missing_value.datatype = 5;
    mfrsr = missing2nan(mfrsr);
    head_id = deblank(char(mfrsr.atts.head_id.data));
    if ~strcmp(arg.head_id,head_id)
        if exist(corr_matpath,fmask,'.',head_id,'.mat')
            load([corr_matpath,fmask,'.',head_id,'.mat']);
        else
            corrs = get_head_corrs(arg);
            save([corr_matpath,fmask,'.',head_id,'.mat'], 'corrs');
        end
    end
    mfrsr = apply_mfrsr_corrs(mfrsr,corrs);
    mfrsr.quiet = true;
    mfrsr.clobber = true;
    b1_name = [fmask,'.b1.',datestr(mfrsr.time(1), 'YYYYmmDD.HHMMSS'), '.nc'];
    mfrsr.fname = [outpath, b1_name];
    mfrsr = clean_up_ancstruct(mfrsr,corrs);
    mfrsr = anccheck(mfrsr);
    ancsave(mfrsr);
    %%
end
status = 1;
%%
    function mfrsr = clean_up_ancstruct(mfrsr, corrs);
        
        order = {
            'base_time'
            'time_offset'
            'time'
            'bench_angle'
            'filter_1_wavelength'
            'filter_2_wavelength'
            'filter_3_wavelength'
            'filter_4_wavelength'
            'filter_5_wavelength'
            'filter_6_wavelength'
            'hemisp_broadband'
            'th_broadband'
            'corth_broadband'
            'hemisp_narrowband_filter1'
            'th_filter1'
            'corth_filter1'
            'hemisp_narrowband_filter2'
            'th_filter2'
            'corth_filter2'
            'hemisp_narrowband_filter3'
            'th_filter3'
            'corth_filter3'
            'hemisp_narrowband_filter4'
            'th_filter4'
            'corth_filter4'
            'hemisp_narrowband_filter5'
            'th_filter5'
            'corth_filter5'
            'hemisp_narrowband_filter6'
            'th_filter6'
            'corth_filter6'
            'diffuse_hemisp_broadband'
            'dif_broadband'
            'cordif_broadband'
            'diffuse_hemisp_narrowband_filter1'
            'dif_filter1'
            'cordif_filter1'
            'diffuse_hemisp_narrowband_filter2'
            'dif_filter2'
            'cordif_filter2'
            'diffuse_hemisp_narrowband_filter3'
            'dif_filter3'
            'cordif_filter3'
            'diffuse_hemisp_narrowband_filter4'
            'dif_filter4'
            'cordif_filter4'
            'diffuse_hemisp_narrowband_filter5'
            'dif_filter5'
            'cordif_filter5'
            'diffuse_hemisp_narrowband_filter6'
            'dif_filter6'
            'cordif_filter6'
            'direct_normal_broadband'
            'cordirnorm_broadband'
            'direct_normal_narrowband_filter1'
            'cordirnorm_filter1'
            'direct_normal_narrowband_filter2'
            'cordirnorm_filter2'
            'direct_normal_narrowband_filter3'
            'cordirnorm_filter3'
            'direct_normal_narrowband_filter4'
            'cordirnorm_filter4'
            'direct_normal_narrowband_filter5'
            'cordirnorm_filter5'
            'direct_normal_narrowband_filter6'
            'cordirnorm_filter6'
            'direct_horizontal_broadband'
            'cordirhor_broadband'
            'direct_horizontal_narrowband_filter1'
            'cordirhor_filter1'
            'direct_horizontal_narrowband_filter2'
            'cordirhor_filter2'
            'direct_horizontal_narrowband_filter3'
            'cordirhor_filter3'
            'direct_horizontal_narrowband_filter4'
            'cordirhor_filter4'
            'direct_horizontal_narrowband_filter5'
            'cordirhor_filter5'
            'direct_horizontal_narrowband_filter6'
            'cordirhor_filter6'
            'dif2dirhor_broadband'
            'dif2dirhor_filter1'
            'dif2dirhor_filter2'
            'dif2dirhor_filter3'
            'dif2dirhor_filter4'
            'dif2dirhor_filter5'
            'dif2dirhor_filter6'
            'head_temp'
            'logger_volt'
            'callang_flags'
            'zen_angle'
            'cos_zen'
            'airmass'
            'az_angle'
            'r_au'
            'diffuse_correction_broadband'
            'diffuse_correction_filter1'
            'diffuse_correction_filter2'
            'diffuse_correction_filter3'
            'diffuse_correction_filter4'
            'diffuse_correction_filter5'
            'diffuse_correction_filter6'
            'diff_corr_err_broadband'
            'diff_corr_err_filter1'
            'diff_corr_err_filter2'
            'diff_corr_err_filter3'
            'diff_corr_err_filter4'
            'diff_corr_err_filter5'
            'diff_corr_err_filter6'
            'cosine_correction_broadband'
            'cosine_correction_filter1'
            'cosine_correction_filter2'
            'cosine_correction_filter3'
            'cosine_correction_filter4'
            'cosine_correction_filter5'
            'cosine_correction_filter6'
            'SN_response_broadband'
            'SN_response_filter1'
            'SN_response_filter2'
            'SN_response_filter3'
            'SN_response_filter4'
            'SN_response_filter5'
            'SN_response_filter6'
            'WE_response_broadband'
            'WE_response_filter1'
            'WE_response_filter2'
            'WE_response_filter3'
            'WE_response_filter4'
            'WE_response_filter5'
            'WE_response_filter6'
            'filter_1_trace'
            'filter_2_trace'
            'filter_3_trace'
            'filter_4_trace'
            'filter_5_trace'
            'filter_6_trace'
            'channel1_offset'
            'channel2_offset'
            'channel3_offset'
            'channel4_offset'
            'channel5_offset'
            'channel6_offset'
            'channel7_offset'
            'channel1_detector_sensitivity'
            'channel2_detector_sensitivity'
            'channel3_detector_sensitivity'
            'channel4_detector_sensitivity'
            'channel5_detector_sensitivity'
            'channel6_detector_sensitivity'
            'channel7_detector_sensitivity'
            'channel1_logger_gain'
            'channel2_logger_gain'
            'channel3_logger_gain'
            'channel4_logger_gain'
            'channel5_logger_gain'
            'channel6_logger_gain'
            'channel7_logger_gain'
            'lat'
            'lon'
            'alt'};
        
        for d = 1:length(order)
            mfrsr.vars.(char(order(d))).id = d;
        end
        
        irradiance_units = {    'hemisp_broadband'
            'th_broadband'
            'corth_broadband'
            'th_filter1'
            'corth_filter1'
            'hemisp_narrowband_filter2'
            'th_filter2'
            'corth_filter2'
            'hemisp_narrowband_filter3'
            'th_filter3'
            'corth_filter3'
            'hemisp_narrowband_filter4'
            'th_filter4'
            'corth_filter4'
            'hemisp_narrowband_filter5'
            'th_filter5'
            'corth_filter5'
            'hemisp_narrowband_filter6'
            'th_filter6'
            'corth_filter6'
            'diffuse_hemisp_broadband'
            'dif_broadband'
            'cordif_broadband'
            'diffuse_hemisp_narrowband_filter1'
            'dif_filter1'
            'cordif_filter1'
            'diffuse_hemisp_narrowband_filter2'
            'dif_filter2'
            'cordif_filter2'
            'diffuse_hemisp_narrowband_filter3'
            'dif_filter3'
            'cordif_filter3'
            'diffuse_hemisp_narrowband_filter4'
            'dif_filter4'
            'cordif_filter4'
            'diffuse_hemisp_narrowband_filter5'
            'dif_filter5'
            'cordif_filter5'
            'diffuse_hemisp_narrowband_filter6'
            'dif_filter6'
            'cordif_filter6'
            'direct_normal_broadband'
            'cordirnorm_broadband'
            'direct_normal_narrowband_filter1'
            'cordirnorm_filter1'
            'direct_normal_narrowband_filter2'
            'cordirnorm_filter2'
            'direct_normal_narrowband_filter3'
            'cordirnorm_filter3'
            'direct_normal_narrowband_filter4'
            'cordirnorm_filter4'
            'direct_normal_narrowband_filter5'
            'cordirnorm_filter5'
            'direct_normal_narrowband_filter6'
            'cordirnorm_filter6'
            'direct_horizontal_broadband'
            'cordirhor_broadband'
            'direct_horizontal_narrowband_filter1'
            'cordirhor_filter1'
            'direct_horizontal_narrowband_filter2'
            'cordirhor_filter2'
            'direct_horizontal_narrowband_filter3'
            'cordirhor_filter3'
            'direct_horizontal_narrowband_filter4'
            'cordirhor_filter4'
            'direct_horizontal_narrowband_filter5'
            'cordirhor_filter5'
            'direct_horizontal_narrowband_filter6'
            'cordirhor_filter6'};
        
        for f = 1:length(irradiance_units)
            mfrsr.vars.(char(irradiance_units(f))).atts.units = mfrsr.vars.hemisp_narrowband_filter1.atts.units;
        end
        
        unitless_fields = {
            'callang_flags'
            'cos_zen'
            'airmass'
            'az_angle'
            'r_au'
            'diffuse_correction_broadband'
            'diffuse_correction_filter1'
            'diffuse_correction_filter2'
            'diffuse_correction_filter3'
            'diffuse_correction_filter4'
            'diffuse_correction_filter5'
            'diffuse_correction_filter6'
            'diff_corr_err_broadband'
            'diff_corr_err_filter1'
            'diff_corr_err_filter2'
            'diff_corr_err_filter3'
            'diff_corr_err_filter4'
            'diff_corr_err_filter5'
            'diff_corr_err_filter6'
            'SN_response_broadband'
            'SN_response_filter1'
            'SN_response_filter2'
            'SN_response_filter3'
            'SN_response_filter4'
            'SN_response_filter5'
            'SN_response_filter6'
            'WE_response_broadband'
            'WE_response_filter1'
            'WE_response_filter2'
            'WE_response_filter3'
            'WE_response_filter4'
            'WE_response_filter5'
            'WE_response_filter6'
            'dif2dirhor_broadband'
            'dif2dirhor_filter1'
            'dif2dirhor_filter2'
            'dif2dirhor_filter3'
            'dif2dirhor_filter4'
            'dif2dirhor_filter5'
            'dif2dirhor_filter6'};
        
        for f = 1:length(unitless_fields)
            mfrsr.vars.(char(unitless_fields(f))).atts.units = mfrsr.vars.cosine_correction_broadband.atts.units;
        end
        % for broadband fields
        fields = {'th_broadband','corth_broadband'};
        for f = 1:length(fields)
            mfrsr.vars.(char(fields(f))).atts.long_name = mfrsr.vars.hemisp_broadband.atts.long_name;
            mfrsr.vars.(char(fields(f))).atts = mfrsr.vars.hemisp_broadband.atts;
        end
        
        %for filter fields
        for f = 1:6
            mfrsr.vars.(['th_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['hemisp_narrowband_filter',num2str(f)]).atts.long_name;
            mfrsr.vars.(['corth_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['hemisp_narrowband_filter',num2str(f)]).atts.long_name;
            
            mfrsr.vars.(['dif_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['diffuse_hemisp_narrowband_filter',num2str(f)]).atts.long_name;
            mfrsr.vars.(['cordif_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['diffuse_hemisp_narrowband_filter',num2str(f)]).atts.long_name;
            
            mfrsr.vars.(['cordirnorm_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(f)]).atts.long_name;
            
            mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(f)]).atts.long_name;
            mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(f)]).atts.long_name.data = ['Direct Horizontal Narrowband Irradiance, Filter ',num2str(f)];
            mfrsr.vars.(['cordirhor_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(f)]).atts.long_name;
            
            mfrsr.vars.(['dif2dirhor_filter',num2str(f)]).atts.long_name = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(f)]).atts.long_name;
            mfrsr.vars.(['dif2dirhor_filter',num2str(f)]).atts.long_name.data = ['Diffuse to direct horizontal ratio, filter ',num2str(f)];
            
            mfrsr.vars.(['th_filter',num2str(f)]).atts = mfrsr.vars.(['hemisp_narrowband_filter',num2str(f)]).atts;
            mfrsr.vars.(['corth_filter',num2str(f)]).atts = mfrsr.vars.(['hemisp_narrowband_filter',num2str(f)]).atts;
            
            mfrsr.vars.(['dif_filter',num2str(f)]).atts = mfrsr.vars.(['diffuse_hemisp_narrowband_filter',num2str(f)]).atts;
            mfrsr.vars.(['cordif_filter',num2str(f)]).atts = mfrsr.vars.(['diffuse_hemisp_narrowband_filter',num2str(f)]).atts;
            
            mfrsr.vars.(['cordirnorm_filter',num2str(f)]).atts = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(f)]).atts;
            
            mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(f)]).atts = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(f)]).atts;
            mfrsr.vars.(['cordirhor_filter',num2str(f)]).atts = mfrsr.vars.(['direct_horizontal_narrowband_filter',num2str(f)]).atts;
            
            mfrsr.vars.(['dif2dirhor_filter',num2str(f)]).atts = mfrsr.vars.(['direct_normal_narrowband_filter',num2str(f)]).atts;
            
        end
        
        for i = 2:7
            
            mfrsr.vars.(['th_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            mfrsr.vars.(['dif_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            mfrsr.vars.(['cordirnorm_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            mfrsr.vars.(['cordirhor_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            mfrsr.vars.(['cordif_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            mfrsr.vars.(['corth_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            mfrsr.vars.(['dif2dirhor_filter',num2str(i-1)]).atts.actual_wavelength.data = corrs{i}.trace.normed.cw;
            
            mfrsr.vars.(['th_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            mfrsr.vars.(['dif_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            mfrsr.vars.(['cordirnorm_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            mfrsr.vars.(['cordirhor_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            mfrsr.vars.(['cordif_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            mfrsr.vars.(['corth_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            mfrsr.vars.(['dif2dirhor_filter',num2str(i-1)]).atts.filter_FWHM.data = corrs{i}.trace.normed.FWHM;
            
        end
        mfrsr.vars.r_au.atts.units.datatype = 2;
        mfrsr.vars.r_au.atts.units.data = 'Astronomical Unit';
        
        % set corrections attribute to none
        no_corrs = {    'hemisp_broadband'
            'hemisp_narrowband_filter1'
            'hemisp_narrowband_filter2'
            'hemisp_narrowband_filter3'
            'hemisp_narrowband_filter4'
            'hemisp_narrowband_filter5'
            'hemisp_narrowband_filter6'
            'diffuse_hemisp_broadband'
            'diffuse_hemisp_narrowband_filter1'
            'diffuse_hemisp_narrowband_filter2'
            'diffuse_hemisp_narrowband_filter3'
            'diffuse_hemisp_narrowband_filter4'
            'diffuse_hemisp_narrowband_filter5'
            'diffuse_hemisp_narrowband_filter6'
            'direct_normal_broadband'
            'direct_normal_narrowband_filter1'
            'direct_normal_narrowband_filter2'
            'direct_normal_narrowband_filter3'
            'direct_normal_narrowband_filter4'
            'direct_normal_narrowband_filter5'
            'direct_normal_narrowband_filter6'
            'direct_horizontal_broadband'
            'direct_horizontal_narrowband_filter1'
            'direct_horizontal_narrowband_filter2'
            'direct_horizontal_narrowband_filter3'
            'direct_horizontal_narrowband_filter4'
            'direct_horizontal_narrowband_filter5'
            'direct_horizontal_narrowband_filter6'
            };
        
        for f = 1:length(no_corrs);
            mfrsr.vars.(char(no_corrs(f))).atts.corrections.datatype = 2;
            mfrsr.vars.(char(no_corrs(f))).atts.corrections.data = 'no corrections applied';
        end
        
        % set corrections attribute to offset subtracted
        offset_corrs = {
            'th_broadband'
            'th_filter1'
            'th_filter2'
            'th_filter3'
            'th_filter4'
            'th_filter5'
            'th_filter6'
            'dif_broadband'
            'dif_filter1'
            'dif_filter2'
            'dif_filter3'
            'dif_filter4'
            'dif_filter5'
            'dif_filter6'
            };
        
        for f = 1:length(offset_corrs);
            mfrsr.vars.(char(offset_corrs(f))).atts.corrections.datatype = 2;
            mfrsr.vars.(char(offset_corrs(f))).atts.corrections.data = 'offset corrected';
        end
        % set corrections to cosine corrected
        cos_corrs = {
            'cordirnorm_broadband'
            'cordirnorm_filter1'
            'cordirnorm_filter2'
            'cordirnorm_filter3'
            'cordirnorm_filter4'
            'cordirnorm_filter5'
            'cordirnorm_filter6'
            'cordirhor_broadband'
            'cordirhor_filter1'
            'cordirhor_filter2'
            'cordirhor_filter3'
            'cordirhor_filter4'
            'cordirhor_filter5'
            'cordirhor_filter6'
            };
        for f = 1:length(cos_corrs);
            mfrsr.vars.(char(cos_corrs(f))).atts.corrections.datatype = 2;
            mfrsr.vars.(char(cos_corrs(f))).atts.corrections.data = 'cosine corrected';
        end
        
        % set corrections to offset and cosine corrected
        
        all_corrs = {
            'corth_broadband'
            'corth_filter1'
            'corth_filter2'
            'corth_filter3'
            'corth_filter4'
            'corth_filter5'
            'corth_filter6'
            'cordif_broadband'
            'cordif_filter1'
            'cordif_filter2'
            'cordif_filter3'
            'cordif_filter4'
            'cordif_filter5'
            'cordif_filter6'
            'dif2dirhor_broadband'
            'dif2dirhor_filter1'
            'dif2dirhor_filter2'
            'dif2dirhor_filter3'
            'dif2dirhor_filter4'
            'dif2dirhor_filter5'
            'dif2dirhor_filter6'
            };
        for f = 1:length(all_corrs);
            mfrsr.vars.(char(all_corrs(f))).atts.corrections.datatype = 2;
            mfrsr.vars.(char(all_corrs(f))).atts.corrections.data = 'offset and cosine corrected';
        end
        
        
        %
        function arg = set_arg;
            
            %%
            basepath = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrC1\'];
            fmask = ['sgpmfrsrC1'];
            a0_path = [basepath,'a0\'];
            b1_path = [basepath,'b1\'];
            corr_matpath = [basepath,'corr_mat\'];
            raw_corrpath = [basepath,'corrs\'];
            filter_trace_path = [raw_corrpath, 'filter_traces\'];
            arg.basepath = basepath;
            arg.fmask = fmask;
            arg.a0_path = a0_path;
            arg.b1_path = b1_path;
            arg.corr_matpath = corr_matpath;
            arg.raw_corrpath = raw_corrpath;
            arg.filter_trace_path = filter_trace_path;
            status = mfrsr_a0tob1(arg);
            
            
            basepath = ['D:\case_studies\new_xmfrx_proc\sgpmfrsrE13\'];
            fmask = ['sgpmfrsrE13'];
            a0_path = [basepath,'a0\'];
            b1_path = [basepath,'b1\'];
            corr_matpath = [basepath,'corr_mat\'];
            raw_corrpath = [basepath,'corrs\'];
            filter_trace_path = [raw_corrpath, 'filter_traces\'];
            arg.basepath = basepath;
            arg.fmask = fmask;
            arg.a0_path = a0_path;
            arg.b1_path = b1_path;
            arg.corr_matpath = corr_matpath;
            arg.raw_corrpath = raw_corrpath;
            arg.filter_trace_path = filter_trace_path;
            
            status = mfrsr_a0tob1(arg);
            
            %%
            basepath = ['D:\case_studies\new_xmfrx_proc\head_cals\bbhrp_period\double-checked\sgpmfr10mC1'];
            fmask = ['sgpmfrsrE13'];
            a0_path = [basepath,'a0\'];
            b1_path = [basepath,'b1\'];
            corr_matpath = [basepath];
            raw_corrpath = [basepath];
            filter_trace_path = [raw_corrpath];
            arg.basepath = basepath;
            arg.fmask = fmask;
            arg.a0_path = a0_path;
            arg.b1_path = b1_path;
            arg.corr_matpath = corr_matpath;
            arg.raw_corrpath = raw_corrpath;
            arg.filter_trace_path = 'D:\case_studies\new_xmfrx_proc\head_cals\bbhrp_period\double-checked\sgpmfr10mC1';
            arg.head_id = '922';
            status = mfrsr_a0tob1(arg);
            
            %%