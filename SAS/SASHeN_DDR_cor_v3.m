function blah % DDR linearity for SASHe with collocated MFRSR
% This code loads MFRSR and SASHe files "filtered" to exclude bad <0 irradiances and 
% ddr that exceed Rayleigh.  It compares SASHe to MFRSR DDRs and computes a
% correction factor using a robust 2nd order fit of binned values, and then saves the
% result to a mat file for use in ARM_aod_ddr_plots_Kassianov_shared

% mfr = load(['D:\aodfit_be\pvc\pvcmfrsraod1michM1.c1.ddr_filt.20120709_20130404.mat']);
% sas = load(['D:\aodfit_be\pvc\pvcsashevisaodM1.c1.ddr_filt.20120629_20130621.mat']);
% 
% mfr = load(['D:\aodfit_be\hou\houmfrsr7nchM1.b1.ddr_filt.20210915_20221001.mat']);
% sas = load(['D:\aodfit_be\hou\housashevisaodM1.c1.ddr_filt.20210921_20221001.mat']);

mfr = load(['D:\epc\epcmfrsr7nchM1.b1.ddr_filt.20230505_20230923.mat']);
sas = load(['D:\epc\epcsasheniraodM1.c1.ddr_filt.20230113_20230810']);
% sas = load(['D:\epc\epcsasheniraodM1.c1.ddr_filt.Feb10_14.mat']);

% mfr = load(['D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.ddr_filt.20210915_20221001.mat']);
% sas = load(['D:\aodfit_be\hou\housasheniraodM1.c1.ddr_filt.20210921_20221001.mat']);

[outpath,fname] = fileparts(mfr.fname); outpath = [fileparts(outpath),filesep];
if foundstr(fname,'epc')
   tla = 'epc';
elseif foundstr(fname, 'pvc')
   tla = 'pvc';
elseif foundstr(fname,'hou')
   tla = 'hou';
end
ver = 'v3';

disp(length(mfr.time))
figure; plot(mfr.time, [mfr.vdata.direct_diffuse_ratio_filter1;mfr.vdata.direct_diffuse_ratio_filter2;...
   mfr.vdata.direct_diffuse_ratio_filter3;mfr.vdata.direct_diffuse_ratio_filter4;...
   mfr.vdata.direct_diffuse_ratio_filter5;mfr.vdata.direct_diffuse_ratio_filter7],'.');legend('415','500','615','675','870','1625'); dynamicDateTicks;
title([upper(tla),' MFRSR DDR']);
% if isfield(mfr.vdata,'direct_diffuse_ratio_filter7');
%    hold('on');
%    plot(mfr.time, mfr.vdata.direct_diffuse_ratio_filter7,'k.');
%    legend('415','500','615','675','870','1625');
%    hold('off')
% end

ddr = sas.vdata.direct_normal_transmittance./sas.vdata.diffuse_transmittance;
figure; plot(sas.time, ddr, '.'); dynamicDateTicks
title([upper(tla),' SASHe DDR']);
linkexes;
ok = menu('Hit ok when done zooming','OK')
xl = xlim;
%Zooming into region including Feb-Apr
xl_ = mfr.time>xl(1) & mfr.time<xl(2); mfr = anc_sift(mfr, xl_);
xl_ = sas.time>xl(1) & sas.time<xl(2); sas = anc_sift(sas, xl_);

[mins, sinm] = nearest(mfr.time, sas.time);
mfr = anc_sift(mfr, mins); sas = anc_sift(sas, sinm);

sas_ddr = sas.vdata.direct_normal_transmittance./sas.vdata.diffuse_transmittance;

% figure; plot(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),'.'); legend('filter 1')
% good = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),2,6); sum(good)
%
% [P] = polyfit(mfr.vdata.direct_diffuse_ratio_filter1(good), sas_ddr(2,good),2);
% [P_] = polyfit(sas_ddr(2,good),mfr.vdata.direct_diffuse_ratio_filter1(good),2);
%
% figure; plot(mfr.vdata.direct_diffuse_ratio_filter1(good), sas_ddr(2,good), '.',...
%    mfr.vdata.direct_diffuse_ratio_filter1(good), polyval(P,mfr.vdata.direct_diffuse_ratio_filter1(good)),'c-',...
%    polyval(P_,sas_ddr(2,good)), sas_ddr(2,good),'r-')

% D = den2plot(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:));
% figure; scatter(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),6,log10(D)); colormap(comp_map_w_jet);

% figure; plot(mfr.vdata.direct_diffuse_ratio_filter2, sas_ddr(4,:),'.'); legend('filter 2')

good7 = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter7, sas_ddr(6,:),2,4.5);

% figure; plot(...
%    mfr.vdata.direct_diffuse_ratio_filter5(good5), sas_ddr(7,good5),'.',...
%    mfr.vdata.direct_diffuse_ratio_filter4(good4), sas_ddr(6,good4),'.',...
%    mfr.vdata.direct_diffuse_ratio_filter3(good3), sas_ddr(5,good3),'.',...
%    mfr.vdata.direct_diffuse_ratio_filter2(good2), sas_ddr(4,good2),'.',...
%       mfr.vdata.direct_diffuse_ratio_filter1(good1), sas_ddr(2,good1),'.');
% legend('filter 5','filter 4','filter 3','filter 2','filter 1')
% xlabel('MFRSR DDR'); ylabel('SASHe DDR');
% title('PVC MFRSR and SASHE DDR Analysis');
% figure; plot(...
%    mfr.vdata.direct_diffuse_ratio_filter5(good5), sas_ddr(7,good5)./mfr.vdata.direct_diffuse_ratio_filter5(good5),'.',...
%    mfr.vdata.direct_diffuse_ratio_filter4(good4), sas_ddr(6,good4)./mfr.vdata.direct_diffuse_ratio_filter4(good4),'.',...
%    mfr.vdata.direct_diffuse_ratio_filter3(good3), sas_ddr(5,good3)./mfr.vdata.direct_diffuse_ratio_filter3(good3),'.',...
%    mfr.vdata.direct_diffuse_ratio_filter2(good2), sas_ddr(4,good2)./mfr.vdata.direct_diffuse_ratio_filter2(good2),'.',...
%       mfr.vdata.direct_diffuse_ratio_filter1(good1), sas_ddr(2,good1)./mfr.vdata.direct_diffuse_ratio_filter1(good1),'.');
% legend('filter 5','filter 4','filter 3','filter 2','filter 1');
% logy
% title('PVC MFRSR and SASHE DDR Analysis');
%
% figure; plot(...
%    sas_ddr(7,good5), sas_ddr(7,good5)./mfr.vdata.direct_diffuse_ratio_filter5(good5),'.',...
%    sas_ddr(6,good4), sas_ddr(6,good4)./mfr.vdata.direct_diffuse_ratio_filter4(good4),'.',...
%    sas_ddr(5,good3), sas_ddr(5,good3)./mfr.vdata.direct_diffuse_ratio_filter3(good3),'.',...
%    sas_ddr(4,good2), sas_ddr(4,good2)./mfr.vdata.direct_diffuse_ratio_filter2(good2),'.',...
%    sas_ddr(2,good1), sas_ddr(2,good1)./mfr.vdata.direct_diffuse_ratio_filter1(good1),'.');
% legend('filter 5','filter 4','filter 3','filter 2','filter 1');
% xlabel('SASHe DDR');
% logy
% title('PVC MFRSR and SASHE DDR Analysis');


figure; plot(...
   sas_ddr(6,good7), mfr.vdata.direct_diffuse_ratio_filter7(good7)./sas_ddr(6,good7),'.');
legend('filter 7');
ylabel('MFRSR/SASHe DDR corr factor');
xlabel('Raw SASHe DDR')
title({[upper(tla),' MFRSR and SASHE DDR Correction Factor'];'Multiply SASHe DDR by correction factor'});
logy
liny
v = axis;

X = [sas_ddr(6,good7)];
Y = [mfr.vdata.direct_diffuse_ratio_filter7(good7)./sas_ddr(6,good7)];
figure; plot(X,Y,'.');
ylabel('MFRSR/SASHe DDR corr factor');
xlabel('Raw SASHe DDR')
title({[upper(tla),' MFRSR and SASHE DDR Correction Factor'];'Multiply SASHe DDR by correction factor'});
axis(v)

D_XY = ptdens(X,Y, 32./sqrt(length(X)));
figure; scatter(X,Y,6,log10(D_XY));
ylabel('MFRSR/SASHe DDR corr factor');
xlabel('Raw SASHe DDR')
title({[upper(tla),' MFRSR and SASHE DDR Correction Factor'];'Multiply SASHe DDR by correction factor'});
axis(v); 
colormap(comp_map_w_jet);
maxes = max(xlim); maxes = ceil(maxes .* .7);
for UB = 1:maxes
   LB = UB - 1;
   BB = X>=LB & X<UB+1;
   X_(UB) = (LB + UB)./2;
   Y_(UB) = mean(Y(BB));
end
nil = X_==0 | Y_==0 | isnan(X_)|isnan(Y_); 
X_(nil) = []; Y_(nil)=[];
[gd,P_] = rpoly_mad(X_(2:end), Y_(2:end), 2,6);
figure; plot(X_, Y_, 'ro',X_, polyval(P_, X_), 'k--','LineWidth',3)

% ddr_corr = [X_, polyval(P_, X_)];

ddr_corr.tla_ver = [tla,' ' ver];
ddr_corr.ddr = X_; ddr_corr.fac = polyval(P_, X_); 
ddr_corr.note = 'Multiply raw ddr by fac, or divide diffuse_hemisp by fac';
save([outpath, tla, 'nir_ddrcorr_',ver,'.mat'],'-struct','ddr_corr')


end
% function plot_ddr(X,Y,x_str, y_str, site_str, nm_str, pname);
% t_str = ['Direct Normal to Diffuse Ratio ',nm_str];
% % Evaluate from here...
% if size(X,1)==size(Y,2); Y = Y'; end
% bad = X<=0 | Y<=0; X(bad) =[]; Y(bad) = [];
% D = den2plot(X,Y);
% figure; scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
% xlabel(x_str); ylabel(y_str); title({site_str; t_str})
% xl = xlim; yl = ylim; xlim([floor(min([xl, yl])),round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
% hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
% [good, P_bar] = rbifit(X,Y,3,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off')
% [gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
% gt.Units = 'Normalized'; gt.Position = round(gt.Position.*10)./10;
% zoom('on');
% menu('Zoom as desired then click OK','OK')
% xl = xlim; yl = ylim; xlim([min([xl, yl]),round(50.*min([xl(2),yl(2)]))./50]);ylim(xlim); axis('square');
% 
% if isavar('pname')&&isadir(pname)
%    tla = [strtok(site_str), ' ']; xtok = [strtok(x_str), ' ']; ytok = [strtok(y_str), ' ']; nm = strrep(nm_str,' ','');
%    saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_DDR.png'],' ','_'));
%    saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_DDR.fig'],' ','_'));
% end
% return