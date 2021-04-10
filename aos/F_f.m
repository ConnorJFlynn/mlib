function [F_f_, status] = F_f(delta_ap, delta_sp, gp)
% F_f is a function to 'interpolate' between the empirical response
% functions F_a0(ssa=0) and F_s(ssa=1). F_f is constrained to be
% unity if either for ssa=0 or ssa=1
% The interpolation is done using a two stream radiative transfer model
%     my $self = shift @_;
%     die("$0: Wrong number of arguments passed to F_f\n") if (scalar(@_) != 3);
%     my ($delta_ap, $delta_sp, $gp) = @_;
%     my $F_f;
%     eval{
F_f_=delta_f_2S(delta_ap,delta_sp,gp) ./ (delta_f_2S(0,delta_sp,gp)+delta_f_2S(delta_ap,0,gp));
if F_f_==0
    warning('0: numerical exception in subroutine F_f');
    F_f_ = NaN;
    status = false;
else
    status = true;
end

return



