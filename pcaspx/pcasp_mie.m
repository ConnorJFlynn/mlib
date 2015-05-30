%%
clear
% assign particle diameters
d = 1e-3*[102, 114, 125, 152, 199, 220, 240, 269, 350, 450, 596, 799, 1361, 2013]';
% fix cross section units to cm^2
bnl = 1e12*[1.98e-16, 3.71e-16, 6.55e-16, 2.15e-15, 9.94e-15, 1.74e-14, 2.69e-14, 4.6e-14, ...
1.64e-13, 3.26e-13, 5.79e-13, 9.88e-13, 1.93e-12, 2.57e-12]';
bin_pos = [350,  370, 880, 4180, 4550, 4880, 5300, 6080, 8290, 8370, 8470, ...
    8800, 9700, 9875]';
num_ang = [181];
for n = 1:length(num_ang)
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

%%

% disp(['wavelength =',num2str(wl)])
% disp(['index of refraction =',num2str(n_ref)])
% disp(['Integrated over 35<=theta<=120'])
disp(['Angular spacing = ',num2str(90/nang),' degrees'])
disp(['theta_min = ',num2str(theta_deg(angs(1))),'  theta_max = ',num2str(theta_deg(angs(end)))]);
disp('r(um)   Q_sca    cross-section(um^2)   PCASP_cross-section   fraction')
s = sprintf('%g  %e  %e  %e   %g\n', [r_eff; qsca; crosssection ; dif_cross ; difr]);
disp(s)
clear P K i1 i2 xx
end
%%
% %d = rd_pcasp_csv;
% gn = [1:3];
% [P_bnl, S_bnl] = polyfit(bnl(gn), bin_pos(gn),1);
% [P_pnl, S_pnl] = polyfit(dif_cross(gn), bin_pos(gn),1);
% figure; plot(bnl(gn), bin_pos(gn),'bo', dif_cross(gn), bin_pos(gn),'mx',...
%     bnl(gn), polyval(P_bnl, bnl(gn)),'b-', dif_cross(gn), polyval(P_pnl,dif_cross(gn)),'m-');
% title('low range')
% xlabel('cross-section (um^2)')
% ylabel('bin position')
% 
% gn = [4:8];
% [P_bnl, S_bnl] = polyfit(bnl(gn), bin_pos(gn),1);
% [P_pnl, S_pnl] = polyfit(dif_cross(gn), bin_pos(gn),1);
% figure; plot(bnl(gn), bin_pos(gn),'bo', dif_cross(gn), bin_pos(gn),'mx',...
%     bnl(gn), polyval(P_bnl, bnl(gn)),'b-', dif_cross(gn), polyval(P_pnl,dif_cross(gn)),'m-');
% title('medium range')
% xlabel('cross-section (um^2)')
% ylabel('bin position')
% 
% gn = [9:14];
% [P_bnl, S_bnl] = polyfit(bnl(gn), bin_pos(gn),1);
% [P_pnl, S_pnl] = polyfit(dif_cross(gn), bin_pos(gn),1);
% figure; plot(bnl(gn), bin_pos(gn),'bo', dif_cross(gn), bin_pos(gn),'mx',...
%     bnl(gn), polyval(P_bnl, bnl(gn)),'b-', dif_cross(gn), polyval(P_pnl,dif_cross(gn)),'m-');
% title('hi range')
% xlabel('cross-section (um^2)')
% ylabel('bin position')
