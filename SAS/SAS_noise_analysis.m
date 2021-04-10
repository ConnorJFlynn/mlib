function SAS_noise_analysis
in_vis = getfullname('*.csv','SAS_radcal'); 
[pname, visname,ext] = fileparts(in_vis);pname=[pname, filesep];
visname = [visname,ext]; clear ext;

vis = SAS_read_Albert_csv([pname, visname]); 
close(gcf);
vis.Shuttered_0 = vis.Shuttered_0 | vis.spec(:,600)>1000;
vis.Shuttered_0 = ~(vis.Shuttered_0==0 | vis.spec(:,600)<1000);
vis.spec_sans_dark = vis.spec-ones([length(vis.Shuttered_0),1])...
   *mean(vis.spec(vis.Shuttered_0==0,:));
% figure; semilogy(vis.nm, vis.spec_sans_dark(vis.Shuttered_0==1,:),'r',...
%    vis.nm, mean(vis.spec_sans_dark(vis.Shuttered_0==1,:)),'k')
% good = He_vis_1010108U1.nm>300&He_vis_1010108U1.nm<1130;
min_nm = 340;
max_nm = 1130;
good = vis.nm>=min_nm & vis.nm<=max_nm;
%%
% sphere_rad = Labsphere_ARM_lampA_ps1;
% % The idea is that we've selected the solid angle so that the numerical value for the radiance of
% % the sphere is equal to the numerical value for the irradiance in our
% % units.
% vis.rad = interp1(sphere_rad(:,1), sphere_rad(:,2), vis.nm,'pchip');
% vis.rad(~good) = NaN;
% vis.resp = (mean(vis.spec_sans_dark(vis.Shuttered_0==1,:))...
%    ./mean(vis.Integration(vis.Shuttered_0==1)))./vis.rad;
% figure; semilogy(sphere_rad(:,1), sphere_rad(:,2),'k-', vis.nm, vis.rad, '.');
% figure; semilogy(vis.nm, vis.resp, '-k.');

%% Look at variance dependence\
vis.mean_sig = mean(vis.spec_sans_dark(vis.Shuttered_0==1,:),1);
vis.std_sig = std(vis.spec_sans_dark(vis.Shuttered_0==1,:),1,1);
vis.mean_sig = mean(vis.spec(vis.Shuttered_0==1,:),1);
vis.std_sig = std(vis.spec(vis.Shuttered_0==1,:),1,1);
vis.var_sig = vis.std_sig.^2;
%%
figure;
scatter(vis.mean_sig(good),(vis.var_sig(good)), 8,vis.nm(good));colorbar;
title('SAS-He Si CCD variance vs signal')
xlabel('dark-subtracted signal')
ylabel('variance')
hold('on')
good = ~isnan(vis.mean_sig)&~isnan(vis.var_sig)&(vis.mean_sig>0)&(vis.var_sig>0)&good;
[P_cmos,S_cmos,MU_cmos] = polyfit(vis.mean_sig(good),(vis.var_sig(good)),1);
read_noise_variance = polyval(P_cmos,-MU_cmos(1)./MU_cmos(2));
spec_g = P_cmos(1)./MU_cmos(2);
vis.spec_g = spec_g;
plot(vis.mean_sig(good), polyval(P_cmos,vis.mean_sig(good),S_cmos,MU_cmos),'r-');
hold('off')
tx1 = text(.03,.9,...
   {['g= ',sprintf('%2.2e cts/e',spec_g)],...
   [sprintf('1/g = %.2f e/cts',1./spec_g)],...
   ['read noise variance =',sprintf('%2.2f',read_noise_variance)]},...
   'units','normal','backgroundcolor','w','edgecolor','k','fontname','Tahoma','fontweight','bold');
%%
in_nir = getfullname('*.csv','SAS_radcal'); 
[pname, nirname,ext] = fileparts(in_nir); pname=[pname, filesep];
nirname = [nirname,ext]; clear ext;

nir = SAS_read_Albert_csv([pname, nirname]);
close(gcf);
min_nm = 900; max_nm = 1700;
good = (nir.nm > min_nm)& (nir.nm < 1372)|(nir.nm > 1395) & (nir.nm<=1575)|(nir.nm > 1650) & (nir.nm<=max_nm);
max_min = (max(nir.spec(:,good)')./min(nir.spec(:,good)'))';
nir.Shuttered_0 = nir.Shuttered_0 | max_min>5;
nir.Shuttered_0 = ~(nir.Shuttered_0==0 | max_min<5);

nir.spec_sans_dark = nir.spec-ones([length(nir.Shuttered_0),1])...
   *mean(nir.spec(nir.Shuttered_0==0,:));

% figure; semilogy(nir.nm, nir.spec_sans_dark(nir.Shuttered_0==1,:),'r',...
%    nir.nm, mean(nir.spec_sans_dark(nir.Shuttered_0==1,:)),'k')
%%
nir.mean_sig = mean(nir.spec_sans_dark(nir.Shuttered_0==1,:),1);
% ccd.mean_sig = mean(ccd.Sample(part,:),1)- mean_dark_offset;
nir.std_sig = std(nir.spec_sans_dark(nir.Shuttered_0==1,:),1,1);
nir.mean_sig = mean(nir.spec(nir.Shuttered_0==1,:),1);
nir.std_sig = std(nir.spec(nir.Shuttered_0==1,:),1,1);
nir.var_sig = nir.std_sig.^2;

figure;
scatter(nir.mean_sig(good),(nir.var_sig(good)), 8,nir.nm(good));colorbar;
title('SAS-He InGaAs Array variance vs signal')
xlabel('signal')
ylabel('variance')
hold('on')
good = ~isnan(nir.mean_sig)&~isnan(nir.var_sig)&(nir.mean_sig>0)&(nir.var_sig>0)&good;
[P_cmos,S_cmos,MU_cmos] = polyfit(nir.mean_sig(good),(nir.var_sig(good)),1);
read_noise_variance = polyval(P_cmos,-MU_cmos(1)./MU_cmos(2));
spec_g = P_cmos(1)./MU_cmos(2);
nir.spec_g = spec_g;
plot(nir.mean_sig(good), polyval(P_cmos,nir.mean_sig(good),S_cmos,MU_cmos),'r-');
hold('off')
tx1 = text(.03,.9,...
   {['g= ',sprintf('%2.2e cts/e',spec_g)],...
   [sprintf('1/g = %.0f e/cts',1./spec_g)],...
   ['read noise variance =',sprintf('%2.2f',read_noise_variance)]},...
   'units','normal','backgroundcolor','w','edgecolor','k','fontname','Tahoma','fontweight','bold');
%%
