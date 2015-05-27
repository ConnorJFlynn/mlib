function [S11,Q_scat,Q_ext,Q_bks,gasym]=phase(lambda,r,m,angle);
% returns S11 for a given lambda, radius (can be an array),complex refractive index
% and angle (can be an array) in degrees

k=2*pi./lambda;
x=mie_par(r,lambda);
N=mie_test(x);
[MM,NN]=size(x);

%[Q_ext,Q_scat,a,b]=mie(x,m,N);
[Q_ext,Q_scat,Q_bks,gasym,a,b]=mie2(x,m,N);
[p,t]=ALegendr(angle*pi/180,N);

n=1:N;
for i=2:MM*NN
        n(i,:)=n(1,:);
end

E = (2*n+1)./(n.*(n+1));
a = a.*E;
b = b.*E;
S1 = a*p + b*t;
S2 = a*t + b*p;

S11 = ((S2.*conj(S2))+(S1.*conj(S1)))/2;
S12 = ((S2.*conj(S2))-(S1.*conj(S1)))/2;
S33 = ((S1.*conj(S2))+(S2.*conj(S1)))/2;
S34 = i*((S1.*conj(S2))-(S2.*conj(S1)))/2;

%Intensities of an individual particle
I_parallel=S11+S12;
I_perpend=S11-S12;
% figure(1)
% semilogy(angle,I_parallel,angle,I_perpend)

%Phase function of an individual particle
P=S11'./(ones(size(angle))'*(k.^2*pi*r.^2.*Q_scat'));
% figure(2)
% semilogy(angle,P)
