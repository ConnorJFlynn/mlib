%%%%%%   MPL far-range correction assuming far-range Rayleigh atmosphere
%%%%%%   Donna Powell Pacific Northwest National Lab
%%%%%%   February 20, 2001   


%%%%%%   K(r) far range misalignment correction.
%%%%%%   X(r) normalized lidar return (uncalibrated attenuated backscatter).
%%%%%%   S(r) = C * Beta_R(r) * T2(r) * K(r) or X(r) * K(r).

%%%%%%   given S(r) and Rayleigh Beta_R(r) and T2(r) for far range solve for K(r)
%%%%%%   recall T2(r)=exp(-2*(optical_depth_R(r)+ optical_depth_A))
%%%%%%   R(r) = Rayleigh Beta_R and T2 above some height rl where atm. is approx. Ray.
%%%%%%   ln[S(r)] = ln[C*T2(0 to rl)] + ln[R(r)] + ln[K(r)]
%%%%%%   dln[S(r)] = dln[R(r)] + dln[K(r)]
%%%%%%   so integ( dln[K(r)] ) = integ( dln[S(r)]/dln[R(r)] )

%for i=1:1000
%S(i) = mean(signal_r2(i));
%R(i) = beta_R(i)*T2_R(i);
%end;

X=100*exp(-2*opt_dep_R)*beta_R;
S=X.*K;
R=beta_R*exp(-2*trapz(a(n:1000),ext_R(n:1000)));

ln_S=real(log(S));
ln_R=real(log(R));
ln_K_orig=real(log(K_orig));

for i=1:999
    delta_ln_S(i)=real(ln_S(i+1)-ln_S(i))/0.030;
    delta_ln_R(i)=real(ln_R(i+1)-ln_R(i))/0.030;
    delta_ln_K_orig(i)=real(ln_K_orig(i+1)-ln_K_orig(i))/0.030;
    delta_ratio(i)= delta_ln_S(i)-delta_ln_R(i);
end

for i=3:998
ln_K(i)=trapz(a(3:i+1),delta_ratio(3:i+1));
K_new(i)=exp(ln_K(i));
end





