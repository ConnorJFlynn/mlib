% read CARL ALIVE data provided by Rich Ferrare

function [UT,aod,z,aod_profile,aod_err,ext,ext_err,r,p,t,h2o_dens,w_max_height]=read_CARL_ALIVE(pathname,day,month,year)

% files are sgp10rlprofbe1turnC1.c0.20050906.000000.cdf
filename=['sgp10rlprofbe1turnC1.c0.' sprintf('%4d',year) sprintf('%02d',month) sprintf('%02d',day) '.000000.cdf']

nc = ancload([pathname filename]);% Open NetCDF file.

UT = nc.vars.time_offset.data(:)/60/60;
z  = nc.vars.height.data(:) + nc.vars.alt.data(:)/1e3;
aod = nc.vars.aod.data(:);
aod_profile=nc.vars.aod_profile.data';
aod_err = nc.vars.aod.data';
ext=nc.vars.ext.data';
ext_err=nc.vars.ext.data';
r=nc.vars.w.data';
p=nc.vars.p.data';
t=nc.vars.t.data';
w_max_height=nc.vars.w_max_height.data;

%calculate water vapor density (Boegel p 111)
h2o_dens=216.68.*(1+1e-8.*p.*(70-t)).*r.*p./(621.98+r)./(273.15+t);