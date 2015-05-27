% mpl_inarg.in_dir = 'F:\case_studies\clasic_chaps\sgpmplpolC1.b1\';
mpl_inarg.in_dir = 'D:\case_studies\mplpol\sgpmplpolc1\sgpmplpolC1. b1\';
mpl_inarg.tla = 'sgp';
mpl_inarg.fstem = [mpl_inarg.tla,'_mplpol_3flynn.'];

   mpl_inarg.out_dir = [mpl_inarg.in_dir, 'out',filesep];
   mpl_inarg.bad_dir = [mpl_inarg.out_dir,'..',filesep, 'bad',filesep];
   mpl_inarg.mat_dir = [mpl_inarg.out_dir,'..',filesep, 'mat',filesep];
   mpl_inarg.fig_dir = [mpl_inarg.out_dir,'..',filesep, 'fig',filesep];
   mpl_inarg.png_dir = [mpl_inarg.out_dir,'..',filesep, 'png',filesep];

   mpl_inarg.Nsecs = 150;
%    mpl_inarg.Nrecs = 300;
%    mpl_inarg.dtc = eval(['@dtc_',mpl_inarg.tla,'_']); %accept and return MHz
   mpl_inarg.dtc = str2func(['dtc_',mpl_inarg.tla,'_']);
   mpl_inarg.ap = str2func(['ap_',mpl_inarg.tla,'_']); %accept range, return .cop, .crs
   mpl_inarg.ol_corr = str2func(['ol_',mpl_inarg.tla,'_']); % accept range,
 
%    mpl_inarg.dtc = @dtc_sgp_; %accept and return MHz
%    mpl_inarg.ap = @ap_fkb_; %accept range, return .cop, .crs
%    mpl_inarg.ol_corr = @ol_fkb_; % accept range, return ol_corr

   mpl_inarg.cop_snr = 2.25;
   mpl_inarg.ldr_snr = 1.5;
   mpl_inarg.ldr_error_limit = .3;
   mpl_inarg.fig = gcf;
   mpl_inarg.vis = 'on';
   mpl_inarg.cv_log_bs = [1,4.5];
   mpl_inarg.cv_dpr = [-2.25,0];
   mpl_inarg.plot_ranges = [15,5,2];
   
   %%
   [status,polavg] = batch_b1todaily(mpl_inarg);
   %%
   
   % March 28,0-5 UTC ap, fkbmplpolM1.b1.20070328.000002.cdf
   % Apr 3, 21-22 > 1.5 km overlap
   % Dang, doesn't look collimated.  Fitting from 8-14 to force agreement
   % with Rayleigh profile.
%    xl = [21.0466  , 21.4519];
% t.ol = (serial2Hh(Apr3.time)>=xl(1))&(serial2Hh(Apr3.time)<=xl(2));
% figure;semilogy(Apr3.range, mean(Apr3.attn_bscat(:,t.ol),2), 'b',Apr3.range, 250*Apr3.std_attn_prof,'r');
% %%
% r.ray_fit1 = Apr3.range>=8 & Apr3.range<=15;
% P_ray = polyfit(Apr3.range(r.ray_fit1), (250*Apr3.std_attn_prof(r.ray_fit1))./mean(Apr3.attn_bscat(r.ray_fit1,t.ol),2),1);
% %    figure; plot(Apr3.range, (250*Apr3.std_attn_prof)./mean(Apr3.attn_bscat(:,t.ol),2), 'g',Apr3.range, polyval(P_ray,Apr3.range),'k'); 
% ray_corr = polyval(P_ray, Apr3.range);
% top_ind = interp1(Apr3.range, [1:length(Apr3.range)],16,'nearest');
% ray_top = ray_corr(top_ind);
% ray_corr = ray_corr ./ ray_top; ray_corr(top_ind:end) = 1;ray_corr = ray_corr .* ray_top;
% figure;semilogy(Apr3.range, mean(Apr3.attn_bscat(:,t.ol),2).*ray_corr, 'b',Apr3.range, 250*Apr3.std_attn_prof,'r');
% %%
% ol_range = [2.15,10]; ol.r = (Apr3.range>=ol_range(1))&(Apr3.range<=ol_range(2));
% patch1 = 250*Apr3.std_attn_prof(ol.r)./(mean(Apr3.attn_bscat(ol.r,t.ol),2).*ray_corr(ol.r))
% %copied range and patch1 into Tablecurve to generate fkb_ray_olcorr_patch1
% %%
% combo_patch = fkb_ray_olcorr_patch1(Apr3.range).*ray_corr; combo_patch(1:4) = NaN;
% two_ind = interp1(Apr3.range, [1:length(Apr3.range)],2,'nearest');
% combo_patch(1:two_ind) = combo_patch(two_ind);
% % figure;semilogy(Apr3.range, mean(Apr3.attn_bscat(:,t.ol),2).*combo_patch, 'g',Apr3.range, 250*Apr3.std_attn_prof,'r');
% %
% figure; imagegap(serial2Hh(Apr25.time), Apr25.range, real(log10(Apr25.attn_bscat.*(combo_patch*ones(size(Apr25.time)))))); colorbar
% caxis([-1.5,2])
% %%
% 
% t.ol_2 = (serial2Hh(Apr25.time)>=14)&(serial2Hh(Apr25.time)<=15);
% rescaled = Apr25.attn_bscat.*(combo_patch*ones(size(Apr25.time)));
% 
% r.ol_2 = (Apr25.range>=1.5)&(Apr25.range<=2);
% r.low = (Apr25.range<2);
% P_low = polyfit(Apr25.range(r.ol_2), real(log10(mean(rescaled(r.ol_2,t.ol_2),2))),1);
% figure; semilogy(Apr25.range, mean(rescaled(:,t.ol_2),2),'.k',Apr25.range(r.low),10.^polyval(P_low,Apr25.range(r.low)),'r');
% %%
% 
% low_patch2 = 10.^polyval(P_low,Apr25.range(r.low))./(mean(rescaled(r.low,t.ol_2),2));
% %%
% ol_corr = combo_patch;
% ol_corr(r.low) = ol_corr(r.low) .* low_patch2;
% 
% figure; imagegap(serial2Hh(Apr25.time), Apr25.range, real(log10(Apr25.attn_bscat.*(ol_corr*ones(size(Apr25.time)))))); colorbar
% caxis([-1.5,2]);
% %%
% ol_corr = ol_corr ./ ol_corr(end);
% % figure; semilogy(Apr25.range, ol_corr,'.');
% 
% ol_mat.range = Apr25.range;
% ol_mat.corr = ol_corr;
% save(['C:\mlib\lidar\mpl\overlap\fkb_Apr_ol.mat'],'ol_mat');
% 
% this = loadinto('C:\mlib\lidar\mpl\overlap\fkb_Apr_ol.mat');
%    % Apr 25, 14-16 UTC < 2 km overlap
%    %%
%    mpl = ancload_coords(['E:\case_studies\fkb\fkbmplolM1.b1\fkbmplpolM1.b1.20070328.000002.cdf']);
%    %
%    mpl = ancloadpart(mpl,1,4000);
%    
%    mpl = ancsift(mpl, mpl.dims.time, [1:4000]);
%    %%
%    polV = mean(mpl.vars.polarization_control_voltage.data)
%    cop = (mpl.vars.polarization_control_voltage.data<polV);
%    
% ap.cop_raw = mean(mpl.vars.signal_return.data(:,cop),2);
% ap.crs_raw = mean(mpl.vars.signal_return.data(:,~cop),2);
% ap.range = mpl.vars.range.data;
% r.gte1 = ap.range>=1;
% r.gte50 = ap.range>=50;
% ap.cop = [ap.cop_raw(~r.gte1);smooth(mpl.vars.range.data(r.gte1), ap.cop_raw(r.gte1), .02,'lowess')] - mean(ap.cop_raw(r.gte50));
% ap.crs = [ap.crs_raw(~r.gte1);smooth(mpl.vars.range.data(r.gte1), ap.crs_raw(r.gte1), .02,'lowess')] - mean(ap.crs_raw(r.gte50));
%    figure; semilogy(mpl.vars.range.data, ap.cop_raw, 'b',mpl.vars.range.data, ap.cop, 'r')
% figure; semilogy(mpl.vars.range.data, ap.crs_raw, 'b',mpl.vars.range.data, ap.crs, 'r')
% save('C:\matlib\ap_fkb.Mar28.mat','ap')