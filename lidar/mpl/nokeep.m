function nc = nokeep(nc)
fields = fieldnames(nc.vars);
for f = 1:length(fields)
   if strcmp(fields(f),'detector_counts')
      nc.vars.(char(fields(f))).keep = false;
   end
   if strcmp(fields(f),'dtc_MHz')
      nc.vars.(char(fields(f))).keep = false;
   end   
   if strcmp(fields(f),'height')
      nc.vars.(char(fields(f))).keep = false;
   end
   if strcmp(fields(f),'range')
      nc.vars.(char(fields(f))).keep = false;
   end   
end      

%     'base_time'
%     'time_offset'
%     'range_bins'
%     'shots_summed'
%     'pulse_rep'
%     'energy_monitor'
%     'detector_temp'
%     'filter_temp'
%     'instrument_temp'
%     'laser_temp'
%     'voltage_05'
%     'voltage_10'
%     'voltage_15'
%     'preliminary_cbh'
%     'background_signal'
%     'range_bin_time'
%     'range_bin_width'
%     'max_altitude'
%     'detector_counts'
%     'dtc_MHz'
%     'range_offset'
%     'range'
%     'height'
%     'lat'
%     'lon'
%     'alt'
%     'time'
%     'dtc_bg'