function [Si_resp, In_resp] = rad_cals_SWSpec_vs_GSFC_Grande_2016_07_12
% 2016_07_12.NASA_GSFC.SWS_PreENA_deploy
% This calibration was only of the SWS head, not including baffle and
% window required for ENA installation.  Final calibration will require
% incorporating this calibration against Grande with another at PNNL on 2016_08_22
% using the green integrating sphere as reference with and without the window and baffle.
%
%%

rad = get_grande([getnamedpath('rad_cals'),'\cal_sources_references_xsec\GSFC_Grande\']);
done = false;
while ~done
    cal = menu('Compute responsivity or done?','Compute resp','Done');
    if cal==2
        done= true;
    else
        pause(.05);
        nir_file = getfullname('*SASZe*nir*.csv','SASZE_cals','Select SASZe NIR cal file.');
        nir = rd_raw_SAS(nir_file);
        [pname, fname] = fileparts(nir_file);pname = [pname, filesep];
        
        lamp_i = strfind(fname, 'Lamps');
        if ~isempty(lamp_i)
            lamp = fname(lamp_i-1);
        end
        
        filename = [nir.pname, strrep(nir.fname{:}, 'nir','vis')];
        vis = rd_raw_SAS(filename);
        
        
        nir.rad.(['lamps_',lamp,'_fit']) = planck_fit(rad.nm, rad.(['lamps_',lamp]),[nir.lambda]);
        nir.rad.lamp_1_fit = planck_fit(rad.nm, rad.lamps_1,nir.lambda);
        vis.rad.(['lamps_',lamp,'_fit']) = planck_fit(rad.nm, rad.(['lamps_',lamp]),[vis.lambda]);
        vis.rad.lamp_1_fit = planck_fit(rad.nm, rad.lamps_1,vis.lambda);
        
        
        %%
        vis_cal.t_int_ms = unique(vis.t_int_ms);
        vis_cal.lambda = vis.lambda;
        vis_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
        nir_cal.t_int_ms = unique(nir.t_int_ms);
        nir_cal.lambda = nir.lambda;
        nir_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
        %%
        for vt = 1:length(vis_cal.t_int_ms)
            vis_cal.time = min(vis.time(vis.t_int_ms==vis_cal.t_int_ms(vt)));
            vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = mean(vis.spec(vis.Shutter_open_TF==1 & vis.t_int_ms==vis_cal.t_int_ms(vt),:));
            vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = mean(vis.spec(vis.Shutter_open_TF==0 & vis.t_int_ms==vis_cal.t_int_ms(vt),:));
            vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']) - vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']);
            vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms'])./vis_cal.t_int_ms(vt);
            rad_sub = vis.rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis_cal.lambda))-vis.rad.lamp_1_fit.Irad(1:length(vis_cal.lambda));
            vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms']) = vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms'])./rad_sub;
            figure_(8);
            sa(1) = subplot(2,1,1);
            plot(vis_cal.lambda,  vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'c-',...
                vis_cal.lambda, vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'r-');
            title(['Vis spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(vis_cal.t_int_ms(vt))],'interp','none');
            legend('lights','darks')
            sa(2) = subplot(2,1,2);
            plot(vis_cal.lambda, vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms']), 'g-')
            legend('signal');
            linkaxes(sa,'x');
            figure_(9)
            %             set(gcf,'position',[f8.pos(1)+f8.pos(3)+50, f8.pos(2), f8.pos(3), f8.pos(4)]);
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
            
            figure_(9)
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
            header(end+1) = {['% Calibration_date: ',datestr(vis_cal.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
            %             header(end+1) = {['% Cal_source: ',src_fname]};
            header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
            header(end+1) = {['% Lamps: ',num2str(lamp)]};
            header(end+1) = {['% Spectrometer_type: Zeiss PGS']};
            header(end+1) = {['% Integration_time_ms: ',num2str(vis_cal.t_int_ms(vt))]};
            header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
            header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
            
            %%
            
            in_cal = [vis_cal.lambda', vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])',...
                vis_cal.(['rate_',num2str(vis_cal.t_int_ms(vt)),'_ms'])',vis_cal.(['sig_',num2str(vis_cal.t_int_ms(vt)),'_ms'])',...
                vis_cal.(['light_',num2str(vis_cal.t_int_ms(vt)),'_ms'])',vis_cal.(['dark_',num2str(vis_cal.t_int_ms(vt)),'_ms'])',...
                (vis.rad.(['lamps_',lamp,'_fit']).Irad(1:length(vis_cal.lambda)))']';
            [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,vis_cal.time, vis_cal.t_int_ms(vt),pname);
            
            resp_Si = [vis_cal.lambda; vis_cal.(['resp_',num2str(vis_cal.t_int_ms(vt)),'_ms'])]';
            [resp_stem, resp_dir] = gen_sws_resp_files(resp_Si,floor(vis_cal.time(1)), unique(vis_cal.t_int_ms(vt)),pname);
            
            menu('OK','OK')
            [~, resp_stem,ext] = fileparts(resp_stem);
            [~, resp_stem, ex] = fileparts(resp_stem);
            ii_ = strfind(ex,'_'); ex(ii_:end) = [];
            resp_stem = [resp_stem, ex];
            n = 1; resp_stem_ = resp_stem;
            while isafile([resp_dir, resp_stem, '.fig'])
                n = n+1
                resp_stem = [resp_stem_, sprintf('_%d',n)];
            end
            saveas(gcf,[resp_dir,resp_stem,'.fig']);
        end
        [~, resp_stem, ext] = fileparts(resp_stem);
        n = 1; resp_stem_ = resp_stem;
        while isafile([resp_dir, resp_stem, '.mat']);
            n = n+1;
            resp_stem = [resp_stem_, sprintf('_%d',n)];
        end
        save([resp_dir, resp_stem, '.mat'],'-struct','vis_cal');
        clear vis_cal
        %         rad.(['lamps_',lamp,'_fit']) = planck_fit(rad.nm, rad.(['lamps_',lamp]),[sws.In_lambda]);
        %         nir_cal.t_int_ms = unique(sws.In_ms)
        %         nir_cal.lambda = sws.In_lambda;
        %         nir_cal.resp_units = ['(counts/ms)/(W/(m^2.sr.um))'];
        clear vxl_lower
        %% !nir
        for vt = 1:length(nir_cal.t_int_ms)
            nir_cal.time = min(nir.time(nir.t_int_ms==nir_cal.t_int_ms(vt)));
            nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = mean(nir.spec(nir.Shutter_open_TF==1 & nir.t_int_ms==nir_cal.t_int_ms(vt),:));
            nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = mean(nir.spec(nir.Shutter_open_TF==0 & nir.t_int_ms==nir_cal.t_int_ms(vt),:));
            nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']) - nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']);
            nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms'])./nir_cal.t_int_ms(vt);
            rad_sub = nir.rad.(['lamps_',lamp,'_fit']).Irad(1:length(nir_cal.lambda))-nir.rad.lamp_1_fit.Irad(1:length(nir_cal.lambda));
            nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms']) = nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms'])./rad_sub;
            figure_(18);
            
            sa(1) = subplot(2,1,1);
            plot(nir_cal.lambda,  nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'c-',...
                nir_cal.lambda, nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'r-');
            title(['NIR spectrometer: ',lamp,' Lamps, t_int_ms=',num2str(nir_cal.t_int_ms(vt))],'interp','none');
            legend('lights','darks')
            sa(2) = subplot(2,1,2);
            plot(nir_cal.lambda, nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms']), 'g-')
            legend('signal');
            linkaxes(sa,'x');
            figure_(19)
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
            
            figure_(19)
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
            header(end+1) = {['% Calibration_date: ',datestr(nir_cal.time(1),'yyyy-mm-dd HH:MM:SS UTC')]};
            %             header(end+1) = {['% Cal_source: ',src_fname]};
            header(end+1) = {['% Source_units: W/(m^2.sr.um)']};
            header(end+1) = {['% Lamps: ',num2str(lamp)]};
            header(end+1) = {['% Spectrometer_type: Zeiss PGS']};
            header(end+1) = {['% Integration_time_ms: ',num2str(nir_cal.t_int_ms(vt))]};
            header(end+1) = {['% Resp_units: (count/ms)/(W/(m^2.sr.um))']};
            header(end+1) = {['pixel  lambda_nm   resp    rate      signal    lights     darks      src_radiance'] };
            
            %%
            
            in_cal = [nir_cal.lambda', nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms'])',...
                nir_cal.(['rate_',num2str(nir_cal.t_int_ms(vt)),'_ms'])',nir_cal.(['sig_',num2str(nir_cal.t_int_ms(vt)),'_ms'])',...
                nir_cal.(['light_',num2str(nir_cal.t_int_ms(vt)),'_ms'])',nir_cal.(['dark_',num2str(nir_cal.t_int_ms(vt)),'_ms'])',...
                (nir.rad.(['lamps_',lamp,'_fit']).Irad(1:length(nir_cal.lambda)))']';
            
            [resp_stem, resp_dir] = gen_sasze_resp_file(in_cal,header,nir_cal.time, nir_cal.t_int_ms(vt),pname);
            resp_InGaAs = [nir_cal.lambda; nir_cal.(['resp_',num2str(nir_cal.t_int_ms(vt)),'_ms'])]';
            [resp_stem, resp_dir] = gen_sws_resp_files(resp_InGaAs,floor(nir_cal.time(1)), unique(nir_cal.t_int_ms(vt)),pname);
            menu('OK','OK')
            [~, resp_stem,ext] = fileparts(resp_stem);
            [~, resp_stem, ex] = fileparts(resp_stem);
            ii_ = strfind(ex,'_'); ex(ii_:end) = [];
            resp_stem = [resp_stem, ex];
            n = 1; resp_stem_ = resp_stem;
            while isafile([resp_dir, resp_stem, '.fig'])
                n = n+1
                resp_stem = [resp_stem_, sprintf('_%d',n)];
            end
            saveas(gcf,[resp_dir,resp_stem,'.fig']);
        end
        [~, resp_stem, ext] = fileparts(resp_stem);
        n = 1; resp_stem_ = resp_stem;
        while isafile([resp_dir, resp_stem, '.mat']);
            n = n+1;
            resp_stem = [resp_stem_, sprintf('_%d',n)];
        end
        save([resp_dir, resp_stem,'.mat'],'-struct','nir_cal');
        clear nir_cal
        
        
        %% !nir
        
    end
end

return

