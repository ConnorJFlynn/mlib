function [aos, status] = read_aos(ncid);
%function [aos, status] = read_aos(ncid);

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

if any(findstr(static.datastream, 'cmdlaos'))
    %Reading cmdlaos data file
    disp('reading cmdlaos file...');
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_B_1um_RefRH');
    if varid>0
        aos.Bsp_B_1um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_G_1um_RefRH');
    if varid>0
        aos.Bsp_G_1um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_B_10um_RefRH');
    if varid>0
        aos.Bsp_B_10um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_G_10um_RefRH');
    if varid>0
        aos.Bsp_G_10um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_B_1um_WetRH');
    if varid>0
        aos.Bsp_B_1um_WetRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_G_1um_WetRH');
    if varid>0
        aos.Bsp_G_1um_WetRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_B_10um_WetRH');
    if varid>0
        aos.Bsp_B_10um_WetRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bsp_G_10um_WetRH');
    if varid>0
        aos.Bsp_G_10um_WetRH = nc_getvar(ncid, varid);
    end;    
    
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_B_1um_RefRH');
    if varid>0
        aos.Bbsp_B_1um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_G_1um_RefRH');
    if varid>0
        aos.Bbsp_G_1um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_B_10um_RefRH');
    if varid>0
        aos.Bbsp_B_10um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_G_10um_RefRH');
    if varid>0
        aos.Bbsp_G_10um_RefRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_B_1um_WetRH');
    if varid>0
        aos.Bbsp_B_1um_WetRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_G_1um_WetRH');
    if varid>0
        aos.Bbsp_G_1um_WetRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_B_10um_WetRH');
    if varid>0
        aos.Bbsp_B_10um_WetRH = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'Bbsp_G_10um_WetRH');
    if varid>0
        aos.Bbsp_G_10um_WetRH = nc_getvar(ncid, varid);
    end;    

    [varid, rcode] = ncmex('VARID', ncid, 'RH_refNeph');
    if varid>0
        aos.RH_refNeph = nc_getvar(ncid, varid);
    end;
    [varid, rcode] = ncmex('VARID', ncid, 'RH_wetNeph');
    if varid>0
        aos.RH_wetNeph = nc_getvar(ncid, varid);
    end;      
 else
     %Not sure what type of aos file!
disp('Not sure what type of aos netcdf file this is...');
end

base_time = nc_getvar(ncid, 'base_time');
time_offset = nc_getvar(ncid, 'time_offset');
epoch_time = base_time + time_offset;
[time] = epoch2serial(epoch_time);

aos.time = time;
aos.static = static;

status = 1;
