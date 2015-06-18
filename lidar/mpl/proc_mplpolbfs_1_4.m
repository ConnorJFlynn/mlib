function [polavg,ind] = proc_mplpolb_1_4(nc_mplpol,inarg)
%[polavg,ind] = proc_mplpolb1_4(nc_mplpol,inarg)
% polavg contains averaged mplpol data
% ind contains index of last used value from mplpol
% mplpol is an ancstruct with mplpol data
% inarg has the following optional elements 
% .outdir 
% .Nsecs
% .ldr_snr
% 2008/05/21 fixed ldr_snr computations

if ~exist('nc_mplpol','var')||isempty(nc_mplpol)
   nc_mplpol = anc_load;
   disp('Loaded file');
end
if ~exist('inarg','var');
   inarg = [];
   Nsecs = 120;
   ldr_snr = .25;
else
   if isfield(inarg,'out_dir')
      outdir = inarg.out_dir;
   else
      outdir = [];
   end
   if isfield(inarg,'Nsecs')
      Nsecs = inarg.Nsecs;
   else
      Nsecs = 60;
   end
   if isfield(inarg,'ldr_snr')
      ldr_snr = inarg.ldr_snr;
   else
      ldr_snr = .25;
   end
end
%%
if isfield(nc_mplpol,'fname')&&isfield(nc_mplpol,'atts')&&isfield(nc_mplpol,'recdim')...
      &&isfield(nc_mplpol,'dims')&&isfield(nc_mplpol,'vars')&&isfield(nc_mplpol,'time')
   mplpol = anc2mplpol(nc_mplpol);
   [polavg,ind] = proc_mplpolraw_4(mplpol,inarg);
elseif isfield(nc_mplpol,'fname')&&isfield(nc_mplpol,'gatts')&&isfield(nc_mplpol,'ncdef')...
      &&isfield(nc_mplpol,'time')
   mplpol = anc_2mplpol(nc_mplpol);
   [polavg,ind] = proc_mplpolraw_4(mplpol,inarg);
else
   polavg = [];
   ind = [];
end
return

function mplpol = anc2mplpol(anc);
mplpol.time = anc.time;
mplpol.range = anc.vars.range.data;
r.lte_5 = mplpol.range>=0 & mplpol.range<=5;
r.lte_10 = mplpol.range>=0 & mplpol.range<=10;
r.lte_15 = mplpol.range>=0 & mplpol.range<=15;
r.lte_20 = mplpol.range>=0 & mplpol.range<=20;
r.lte_25 = mplpol.range>=0 & mplpol.range<=25;
r.lte_30 = mplpol.range>=0 & mplpol.range<=30;
mplpol.r = r;

statics.range_bin_time =double(round(anc.vars.range_bin_width.data(1)./1.5e-4)); 
statics.fname = anc.fname;
statics.unitSN = anc.atts.serial_number.data;
statics.datastream = anc.atts.zeb_platform.data;
mplpol.statics = statics;

hk.instrument_temp = anc.vars.scope_temp.data ;
hk.laser_temp = anc.vars.laser_temp.data;
hk.detector_temp = anc.vars.detector_temp.data;
hk.pulse_rep = anc.vars.pulse_rep.data.*ones(size(hk.detector_temp));
hk.shots_summed =anc.vars.shots_per_avg.data.*ones(size(hk.detector_temp));
hk.pol_V1 = anc.vars.polarization_control_voltage.data;
hk.preliminary_cbh = anc.vars.preliminary_cbh.data;
hk.energy_monitor=anc.vars.energy_monitor.data;
mplpol.hk = hk;

mplpol.rawcts_copol = anc.vars.signal_return_co_pol.data;
mplpol.rawcts_crosspol = anc.vars.signal_return_cross_pol.data;

return

function mplpol = anc_2mplpol(anc);
mplpol.time = anc.time;
mplpol.range = anc.vdata.range;
r.lte_5 = mplpol.range>=0 & mplpol.range<=5;
r.lte_10 = mplpol.range>=0 & mplpol.range<=10;
r.lte_15 = mplpol.range>=0 & mplpol.range<=15;
r.lte_20 = mplpol.range>=0 & mplpol.range<=20;
r.lte_25 = mplpol.range>=0 & mplpol.range<=25;
r.lte_30 = mplpol.range>=0 & mplpol.range<=30;
mplpol.r = r;

statics.range_bin_time =double(round(anc.vdata.range_bin_width(1)./1.5e-4)); 
statics.fname = anc.fname;
statics.unitSN = anc.gatts.serial_number;
if isfield(anc.gatts,'datastream')
statics.datastream = anc.gatts.datastream;
elseif isfield(anc.gatts,'zeb_platform')
   statics.datastream = anc.gatts.zeb_platform;
else
   statics.datastream = [];
end
mplpol.statics = statics;

hk.instrument_temp = anc.vdata.scope_temp ;
hk.laser_temp = anc.vdata.laser_temp;
hk.detector_temp = anc.vdata.detector_temp;
hk.pulse_rep = anc.vdata.pulse_rep.*ones(size(hk.detector_temp));
hk.shots_summed =anc.vdata.shots_per_avg.*ones(size(hk.detector_temp));
hk.pol_V1 = anc.vdata.polarization_control_voltage;
hk.preliminary_cbh = anc.vdata.preliminary_cbh;
hk.energy_monitor=anc.vdata.energy_monitor;
mplpol.hk = hk;

mplpol.rawcts_copol = anc.vdata.signal_return_co_pol;
mplpol.rawcts_crosspol = anc.vdata.signal_return_cross_pol;

return