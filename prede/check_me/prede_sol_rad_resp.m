function sky_cal = prede_sol_rad_resp
% sky_cal = prede_sol_rad_resp
% Incorporates Langley calibration with direct-sun exposed spectralon
% measurements to derive a radiance calibration that is radiometrically
% tied to the irradiance calibration
% 
% read in prede sun...
% if ~exist([in_dir,'Vo'],'dir')
%     mkdir([in_dir,'Vo']);
% end
% met = MLO_met_data(['C:\case_studies\4STAR\data\2012_MLO_May_June\MET',filesep]);
%
% Important files: *.SUN for direct beam
%                  *.dat for sky scans
% deprecated                 *.MAN for manual shading files with spectralon panel
%  current as of Nov 2016    *.RDM for spectralon panel using *.set file and "Random" mode.

%  The idea is to select a *.RDM file and identify the shaded and unshaded
%  values.  Use Select and UnSelect to exclude questionable values. 
%  Then compute the raw solar radiance from unshaded-shaded
%  Then load the corresponding *.SUN file and the Vos to express the
%  radiance in terms of I/Io.

Langleys = load(getfullname('*all.refined_Vos.mat','Prede_Lang'));
guey_ESR = gueymard_ESR;
spec_reflectivity = 0.99;
% for iw = 1:length(star.w(star.aeronetcols(star.vis_pix)))
for iw = length(Langleys.wl):-1:2    
%     Compute a gaussian of FWHM 10 nm centered on each filter at guey_ESR(:,1) wavelengths.
%     Compute the integral of this Gaussian with guey_ESR(:,2)
    g_ESR(iw) = trapz(guey_ESR(:,1), guey_ESR(:,2).*gaussian_fwhm(guey_ESR(:,1),Langleys.wl(iw),10)./trapz(gaussian_fwhm(guey_ESR(:,1),500,10)));
end
% Current solar_distance, Jan 15 = 0.9836
% So, compared to a distance of 1 AU, our intensity will be higher
% So, we need to multiply our sun measurements by R^2 to put them on the
% same scale as the Io

% Io = 1e-6.*[0 132.3223  319.9116  397.2279  236.9746  218.2916  201.9398];
Io = Langleys.mean_Vo;
%% 
% there are two pieces of code below trying to do the same thing developed at
% different times. Both are attempting. to look at the shaded-unshaded measurements
% One is an attempt to be more automated, reading a sun file and a man file 
% and then trying to match up appropriate columns.
% The other is hand-holding.
%
% Spectralon sequence on Jan 17, 2016
% from *.SUN 
rdm_file = getfullname('*.RDM','prede');
if ~iscell(rdm_file)
    rdm_file = {rdm_file};
end
if length(rdm_file)>0
[pname, fname] = fileparts(rdm_file{1}); pname = [pname, filesep];
prede_spec = read_prede(rdm_file{1});
sky_cal.pname = pname;
sky_cal.wl = prede_spec.wl;
sky_cal.LatN = prede_spec.LatN;
sky_cal.LonE = prede_spec.LonE;
sky_cal.Langley_Io = Io';
sky_cal.g_ESR = g_ESR;
sky_cal.Resp_Ir = Io' ./ g_ESR;

figure; 

for R = length(rdm_file):-1:1
[~, fname] = fileparts(rdm_file{R});
prede_spec = read_prede(rdm_file{R});

% Now maybe plot values from the Man file and let the user put the first
% record we want to use on the left-hand edge of the plot to use as the
% start time.
SA = scat_ang_degs(prede_spec.zen_sun, prede_spec.azi_sun, prede_spec.zen, prede_spec.azi);

sb(1) = subplot(2,1,1); plot([1:length(prede_spec.time)], SA,'o-'); legend('Scattering angle')
sb(2) = subplot(2,1,2); plot([1:length(prede_spec.time)], prede_spec.filter_4,'x-'); legend('Filter_4')
linkaxes(sb,'x');zoom('on');

unshaded = false(size(prede_spec.time));
done = false;
rec = [1:length(prede_spec.time)];
while ~done
    these = menu('Zoom in to select "unshaded" values...','Select these...','Unselect these...','Done');
    v = axis(sb(2));
    if these==1         
        those = rec>=v(1)&rec<=v(2)&prede_spec.filter_4>=v(3)&prede_spec.filter_4<=v(4);
        unshaded(those) = true;
    elseif these == 2
           those = rec>=v(1)&rec<=v(2)&prede_spec.filter_4>=v(3)&prede_spec.filter_4<=v(4);
           unshaded(those) = false;
    elseif these ==3
        done = true;
    end
    sb(1) = subplot(2,1,1); plot([1:length(prede_spec.time)], SA,'o-',rec(~those), SA(~those),'ro'); legend('Scattering angle')
    sb(2) = subplot(2,1,2); plot([1:length(prede_spec.time)], prede_spec.filter_4,'x-',rec(~those), prede_spec.filter_4(~those),'rx'); legend('Filter_4')
    linkaxes(sb,'x');zoom('on');axis(sb(2),v);
end
    
shaded = false(size(prede_spec.time));
done = false;
rec = [1:length(prede_spec.time)];
while ~done
    these = menu('Zoom in to select "shaded" values (not "blocked" values).','Select these...','Unselect these...','Done');
    v = axis(sb(2));
    if these==1         
        those = rec>=v(1)&rec<=v(2)&prede_spec.filter_4>=v(3)&prede_spec.filter_4<=v(4);
        shaded(those) = true;
    elseif these == 2
           those = rec>=v(1)&rec<=v(2)&prede_spec.filter_4>=v(3)&prede_spec.filter_4<=v(4);
           shaded(those) = false;
    elseif these ==3
        done = true;
    end
    sb(1) = subplot(2,1,1); plot([1:length(prede_spec.time)], SA,'o-',rec(~those), SA(~those),'k*'); legend('Scattering angle')
    sb(2) = subplot(2,1,2); plot([1:length(prede_spec.time)], prede_spec.filter_4,'x-',rec(~those), prede_spec.filter_4(~those),'k*'); legend('Filter_4')
    linkaxes(sb,'x');zoom('on');axis(sb(2),v);
end

% filter_4_unshaded = NaN(size(unshaded));
% filter_4_unshaded(shaded|unshaded) = interp1(rec(unshaded), prede_spec.filter_4(unshaded), rec(shaded|unshaded),'linear');
% filter_4_shaded = NaN(size(shaded));
% filter_4_shaded(shaded|unshaded) = interp1(rec(shaded), prede_spec.filter_4(shaded), rec(shaded|unshaded),'linear');
% filter_4_rad = filter_4_unshaded - filter_4_shaded;
% 100.*std(filter_4_rad(~isnan(filter_4_rad)))./mean(filter_4_rad(~isnan(filter_4_rad)))

filters = [prede_spec.filter_1',prede_spec.filter_2',prede_spec.filter_3',...
    prede_spec.filter_4',prede_spec.filter_5',prede_spec.filter_6',prede_spec.filter_7'];
filters_unshaded = NaN(size(filters));
filters_unshaded(shaded|unshaded,:) = interp1(rec(unshaded), filters(unshaded,:), rec(shaded|unshaded),'linear');
filters_shaded = NaN(size(filters));
filters_shaded(shaded|unshaded,:) = interp1(rec(shaded), filters(shaded,:), rec(shaded|unshaded),'linear');
dirn_rad = filters_unshaded - filters_shaded; % direct normal solar as radiance
dirn_rad = dirn_rad(~isnan(dirn_rad(:,3)),:);
sky_cal.time(R) = mean(prede_spec.time(shaded|unshaded));
sky_cal.rec(R).dirn_rad = dirn_rad;
100.*std(dirn_rad)./mean(dirn_rad)
keep = IQ(dirn_rad(:,3),.1);
sky_cal.rec(R).keep = keep;
% 100.*std(dirn_rad(keep,:))./mean(dirn_rad(keep,:))
sky_cal.rec(R).mean_dirn_rad = mean(dirn_rad(keep,:));
sky_cal.rec(R).std_dirn_rad = std(dirn_rad(keep,:));
sky_cal.rec(R).pct_dev_dirn_rad = 100.*sky_cal.rec(R).std_dirn_rad./sky_cal.rec(R).mean_dirn_rad;
%%

ok = menu('Shift plot until first shaded value of a shade/unshade sequence is at the left limit','Done');
xl = xlim; ii = ceil(xl(1));

prede_sun = read_prede(getfullname([fname(1:6),'*.SUN'],'prede'));
datestr(prede_spec.time([1 end]))

before = 1; after = before +1; 
% Should catch pathological cases where panel measurements aren't bracketed
while prede_sun.time(after)<prede_spec.time(end) && after <= length(prede_sun.time) && after<length(prede_sun.time)
%     [datestr(prede_sun.time(after)), ' is before ',datestr(prede_spec.time(ii))]
    before = before + 1; after = before + 1;    
end
[datestr(prede_sun.time(before)), ' is before ',datestr(prede_spec.time(ii))]
[datestr(prede_sun.time(after)), ' is after ',datestr(prede_spec.time(ii))]

dirn_1 = [prede_sun.filter_1(before);prede_sun.filter_2(before);...
    prede_sun.filter_3(before);prede_sun.filter_4(before);prede_sun.filter_5(before);...
    prede_sun.filter_5(before); prede_sun.filter_6(before)];
dirn_2 = [prede_sun.filter_1(after);prede_sun.filter_2(after);...
    prede_sun.filter_3(after);prede_sun.filter_4(after);prede_sun.filter_5(after);...
    prede_sun.filter_5(after); prede_sun.filter_6(after)];
dirn = mean([dirn_1,dirn_2],2);
sky_cal.rec(R).dirn_before = dirn_1;
sky_cal.rec(R).dirn_after = dirn_2;
sky_cal.rec(R).dirn = dirn;
sky_cal.rec(R).So = mean(dirn_rad)'.*(Io./dirn);
sky_cal.rec(R).spec_reflectivity = spec_reflectivity; 
sky_cal.rec(R).Panel_TOA_radiance = spec_reflectivity.*1e4.*g_ESR'./pi;
sky_cal.rec(R).D_resp = sky_cal.rec(R).So ./ sky_cal.rec(R).Panel_TOA_radiance;
sky_cal.D_resp(:,R) = sky_cal.rec(R).D_resp;
%This should be what the Prede would record for the Spectralon at TOA
% So checking how repeatable this is day by day is our stability test.
% Careful here!  Make sure we're properly accounting for soldst for Do
% Do_panel_cts = mean(dirn_rad)'.*Io./dirn;
% 
% Td = Do_panel_cts./Io % Comparable to a unitless diffuse transmittance? Useful or not useful?
% 
% Panel_TOA_radiance = spec_reflectivity.*1e4.*g_ESR'./pi;
% % The factor of 1e4 converts Irradiance in W/cm^2/nm to radiance in (W/m2/nm/sr)
% D_resp = Do_panel_cts ./ Panel_TOA_radiance;
% 
% % So actual sky radiance will be
% sky_rad = sky_cts / D_resp;% = sky_cts * panel_TOA_radiance/Do_panel_cts
% % = sky_cts * panel_TOA_radiance * (prede_dirn * soldst^2 /Io) *(1/filters_rad)
% % Time to build a loop for this...
% % And still need to sort out how to represent the diffuse as a unitless
% % value referenced against the instrument Io. 
% 
% Dos = [ 0.0895, 0.2268, 0.2821, 0.1705, 0.1491, 0.1355; ...
%         0.0922, 0.2337, 0.2919, 0.1757, 0.1452,  0.1471; ...
%         0.0912,    0.2313,    0.2880,    0.1740,    0.1474,    0.1429; ...    
%         0.0905,     0.2299,    0.2863,    0.1729,    0.1498,    0.1397 ];
% 
% 100.*std(Dos)./mean(Dos)

end
sky_cal.mean_D_resp = mean(sky_cal.D_resp,2)';
sky_cal.pct_dev_D_resp = 100.*std(sky_cal.D_resp')./sky_cal.mean_D_resp;
save([pname,filesep, 'Resp_from_panel_and_sun_on_',datestr(prede_spec.time(1),'yyyymmdd'),...
    '.created_',datestr(now,'yyyymmdd'),'.mat'],'-struct','sky_cal')
else
    sky_cal = [];
end

return