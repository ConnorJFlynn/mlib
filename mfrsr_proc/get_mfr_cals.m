function cals = get_mfr_cals(mfr)
if ~exist('mfr','var')
mfr = ancload;
end
   %
%%


%%
mfr = ancsift(mfr,mfr.dims.time, mfr.time==mfr.time(1));
cals.atts.site_id = mfr.atts.site_id;
cals.atts.facility_id = mfr.atts.facility_id;
cals.recdim = mfr.recdim;
cals.dims.time = mfr.dims.time;
cals.time = floor(mfr.time)+.5;

for f = 1:5
cals.vars.(['offset_filter',num2str(f)]) = mfr.vars.(['offset_filter',num2str(f)]);
cals.vars.(['nominal_calibration_factor_filter',num2str(f)]) = mfr.vars.(['nominal_calibration_factor_filter',num2str(f)]);
cals.vars.(['Io_filter',num2str(f)]) = mfr.vars.(['Io_filter',num2str(f)]);
cals.vars.(['qc_Io_filter',num2str(f)]) = mfr.vars.(['qc_Io_filter',num2str(f)]);


cals.vars.(['offset_filter',num2str(f)]).dims = mfr.vars.time_offset.dims;
cals.vars.(['nominal_calibration_factor_filter',num2str(f)]).dims = mfr.vars.time_offset.dims;
cals.vars.(['Io_filter',num2str(f)]).dims = mfr.vars.time_offset.dims;
cals.vars.(['qc_Io_filter',num2str(f)]).dims = mfr.vars.time_offset.dims;

fld_str = ['filter',num2str(f),'_CWL_measured'];

cals.vars.(fld_str)=cals.vars.(['Io_filter',num2str(f)]);
cals.vars.(fld_str).atts.long_name.data = fld_str;
cals.vars.(fld_str).atts.units.data = 'nm';
cals.vars.(fld_str).data = sscanf(mfr.atts.(fld_str).data,'%f');

fld_str = ['filter',num2str(f),'_FWHM_measured'];
cals_.vars.(fld_str)=cals.vars.(['Io_filter',num2str(f)]);
cals.vars.(fld_str).atts.long_name.data = fld_str;
cals.vars.(fld_str).atts.units.data = 'nm';
cals.vars.(fld_str).data = sscanf(mfr.atts.(fld_str).data,'%f');
end
fld_str = ['logger_id'];
cals.vars.(fld_str)= cals.vars.(['Io_filter1']);
cals.vars.(fld_str).atts.long_name.data = fld_str;
cals.vars.(fld_str).atts.units.data = 'unitless';
cals.vars.(fld_str).data = sscanf(mfr.atts.(fld_str).data,'%d');
fld_str = ['head_id'];
cals.vars.(fld_str)=cals.vars.(['Io_filter1']);
cals.vars.(fld_str).atts.long_name.data = fld_str;
cals.vars.(fld_str).atts.units.data = 'unitless';
cals.vars.(fld_str).data = sscanf(mfr.atts.(fld_str).data,'%d');


[pname, fname, ext] = fileparts(mfr.fname);
[fstem,frem] = strtok(fname,'.');
fstem(findstr(fstem,'aod1mich'):end)=[];
fstem = [fstem,'cals'];
cals.fname = [pname,filesep, fstem,frem,ext];
%%
vars.head_id = cals.vars.head_id;
cals.vars = rmfield(cals.vars, 'head_id');
vars.logger_id = cals.vars.logger_id;
cals.vars = rmfield(cals.vars, 'logger_id');
vars.head_id.id = 1;
vars.logger_id.id = 2;

those = sort(fieldnames(cals.vars));
for th = 1:length(those)
  cals.vars.(those{th}).id = th+2;
  vars.(those{th}) = cals.vars.(those{th});
end
cals.vars = vars;
cals.quiet = true;
cals = anccheck(cals);
cals.clobber = true;
%%
% ancsave(cals)


%%
