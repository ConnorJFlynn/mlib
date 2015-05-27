function aos_mon = add_ccn(aos_mon);
% aos_mon = add_ccn(aos_mon);
% The bulk of this copied from grid_aos.
ccn = loadinto('C:\case_studies\dust\nimaosM1.noaa\nim_ccn.mat');
   inds = interp1(ccn.time, [1:length(ccn.time)],aos_mon.time, 'nearest');
%    if isfield(aos_mon,'fname')
%       aos_mon = rmfield(aos_mon,'fname');
%    end
   if isfield(aos_mon,'station')
      aos_mon = rmfield(aos_mon,'station');
   end
   %had been commented from here ...
   if isfield(aos_mon,'CN_contr_1um')
      aos_mon = rmfield(aos_mon,'CN_contr_1um');
   end
   if isfield(aos_mon,'CN_contr_10um')
      aos_mon = rmfield(aos_mon,'CN_contr_10um');
   end
   if isfield(aos_mon,'CN_amb_1um')
      aos_mon = rmfield(aos_mon,'CN_amb_1um');
   end
   if isfield(aos_mon,'CN_amb_10um')
      aos_mon = rmfield(aos_mon,'CN_amb_10um');
   end
   aos_mon.ccn_corr = ccn.ccn_corr(inds);
   aos_mon.cpc_corr = ccn.cpc_corr(inds);
   aos_mon.SS_pct = ccn.SS_pct(inds);
   miss = (aos_mon.ccn_corr<0);
   aos_mon.ccn_corr(miss) = NaN;
miss = (aos_mon.cpc_corr<0);
   aos_mon.cpc_corr(miss) = NaN;
miss = (aos_mon.SS_pct<.1);
   aos_mon.SS_pct(miss) = NaN;
         
% to here...
   if isfield(aos_mon,'hex_flags');
      aos_mon = rmfield(aos_mon,'hex_flags');
   end

