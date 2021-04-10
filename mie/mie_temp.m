r_eff = .102/2;
wl = .6328;
%Mie size parameter xx
xxx = 2*pi*r_eff/wl;
% Number of angles between 0-90 degrees
n_ref = 1.59; % Complex index of refraction, in this case purely real
nang = [180];

r_eff = [100:10000];
wl = [300:2000]';
xx = 2.*pi.*((ones(size(wl))*r_eff)./(wl*ones(size(r_eff))));
xxx = sort(xx(:));
xxx = xxx(1:10:end);
for x = length(xxx):-1:1
% Compute Mie scattering properties for each radius
   xx =xxx(x);
   [~,~,qext(x)]=bhmie(xx,n_ref,nang);
   if mod(x,1000)==0
       disp(x)
   end
end
[s1,s2,qext(x),qsca(x),qback(x),gsca(x)]=bhmie(xx,n_ref,nang);
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

