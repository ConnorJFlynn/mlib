function SGP_Ze_responsivity
% And now computing responsivity of Ze specs from ARM sphere radiances
% First, load the SAS data files:
pname = 'C:\case_studies\SAS\Cals pre deployment\Ze1_1010109U1_1001069U1\40ms\';
visname = '20101215_1010109U1.csv';
Ze_vis_1010109U1 = SAS_read_Albert_csv([pname, visname]);
Ze_vis_1010109U1.spec_sans_dark = Ze_vis_1010109U1.spec-ones([length(Ze_vis_1010109U1.Shuttered_0),1])...
   *mean(Ze_vis_1010109U1.spec(Ze_vis_1010109U1.Shuttered_0==0,:));
%%
figure; semilogy(Ze_vis_1010109U1.nm, Ze_vis_1010109U1.spec_sans_dark(Ze_vis_1010109U1.Shuttered_0==1,:),'r',...
   Ze_vis_1010109U1.nm, mean(Ze_vis_1010109U1.spec_sans_dark(Ze_vis_1010109U1.Shuttered_0==1,:)),'k')
%%

min_nm = 340;
max_nm = 1130;
good = Ze_vis_1010109U1.nm>=min_nm&Ze_vis_1010109U1.nm<=max_nm;

sphere_rad = Labsphere_ARM_lampA_ps1;
Ze_vis_1010109U1.rad = interp1(sphere_rad(:,1), sphere_rad(:,2), Ze_vis_1010109U1.nm,'pchip');
Ze_vis_1010109U1.rad(~good) = NaN;

Ze_vis_1010109U1.resp = (mean(Ze_vis_1010109U1.spec_sans_dark(Ze_vis_1010109U1.Shuttered_0==1,:))...
   ./mean(Ze_vis_1010109U1.Integration(Ze_vis_1010109U1.Shuttered_0==1)))./Ze_vis_1010109U1.rad;

% figure; semilogy(sphere_rad(:,1), sphere_rad(:,2),'k-', Ze_vis_1010109U1.nm, Ze_vis_1010109U1.rad, '.');
figure; semilogy(Ze_vis_1010109U1.nm, Ze_vis_1010109U1.resp, '-k.');

%% Look at variance dependence
ccd.mean_sig = mean(Ze_vis_1010109U1.spec_sans_dark(Ze_vis_1010109U1.Shuttered_0==1,:),1);
% ccd.mean_sig = mean(ccd.Sample(part,:),1)- mean_dark_offset;
ccd.std_sig = std(Ze_vis_1010109U1.spec_sans_dark(Ze_vis_1010109U1.Shuttered_0==1,:),1,1);
ccd.var_sig = ccd.std_sig.^2;
%%

figure;
scatter(ccd.mean_sig(good),(ccd.var_sig(good)), 8,Ze_vis_1010109U1.nm(good));colorbar;
title('Avaspec CCD 2048 variance vs signal')
xlabel('dark-subtracted signal')
ylabel('variance')
hold('on')
good = ~isnan(ccd.mean_sig)&~isnan(ccd.var_sig)&(ccd.mean_sig>0)&(ccd.var_sig>0)&good;
[P_cmos,S_cmos,MU_cmos] = polyfit(ccd.mean_sig(good),(ccd.var_sig(good)),1);
read_noise_variance = polyval(P_cmos,-MU_cmos(1)./MU_cmos(2));
spec_g = P_cmos(1)./MU_cmos(2);
ccd.spec_g = spec_g;
plot(ccd.mean_sig(good), polyval(P_cmos,ccd.mean_sig(good),S_cmos,MU_cmos),'r-');
hold('off')
tx1 = text(.03,.9,...
   {['g= ',sprintf('%2.2e cts/e',spec_g)],...
   [sprintf('1/g = %.0f e/cts',1./spec_g)],...
   ['read noise variance =',sprintf('%2.2f',read_noise_variance)]},...
   'units','normal','backgroundcolor','w','edgecolor','k','fontname','Tahoma','fontweight','bold');
%%
% zoom('on');
% k = menu('Zoom in, select save or skip when done.','save','skip');
% if k ==1
% saveas(gcf,[plot_path, spec_desc, '_g'],'fig');
% saveas(gcf,[plot_path, spec_desc, '_g'],'png');
% end

%%
pname = 'C:\case_studies\SAS\Cals pre deployment\Ze1_1010109U1_1001069U1\40ms\';
nirname = '20101215_1001069U1.csv';
Ze_nir_1001069U1 = SAS_read_Albert_csv([pname, nirname]);
Ze_nir_1001069U1.spec_sans_dark = Ze_nir_1001069U1.spec-ones([length(Ze_nir_1001069U1.Shuttered_0),1])...
   *mean(Ze_nir_1001069U1.spec(Ze_nir_1001069U1.Shuttered_0==0,:));
figure; semilogy(Ze_nir_1001069U1.nm, Ze_nir_1001069U1.spec_sans_dark(Ze_nir_1001069U1.Shuttered_0==1,:),'r',...
   Ze_nir_1001069U1.nm, mean(Ze_nir_1001069U1.spec_sans_dark(Ze_nir_1001069U1.Shuttered_0==1,:)),'k')
%%
% min nm = 900 nm;
% max nm = 1735 nm;
min_nm = 900;
max_nm = 1735;
good = (Ze_nir_1001069U1.nm >= min_nm) & (Ze_nir_1001069U1.nm <= max_nm);
good_stats = Ze_nir_1001069U1.nm>1000&Ze_nir_1001069U1.nm<1350|Ze_nir_1001069U1.nm>1450&Ze_nir_1001069U1.nm<1650;

Ze_nir_1001069U1.rad = interp1(sphere_rad(:,1), sphere_rad(:,2), Ze_nir_1001069U1.nm,'pchip');
Ze_nir_1001069U1.rad(~good) = NaN;
% Ze_nir_1001069U1.rad(Ze_nir_1001069U1.nm<900) = NaN;
% Ze_nir_1001069U1.rad(Ze_nir_1001069U1.nm>1735) = NaN;
Ze_nir_1001069U1.resp = (mean(Ze_nir_1001069U1.spec_sans_dark(Ze_nir_1001069U1.Shuttered_0==1,:))...
   ./mean(Ze_nir_1001069U1.Integration(Ze_nir_1001069U1.Shuttered_0==1)))./Ze_nir_1001069U1.rad;
% smoothed_mean = smooth(Ze_nir_1001069U1.resp,4);

ri = relmax(Ze_nir_1001069U1.resp); ri = sort(ri);
Ze_nir_1001069U1.resp = interp1(Ze_nir_1001069U1.nm([1:(ri(1)-1),ri,(ri(end)+1):end]), Ze_nir_1001069U1.resp([1:(ri(1)-1),ri,(ri(end)+1):end]), Ze_nir_1001069U1.nm);

figure; semilogy(Ze_vis_1010109U1.nm, Ze_vis_1010109U1.resp, '.-',Ze_nir_1001069U1.nm, Ze_nir_1001069U1.resp, '.-');
title('SGP SAS-Ze responsivity');
legend('vis','nir');
%%
p = mfilename('fullpath');
[ppname, ~,~] = fileparts(p);
ppname = [ppname, filesep];
tmp = [Ze_vis_1010109U1.nm;Ze_vis_1010109U1.resp];
saveasp(tmp, [ppname,'sgpsasze_Si_resp_20110307.m']);
saveasp(tmp, [pname,'sgpsasze_Si_resp_20110307.m']);
tmp = [Ze_nir_1001069U1.nm;Ze_nir_1001069U1.resp];
saveasp(tmp, [ppname,'sgpsasze_InGaAs_resp_20110307.m']);
saveasp(tmp, [pname,'sgpsasze_InGaAs_resp_20110307.m']);
%%
nir.mean_sig = mean(Ze_nir_1001069U1.spec_sans_dark(Ze_nir_1001069U1.Shuttered_0==1,:),1);
% ccd.mean_sig = mean(ccd.Sample(part,:),1)- mean_dark_offset;
nir.std_sig = std(Ze_nir_1001069U1.spec_sans_dark(Ze_nir_1001069U1.Shuttered_0==1,:),1,1);
nir.var_sig = nir.std_sig.^2;
figure;
scatter(nir.mean_sig(good_stats),(nir.var_sig(good_stats)), 8,Ze_nir_1001069U1.nm(good_stats));colorbar;
title('SAS-Ze NIR variance vs signal')
xlabel('dark-subtracted signal')
ylabel('variance')
%%

%%
blah = sgpsasze_Si_resp_20110307;
blah(2,isnan(blah(2,:))) = 0;
% Ze_vis_1010109U1.resp(isnan(Ze_vis_1010109U1.resp))= 0;
fid = fopen([pname, 'Ze_vis_1010109U1.dat'],'w'); 
% fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
fprintf(fid,'%4.2f, %4.5g \n',blah);
fclose(fid);
Ze_nir_1001069U1.resp(isnan(Ze_nir_1001069U1.resp))= 0;
blah = sgpsasze_InGaAs_resp_20110307;
blah(2,isnan(blah(2,:))) = 0;
fid = fopen([pname,'Ze_nir_1001069U1.dat'],'w'); 
% fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
% fprintf(fid,'%4.2f, %4.5g \n',[Ze_nir_1001069U1.nm; Ze_nir_1001069U1.resp]);
fprintf(fid,'%4.2f, %4.5g \n',blah);
fclose(fid);

%%
% guey = loadinto('guey.mat');
% gnm = guey(:,1)>=300 & guey(:,1)<=2500;
% fid = fopen(['C:\mlib\local\rad_cals\guey_SAS_subrange.dat'],'w'); 
% 
% fprintf(fid,'%4.2f, %4.5g \n',[guey(gnm,1)'; guey(gnm,3)']);
% fclose(fid);
%%
% pme = saveasp(guey, 'C:\mlib\local\rad_cals\gueymard_ESR.m');


%%
 figure; semilogy(sphere_rad(:,1), sphere_rad(:,2),'k-', ...
    Ze_vis_1010109U1.nm, Ze_vis_1010109U1.rad, 'r.',...
    Ze_nir_1001069U1.nm, Ze_nir_1001069U1.rad, 'b.');