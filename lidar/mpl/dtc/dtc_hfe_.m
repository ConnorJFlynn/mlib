function MHz = dtc_hfe_(MHz,in_time);
% MHz = dtc_hfe(MHz,in_time);
% 
dtc.time(1) = [inf];
dtc.dtc{1} = @prescale_generic_dtc;
% Add starting times and detector dtc functions if available...

if ~exist('in_time','var')||isempty(in_time)
   first = 1;
else
   first = find(in_time>dtc.time,1);
end
first = max([1,first]);
MHz = dtc.dtc{first}(MHz);

return