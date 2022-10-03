function [vis_resp, nir_resp] = radcal_He2_HOU_Oriel_20220909;
% [vis_resp, nir_resp] = radcal_He2_HOU_Oriel_20220909;
% Measurements taken by Connor at HOU with Oriel lamp and SASHe2.  
% Just one set of integration times, and no blocked beam since diffuser is
% well protected at the back of the baffle array.

% Read calibrated irradiance source
visfile = getfullname('*_vis_*.csv','sasze');
[pname, vis_stem,ext] = fileparts(visfile);
pname = strrep([pname, filesep], [filesep filesep], filesep);
vis_stem = 'housashevisM1';nir_stem = 'housashenirM1';
vis = rd_SAS_raw(visfile); nir = rd_SAS_raw([vis.pname{:},strrep(vis.fname{:},'vis','nir')]);
if iscell(vis.pname)&&isadir(vis.pname)&&iscell(nir.pname)&&isadir(nir.pname)
    vis.pname = vis.pname{:}; nir.pname = nir.pname{:};
end
pat = 'System SN = '; i = 1;p = [];

while (i < length(vis.header))&&isempty(p); i = i +1; p = strfind(vis.header{i},pat) + length(pat); end
SAS_unit = vis.header{i}(p:end);

lamp = oriel_5115;
lamp_str = 'Oriel_SN_5115';

nm_cal = [vis.wl, nir.wl]; [nm_out, ij] = sort(nm_cal);
% Use planck_tungsten_fit to interpolate/extrapolate
[irad] = planck_tungsten_fit(lamp.nm,lamp.irad, nm_out);

% Get spectralon reflectance and apply to get radiance from irradiance
% panel = spectralon_srt_2784;
clear header
header(1) = {'% SASHe2 normalized wavelength response at SGP by Connor Flynn'};
header(end+1) = {['% SAS_unit: ', SAS_unit]};
header(end+1) = {['% Calibration_date: ',datestr(vis.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
header(end+1) = {['% Cal_source: ',lamp_str]};
header(end+1) = {['% Source_units: ',lamp.units]};
header(end+1) = {['% Lamps: 1']};

vis_irad = interp1(irad.nm, irad.Irad, vis.wl,'pchip');
nir_irad = interp1(irad.nm, irad.Irad, nir.wl,'pchip');

vis.rate = vis.spec./(vis.t_int_ms*ones(size(vis.wl)));
nir.rate = nir.spec./(nir.t_int_ms*ones(size(nir.wl)));

% Prepare to step through sequence of integration times for each spec.
% to output a responsivity file for each spec and integration time
% Also aggregate calibration results under "in_cal".

vints = unique(vis.t_int_ms); %

shtr_open = logical(vis.Shutter_open_TF); shtr_open(2:end) = shtr_open(2:end) & shtr_open(1:end-1); % Trim off first "open" after a dark.
shtr_closed = ~vis.Shutter_open_TF; shtr_closed(2:end) = shtr_closed(2:end) & shtr_closed(1:end-1); % Trim off first "dark" after a light.


figure; 
for v = length(vints) %:-1:1
    vint = vints(v);
    headr = header;
    headr(end+1) = {['% Spectrometer_type: CCD2048']};
    pat = 'Spec SN = '; i = 1;p = [];
    while (i < length(vis.header))&&isempty(p); i = i +1; p = strfind(vis.header{i},pat) + length(pat); end
    headr(end+1) = strrep(vis.header(i),'Spec SN =', 'Spectrometer_SN:');
    headr(end+1) = {sprintf('%% Integration_time_ms: %d',vint)};
    headr(end+1) = {['% Resp_units: (count/ms)/(normalized irad)']};

    v_ = vis.t_int_ms==vint;
    dark = shtr_closed; darks = mean(vis.rate(dark,:));
    light = shtr_open;  lights = mean(vis.rate(light,:));

    %     figure; plot(vis.wl, blocked_dark,'-',vis.wl, blocked_light,'-',vis.wl, unblocked_dark,'-',vis.wl, unblocked_light,'-')
    rate = lights - darks;
    vis_resp = rate./vis_irad; vis_resp = vis_resp./max(vis_resp);

    ok = false;
    while ~ok
        figure_(832039284); clf; clear xl_lower xl_upper
        sb(1) = subplot(2,1,1); plot(vis.wl, rate,'-'); logy;
        sb(2)= subplot(2,1,2); plot(vis.wl, vis_resp,'-'); logy; linkaxes(sb,'x');zoom('on');
        vl = axis;
        done = menu('Zoom/pan in to place lowest acceptable responsivity at left-hand axis limit.','OK');
        xl_lower = xlim;xl_lower = min([xl_lower(1),350]);
        axis(vl);
        done = menu('Zoom/pan in to place highest acceptable responsivity at right-hand axis limit.','OK');
        xl_upper = xlim; xl_upper = (max([1100,xl_upper(2)]));
        badr = vis.wl < xl_lower| vis.wl > xl_upper;
        subplot(2,1,2); hold('on');plot(vis.wl(badr), vis_resp(badr),'kx'); hold('off')
        subplot(2,1,1); hold('on');plot(vis.wl(badr), rate(badr),'rx'); hold('off')
        title([sprintf(' Lower limit: %2.1f nm ',xl_lower), sprintf(' Upper limit: %2.1f nm',xl_upper)]);
        axis(vl)
        ok = menu('When limits are OK select done:','redo','done'); ok = ok>1;
    end
    vis_resp(badr) = NaN;
%     headr(end+1) = {['pixel, lambda_nm,  resp,   rate,     light,   dark,  src_irrad']};
    col_hedr = ['pixel, lambda_nm,  resp,   rate,     light,   dark,    src_irrad'];
    fmt = '%4d, %8.1f, %9.4g, %8.3f, %10.3f,  %10.3f, %10.3e \n';
    in_cal = [[1:length(vis.wl)]; vis.wl; vis_resp; rate; darks; lights; vis_irad];
%     [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,headr,min(nir.time), vint,nir.pname);

    [resp_stem, resp_dir] = gen_sas_resp_file(headr, col_hedr, fmt,in_cal , mean(vis.time), vint, vis_stem, pname);
end

ints = unique(nir.t_int_ms); 
for v = length(ints) % :-1:1
    nint = ints(v);
    headr = header;
    headr(end+1) = {['% Spectrometer_type: NIR256-1.7']};
    pat = 'Spec SN = '; i = 1;p = [];
    while (i < length(nir.header))&&isempty(p); i = i +1; p = strfind(nir.header{i},pat) + length(pat); end
    headr(end+1) = strrep(nir.header(i),'Spec SN =', 'Spectrometer_SN:');
    headr(end+1) = {sprintf('%% Integration_time_ms: %d',nint)};
    headr(end+1) = {['% Resp_units: (count/ms)/(normalized irad))']};

    n_ = nir.t_int_ms==nint;
    dark = shtr_closed; darks = mean(nir.rate(dark,:));
    light = shtr_open;  lights = mean(nir.rate(light,:));

    rate = lights - darks;
    nir_resp = rate./nir_irad; nir_resp = nir_resp./max(nir_resp);

    ok = false;
    while ~ok
        figure_(832039284);
        clf; clear xl_lower xl_upper
        sb(1) = subplot(2,1,1); plot(nir.wl, rate,'-'); logy;
        sb(2)= subplot(2,1,2); plot(nir.wl, nir_resp,'-'); logy; linkaxes(sb,'x');zoom('on');
        vl = axis;
        done = menu('Zoom/pan in to place lowest acceptable responsivity at left-hand axis limit.','OK');
        xl_lower = xlim;xl_lower = min([xl_lower(1),1000]);
        axis(vl);
        done = menu('Zoom/pan in to place highest acceptable responsivity at right-hand axis limit.','OK');
        xl_upper = xlim; xl_upper = (max([1600,xl_upper(2)]));
        badr = nir.wl < xl_lower| nir.wl > xl_upper;
        subplot(2,1,2); hold('on');plot(nir.wl(badr), nir_resp(badr),'kx'); hold('off')
        subplot(2,1,1); hold('on');plot(nir.wl(badr), rate(badr),'rx'); hold('off')
        title([sprintf(' Lower limit: %2.1f nm ',xl_lower), sprintf(' Upper limit: %2.1f nm',xl_upper)])
        axis(vl)
        ok = menu('When limits are OK select done:','redo','done'); ok = ok>1;
    end
    nir_resp(badr) = NaN;
    in_cal = [[1:length(nir.wl)];nir.wl; nir_resp;rate; lights; darks; nir_irad];
    [resp_stem, resp_dir] = gen_sas_resp_file(headr, col_hedr, fmt,in_cal , mean(nir.time), nint, nir_stem, resp_dir);
%     [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,headr,min(nir.time), vint,nir.pname);
end


end
