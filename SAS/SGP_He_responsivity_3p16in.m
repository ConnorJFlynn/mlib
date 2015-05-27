function SGP_He_responsivity_3p16in

% And now computing responsivity of He specs from ARM sphere radiances
% First, load the SAS data files:
pname = 'C:\case_studies\SAS\Cals pre deployment\He1_1010108U1_1010110U1\3point16 inches back no plate\';
visname = '20101216_1010108U1.csv';
nirname = '20101216_1010110U1.csv';
He_vis_1010108U1 = SAS_read_ava([pname, visname]);
He_vis_1010108U1.spec_sans_dark = He_vis_1010108U1.spec-ones([length(He_vis_1010108U1.Shuttered_0),1])...
   *mean(He_vis_1010108U1.spec(He_vis_1010108U1.Shuttered_0==0,:));

He_nir_H1010110U1 = SAS_read_ava([pname, nirname]);
He_nir_H1010110U1.spec_sans_dark = He_nir_H1010110U1.spec-ones([length(He_nir_H1010110U1.Shuttered_0),1])...
   *mean(He_nir_H1010110U1.spec(He_nir_H1010110U1.Shuttered_0==0,:));
figure; semilogy(He_vis_1010108U1.nm, He_vis_1010108U1.spec_sans_dark(He_vis_1010108U1.Shuttered_0==1,:),'r',...
   He_vis_1010108U1.nm, mean(He_vis_1010108U1.spec_sans_dark(He_vis_1010108U1.Shuttered_0==1,:)),'k',...
   He_nir_H1010110U1.nm, He_nir_H1010110U1.spec_sans_dark(He_nir_H1010110U1.Shuttered_0==1,:),'r',...
   He_nir_H1010110U1.nm, mean(He_nir_H1010110U1.spec_sans_dark(He_nir_H1010110U1.Shuttered_0==1,:)),'k')
% good = He_vis_1010108U1.nm>300&He_vis_1010108U1.nm<1130;
min_nm = 340;
max_nm = 1130;
good = He_vis_1010108U1.nm>=min_nm & He_vis_1010108U1.nm<=max_nm;
%%
sphere_rad = Labsphere_ARM_lampA_ps1;
% The idea is that we've selected the solid angle so that the numerical value for the radiance of
% the sphere is equal to the numerical value for the irradiance in our
% units.
He_vis_1010108U1.rad = interp1(sphere_rad(:,1), sphere_rad(:,2), He_vis_1010108U1.nm,'pchip');
He_vis_1010108U1.rad(~good) = NaN;
He_vis_1010108U1.resp = (mean(He_vis_1010108U1.spec_sans_dark(He_vis_1010108U1.Shuttered_0==1,:))...
   ./mean(He_vis_1010108U1.Integration(He_vis_1010108U1.Shuttered_0==1)))./He_vis_1010108U1.rad;
% figure; semilogy(sphere_rad(:,1), sphere_rad(:,2),'k-', He_vis_1010108U1.nm, He_vis_1010108U1.rad, '.');
% figure; semilogy(He_vis_1010108U1.nm, He_vis_1010108U1.resp, '-k.');

%% Look at variance dependence
% ccd.mean_sig = mean(He_vis_1010108U1.spec_sans_dark(He_vis_1010108U1.Shuttered_0==1,:),1);
% % ccd.mean_sig = mean(ccd.Sample(part,:),1)- mean_dark_offset;
% ccd.std_sig = std(He_vis_1010108U1.spec_sans_dark(He_vis_1010108U1.Shuttered_0==1,:),1,1);
% ccd.var_sig = ccd.std_sig.^2;
% %%
% figure;
% scatter(ccd.mean_sig(good),(ccd.var_sig(good)), 8,He_vis_1010108U1.nm(good));colorbar;
% title('Avaspec CCD 2048 variance vs signal')
% xlabel('dark-subtracted signal')
% ylabel('variance')
% hold('on')
% good = ~isNaN(ccd.mean_sig)&~isNaN(ccd.var_sig)&(ccd.mean_sig>0)&(ccd.var_sig>0)&good;
% [P_cmos,S_cmos,MU_cmos] = polyfit(ccd.mean_sig(good),(ccd.var_sig(good)),1);
% read_noise_variance = polyval(P_cmos,-MU_cmos(1)./MU_cmos(2));
% spec_g = P_cmos(1)./MU_cmos(2);
% ccd.spec_g = spec_g;
% plot(ccd.mean_sig(good), polyval(P_cmos,ccd.mean_sig(good),S_cmos,MU_cmos),'r-');
% hold('off')
% tx1 = text(.03,.9,...
%    {['g= ',sprintf('%2.2e cts/e',spec_g)],...
%    [sprintf('1/g = %.0f e/cts',1./spec_g)],...
%    ['read noise variance =',sprintf('%2.2f',read_noise_variance)]},...
%    'units','normal','backgroundcolor','w','edgecolor','k','fontname','Tahoma','fontweight','bold');

%%
min_nm = 900;
max_nm = 1735;
good = (He_nir_H1010110U1.nm > min_nm)& (He_nir_H1010110U1.nm < 1372)...
   |(He_nir_H1010110U1.nm > 1395) & (He_nir_H1010110U1.nm<=max_nm);

He_nir_H1010110U1.rad = interp1(sphere_rad(:,1), sphere_rad(:,2), He_nir_H1010110U1.nm,'pchip');
% He_nir_H1010110U1.rad(He_nir_H1010110U1.nm<900) = NaN;
% He_nir_H1010110U1.rad(He_nir_H1010110U1.nm>1735) = NaN;
He_nir_H1010110U1.rad(~good)= NaN;
He_nir_H1010110U1.resp = (mean(He_nir_H1010110U1.spec_sans_dark(He_nir_H1010110U1.Shuttered_0==1,:))...
   ./mean(He_nir_H1010110U1.Integration(He_nir_H1010110U1.Shuttered_0==1)))./He_nir_H1010110U1.rad;
ri = relmax(He_nir_H1010110U1.resp); ri = sort(ri);
semilogy(He_vis_1010108U1.nm, He_vis_1010108U1.resp, '.-',He_nir_H1010110U1.nm, He_nir_H1010110U1.resp, '.-',...
 He_nir_H1010110U1.nm(ri), He_nir_H1010110U1.resp(ri),'ro'  );
title('SGP SAS-He responsivity');
legend('vis','nir');
He_nir_H1010110U1.resp = interp1(He_nir_H1010110U1.nm([1:(ri(1)-1),ri,(ri(end)+1):end]), He_nir_H1010110U1.resp([1:(ri(1)-1),ri,(ri(end)+1):end]), He_nir_H1010110U1.nm);

%%
% nir.mean_sig = mean(He_nir_H1010110U1.spec_sans_dark(He_nir_H1010110U1.Shuttered_0==1,:),1);
% % ccd.mean_sig = mean(ccd.Sample(part,:),1)- mean_dark_offset;
% nir.std_sig = std(He_nir_H1010110U1.spec_sans_dark(He_nir_H1010110U1.Shuttered_0==1,:),1,1);
% nir.var_sig = nir.std_sig.^2;

%%
figure; semilogy(sphere_rad(:,1), sphere_rad(:,2),'k-', He_vis_1010108U1.nm, He_vis_1010108U1.rad, 'b+',...
   He_nir_H1010110U1.nm, He_nir_H1010110U1.rad, 'rx');
%%
figure; semilogy(He_vis_1010108U1.nm, He_vis_1010108U1.resp, '.-',He_nir_H1010110U1.nm, He_nir_H1010110U1.resp, '.-');
title('SGP SAS-He responsivity 0.8"');
legend('vis','nir');
%%
% figure;
% scatter(nir.mean_sig(good),(nir.var_sig(good)), 8,He_nir_H1010110U1.nm(good));colorbar;
% title('SAS-He nir variance vs signal')
% xlabel('dark-subtracted signal')
% ylabel('variance')
% hold('on')
% good = ~isNaN(nir.mean_sig)&~isNaN(nir.var_sig)&(nir.mean_sig>0)&(nir.var_sig>0)&good;
% [P_cmos,S_cmos,MU_cmos] = polyfit(nir.mean_sig(good),(nir.var_sig(good)),1);
% read_noise_variance = polyval(P_cmos,-MU_cmos(1)./MU_cmos(2));
% spec_g = P_cmos(1)./MU_cmos(2);
% nir.spec_g = spec_g;
% plot(nir.mean_sig(good), polyval(P_cmos,nir.mean_sig(good),S_cmos,MU_cmos),'r-');
% hold('off')
% tx1 = text(.03,.9,...
%    {['g= ',sprintf('%2.2e cts/e',spec_g)],...
%    [sprintf('1/g = %.0f e/cts',1./spec_g)],...
%    ['read noise variance =',sprintf('%2.2f',read_noise_variance)]},...
%    'units','normal','backgroundcolor','w','edgecolor','k','fontname','Tahoma','fontweight','bold');
%%
% saveasp(He_vis_1010108U1, [pname,'He_vis_1010108U1_p8in.m']);
% saveasp(He_nir_H1010110U1, [pname,'He_nir_H1010110U1_p8in.m']);
% 
% He_vis_1010108U1.resp(isNaN(He_vis_1010108U1.resp))= 0;
% % fid = fopen(['C:\case_studies\SAS\Cals pre deployment\Ze1_1010109U1_1001069U1\40ms\Ze_vis_1010109U1.dat'],'w'); 
% fid = fopen([pname,'He_vis_1010108U1.dat'],'w'); 
% 
% % fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% % fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
% fprintf(fid,'%4.2f, %4.5g \n',[He_vis_1010108U1.nm; He_vis_1010108U1.resp]);
% fclose(fid);
% He_nir_H1010110U1.resp(isNaN(He_nir_H1010110U1.resp))= 0;
% % fid = fopen(['C:\case_studies\SAS\Cals pre deployment\Ze1_1010109U1_1001069U1\40ms\He_nir_H1010110U1.dat'],'w'); 
% fid = fopen([pname, 'He_nir_H1010110U1.dat'],'w'); 
% 
% % fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% % fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
% fprintf(fid,'%4.2f, %4.5g \n',[He_nir_H1010110U1.nm; He_nir_H1010110U1.resp]);
% fclose(fid);
%%
p = mfilename('fullpath');
[ppname, ~,~] = fileparts(p);
ppname = [ppname, filesep];
tmp = [He_vis_1010108U1.nm;He_vis_1010108U1.resp];
saveasp(tmp, [ppname,'sgpsashe_Si_resp_3p16in_20110307.m']);
saveasp(tmp, [pname,'sgpsashe_Si_resp_3p16in_20110307.m']);
tmp = [He_nir_H1010110U1.nm;He_nir_H1010110U1.resp];
saveasp(tmp, [ppname,'sgpsashe_InGaAs_resp_3p16in_20110307.m']);
saveasp(tmp, [pname,'sgpsashe_InGaAs_resp_3p16in_20110307.m']);
% 
% saveasp(He_vis_1010108U1, [pname,'He_vis_1010108U1_p8in.m']);
% saveasp(He_nir_H1010110U1, [pname,'He_nir_H1010110U1_p8in.m']);
blah = sgpsashe_Si_resp_3p16in_20110307;
blah(2,isNaN(blah(2,:))) = 0;
% He_vis_1010108U1.resp(isNaN(He_vis_1010108U1.resp))= 0;
% fid = fopen(['C:\case_studies\SAS\Cals pre deployment\Ze1_1010109U1_1001069U1\40ms\Ze_vis_1010109U1.dat'],'w'); 
fid = fopen([pname,'He_vis_1010108U1_3p16in.dat'],'w'); 
% fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
fprintf(fid,'%4.2f, %4.5g \n',blah);
fclose(fid);

blah = sgpsashe_InGaAs_resp_3p16in_20110307;
blah(2,isNaN(blah(2,:))) = 0;
% fid = fopen(['C:\case_studies\SAS\Cals pre deployment\Ze1_1010109U1_1001069U1\40ms\He_nir_H1010110U1.dat'],'w'); 
fid = fopen([pname, 'He_nir_H1010110U1_3p16in.dat'],'w'); 

% fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
fprintf(fid,'%4.2f, %4.5g \n',blah);
fclose(fid);

%%
% guey = loadinto('guey.mat');
% gnm = guey(:,1)>=300 & guey(:,1)<=2500;
% fid = fopen(['C:\mlib\local\rad_cals\guey_SAS_subrange.dat'],'w'); 
% % fprintf(fid,'Source:  ARM Labsphere via SWS to ARCS 455 \n');
% % fprintf(fid,'Units:   Responsivity in (cts-dark)/ms/[mW/(m^2.sr.nm)] \n');
% fprintf(fid,'%4.2f, %4.5g \n',[guey(gnm,1)'; guey(gnm,3)']);
% fclose(fid);
% %%
% pme = saveasp(guey, 'C:\mlib\local\rad_cals\gueymard_ESR.m');
% 
% 
% %%
%  figure; semilogy(sphere_rad(:,1), sphere_rad(:,2),'k-', ...
%     He_vis_1010108U1.nm, He_vis_1010108U1.rad, 'r.',...
%     He_nir_H1010110U1.nm, He_nir_H1010110U1.rad, 'b.');