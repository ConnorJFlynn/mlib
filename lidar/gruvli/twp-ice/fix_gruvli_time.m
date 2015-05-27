function status = fix_gruvli_time(full_name);
if ~exist('full_name', 'var');
    [fname, pname] = uigetfile;
    full_name = [pname, fname];
end
ncid = ncmex('open', full_name, 'write');
time_var = nc_getvar(ncid, 'time');
status = nc_putvar(ncid, 'time_offset', time_var);
status = ncmex('ATTCOPY', ncid, 'time', 'units', ncid, 'time_offset');
status = ncmex('close', ncid)
