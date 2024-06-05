function [vis_resp, nir_resp] = radcal_Ze1_SGP_Oriel_20220508_2;
% [vis_resp, nir_resp] = radcal_Ze1_SGP_Oriel_20220508_2;
% Measurements taken by Connor at SGP with Oriel lamp and spectralon blank
% with SASZe1.  Multiple integration times for  VIS and NIR specs for NLC
%
% Blocked light beam, shutter closed (darks)  / open_diffuse (stray light)
% 5*times unblocked light beam, shutter closed (darks) / open_lamp (lamp)
% Try to analyze two ways, once subtracting open_difuse, from open_lamp
% In principle, this should be best since open_diffuse will also have darks
% But if blocking the direct light also changes the diffuse then maybe not.
% So also try just unblocked open_lamp - unblocked closed_darks.

% Read calibrated irradiance source
visfile = getfullname('*_vis_*.csv','sasze');
[pname, vis_stem,ext] = fileparts(visfile);
pname = strrep([pname, filesep], [filesep filesep], filesep);
vis_stem = 'sgpsaszevisC1';nir_stem = 'sgpsaszenirC1';
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
panel = spectralon_srt_2784;
clear header
header(1) = {'% SASZe2 radiance calibration at SGP by Connor Flynn'};
header(end+1) = {['% SAS_unit: ', SAS_unit]};
header(end+1) = {['% Calibration_date: ',datestr(vis.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
header(end+1) = {['% Cal_source: ',lamp_str]};
header(end+1) = {['% Source_units: ',lamp.units]};
header(end+1) = {['% Diffuser: spectralon ',panel.header_raw]};
header(end+1) = {['% Lamps: 1']};

vis_irad = interp1(irad.nm, irad.Irad, vis.wl,'pchip');
vis_refl = interp1(panel.nm, panel.refl, vis.wl, 'pchip');
vis_rad = vis_irad.*vis_refl./pi;
nir_irad = interp1(irad.nm, irad.Irad, nir.wl,'pchip');
nir_refl = interp1(panel.nm, panel.refl, nir.wl, 'pchip');
nir_rad = nir_irad.*nir_refl./pi;
% The following line will only work in the case with one integration time.
vis.rate = vis.spec./(vis.t_int_ms*ones(size(vis.wl)));
nir.rate = nir.spec./(nir.t_int_ms*ones(size(nir.wl)));

% Prepare to step through sequence of integration times for each spec.
% to output a responsivity file for each spec and integration time
% Also aggregate calibration results under "cal".


vints = unique(vis.t_int_ms); %
% Minor problem: It appears the new dual-integration SW is yielding a fixed
% Integration time for each of these gosub experiments which attempted to
% set different integration times.  This bears further examination.
% It does not invalidate the current calibration but does limit it to
% smaller fixed integration times that intended/desired.

rec = cumsum(uint16(vis.time>0)); % Need this to distinguish diffuse from unshaded since tags are the same
% figure; plot(double(rec), vis.spec(:,500),'o'); zoom('on'); xlabel('record #'); ylabel('spec') % Use to identify desired ranges
blk_ = rec<240 | rec>1440;
shtr_open = vis.Shutter_open_TF; shtr_open(2:end) = shtr_open(2:end) & shtr_open(1:end-1); % Trim off first "open" after a dark.
shtr_closed = ~vis.Shutter_open_TF; shtr_closed(2:end) = shtr_closed(2:end) & shtr_closed(1:end-1); % Trim off first "dark" after a light.

for v = length(vints) %:-1:1
    vint = vints(v);
    headr = header;
    headr(end+1) = {['% Spectrometer_type: CCD2048']};
    pat = 'Spec SN = '; i = 1;p = [];
    while (i < length(vis.header))&&isempty(p); i = i +1; p = strfind(vis.header{i},pat) + length(pat); end
    headr(end+1) = strrep(vis.header(i),'Spec SN =', 'Spectrometer_SN:');
    headr(end+1) = {sprintf('%% Integration_time_ms: %d',vint)};
    headr(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};

    v_ = vis.t_int_ms==vint;
    blk_light = v_&blk_&shtr_open; blk_dark = v_&blk_&shtr_closed;
    blocked_light = mean(vis.rate(blk_light,:));
    blocked_dark = mean(vis.rate(blk_dark,:));
    unblk_light = v_&~blk_&shtr_open; ublk_dark = v_&~blk_&shtr_closed;
    ubblk_light_ij = find(unblk_light);
    unblocked_light = mean(vis.rate(unblk_light,:));
    unblocked_lighta = mean(vis.rate(ubblk_light_ij(1:2:end),:));unblocked_lightb = mean(vis.rate(ubblk_light_ij(2:2:end),:));
    unblocked_dark = mean(vis.rate(ublk_dark,:));
    %     figure; plot(vis.wl, blocked_dark,'-',vis.wl, blocked_light,'-',vis.wl, unblocked_dark,'-',vis.wl, unblocked_light,'-')
    rate = unblocked_light - blocked_light;
    ratea = unblocked_lighta - blocked_light;
    rateb = unblocked_lightb - blocked_light;

    rate2 = unblocked_light-unblocked_dark - (blocked_light-blocked_dark);
    vis_resp = rate./vis_rad;
    vis_respa = ratea./vis_rad; vis_respb = rateb./vis_rad;
    vresp_pct_err = 100.*sqrt((vis_respa-vis_resp).^2)./vis_resp;
    %     figure; plot(vis.wl, [vis_resp; vis_respa; vis_respb],'-', vis.wl, vresp_pct_err,'k-'); logy; zoom('on');
    ok = false;
    while ~ok
        figure_(832039284); clf; clear xl_lower xl_upper
        sb(1) = subplot(2,1,1); plot(vis.wl, unblocked_light,'-'); logy;
        sb(2)= subplot(2,1,2); plot(vis.wl, vis_resp,'-'); logy; linkaxes(sb,'x');zoom('on');
        vl = axis;
        done = menu('Zoom/pan in to place lowest acceptable responsivity at left-hand axis limit.','OK');
        xl_lower = xlim;xl_lower = min([xl_lower(1),350]);
        axis(vl);
        done = menu('Zoom/pan in to place highest acceptable responsivity at right-hand axis limit.','OK');
        xl_upper = xlim; xl_upper = (max([1100,xl_upper(2)]));
        badr = vis.wl < xl_lower| vis.wl > xl_upper;
        subplot(2,1,2); hold('on');plot(vis.wl(badr), vis_resp(badr),'kx'); hold('off')
        subplot(2,1,1); hold('on');plot(vis.wl(badr), unblocked_light(badr),'rx'); hold('off')
        title([sprintf(' Lower limit: %2.1f nm ',xl_lower), sprintf(' Upper limit: %2.1f nm',xl_upper)]);
        axis(vl)
        ok = menu('When limits are OK select done:','redo','done'); ok = ok>1;
    end
    vis_resp(badr) = NaN;
%     headr(end+1) = {['pixel, lambda_nm,  resp,   rate,     unblocked,   blocked,    src_radiance, panel_refl, src_irrad']};
    col_hedr = ['pixel, lambda_nm,  resp,   rate,     unblocked,   blocked,    src_radiance, panel_refl, src_irrad'];
    fmt = '%4d, %8.1f, %9.4g, %8.3f, %10.3f,  %10.3f,  %10.3e, %10.4f,   %10.3e \n';
    in_cal = [[1:length(vis.wl)]; vis.wl; vis_resp;rate;unblocked_light;blocked_light;vis_rad; vis_refl; vis_irad];
%     [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,headr,min(nir.time), vint,nir.pname);

    [resp_stem, resp_dir] = gen_sas_resp_file(headr, col_hedr, fmt,in_cal , mean(vis.time), vint, vis_stem, pname);
end

ints = unique(nir.t_int_ms); %#ok<*NASGU>
for v = length(ints) % :-1:1
    nint = ints(v);
    headr = header;
    headr(end+1) = {['% Spectrometer_type: NIR256-1.7']};
    pat = 'Spec SN = '; i = 1;p = [];
    while (i < length(nir.header))&&isempty(p); i = i +1; p = strfind(nir.header{i},pat) + length(pat); end
    headr(end+1) = strrep(nir.header(i),'Spec SN =', 'Spectrometer_SN:');
    headr(end+1) = {sprintf('%% Integration_time_ms: %d',nint)};
    headr(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};

    n_ = nir.t_int_ms==nint;
    blk_light = n_&blk_&shtr_open; blk_dark = n_&blk_&shtr_closed;
    blocked_light = mean(nir.rate(blk_light,:));
    blocked_dark = mean(nir.rate(blk_dark,:));
    unblk_light = n_&~blk_&shtr_open; ublk_dark = n_&~blk_&shtr_closed;
    ubblk_light_ij = find(unblk_light);
    unblocked_light = mean(nir.rate(unblk_light,:));
    unblocked_lighta = mean(nir.rate(ubblk_light_ij(1:2:end),:));unblocked_lightb = mean(nir.rate(ubblk_light_ij(2:2:end),:));
    unblocked_dark = mean(nir.rate(ublk_dark,:));
    %     figure; plot(nir.wl, blocked_dark,'-',nir.wl, blocked_light,'-',nir.wl, unblocked_dark,'-',nir.wl, unblocked_light,'-')
    rate = unblocked_light - blocked_light;
    ratea = unblocked_lighta - blocked_light;
    rateb = unblocked_lightb - blocked_light;

    rate2 = unblocked_light-unblocked_dark - (blocked_light-blocked_dark);
    nir_resp = rate./nir_rad;
    nir_respa = ratea./nir_rad; nir_respb = rateb./nir_rad;
    nresp_pct_err = 100.*sqrt((nir_respa-nir_resp).^2)./nir_resp;
    %     figure; plot(nir.wl, [nir_resp; nir_respa; nir_respb],'-', nir.wl, resp_pct_err,'k-'); logy; zoom('on');
    ok = false;
    while ~ok
        figure_(832039284);
        clf; clear xl_lower xl_upper
        sb(1) = subplot(2,1,1); plot(nir.wl, unblocked_light,'-'); logy;
        sb(2)= subplot(2,1,2); plot(nir.wl, nir_resp,'-'); logy; linkaxes(sb,'x');zoom('on');
        vl = axis;
        done = menu('Zoom/pan in to place lowest acceptable responsivity at left-hand axis limit.','OK');
        xl_lower = xlim;xl_lower = min([xl_lower(1),1000]);
        axis(vl);
        done = menu('Zoom/pan in to place highest acceptable responsivity at right-hand axis limit.','OK');
        xl_upper = xlim; xl_upper = (max([1600,xl_upper(2)]));
        badr = nir.wl < xl_lower| nir.wl > xl_upper;
        subplot(2,1,2); hold('on');plot(nir.wl(badr), nir_resp(badr),'kx'); hold('off')
        subplot(2,1,1); hold('on');plot(nir.wl(badr), unblocked_light(badr),'rx'); hold('off')
        title([sprintf(' Lower limit: %2.1f nm ',xl_lower), sprintf(' Upper limit: %2.1f nm',xl_upper)])
        axis(vl)
        ok = menu('When limits are OK select done:','redo','done'); ok = ok>1;
    end
    nir_resp(badr) = NaN;
%     headr(end+1) = {['pixel, lambda_nm,  resp,   rate,     unblocked,   blocked,    src_radiance, panel_refl, src_irrad'] };
    in_cal = [[1:length(nir.wl)];nir.wl; nir_resp;rate;unblocked_light;blocked_light;nir_rad; nir_refl; nir_irad];
    [resp_stem, resp_dir] = gen_sas_resp_file(headr, col_hedr, fmt,in_cal , mean(nir.time), nint, nir_stem, resp_dir);
%     [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,headr,min(nir.time), vint,nir.pname);
end


end
