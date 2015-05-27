function [sonde, status] = read_sonde(ncid);
%function [sonde, status] = read_sonde(ncid);

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

if any(findstr(static.datastream, 'lssonde'))
    %Reading lssonde data file
    disp('reading lssonde file...');
    [varid, rcode] = ncmex('VARID', ncid, 'alt');
    if varid>0
        sonde.alt = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'tdry');
    if varid>0
        sonde.tdry = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'pres');
    if varid>0
        sonde.pres = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'rh');
    if varid>0
        sonde.rh = nc_getvar(ncid, varid);
    end;
    
elseif any(findstr(static.datastream, 'sondewnpn'))
    %Reading sonde_wnpn data file
    disp('reading sondewnpn file...');
    [varid, rcode] = ncmex('VARID', ncid, 'alt');
    if varid>0
        sonde.alt = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'tdry');
    if varid>0
        sonde.tdry = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'pres');
    if varid>0
        sonde.pres = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'rh');
    if varid>0
        sonde.rh = nc_getvar(ncid, varid);
    end;
 else
     %Not sure what type of mpl file!
disp('Not sure what type of mpl netcdf file this is...');
end

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);

sonde.time = time;
sonde.static = static;

status = 1;
