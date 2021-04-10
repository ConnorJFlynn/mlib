function [polavg,ind] = proc_mplpolfsb1_4(nc_mplpol,inarg)
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
   [polavg,ind] = proc_mplpolfsraw_4(mplpol,inarg);
else
   polavg = [];
   ind = [];
end
return

function mplpol = anc_2mplpol(anc);
mplpol.time = anc.time;
mplpol.range = anc.vdata.range;
try
   max_alt = (3e5./2)./anc.vdata.pulse_rep;% speed of light in km/s divided by 2, divided by pulse_rep
   mplpol.max_alt = max_alt;
catch
   disp('No pulse rep in file. Now what?');
end
[~,ds] = fileparts(anc.fname);  [ds_,ds] = strtok(ds,'.');ds_ = [ds_,'.',strtok(ds,'.')];
pos_range = mod(mplpol.range,max_alt);
r.lte_5 = pos_range>=0 & pos_range<=5;
r.lte_10 = pos_range>=0 & pos_range<=10;
r.lte_15 = pos_range>=0 & pos_range<=15;
r.lte_20 = pos_range>=0 & pos_range<=20;
r.lte_25 = pos_range>=0 & pos_range<=25;
r.lte_30 = pos_range>=0 & pos_range<=30;
% r.lte_5 = mplpol.range>=0 & mplpol.range<=5;
% r.lte_10 = mplpol.range>=0 & mplpol.range<=10;
% r.lte_15 = mplpol.range>=0 & mplpol.range<=15;
% r.lte_20 = mplpol.range>=0 & mplpol.range<=20;
% r.lte_25 = mplpol.range>=0 & mplpol.range<=25;
% r.lte_30 = mplpol.range>=0 & mplpol.range<=30;
mplpol.r = r;

statics.range_bin_time =double(round(anc.vdata.range_bin_width(1)./1.5e-4));
statics.fname = anc.fname; statics.max_alt = max_alt;
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
if isfield(anc.vdata,'preliminary_cbh')
   hk.preliminary_cbh = anc.vdata.preliminary_cbh;
else
   hk.preliminary_cbh = NaN(size(anc.time));
end
hk.energy_monitor=anc.vdata.energy_monitor;
mplpol.hk = hk;

mplpol.rawcts_copol = anc.vdata.signal_return_co_pol;
mplpol.rawcts_crosspol = anc.vdata.signal_return_cross_pol;
if isfield(anc.vdata, 'overlap_correction')
   mplpol.ol.ol_range = anc.vdata.overlap_correction_heights./2; % b1 file has wrong range 
   mplpol.ol.ol_corr = anc.vdata.overlap_correction;
   mplpol.r.ol_corr = ones(size(mplpol.range));
   ol_range = mplpol.range>=min(mplpol.ol.ol_range) & mplpol.range<=max(mplpol.ol.ol_range);
   mplpol.r.ol_corr(ol_range) = interp1(mplpol.ol.ol_range, mplpol.ol.ol_corr, mplpol.range(ol_range), 'pchip');
   figure; plot(mplpol.range(ol_range), 1./mplpol.r.ol_corr(ol_range),'o'); 
   legend('Overlap'); xlabel('range [km]');
    title({['Overlap corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
end
if isfield(anc.vdata ,'afterpulse_correction_height');  
   mplpol.ap.range = anc.vdata.afterpulse_correction_height;
   %slight shift of range based on observation at ASI.  Not sure it's
   %needed/correct everywhere
   mplpol.ap.range = mplpol.ap.range - (mplpol.ap.range(2)-mplpol.ap.range(1));
   pos_range = mod(mplpol.range,mplpol.statics.max_alt);
   mplpol.ap.copol = anc.vdata.afterpulse_correction_co_pol;
   mplpol.ap.crosspol = anc.vdata.afterpulse_correction_cross_pol;
   
   fit_range = mplpol.ap.range>=3&mplpol.ap.range<=10;
   lte_fit = pos_range>0 & pos_range<=3;
   x_range = pos_range>1&pos_range<max_alt;

   log_r = log10(mplpol.ap.range(fit_range)); 
   log_cop = log10(mplpol.ap.copol(fit_range));
   log_crs = log10(mplpol.ap.crosspol(fit_range));
   [P,S] = polyfit(log_r, log_cop,1); 
   cop_fit = 10.^(polyval(P,log10(pos_range),S));
   [Px,Sx] = polyfit(log_r, log_crs,1); 
   crs_fit = 10.^(polyval(Px,log10(pos_range),Sx));
   
   mplpol.r.ap_copol = cop_fit;
   mplpol.r.ap_copol(lte_fit) = interp1(mplpol.ap.range, mplpol.ap.copol,pos_range(lte_fit),'linear'); 
%    mplpol.r.ap_copol(lte1) = mplpol.ap.copol(mplpol.ap.range>0&mplpol.ap.range<=1); 
   
   mplpol.r.ap_crosspol = crs_fit;
   mplpol.r.ap_crosspol(lte_fit) = interp1(mplpol.ap.range, mplpol.ap.crosspol,pos_range(lte_fit),'linear');
%    mplpol.r.ap_crosspol(lte1) = mplpol.ap.crosspol(mplpol.ap.range>0&mplpol.ap.range<=1); 
   
   figure; plot(mplpol.ap.range, mplpol.ap.copol,'o',mplpol.range, mplpol.r.ap_copol,'r-',...
      mplpol.ap.range, mplpol.ap.crosspol,'o',mplpol.range, mplpol.r.ap_crosspol,'k-'); logy; 
   legend('ap copol','ap copol fit','ap crspol','ap crspol fit'); xlabel('range [km]');
   title({['Afterpulse corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
 end
if isfield(anc.vdata, 'deadtime_correction');
   mplpol.dtc.MHz = anc.vdata.deadtime_correction_counts;
   mplpol.dtc.correction = anc.vdata.deadtime_correction;
   maxd = max(max(mplpol.rawcts_copol));
   figure; xx(1) = subplot(2,1,1);
   plot(mplpol.dtc.MHz, mplpol.dtc.correction, '-o',...
      [mplpol.dtc.MHz;maxd],interp1(mplpol.dtc.MHz,(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-kx',...
      [mplpol.dtc.MHz;maxd],10.^interp1(mplpol.dtc.MHz,log10(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-ro');
   liny;
   legend('Vendor table','linear interp','log interp','Location','NorthWest');
   title({['Detector deadtime corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
   xx(2) = subplot(2,1,2);
   plot(mplpol.dtc.MHz, mplpol.dtc.correction, '-o',...
      [mplpol.dtc.MHz;maxd],interp1(mplpol.dtc.MHz,(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-kx',...
      [mplpol.dtc.MHz;maxd],10.^interp1(mplpol.dtc.MHz,log10(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-ro');
   logy;
 linkaxes(xx,'x');
end
return

% Depcrecated, not used
function mplpol = anc2mplpol(anc);
mplpol.time = anc.time;
if isfield(anc.vars, 'range')&&isfield(anc.vars,'signal_return_co_pol')
   mplpol.range = anc.vars.range.data;
   statics.range_bin_time =double(round(anc.vars.range_bin_width.data(1)./1.5e-4));
   statics.unitSN = anc.atts.serial_number.data;
   statics.datastream = anc.atts.zeb_platform.data;
   hk.instrument_temp = anc.vars.scope_temp.data ;
   hk.laser_temp = anc.vars.laser_temp.data;
   hk.detector_temp = anc.vars.detector_temp.data;
   hk.pulse_rep = anc.vars.pulse_rep.data.*ones(size(hk.detector_temp));
   hk.shots_summed =anc.vars.shots_per_avg.data.*ones(size(hk.detector_temp));
   hk.pol_V1 = anc.vars.polarization_control_voltage.data;
   hk.preliminary_cbh = anc.vars.preliminary_cbh.data;
   hk.energy_monitor=anc.vars.energy_monitor.data;
   mplpol.rawcts_copol = anc.vars.signal_return_co_pol.data;
   mplpol.rawcts_crosspol = anc.vars.signal_return_cross_pol.data;
elseif isfield(anc.vars,'height')&&isfield(anc.vars,'backscatter_1')
   mplpol.range = anc.vars.height.data;
   statics.range_bin_time = (2.*1000*(mplpol.range(2)-mplpol.range(1))/3e8)*1e9;
   statics.unitSN = '';
   statics.datastream = '';
   hk.instrument_temp = anc.vars.temp_telescope.data ;
   hk.laser_temp = anc.vars.temp_laser.data;
   hk.detector_temp = anc.vars.temp_detector.data;
   hk.pulse_rep = double(anc.vars.rep_rate.data);
   hk.shots_summed =double(anc.vars.nshots.data);
   hk.pol_V1 = NaN(size(hk.shots_summed));
   hk.preliminary_cbh = anc.vars.initial_cbh.data;
   hk.energy_monitor=anc.vars.energy.data;
   mplpol.rawcts_copol = anc.vars.backscatter_2.data;
   mplpol.rawcts_crosspol = anc.vars.backscatter_1.data;
end
r.lte_5 = mplpol.range>=0 & mplpol.range<=5;
r.lte_10 = mplpol.range>=0 & mplpol.range<=10;
r.lte_15 = mplpol.range>=0 & mplpol.range<=15;
r.lte_20 = mplpol.range>=0 & mplpol.range<=20;
r.lte_25 = mplpol.range>=0 & mplpol.range<=25;
r.lte_30 = mplpol.range>=0 & mplpol.range<=30;
mplpol.r = r;
statics.fname = anc.fname;
mplpol.statics = statics;
mplpol.hk = hk;

return


% if isfield(nc_mplpol,'fname')&&isfield(nc_mplpol,'atts')&&isfield(nc_mplpol,'recdim')...
%       &&isfield(nc_mplpol,'dims')&&isfield(nc_mplpol,'vars')&&isfield(nc_mplpol,'time')
%    mplpol = anc2mplpol(nc_mplpol);
%    [polavg,ind] = proc_mplpolfsraw_4(mplpol,inarg);
% else
%    polavg = [];
%    ind = [];
% end
