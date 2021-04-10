function [T,R] = TwoStream_1L(delta_ap, delta_sp, gp, delta_af, delta_sf, gf,mu1);
% if nargin~=6
%     error('2Stream_1L needs 6 args');
% end

%     my ($delta_e, $g, $ssa, $K, $T, $R, $x );
%     # average filter + particle properties
delta_e = delta_sp+delta_ap+delta_sf+delta_af; % total extinction aptical depth
ssa = (delta_sp + delta_sf)./delta_e; %# single scattering albedo
g = (abs(gp.*delta_sp)+gf.*delta_sf)./(abs(delta_sp)+delta_sf); %# average asymmetry parameter
if (delta_sp <=0.0)
    g = gf;
end;

ssaNameMe = (1.0-ssa)*(1.0-ssa*g); % ## When we rename do a find and replace ssaNameMe with the new name

% % I don't know what self->{mu1} does...
% mu1 = self->{mu1};

if(ssaNameMe>0) %{ # case a)
    K = sqrt(ssaNameMe);
    v = K.*delta_e./mu1;
    ep = exp(v);
    en = exp(-v);
    sinhp = (ep-en)./2.0;
    coshp = (ep+en)./2.0;
    ssa1g = ssa*(1.0+g);
    sinhpK = sinhp./K;
    ssa1g2 = 2.0-ssa1g;
    T = 2.0./(ssa1g2 .* sinhpK + 2.0 .* coshp);
    R = (ssa.*(1.0-g).*sinhpK)./(ssa1g2 .* sinhpK + 2.0 .* coshp);
    % 	  return (T,R);
elseif(ssaNameMe==0) %{ # case b)
    ssade = ssa.*delta_e;
    ssadeg = ssade .* g;
    ssademdeg = ssade - ssadeg;
  	T=2.0.*mu1./(2.0.*delta_e-ssademdeg+2.0.*mu1);   % 	K=0
   	R=ssademdeg./(2.0.*delta_e-ssademdeg+2.0.*mu1); %  limit(K->0,sinh(x*K)/K = x
    % 	  return (T,R);                                                                           #       limit(K->0,cosh(x*K) = 1
else %{ # case c)
    x = abs(ssaNameMe);
    sqrtx = sqrt(x);
    ssa1g = ssa(1.0+g);
    xdemu1 = sqrtx.*delta_e./mu1;
    sinp = sin(xdemu1);
    cosp = cos(xdemu1);
    sinpsx = sinp ./ sqrtx;
    T = 2.0./((2.0-ssa1g) .* sinpsx + 2.0 .* cosp);
    R = (ssa.*(1.0-g).* sinpsx)./((2.0-ssa1g) .* sinp./x + 2.0 .* cosp);
    % 	  return (T,R);
end
% 	# K = 1i*sqrt( x )
% 	# use sinh(1i*x) = 1i * sin(x)
% 	# and cosh(1i*x)=c
%     }

% }


return