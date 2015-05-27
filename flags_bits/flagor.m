function flag = flagor(ref_t, ref_flag, in_t);
% flag = flagor(ref_t, ref_flag, in_t);
% sets flag to true if in_t is bounded by true ref_flags
% Leaves flag as NaN if unable to compare due to bounds of ref_t
flag = NaN(size(in_t));
first_time = min(find(in_t > ref_t(1)));
if ~isempty(first_time)
    flag(1:first_time-1) = 0;
    for t = first_time:length(in_t)
        %[min_pos, ind_pos] = min((ref_t - in_t)>0);
        [lte] = max(find(ref_t<=in_t(t)));
        [gte] = min(find(ref_t>=in_t(t)));
        if ~isempty(lte)&~isempty(gte)
            if lte==gte
                flat(t) = ref_flag(lte);
            else
                flag(t) = (ref_flag(lte)&ref_flag(gte));
            end
        end
    end
end