function sas1 = catsas(sas1,sas2);
% sas1 = catsas(sas1,sas2);
if ~exist('sas1','var')
   sas1 = rd_raw_SAS;
end
if ~exist('sas2','var');
   sas2 = rd_raw_SAS;
end

% if strcmp(sas1.sn,sas2.sn)
in_time = sas1.time;
[~,inds]  = unique([sas1.time; sas2.time]);
fields = fieldnames(sas1);
for f = length(fields):-1:1
   if all(size(sas1.(fields{f}))==size(in_time))
      tmp = [sas1.(fields{f});sas2.(fields{f})];
      sas1.(fields{f})= tmp(inds);
   end
end
tmp = [sas1.spec;sas2.spec];
sas1.spec = tmp(inds,:);

% else
%    disp('Serial numbers do not match.  Not concatenating.')
% end

return
end
