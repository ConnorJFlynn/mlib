function sws_sub = sws_raw_sub(sws)
%  This function takes a subset of critical elements from the sws
%  anc_struct and renames them as labeled in read_sas_raw, bundle_sas_raw,

if isfield(sws,'ncdef')
   sws_sub.time = sws.time';
   sws_sub.spec = sws.vdata.spectra'; 
   sws_sub.t_int_ms = sws.vdata.integration_time';
   sws_sub.lambda = sws.vdata.wavelength';
   sws_sub.Shutter_open_TF = sws.vdata.shutter_state';
else
   sws_sub = [];
   error('Improper sws struct passed into sws_raw_sub!');
end
return