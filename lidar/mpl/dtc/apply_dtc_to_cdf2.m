function status = apply_dtc_to_cdf2(fname, dtc_function);
% status = apply_dtc_to_cdf(fname, dtc_function);
% This was an internal function is used by for_files
% In addition to applying the deadtime correction, it also updates
% the netcdf file (detector_counts, background, and :deadtime_corrected)
% I have broken it out here in case it will come in  handy generally
% CJF 2005-02-22
mpl_nc = nclink(fname);
% ncid = ncmex('open', fname, 'write')
% [dtc_att, status] = ncmex('ATTGET', ncid, 'global', 'deadtime_corrected');
%
% [ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
% [unlim, unlim_length, status] = ncmex('DIMINQ', ncid, recdim);
status = 1;
if (length(findstr(upper(mpl_nc.atts.deadtime_corrected.data),'NO')>0))
    mpl_nc = ncload(fname);
    if(mpl_nc.dims.time.length>0)
        disp('Applying deadtime correction');
        eval(['mpl_nc.vars.detector_counts.data = ', dtc_function, '(mpl_nc.vars.detector_counts.data);'])
        %   dtc = dtc_apd6850_ipa(rawcts);
        [bins,profs] = size(mpl_nc.vars.detector_counts.data);
        r = [fix(bins*.87):ceil(bins*.97)];
        mpl_nc.vars.background_signal.data = mean(mpl_nc.vars.detector_counts.data(r,:));
        mpl_nc.atts.deadtime_corrected.data = 'Yes';
        mpl_nc.atts.deadtime_corrected.datatype = 2;
        %    status = ncmex('ATTPUT', ncid, 'global', 'deadtime_corrected', 'char', length('Yes'), 'Yes');
        in_string = 'deadtime-corrected MHz';
        if isfield(mpl_nc.vars.detector_counts,'corrections')
            mpl_nc.vars.detector_counts.atts.corrections.data = [mpl_nc.vars.detector_counts.atts.corrections.data, in_string];
        else
            mpl_nc.vars.detector_counts.atts.corrections.data = [in_string];
            mpl_nc.vars.detector_counts.atts.corrections.datatype = 2;
        end
        mpl_nc.vars.detector_counts.atts.APD_serial_number.data = [dtc_function];
%        mpl_nc.vars.detector_counts.atts.APD_serial_number.datatype = 2;
        mpl_nc.clobber = 1;
        status = ncsave(mpl_nc, fname);
    end
end
