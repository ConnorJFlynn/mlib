function [sonde] = time4sonde(range_in, time,filename);
%function [sonde] = time4sonde(range_in, filename);
%If need be we can put logic here to find a suitable sonde such that we never return an empty sonde structure
if nargin==1
    disp(['select a sonde file'])
    [fid, fname, pname] = getfile('*.*', 'sonde_data');
    filename = [pname fname];
    fclose(fid);
elseif nargin==2
    disp(['select a sonde file'])
    [fid, fname, pname] = getfile(['*',datestr(time,'yyyymmdd'),'*'], 'sonde_data');
    filename = [pname fname];
    fclose(fid);
end   

ncid = ncmex('open', filename, 'write');
%[sonde.atten_prof,sonde.tau,sonde.maxalt,sonde.temperature,sonde.pressure] = sonde_ray_atten(ncid, range_in);
[sonde.atten_prof,sonde.tau,sonde.maxalt,sonde.temperature,sonde.pressure] = sonde_std_atm_ray_atten(ncid, range_in);




