% ena SWS cal

oriel = getfullname('oriel*.mat','oriel'); 
oriel = load(oriel);
if isstruct(oriel)&&length(fieldnames(oriel))==1
    oriel = oriel.(char(fieldnames(oriel)));
end
spec_panel = load(['F:\case_studies\radiation_cals\cal_sources_references_xsec\Spectralon_panels\Spectralon_SRM_99O.mat']);

% load ophir irradiance, convert to radiance

% load pairs of unshaded, shaded files, compute rates, take difference of
% rates, compute resp
cal_files = getfullname('Unshaded_*_vis_1s*.csv','unshaded','Select unshaded cal files');
pname = [fileparts(cal_files{1}),filesep,'..',filesep,'resp',filesep];
if ~isdir(pname)
    mkdir(pname)
end
for c = length(cal_files):-1:1
    
unshaded =bundle_sas_raw(cal_files{c});
fstem = strtok(unshaded.fname,'.'); fstem = strrep(fstem,'Unshaded','Shaded');
fil = dir([unshaded.pname, fstem{:},'.*.csv']);
if length(fil)~=1
    shaded = getfullname([fstem{:},'.*.csv'],'shaded','Select shaded cal files');
else
    shaded = getfullname([fil.folder,filesep,fil.name],'shaded','Select shaded cal files');
end
shaded = bundle_sas_raw(shaded);

% dirn 
cal(c).vis.time = meannonan(unshaded.time);
cal(c).vis.lambda = unshaded.lambda;
cal(c).vis.t_int_ms = meannonan(unshaded.t_int_ms);
cal(c).vis.unshaded = meannonan(unshaded.rate);
cal(c).vis.shaded = meannonan(shaded.rate);
cal(c).vis.sig = meannonan(unshaded.rate) - meannonan(shaded.rate);
% figure; plot(shaded.lambda, cal(c).vis.dirn,'-');
cal(c).vis.irrad = interp1(oriel.nm, oriel.irrad_fit, shaded.lambda,'pchip');
% irrad units mW/m^2/nm  same as W/m^s/um
spec_panel.vis.SWS_refl = interp1(spec_panel.nm, spec_panel.Refl, unshaded.lambda,'pchip');
cal(c).vis.resp = cal(c).vis.sig./(cal(c).vis.irrad.*spec_panel.vis.SWS_refl(1:256)./pi);

% replace day_vis_1s by day_nir_1s
unshaded =bundle_sas_raw(strrep(cal_files{c},'day_vis_1s','day_nir_1s'));
fstem = strtok(unshaded.fname,'.'); fstem = strrep(fstem,'Unshaded','Shaded');
fil = dir([unshaded.pname, fstem{:},'.*.csv']);
if length(fil)~=1
    shaded = getfullname([fstem{:},'.*.csv'],'shaded','Select shaded cal files');
else
    shaded = getfullname([fil.folder,filesep,fil.name],'shaded','Select shaded cal files');
end
shaded = bundle_sas_raw(shaded);

% dirn 
cal(c).nir.time = meannonan(unshaded.time);
cal(c).nir.lambda = unshaded.lambda;
cal(c).nir.t_int_ms = meannonan(unshaded.t_int_ms);
cal(c).nir.unshaded = meannonan(unshaded.rate);
cal(c).nir.shaded = meannonan(shaded.rate);
cal(c).nir.sig = meannonan(unshaded.rate) - meannonan(shaded.rate);
% figure; plot(shaded.lambda, cal(c).nir.dirn,'-');
cal(c).nir.irrad = interp1(oriel.nm, oriel.irrad_fit, shaded.lambda,'pchip');
% irrad units mW/m^2/nm  same as W/m^s/um
spec_panel.nir.SWS_refl = interp1(spec_panel.nm, spec_panel.Refl, unshaded.lambda,'pchip');
cal(c).nir.resp = cal(c).nir.sig./(cal(c).nir.irrad.*spec_panel.nir.SWS_refl(1:256)./pi);



figure; plot(cal(c).vis.lambda, cal(c).vis.resp,'.-',cal(c).nir.lambda,cal(c).nir.resp,'.-');
xlabel('wavelength [nm]'); ylabel('Resp [mW/m^2/nm/sr]');
title(sprintf(['VIS tint: %d, NIR tint: %d'],cal(c).vis.t_int_ms, cal(c).nir.t_int_ms));

resp_sws = [cal(c).nir.lambda; cal(c).nir.resp]';
[resp_stem, resp_dir] = gen_sws_resp_files(resp_sws,floor(cal(c).nir.time(1)), cal(c).nir.t_int_ms, pname);

resp_sws = [cal(c).vis.lambda; cal(c).vis.resp]';
[resp_stem, resp_dir] = gen_sws_resp_files(resp_sws,floor(cal(c).vis.time(1)), cal(c).vis.t_int_ms, pname);

            clear header
            header(1) = {'% SWS Si radiance calibration at ENA by Albert Mendoza'};
            header(end+1) = {['% Calibration_date: ',datestr(cal(c).vis.time,'yyyy-mm-dd HH:MM:SS UTC')]};
            %             header(end+1) = {['% Cal_source: ',src_fname]};
            header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
            header(end+1) = {['% Lamps: Oriel 5115 at 0.5 m from 12"x12" Spectralon panel']};
            header(end+1) = {['% Spectrometer_type: Zeiss PGS']};
            header(end+1) = {['% Integration_time_ms: ',num2str(cal(c).vis.t_int_ms)]};
            header(end+1) = {['% Radiance = src_irrad * Refl / pi']};
            header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
            header(end+1) = {['pixel  lambda_nm   resp    signal      unshaded    shaded     Reflectance      src_irrad'] };            
            
            in_cal = [cal(c).vis.lambda', cal(c).vis.resp',cal(c).vis.sig', ...
                cal(c).vis.unshaded', cal(c).vis.shaded', spec_panel.vis.SWS_refl', ...
                cal(c).vis.irrad']';            

            [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,cal(c).vis.time, cal(c).vis.t_int_ms,pname);



            clear header
            header(1) = {'% SWS InGaAs radiance calibration at ENA by Albert Mendoza'};
            header(end+1) = {['% Calibration_date: ',datestr(cal(c).nir.time,'yyyy-mm-dd HH:MM:SS UTC')]};
            %             header(end+1) = {['% Cal_source: ',src_fname]};
            header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
            header(end+1) = {['% Lamps: Oriel 5115 at 0.5 m from 12"x12" Spectralon panel']};
            header(end+1) = {['% Spectrometer_type: Zeiss PGS']};
            header(end+1) = {['% Integration_time_ms: ',num2str(cal(c).nir.t_int_ms)]};
            header(end+1) = {['% Radiance = src_irrad * Refl / pi']};
            header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
            header(end+1) = {['pixel  lambda_nm   resp    signal      unshaded    shaded     Reflectance      src_irrad'] };            
            
            in_cal = [cal(c).nir.lambda', cal(c).nir.resp',cal(c).nir.sig', ...
                cal(c).nir.unshaded', cal(c).nir.shaded', spec_panel.nir.SWS_refl', ...
                cal(c).nir.irrad']';            

            [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,cal(c).nir.time, cal(c).nir.t_int_ms,pname);

end



