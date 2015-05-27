function polavg = cutpol(polavg,hours);
%Strips all records less than hours before last record.
keep = polavg.time >= polavg.time(end) - hours/24;
in_time = length(polavg.time);
fields = fieldnames(polavg);
for f = 1:length(fields)
    if size(polavg.(fields{f}),2)==in_time
        tmp = polavg.(fields{f});
        polavg.(fields{f}) = tmp(:,keep);
    end
end
hk = fieldnames(polavg.hk);
for h = 1:length(hk);
    if findstr(hk{h},'_flag')
        polavg.hk = rmfield(polavg.hk,hk{h});
    else
        tmp = polavg.hk.(hk{h});
        polavg.hk.(hk{h}) = tmp(keep);
    end
end
end
%%