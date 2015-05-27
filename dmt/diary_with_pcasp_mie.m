% assign particle diameters
d = 1e-3*[102, 114, 125, 152, 199, 220, 240, 269, 350, 450, 596, 799, 1361, 2013]';
% fix cross section units to cm^2
bnl = 1e12*[1.98e-16, 3.71e-16, 6.55e-16, 2.15e-15, 9.94e-15, 1.74e-14, 2.69e-14, 4.6e-14, ...
1.64e-13, 3.26e-13, 5.79e-13, 9.88e-13, 1.93e-12, 2.57e-12]';
bnl_pos = [250,  370, 880, 4180, 4550, 4880, 5300, 6080, 8290, 8370, 8470, ...
    8800, 9700, 9875]';
num_ang = [181];
n = 1;
%%

% Compute Mie scattering properties for each radius
for i = length(d):-1:1
    r_eff(i) = d(i)/2;
    wl = .6328;
    %Mie size parameter xx
    xx(i) = 2*pi*r_eff(i)/wl;
    nang = num_ang(n);% Number of angles between 0-90 degrees
    n_ref = 1.59; % Complex index of refraction, in this case purely real
    [s1,s2,qext(i),qsca(i),qback(i),gsca(i)]=bhmie(xx(i),n_ref,nang);
    K(i) = 4./(qsca(i)*xx(i).^2);
    i1 = abs(s1).^2;
    i2 = abs(s2).^2;
    P(i,:) = K(i) * (i1 + i2)/2;
    % Integral of P(i,:) over 4pi str = 4pi.
    
    ii1 = abs(s1+fliplr(s1)).^2;
    ii2 = abs(s2+fliplr(s2)).^2;
    pp(i,:) = K(i) * (ii1 + ii2)/2;

    phi = [0:359]*pi/180;
    theta = linspace(0,pi,2*nang -1);
    theta_deg = theta * (180/pi);
    angs = find((theta_deg >= 35)&(theta_deg<=120));
    angs2 = find((theta_deg>=60)&(theta_deg<=145));
%      sub = (theta_deg >= 0)&(theta_deg<=180);
%     difr = trapz(phi,ones(size(phi))*trapz(theta(sub), sin(theta(sub)).*P(sub)))/(4*pi);
    crosssection(i) = qsca(i) * pi * (r_eff(i)).^2 ;
    
    difr(i) = trapz(theta(angs), sin(theta(angs)).*P(i,angs))/2;
    difr2(i) = trapz(theta(angs2), sin(theta(angs2)).*P(i,angs2))/2;
    dif_cross(i) = (difr(i)+difr2(i)) * crosssection(i);

    tot(i) = trapz(theta, sin(theta).*pp(i,:));
    ddifr1(i) = trapz(theta(angs), sin(theta(angs)).*pp(i,angs))/tot(i);
    ddifr2(i) = trapz(theta(angs2), sin(theta(angs2)).*pp(i,angs2))/tot(i);
    ddif_cross1(i) = 2*crosssection(i)*ddifr1(i);
    ddif_cross2(i) = 2*crosssection(i)*ddifr2(i);
    
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
end

pcasp_mie

Angular spacing = 0.49724 degrees
theta_min = 35  theta_max = 120
r(um)   Q_sca    cross-section(um^2)   PCASP_cross-section   fraction
0.051  2.052550e-002  1.677196e-004  1.933519e-004   0.593771
0.057  3.214907e-002  3.281467e-004  3.780221e-004   0.597196
0.0625  4.658618e-002  5.716985e-004  6.580083e-004   0.600588
0.076  1.017177e-001  1.845753e-003  2.117266e-003   0.609861
0.0995  2.843404e-001  8.843712e-003  1.001831e-002   0.628905
0.11  4.036760e-001  1.534505e-002  1.720403e-002   0.638406
0.12  5.353879e-001  2.422038e-002  2.676576e-002   0.647661
0.1345  7.549642e-001  4.290627e-002  4.590602e-002   0.65978
0.175  1.805224e+000  1.736829e-001  1.618800e-001   0.647308
0.225  2.683209e+000  4.267460e-001  3.240357e-001   0.534091
0.298  3.857656e+000  1.076232e+000  5.770066e-001   0.391933
0.3995  4.171633e+000  2.091653e+000  9.830884e-001   0.290457
0.6805  1.693398e+000  2.463572e+000  1.905904e+000   0.476235
1.0065  2.596201e+000  8.262582e+000  2.540529e+000   0.211858

pcasp_mie
Angular spacing = 0.49724 degrees
theta_min = 35  theta_max = 120
r(um)   Q_sca    cross-section(um^2)   PCASP_cross-section   fraction
0.051  2.052550e-002  1.677196e-004  1.933519e-004   0.593771
0.057  3.214907e-002  3.281467e-004  3.780221e-004   0.597196
0.0625  4.658618e-002  5.716985e-004  6.580083e-004   0.600588
0.076  1.017177e-001  1.845753e-003  2.117266e-003   0.609861
0.0995  2.843404e-001  8.843712e-003  1.001831e-002   0.628905
0.11  4.036760e-001  1.534505e-002  1.720403e-002   0.638406
0.12  5.353879e-001  2.422038e-002  2.676576e-002   0.647661
0.1345  7.549642e-001  4.290627e-002  4.590602e-002   0.65978
0.175  1.805224e+000  1.736829e-001  1.618800e-001   0.647308
0.225  2.683209e+000  4.267460e-001  3.240357e-001   0.534091
0.298  3.857656e+000  1.076232e+000  5.770066e-001   0.391933
0.3995  4.171633e+000  2.091653e+000  9.830884e-001   0.290457
0.6805  1.693398e+000  2.463572e+000  1.905904e+000   0.476235
1.0065  2.596201e+000  8.262582e+000  2.540529e+000   0.211858
