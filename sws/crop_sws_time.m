function sws = crop_sws_time(sws,keep);
%sws = crop_sws_time(sws,keep);
t_len = length(sws.time);
fld = fieldnames(sws);
for f = 1:length(fld)
   if size(sws.(fld{f}),2)==t_len
      if size(sws.(fld{f}),1)==1
         sws.(fld{f}) = sws.(fld{f})(keep);
      else
                  sws.(fld{f}) = sws.(fld{f})(:,keep);
      end
   end
end