
function nc_file = write_mplpolfs_flynn(mplps, pname);
% nc_file = write_mplps(mplps, pname);
% provided with a complete mplps structure, writes it to netcdf in pname
% 2023-08-15: cjf, added deadtime correction attribute and fields
year = str2num(datestr(mplps.time(1), 10));
epoch = serial2epoch(mplps.time);
julian_day = floor(serial2doy1(mplps.time(1)));

base_time = min(epoch);
base_time_str = [datestr(min(mplps.time),31) ' GMT'];
base_time_long_name = 'Base time in Epoch';
base_time_units = 'seconds since 1970-1-1 0:00:00 0:00';

time_offset = epoch - base_time;
time_offset_long_name = ['Time offset from base_time'];
time_offset_units = ['seconds since ' base_time_str] ;

%time is seconds since midnight of the day of the first record
time = (serial2doy1(mplps.time) - julian_day) * (24*60*60);
time_long_name  = 'Time offset from midnight';
time_units = ['seconds since ' datestr(floor(mplps.time(1)),31) ' GMT' ];

julian_day_long_name = 'Day of year'; 
julian_day_units = ['days since ' datestr(datenum(year,1,1),31) ' UTC inclusive'];
julian_day_comment = ['For example: Jan 1 6:00 AM = 1.25'];      
%      !!

%Create and define the outgoing netcdf file...
%construct outgoing filename
ds_name_stem = strtok(mplps.statics.datastream, '.');
begin_date = floor(mplps.time(1));
begin_datestr = [datestr(begin_date,10), datestr(begin_date,5), datestr(begin_date,7)];
ds_name = [ds_name_stem, '.c1.', begin_datestr, '.000000.cdf'];

n_str = ''; n = 0;
while isafile([pname, mplps.fname,n_str,'.nc'])
  n = n +1; n_str = ['.',num2str(n)];
end
nc_file = [pname, mplps.fname,n_str,'.nc'];
ncid = netcdf.create([pname, mplps.fname,n_str,'.nc'],'NETCDF4');
% netcdf.endDef(ncid)

unlim_id = netcdf.defDim(ncid,'time',0);
rng_id = netcdf.defDim(ncid, 'range', length(mplps.range(mplps.r.lte_20)));
dtc_id = netcdf.defDim(ncid,'dtc_MHz', length(mplps.dtc.MHz));

att_name = 'proc_level';
att_val = 'c1';
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'input_source';
att_val = [mplps.statics.datastream];
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'site_id';
att_val = 'mar';
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'facility_id';
att_val = 'M1 : MARCUS ARM Mobile Facility';
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'proc_level';
att_val = 'c1';
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'MPL Data PI';
att_val = ['Connor J. Flynn Connor.J.Flynn@ou.edu 509-554-7791'];
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'time_offset_description';
att_val = 'The time is referenced to the middle of each averaging interval.';
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'serial_number';
att_val = [num2str(mplps.statics.unitSN)];
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'dtc_lin_fraction';
att_val = [num2str(mplps.dtc.lin_frac)];
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

att_name = 'history';
att_val = ['Created by CJF on ', datestr(now)];
netcdf.putAtt(ncid, netcdf.getConstant('GLOBAL'), att_name, att_val) ;

varname = 'base_time';
datatype = 4; dim_ids = [];
varid = netcdf.defVar(ncid, varname, datatype, dim_ids);   
netcdf.putAtt(ncid, varid,'string', base_time_str);
netcdf.putAtt(ncid, varid,'long_name', base_time_long_name);
netcdf.putAtt(ncid, varid, 'units', base_time_units);

varname = 'time_offset';
datatype = 6;  dim_ids = [0];
varid = netcdf.defVar(ncid, varname, datatype, dim_ids);   
netcdf.putAtt(ncid, varid,'long_name', time_offset_long_name);
netcdf.putAtt(ncid, varid, 'units', time_offset_units);

time_id = netcdf.defVar(ncid, 'time', datatype, dim_ids);   
netcdf.putAtt(ncid, time_id,'long_name', 'time in seconds since midnight');
netcdf.putAtt(ncid, time_id, 'units',  time_units);

% jd_id = netcdf.defVar(ncid, 'julian_day', datatype, dim_ids);
% netcdf.putAtt(ncid, jd_id,'long_name', julian_day_long_name);
% netcdf.putAtt(ncid, jd_id, 'units', julian_day_units);
% netcdf.putAtt(ncid, jd_id, 'comment', julian_day_comment);

datatype = 5;
varname = 'range';
varid = netcdf.defVar(ncid, varname, datatype, rng_id);
att_val = 'height above ground level to the center of the bin';
netcdf.putAtt(ncid, varid, 'long_name',  att_val);
att_val = 'km';
netcdf.putAtt(ncid, varid, 'units', att_val);

datatype = 5;
varname = 'dtc_cts';
varid = netcdf.defVar(ncid, varname, datatype, dtc_id);
att_val = 'raw cts for deadtime correction table';
netcdf.putAtt(ncid, varid, 'long_name',  att_val);
att_val = 'MHz';
netcdf.putAtt(ncid, varid, 'units', att_val);

datatype = 5;
varname = 'dtc_factor';
varid = netcdf.defVar(ncid, varname, datatype, dtc_id);
att_val = 'dead-time correction factor';
netcdf.putAtt(ncid, varid, 'long_name',  att_val);
att_val = 1;
netcdf.putAtt(ncid, varid, 'units', att_val);

varname = 'attn_bscat';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'combined range-corrected backscatter components';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'cts/(us-km^2)';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;
att_val = 'equivalent to MPLnet NRB';
netcdf.putAtt(ncid, varid, 'comment',  att_val) ;

varname = 'ldr';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'linear depolarization ratio';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'unitless';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;
att_val = 'No depolarization = 0';
netcdf.putAtt(ncid, varid, 'comment_1',  att_val) ;
att_val = 'Full depolarization = 1';
netcdf.putAtt(ncid, varid, 'comment_2',  att_val) ;

varname = 'attn_bscat_SNR';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'attenuated profile Signal to Noise Ratio';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'cts/(us-km^2)';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'ldr_SNR';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'LDR Signal to Noise Ratio';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'unitless';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'copol';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'copol NRB';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'cts/(us-km^2)';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'crosspol';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'crosspol NRB';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'cts/(us-km^2)';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'copol_SNR';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'copol Signal to Noise Ratio';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'unitless';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'crosspol_SNR';
varid = netcdf.defVar(ncid, varname, datatype, [1 0]);
att_val = 'crosspol Signal to Noise Ratio';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'unitless';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'copol_bg';
varid = netcdf.defVar(ncid, varname, datatype, 0);
att_val = 'sky background in copol channel';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'counts per microsecond';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'crosspol_bg';
varid = netcdf.defVar(ncid, varname, datatype, [0]);
att_val = 'background in crosspol channel';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'counts per microsecond';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'energy_monitor';
varid = netcdf.defVar(ncid, varname, datatype, 0);
att_val = 'average laser pulse energy';
netcdf.putAtt(ncid, varid, 'long_name', att_val) ;
att_val = 'microjoules';
netcdf.putAtt(ncid, varid, 'units', att_val) ;

varname = 'overlap_corr';
varid = netcdf.defVar(ncid, varname, datatype, rng_id);
att_val = 'near-range overlap correction factor';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'unitless';
netcdf.putAtt(ncid, varid, 'units', att_val) ;
att_val = 'applied to remove near-field instrument artifact';
netcdf.putAtt(ncid, varid, 'utility', att_val) ;
% att_val = 'derived from vertical data on 2003-11-19 by CJF';
% status = netcdf.putAtt(ncid, varnid, 'source',  att_val) ;

varname = 'copol_afterpulse';
varid = netcdf.defVar(ncid, varname, datatype, 1);
att_val = 'afterpulse subtracted from copol channel';
 netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'cts/usec';
 netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'crosspol_afterpulse';
varid = netcdf.defVar(ncid, varname, datatype, 1);
att_val = 'afterpulse subtracted from crosspol channel';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'cts/usec';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'lat';
varid = netcdf.defVar(ncid, 'lat', datatype, 0);
att_val = 'north latitude';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'degrees';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'lon';
varid = netcdf.defVar(ncid, 'lon', datatype,0);
att_val = 'east longitude';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'degrees';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

varname = 'alt';
varid = netcdf.defVar(ncid, 'alt', datatype, 0);
att_val = 'altitude';
netcdf.putAtt(ncid, varid, 'long_name',  att_val) ;
att_val = 'meters above Mean Sea Level';
netcdf.putAtt(ncid, varid, 'units',  att_val) ;

netcdf.endDef(ncid);

status = 0;
varname = 'base_time'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid,varid , base_time);


varname = 'time_offset'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, 0,length(time_offset),time_offset);


varname = 'time'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, time);


varname = 'range'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.range(mplps.r.lte_20));

varname = 'dtc_cts'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.dtc.MHz);

varname = 'dtc_factor'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.dtc.correction);

varname = 'attn_bscat'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.attn_bscat(mplps.r.lte_20,:));


varname = 'ldr'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.ldr(mplps.r.lte_20,:));


varname = 'attn_bscat_SNR'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.attn_bscat_snr(mplps.r.lte_20,:));


varname = 'ldr_SNR'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.ldr_snr(mplps.r.lte_20,:));


varname = 'copol'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.cop(mplps.r.lte_20,:));


varname = 'crosspol'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.crs(mplps.r.lte_20,:));


varname = 'copol_SNR'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.cop_snr(mplps.r.lte_20,:)); 


varname = 'crosspol_SNR'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.crs_snr(mplps.r.lte_20,:)); 


varname = 'copol_bg'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.hk.cop_bg);


varname = 'crosspol_bg'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.hk.crs_bg);


varname = 'energy_monitor'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.hk.energy_monitor);


varname = 'overlap_corr'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.ol_corr(mplps.r.lte_20));


varname = 'crosspol_afterpulse'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.crs_ap(mplps.r.lte_20));


varname = 'copol_afterpulse'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, mplps.cop_ap(mplps.r.lte_20));


% netcdf.putVar(ncid, 'julian_day',serial2doy0(mplps.time));

varname = 'alt'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, zeros(size(mplps.time)));

varname = 'lon'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, zeros(size(mplps.time)));


varname = 'lat'; varid = netcdf.inqVarID(ncid, varname);
netcdf.putVar(ncid, varid, zeros(size(mplps.time)));


netcdf.close(ncid);
disp(['Saved: ',nc_file])
return