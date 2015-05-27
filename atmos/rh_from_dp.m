function rh = rh_from_dp(T,Dp)
if ~all((T<1000)|(T>200)) %Probably in C 
    T=T+273.15; %Convert to K
end

rh = exp(5423 * (1./T - 1./Dp));
end