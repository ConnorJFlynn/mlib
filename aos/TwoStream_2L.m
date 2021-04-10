function [T2L, R2L] = TwoStream_2L(delta_ap, delta_sp, gp)

% # 2 Stream with two layers
% # first layer is composite of particles and fiber filters
% # second layer is filter only
% # first layer is fraction (chi) of total filter thickness
% # returns transmittance and reflectance
% # filter parameters are defined as:
% # delta_sf=9.631
% # delta_af=0.017
% # gf=0.75
 delta_af =0.017;
 delta_sf =9.631;
 chi = 0.2;
 gf = 0.75 ;
 mu1 = 3^(-.5);
 

%     my $self = shift @_;
%     die("$0: Wrong number of arguments passed to _2Stream_2L\n") if (scalar(@_) != 3);
%     my ($delta_ap, $delta_sp, $gp) = @_;
    [T1, R1] = TwoStream_1L(delta_ap, delta_sp, gp, delta_af.*chi, delta_sf.*chi, gf, mu1);
    [T2, R2] = TwoStream_1L(0,0,0,delta_af.*(1.0-chi),delta_sf.*(1.0-chi),gf,mu1);
    
%     [T1, R1] = 2Stream_1L($delta_ap,$delta_sp,$gp,$self->{delta_af}*$self->{chi},$self->{delta_sf}*$self->{chi},$self->{gf});
%     [T2, R2] = 2Stream_1L(0,0,0,$self->{delta_af}*(1.0-$self->{chi}),$self->{delta_sf}*(1.0-$self->{chi}),$self->{gf});
    
    IR12 = 1.0 - R1 .* R2;
    T2L = T1 .* T2 ./ IR12;        %# For better readablility and effeciency, moved to calling _2Stream_1L once, and using the set variables
    R2L = R1 + (T1 .* T1) .* R2 ./ IR12; %#

return