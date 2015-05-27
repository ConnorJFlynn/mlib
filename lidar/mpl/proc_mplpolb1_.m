function [polavg,ind] = proc_mplpolb1_(nc_mplpol,inarg)
%[polavg,ind] = proc_mplpolb1_(nc_mplpol,inarg)
% polavg contains averaged mplpol data
% ind contains index of last used value from mplpol
% mplpol is an ancstruct with mplpol data
% inarg has the following optional elements 
% .outdir 
% .Nsamples
% .ldr_snr
% 2008/05/21 fixed ldr_snr computations

if ~exist('nc_mplpol','var')||isempty(nc_mplpol)
   nc_mplpol = ancload;
   disp('Loaded file');
end
if ~exist('inarg','var');
   inarg = [];
   Nsamples = 8;
   ldr_snr = .25;
else
   if isfield(inarg,'outdir')
      outdir = inarg.outdir;
   else
      outdir = [];
   end
   if isfield(inarg,'Nsamples')
      Nsamples = inarg.Nsamples;
   else
      Nsamples = 8;
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
   [polavg,ind] = proc_mplpolraw_(mplpol,inarg);
else
   polavg = [];
   ind = [];
end
return

function mplpol = anc2mplpol(anc);
mplpol.time = anc.time;
mplpol.range = anc.vars.range.data;

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

mplpol.rawcts = anc.vars.signal_return.data;
