function ol_out = ol_pvc_(range,in_time);
% ol_out = ol_pvc_(range,in_time);
% The ol functions return ol_out of length(range)
ol.time(1) = [inf];
ol.ol_corr{1} = @ol_unity;
ol.time(2) = datenum('20070101','yyyymmdd');
ol.ol_corr{2} = @olcorr_pvc_20090308;
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

function ol_out = olcorr_pvc_20090308(range);
ol_in = loadinto(['C:\mlib\local\lidar\mpl\overlap\fkb_Apr_ol.mat']);
ol_out = interp1(ol_in.range, ol_in.corr, range, 'nearest','extrap');
return