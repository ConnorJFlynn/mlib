function [vis_cal, nir_cal] = Radiance_cals_SASZe2_GSFC_Grande
% Based on Radiance_cals_SASZe2_GSFC_postTCAP1 etc but attempting to make generally applicable to any
% calibration done with SASZE and Grande.
% We need the directory path to contain information on the SASZE unit
% number and the number of Lamps turned on following this pattern:
% 2013_03_14.AMF1_SASZe2.ZeOrigOptics_Shadowband_GSFC_Cal

% Then for each spectrometer file, unique responsivities for each integration time are computed and
% written to file by the function "gen_sasze_resp_files".
% gen_sasze_resp_files applies the pattern:
%   ['sasze1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db,'.dat']
% which does not include the lamp number.

rad = get_grande;
% src_dir = 'D:\case_studies\radiation_cals\spheres\GSFC_Grande\';
% src_fname = '20121206134000Grande.txt';
% src_fname = '20130523_Grande.txt';
% 
% fid = fopen([src_dir, src_fname],'r');
% in_line = fgetl(fid);
% while (isempty(strfind(in_line,'lamps'))||isempty(strfind(in_line,'lamp')))&&~feof(fid)
%     in_line = fgetl(fid);
% end
% mark = ftell(fid);
% first_row = fgetl(fid);
% fseek(fid,mark,-1);
% tmp = textscan(first_row,'%f ');
% 
% tmp = textscan(fid,repmat('%f ',[1,length(tmp{:})]));
% %
% fclose(fid);
% %%
% rad.nm = tmp{1};
% rad.lamps_8 = tmp{2};
% rad.lamps_7 = tmp{3};
% rad.lamps_6 = tmp{4};
% rad.lamps_5 = tmp{5};
% rad.lamps_4 = tmp{6};
% rad.lamps_3 = tmp{7};
% rad.lamps_2 = tmp{8};
% rad.lamps_1 = tmp{9};
% if length(tmp)>9
%     rad.lamps_1_att_100 = tmp{10};
%     rad.lamps_1_att_50 = tmp{11};
%     rad.lamps_1_att_30 = tmp{12};
% end
% rad.units = 'W/(m^2.sr.um)';
% while isNaN(rad.nm(end))
%     rad.nm(end) = [];
%     rad.lamps_8(end) = [];
%     rad.lamps_7(end) = [];
%     rad.lamps_6(end) = [];
%     rad.lamps_5(end) = [];
%     rad.lamps_4(end) = [];
%     rad.lamps_3(end) = [];
%     rad.lamps_2(end) = [];
%     rad.lamps_1(end) = [];
%     if length(tmp)>9
%         rad.lamps_1_att_100(end) = [];
%         rad.lamps_1_att_50(end) = [];
%         rad.lamps_1_att_30(end) = [];
%     end
% end

%% 3-lamp preclean
nir_file = getfullname('*SASZe*nir*.csv','SASZE_cals','Select SASZe NIR cal file.');
nir = rd_raw_SAS(nir_file);

SAS_unit_i = strfind(nir.pname, 'SASZe');
if ~isempty(SAS_unit_i)
SAS_unit = nir.pname(SAS_unit_i+[0:5]);
end
lamp_i = strfind(nir.pname, 'Lamp')
if ~isempty(lamp_i)
    lamp = nir.pname(lamp_i-1);
end

if ~isempty(strfind(nir.pname, '1Lamps1'))
    lamp = [lamp, '_att_100'];
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
    if ~exist('vxl_lower','var')
        v = axis;
        done = menu('Zoom in to place lowest wavelength limit at LH axis limit.','OK');
        xl_lower = xlim; vxl_lower = round(xl_lower(1));
        axis(v);
        done = menu('Zoom in to place highest wavelength limit at RH axis limit.','OK');
    xl_upper = xlim; vxl_upper = round(xl_upper(2));
end
    bad = vis.lambda < vxl_lower | vis.lambda > vxl_upper;
    axis(v);
    vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])(bad) = NaN;
    
        clear header
    header(1) = {'% SAS-Ze1 VIS radiance calibration at NASA GSFC by Albert Mendoza'};
    i = 1;
    while (i < length(vis.header))&&isempty(strfind(vis.header{i},'SN ='))
        i = i +1;
    end
    header(end+1) = {['% SAS_unit: ', SAS_unit]};
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
    
    [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,vis_cal.time, vis_cal.t_int_ms(vt),vis.pname);
    save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','vis_cal');
    saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
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
    linkaxes(sd,'x');
    %%
    if ~exist('nxl_lower','var')
        v = axis;
        done = menu('Zoom in to place lowest wavelength limit at LH axis limit.','OK');
        xl_lower = xlim; nxl_lower = round(xl_lower(1));
        axis(v);
        done = menu('Zoom in to place higheest wavelength limit at RH axis limit.','OK');
        xl_upper = xlim; nxl_upper = round(xl_upper(2));
    end
    bad = nir.lambda < nxl_lower | nir.lambda > nxl_upper;
    axis(v);
    nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms'])(bad) = NaN;
    %%
    clear header
    header(1) = {'% SAS-Ze2 NIR radiance calibration at NASA GSFC by Albert Mendoza'};
    i = 1;
    while (i < length(nir.header))&&isempty(strfind(nir.header{i},'SN ='))
        i = i +1;
    end
    header(end+1) = {['% SAS_unit: ',SAS_unit]};
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
    
    [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,nir_cal.time, nir_cal.t_int_ms(vt),nir.pname);
    save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','vis_cal');
    saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
    %     menu('OK','OK')
end

%%

return