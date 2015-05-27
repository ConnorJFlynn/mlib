function [z,extinction, aod,extinction_uncertainty,time_start,time_end]=read_CARL(pathname,start_prof,end_prof,z_site)

[filename,pathname]=uigetfile([pathname 'RamanLidar\data\*.*'],'Choose a File', 0, 0);

nc = netcdf(deblank([pathname filename]), 'nowrite');              % Open NetCDF file.
description = nc.description(:);                      % Global attribute.
variables = var(nc);                                 % Get variable data.
 for i = 1:length(variables)
    disp([name(variables{i}) ' =']), disp(' ')
%    disp(variables{i}(:))
end

nc{'base_time'}(:);
UT=nc{'time_offset'}(:)/3600;
disp(UT')

time_start=UT(start_prof);
time_end=UT(end_prof);
z=nc{'height'}(:)+z_site; %add site altitude
extinction=mean(nc{'ext'}(start_prof:end_prof,:),1);
extinction_uncertainty=mean(nc{'ext_err'}(start_prof:end_prof,:),1);
aod=mean(nc{'aod_profile'}(start_prof:end_prof,:),1);

nc = close(nc);       %Close the file.