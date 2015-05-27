function [sas2, sas]= sift_raw_sas(sas,ii)
% [sas2, sas]= sift_raw_sas(sas,ii)
% divides SAS raw struct into two logical pieces according to ii
fields = fieldnames(sas)
in_time = sas.time;
for f = 1:length(fields)
    if (size(sas.(fields{f}),1)==length(in_time))&& (size(sas.(fields{f}),2)==1)
        sas2.(fields{f}) = sas.(fields{f})(ii);
        sas.(fields{f})(ii) = [];
    elseif (size(sas.(fields{f}),1)==length(in_time))&& (size(sas.(fields{f}),2)~=1)
        sas2.(fields{f}) = sas.(fields{f})(ii,:);
        sas.(fields{f})(ii,:) = [];
    else
        sas2.(fields{f}) = sas.(fields{f});
    end
end

return
