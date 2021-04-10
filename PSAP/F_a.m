function [F_a_, status] = F_a(delta_a)

c1 = 0.354;
c2 = 0.617;
if(delta_a == 0.0)
    F_a_ = 1./c1;
else
    c12 = c1./c2;
    F_a_ = (sqrt(delta_a.*2.0./c2+c12.*c12)-c12)./delta_a;
end
if F_a_ ==0
    warning('F_a yielded 0: numerical exception in subroutine F_a');
    F_a_ = NaN;
    status = false;
else
    status = true;
end


return