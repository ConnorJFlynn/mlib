function dp = calc_dp(T,rh)
% T in K, rh in fractional
dp = NaN(size(T));
good = (T>-900) & (rh > -900);

if any((T(good)<0))||all(T(good)<200)
    T(good)=T(good)+273.15; %Convert to K
end
 if any((rh(good) > 2)) %Probably in %
    rh = rh/100;
 end
IDp = (1./T - log(rh)/5423);
dp(good) = 1./IDp(good);

end

