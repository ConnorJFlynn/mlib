function ol_out = ol_abc_(range,in_time);
% ol_out = ol_abc_(range,in_time);
% The ol functions return ol_out of length(range)
ol.time(1) = [inf];
ol.ol_corr{1} = @ol_unity;
if ~exist('in_time','var')||isempty(in_time)
   in = 1;
else
   first = find(in_time>ol.time,1);
end
first = max([1,first]);
ol_out = ol.ol_corr{first}(range);
return

function ol_corr = ol_unity(range);
ol_corr = ones(size(range));
return
