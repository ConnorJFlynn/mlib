r_eff = .102/2;
wl = .6328;
%Mie size parameter xx
xx = 2*pi*r_eff/wl;
% Number of angles between 0-90 degrees
n_ref = 1.59; % Complex index of refraction, in this case purely real
nang = [181,1001,2001];

for n = 1:length(nang);
% Compute Mie scattering properties for each radius

    [s1,s2,qext(n),qsca(n),qback(n),gsca(n)]=bhmie(xx,n_ref,nang(n));
    crosssection(n) = qsca(n) * pi * (r_eff).^2;
    K = 4./(qsca(n)*xx.^2);
    i1 = abs(s1).^2;
    i2 = abs(s2).^2;
    % Integral over 4pi str = 4pi.
    P{n} = K * (i1 + i2)/2;
%     phi = [0:359]*pi/180;
    theta{n} = linspace(0,pi,2*nang(n) -1);
    theta_deg = theta{n} * (180/pi);
    pcasp_angs = (theta_deg >= 35)&(theta_deg<=120);
%      sub = (theta_deg >= 0)&(theta_deg<=180);
%     difr = trapz(phi,ones(size(phi))*trapz(theta(sub), sin(theta(sub)).*P(sub)))/(4*pi);
    difr(n) = trapz(theta{n}(pcasp_angs), sin(theta{n}(pcasp_angs)).*P{n}(pcasp_angs))/(2);
    dif_cross(n) = difr(n) * crosssection(n);
end
disp(' ')
%%

