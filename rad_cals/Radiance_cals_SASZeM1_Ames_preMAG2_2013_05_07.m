function [vis_cal, nir_cal] = Radiance_cals_SASZeM1_Ames_preMAG2_2013_05_07
% C:\case_studies\radiation_cals\2013_03_14.AMF1_ZeOrigOptics_Shadowband_GSFC_Cal
% Measurements taken by Connor at NASA Ames in May, just prior to MAG2
% after the fiber broke during shipping after Albert's calibration trip to GSFC

% This code reads the source calibrated radiances, and let's the user
% select a pair of vis and nir data files contained in a directory that
% identifies the number of lamps illuminated for the source.
% Then for each spectrometer file, unique responsivities for each integration time are computed and
% written to file by the function "gen_sasze_resp_files".
% gen_sasze_resp_files applies the pattern:
%   ['sasze1.resp_func.',datestr(time,'yyyymmdd0000'),det_str,num2str(tint),'ms',db,'.dat']
% which does not include the lamp number.
% data directory = C:\case_studies\radiation_cals\2013_05_07.NASA_ARC_SASZe1_cals
src_dir = 'D:\case_studies\radiation_cals\spheres\HISS\';
src_fname = '201112131052Hiss-corrected.txt';
rad = get_hiss_Nov2011;
% fid = fopen([src_dir, src_fname],'r');
% tmp = textscan(fid,'%f %f %f %f %f %f %f %f %f ','headerlines',15)
% %
% fclose(fid);
%%
field = fieldnames(rad);
while isNaN(rad.nm(end))
    rad.nm(end) = [];
    for f = 1:length(field)
        if ~isempty(strfind(field,'lamp'))
            rad.(char(field(f)))(end) = [];
        end
    end
end

%% 12-lamp preclean
% raw_data_dir = uigetdir;
[nir_files, pname]= dir_list('*_nir_1s*.csv','sasze_cal');
file_n = 1;
if exist([pname,nir_files(file_n).name],'file')&&exist([pname, strrep(nir_files(file_n).name, '_nir_','_vis_')], 'file')
    nir = rd_raw_SAS([pname,nir_files(file_n).name]);
    
    SAS_unit_i = strfind(nir.pname, 'SASZe');
    if ~isempty(SAS_unit_i)&&(SAS_unit_i~=0)
        SAS_unit = nir.pname(SAS_unit_i+[0:5]);
    end
    lamp_i = strfind(nir.pname, 'Lamp');
    if ~isempty(lamp_i)&&(lamp_i~=0)
        tmp = (strtok(fliplr(nir.pname(1:lamp_i+3)),'_'));
        lamp = fliplr(tmp(5:end));
    end
    
    filename = [nir.pname, strrep(nir.fname{:}, '_nir_','_vis_')];
    vis = rd_raw_SAS(filename);
    
    figure(1);
    rad.(['lamps_',lamp,'_fit']) = planck_tungsten_fit(rad.nm, rad.(['lamps_',lamp]),[vis.lambda, nir.lambda]);

for file_n = 1:length(nir_files)
    nir = rd_raw_SAS([pname,nir_files(file_n).name]);
    tmp = nir.spec>=(2^16 -1);
    nir_nrow_NaNs = sum(tmp,1);
    nir_ncol_NaNs = sum(tmp,2);
    if sum(nir_nrow_NaNs)>0||sum(nir_ncol_NaNs)>0
        sprintf('sum(nir_nrow_NaNs)=%d',sum(nir_nrow_NaNs))
     end
    nir.spec(tmp) = NaN;
    
    SAS_unit_i = strfind(nir.pname, 'SASZe');
    if ~isempty(SAS_unit_i)&&(SAS_unit_i~=0)
        SAS_unit = nir.pname(SAS_unit_i+[0:5]);
    end
    lamp_i = strfind(nir.pname, 'Lamp');
    if ~isempty(lamp_i)&&(lamp_i~=0)
        tmp = (strtok(fliplr(nir.pname(1:lamp_i+3)),'_'));
        lamp = fliplr(tmp(5:end));
    end
    
    filename = [nir.pname, strrep(nir.fname{:}, '_nir_','_vis_')];
    vis = rd_raw_SAS(filename);
    tmp_ = vis.spec>=(2^16 -1);
    vis_nrow_NaNs = sum(tmp_,1);
    vis_ncol_NaNs = sum(tmp_,2);
    if sum(vis_nrow_NaNs)>0||sum(vis_ncol_NaNs)>0
        sprintf('sum(vis_nrow_NaNs)=%d',sum(vis_nrow_NaNs))
     end
    vis.spec(tmp_) = NaN;
    
    % emanp = fliplr(nir.pname); lamp = emanp(6);

    
    % rad.lamps_8_fit = planck_fit(rad.nm, rad.lamps_8,[vis.lambda, nir.lambda]);
    % rad.lamps_7_fit = planck_fit(rad.nm, rad.lamps_7,[vis.lambda, nir.lambda]);
    % rad.lamps_6_fit = planck_fit(rad.nm, rad.lamps_6,[vis.lambda, nir.lambda]);
    % rad.lamps_5_fit = planck_fit(rad.nm, rad.lamps_6,[vis.lambda, nir.lambda]);
    % rad.lamps_4_fit = planck_fit(rad.nm, rad.lamps_4,[vis.lambda, nir.lambda]);
    % rad.lamps_3_fit = planck_fit(rad.nm, rad.lamps_3,[vis.lambda, nir.lambda]);
    % rad.lamps_2_fit = planck_fit(rad.nm, rad.lamps_2,[vis.lambda, nir.lambda]);
    % rad.lamps_1_fit = planck_fit(rad.nm, rad.lamps_1,[vis.lambda, nir.lambda]);
    
    %%
    vis_cal.t_int_ms = unique(vis.t_int_ms);
    vis_cal.lambda = vis.lambda;
    vis_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
    %%
    for vt = 1:length(vis_cal.t_int_ms)
        clear header
        header(1) = {'% SASZeM1 VIS radiance calibration at NASA ARC by Connor Flynn'};
        
        vis_cal.time = min(vis.time(vis.t_int_ms==vis_cal.t_int_ms(vt)));
        
        vis_cal.(['light_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']) = meannonan(vis.spec(vis.Shutter_open_TF==1 & vis.t_int_ms==vis_cal.t_int_ms(vt),:));
        vis_cal.(['dark_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']) = meannonan(vis.spec(vis.Shutter_open_TF==0 & vis.t_int_ms==vis_cal.t_int_ms(vt),:));
        vis_cal.(['sig_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']) = vis_cal.(['light_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']) - vis_cal.(['dark_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']);
        vis_cal.(['rate_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']) = vis_cal.(['sig_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms'])./vis_cal.t_int_ms(vt);
        vis_cal.(['resp_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']) = vis_cal.(['rate_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms'])./(rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis.lambda)));
        figure(8);
        sa(1) = subplot(2,1,1);
        plot(vis.lambda,  vis_cal.(['light_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']), 'c-',...
            vis.lambda, vis_cal.(['dark_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']), 'r-',...
            vis.lambda, vis_cal.(['sig_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']), 'b-');
        title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p')],'interp','none');
        legend('lights','darks','signal')
        sa(2) = subplot(2,1,2);
        plot(vis.lambda, vis.spec(vis.Shutter_open_TF==1 & vis.t_int_ms==vis_cal.t_int_ms(vt),:)...
            -(ones([sum(vis.Shutter_open_TF==1 & vis.t_int_ms==vis_cal.t_int_ms(vt)),1])*...
            vis_cal.(['light_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms'])),'b.',...
            vis.lambda, vis.spec(vis.Shutter_open_TF==0 & vis.t_int_ms==vis_cal.t_int_ms(vt),:)...
            -(ones([sum(vis.Shutter_open_TF==0 & vis.t_int_ms==vis_cal.t_int_ms(vt)),1])*...
            vis_cal.(['dark_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms'])),'k.')
        legend('signal-mean', 'dark-mean');
        linkaxes(sa,'x');
        figure(9)
        sb(1) = subplot(2,1,1);
        plot(vis.lambda, vis_cal.(['rate_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']), 'b-');
        title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p')],'interp','none');
        legend('rate')
        sb(2) = subplot(2,1,2);
        plot(vis.lambda, vis_cal.(['resp_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']), 'r-');
        legend('resp');
        linkaxes(sb,'x');
        %%
        v = axis;
%         done = menu('Zoom in to place lowest acceptable responsivity at left-hand axis limit.','OK');
%         xl_lower = xlim;
%         axis(v);
%         done = menu('Zoom in to place higheest acceptable responsivity at right-hand axis limit.','OK');
%         xl_upper = xlim;
        xl_lower(1) = 350; xl_upper(2) = 1100;
        bad = vis.lambda < xl_lower(1) | vis.lambda > xl_upper(2);
        vis_cal.(['resp_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms'])(bad) = NaN;
        xlim([xl_lower(1),xl_upper(2)]);

        
        i = 1;
        while (i < length(vis.header))&&isempty(strfind(vis.header{i},'SN ='))
            i = i +1;
        end
%         !! right here!
        header(end+1) = {['% SAS_unit: ' SAS_unit]};
        header(end+1) = {['% Calibration_date: ',datestr(vis.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
        header(end+1) = {['% Cal_source: ',src_fname]};
        header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
        header(end+1) = {['% Lamps: ',num2str(lamp)]};
        header(end+1) = {['% Spectrometer_type: CCD2048']};
        header(end+1) = strrep(vis.header(i),'SN =', 'Spectrometer_SN:');
        header(end+1) = {['% Integration_time_ms: ',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p')]};
        header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
        header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
        
        %%
        
        in_cal = [vis_cal.lambda; vis_cal.(['resp_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']);...
            vis_cal.(['rate_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']);vis_cal.(['sig_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']);...
            vis_cal.(['light_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']);vis_cal.(['dark_',strrep(num2str(vis_cal.t_int_ms(vt)),'.','p'),'_ms']);...
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
        clear header
        header(1) = {'% SASZeM1 NIR radiance calibration at NASA ARC by Connor Flynn'};
        
        nir_cal.time = min(nir.time(nir.t_int_ms==nir_cal.t_int_ms(vt)));
        nir_cal.(['light_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']) = meannonan(nir.spec(nir.Shutter_open_TF==1 & nir.t_int_ms==nir_cal.t_int_ms(vt),:));
        nir_cal.(['dark_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']) = meannonan(nir.spec(nir.Shutter_open_TF==0 & nir.t_int_ms==nir_cal.t_int_ms(vt),:));
        nir_cal.(['sig_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']) = nir_cal.(['light_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']) - nir_cal.(['dark_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']);
        nir_cal.(['rate_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']) = nir_cal.(['sig_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms'])./nir_cal.t_int_ms(vt);
        nir_cal.(['resp_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']) = nir_cal.(['rate_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms'])./(rad.(['lamps_',lamp,'_fit']).Irad(1+length(vis.lambda):end));
        figure(10);
        sc(1) = subplot(2,1,1);
        plot(nir.lambda,  nir_cal.(['light_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']), 'c-',...
            nir.lambda, nir_cal.(['dark_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']), 'r-',...
            nir.lambda, nir_cal.(['sig_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']), 'b-');
        title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p')],'interp','none');
        legend('lights','darks','signal')
        sc(2) = subplot(2,1,2);
        plot(nir.lambda, nir.spec(nir.Shutter_open_TF==1 & nir.t_int_ms==nir_cal.t_int_ms(vt),:)...
            -(ones([sum(nir.Shutter_open_TF==1 & nir.t_int_ms==nir_cal.t_int_ms(vt)),1])*...
            nir_cal.(['light_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms'])),'b.',...
            nir.lambda, nir.spec(nir.Shutter_open_TF==0 & nir.t_int_ms==nir_cal.t_int_ms(vt),:)...
            -(ones([sum(nir.Shutter_open_TF==0 & nir.t_int_ms==nir_cal.t_int_ms(vt)),1])*...
            nir_cal.(['dark_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms'])),'k.')
        legend('signal-mean', 'dark-mean');
        figure(11);
        sd(1) = subplot(2,1,1);
        plot(nir.lambda, nir_cal.(['rate_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']), 'b-');
        title(['nir spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
        legend('rate')
        sd(2) = subplot(2,1,2);
        plot(nir.lambda, nir_cal.(['resp_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']), 'r-');
        legend('resp');
        linkaxes(sd,'x')
        %%
        v = axis;
%         done = menu('Zoom in to place lowest acceptable responsivity at left-hand axis limit.','OK');
%         xl_lower = xlim;
%         axis(v);
%         done = menu('Zoom in to place higheest acceptable responsivity at right-hand axis limit.','OK');
%         xl_upper = xlim;
        xl_lower(1) = 905; xl_upper(2) = 1750;
        bad = nir.lambda < xl_lower(1) | nir.lambda > xl_upper(2);
        nir_cal.(['resp_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms'])(bad) = NaN;
        xlim([xl_lower(1),xl_upper(2)]);
        %%
        i = 1;
        while (i < length(nir.header))&&isempty(strfind(nir.header{i},'SN ='))
            i = i +1;
        end
        header(end+1) = {['% SAS_unit: ' SAS_unit]};
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
        in_cal = [nir_cal.lambda; nir_cal.(['resp_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']);...
            nir_cal.(['rate_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']);nir_cal.(['sig_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']);...
            nir_cal.(['light_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']);nir_cal.(['dark_',strrep(num2str(nir_cal.t_int_ms(vt)),'.','p'),'_ms']);...
            (rad.(['lamps_',lamp,'_fit']).Irad(1+length(vis.lambda):end))];
        
        [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,nir_cal.time, nir_cal.t_int_ms(vt),nir.pname);
        save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','vis_cal');
        saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
        %     menu('OK','OK')
    end
end
%%
else
    disp('No suitable files in directory?')
end
return