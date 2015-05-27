function [mfrod, status] = read_mfrod(ncid);
%function [mfrod, status] = read_mfrod(ncid);

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

if any(findstr(static.datastream, 'mfrsrod'))
    %Reading mfrsrod data file
    disp('reading mfrsrod file...');
    [varid, rcode] = ncmex('VARID', ncid, 'aerosol_optical_depth_filter2');
    if varid>0
        mfrod.aod_500 = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'angstrom_exponent');
    if varid>0
        mfrod.angstrom = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'optical_depth_stability_flag');
    if varid>0
        mfrod.stable_flag = nc_getvar(ncid, varid);
    end;    
elseif any(findstr(static.datastream, 'nimfrod'))
        %Reading nimfrod data file
    disp('reading nimfrod file...');
    [varid, rcode] = ncmex('VARID', ncid, 'aerosol_optical_depth_filter2');
    if varid>0
        mfrod.aod_500 = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'angstrom_exponent');
    if varid>0
        mfrod.angstrom = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'optical_depth_stability_flag');
    if varid>0
        mfrod.stable_flag = nc_getvar(ncid, varid);
    end;
 else
     %Not sure what type of file!
disp('Not sure what type of netcdf file this is...');
end

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);

mfrod.time = time;
mfrod.static = static;

status = 1;
