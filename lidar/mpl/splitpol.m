function [before, polavg]= splitpol(polavg,keep);
%Splits polavg into two parts.

in_time = length(polavg.time);
fields = fieldnames(polavg);
for f = 1:length(fields)
    if size(polavg.(fields{f}),2)==in_time
        tmp = polavg.(fields{f});
        polavg.(fields{f}) = tmp(:,keep);
        before.(fields{f}) = tmp(:,~keep);
    end
end
hk = fieldnames(polavg.hk);
for h = 1:length(hk);
%    disp(h)
    if findstr(hk{h},'_flag')
        polavg.hk = rmfield(polavg.hk,hk{h});
    else
        tmp = polavg.hk.(hk{h});
        try
        polavg.hk.(hk{h}) = tmp(keep);
        before.hk.(hk{h}) = tmp(~keep);
        catch
            disp('skip std bg');
        end
           
        
    end
end
before.dtc = polavg.dtc;
before.statics = polavg.statics;
before.range = polavg.range;
before.r = polavg.r;
before.std_attn_prof = polavg.std_attn_prof;
if isfield(polavg,'cop_ap')
before.cop_ap = polavg.cop_ap;
before.crs_ap = polavg.crs_ap;
before.ol_corr = polavg.ol_corr;
end
return
%%