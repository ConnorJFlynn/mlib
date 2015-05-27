function grid_aos
%Then we'll fix each month onto a hard 1 min grid, compute aip, and
%downsample.
ccn = loadinto('C:\case_studies\dust\nimaosM1.noaa\nim_ccn.mat');
mon_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\'];
mon_dir = ['C:\case_studies\dust\nimaosM1.noaa\monthly_mats\aos\'];
grid_m_dir = ['C:\case_studies\dust\nimaosM1.noaa\grid_m\'];
if ~exist(grid_m_dir,'dir')
   mkdir(grid_m_dir);
end

mats = dir([mon_dir, 'aos.*.mat']);
for m = 1:length(mats)
   aos_mon = loadinto([mon_dir, mats(m).name]);
   inds = interp1(ccn.time, [1:length(ccn.time)],aos_mon.time, 'nearest');
   if isfield(aos_mon,'fname')
      aos_mon = rmfield(aos_mon,'fname');
   end
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
   
   save([mon_dir, mats(m).name],'aos_mon');
% to here...
   if isfield(aos_mon,'hex_flags');
      aos_mon = rmfield(aos_mon,'hex_flags');
   end

   fields = fieldnames(aos_mon);

   % Now force onto fixed minute grid...
   aos_grid.time = [aos_mon.time(1):(1/(24*60)):aos_mon.time(end)];
   inds = uint32(interp1(aos_mon.time,[1:length(aos_mon.time)],aos_grid.time,'nearest'));
   for f = 2:length(fields)
      aos_grid.(fields{f}) = aos_mon.(fields{f})(inds);
      aos_grid.(fields{f})(diff2(inds)==0) = NaN;
   end
   save([grid_m_dir, mats(m).name],'aos_grid');
end

