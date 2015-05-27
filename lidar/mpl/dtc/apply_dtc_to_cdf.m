function status = apply_dtc_to_cdf(fname);
% status = apply_dtc_to_cdf(fname);
% This was an internal function is used by for_files
% In addition to applying the deadtime correction, it also updates
% the netcdf file (detector_counts, background, and :deadtime_corrected)
% I have broken it out here in case it will come in  handy generally
% CJF 2005-02-22
ncid = ncmex('open', fname, 'write')
[dtc_att, status] = ncmex('ATTGET', ncid, 'global', 'deadtime_corrected');

[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
[unlim, unlim_length, status] = ncmex('DIMINQ', ncid, recdim);

if ((unlim_length>0) & (length(findstr(upper(dtc_att),'NO')>0)))
   rawcts = nc_getvar(ncid, 'detector_counts');
   disp('Applying deadtime correction');
   dtc = dtc_apd6850_ipa(rawcts);
   status = nc_putvar(ncid, 'detector_counts', dtc);
   [bins,profs] = size(rawcts);
   r = [fix(bins*.87):ceil(bins*.97)];
   bg = nc_getvar(ncid, 'background');
   new_bg = mean(rawcts(r,:));
   status = nc_putvar(ncid, 'background', new_bg);
   status = ncmex('REDEF', ncid);
   status = ncmex('ATTPUT', ncid, 'global', 'deadtime_corrected', 'char', length('Yes'), 'Yes');
   [corr_att, status] = ncmex('ATTGET', ncid, 'detector_counts', 'corrections');
   in_string = 'deadtime-corrected MHz';
   status = ncmex('ATTPUT', ncid, 'detector_counts', 'corrections', 'char', length(in_string), in_string);
   in_string = 'SPCM-AQR-FC 6850a';
   status = ncmex('ATTPUT', ncid, 'detector_counts', 'APD_serial_number', 'char', length(in_string), in_string);
   
   status = ncmex('ENDEF', ncid);
end
status = ncmex('close', ncid);
end