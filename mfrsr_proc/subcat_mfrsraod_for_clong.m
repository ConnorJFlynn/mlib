function nc = subcat_mfrsraod_for_clong
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
mfr = getfullname_('*mfr*.cdf','cip','Select an MFRSR or NIMFR AOD file from the directory you want to process.');
if iscell(mfr)
    mfr = mfr{1};
end
[pname, fname, ext] = fileparts(mfr);
pname = [pname, filesep];
subdir = [pname, 'subdir',filesep];
if ~exist([pname, 'subdir'],'dir')
    mkdir([pname, 'subdir']);
end
catdir = [pname, 'catdir',filesep];
if ~exist([pname, 'catdir'],'dir')
    mkdir([pname, 'catdir']);
end

[ds,part] = strtok(fname,'.'); [dl,part] = strtok(part,'.'); [yearstr,part] = strtok(part,'.');

files = dir([pname, ds,'.',dl,'.*',ext]);
for f = 1:length(files)
    disp([num2str(f), ' of ',num2str(length(files))])
    in = ancload([pname, files(f).name]);
    
    vars.diffuse_hemisp_narrowband_filter1 = in.vars.diffuse_hemisp_narrowband_filter1;
    vars.diffuse_hemisp_narrowband_filter5 = in.vars.diffuse_hemisp_narrowband_filter5;
    vars.qc_diffuse_hemisp_narrowband_filter1 = in.vars.qc_diffuse_hemisp_narrowband_filter1;
    vars.qc_diffuse_hemisp_narrowband_filter5 = in.vars.qc_diffuse_hemisp_narrowband_filter5;
    vars.aerosol_optical_depth_filter1 = in.vars.aerosol_optical_depth_filter1;
    vars.aerosol_optical_depth_filter5 = in.vars.aerosol_optical_depth_filter5;
    vars.qc_aerosol_optical_depth_filter1 = in.vars.qc_aerosol_optical_depth_filter1;
    vars.qc_aerosol_optical_depth_filter5 = in.vars.qc_aerosol_optical_depth_filter5;    
    in.fname = [subdir,files(f).name];
    if isfield(in.dims, 'bench_angle')
    in.dims = rmfield(in.dims, 'bench_angle');
    end
    if isfield(in.dims, 'wavelength')
    in.dims = rmfield(in.dims, 'wavelength');
    end
    fields = fieldnames(in.vars);
    for fld = length(fields):-1 :1
        field =fields{fld};
        if ~isempty(strfind(field,'direct'))||~isempty(strfind(field,'total_optical'))||~isempty(strfind(field,'filter6'))...
                ||~isempty(strfind(field,'filter2'))||~isempty(strfind(field,'filter3'))||~isempty(strfind(field,'filter4'))...
                ||~isempty(strfind(field,'broadband'))||~isempty(strfind(field,'normalized_transmittance'))...
                ||~isempty(strfind(field,'wavelength_filter'))||~isempty(strfind(field,'wavelength_filter'))...
                ||~isempty(strfind(field,'_raw'))||~isempty(strfind(in.vars.(field).dims{:},'wavelength'))...
                ||~isempty(strfind(field,'bench_angle'))||~isempty(strfind(field,'Ozone'))...
                ||~isempty(strfind(field,'logger'))||~isempty(strfind(field,'head'))...
                ||~isempty(strfind(field,'Rayleigh'))||~isempty(strfind(field,'sun_to_earth'))...
                ||~isempty(strfind(field,'_we_'))||~isempty(strfind(field,'_sn_'))||~isempty(strfind(field,'calibration'))...
                ||(isempty(strfind(field,'diffuse'))&&~isempty(strfind(field,'hemisp')))...
                ||~isempty(strfind(field,'aerosol_optical'))||~isempty(strfind(field,'computed'))
            in.vars = rmfield(in.vars,field);
        else
%             disp(['Keeping ',field])
        end
    end
    in.vars.diffuse_hemisp_narrowband_filter1 = vars.diffuse_hemisp_narrowband_filter1;
    in.vars.diffuse_hemisp_narrowband_filter5 = vars.diffuse_hemisp_narrowband_filter5;
    in.vars.qc_diffuse_hemisp_narrowband_filter1 = vars.qc_diffuse_hemisp_narrowband_filter1;
    in.vars.qc_diffuse_hemisp_narrowband_filter5 = vars.qc_diffuse_hemisp_narrowband_filter5;
    in.vars.aerosol_optical_depth_filter1 = vars.aerosol_optical_depth_filter1;
    in.vars.aerosol_optical_depth_filter5 = vars.aerosol_optical_depth_filter5;
    in.vars.qc_aerosol_optical_depth_filter1 = vars.qc_aerosol_optical_depth_filter1;
    in.vars.qc_aerosol_optical_depth_filter5 = vars.qc_aerosol_optical_depth_filter5;
    
%         %%
%     in.quiet = true;
%     in = anccheck(in);
    if ~exist('nc','var')
        nc = in;
    else
        nc = anccat(nc,in);
    end
%     in.clobber = true;  
%     disp(['Writing ',files(f).name, ' , ',num2str(f),' of ',num2str(length(files))]);
%     ancsave(in);
end
nc.fname = [catdir,files(1).name];
save(strrep(nc.fname,'.cdf','.mat'),'-struct','nc');
nc = anccheck(nc);
nc.quiet = true;
disp(['Writing ',nc.fname]);

ancsave(nc);
%%
% plot_qcs(nc);
%%

 
% plot_qcs(nc);
%%
disp('Done!')


%%
% nc = load(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\catdir\sgpmfrsraod1michC1.c1.20070101.000000.mat']);
% nc.vars.T_dif_filter1.data = nc.vars.diffuse_hemisp_narrowband_filter1.data ./sscanf(nc.atts.filter1_TOA_direct_normal.data,'%g');
% nc.vars.T_dif_filter5.data = nc.vars.diffuse_hemisp_narrowband_filter5.data ./sscanf(nc.atts.filter5_TOA_direct_normal.data,'%g');
% nc.vars.dif_T.data = (nc.vars.T_dif_filter1.data - nc.vars.T_dif_filter5.data);
% nc.vars.ratio_T.data = nc.vars.T_dif_filter1.data ./ nc.vars.T_dif_filter5.data;
% % nc.vars.dif_T.data = nc.vars.airmass.data.*(nc.vars.T_dif_filter1.data - nc.vars.T_dif_filter5.data);
% % nc.vars.ratio_T.data = nc.vars.airmass.data.* nc.vars.T_dif_filter1.data ./ nc.vars.T_dif_filter5.data;
% good = nc.vars.diffuse_hemisp_narrowband_filter1.data > 0 & nc.vars.diffuse_hemisp_narrowband_filter5.data> 0 & nc.vars.airmass.data < 15 & nc.vars.airmass.data > 1;
% figure; plot(serial2doy(nc.time(good)), nc.vars.dif_T.data(good), 'g.', serial2doy(nc.time(good)), nc.vars.ratio_T.data(good), 'r.') ;
% legend('diff','ratio')


%%

return


