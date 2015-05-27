function whitening_study
%% Initial examination of MFRSR AOD datastreams showed large differences between C1 and E13 MFRSR AOD and irradiances.
% Now looking at b1 to see try and isolate problem

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
sky.C1_diffuse_hemisp_415nm = sky.N_avg;
sky.C1_diffuse_hemisp_870nm = sky.N_avg;
sky.C1_direct_normal_filter1 = sky.N_avg;
sky.C1_direct_normal_filter5 = sky.N_avg;
sky.C1_direct_diffuse_ratio_filter1 = sky.N_avg;
sky.C1_direct_diffuse_ratio_filter5 = sky.N_avg;
sky.E13_diffuse_hemisp_415nm = sky.N_avg;
sky.E13_diffuse_hemisp_870nm = sky.N_avg;
sky.E13_direct_normal_filter1 = sky.N_avg;
sky.E13_direct_normal_filter5 = sky.N_avg;
sky.E13_direct_diffuse_ratio_filter1 = sky.N_avg;
sky.E13_direct_diffuse_ratio_filter5 = sky.N_avg;

mfr = load(['D:\case_studies\clong\from_bds2\sgpmfrsrC1.b1\catdir\sgpmfrsrC1.b1.19980101.000000.mat']);
good = mfr.vars.diffuse_hemisp_narrowband_filter1.data>0 & mfr.vars.diffuse_hemisp_narrowband_filter5.data>0 & ...
    mfr.vars.direct_normal_narrowband_filter1.data>0 & mfr.vars.direct_normal_narrowband_filter5.data>0 & ...
    mfr.vars.direct_diffuse_ratio_filter1.data > 0 & mfr.vars.direct_diffuse_ratio_filter1.data < 20 & ...
mfr.vars.direct_diffuse_ratio_filter5.data > 0 & mfr.vars.direct_diffuse_ratio_filter5.data < 100;
mfrC1 = ancsift(mfr, mfr.dims.time, good & mfr.time>datenum(2002,1,1));
mfr = load(['D:\case_studies\clong\from_bds2\sgpmfrsrE13.b1\catdir\sgpmfrsrE13.b1.19980101.000000.mat']);
good = mfr.vars.diffuse_hemisp_narrowband_filter1.data>0 & mfr.vars.diffuse_hemisp_narrowband_filter5.data>0 & ...
    mfr.vars.direct_normal_narrowband_filter1.data>0 & mfr.vars.direct_normal_narrowband_filter5.data>0 & ...
    mfr.vars.direct_diffuse_ratio_filter1.data > 0 & mfr.vars.direct_diffuse_ratio_filter1.data < 20 & ...
mfr.vars.direct_diffuse_ratio_filter5.data > 0 & mfr.vars.direct_diffuse_ratio_filter5.data < 100;
mfr13 = ancsift(mfr, mfr.dims.time, good& mfr.time>datenum(2002,1,1));

[ainb, bina] = nearest(mfrC1.time, mfr13.time, 1/(24*60));
mfrC1 = ancsift(mfrC1, mfrC1.dims.time, ainb);
mfr13 = ancsift(mfr13, mfr13.dims.time, bina);

% [mfrC1_1998, mfrC1_2007] = ancsift(mfr, mfr.dims.time, mfr.time< datenum(2002,1,1)); clear mfr
[ainb, bina] = nearest(sky.time, mfrC1.time, 1./(24*60));

        sky.C1_diffuse_hemisp_415nm(ainb) = (mfrC1.vars.diffuse_hemisp_narrowband_filter1.data(bina));
        sky.C1_diffuse_hemisp_870nm(ainb) = (mfrC1.vars.diffuse_hemisp_narrowband_filter5.data(bina));
        sky.C1_direct_normal_filter1(ainb) = (mfrC1.vars.direct_normal_narrowband_filter1.data(bina));
        sky.C1_direct_normal_filter5(ainb) = (mfrC1.vars.direct_normal_narrowband_filter5.data(bina));
        sky.C1_direct_diffuse_ratio_filter1(ainb) = (mfrC1.vars.direct_diffuse_ratio_filter1.data(bina));
        sky.C1_direct_diffuse_ratio_filter5(ainb) = (mfrC1.vars.direct_diffuse_ratio_filter5.data(bina));
        
        sky.E13_diffuse_hemisp_415nm(ainb) = (mfr13.vars.diffuse_hemisp_narrowband_filter1.data(bina));
        sky.E13_diffuse_hemisp_870nm(ainb) = (mfr13.vars.diffuse_hemisp_narrowband_filter5.data(bina));
        sky.E13_direct_normal_filter1(ainb) = (mfr13.vars.direct_normal_narrowband_filter1.data(bina));
        sky.E13_direct_normal_filter5(ainb) = (mfr13.vars.direct_normal_narrowband_filter5.data(bina));
        sky.E13_direct_diffuse_ratio_filter1(ainb) = (mfr13.vars.direct_diffuse_ratio_filter1.data(bina));
        sky.E13_direct_diffuse_ratio_filter5(ainb) = (mfr13.vars.direct_diffuse_ratio_filter5.data(bina));
        
        figure; plot(sky.C1_diffuse_hemisp_415nm(ainb), sky.E13_diffuse_hemisp_415nm(ainb), 'o'); legend('diffuse 415')
        figure; plot(sky.C1_diffuse_hemisp_870nm(ainb), sky.E13_diffuse_hemisp_870nm(ainb), 'o'); legend('diffuse 870')
        
        figure; plot(sky.C1_direct_normal_filter1(ainb), sky.E13_direct_normal_filter1(ainb), 'o'); legend('direct 415')
        figure; plot(sky.C1_direct_normal_filter5(ainb), sky.E13_direct_normal_filter5(ainb), 'o'); legend('direct 870')
        
        figure; plot(sky.C1_direct_diffuse_ratio_filter1(ainb), sky.E13_direct_diffuse_ratio_filter1(ainb), 'o'); legend('DDR 415')
        figure; plot(sky.C1_direct_diffuse_ratio_filter5(ainb), sky.E13_direct_diffuse_ratio_filter5(ainb), 'o'); legend('DDR 870')

        figure; scatter(sky.C1_diffuse_hemisp_415nm(ainb)./sky.C1_diffuse_hemisp_870nm(ainb),...
            sky.E13_diffuse_hemisp_415nm(ainb)./sky.E13_diffuse_hemisp_870nm(ainb), 2,serial2doy(sky.time(ainb)),'filled');colorbar 
        xlabel('C1 415/870 diffuse');
        ylabel('E13 415/870 diffuse');
        title('415/870 diffuse ratio')
        
        
       figure; scatter(sky.C1_direct_normal_filter1(ainb)./sky.C1_direct_normal_filter5(ainb),...
            sky.E13_direct_normal_filter1(ainb)./sky.E13_direct_normal_filter5(ainb), 2,serial2doy(sky.time(ainb)),'filled'); colorbar
        xlabel('C1 415/870 direct');
        ylabel('E13 415/870 difect');
        title('415/870 direct')
        
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
        (mfr.vars.direct_normal_narrowband_filter1.data>0)&(mfr.vars.direct_normal_narrowband_filter5.data>0)&...
        (mfr.vars.direct_diffuse_ratio_filter1.data>0)&(mfr.vars.direct_diffuse_ratio_filter5.data>0)&...
        (mfr.vars.direct_diffuse_ratio_filter1.data<20)&(mfr.vars.direct_diffuse_ratio_filter5.data<50);
    sky.N_avg(t) = sum(t_);
    if sum(t_)>1
        sky.diffuse_hemisp_415nm(t) = mean(mfr.vars.diffuse_hemisp_narrowband_filter1.data(t_));
        sky.diffuse_hemisp_870nm(t) = mean(mfr.vars.diffuse_hemisp_narrowband_filter5.data(t_));
        sky.direct_normal_filter1(t) = mean(mfr.vars.direct_normal_narrowband_filter1.data(t_));
        sky.direct_normal_filter5(t) = mean(mfr.vars.direct_normal_narrowband_filter5.data(t_));
        sky.direct_diffuse_ratio_filter1(t) = mean(mfr.vars.direct_diffuse_ratio_filter1.data(t_));
        sky.direct_diffuse_ratio_filter5(t) = mean(mfr.vars.direct_diffuse_ratio_filter5.data(t_));
    elseif sum(t_)==1
        sky.diffuse_hemisp_415nm(t) = (mfr.vars.diffuse_hemisp_narrowband_filter1.data(t_));
        sky.diffuse_hemisp_870nm(t) = (mfr.vars.diffuse_hemisp_narrowband_filter5.data(t_));
        sky.direct_normal_filter1(t) = (mfr.vars.direct_normal_narrowband_filter1.data(t_));
        sky.direct_normal_filter5(t) = (mfr.vars.direct_normal_narrowband_filter5.data(t_));
        sky.direct_diffuse_ratio_filter1(t) = (mfr.vars.direct_diffuse_ratio_filter1.data(t_));
        sky.direct_diffuse_ratio_filter5(t) = (mfr.vars.direct_diffuse_ratio_filter5.data(t_));
    else
        %             disp(['No good AOD for this clear sky time: ',datestr(sky.time(t))])
        sky.diffuse_hemisp_415nm(t) = -9;
        sky.diffuse_hemisp_870nm(t) = -9;
        sky.direct_normal_filter1(t) = -9;
        sky.direct_normal_filter5(t) = -9;
        sky.direct_diffuse_ratio_filter1(t) = -9;
        sky.direct_diffuse_ratio_filter5(t) = -9;
        
    end
    
%            disp(t_ii -t)
    
end

save(['D:\case_studies\clong\sky_whitening_b1_C1.mat'],'-struct','sky')

%%
% save(['D:\case_studies\clong\sgpmfrsraod1michC1.c1\2007\2007_clr.mat'],'-struct','sky');
%%

%%
sky.T_dif_filter1 = sky.diffuse_hemisp_415nm ./sscanf(mfr.atts.filter1_TOA_direct_normal.data,'%g');
sky.T_dif_filter5 = sky.diffuse_hemisp_870nm ./sscanf(mfr.atts.filter5_TOA_direct_normal.data,'%g');

sky.dif_T = (sky.T_dif_filter1 - sky.T_dif_filter5);
sky.ratio_T = sky.T_dif_filter1 ./ sky.T_dif_filter5;
% sky.V = datevec(sky.time);
save(['D:\case_studies\clong\sky_whitening_E13.mat'],'-struct','sky')
% nc.vars.dif_T.data = nc.vars.airmass.data.*(nc.vars.T_dif_filter1.data - nc.vars.T_dif_filter5.data);
% nc.vars.ratio_T.data = nc.vars.airmass.data.* nc.vars.T_dif_filter1.data ./ nc.vars.T_dif_filter5.data;
good =sky.N_avg >= 1;
figure; plot(serial2doys(sky.time(good)), sky.dif_T(good), 'g.', serial2doys(sky.time(good)), sky.ratio_T(good), 'r.') ;
legend('diff','ratio')

figure; scatter(C1.T_dif_filter1(t_), C1.T_dif_filter1_E13(t_),9,C1.V_UT(t_,2)); title(['diffuse Tr 415 nm: ',num2str(year), '-',num2str(year+1)]);  
xlabel('C1'); ylabel('E13'); cb = colorbar;caxis([0,12]); 
xl = xlim; xl(1) = 0; xlim(xl); ylim(xl);
hold('on'); plot(xl,xl,'k--');
year = 2008; 
t_ = C1.time>datenum(year,01,01)&C1.time<datenum(year+1,1,1)&...
    C1.diffuse_hemisp_415nm>0 &C1.diffuse_hemisp_415nm_E13>0;  sum(t_)

%%
year = 1998; t_ = sky.time>datenum(year,01,01)&sky.time<datenum(year+1,1,1)&sky.diffuse_hemisp_415nm>0 &sky.diffuse_hemisp_415nm_E13>0;  sum(t_)

figure; scatter(sky.T_dif_filter5(t_), sky.T_dif_filter5_E13(t_),9,sky.V_UT(t_,1)); colorbar

return