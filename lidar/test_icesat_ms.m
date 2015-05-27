% Script to show the degree of multiple scattering for the ICESat lidar
% for constant optical depth but for two values of effective radius for
% both an ice cloud and a liquid cloud. 

alt = 600e3; % Instrument altitude (m)
wavelength = 532e-9; % (m)
rho_div = 110e-6 .* 0.5; % Half-angle beam divergence (radians)
rho_fov = 170e-6 .* 0.5; % Half-angle field-of-view (radians)
footprint = rho_fov.*alt.*2; % Receiver footprint on the ground (m)
drange = 25; % Distance between range gates (m)

disp(['Receiver footprint on the ground: ' num2str(footprint) ' m']);

% Open figure with the appropriate size to be printed nicely
figure(1)
set(gcf,'units','inches',...
        'paperposition',[0.5 0.5 5.5 7],'position',[0.5 0.5 5.5 7],...
        'defaultaxesfontsize',13,'defaulttextfontsize',13)
clf

% Do two cases, an ice cloud and a liquid cloud
for icase = 1:2
  if icase == 2
    % Liquid cloud
    disp('LIQUID CLOUD');
    range = 3000:-drange:0; % (m)
    ext = zeros(size(range)); % Extinction coefficient (m-1)
    radius = 5e-6.*ones(size(range)); % (m)
    index = find(range > 1000 & range <= 2000); % Cloud 1-2 km
    ext(index) = 0.01;
    % asymmetry and single-scatter albedo for 5-micron and 10-micron
    % droplets:
    g = [0.84686 0.862617];
    ssa = [1.0 1.0];
    droplet_frac = ones(size(ext));
    pristine_ice_frac = zeros(size(ext));
  else
    % Ice cloud
    disp('ICE CLOUD');
    range = 9000:-drange:3000; % (m)
    ext = zeros(size(range)); % Extinction coefficient (m-1)
    radius = 50e-6.*ones(size(range)); % (m)
    index = find(range > 4000 & range <= 8000); % Cloud 4-8 km
    ext(index) = 0.001;
    % asymmetry and single-scatter albedo for 50-micron and 100-micron
    % particles:
    %    g = [0.82512 0.83923]; ssa = [0.999994 0.999988]; % 6 bullet rosette
    g = [0.73981 0.7399]; ssa = [0.999995 0.999989]; % smooth agg
    droplet_frac = zeros(size(ext));
    pristine_ice_frac = zeros(size(ext)); % Only for Ping Yang's phase
                                          % functions
  end
  S = 18.0.*ones(size(range)); % Extinction-backscatter ratio (sr)
  ext_air = 1.6e-6.*exp(-range./8000).*8.*pi./3; % Molecular extinction (m-1)
  ssa_air = ones(size(ext_air)); % Single-scatter albedo of air
  % Options
  options = '';
  waoptions = [' ' options];

  optical_depth = sum(ext).*abs(median(diff(range)));
  disp(['Optical depth: ' num2str(optical_depth)]);
  
  % First radius
  wa = multiscatter(waoptions, wavelength, alt, rho_div, rho_fov, ...
                    range, ext, radius, S, ext_air, ssa(1), g(1), ...
                    ssa_air, droplet_frac, pristine_ice_frac);
  % Doubled radius
  wa2 = multiscatter(waoptions, wavelength, alt, rho_div, rho_fov, ...
                    range, ext, 2.*radius, S, ext_air, ssa(2), g(2), ...
                    ssa_air, droplet_frac, pristine_ice_frac);

  % QSA calculation only, and also output the single-scattered return
  qsa = multiscatter([options ' -output-all -qsa-only'], ...
                     wavelength, alt, rho_div, rho_fov, ...
                     range, ext, radius, S, ext_air);

  % Single scattering
  single_bscat = multiscatter_platt(drange, ext, S, ext_air, 1.0);
  
  % Platt approximation with mu=0.5
  platt_bscat = multiscatter_platt(drange, ext, S, ext_air, 0.5);
  
  % Plot the result
  subplot(2,1,icase);
  semilogx(single_bscat,qsa.range./1000,'k--',...
       'linewidth',1,'color',[1 1 1].*0.6);
  hold on
  semilogx(platt_bscat, range./1000,'k',...
       'color',[1 1 1].*0.6,'linewidth',3);
  semilogx(wa.bscat, wa.range./1000,'k-','linewidth',1,'color',[1 1 1].*0);
  semilogx(wa2.bscat, wa.range./1000,'k--','linewidth',1,'color',[1 1 1].*0);
  xlim([1.e-8 1.e-3]);
  ylim(fliplr(range([1 end]))./1000);
  xlabel('Apparent backscatter (m^{-1} sr^{-1})');
  ylabel('Height (km)');
  set(gca,'xtick',10.^[-9:-2]);
  if icase == 1
    text(1.e-8, 8.5, ['\bf  (a) Ice cloud, optical depth = ' num2str(optical_depth)]);
    legend('Single scattering','Platt \eta = 0.5',...
           '{\itr_e} = 50 \mum','{\itr_e} = 100 \mum',...
           4);
    title('ICESat 532-nm lidar');
  else
    legend('Single scattering','Platt \eta = 0.5',...
           '{\itr_e} = 5 \mum','{\itr_e} = 10 \mum',...
           4);
    text(1.e-8, 2.75, ['\bf  (b) Liquid cloud, optical depth = ' num2str(optical_depth)]);
  end
end
