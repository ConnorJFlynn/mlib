% read MPL ALIVE data provided by Connor Flynn

function [z,UT,aot,extinction]=read_MPLARM_ALIVE(pathname,z_site,day,month,year)

% files are named mpl102.ext.20050913.v070226.cdf
filename=['mpl102.ext.' sprintf('%4d',year) sprintf('%02d',month) sprintf('%02d',day) '.v20070305.cdf']
%filename=['mpl102.ext.' sprintf('%4d',year) sprintf('%02d',month) sprintf('%02d',day) '.v20070228.cdf']
%filename=['mpl102.ext.' sprintf('%4d',year) sprintf('%02d',month) sprintf('%02d',day) '.v070226.cdf']
filename=['mpl004.ext.' sprintf('%4d',year) sprintf('%02d',month) sprintf('%02d',day) '.v20090512.cdf']
nc = ancload(deblank([pathname filename]));% Open NetCDF file.

UT=serial2Hh(nc.time(:));
%disp(UT');
z = nc.vars.range.data + z_site;
%disp(z');

extinction=nc.vars.alpha_a_Klett.data';
aot=nc.vars.aod_523nm.data; 

%remove profiles that have only values less or equal 0
extinction(isnan(extinction)) = -9999;
ii=find(all(extinction<=0,2)==1);
extinction(ii,:)=[];
UT(ii)=[];
aot(ii)=[];