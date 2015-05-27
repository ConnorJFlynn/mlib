function [Si_resp, In_resp] = Radiance_cals_SWS_vs_GSFC_Grande_2014_05_14
% 
%%

rad = get_grande('D:\case_studies\radiation_cals\spheres\GSFC_Grande\');
%%
done = false;
while ~done
    cal = menu('Compute responsivity or done?','Compute resp','Done');
    if cal==2
        done= true;
    else
        pause(.05);
        infile = getfullname('*.raw.dat','sws_cal','Select a SWS file in desired Lamp directory');
        
        [pname, fname] = fileparts(infile);pname = [pname, filesep];
        lamp_i = strfind(pname, 'lamp')
        if ~isempty(lamp_i)
            lamp = pname(lamp_i-1);
        end
        
        if ~isempty(strfind(pname, '1lamps1'))
            lamp = [lamp, '_att_100'];
        end
        files = dir([pname,'*.raw.dat']);
        sws =bundle_sws_raw_2(files,pname);
%         tmp = load([pname, filesep,files(1).name]); sws = tmp.sws_raw; clear tmp;
%         for f = 2:length(files)
%             tmp = load([pname, filesep,files(f).name]);
%             sws = cat_sws_raw_2(sws,tmp.sws_raw); clear tmp;
%         end
        rad.(['lamps_',lamp,'_fit']) = planck_fit(rad.nm, rad.(['lamps_',lamp]),[sws.Si_lambda]);
        
        %%
        vis_cal.t_int_ms = unique(sws.Si_ms)
        vis_cal.lambda = sws.Si_lambda;
        vis_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
        %%
        for vt = 1:length(vis_cal.t_int_ms)
            vis_cal.time = min(sws.time(sws.Si_ms==vis_cal.t_int_ms(vt)));
            
            vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = mean(sws.Si_spec(:,sws.shutter==0 & (sws.Si_ms==vis_cal.t_int_ms(vt))),2);
            vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = mean(sws.Si_spec(:,sws.shutter==1 & (sws.Si_ms==vis_cal.t_int_ms(vt))),2);
            
            vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']) - vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']);
            vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms'])./vis_cal.t_int_ms(vt);
            vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms'])./(rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis_cal.lambda)));
            figure(8);
            if ~exist('f8','var')
                f8.h = gcf;
                f8.pos = get(f8.h,'position');
            end
            sa(1) = subplot(2,1,1);
            plot(vis_cal.lambda,  vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'c-',...
                vis_cal.lambda, vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'r-');
            title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(vis_cal.t_int_ms(vt))],'interp','none');
            legend('lights','darks')
            sa(2) = subplot(2,1,2);
            plot(vis_cal.lambda, vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'g-')
            legend('signal');
            linkaxes(sa,'x');
            figure(9)
            set(gcf,'position',[f8.pos(1)+f8.pos(3)+50, f8.pos(2), f8.pos(3), f8.pos(4)]);
            sb(1) = subplot(2,1,1);
            plot(vis_cal.lambda, vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'b-');
            title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(vis_cal.t_int_ms(vt))],'interp','none');
            legend('rate')
            sb(2) = subplot(2,1,2);
            plot(vis_cal.lambda, vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'r-');
            legend('resp');
            linkaxes(sb,'x');
            %%
            vxl_lower = 349; vxl_upper = 1071;v1 = axis(sb(1));v2 = axis(sb(2));
            if ~exist('vxl_lower','var')
                v1 = axis(sb(1));v2 = axis(sb(2));
                zoom('on');
                done = menu('Zoom in to place lowest wavelength limit at LH axis limit.','OK');
                xl_lower = xlim; vxl_lower = round(xl_lower(1));
                axis(sb(1),v1);axis(sb(2),v2);
                zoom('on');
                done = menu('Zoom in to place highest wavelength limit at RH axis limit.','OK');
                xl_upper = xlim; vxl_upper = round(xl_upper(2));
            end
            bad = vis_cal.lambda < vxl_lower | vis_cal.lambda > vxl_upper;
            axis(sb(1),v1);axis(sb(2),v2);
            vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])(bad) = NaN;
            
            figure(9)
            sb(1) = subplot(2,1,1);
            plot(vis_cal.lambda, vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'b-');
            title(['VIS spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(vis_cal.t_int_ms(vt))],'interp','none');
            legend('rate')
            sb(2) = subplot(2,1,2);
            plot(vis_cal.lambda, vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'r-');
            legend('resp');
            linkaxes(sb,'x');axis(sb(1),v1);axis(sb(2),v2);
            
            clear header
            header(1) = {'% SWS VIS radiance calibration at NASA GSFC by Albert Mendoza'};
            header(end+1) = {['% SWS ']};
            header(end+1) = {['% Calibration_date: ',datestr(sws.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
            %             header(end+1) = {['% Cal_source: ',src_fname]};
            header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
            header(end+1) = {['% Lamps: ',num2str(lamp)]};
            header(end+1) = {['% Spectrometer_type: Zeiss PGS']};
            header(end+1) = {['% Integration_time_ms: ',num2str(vis_cal.t_int_ms(vt))]};
            header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
            header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
            
            %%
            
            in_cal = [vis_cal.lambda'; vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])';...
                vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms'])';vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms'])';...
                vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms'])';vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms'])';...
                (rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis_cal.lambda)))'];
            
            [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,vis_cal.time, vis_cal.t_int_ms(vt),pname);
            save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','vis_cal');
            saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
            menu('OK','OK')
            % Begin pasted block
            %%
            resp_Si = [vis_cal.lambda, vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])];
            [resp_stem, resp_dir] = gen_sws_resp_files(resp_Si,floor(sws.time(1)), unique(vis_cal.t_int_ms(vt)),pname);
            %% End of pasted block
                        
        end
        rad.(['lamps_',lamp,'_fit']) = planck_fit(rad.nm, rad.(['lamps_',lamp]),[sws.In_lambda]);
        nir_cal.t_int_ms = unique(sws.In_ms)
        nir_cal.lambda = sws.In_lambda;
        nir_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
        clear vxl_lower
        %% !nir
        for vt = 1:length(nir_cal.t_int_ms)
            nir_cal.time = min(sws.time(sws.In_ms==nir_cal.t_int_ms(vt)));
            
            nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = mean(sws.In_spec(:,sws.shutter==0 & (sws.In_ms==nir_cal.t_int_ms(vt))),2);
            nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = mean(sws.In_spec(:,sws.shutter==1 & (sws.In_ms==nir_cal.t_int_ms(vt))),2);
            
            nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']) - nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']);
            nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms'])./nir_cal.t_int_ms(vt);
            nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms'])./(rad.(['lamps_',lamp,'_fit']).Irad(1:length(nir_cal.lambda)));
            figure(18);
            set(gcf,'position',[f8.pos(1), f8.pos(2)+f8.pos(4)+50, f8.pos(3), f8.pos(4)]);

            if ~exist('f18','var')
                f18.h = gcf;
                f18.pos = get(f18.h,'position');
            end
            sa(1) = subplot(2,1,1);
            plot(nir_cal.lambda,  nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'c-',...
                nir_cal.lambda, nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
            title(['NIR spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
            legend('lights','darks')
            sa(2) = subplot(2,1,2);
            plot(nir_cal.lambda, nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'g-')
            legend('signal');
            linkaxes(sa,'x');
            figure(19)
            set(gcf,'position',[f18.pos(1)+f18.pos(3)+50, f18.pos(2), f18.pos(3), f18.pos(4)]);
            sb(1) = subplot(2,1,1);
            plot(nir_cal.lambda, nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'b-');
            title(['NIR spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
            legend('rate')
            sb(2) = subplot(2,1,2);
            plot(nir_cal.lambda, nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
            legend('resp');
            linkaxes(sb,'x');
            
            %%
            vxl_lower = 939; vxl_upper = 2201;v1 = axis(sb(1));v2 = axis(sb(2));
            if ~exist('vxl_lower','var')
                v1 = axis(sb(1));
                v2 = axis(sb(2));
                zoom('on');
                done = menu('Zoom in to place lowest wavelength limit at LH axis limit.','OK');
                xl_lower = xlim; vxl_lower = round(xl_lower(1));
                axis(sb(1),v1);axis(sb(2),v2);
                zoom('on');
                done = menu('Zoom in to place highest wavelength limit at RH axis limit.','OK');
                xl_upper = xlim; vxl_upper = round(xl_upper(2));
            end
            bad = nir_cal.lambda < vxl_lower | nir_cal.lambda > vxl_upper;
            axis(sb(1),v1);axis(sb(2),v2);
            nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms'])(bad) = NaN;
            
            figure(19)
            sb(1) = subplot(2,1,1);
            plot(nir_cal.lambda, nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'b-');
            title(['NIR spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
            legend('rate')
            sb(2) = subplot(2,1,2);
            plot(nir_cal.lambda, nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
            legend('resp');
            linkaxes(sb,'x');axis(sb(1),v1);axis(sb(2),v2);
            
            clear header
            header(1) = {'% SWS InGaAs radiance calibration at NASA GSFC by Albert Mendoza'};
            
            header(end+1) = {['% SWS ']};
            header(end+1) = {['% Calibration_date: ',datestr(sws.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
            %             header(end+1) = {['% Cal_source: ',src_fname]};
            header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
            header(end+1) = {['% Lamps: ',num2str(lamp)]};
            header(end+1) = {['% Spectrometer_type: Zeiss PGS']};
            header(end+1) = {['% Integration_time_ms: ',num2str(nir_cal.t_int_ms(vt))]};
            header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
            header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
            
            %%
            
            in_cal = [nir_cal.lambda'; nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms'])';...
                nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms'])';nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms'])';...
                nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms'])';nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms'])';...
                (rad.(['lamps_',lamp,'_fit']).Irad(1:length(nir_cal.lambda)))'];

            [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,nir_cal.time, nir_cal.t_int_ms(vt),pname);
            save([resp_dir, strrep(resp_stem,'.dat','.mat')],'-struct','nir_cal');
            
            saveas(gcf,[resp_dir,strrep(resp_stem,'.dat','.fig')]);
            menu('OK','OK')
            % Begin pasted block
            %%
            resp_InGaAs = [nir_cal.lambda, nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms'])];
            [resp_stem, resp_dir] = gen_sws_resp_files(resp_InGaAs,floor(sws.time(1)), unique(nir_cal.t_int_ms(vt)),pname);
            %% End of pasted block
        end
        
        %% !nir
        
    end
end

return

