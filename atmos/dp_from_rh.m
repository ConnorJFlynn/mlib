function dp = dp_from_rh(T,rh)
 
if ~all((T<1000)|(T>200)) %Probably in C 
    T=T+273.15; %Convert to K
end
 if all((rh<0)|(rh > 2)) %Probably in %
    rh = rh/100;
 end
IDp = (1./T - log(rh)/5423);
dp = 1./IDp;

end

