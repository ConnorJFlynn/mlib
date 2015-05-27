% close all
% clear all
% clc
ss_cal = [.15,.25, .5, .75, 1]./100;
dT = [2.7859,3.9485,6.855,9.7615,12.668] ; % assume dT = dTinner = dTouter
dT = -0.1 + dT;
Q1 = (0.5.*1000)./60; % flow in cc/sec
Q = Q1 * (1e-02).^3; % flow in m3/sec

P = 100e3; % pressure in Pa (N/m2)

B1 = 877;
B2 = 1.3;
B3 = 3.75e-4;
B4 = 1.27e-5;
B5 = 2.24e-5;

T1 = 23.5 + 273;
Tc = T1;
Th = T1 + dT;
T_prime = (Th + Tc)./2;

dTQP = dT.*Q.*P;
TBBT = (T_prime.*(B3+B4.*T_prime));
C1 = B1.*dTQP;
C2 = (T_prime - B2.*dTQP./TBBT).^2; C1./C2;

C3a = 1./TBBT;
C3b = 1./(B5.*T_prime.^1.94);
C3 = (C3a - C3b);
S_lance = (C1./C2).*(C3);


b0t = ss_cal./S_lance;
% 
% ss = b0 .* S; 

[fdt] = interp1(dT,b0t, [2:0.1:15],'pchip');

% 0.006;
figure; plot(dT, b0t, '-o', [2:0.1:15],fdt,'k.');
% title('offset = +0.1')
% figure; plot(dT, b0+ 1./(1-dT).^2, '-o')



b0 