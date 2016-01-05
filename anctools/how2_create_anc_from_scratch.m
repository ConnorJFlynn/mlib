Creating an anc struct from scratch:

% first assign .fname in similar manner (but will need pname too)
ds_name_stem = 'isdac_mplpol_3flynn';
begin_date = floor(mplps.time(1));
begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
ds_name = [ds_name_stem, '.c1.', begin_datestr, '.000000.cdf'];
anc.fname = ds_name;

% Next define recdim, time, and other dims.
anc.recdim.name = 'time';
anc.recdim.id = 0;
anc.recdim.length = length(mplps.time);

anc.dims.time.id = 0;
anc.dims.time.length = anc.recdim.length;
anc.dims.time.isunlim = true;

anc.dims.range.id = 1;
anc.dims.range.length = length(mplps.range);
anc.dims.range.isunlim = false;

anc.time = mplps.time;
% Use timesync to create and populate time fields.
anc = timesync(anc);


function atts = default_var_atts(long_name,units);
% var = def_var_atts(var,long_name,units);
atts.long_name.data =char(long_name);
atts.long_name = ancfixdatatype(atts.long_name);
atts.units.data =char(units);
atts.units = ancfixdatatype(atts.units);
atts = init_ids(atts);
return

function att = define_att(att_val);
% att = define_att(att_name, att_val);
att.data = att_val;
att = ancfixdatatype(att);

return

function var = default_var_def(var_val, long_name, units, dims, datatype);
% var = default_var_def(var_val, long_name, units, datatype);
var.data = var_val;
var.dims = dims;
var.atts = default_var_atts(long_name,units);
if ~exist('datatype','var')
   var = ancfixdatatype(var);
else
   var.datatype = datatype;   
end
return
