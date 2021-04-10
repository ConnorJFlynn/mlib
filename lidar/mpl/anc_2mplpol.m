function mplpol = anc_2mplpol(anc);
% mplpol = anc_2mplpol
% Converts ARM netcdf MPL file to lidar-specific "mplpol" struct
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
   [mplpol.ol.ol_range,ii] = unique(anc.vdata.overlap_correction_heights); % b1 file has wrong range 
   
   mplpol.ol.ol_corr = anc.vdata.overlap_correction; mplpol.ol.ol_corr = mplpol.ol.ol_corr(ii);
   mplpol.r.ol_corr = ones(size(mplpol.range));
   ol_range = mplpol.range>=min(mplpol.ol.ol_range) & mplpol.range<=max(mplpol.ol.ol_range);
   mplpol.r.ol_corr(ol_range) = interp1(mplpol.ol.ol_range, mplpol.ol.ol_corr, mplpol.range(ol_range), 'pchip');

   % This routine attempts to fit the supplied OL with a combination of
   % analytic functions representing optical overlap corrections.  
   % Seems to do well at very shortest range, but can miss the slope at the
   % top 
   fitted_olc = analytic_ol_uc(mplpol.range(ol_range), 1./mplpol.r.ol_corr(ol_range));
   
   if ~isgraphics(41)
      figure_(41); plot(mplpol.range(ol_range), 1./mplpol.r.ol_corr(ol_range),'o',...
         mplpol.range(ol_range), fitted_olc,'k-' ); 
   legend('Overlap'); xlabel('range [km]');
    title({['Overlap corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
   end

   if ~isgraphics(41)
      figure_(41); plot(mplpol.range(ol_range), 1./mplpol.r.ol_corr(ol_range),'o'); 
   legend('Overlap'); xlabel('range [km]');
    title({['Overlap corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
   end

end
if isfield(anc.vdata ,'afterpulse_correction_height');  
   mplpol.ap.range = anc.vdata.afterpulse_correction_height;
else
   mplpol.ap.range = anc.vdata.range;
end

if isfield(anc.vdata,'afterpulse_correction_co_pol')
   %slight shift of range based on observation at ASI.  Not sure it's
   %needed/correct everywhere
   mplpol.ap.range = mplpol.ap.range - (mplpol.ap.range(2)-mplpol.ap.range(1));
   pos_range = mod(mplpol.range,mplpol.statics.max_alt);
   mplpol.ap.copol = anc.vdata.afterpulse_correction_co_pol;
   mplpol.ap.crosspol = anc.vdata.afterpulse_correction_cross_pol;
   ap_fit.cop = fit_ap(mplpol.ap.range, mplpol.ap.copol);
   ap_fit.crx = fit_ap(mplpol.ap.range, mplpol.ap.crosspol);
    mplpol.r.ap_copol = ap_fit.cop.ap_fit;
    mplpol.r.ap_crosspol = ap_fit.crx.ap_fit;
%    ind = interp1(mod(mplpol.range,max_alt), [1:length(mplpol.range)],ap_fit.cop.range,'nearest');
%    mplpol.r.ap_copol = ap_fit.cop.ap_fit(ind);
%    mplpol.r.ap_crosspol = ap_fit.crx.ap_fit(ind);   
% %    fit_range = mplpol.ap.range>=3&mplpol.ap.range<=10;
% %    lte_fit = pos_range>0 & pos_range<=3;
% %    x_range = pos_range>1&pos_range<max_alt;
% % 
% %    log_r = log10(mplpol.ap.range(fit_range)); 
% %    log_cop = log10(mplpol.ap.copol(fit_range));
% %    log_crs = log10(mplpol.ap.crosspol(fit_range));
% %    [P,S] = polyfit(log_r, log_cop,1); 
% %    cop_fit = 10.^(polyval(P,log10(pos_range),S));
% %    [Px,Sx] = polyfit(log_r, log_crs,1); 
% %    crs_fit = 10.^(polyval(Px,log10(pos_range),Sx)); 
% % 
% 
%    mplpol.r.ap_copol = cop_fit;
%    mplpol.r.ap_copol(lte_fit) = interp1(mplpol.ap.range, mplpol.ap.copol,pos_range(lte_fit),'linear'); 
% %    mplpol.r.ap_copol(lte1) = mplpol.ap.copol(mplpol.ap.range>0&mplpol.ap.range<=1); 
%    
%    mplpol.r.ap_crosspol = crs_fit;
%    mplpol.r.ap_crosspol(lte_fit) = interp1(mplpol.ap.range, mplpol.ap.crosspol,pos_range(lte_fit),'linear');
%    %    mplpol.r.ap_crosspol(lte1) = mplpol.ap.crosspol(mplpol.ap.range>0&mplpol.ap.range<=1);    
   cop_ap_bg = mean(mplpol.r.ap_copol(mplpol.range>45&mplpol.range<50));
   if isNaN(cop_ap_bg)
       cop_ap_bg = meannonan(mplpol.r.ap_copol(mplpol.range<0));
   end
   crs_ap_bg = mean(mplpol.r.ap_crosspol(mplpol.range>45&mplpol.range<50));
   if isNaN(crs_ap_bg)
       crs_ap_bg = meannonan(mplpol.r.ap_crosspol(mplpol.range<0));
   end
if ~isgraphics(42)
   figure_(42); plot(ap_fit.cop.range,ap_fit.cop.ap_fit,'-o',... 
       ap_fit.crx.range,ap_fit.crx.ap_fit,'-x'); legend('ap cop','ap crx');
    xlabel('range [km]');logy; 
   title({['Afterpulse corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
end
end
if isfield(anc.vdata, 'deadtime_correction')
    mplpol.dtc.MHz = anc.vdata.deadtime_correction_counts;
    mplpol.dtc.correction = anc.vdata.deadtime_correction;
   maxd = max(max(mplpol.rawcts_copol)); maxt = max(anc.vdata.deadtime_correction_counts);

   if isavar('MHz')
       mplpol.dtc.MHz = MHz;
       mplpol.dtc.correction = dtc_corr;
   end
   MHz = mplpol.dtc.MHz; dtc_corr = mplpol.dtc.correction;
   
   X_ = mplpol.dtc.MHz;
   logY_ = log10(mplpol.dtc.correction);
   
   [P_,S_,mu_] = polyfit(X_(end-2:end),logY_(end-2:end),2);
   high_end = [max(mplpol.dtc.MHz),maxd];
   high_ends = linspace(high_end(1),high_end(2),10);
   high_dtc = 10.^polyval(P_,high_ends,S_,mu_);
   
   % append fitted value to table  
   mplpol.dtc.MHz = [mplpol.dtc.MHz;high_ends'];
   [mplpol.dtc.MHz,ij] = unique(mplpol.dtc.MHz);
   mplpol.dtc.correction = [mplpol.dtc.correction; high_dtc'];
   mplpol.dtc.correction =mplpol.dtc.correction(ij);
   if ~isgraphics(43)
   figure_(43); 
      plot(anc.vdata.deadtime_correction_counts, anc.vdata.deadtime_correction, '-o',...
       [mplpol.dtc.MHz;maxd],10.^interp1(mplpol.dtc.MHz,log10(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-r');
   logy; xlabel('MHz'); ylabel('dtc factor')
      legend('Vendor table','log interp','Location','NorthWest');
   title(['Deadtime corrections for ',ds_,datestr(anc.time(1),': yyyy-mm-dd')]);
   end
%    xx(1) = subplot(2,1,1);
%    plot(anc.vdata.deadtime_correction_counts, anc.vdata.deadtime_correction, '-o',...
%        [mplpol.dtc.MHz;maxd],10.^interp1(mplpol.dtc.MHz,log10(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-r');
%    liny;
%    legend('Vendor table','log interp','Location','NorthWest');
%    title({['Detector deadtime corrections for ',ds_];[datestr(anc.time(1),'yyyy-mm-dd')]});
%    xx(2) = subplot(2,1,2);
%    plot(anc.vdata.deadtime_correction_counts, anc.vdata.deadtime_correction, '-o',...
%        [mplpol.dtc.MHz;maxd],10.^interp1(mplpol.dtc.MHz,log10(mplpol.dtc.correction),[mplpol.dtc.MHz;maxd],'linear','extrap'),'-r');
%    logy;
%    linkaxes(xx,'x');
end
return

