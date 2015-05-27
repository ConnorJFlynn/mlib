function aos_1min = grid_aos_1min(aos_mon)
   if isfield(aos_mon,'fname')
      aos_mon = rmfield(aos_mon,'fname');
   end
   if isfield(aos_mon,'station')
      aos_mon = rmfield(aos_mon,'station');
   end
   if isfield(aos_mon,'hex_flags');
      aos_mon = rmfield(aos_mon,'hex_flags');
   end

   fields = fieldnames(aos_mon);

   % Now force onto fixed minute grid...
   dt = (1/(24*60));
   aos_1min.time = [floor(aos_mon.time(1)./dt).*dt:dt:floor(aos_mon.time(end)./dt).*dt]';
   inds = uint32(interp1(aos_mon.time,[1:length(aos_mon.time)],aos_1min.time,'nearest'));
   for f = 2:length(fields)
      aos_1min.(fields{f}) = aos_mon.(fields{f})(inds);
      aos_1min.(fields{f})(diff2(inds)==0) = NaN;
   end
%    save([grid_m_dir, mats(m).name],'aos_1min');
% end

