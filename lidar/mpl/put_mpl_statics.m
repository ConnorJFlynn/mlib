function status = put_mpl_statics(cdfid, time_in, range, statics);

if nargin<4
   statics.deadtime_corrected = 0;
end
[status] = nc_putvar(cdfid, 'range', range);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'base_time', serial2epoch(time_in));
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'range_bin_time', 200);
if status<0
   keyboard;
end

att_name = 'deadtime_corrected';
if statics.deadtime_corrected == 1
att_val = 'yes';
else
   att_val = 'no';
end
att_datatype = 2; %char=2
status = ncmex('ATTPUT', cdfid, 'nc_global', att_name, att_datatype, length(att_val), att_val) ;


[status] = nc_putvar(cdfid, 'lat', 123);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'lon', 123);
if status<0
   keyboard;
end

[status] = nc_putvar(cdfid, 'alt', 123);
if status<0
   keyboard;
end

end