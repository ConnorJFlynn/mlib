function [vis_cal, nir_cal] = Radiance_cals_SASZe_auto(sas_pname);
% [vis_cal, nir_cal] = Radiance_cals_SASZe_auto(pname)
% 2013-12-22: generalizing radiance calibration for SASZe to support a
% proscribed directory structure for the calibration set.
% The trunk directory will identify the instrument and the cal source.
% Inside this trunk data will be stored in "Lamps_n" directories.
% The cals will loop over all "Lamps_*" directories found.
%
% At the least, this code should compute responsivities for each lamp
% setting and integration time.
% Optimally, it also should incorporate
% A) determination of linearity (vs WD or rate) Flynn
% B) determination of gain and read_noise (Kiedron)
% C) dark(lambda) for each time
% D) attribution of dark to read noise and thermal (Jakel)

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
rad = get_hiss_June2013;
field = fieldnames(rad);
%Trim NaN radiances
while isNaN(rad.nm(end))
    rad.nm(end) = [];
    for f = 1:length(field)
        if ~isempty(strfind(field,'lamp'))
            rad.(char(field(f)))(end) = [];
        end
    end
end
if ~exist('sas_pname','var')||~exist(sas_pname, 'dir')
    sas_pname = getdir('','rad_cals', 'Select directory containing radiance calibrations');
end

lamp_dirs = dir([sas_pname,'Lamps_*']);
lamps = [];
for ll = length(lamp_dirs):-1:1
    lamp_dir = lamp_dirs(ll).name;
    [~,lamp_tok] = strtok(lamp_dir,'_'); lamp_tok(1) = [];
    lamps = unique([lamps,sscanf(strrep(lamp_tok,'p','.'),'%g')]);
end
% sas_pname = ['D:\case_studies\radiation_cals\2013_12_20.SGP_LAB12_SASZe1_cals\socket_A_and_C.postclean_predeploy\'];

% fid = fopen([src_dir, src_fname],'r');
% tmp = textscan(fid,'%f %f %f %f %f %f %f %f %f ','headerlines',15)
% %
% fclose(fid);
%%

%%
% Build a structure versus cal.lamp_N.vis/nir
% Retain well-depth
% Cross-reference integration time

k = 0;
lamps = fliplr(lamps);
for ll = lamps
    close('all')
    lamp = num2str(ll);
    k = k+1;
    lamp_str = ['Lamps_',sprintf('%d',ll)]
    
    %     [nir_files, pname]= dir_list([sas_pname, lamp_str,filesep,'*_nir_1s*.csv'],'sasze_cal');
    [nir_files]= dir([sas_pname, lamp_str,filesep,'*_nir_1s*.csv']);
    
    file_n = 1;
    if exist([sas_pname, lamp_str,filesep,nir_files(file_n).name],'file')&&...
            exist([sas_pname, lamp_str,filesep, strrep(nir_files(file_n).name, '_nir_','_vis_')], 'file')
        nir_ = rd_raw_SAS([sas_pname, lamp_str,filesep,nir_files(file_n).name]);
        
        SAS_unit_i = strfind(nir_.pname, 'SASZe');
        if ~isempty(SAS_unit_i)&&(SAS_unit_i~=0)
            SAS_unit = nir_.pname(SAS_unit_i+[0:5]);
        end
        filename = [nir_.pname, strrep(nir_.fname{:}, '_nir_','_vis_')];
        vis_ = rd_raw_SAS(filename);
        light = nir_.Shutter_open_TF==1;
        light(1:end-1) = light(1:end-1)&light(2:end); light(2:end) = light(1:end-1)&light(2:end);light(1) = false;
        dark = nir_.Shutter_open_TF==0;
        dark(1:end-1) = dark(1:end-1)&dark(2:end); dark(2:end) = dark(1:end-1)&dark(2:end);dark(1) = false;
        vis_.light = light; vis_.dark = dark;
        nir_.light = light; nir_.dark = dark;
        figure(25);
        ax(1) = subplot(2,1,1);
        plot(vis_.lambda, vis_.spec(light,:), '-b',vis_.lambda, nanmean(vis_.spec(light,:)),'k-', ...
            nir_.lambda, nir_.spec(light,:), '-r',nir_.lambda, nanmean(nir_.spec(light,:)), 'k-');
        title([lamp_str, ': ',nir_.fname{:}],'interp','none')
        ax(2) = subplot(2,1,2);
        plot(vis_.lambda, 100.*(vis_.spec(light,:)-ones([sum(light),1])*nanmean(vis_.spec(light,:)))...
            ./(ones([sum(light),1])*nanmean(vis_.spec(light,:))),'b.', ...
            nir_.lambda, 100.*(nir_.spec(light,:)-ones([sum(light),1])*nanmean(nir_.spec(light,:)))...
            ./(ones([sum(light),1])*nanmean(nir_.spec(light,:))), 'r.');
        linkaxes(ax,'x');
        %         figure(1);
        [lambda, lam_ii] = sort([vis_.lambda, nir_.lambda]);
        rad.(['lamps_',lamp,'_fit']) = planck_tungsten_fit(rad.nm, rad.(['lamps_',lamp]),lambda);
        rad_ii.rad(lam_ii) = rad.(['lamps_',lamp,'_fit']).Irad;
        rad_ii.vis = rad_ii.rad(1:length(vis_.lambda));
        rad_ii.nir = rad_ii.rad(length(vis_.lambda)+1:end);
        
        for file_n = 2:length(nir_files)
            nir = rd_raw_SAS([nir_.pname,nir_files(file_n).name]);
            tmp = nir.spec>=(2^16 -1);
            nir_nrow_NaNs = sum(tmp,1);
            nir_ncol_NaNs = sum(tmp,2);
            if sum(nir_nrow_NaNs)>0||sum(nir_ncol_NaNs)>0
                sprintf('sum(nir_nrow_NaNs)=%d',sum(nir_nrow_NaNs))
            end
            nir.spec(tmp) = NaN;
            
            filename = [nir.pname, strrep(nir.fname{:}, '_nir_','_vis_')];
            vis = rd_raw_SAS(filename);
            %nir and vis have both been read in.
            %Check for saturated values.
            tmp_ = vis.spec>=(2^16 -1);
            vis_nrow_NaNs = sum(tmp_,1);
            vis_ncol_NaNs = sum(tmp_,2);
            if sum(vis_nrow_NaNs)>0||sum(vis_ncol_NaNs)>0
                sprintf('sum(vis_nrow_NaNs)=%d',sum(vis_nrow_NaNs))
            end
            vis.spec(tmp_) = NaN;
            
            % define light and dark as subset of shutter positions with
            % edges excluded.
            light = nir.Shutter_open_TF==1;
            light(1:end-1) = light(1:end-1)&light(2:end); light(2:end) = light(1:end-1)&light(2:end);light(1) = false;
            dark = nir.Shutter_open_TF==0;
            dark(1:end-1) = dark(1:end-1)&dark(2:end); dark(2:end) = dark(1:end-1)&dark(2:end);dark(1) = false;
            vis.light = light; vis.dark = dark;
            nir.light = light; nir.dark = dark;
            figure(25);
            ax(1) = subplot(2,1,1);
            plot(vis.lambda, vis.spec(light,:), '-b',vis.lambda, nanmean(vis.spec(light,:)),'k-', ...
                nir.lambda, nir.spec(light,:), '-r',nir.lambda, nanmean(nir.spec(light,:)), 'k-');
            title([lamp_str, ': ', nir.fname{:}],'interp','none')
            ax(2) = subplot(2,1,2);
            plot(vis.lambda, 100.*(vis.spec(light,:)-ones([sum(light),1])*nanmean(vis.spec(light,:)))...
                ./(ones([sum(light),1])*nanmean(vis.spec(light,:))),'b.', ...
                nir.lambda, 100.*(nir.spec(light,:)-ones([sum(light),1])*nanmean(nir.spec(light,:)))...
                ./(ones([sum(light),1])*nanmean(nir.spec(light,:))), 'r.');
            linkaxes(ax,'x');
            
            %%
            if ~exist('nir_','var')
                nir_ = nir;
                vis_ = vis;
            else
                nir_ = catsas(nir_, nir);
                vis_ = catsas(vis_, vis);
            end
        end
        nir = nir_; clear nir_
        vis = vis_; clear vis_
        % Now we've read all the files for this lamp setting, generated tightened determinations of "light" and "dark",
        % and concatenated under vis and nir structs.
        
        save([sas_pname,'SASZe_radcals.',lamp_str,'.nir.', datestr(nir.time(1),'yyyymmdd_HHMMSS'),'.mat'],'-struct','nir');
        save([sas_pname,'SASZe_radcals.',lamp_str,'.vis.', datestr(nir.time(1),'yyyymmdd_HHMMSS'),'.mat'],'-struct','vis')
        %         cal.(lamp_str).vis.t_int_ms = unique(vis.t_int_ms);
        lamp_cal.vis = vis; clear vis
        lamp_cal.nir = nir; clear nir
        spec_str = {'vis','nir'};
        for spc_ = spec_str; spc = char(spc_);
            light = lamp_cal.(spc).light;
            dark = lamp_cal.(spc).dark;
            t_int_ms = lamp_cal.(spc).t_int_ms(light);
            N_avg = lamp_cal.(spc).spectra_avg(light);
            cts_avg = lamp_cal.(spc).spec(light,:);
            dks_avg = lamp_cal.(spc).spec(dark,:);
            dks_at_light = interp1(find(dark),dks_avg,find(light),'nearest');
            sig_avg = cts_avg - dks_at_light;
            sig_cts = N_avg*ones([1,size(cts_avg,2)]) .* sig_avg;
            
            cal.(lamp_str).(spc).t_int_ms = unique(t_int_ms);
            cal.(lamp_str).(spc).lambda = lamp_cal.(spc).lambda;
            cal.(lamp_str).(spc).resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
            
            for vt = 1:length(cal.(lamp_str).(spc).t_int_ms)
                clear header
                header(1) = {['% SASZeM1 ',upper(spc),' radiance calibration at NASA ARC by Connor Flynn']};
                %%
                %             vt = vt +1;
                cal.(lamp_str).(spc).time = min(lamp_cal.(spc).time(lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt)));
                
                N_avg = lamp_cal.(spc).spectra_avg(light & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt));
                cts_avg = lamp_cal.(spc).spec(light & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt),:);
                dks_avg = lamp_cal.(spc).spec(dark & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt),:);
                sig_avg = cts_avg - ones([size(cts_avg,1),1])*mean(dks_avg);
                sig_cts = N_avg*ones([1,size(cts_avg,2)]) .* sig_avg;
                mean_cts = nanmean(sig_cts,1);
                var_cts = nanvar(sig_cts,1);
                
                %%
%                 blah
                cal.(lamp_str).(spc).(['N_avg_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) = ...
                    sum(lamp_cal.(spc).spectra_avg(light & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt)));
                cal.(lamp_str).(spc).(['light_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) ...
                    = meannonan(lamp_cal.(spc).spec(light & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt),:));
                cal.(lamp_str).(spc).(['welldepth_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) ...
                    = cal.(lamp_str).(spc).(['light_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])./(2.^16 -1);
                cal.(lamp_str).(spc).(['dark_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) ...
                    = meannonan(lamp_cal.(spc).spec(dark & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt),:));
                cal.(lamp_str).(spc).(['sig_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])...
                    = cal.(lamp_str).(spc).(['light_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) ...
                    - cal.(lamp_str).(spc).(['dark_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']);
                cal.(lamp_str).(spc).(['rate_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) ...
                    = cal.(lamp_str).(spc).(['sig_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])...
                    ./cal.(lamp_str).(spc).t_int_ms(vt);
                %             rad_ii(lam_ii) = (rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis.lambda)));
                cal.(lamp_str).(spc).(['resp_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']) ...
                    = cal.(lamp_str).(spc).(['rate_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])...
                    ./rad_ii.(spc);
                %             cal.(lamp_str).vis.(['resp_',strrep(num2str(cal.(lamp_str).vis.t_int_ms(vt)),'.','p'),'_ms']) ...
                %                 = cal.(lamp_str).vis.(['rate_',strrep(num2str(cal.(lamp_str).vis.t_int_ms(vt)),'.','p'),'_ms'])...
                %                 ./(rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis.lambda)));
                
                figure; scatter(mean_cts, var_cts,8,lamp_cal.(spc).lambda);colorbar
                title([upper(spc),' at ',sprintf('%g ms',cal.(lamp_str).(spc).t_int_ms(vt))]);
                
                %             figure;
                % good = ~isNaN(avanir.mean_sig)&~isNaN(avanir.var_sig)&(avanir.mean_sig>0)&(avanir.var_sig>0)&...
                %    (CCD.good)&(CCD.nm>975)&(CCD.nm<1250);
                % scatter(avanir.mean_sig(good),(avanir.var_sig(good)), 8,avanir.nm(good));colorbar;
                % title('Avaspec avanir LS0601005 variance vs signal')
                % xlabel('dark-subtracted signal')
                % ylabel('variance')
                % hold('on')
                
                % [P_avanir,S_avanir,MU_avanir] = polyfit(avanir.mean_sig(good),(avanir.var_sig(good)),1);
                % read_noise_variance = polyval(P_avanir,-MU_avanir(1)./MU_avanir(2));
                % avanir.read_noise_variance = read_noise_variance;
                % spec_g = P_avanir(1)./MU_avanir(2);
                % avanir.spec_g = spec_g;
                % plot(avanir.mean_sig(good), polyval(P_avanir,avanir.mean_sig(good),S_avanir,MU_avanir),'r-');
                % hold('off')
                % tx1 = text(.03,.9,...
                %    {['g= ',sprintf('%2.2e cts/e',spec_g)],...
                %    [sprintf('1/g = %.0f e/cts',1./spec_g)],...
                %    ['read noise variance =',sprintf('%2.2f',read_noise_variance)]},...
                %    'units','normal','backgroundcolor','w','edgecolor','k','fontname','Tahoma','fontweight','bold');
                zoom('on');
                %             k = menu('Zoom in, select save or skip when done.','save','skip');
                %             if k ==1
                %                 saveas(gcf,[plot_path, spec_desc, '_g'],'fig');
                %                 saveas(gcf,[plot_path, spec_desc, '_g'],'png');
                %             end
                
                
                figure(8);
                sa(1) = subplot(2,1,1);
                plot(lamp_cal.(spc).lambda,  cal.(lamp_str).(spc).(['light_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']), 'c-',...
                    lamp_cal.(spc).lambda, cal.(lamp_str).(spc).(['dark_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']), 'r-',...
                    lamp_cal.(spc).lambda, cal.(lamp_str).(spc).(['sig_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']), 'b-');
                title([upper(spc),' spectrometer: ',lamp,' Lamps, t_int_ms=',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p')],'interp','none');
                legend('lights','darks','signal')
                sa(2) = subplot(2,1,2);
                plot(lamp_cal.(spc).lambda, lamp_cal.(spc).spec(light & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt),:)...
                    -(ones([sum(light & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt)),1])*...
                    cal.(lamp_str).(spc).(['light_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])),'b.',...
                    lamp_cal.(spc).lambda, lamp_cal.(spc).spec(dark & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt),:)...
                    -(ones([sum(dark & lamp_cal.(spc).t_int_ms==cal.(lamp_str).(spc).t_int_ms(vt)),1])*...
                    cal.(lamp_str).(spc).(['dark_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])),'k.')
                legend('signal-mean', 'dark-mean');
                linkaxes(sa,'x');
                figure(9)
                sb(1) = subplot(2,1,1);
                plot(lamp_cal.(spc).lambda, cal.(lamp_str).(spc).(['rate_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']), 'b-');
                title([upper(spc),' spectrometer: ',lamp,' Lamps, t_int_ms=',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p')],'interp','none');
                legend('rate')
                sb(2) = subplot(2,1,2);
                plot(lamp_cal.(spc).lambda, cal.(lamp_str).(spc).(['resp_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']), 'r-');
                legend('resp');
                linkaxes(sb,'x');
                %%
                v = axis;
                %         done = menu('Zoom in to place lowest acceptable responsivity at left-hand axis limit.','OK');
                %         xl_lower = xlim;
                %         axis(v);
                %         done = menu('Zoom in to place higheest acceptable responsivity at right-hand axis limit.','OK');
                %         xl_upper = xlim;
                if strcmp(spc,'vis')
                    xl_lower(1) = 350; xl_upper(2) = 1100;
                else
                    xl_lower(1) = 970; xl_upper(2) = 1700;
                end
                bad = lamp_cal.(spc).lambda < xl_lower(1) | lamp_cal.(spc).lambda > xl_upper(2);
                cal.(lamp_str).(spc).(['resp_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms'])(bad) = NaN;
                xlim([xl_lower(1),xl_upper(2)]);
                
                i = 1;
                while (i < length(lamp_cal.(spc).header))&&isempty(strfind(lamp_cal.(spc).header{i},'SN ='))
                    i = i +1;
                end
                %         !! right here!
                header(end+1) = {['% SAS_unit: ' SAS_unit]};
                header(end+1) = {['% Calibration_date: ',datestr(lamp_cal.(spc).time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
                header(end+1) = {['% Cal_source: ',src_fname]};
                header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
                header(end+1) = {['% Lamps: ',num2str(lamp)]};
                header(end+1) = {['% Spectrometer_type: CCD2048']};
                header(end+1) = strrep(lamp_cal.(spc).header(i),'SN =', 'Spectrometer_SN:');
                header(end+1) = {['% Integration_time_ms: ',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p')]};
                header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
                header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
                
                %%
                
                in_cal = [cal.(lamp_str).(spc).lambda; cal.(lamp_str).(spc).(['resp_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']);...
                    cal.(lamp_str).(spc).(['rate_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']);cal.(lamp_str).(spc).(['sig_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']);...
                    cal.(lamp_str).(spc).(['light_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']);cal.(lamp_str).(spc).(['dark_',strrep(num2str(cal.(lamp_str).(spc).t_int_ms(vt)),'.','p'),'_ms']);...
                    (rad.(['lamps_',lamp,'_fit']).Irad(1:length(lamp_cal.(spc).lambda)))];
                
                [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,cal.(lamp_str).(spc).time, cal.(lamp_str).(spc).t_int_ms(vt),lamp_cal.(spc).pname);
                %             save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','cal');
                saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
                %     menu('OK','OK')
            end
            
            
        end
        sascal.(lamp_str) = lamp_cal;
        
        
    else
        disp('No suitable files in directory?')
    end
end
save([sas_pname, strrep(resp_stem,'.dat','.mat')],'-struct','cal');

return