function [twr, status] = read_twrmr(ncid);
%function [twr, status] = read_twrmr(ncid);

[ndims, nvars, natts, recdim, status] = ncmex('INQUIRE', ncid);
for i = 1:natts
    temp = ncmex('ATTNAME', ncid, 'nc_global', i-1);
    attname{i} = temp;
    if any(findstr(temp,'eb_platform'))
        [value] = ncmex('ATTGET', ncid, 'nc_global', temp);
        if ischar(value)
            static.datastream = value;
        end
    end    
end;

if any(findstr(static.datastream, 'twrmr'))
    %Reading twr mr data file
    disp('reading twr mr file...');
    [varid, rcode] = ncmex('VARID', ncid, 'temp_02m');
    if varid>0
        twr.temp_02m = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'temp_25m');
    if varid>0
        twr.temp_25m = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'temp_60m');
    if varid>0
        twr.temp_60m = nc_getvar(ncid, varid);
    end;

    [varid, rcode] = ncmex('VARID', ncid, 'pres_02m');
    if varid>0
        twr.pres_02m = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'pres_25m');
    if varid>0
        twr.pres_25m = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'pres_60m');
    if varid>0
        twr.pres_60m = nc_getvar(ncid, varid);
    end;
    
    [varid, rcode] = ncmex('VARID', ncid, 'rh_02m');
    if varid>0
        twr.rh_02m = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'rh_25m');
    if varid>0
        twr.rh_25m = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'rh_60m');
    if varid>0
        twr.rh_60m = nc_getvar(ncid, varid);
    end;    
 else
     %Not sure what type of file!
disp('Not sure what type of netcdf file this is...');
end

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);

twr.time = time;
twr.static = static;

status = 1;
