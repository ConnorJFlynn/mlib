function mfr = anc2mfr(anc_mfr);
% mfr = anc2mfr(anc_mfr);
% Accepts an anc_mfr struct from an ARM netcdf file and converts to
% more terse mfr representation.  Attempts to determine format of
% input file in order to accept a variety of data levels
%
%     $Revision :$      % delete the space before the :
%     $Date :$          % delete the space before the :

%-------------------------------------------------------------------
% VERSION INFORMATION:
%
%   $RCSfile :$         % delete the space before the :
%   $Revision :$        % delete the space before the :
%   $Date :$            % delete the space before the :
%
%   $Log :$             % delete the space before the :
%
%-------------------------------------------------------------------


mfr.statics.fname = anc_mfr.fname;
if isfield(mfr.statics, 'header')
   mfr.statics.header = anc_mfr.header;
end
mfr.statics.lat = anc_mfr.vars.lat.data;
mfr.statics.lon = anc_mfr.vars.lon.data;
mfr.time = anc_mfr.time;
mfr.hk.V = anc_mfr.vars.logger_volt.data;
mfr.hk.T = anc_mfr.vars.logger_temp.data;

% if findstr(anc_mfr.atts.proc_level.data, 'a0') %Then we need sunae
[mfr.hk.sza, mfr.hk.saa, mfr.hk.r_au, mfr.hk.ha, mfr.hk.da, mfr.hk.sea, mfr.hk.airmass] = sunae(anc_mfr.vars.lat.data, anc_mfr.vars.lon.data, anc_mfr.time);
% mfr.hk.saa = anc_mfr.vars.solar_azimuth.data = data(:,place);
% mfr.hk.sea = anc_mfr.vars.solar_elevation.data = data(:,place);
% mfr.hk.sza = anc_mfr.vars.solar_zenith.data = data(:,place);
% mfr.hk.ha = anc_mfr.vars.hour_angle.data = data(:,place);
% mfr.hk.da = anc_mfr.vars.declination.data = data(:,place);
% mfr.hk.airmass = anc_mfr.vars.airmass.data = data(:,place);
% mfr.hk.r_au = anc_mfr.vars.solar_dist_au.data = data(:,place);
% mfr.hk.solar_time = anc_mfr.vars.solar_time.data = data(:,place);

   mfr.th_ch1 = anc_mfr.vars.hemisp_broadband.data;
   mfr.dif_ch1 = anc_mfr.vars.diffuse_hemisp_broadband.data;
   mfr.dirhor_ch1 = anc_mfr.vars.direct_horizontal_broadband;
for ch = 2:7
   mfr.(['th_ch',num2str(ch)]) = anc_mfr.vars.(['hemisp_narrowband_filter',num2str(ch-1)]).data;
   mfr.(['dif_ch',num2str(ch)]) = anc_mfr.vars.(['diffuse_hemisp_narrowband_filter',num2str(ch-1)]).data;
   mfr.(['dirhor_ch',num2str(ch)]) = anc_mfr.vars.(['direct_horizontal_narrowband_filter',num2str(ch-1)]).data;
end
% elseif findstr(anc_mfr.atts.proc_level.data, 'a1') 
   