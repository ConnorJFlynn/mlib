function nc = subcat_surfspecalb_for_cip
% Select a file from a desired directory.
% For all files in this directory, 
% Strip unnecessary fields
% Add new QC definition, but don't populate it.
% % Save resulting daily subset files in a subdirectory named for the year.
% 
% % For all files in the year subdirectory, read and concat.
% % Save concat results to file and pass back out as mat file.
% % Then evaluate resutls of new screen.
% 
% % Step 1: strip out unneeded info, add new QC tests to AOD and angstrom
% 
% % First, create subset of monthly data with fewer fields
% % remove all direct_horiz and qc_direct_horiz
% % remove all filter 1 3 4 6
% % remove all total_optical_depth
mfr = getfullname_('*surfspecalb*.cdf','cip','Select a surfspecalb file from the directory you want to process.');
if iscell(mfr)
    mfr = mfr{1};
end
[pname, fname, ext] = fileparts(mfr);
pname = [pname, filesep];
% subdir = [pname, 'subdir',filesep];
% if ~exist([pname, 'subdir'],'dir')
%     mkdir([pname, 'subdir']);
% end
catdir = [pname, 'catdir',filesep];
if ~exist([pname, 'catdir'],'dir')
    mkdir([pname, 'catdir']);
end

[ds,part] = strtok(fname,'.'); [dl,part] = strtok(part,'.'); [yearstr,part] = strtok(part,'.');

files = dir([pname, ds,'.',dl,'.*',ext]);
for f = 1:length(files)
    disp([num2str(f), ' of ',num2str(length(files))])
    in = ancload([pname, files(f).name]);
    date(f) = in.time(1);
    
    
%     in.fname = [subdir,files(f).name];
    in.dims = rmfield(in.dims, 'wavenumber');
    fields = fieldnames(in.vars);
    for fld = length(fields):-1 :1
        field =fields{fld};
        if (~strcmp(field,'time')&&isempty(strfind(field,'albedo'))&&isempty(strfind(field,'surface_type'))...
                &&~strcmp(field,'filter')&&~strcmp(field,'lat')&&~strcmp(field,'lon')...
                &&isempty(strfind(field,'alt')))||~isempty(strfind(field,'qc_'))||~isempty(strfind(field,'estimated_spectral_albedo'))
            in.vars = rmfield(in.vars,field);
%             disp(['!!!!  Removed ',field])
%         else
%             disp(['Preserved ',field])
        end
        
    end    %         %%
%     in.quiet = true;
%     in = anccheck(in);
    if ~exist('nc','var')
        nc = in;
    else
        nc = anccat(nc,in);
        nc.vars.surface_type_10m_tower.data = [in.vars.surface_type_10m_tower.data, nc.vars.surface_type_10m_tower.data];
        nc.vars.surface_type_25m_tower.data = [in.vars.surface_type_25m_tower.data, nc.vars.surface_type_25m_tower.data];
    end
%     in.clobber = true;  
%     disp(['Writing ',files(f).name, ' , ',num2str(f),' of ',num2str(length(files))]);
%     ancsave(in);
end
nc.fname = [catdir,files(1).name];
nc.dims.date = nc.dims.filter;
nc.dims.date.id = 2;
nc.dims.date.length = length(nc.vars.surface_type_10m_tower.data);
nc.vars.surface_type_25m_tower.dims = {'date'};
nc.vars.surface_type_10m_tower.dims = {'date'};
nc.vars.date = nc.vars.surface_type_10m_tower;
nc.vars.date.data = date';
nc.vars.surface_type_25m_tower.data = nc.vars.surface_type_25m_tower.data';
nc.vars.surface_type_10m_tower.data = nc.vars.surface_type_10m_tower.data';
nc.vars.date.atts.long_name.data = 'date used for surface type';
nc.vars.date.atts.units.data = 'unitless';
nc.vars.date.atts = rmfield(nc.vars.date.atts,'comment');

nc = anccheck(nc)
nc.quiet = true;
disp(['Writing ',nc.fname]);
nc.clobber = true;
success =ancsave(nc);
if success==1
    save(strrep(nc.fname, '.cdf','.mat'),'-struct','nc')
end
%%
% plot_qcs(nc);
%%

%% 
% 
% disp('Done!')      
% clear in
% % Next, read and concat contents of yyyy directory.
% files = dir([subdir, '*.cdf']);
% nc = ancload([subdir, files(1).name]);
% for f = 2:length(files)
%     disp(['Reading ',num2str(f), ' of ',num2str(length(files))])
%     nc = anccat(nc, ancload([subdir, files(f).name]));
% end
%
% nc.fname = [catdir,files(1).name];
% %
% nc = anccheck(nc);
% %%
% plot_qcs(nc);
% %%
% nc.quiet = true;
% disp(['Writing ',nc.fname]);
% ancsave(nc);
% %%
% 
% plot_qcs(nc);
%%
disp('Done!')


% %%
% 
% % nc = ancload;
% %%
% 
%  nc.vars.Tr_filter2.data = nc.vars.direct_normal_narrowband_filter2.data./sscanf(nc.atts.filter2_TOA_direct_normal.data,'%g');
%  %%
% 
% % At this point, we have created a subset file with appropriate QC
% % definitions, and concatenated the results into a single file, but have
% % not evaluated the QC test.
% %%
% % plot_qcs(nim);
% % Clean up existin QC error with isolated variability flags at 00:00 UTC
% % These tests are in AOD QC bits 3 and 7
% % Clean this up for filter2
% qc = nc.vars.qc_aerosol_optical_depth_filter2;
% vari = bitget(uint32(qc.data),3);  %Test "3" for questionable variability
% vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
% vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
% qc.data = bitset(uint32(qc.data), 3,vari);
% 
% vari = bitget(uint32(qc.data),7); %Test "7" for 'bad' variability
% vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
% vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
% qc.data = bitset(uint32(qc.data), 3,vari);
% nc.vars.qc_aerosol_optical_depth_filter2 = qc;
% 
% 
% % Clean this up for filter5
% qc = nc.vars.qc_aerosol_optical_depth_filter5;
% vari = bitget(uint32(qc.data),3);  %Test "3" for questionable variability
% vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
% vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
% qc.data = bitset(uint32(qc.data), 3,vari);
% 
% vari = bitget(uint32(qc.data),7); %Test "7" for 'bad' variability
% vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
% vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
% qc.data = bitset(uint32(qc.data), 3,vari);
% nc.vars.qc_aerosol_optical_depth_filter5 = qc;
% 
% % Clean this up for Angstrom Exponent
% qc = nc.vars.qc_angstrom_exponent;
% vari = bitget(uint32(qc.data),2);  %Test "2" for questionable variability
% vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
% vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
% qc.data = bitset(uint32(qc.data), 3,vari);
% 
% vari = bitget(uint32(qc.data),5); %Test "5" for 'bad' variability
% vari(2:end-1) = vari(2:end-1)|(vari(1:end-2)&vari(3:end));
% vari(1) = vari(1)|vari(2); vari(end) = vari(end)|vari(end-1);
% qc.data = bitset(uint32(qc.data), 3,vari);
% nc.vars.qc_angstrom_exponent = qc;
% 
% % nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data)	, 12,false);
% % nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data)	, 12,false);
% % nc.vars.qc_angstrom_exponent.data = bitset(uint32(nc.vars.qc_angstrom_exponent.data), 9,false);
% %
% 
% 
% % At this point we've fixed the existing variability test but have not
% % applied the new QC test.
% 
% % Populating Boolean T/F arrays
% filter2_qc = nc.vars.qc_aerosol_optical_depth_filter2.data >0; % good when ~filter_qc
% filter5_qc = nc.vars.qc_aerosol_optical_depth_filter5.data >0;
% ang_qc = nc.vars.qc_angstrom_exponent.data >0; % good when ~ang_qc
% Tr_test = real(log10(nc.vars.Tr_filter2.data))<log10(.01);  % good when ~Tr_test
% 
% nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test)
% nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test)
% 
% % The figure below is using the T/F arrays to select only those values
% % corresponding to the T/F states in the arrays.
% % The "~" symbol is negation
% figure; 
% sb(1) = subplot(2,1,1);
% plot(serial2doy(nc.time(~filter2_qc)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc), 'r.',...
%     serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc& ~Tr_test), 'g.');
% [pn,filename,ext] = fileparts(nc.fname);
% title(filename);
% legend('bad','good');
% ylabel('AOD');
% xlabel('time [day of year]');
% 
% sb(2) = subplot(2,1,2);
% plot(serial2doy(nc.time(~filter2_qc)), nc.vars.angstrom_exponent.data(~filter2_qc), 'r.',...
%     serial2doy(nc.time(~filter2_qc & ~Tr_test)), nc.vars.angstrom_exponent.data(~filter2_qc& ~Tr_test), 'g.')
% legend('bad','good');
% ylabel('angstrom');
% xlabel('time [day of year]');
% linkaxes(sb,'x')
% %%
% without_Tr_test = nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc);
% [wo_Tr_N, bins] = hist(log10(without_Tr_test),50);
% figure(99);
% bar(bins, log10(wo_Tr_N));
% title('Here is the PDF before applying the Tr Test')
% 
% %%
% with_Tr_test = nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc&~Tr_test);
% [w_Tr_N, bins] = hist(log10(with_Tr_test),50);
% figure(199);
% bar(bins, log10(w_Tr_N));
% title('Here is the PDF AFTER applying the Tr Test')
% %%
% 
% sum((~filter2_qc& ~Tr_test)) % These are the green points that are in fact pretty good
% sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test)) % These are the red points that have now been successfully excluded
% 
% 100.*sum((~filter2_qc)& ~(~filter2_qc& ~Tr_test))./sum((~filter2_qc& ~Tr_test)) 
% %%
% nc.vars.qc_aerosol_optical_depth_filter2.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter2.data), 12,Tr_test);
% nc.vars.qc_aerosol_optical_depth_filter5.data = bitset(uint32(nc.vars.qc_aerosol_optical_depth_filter5.data), 12,Tr_test);
% nc.vars.qc_angstrom_exponent.data = bitset(uint32(nc.vars.qc_angstrom_exponent.data), 9,Tr_test)
% 
% 
% %%
% figure; 
% sc(1) = subplot(2,1,1);
% plot(serial2doy(nc.time(~filter2_qc)), [nc.vars.aerosol_optical_depth_filter2.data(~filter2_qc);nc.vars.aerosol_optical_depth_filter3.data(~filter2_qc);...
%     nc.vars.aerosol_optical_depth_filter4.data(~filter2_qc);nc.vars.aerosol_optical_depth_filter5.data(~filter2_qc)], '.');
% [pn,filename,ext] = fileparts(nc.fname);
% title(filename);
% legend('filter 1','filter 2','filter 3','filter 4','filter_5');
% ylabel('AOD');
% xlabel('time [day of year]');
% 
% sc(2) = subplot(2,1,2);
% plot(serial2doy(nc.time(~filter2_qc)), nc.vars.angstrom_exponent.data(~filter2_qc), 'g.')
% legend('bad','good');
% ylabel('angstrom');
% xlabel('time [day of year]');
% linkaxes(sc,'x')
%%

return


