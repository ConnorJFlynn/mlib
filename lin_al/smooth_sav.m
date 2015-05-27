function [g] = smooth_sav(prof, wing, order);
%usage [g] = smooth_sav(prof, wing, order);
end_prof = length(prof);
g = zeros(size(prof));
c_mid = savgo(wing, wing, order, 0);
for i = 1:end_prof
    if(i<=wing)
        wing_L = i -1;
        wing_R = wing;
        c_n = savgo(wing_L, wing_R, order, 0);
    elseif(i>=(end_prof - wing))
        wing_L = wing;
        wing_R = end_prof - i;
        c_n = savgo(wing_L, wing_R, order, 0);
    else
        wing_L = wing;
        wing_R = wing;
        c_n = c_mid;
    end
    g(i) = sum(prof(i-wing_L:i+wing_R) .* c_n);
end;