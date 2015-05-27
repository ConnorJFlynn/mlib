function [vis_cal, nir_cal] = Radiance_cals_SASZe2_GSFC_preASR_2013_03_14_premod
% C:\case_studies\radiation_cals\2013_03_14.AMF1_ZeOrigOptics_Shadowband_GSFC_Cal
% Measurements taken by Albert at GSFC in March, just prior to ASR STM
% with SWS, SASZe1 (before and after marine mods), and SASZe2. 
% Need to confirm if Grande was used and what the reduced 1-lamp cal is for
% SWS. 

% Collected pre-cleaning and post-clean calibrations for 8 and 3 lamps.
% This code reads the source calibrated radiances, and let's the user
% select a pair of vis and nir data files contained in a directory that
% identifies the number of lamps illuminated for the source.
% Then for each spectrometer file, unique responsivities for each integration time are computed and
% written to file by the function "gen_sasze_resp_files".
% gen_sasze_resp_files applies the pattern:
%   ['sasze1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db,'.dat']
% which does not include the lamp number.

src_dir = 'D:\case_studies\radiation_cals\spheres\GSFC_Grande\';
src_fname = '20121206134000Grande.txt';

fid = fopen([src_dir, src_fname],'r');
tmp = textscan(fid,'%f %f %f %f %f %f %f %f %f ','headerlines',29)
%
fclose(fid);
%%
rad.nm = tmp{1};
rad.lamps_8 = tmp{2};
rad.lamps_7 = tmp{3};
rad.lamps_6 = tmp{4};
rad.lamps_5 = tmp{5};
rad.lamps_4 = tmp{6};
rad.lamps_3 = tmp{7};
rad.lamps_2 = tmp{8};
rad.lamps_1 = tmp{9};
rad.units = 'W/(m^2.sr.um)';
while isNaN(rad.nm(end))
    rad.nm(end) = [];
    rad.lamps_8(end) = [];
    rad.lamps_7(end) = [];
    rad.lamps_6(end) = [];
    rad.lamps_5(end) = [];
    rad.lamps_4(end) = [];
    rad.lamps_3(end) = [];
    rad.lamps_2(end) = [];
    rad.lamps_1(end) = [];
end

%% 3-lamp preclean
nir = rd_raw_SAS;

SAS_unit_i = findstr(nir.pname, 'SASZe');
if ~isempty(SAS_unit_i)&&(SAS_unit_i~=0)
SAS_unit = nir.pname(SAS_unit_i+[0:5]);
end
lamp_i = findstr(nir.pname, 'Lamp')
if ~isempty(lamp_i)&&(lamp_i~=0)
    lamp = nir.pname(lamp_i-1);
end

filename = [nir.pname, strrep(nir.fname{:}, 'nir','vis')];
vis = rd_raw_SAS(filename);

% emanp = fliplr(nir.pname); lamp = emanp(6);
rad.(['lamps_',lamp,'_fit']) = planck_fit(rad.nm, rad.(['lamps_',lamp]),[vis.lambda, nir.lambda]);


% rad.lamps_8_fit = planck_fit(rad.nm, rad.lamps_8,[vis.lambda, nir.lambda]);
% rad.lamps_7_fit = planck_fit(rad.nm, rad.lamps_7,[vis.lambda, nir.lambda]);
% rad.lamps_6_fit = planck_fit(rad.nm, rad.lamps_6,[vis.lambda, nir.lambda]);
% rad.lamps_5_fit = planck_fit(rad.nm, rad.lamps_6,[vis.lambda, nir.lambda]);
% rad.lamps_4_fit = planck_fit(rad.nm, rad.lamps_4,[vis.lambda, nir.lambda]);
% rad.lamps_3_fit = planck_fit(rad.nm, rad.lamps_3,[vis.lambda, nir.lambda]);
% rad.lamps_2_fit = planck_fit(rad.nm, rad.lamps_2,[vis.lambda, nir.lambda]);
% rad.lamps_1_fit = planck_fit(rad.nm, rad.lamps_1,[vis.lambda, nir.lambda]);

%%
vis_cal.t_int_ms = unique(vis.t_int_ms)
vis_cal.lambda = vis.lambda;
vis_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
%%
for vt = 1:length(vis_cal.t_int_ms)
    vis_cal.time = min(vis.time(vis.t_int_ms==vis_cal.t_int_ms(vt)));
    
    vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = mean(vis.spec(vis.Shutter_open_TF==1 & vis.t_int_ms==vis_cal.t_int_ms(vt),:));
    vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = mean(vis.spec(vis.Shutter_open_TF==0 & vis.t_int_ms==vis_cal.t_int_ms(vt),:));
    vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']) - vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']);
    vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms'])./vis_cal.t_int_ms(vt);
    vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms'])./(rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis.lambda)));
    figure(8);
    sa(1) = subplot(2,1,1);
    plot(vis.lambda,  vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'c-',...
        vis.lambda, vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'r-');
    title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(vis_cal.t_int_ms(vt))],'interp','none');
    legend('lights','darks')
    sa(2) = subplot(2,1,2);
    plot(vis.lambda, vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'g-')
    legend('signal');
    linkaxes(sa,'x');
    figure(9)
    sb(1) = subplot(2,1,1);
    plot(vis.lambda, vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'b-');
    title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(vis_cal.t_int_ms(vt))],'interp','none');
    legend('rate')
    sb(2) = subplot(2,1,2);
    plot(vis.lambda, vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'r-');
    legend('resp');
    linkaxes(sb,'x');
    %%
    v = axis;
    done = menu('Zoom in to place lowest acceptable responsivity at left-hand axis limit.','OK');
    xl_lower = xlim;
    axis(v);
    done = menu('Zoom in to place higheest acceptable responsivity at right-hand axis limit.','OK');
    xl_upper = xlim;
    bad = vis.lambda < xl_lower(1) | vis.lambda > xl_upper(2);
    axis(v);
    vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])(bad) = NaN;
    
        clear header
    header(1) = {'% SAS-Ze1 VIS radiance calibration at NASA GSFC by Albert Mendoza'};
    i = 1;
    while (i < length(vis.header))&&isempty(strfind(vis.header{i},'SN ='))
        i = i +1;
    end
    header(end+1) = {['% SAS_unit: '; SAS_unit]};
    header(end+1) = {['% Calibration_date: ',datestr(vis.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
    header(end+1) = {['% Cal_source: ',src_fname]};
    header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
    header(end+1) = {['% Lamps: ',num2str(lamp)]};
    header(end+1) = {['% Spectrometer_type: CCD2048']};
    header(end+1) = strrep(vis.header(i),'SN =', 'Spectrometer_SN:');
    header(end+1) = {['% Integration_time_ms: ',num2str(vis_cal.t_int_ms(vt))]};
    header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
    header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
    
    %%
    
    in_cal = [vis_cal.lambda; vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']);...
        vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']);vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']);...
        vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']);vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']);...
        (rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis.lambda)))];
    
    [resp_stem, resp_dir] = gen_sasze_resp_files(in_cal,header,vis_cal.time, vis_cal.t_int_ms(vt),vis.pname);
    %     menu('OK','OK')
end

%%

nir_cal.t_int_ms = unique(nir.t_int_ms);
nir_cal.lambda = nir.lambda;
nir_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];

for vt = 1:length(nir_cal.t_int_ms)
    nir_cal.time = min(nir.time(nir.t_int_ms==nir_cal.t_int_ms(vt)));
    nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = mean(nir.spec(nir.Shutter_open_TF==1 & nir.t_int_ms==nir_cal.t_int_ms(vt),:));
    nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = mean(nir.spec(nir.Shutter_open_TF==0 & nir.t_int_ms==nir_cal.t_int_ms(vt),:));
    nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']) - nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']);
    nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms'])./nir_cal.t_int_ms(vt);
    nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms'])./(rad.(['lamps_',lamp,'_fit']).Irad(1+length(vis.lambda):end));
    figure(10);
    sc(1) = subplot(2,1,1);
    plot(nir.lambda,  nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'c-',...
        nir.lambda, nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
    title(['nir spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
    legend('lights','darks')
    sc(2) = subplot(2,1,2);
    plot(nir.lambda, nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'g-')
    legend('signal');
    linkaxes(sc,'x');
    figure(11);
    sd(1) = subplot(2,1,1);
    plot(nir.lambda, nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'b-');
    title(['nir spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
    legend('rate')
    sd(2) = subplot(2,1,2);
    plot(nir.lambda, nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
    legend('resp');
    linkaxes(sd,'x')
    %%
    clear header
    header(1) = {'% SAS-Ze2 NIR radiance calibration at NASA GSFC by Albert Mendoza'};
    i = 1;
    while (i < length(nir.header))&&isempty(strfind(nir.header{i},'SN ='))
        i = i +1;
    end
    header(end+1) = {['% SAS_unit: ';SAS_unit]};
    header(end+1) = {['% Calibration_date: ',datestr(nir.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
    header(end+1) = {['% Cal_source: ',src_fname]};
    header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
    header(end+1) = {['% Lamps: ',num2str(lamp)]};
    header(end+1) = {['% Spectrometer_type: NIR256']};
    header(end+1) = strrep(nir.header(i),'SN =', 'Spectrometer_SN:');
    header(end+1) = {['% Integration_time_ms: ',num2str(nir_cal.t_int_ms(vt))]};
    header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
    header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
    %%
    
    %
    in_cal = [nir_cal.lambda; nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']);...
        nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']);nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']);...
        nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']);nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']);...
        (rad.(['lamps_',lamp,'_fit']).Irad(1+length(vis.lambda):end))];
    
    [resp_stem, resp_dir] = gen_sasze_resp_files(in_cal,header,nir_cal.time, nir_cal.t_int_ms(vt),nir.pname);
    
    %     menu('OK','OK')
end

%%

return