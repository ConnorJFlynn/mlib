function dif_cross = pcasp_mie_cs(d,n_ref,wl,num_ang)
% dif_cross = pcasp_mie_cs(d,n_ref,wl,num_ang)
% computes effective Mie cross section over PCASP
% FOV assuming double-pass incident light
%Diameter in microns

%Used to be called match_bnl_mie
% This assign particle diameters
% d = 1e-3*[102, 114, 125, 152, 199, 220, 240, 269, 350, 450, 596, 799, 1361, 2013]';
% % fix cross section units to cm^2
% 
% bnl_cs = 1e12*[1.98e-16, 3.71e-16, 6.55e-16, 2.15e-15, 9.94e-15, 1.74e-14, 2.69e-14, 4.6e-14, ...
% 1.64e-13, 3.26e-13, 5.79e-13, 9.88e-13, 1.93e-12, 2.57e-12]';
% 
%  bnl_pos = [250,  370, 880, 4180, 4550, 4880, 5300, 6080, 8290, 8370, 8470, ...
%      8800, 9700, 9875]';
% bnl_diam_um = 1e-3*[102, 114, 125, 152, 199, 220, 240, 269, 350, 450, 596, 799,1361, 2013]';
    
if ~exist('n_ref','var')
    n_ref = 1.59.*ones(size(d));; % Complex index of refraction, in this case purely real
end
if ~exist('wl','var')
    wl = .6328.*ones(size(d));;
end
if ~exist('num_ang','var')
num_ang = [181];
end
n = 1;
%%

% Compute Mie scattering properties for each radius
% for i = length(d):-1:1
    r_eff = d./2;

    %Mie size parameter xx
    xx = 2*pi*r_eff./wl;
    nang = num_ang(n);% Number of angles between 0-90 degrees

    [s1,s2,qext,qsca,qback,gsca]=bhmie(xx,n_ref,nang);
    K = 4./(qsca*xx.^2);
    i1 = abs(s1).^2;
    i2 = abs(s2).^2;
    P = K * (i1 + i2)/2;
    % Integral of P(i,:) over 4pi str = 4pi.
    
%     ii1 = abs(s1+fliplr(s1)).^2;
%     ii2 = abs(s2+fliplr(s2)).^2;
%     pp(i,:) = K(i) * (ii1 + ii2)/2;

    phi = [0:359]*pi/180;
    theta = linspace(0,pi,2*nang -1);
    theta_deg = theta * (180/pi);
    angs = find((theta_deg >= 35)&(theta_deg<=120));
    angs2 = find((theta_deg>=60)&(theta_deg<=145));
%      sub = (theta_deg >= 0)&(theta_deg<=180);
%     difr = trapz(phi,ones(size(phi))*trapz(theta(sub), sin(theta(sub)).*P(sub)))/(4*pi);
    crosssection = qsca * pi * (r_eff).^2 ;
    
    difr = trapz(theta(angs), sin(theta(angs)).*P(angs))/2;
    difr2 = trapz(theta(angs2), sin(theta(angs2)).*P(angs2))/2;
    dif_cross = (difr+difr2) * crosssection;

%     tot(i) = trapz(theta, sin(theta).*pp(i,:));
%     ddifr1(i) = trapz(theta(angs), sin(theta(angs)).*pp(i,angs))/tot(i);
%     ddifr2(i) = trapz(theta(angs2), sin(theta(angs2)).*pp(i,angs2))/tot(i);
%     ddif_cross1(i) = 2*crosssection(i)*ddifr1(i);
%     ddif_cross2(i) = 2*crosssection(i)*ddifr2(i);
    
%     disp(['Particle radius (um): ',num2str(r_eff(i))]);
% %
%     disp(['Wavelength (um): ', num2str(wl)])
%     disp(['Size parameter: ',num2str(xx(i))])
%     disp(['Scattering efficiency: ',num2str(qsca(i))])
%     crosssection(i) = qsca(i) * pi * (r_eff(i)).^2 ;
%     disp(['total scattering cross section: ',num2str(crosssection(i))])
%     disp(['fraction toward PCASP: ',num2str(difr(i))])
%     dif_cross(i) = difr(i) * crosssection(i);
%     disp(['PCASP scattering cross-section: ',num2str(dif_cross(i))]);
%     disp(' ')