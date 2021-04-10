function F_s_ = F_s(delta_s, g)
    b0       = 0.167;
    b1       = -0.175;
    b2       = -0.034;
    b3       = 0.037;
    lds = log(delta_s);
	F_s_=b0+b1.*g+b2.*lds+b3.*g.*lds;
    
    if F_s_ == 0
        warn('F_s yielded 0');
        F_s_ = NaN; 
        status = false;
    else
        status = true;
    end

return