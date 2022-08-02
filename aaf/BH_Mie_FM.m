%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mie code for calculating Qext, Qsca and Qabs for homogeneous spheres
% Based on FORTRAN code given by Bohren and Huffman
% Has been validated against values reported by Bohren and Huffman and
% by comparison to data in Fig. 7 of Lack (2006)
% Written by C.D. Cappa, April 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SSA = BH_Mie_FM(wavelength, radius, realK, imagK,printYN)
global GSA; global GSA_Qext; %geometric surface area
GSA = pi*(radius*1e-9)^2;
RunAngularCalc = 0;
refmed = 1.0; %REFMED = (real) refractive index of surrounding medium
refreli = imagK;
refrelr = realK;
refrel = (refrelr+refreli*1i)/refmed;

%Radius and wavelength in same units, define size parameter
radius = radius*1e-9;
wavelength = wavelength*1e-9;
x = double(2*pi*radius*refmed/wavelength);
% NANG = number of angles between 0 and 90 degrees
% Matrix elements calculated at 2*nang-1 angles,
% including 0, 90 and 180 degrees
nang = 2; %11, 2//11 means what?
dang = (pi/2)/(nang-1);
%%% BHMIE %%%
dx = double(x);

Y = x*refrel;
%%% Series terminated after NSTOP terms %%%
xstop = x + 4*x^(1/3)+2;
nstop = xstop;
ymod = abs(Y);
nmx = max(xstop, ymod)+15;
nmx = fix(nmx);
dang = (pi/2)/(nang-1);
for m=1:nang
    theta(m) = (m-1)*dang;
    amu(m) = cos(theta(m));
end
%%% Logarithmic derivative D(J) calculated by downward recurrence
%%% beginning with initial value (0.0 + 0.0*i) at J=NMX
D(nmx) = 0+0*1i;
nn = nmx-1;
for m=1:nn
rn = nmx-(m)+1;
D(nmx-(m)) = (rn/Y)-(1/(D(nmx-(m)+1)+rn/Y));
end
for m=1:nang
pi0(m) = 0.0;
pi1(m) = 1.0;
end
nn = 2*nang-1;
for m=1:nn
s1(m) = 0.0+0.0*1i;
s2(m) = 0.0+0.0*1i;
end
% Riccati-Bessel Functions with real argument X calculated by
% upward recurrence
psi0 = double(cos(dx));
psi1 = double(sin(dx));
chi0 = -sin(x);
chi1 = cos(x);
apsi0 = double(psi0);
apsi1 = psi1;
xi0 = double(apsi0 - chi0*1i);
xi1 = double(apsi1 - chi1*1i);
global qsca;
qsca = double(0.0);
gsca = double(0.0);

%start of big FOR loop for upward recurrence
%nstop is the number of terms required for convergence using upward recurrence
for n=1:nstop
    dn = n;
    rn = n;
    fn = (2*rn+1)/(rn*(rn+1));
    psi = double((2*dn-1)*psi1/dx-psi0);
    apsi = double(psi);
    chi = (2*rn-1)*chi1/x - chi0;
    xi = apsi + -chi*1i;
    an = (D(n)/refrel+rn/x)*apsi - apsi1;
    an = an/((D(n)/refrel+rn/x)*xi - xi1);
    bn = (refrel*D(n)+rn/x)*apsi - apsi1;
    bn = bn/((refrel*D(n)+rn/x)*xi - xi1);
    qsca = qsca+(2*rn+1)*(abs(an)*abs(an)+abs(bn)*abs(bn));
    % Calculate s1 and s2 for each scattering angle (nang) considered
    for m=1:nang
        mm = 2*nang-(m);
        pii(m) = pi1(m);
        tau(m) = rn*amu(m)*pii(m) - (rn+1)*pi0(m);
        p = (-1)^(n-1);
        s1(m) = s1(m)+fn*(an*pii(m)+bn*tau(m));
        t = (-1)^n;
        s2(m) = s2(m)+fn*(an*tau(m)+bn*pii(m));
        if m==mm
        break
        else
            s1(mm) = s1(mm) + fn*(an*pii(m)*p+bn*tau(m)*t);
            s2(mm) = s2(mm) + fn*(an*tau(m)*t+bn*pii(m)*p);
        end
    end
psi0 = psi1;
psi1 = psi;
apsi1 = psi1;
chi0 = chi1;
chi1 = chi;
xi1 = apsi1 + -chi1*1i;
rn = n+1;
    for m=1:nang
        pi1(m) = ((2*rn-1)/(rn-1))*amu(m)*pii(m);
        pi1(m) = pi1(m)-rn*pi0(m)/(rn-1);
        pi0(m) = pii(m);
    end
end
qsca = (2/(x^2))*qsca;
global qext;
qext = double((4/(x^2))*real(s1(1)));
global qabs;

qabs = double(qext - qsca);
global qback;
qback = double((4/(x^2))*abs(s1(2*nang-1))*abs(s1(2*nang-1)));%//abs(s1(2*nang-1))*abs(s1(2*nang-1)));
global ssa;
ssa = double(qsca/qext);
global GSA_Qabs; %double
global GSA_Qsca; %double
density = double(1.8);
mass = double( (density*1e6)*(4*pi/3)*(radius)^3);
GSA_Qext = double(GSA * qext);
GSA_Qabs = double(GSA * qabs);
GSA_Qsca = double(GSA * qsca);
global MAE_var;
MAE_var = double(GSA_Qabs/mass);
global MEE_var;
MEE_var= double(GSA_Qext/mass);
if printYN==1
    %print "GSA = "+num2str(GSA)+" square meters"
    qext;
    qsca;
    qabs;
    ssa;
    'Single particle extinction is';
    GSA_Qext;
    'Single particle scattering is ';
    GSA_Qsca;
    'Single particle absorption is';
    GSA_Qabs;
    'MAE assuming '; density; ' g/cm^3 density is '; MAE_var;
    'MEE assuming '; density; ' g/cm^3 density is '; MEE_var;
end
SSA = qsca/qext;
%%%% s33 and s34 matrix elements normalized by s11
%%%% s11 is normalized to 1.0 in the forward direction
%%%% pol = degree of palarization (incident unpolarized light)
if RunAngularCalc==1
    s11nor = 0.5*(cabs(s2(1))^2 + cabs(s1(1))^2);
    nana = 2*nang-1;
    % make/o/d/n = (nana) s11, s12, s33, s34, pol, ang
        for m=1:nana
            am = m;
            s11(m-1) = 0.5*cabs(s2(m))*cabs(s2(m));
            s11(m-1) = s11(m-1)+0.5*cabs(s1(m))*cabs(s1(m));
            s12(m-1) = 0.5*cabs(s2(m))*cabs(s2(m));
            s12(m-1) = s12(m-1)-0.5*cabs(s1(m))*cabs(s1(m));
            pol(m-1) = -s12(m-1)/s11(m-1);

            s33(m-1) = real(s2(m)*conj(s1(m)));
            s33(m-1) = s33(m-1)/s11(m-1);
            s34(m-1) = imag(s2(m)*conj(s1(m)));
            s34(m-1) = s34(m-1)/s11(m-1);
            s11(m-1) = s11(m-1)/s11nor;
            ang(m-1) = dang*(am-1)*57.2958;
        end
    end
end
