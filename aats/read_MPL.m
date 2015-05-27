function [z,extinction, extinction_uncertainty,time_start,time_end]=read_MPL(pathname,start_prof,end_prof,z_site)

[filename,pathname]=uigetfile([pathname 'MPL\*.*'],'Choose a File', 0, 0);

nc = netcdf(deblank([pathname filename]), 'nowrite');              % Open NetCDF file.
% description = nc.description(:)                      % Global attribute.
% variables = var(nc);                                 % Get variable data.
% for i = 1:length(variables)
%    disp([name(variables{i}) ' =']), disp(' ')
%    disp(variables{i}(:))
% end

nc{'time'}(:);
UT=(nc{'time'}(:)-floor(nc{'time'}(:)))*24;
disp(UT')
% nc{'range'}(:)
% nc{'extinction'}(:)


time_start=UT(start_prof);
time_end=UT(end_prof);
z=nc{'range'}(:)+z_site; %add site altitude
extinction=mean(nc{'extinction'}(start_prof:end_prof,:),1);
extinction_uncertainty=mean(nc{'extinction_uncertainty'}(start_prof:end_prof,:),1);

nc = close(nc);       %Close the file.


