function anc = mplps_mat2anc(mplps);
% status = write_ISDAC_cdf_1(mplps, pname);
% provided with a complete mplps structure, writes it to netcdf in pname
ds_name_stem = 'isdac_mplpol_3flynn';
ds_name = [ds_name_stem, '.c1.', datestr(mplps.time(1),'yyyymmdd.HH'), '0000.cdf'];
anc.fname = ds_name;

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
anc = timesync(anc);

% Define global atts
att_name = 'proc_level'; att_val = char('c1');
anc.atts.(att_name) = define_att(att_val);

att_name = 'input_source'; att_val = [mplps.statics.datastream];
anc.atts.(att_name) = define_att(att_val);

att_name = 'site_id'; att_val = 'nsa';
anc.atts.(att_name) = define_att(att_val);

att_name = 'facility_id'; att_val = 'C1 : PAARCS2:NSA-Barrow_Central_Facility';
anc.atts.(att_name) = define_att(att_val);

att_name = 'proc_level';att_val = 'c1';
anc.atts.(att_name) = define_att(att_val);

att_name = 'averaging_int'; att_val = [num2str(24*60*(mplps.time(2)-mplps.time(1))), ' minutes'];
anc.atts.(att_name) = define_att(att_val);

att_name = 'deadtime_corrected'; att_val = 'yes';
anc.atts.(att_name) = define_att(att_val);

att_name = 'deadtime_correction'; att_val = 'generic form used';
anc.atts.(att_name) = define_att(att_val);

att_name = 'Principle_Investigator';
att_val = ['Connor J. Flynn Connor.Flynn@pnl.gov 509-375-2041'];
anc.atts.(att_name) = define_att(att_val);

att_name = 'time_offset_description';
att_val = 'The time is referenced to the middle of each averaging interval.';
anc.atts.(att_name) = define_att(att_val);

att_name = 'serial_number'; att_val = [num2str(mplps.statics.unitSN)];
anc.atts.(att_name) = define_att(att_val);

att_name = 'zeb_platform'; att_val = [ds_name_stem, '.c1.'];
anc.atts.(att_name) = define_att(att_val);

att_name = 'history'; att_val = ['Created by CJF on ', datestr(now)];
anc.atts.(att_name) = define_att(att_val);

anc.atts = init_ids(anc.atts);

% Define and populate other fields


%      !! Start here
var_name = 'range';
var_val = mplps.range;
datatype = 5;
long_name = 'height above ground level to the center of the bin'; units = 'km';
dims = {'range'};
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims,datatype);
att_name = 'range_resolution'; att_val = [sprintf('%.3f',mplps.range(2)-mplps.range(1)), ' ',units];
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);

var_name = 'copol_afterpulse';
var_val = mplps.cop_ap;
dims = {'range'};
long_name = 'afterpulse subtracted from copol signal'; units = 'MHz';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'crosspol_afterpulse';
var_val = mplps.crs_ap;
dims = {'range'};
long_name = 'afterpulse subtracted from crosspol signal'; units = 'MHz';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'overlap_correction_factor';
var_val = mplps.ol_corr;
dims = {'range'};
long_name = 'overlap correction factor applied to attenuated backscatter'; units = 'unitless';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'atten_bscat_Rayleigh';
var_val = mplps.std_attn_prof;
dims = {'range'};
long_name = 'Rayleigh attenuated backscatter profile'; units = 'ster/km';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);


var_name = 'julian_day';
var_val = serial2doy(mplps.time);
V = datevec(mplps.time(1)); year = V(1);
long_name = char('Day of year');
units = char(['days since ' datestr(datenum(year,1,1),31) ' UTC']);
dims = {'time'};
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

att_name = 'comment'; att_val = char(['For example: Jan 1 6:00 AM = 0.25']);      
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);

var_name = 'energyMonitor'; 
var_val = mplps.hk.cop_energy_monitor;
dims = {'time'};
long_name = 'average laser pulse energy';
units = 'microjoules';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'copol_bg';
dims = {'time'};
var_val = mplps.hk.cop_bg;
long_name = 'co-polarized background';
units = 'counts per microsecond';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'crosspol_bg';
var_val = mplps.hk.crs_bg;
dims = {'time'};
long_name = 'cross-polarized background';
units = 'counts per microsecond';
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'samples';
var_val = mplps.samples;
long_name = char('Number of sub-samples in averaging interval');
units = char(['unitless']);
dims = {'time'};
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'attn_bscat';
long_name = 'attenuated backscatter from combined linearly polarized components';
units = 'cts/(us-km^2)';
dims = {'range','time'};
anc.vars.(var_name) = default_var_def(mplps.attn_bscat, long_name, units, dims);

var_name = 'attn_bscat_snr';
long_name = 'signal to noise ratio of attenuated backscatter';
units = 'unitless';
dims = {'range','time'};
anc.vars.(var_name) = default_var_def(mplps.attn_bscat_snr, long_name, units, dims);

var_name = 'ldr';
long_name = 'linear depolarization ratio';
units = 'unitless';
dims = {'range','time'};
anc.vars.(var_name) = default_var_def(mplps.ldr, long_name, units, dims);
att_name = 'equation'; att_val = 'ldr = linear_crosspol / (circular_copol + linear_crosspol)';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
att_name = 'comment_1'; att_val = 'No depolarization = 0';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
att_name = 'comment_2';att_val = 'Full depolarization = 1';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);

var_name = 'ldr_snr';
long_name = 'signal to noise ratio of linear depolarization ratio';
units = 'unitless';
dims = {'range','time'};
anc.vars.(var_name) = default_var_def(mplps.ldr_snr, long_name, units, dims);

var_name = 'd_element';
long_name = 'depolarization element from Mueller matrix';
units = 'unitless';
dims = {'range','time'};
anc.vars.(var_name) = default_var_def(mplps.d, long_name, units, dims);
att_name = 'equation'; att_val = 'd = 2*ldr/(1+ldr)';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
att_name = 'comment_1'; att_val = 'No depolarization = 0';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
att_name = 'comment_2';att_val = 'Full depolarization = 1';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);

var_name = 'scene_variability';
long_name = 'relative scene variability during averaging interval';
units = 'unitless';
dims = {'range','time'};
anc.vars.(var_name) = default_var_def(mplps.scene_variability, long_name, units, dims);
att_name = 'Interpretation';
att_val = 'Stable conditions yield values near or below one.';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
att_name = 'Determination'; att_val = 'Determined by comparing expected and observed deviation in copol signal.';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);
att_name = 'Equation';
att_val = 'variability = (observed standard of deviation in sub-samples)/(expected Possion statistics) - 1';
anc.vars.(var_name).atts.(att_name) = define_att(att_val);

anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);

% 
% varname = 'crosspol_variability';
% long_name = 'crosspol relative variability';
% units = 'unitless';
% dims = {'range','time'};
% anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);
% att_name = 'equation'; 
% att_val = 'copol_variability = (copol_stddev / copol_noise) - 1';
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% att_name = 'comment_1'; att_val = 'Determined by comparing expected and observed deviation in copol signal.';
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% att_name = 'comment_2';att_val = 'Stable conditions yield values near zero.';
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% 
% anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);

% var_name = 'scene_variability';
% long_name = 'scene relative variability';
% units = 'unitless';
% dims = {'range','time'};
% anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% att_name = 'Explanation';
% att_val = 'Stable conditions yield values near zero.';
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% att_name = 'Definition'; att_val = 'Taken to be the maximum variability observed for either copol or crosspol signals.';
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% att_name = 'Variability_computation';
% att_val = 'variability = (observed standard of deviation in sub-samples)/(expected Possion statistics) - 1';
% anc.vars.(var_name).atts.(att_name) = define_att(att_val);
% 
% anc.vars.(var_name).atts = init_ids(anc.vars.(var_name).atts);
% 

var_name = 'lat';
long_name = 'north latitude';
units = 'degrees';
var_val = 71.322998046875;
dims = {''};
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'lon';
long_name = 'east longitude';
units = 'degrees';
dims = {''};
var_val = -156.608993530273;
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);

var_name = 'alt';
long_name = 'altitude above mean sea level';
units = 'meters above Mean Sea Level';
dims = {''};
var_val = 8;
anc.vars.(var_name) = default_var_def(var_val, long_name, units, dims);
return

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
