function Act_flux

Oriel_lamp = load(['C:\case_studies\radiation_cals\cal_sources_references_xsec\Oriel_Lamp_5115\oriel_lamp_5115.mat']);
Oriel_5115 = Oriel_lamp.oriel_5115;
% Load shaded and unshaded cal files
Oriel = rd_SAS_raw;
Oriel.dark_125ms = mean(Oriel.spec(Oriel.Shutter_open_TF==0&Oriel.t_int_ms==125,:));
Oriel.dark_1000ms = mean(Oriel.spec(Oriel.Shutter_open_TF==0&Oriel.t_int_ms==1000,:));
Oriel.light_1000ms = mean(Oriel.spec(Oriel.Shutter_open_TF==1&Oriel.t_int_ms==1000,:));
Oriel.light_125ms = mean(Oriel.spec(Oriel.Shutter_open_TF==1&Oriel.t_int_ms==125,:));
Oriel.rate_125ms = (Oriel.light_125ms-Oriel.dark_125ms)./125;
Oriel.rate_1000ms = (Oriel.light_1000ms-Oriel.dark_1000ms)./1000;
figure; plot(Oriel.lambda, [Oriel.rate_125ms;Oriel.rate_1000ms],'-')
legend('Oriel unshaded 125ms','Oriel unshaded 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')

figure; plot(Oriel.lambda, [Oriel.rate_1000ms;...
   smooth(Oriel.rate_1000ms,5)';(smooth(Oriel.rate_1000ms,8)'+smooth(Oriel.rate_1000ms,9)')./2],'-')
legend('0','5','(8+9)/2')

Oriel_blk = rd_SAS_raw;
Oriel_blk.dark_125ms = mean(Oriel_blk.spec(Oriel_blk.Shutter_open_TF==0&Oriel_blk.t_int_ms==125,:));
Oriel_blk.dark_1000ms = mean(Oriel_blk.spec(Oriel_blk.Shutter_open_TF==0&Oriel_blk.t_int_ms==1000,:));
Oriel_blk.light_1000ms = mean(Oriel_blk.spec(Oriel_blk.Shutter_open_TF==1&Oriel_blk.t_int_ms==1000,:));
Oriel_blk.light_125ms = mean(Oriel_blk.spec(Oriel_blk.Shutter_open_TF==1&Oriel_blk.t_int_ms==125,:));
Oriel_blk.rate_125ms = (Oriel_blk.light_125ms-Oriel_blk.dark_125ms)./125;
Oriel_blk.rate_1000ms = (Oriel_blk.light_1000ms-Oriel_blk.dark_1000ms)./1000;
figure; plot(Oriel_blk.lambda, [Oriel_blk.rate_125ms;Oriel_blk.rate_1000ms],'-')
legend('Oriel shaded 125ms','Oriel shaded 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')
figure; plot(Oriel.lambda, [Oriel_blk.rate_1000ms;smooth(Oriel_blk.rate_1000ms,3)';smooth(Oriel_blk.rate_1000ms,4)';...
   smooth(Oriel_blk.rate_1000ms,5)';smooth(Oriel_blk.rate_1000ms,6)';smooth(Oriel_blk.rate_1000ms,6)';...
   smooth(Oriel_blk.rate_1000ms,8)';smooth(Oriel_blk.rate_1000ms,9)';],'-')
legend('0','3','4','5','6','7','8','9')

Oriel_irad.nm = Oriel.lambda;
Oriel_irad.sig_125ms = Oriel.rate_125ms - Oriel_blk.rate_125ms;
Oriel_irad.sig_1000ms = Oriel.rate_1000ms - Oriel_blk.rate_1000ms;
Oriel_irad.sig_1000ms_sm = (smooth(Oriel_irad.sig_1000ms,8)'+smooth(Oriel_irad.sig_1000ms,9)')./2;


Oriel_irad.irad = interp1(Oriel_5115.nm, Oriel_5115.irrad_fit, Oriel_irad.nm,'pchip');
Oriel_irad.resp_125ms = Oriel_irad.sig_125ms./Oriel_irad.irad;
Oriel_irad.resp_1000ms = Oriel_irad.sig_1000ms./Oriel_irad.irad;
Oriel_irad.resp_1000ms = Oriel_irad.sig_1000ms_sm./Oriel_irad.irad;


figure; plot(Oriel.lambda, [Oriel.rate_125ms - Oriel_blk.rate_125ms;Oriel.rate_1000ms - Oriel_blk.rate_1000ms],'-')
legend('Oriel direct 125ms','Oriel direct 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')

North = rd_SAS_raw;
North.dark_125ms = mean(North.spec(North.Shutter_open_TF==0&North.t_int_ms==125,:));
North.dark_1000ms = mean(North.spec(North.Shutter_open_TF==0&North.t_int_ms==1000,:));
North.light_1000ms = mean(North.spec(North.Shutter_open_TF==1&North.t_int_ms==1000,:));
North.light_125ms = mean(North.spec(North.Shutter_open_TF==1&North.t_int_ms==125,:));
North.rate_125ms = (North.light_125ms-North.dark_125ms)./125;
North.rate_1000ms = (North.light_1000ms-North.dark_1000ms)./1000;
North.irad_1000ms = North.rate_1000ms./Oriel_irad.resp_1000ms;
figure; plot(North.lambda, [North.rate_125ms;North.rate_1000ms],'-')
legend('Panel at North, 125ms','Panel at North 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')
title('From North'); legend('North 125ms','North 1000mn');

Floor = rd_SAS_raw;
Floor.dark_125ms = mean(Floor.spec(Floor.Shutter_open_TF==0&Floor.t_int_ms==125,:));
Floor.dark_1000ms = mean(Floor.spec(Floor.Shutter_open_TF==0&Floor.t_int_ms==1000,:));
Floor.light_1000ms = mean(Floor.spec(Floor.Shutter_open_TF==1&Floor.t_int_ms==1000,:));
Floor.light_125ms = mean(Floor.spec(Floor.Shutter_open_TF==1&Floor.t_int_ms==125,:));
Floor.rate_125ms = (Floor.light_125ms-Floor.dark_125ms)./125;
Floor.rate_1000ms = (Floor.light_1000ms-Floor.dark_1000ms)./1000;
Floor.irad_1000ms = Floor.rate_1000ms./Oriel_irad.resp_1000ms;
figure; plot(Floor.lambda, [Floor.rate_125ms;Floor.rate_1000ms],'-')
title('From Floor'); legend('Floor 125ms','Floor 1000mn');
legend('Panel on Floor, 125ms','Panel on Floor 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')

Ceil = rd_SAS_raw;
Ceil.dark_125ms = mean(Ceil.spec(Ceil.Shutter_open_TF==0&Ceil.t_int_ms==125,:));
Ceil.dark_1000ms = mean(Ceil.spec(Ceil.Shutter_open_TF==0&Ceil.t_int_ms==1000,:));
Ceil.light_1000ms = mean(Ceil.spec(Ceil.Shutter_open_TF==1&Ceil.t_int_ms==1000,:));
Ceil.light_125ms = mean(Ceil.spec(Ceil.Shutter_open_TF==1&Ceil.t_int_ms==125,:));
Ceil.rate_125ms = (Ceil.light_125ms-Ceil.dark_125ms)./125;
Ceil.rate_1000ms = (Ceil.light_1000ms-Ceil.dark_1000ms)./1000;
Ceil.irad_1000ms = Ceil.rate_1000ms./Oriel_irad.resp_1000ms;

figure; plot(Ceil.lambda, [Ceil.rate_125ms;Ceil.rate_1000ms],'-')
title('From Ceil'); legend('Ceil 125ms','Ceil 1000mn');
legend('Panel on Ceiling, 125ms','Panel on Ceiling 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')

West = rd_SAS_raw;
West.dark_125ms = mean(West.spec(West.Shutter_open_TF==0&West.t_int_ms==125,:));
West.dark_1000ms = mean(West.spec(West.Shutter_open_TF==0&West.t_int_ms==1000,:));
West.light_1000ms = mean(West.spec(West.Shutter_open_TF==1&West.t_int_ms==1000,:));
West.light_125ms = mean(West.spec(West.Shutter_open_TF==1&West.t_int_ms==125,:));
West.rate_125ms = (West.light_125ms-West.dark_125ms)./125;
West.rate_1000ms = (West.light_1000ms-West.dark_1000ms)./1000;
West.irad_1000ms = West.rate_1000ms./Oriel_irad.resp_1000ms;

figure; plot(West.lambda, [West.rate_125ms;West.rate_1000ms],'-')
title('From West'); legend('West 125ms','West 1000mn');
legend('Panel at West, 125ms','Panel at West 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')

East = rd_SAS_raw;
East.dark_125ms = mean(East.spec(East.Shutter_open_TF==0&East.t_int_ms==125,:));
East.dark_1000ms = mean(East.spec(East.Shutter_open_TF==0&East.t_int_ms==1000,:));
East.light_1000ms = mean(East.spec(East.Shutter_open_TF==1&East.t_int_ms==1000,:));
East.light_125ms = mean(East.spec(East.Shutter_open_TF==1&East.t_int_ms==125,:));
East.rate_125ms = (East.light_125ms-East.dark_125ms)./125;
East.rate_1000ms = (East.light_1000ms-East.dark_1000ms)./1000;
East.irad_1000ms = East.rate_1000ms./Oriel_irad.resp_1000ms;
figure; plot(East.lambda, [East.rate_125ms;East.rate_1000ms],'-')
title('From East'); legend('East 125ms','East 1000mn');
legend('Panel at East, 125ms','Panel at East 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')

South = rd_SAS_raw;
South.dark_125ms = mean(South.spec(South.Shutter_open_TF==0&South.t_int_ms==125,:));
South.dark_1000ms = mean(South.spec(South.Shutter_open_TF==0&South.t_int_ms==1000,:));
South.light_1000ms = mean(South.spec(South.Shutter_open_TF==1&South.t_int_ms==1000,:));
South.light_125ms = mean(South.spec(South.Shutter_open_TF==1&South.t_int_ms==125,:));
South.rate_125ms = (South.light_125ms-South.dark_125ms)./125;
South.rate_1000ms = (South.light_1000ms-South.dark_1000ms)./1000;
South.irad_1000ms = South.rate_1000ms./Oriel_irad.resp_1000ms;

figure; plot(South.lambda, [South.rate_125ms;South.rate_1000ms],'-')
title('From South'); legend('South 125ms','South 1000mn');
legend('Panel at South, 125ms','Panel at South 1000 ms');
xlabel('wavelength [nm]'); ylabel('counts / ms')


figure; plot(South.lambda, [North.rate_1000ms;South.rate_1000ms;East.rate_1000ms;...
 West.rate_1000ms;Floor.rate_1000ms;Ceil.rate_1000ms  ],'-')
title('Rates, all six directions, 1000 ms integration'); 
legend('North','South','East','West','Floor','Ceil');
xlabel('wavelength [nm]'); ylabel('counts / ms')

figure; plot(South.lambda, [North.irad_1000ms;South.irad_1000ms;East.irad_1000ms;...
 West.irad_1000ms;Floor.irad_1000ms;Ceil.irad_1000ms  ],'-')
title('Irradiances, all six directions, 1000 ms integration'); 
legend('North','South','East','West','Floor','Ceil');
xlabel('wavelength [nm]'); ylabel('mW/m^2/nm')


Act_flux.nm = North.lambda;
Act_flux.irad_cube = Ceil.irad_1000ms + Floor.irad_1000ms + North.irad_1000ms + South.irad_1000ms + ...
   East.irad_1000ms + West.irad_1000ms;
Act_flux.irad_sphere = Act_flux.irad_cube./1.5;
guey = load('guey.mat'); guey = guey.guey;


figure; plot(Oriel_irad.nm, Oriel_irad.irad, '-',Act_flux.nm, Act_flux.irad_sphere,'-',...
   guey(:,1), 1000.*guey(:,3),'-');
legend('Oriel lamp','Chamber, cube flux, sphere','Guey ESR')
xlabel('wavelength [nm]'); ylabel('irad [mW/m2/nm]');
xlim([300,425]);

nm_ = (Oriel_irad.nm>=300)&(Oriel_irad.nm<=426);

[Oriel_irad.nm(nm_)',Act_flux.irad_sphere(nm_)']
% Load full cal files, compare rates for saturated (Long) and unsaturated
% (short) spectra.

% Ultimately, compute responsivity (ies) over the pixel range of interest.

% Then load each experiment data file for each direction flux in the
% aerosol chamber: fromCeil, fromFloor, Oriel_blk, South, East, West
% Compute rates for each.  
% Compute irradiances for each.
% Plot them all
% Sum all six components
% Plot it.
% convert to spherical.

% Also express in terms of photons?

return