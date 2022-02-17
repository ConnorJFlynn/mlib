function comp_rayleighs
% compare 4 alternative Rayleigh parameterizations:
% DP (Donna's from Masters)
% Ferrare & Turner
% Lenoble
% Measures

[T_K, P_mB, range_km] = std_atm;
T_K(1) = 273.15;
P_mB(1) = 1013.25;
range_km(1) = 0;
WL_nm = [400, 450, 464, 500, 523, 529, 532, 550,648, 700] ;
[alpha_R_DP] = ray_a_b_DP(T_K(1), P_mB(1).*100, WL_nm.*1e-9 );
 [alpha_R_FT] = ray_a_b_Ferrare_Turner(T_K(1), P_mB(1).*100, WL_nm);
 [alpha_R_L] = ray_a_b_lenoble(T_K(1), P_mB(1).*100, WL_nm.*1e-9);
  [alpha_R_M] = ray_a_b_measures(T_K(1), P_mB(1).*100, WL_nm);
figure; semilogx(alpha_R_DP, range_km,'-',...
   alpha_R_FT, range_km,'-',...
   alpha_R_L, range_km, 'x',...
alpha_R_M, range_km,'o');
legend('DP','FT','Lenoble','Measures')

figure; loglog(WL_nm,alpha_R_DP, '-',...
    WL_nm,alpha_R_FT,'-',...
    WL_nm,alpha_R_L, '-x',...
 WL_nm,alpha_R_M,'-o');
legend('DP','FT','Lenoble','Measures')