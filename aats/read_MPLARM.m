function [z,UT,aot,extinction]=read_MPLARM(pathname,z_site)

[filename,pathname]=uigetfile([pathname 'MPLARM\Dec05_2004\*.*'],'Choose a File');

nc = netcdf(deblank([pathname filename]), 'nowrite');              % Open NetCDF file.
description = nc.description(:)                      % Global attribute.
variables = var(nc);                                 % Get variable data.
for i = 1:length(variables)
    disp([name(variables{i}) ' =']), disp(' ')
    %disp(variables{i}(:))
end

nc{'time'}(:);
UT=(nc{'time'}(:))/60/60;
%disp(UT');

z=nc{'range'}(:)+z_site; %add site altitude
%disp(z');

extinction=nc{'alpha_a_Klett'}(:);
aot=nc{'aot_523nm'}(:);

%remove profiles that have only values less or equal 0
ii=find(all(extinction<=0,2)==1);
extinction(ii,:)=[];
UT(ii)=[];
aot(ii)=[];

nc = close(nc);       %Close the file.