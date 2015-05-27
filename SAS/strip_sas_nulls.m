function sas = strip_sas_nulls(sas);
% sas = strip_sas_nulls(sas);
% Eliminates times when all spectrometer values are zero.

in_time = sas.time;
all_nulls = all(sas.spec==0,2);
fields = fieldnames(sas);
for f = length(fields):-1:1
   if all(size(sas.(fields{f}))==size(in_time))
      sas.(fields{f})= sas.(fields{f})(~all_nulls);
   end
end
sas.spec = sas.spec(~all_nulls,:);

return
end
