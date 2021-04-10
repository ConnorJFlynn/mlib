#!/usr/bin/perl
package CTS;
use strict;
use Carp;
use POSIX qw( sinh cosh );

=head1 CTS.pm - Library containing CTS functions

CTS primarily provides CTS_solver, but also provides access to each method used by CTS_solver and gives access to setting the static values used by CTS_solver to a custom value


=head2 Usage

=head3 Basic

To use CTS first you must create a new instance of the solver.  Use the following code example, to call the generic solver without any additional options.

 use CTS;
 my $cts = CTS->new({});
 my ($result, $return_code) = $psap_cts->CTS_solver($delta_f_meas, 
     $delta_s_meas, $g_meas, $delta_a_start);

=head3 Advanced

To use CTS where you want to pass custom options for one or more of the static values, use the code example below.

 use CTS;
 my $cts = CTS->new({
                               mu1 => 3**-.5, 
                               delta_sf => 9.631, 
                               delta_af => 0.017, 
                               gf => 0.75, 
                               chi => 0.2, 
                               b0 => 0.167, 
                               b1 => -0.175, 
                               b2 => -0.034, 
                               b3 => 0.037
                               fd_stop => 1E-7
                              });
 my ($result, $return_code) = $cts->CTS_solver($delta_f_meas, $delta_s_meas, $g_meas, $delta_a_start);


In the above example, every static value that is user definable is shown.  Depending on the application,  zero, one, or more optional parameters can be changed, and the values used in the above example are the default values that will be used if you leave the associated variable out.

=head2 Variables

=head3 CTS_solver variables

=head4 delta_f_meas - total optical depth of filter+particles, calculated from transmittance or integration of sigma_f

=head4 delta_s_meas - scattering optical depth of particles, calculated using nephelometer total scattering,  flow rate and spot size of PSAP

=head4 g_meas - average asymmetry parameter of particles, calculated using nephelometer total and back scattering ( g is function a of BS/TS)

=head4 delta_a_start - initial guess of absorption optical depth of particles.  The algorithm converges much faster if delta_a_start is set to the value of the absorption optical depth calculated in the previous time step.

=head4 result - the absorption optical depth of the particles, delta_a, calculated by the CTS algorithm

=head4 result_code - a flag that indicates the status of the CTS algorithm, 1 indicates a successful run of the algorithm, 0 indicates a failure because of a numerical failure.

=head3 Static values

=head4 mu1 - a constant related to the average behavior of diffuse light possibly traveling at oblique angles through the multiple scattering media, typically taken to have values between unity and 1/sqrt(3). 

=head4 delta_sf - scattering optical depth of blank filter

=head4 delta_af - absorption optical depth of blank filter

=head4 gf - asymmetry parameter of blank filter

=head4 chi - fraction of filter thickness penetrated by particles

=head4 b0-b3 - empirical fit parameters describing relationship between scattering sensitivity term and asymmetry parameter, F_s=b0+b1*g+b2*log(delta_s)+b3*g*log(delta_s)

=cut

####### For more information about the "Two Stream Method" see Arnott et al. 2005

# 2 Stream forward calculation (single layer)
# input are particle abs., sca., and asymmetry (delta_a,delta_s,g)
# returns transmittance and reflectance	
# ap: particle absorption 
# sp: particle scattering
# af: filter absorption
# sf: filter scattering
# gp: particle parameter
# gf: filter parameter
# 
# Mathematical problems emerge when : 	"K = sqrt((1-ssa)*(1-ssa*g))  < 0 "
# As long as the filter is absorbing the single scattering albedo (ssa) is samller than "1" and K is a positive number 
# In our case the filter is absorbing : delta_af=0.017, in function _2Stream_2L(...)) 
# What happens if delta_ap is negative because of noisy data, first steps of iterative algorithm before delta_ap converges, etc.. ? 
# Solution : 
# 	 i)	calculate [T,R] for three cases
#		                    a)	(1-ssa)*(1-ssa*g) > 0, this is the smple case which was used in Arnott et al.(2005)
#				    b)  (1-ssa)*(1-ssa*g) = 0 
#				    c)  (1-ssa)*(1-ssa*g) < 0   
#	 ii)   use relations sinh(1i*x)=i*sin(x) and cosh(1i*x)=cos(x) 
# With this approach we avoid imaginary numbers and division by zero
# 

## Define some global vars!
#$self->{mu1} = 3**-.5;      # Universal constant
### These are for _2Stream_2L
#$self->{delta_sf} = 9.631;
#$self->{delta_af}=0.017;
#$self->{gf}=0.75;
#$self->{chi}=0.2;
#
### These are for F_s
#$self->{b0}=0.167;
#$self->{b1}=-0.175;
#$self->{b2}=-0.034;
#$self->{b3}=0.037;
#
#
#
### This is for delta_f_2S
#($self->{T2Zero}, $self->{R2Zero}) = $self->_2Stream_2L(0,0,0);

sub new{

    my ($class) = shift @_;
    my ($self) = shift @_ or die "PSAP_CTS.pm: Error reading correct options to new(), did you remember use use new({})?\n";
    bless ($self, $class) or die "PSAP_CTS.pm: Error reading correct options to new(), did you remember use use new({})?\n";

    $self->{mu1} = 3**-.5      unless (defined $self->{mu1});

    $self->{delta_sf} = 9.631  unless (defined $self->{delta_sf});
    $self->{delta_af} = 0.017  unless (defined $self->{delta_af});
    $self->{gf}       = 0.75   unless (defined $self->{gf});
    $self->{chi}      = 0.2    unless (defined $self->{chi});

    $self->{b0}       = 0.167  unless (defined $self->{b0});
    $self->{b1}       = -0.175 unless (defined $self->{b1});
    $self->{b2}       = -0.034 unless (defined $self->{b2});
    $self->{b3}       = 0.037  unless (defined $self->{b3});

    $self->{fd_stop}  = 1E-7   unless (defined $self->{fd_stop});
    
    ($self->{T2Zero}, $self->{R2Zero}) = $self->_2Stream_2L(0,0,0);
    return $self;
}
    



sub _2Stream_1L{
    my $self = shift @_;
    ## We expect 6 arguments, die if we get something else
    die("$0: Wrong number of arguments passed to _2Stream_1L\n") if (scalar(@_) != 6);
    
    my ($delta_ap, $delta_sp, $gp, $delta_af, $delta_sf,$gf) = @_;
    my ($delta_e, $g, $ssa, $K, $T, $R, $x );
    # average filter + particle properties
    $delta_e = $delta_sp+$delta_ap+$delta_sf+$delta_af; # total extinction aptical depth
    $ssa = ($delta_sp + $delta_sf)/$delta_e; # single scattering albedo
    $g = (abs($gp*$delta_sp)+$gf*$delta_sf)/(abs($delta_sp)+$delta_sf); # average asymmetry parameter
    $g = $gf if ($delta_sp <=0.0); # ??

    my $ssaNameMe = (1.0-$ssa)*(1.0-$ssa*$g); ## When we rename do a find and replace ssaNameMe with the new name
    
    ## Changed from orig
    $ssa = ($delta_sp + $delta_sf)/$delta_e;
    my $mu1 = $self->{mu1};
    
    if($ssaNameMe>0){ # case a)
	$K = sqrt($ssaNameMe);
    my $v = $K*$delta_e/$mu1;
    my $ep = exp($v);
    my $en = exp(-$v);
    my $sinhp = ($ep-$en)/2.0;
    my $coshp = ($ep+$en)/2.0;
    my $ssa1g = $ssa*(1.0+$g);
    my $sinhpK = $sinhp/$K;
    my $ssa1g2 = 2.0-$ssa1g;
	$T = 2.0/($ssa1g2 * $sinhpK + 2.0 * $coshp);
    $R = ($ssa*(1.0-$g)*$sinhpK)/($ssa1g2 * $sinhpK + 2.0 * $coshp);
	return ($T,$R);
    }elsif($ssaNameMe==0){ # case b) 
    my $ssade = $ssa*$delta_e;
    my $ssadeg = $ssade * $g;
    my $ssademdeg = $ssade - $ssadeg;
	$T=2.0*$mu1/(2.0*$delta_e-$ssademdeg+2.0*$mu1);                           # 	K=0
	$R=$ssademdeg/(2.0*$delta_e-$ssademdeg+2.0*$mu1); #  	limit(K->0,sinh(x*K)/K = x 
	return ($T,$R);                                                                           #       limit(K->0,cosh(x*K) = 1
    }else{ # case c)
	$x = abs($ssaNameMe);
    my $sqrtx = sqrt($x);
    my $ssa1g = $ssa*(1.0+$g);
    my $xdemu1 = $sqrtx*$delta_e/$mu1;
    my $sinp = sin($xdemu1);
    my $cosp = cos($xdemu1);
    my $sinpsx = $sinp / $sqrtx;
	$T = 2.0/((2.0-$ssa1g) * $sinpsx + 2.0 * $cosp);
	$R = ($ssa*(1.0-$g)* $sinpsx)/((2.0-$ssa1g) * $sinp/$x + 2.0 * $cosp);
	return ($T,$R);

	# K = 1i*sqrt( x )
	# use sinh(1i*x) = 1i * sin(x)
	# and cosh(1i*x)=c
    }
    
}


# 2 Stream with two layers
# first layer is composite of particles and fiber filters
# second layer is filter only
# first layer is fraction (chi) of total filter thickness
# returns transmittance and reflectance
# filter parameters are defined as:
# delta_sf=9.631
# delta_af=0.017
# gf=0.75
sub _2Stream_2L{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to _2Stream_2L\n") if (scalar(@_) != 3);
    my ($delta_ap, $delta_sp, $gp) = @_;
    my ($T2L, $R2L);
    my ($T1, $R1) = $self->_2Stream_1L($delta_ap,$delta_sp,$gp,$self->{delta_af}*$self->{chi},$self->{delta_sf}*$self->{chi},$self->{gf});
    my ($T2, $R2) = $self->_2Stream_1L(0,0,0,$self->{delta_af}*(1.0-$self->{chi}),$self->{delta_sf}*(1.0-$self->{chi}),$self->{gf});
    
    my $IR12 = 1.0-$R1*$R2;
    $T2L = $T1 * $T2 /$IR12;          # For better readablility and effeciency, moved to calling _2Stream_1L once, and using the set variables
    $R2L = $R1 + ($T1*$T1)*$R2/$IR12; #

    return ($T2L, $R2L);
}

# optical depth using 2 stream approach
sub delta_f_2S{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to delta_f_2S\n") if (scalar(@_) != 3);
    my ($delta_ap, $delta_sp, $gp) = @_;
    my ($T1, $R1) = $self->_2Stream_2L($delta_ap, $delta_sp, $gp);
    my ($T2, $R2) = ($self->{T2Zero}, $self->{R2Zero}); 
    return (-log($T1/$T2));
    
}

# F_f is a function to 'interpolate' between the empirical response 
# functions F_a0(ssa=0) and F_s(ssa=1). F_f is constrained to be 
# unity if either for ssa=0 or ssa=1  
# The interpolation is done using a two stream radiative transfer model
sub F_f{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to F_f\n") if (scalar(@_) != 3);
    my ($delta_ap, $delta_sp, $gp) = @_;
    my $F_f;
    eval{
	$F_f=$self->delta_f_2S($delta_ap,$delta_sp,$gp) / ($self->delta_f_2S(0,$delta_sp,$gp)+$self->delta_f_2S($delta_ap,0,$gp));
    };
    if($@){
	warn "$0: numerical exception in subroutine F_f\n";
	return (-9999,0); # Return a MVC (change to aero value for mvc?) and 0 (false)
    }else{
	return ($F_f, 1); # Return our value and 1 (true)
    }
}

#  parametrization for NaCl runs, NOAA
sub F_s{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to F_s\n") if (scalar(@_) != 2);
    my ($delta_s, $g) = @_;
    my $F_s;

    eval{
    my $lds = log($delta_s);
	$F_s=$self->{b0}+$self->{b1}*$g+$self->{b2}*$lds+$self->{b3}*$g*$lds;
    };
    if($@){
	warn "$0: numerical exception in subroutine F_s\n";
	return (-9999,0); # Return a MVC (change to aero value for mvc?) and 0 (false)
    }else{
	return ($F_s, 1); # Return our value and 1 (true)
    }
    
}

# RAOS, single wavelength PSAP Virkkula et. al (2005), ssa<0.3
sub F_a{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to F_a\n") if (scalar(@_) != 1);
    my ($delta_a) = @_;
    my $c1 = 0.354;
    my $c2 = 0.617;
    
    my $F_a;
    eval{
	if($delta_a == 0.0){
	    $F_a = 1/$c1;
	}else{
        my $c12 = $c1/$c2;
	    $F_a = (sqrt($delta_a*2.0/$c2+$c12*$c12)-$c12)/$delta_a;
	}
    };
    if($@){
	warn "$0: numerical exception in subroutine F_a\n";
	return (-9999,0); # Return a MVC (change to aero value for mvc?) and 0 (false)
    }else{
	return ($F_a, 1); # Return our value and 1 (true)
    }
}

# function F_a corrected to ssa=0 using two stream model	
# delta_s(ssa=0.3) = delta_a /( 1.0/0.3 -1.0 )
sub F_a0{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to F_a0\n") if (scalar(@_) != 2);
    my ($delta_a, $g) = @_;
    my ($delta_s_ssa03);
    my ($F_a1, $F_a2) = $self->F_a($delta_a);
    if($delta_a == 0){
	return ($F_a1,$F_a2);
    }else{
	$delta_s_ssa03 = $delta_a/(1.0/0.3-1.0); #del_s as function of del_a for ssa=0.3
	return ($F_a1*$self->delta_f_2S($delta_a,0,$g)/$self->delta_f_2S($delta_a,$delta_s_ssa03,$g),$F_a2);
    }
}

# filter optical depth
# delta_f = (F_a0 *delta_a + F_s *delta_s )* F_f
sub delta_f{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to delta_f\n") if (scalar(@_) != 3);
    my ($delta_a, $delta_s, $g) = @_;
    my (@result_F_a, @result_F_s, @result_F_f);
    @result_F_a = $self->F_a0($delta_a, $g);          # calibration function for ssa=0
    @result_F_s = $self->F_s($delta_s, $g);           # calibration function for ssa=1
    @result_F_f = $self->F_f($delta_a, $delta_s, $g); # cross term
    if($result_F_a[1] && $result_F_s[1] && $result_F_f[1]){
	return ((($result_F_a[0]*$delta_a+$result_F_s[0]*$delta_s)*$result_F_f[0], 1));
    }else{
	return ((-9999,0));
    }
}

# Constrained Two Stream Solver
# solve for delta_a
# Method: Newton approximation
# delta_f_meas :  calculated from transmittance or integration of sigma_f
# delta_s_meas :  calculated using nephelometer total scattering,  flow rate and spot size of PSAP
# g_meas	   :  calculated using nephelometer total and back scattering ( g is function a of BS/TS)
# delta_a_start:  is delta_a_start the value of the absorption optical depth calculated before, this algorithm converges very fast 
sub CTS_solver{
    my $self = shift @_;
    die("$0: Wrong number of arguments passed to CTS_solver\n") if (scalar(@_) != 4);
    my ($delta_f_meas, $delta_s_meas, $g_meas, $delta_a_start) = @_;
    my $maxiter=10; # maximum number of iterations
    my $k=0.0001;   # used for calculating the 1st derivative 
    my @delta_a;
    my @result_delta_f;
    my @result_delta_f_plus_k;

    # Clip to sane bounds
    $delta_f_meas = 0.0 if ($delta_f_meas < 0.0);
    $delta_s_meas = 0.0 if ($delta_s_meas < 0.0);
    if ($g_meas < 0.0 ) { $g_meas = 0.0; }
    elsif ($g_meas > 1.0) { $g_meas = 1.0; }
    $delta_a_start = 0.0 if ($delta_a_start < 0.0 or 
            (ref $delta_a_start and $delta_a_start->Im() != 0.0));
    push @delta_a, $delta_a_start; # starting value

    for(my $i=0; $i<$maxiter; $i++){
	@result_delta_f=$self->delta_f($delta_a[$i], $delta_s_meas, $g_meas);
	@result_delta_f_plus_k = $self->delta_f($delta_a[$i]+$k, $delta_s_meas, $g_meas);

    return (-9999,0) unless ($result_delta_f[1] and $result_delta_f_plus_k[1]);
	
	my $first_derivative=($result_delta_f_plus_k[0]-$result_delta_f[0])/$k;
	my $modification = ($result_delta_f[0] - $delta_f_meas)/$first_derivative;
    my $ada = $delta_a[$i]-$modification;
	push @delta_a, $ada;
    next if ($i == 0);
    my $lda = $delta_a[-2];
    my $ma; 
    if (abs($lda) > abs($ada)) { $ma=abs($lda); }
    else { $ma = abs($ada); }
    last if ($ma == 0);
    last if (abs($lda - $ada) / $ma < $self->{fd_stop});
    }
	return (pop @delta_a, 1);

	# return_code = True   -> no error
	# return_code = False  -> numerical error in one of the sub routines -> no solution
}
   

1;
