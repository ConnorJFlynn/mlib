function delta_f_2S_ = delta_f_2S(delta_ap, delta_sp, gp, T2)
[T1, R1] = TwoStream_2L(delta_ap, delta_sp, gp);
[T2] = TwoStream_2L(0, 0, 0);
%my ($T2, $R2) = ($self->{T2Zero}, $self->{R2Zero});
delta_f_2S_ = (-log(T1./T2)); % Need to check if "log" in perl is ln or log10
return