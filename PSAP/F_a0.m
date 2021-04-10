function [F_a1,F_a2]= F_a0(delta_a,g);

% # delta_s(ssa=0.3) = delta_a /( 1.0/0.3 -1.0 )
[F_a1, F_a2] = F_a(delta_a);
T2Zero = TwoStream_2L(0,0,0);
if(delta_a ~= 0)
    delta_s_ssa03 = delta_a./(1.0./0.3-1.0); %del_s as function of del_a for ssa=0.3
    F_a1 = F_a1.*delta_f_2S(delta_a,0,g, T2Zero)./delta_f_2S(delta_a,delta_s_ssa03,g, T2Zero);    
else
    delta_s_ssa03 = delta_a/(1.0/0.3-1.0); %del_s as function of del_a for ssa=0.3    
    F_a1 = F_a1.*delta_f_2S(delta_a,0,g, T2Zero)./delta_f_2S(delta_a,delta_s_ssa03,g,T2Zero);    
end

return