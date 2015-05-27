function [S11,S12]=phase2(a,b,x,N,angle);
% returns S11 for a given lambda, radius (can be an array),
% complex refractive index and angle (can be an array) in degrees

[MM,NN]=size(x);

n=1:N;
for i=2:MM*NN
        n(i,:)=n(1,:);
end

[p,t]=ALegendr(angle*pi/180,N);
E = (2*n+1)./(n.*(n+1));
a = a.*E;
b = b.*E;
S1 = a*p + b*t;
S2 = a*t + b*p;

S11 = ((S2.*conj(S2))+(S1.*conj(S1)))/2;
S12 = ((S2.*conj(S2))-(S1.*conj(S1)))/2;
