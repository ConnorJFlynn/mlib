function status = output_ipasmpl_a0(a1_ncid, mpl_a1_out);
% status = output_ipasmpl_a0(a1_ncid, mpl_a1_out);
% The only difference between ipasmpl_a0 and ipasmpl_a1 is zenith_angle and energy monitor are nan in a0
% and dtc is applied in a1

[status] = nc_putvar(a1_ncid, 'detector_counts', mpl_a1_out.rawcts);
if status<0
   keyboard;
end

% [status] = nc_putvar(a1_ncid, 'statistical_noise', mpl_a1_out.noise);
% if status<0
%    keyboard;
% end
% 
% [status] = nc_putvar(a1_ncid, 'cts_snr', mpl_a1_out.snr);
% if status<0
%    keyboard;
% end

[status] = nc_putvar(a1_ncid, 'background_signal', mpl_a1_out.hk.bg);
if status<0
   keyboard;
end

[status] = nc_putvar(a1_ncid, 'shots_summed', mpl_a1_out.hk.shots_summed);
if status<0
   keyboard;
end

if findstr(upper(mpl_a1_out.statics.ocr),'YES')
    varname = 'filter_temp';
    [status] = nc_putvar(a1_ncid, varname,  NaN(size(mpl_a1_out.time)));
    varname = 'instrument_temp';
    [status] = nc_putvar(a1_ncid, varname,  NaN(size(mpl_a1_out.time)));
    varname = 'laser_temp';
    [status] = nc_putvar(a1_ncid, varname,  NaN(size(mpl_a1_out.time)));
    varname = 'detector_temp';
    [status] = nc_putvar(a1_ncid, varname,  NaN(size(mpl_a1_out.time)));
else
    varname = 'filter_temp';
    [status] = nc_putvar(a1_ncid, varname,  mpl_a1_out.hk.filter_temp);
    varname = 'instrument_temp';
    [status] = nc_putvar(a1_ncid, varname,  mpl_a1_out.hk.instrument_temp);
    varname = 'laser_temp';
    [status] = nc_putvar(a1_ncid, varname,  mpl_a1_out.hk.laser_temp);
    varname = 'detector_temp';
    [status] = nc_putvar(a1_ncid, varname,  mpl_a1_out.hk.detector_temp);
end
varname = 'energy_monitor';
[status] = nc_putvar(a1_ncid, varname,  NaN(size(mpl_a1_out.time)));

varname = 'zenith_angle';
[status] = nc_putvar(a1_ncid, varname,  NaN(size(mpl_a1_out.time)));

epoch = serial2epoch(mpl_a1_out.time);
base_time = min(epoch);
time_offset = epoch - base_time;

[status] = nc_putvar(a1_ncid, 'time_offset',time_offset );
if status<0
   keyboard;
end

epoch_midnight = serial2epoch(floor(mpl_a1_out.time(1)));
time = time_offset + (base_time - epoch_midnight);
[status] = nc_putvar(a1_ncid, 'time', time);
if status<0
   keyboard;
end

[status] = nc_putvar(a1_ncid, 'doy',serial2doy0(mpl_a1_out.time));
if status<0
   keyboard;
end

% [status] = nc_putvar(a1_ncid, 'deadtime_corrected', 1);
% if status<0
%    keyboard;
% end

att_name = 'deadtime_corrected';
if mpl_a1_out.statics.deadtime_corrected == 1
    status = ncmex('REDEF', a1_ncid);
    att_val = 'yes';
    att_datatype = 2; %char=2
    status = ncmex('ATTPUT', a1_ncid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;
    status = ncmex('ENDEF', a1_ncid);
end

end