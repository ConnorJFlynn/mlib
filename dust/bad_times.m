function aos = bad_times(aos);
bad_time = (serial2doy(aos.time)>321.3)&(serial2doy(aos.time)<332.5)|(serial2doy(aos.time)>302.1)&(serial2doy(aos.time)<303.3);
field = fieldnames(aos);
for f = 1:length(field)
   if (~isempty(findstr(field{f},'Bap_'))||~isempty(findstr(field{f},'Bsp_'))||~isempty(findstr(field{f},'Bbsp_'))||...
         ~isempty(findstr(field{f},'Ang_'))|| ~isempty(findstr(field{f},'subfrac_'))|| ~isempty(findstr(field{f},'w_'))||...
         ~isempty(findstr(field{f},'bsf_'))|| ~isempty(findstr(field{f},'g_')))&&(length(aos.(field{f}))==length(aos.time))
      if isempty(findstr(field{f},'pwd_avg_vis'))
%          disp(field{f})
         aos.(field{f})(bad_time) = NaN;
      end
   end
end
