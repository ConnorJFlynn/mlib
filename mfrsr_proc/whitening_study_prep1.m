function whitening_study
%%
% mfr = ancload(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\sgpmfrsraod1michC1.c1.20070101.000000.cdf']);
% mfr = load(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\catdir\sgpmfrsraod1michC1.c1.20070101.000000.mat']);
% % sky = load(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\2007_clr.mat']);
% sky = rd_clong_clr(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\2007_clr.dat']);

%% Concatenate Chuck's results into a single time series
sky_dir = ['D:\case_studies\clong\clr_sky\']
% files = dir([sky_dir,'*.asc']);
% sky = rd_clong_clr([sky_dir,files(1).name]);
% for f = 2:length(files)
%     sky = cat_timeseries(sky, rd_clong_clr([sky_dir,files(f).name]));
% end
% % [pname, fname, ext] = fileparts(in_file);
% save([sky_dir, 'clear_sky_clong.mat'],'-struct','sky');
sky = load([sky_dir,'clear_sky_clong.mat']);

%% Create subset of MFRSR AOD and concat into single time series
sky.N_avg = zeros(size(sky.time));
sky.diffuse_hemisp_415nm = sky.N_avg;
sky.diffuse_hemisp_870nm = sky.N_avg;
sky.aerosol_optical_depth_filter1 = sky.N_avg;
sky.aerosol_optical_depth_filter5 = sky.N_avg;
aod_dir = ['D:\case_studies\clong\sgp\sgpmfrsraod1michE13.c1\catdir\'];
aods = dir([aod_dir,'*.mat']);
% nc = subcat_mfrsraod_for_clong;
for aa = 1:length(aods)
    disp(aods(aa).name)
    mfr = load([aod_dir,aods(aa).name]);
    qc_aod1 = qc_impacts(mfr.vars.qc_aerosol_optical_depth_filter1);
    qc_aod5 = qc_impacts(mfr.vars.qc_aerosol_optical_depth_filter5);
    
    t_i = max(find(sky.time<=mfr.time(1)));
    t_ii = min(find(sky.time>mfr.time(end)));
    this_min_V = datevec(sky.time(t_i));
    for t = t_i : t_ii
        next_min_V = datevec(sky.time(t)); next_min_V(5) = next_min_V(5)+1; next_min = datenum(next_min_V);
        if any(this_min_V(1:3)~=next_min_V(1:3))
            disp(datestr(datenum(next_min_V)))
        end
        this_min_V = next_min_V;
        t_ = (mfr.time>=sky.time(t))&(mfr.time<next_min)&...
            (mfr.vars.diffuse_hemisp_narrowband_filter1.data>0)&(mfr.vars.diffuse_hemisp_narrowband_filter5.data>0)&...
            (mfr.vars.aerosol_optical_depth_filter1.data>0)&(mfr.vars.aerosol_optical_depth_filter5.data>0)&qc_aod1==0&qc_aod5==0;
        sky.N_avg(t) = sum(t_);
        if sum(t_)>1
            sky.diffuse_hemisp_415nm(t) = mean(mfr.vars.diffuse_hemisp_narrowband_filter1.data(t_));
            sky.diffuse_hemisp_870nm(t) = mean(mfr.vars.diffuse_hemisp_narrowband_filter5.data(t_));
            sky.aerosol_optical_depth_filter1(t) = mean(mfr.vars.aerosol_optical_depth_filter1.data(t_));
            sky.aerosol_optical_depth_filter5(t) = mean(mfr.vars.aerosol_optical_depth_filter5.data(t_));
        elseif sum(t_)==1
            sky.diffuse_hemisp_415nm(t) = (mfr.vars.diffuse_hemisp_narrowband_filter1.data(t_));
            sky.diffuse_hemisp_870nm(t) = (mfr.vars.diffuse_hemisp_narrowband_filter5.data(t_));
            sky.aerosol_optical_depth_filter1(t) = (mfr.vars.aerosol_optical_depth_filter1.data(t_));
            sky.aerosol_optical_depth_filter5(t) = (mfr.vars.aerosol_optical_depth_filter5.data(t_));
        else
%             disp(['No good AOD for this clear sky time: ',datestr(sky.time(t))])
            sky.diffuse_hemisp_415nm(t) = -9;
            sky.diffuse_hemisp_870nm(t) = -9;
            sky.aerosol_optical_depth_filter1(t) = -9;
            sky.aerosol_optical_depth_filter5(t) = -9;
        end
        
%         disp(t_ii -t)
        
    end
    
% save(['D:\case_studies\clong\sky_whitening_E13.mat'],'-struct','sky')    
end
%%
% save(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\2007_clr.mat'],'-struct','sky');
%%

%%
sky.T_dif_filter1 = sky.diffuse_hemisp_415nm ./sscanf(mfr.atts.filter1_TOA_direct_normal.data,'%g');
sky.T_dif_filter5 = sky.diffuse_hemisp_870nm ./sscanf(mfr.atts.filter5_TOA_direct_normal.data,'%g');

sky.dif_T = (sky.T_dif_filter1 - sky.T_dif_filter5);
sky.ratio_T = sky.T_dif_filter1 ./ sky.T_dif_filter5;
% sky.V = datevec(sky.time);
%save(['D:\case_studies\clong\sgp\sgpmfrsraod1michE131.c1.subcat.20000101.mat'],'-struct','sky')
% nc.vars.dif_T.data = nc.vars.airmass.data.*(nc.vars.T_dif_filter1.data - nc.vars.T_dif_filter5.data);
% nc.vars.ratio_T.data = nc.vars.airmass.data.* nc.vars.T_dif_filter1.data ./ nc.vars.T_dif_filter5.data;
good =sky.N_avg >= 1;
figure; plot(serial2doys(sky.time(good)), sky.dif_T(good), 'g.', serial2doys(sky.time(good)), sky.ratio_T(good), 'r.') ;
legend('diff','ratio')

figure; scatter(C1.T_dif_filter1(t_), C1.T_dif_filter1_E13(t_),9,C1.V_UT(t_,2)); title(['diffuse Tr 415 nm: ',num2str(year), '-',num2str(year+1)]);  
xlabel('C1'); ylabel('E13'); cb = colorbar;caxis([0,12]); 
xl = xlim; xl(1) = 0; xlim(xl); ylim(xl);
hold('on'); plot(xl,xl,'k--');
year = 200; 
t_ = C1.time>datenum(year,01,01)&C1.time<datenum(year+1,1,1)&...
    C1.diffuse_hemisp_415nm>0 &C1.diffuse_hemisp_415nm_E13>0;  sum(t_)

%%
year = 1998; t_ = sky.time>datenum(year,01,01)&sky.time<datenum(year+1,1,1)&sky.diffuse_hemisp_415nm>0 &sky.diffuse_hemisp_415nm_E13>0;  sum(t_)

figure; scatter(sky.T_dif_filter5(t_), sky.T_dif_filter5_E13(t_),9,sky.V_UT(t_,1)); colorbar

return