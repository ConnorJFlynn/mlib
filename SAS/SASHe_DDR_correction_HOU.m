% DDR linearity for Feb 2022 at HOU

mfr = load(['D:\aodfit_be\hou\houmfrsr7nchM1.b1.ddr_filt.20220201_0228.mat']);
sas = load(['D:\aodfit_be\hou\housashevisaodM1.c1.ddr_filt.20220201_0228.mat']);

[mins, sinm] = nearest(mfr.time, sas.time); 
mfr = anc_sift(mfr, mins); sas = anc_sift(sas, sinm);

sas_ddr = sas.vdata.direct_normal_transmittance./sas.vdata.diffuse_transmittance;

figure; plot(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),'.'); legend('filter 1')
good = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),2,6); sum(good)

[P] = polyfit(mfr.vdata.direct_diffuse_ratio_filter1(good), sas_ddr(2,good),2);
[P_] = polyfit(sas_ddr(2,good),mfr.vdata.direct_diffuse_ratio_filter1(good),2);

figure; plot(mfr.vdata.direct_diffuse_ratio_filter1(good), sas_ddr(2,good), '.',...
   mfr.vdata.direct_diffuse_ratio_filter1(good), polyval(P,mfr.vdata.direct_diffuse_ratio_filter1(good)),'c-',...
   polyval(P_,sas_ddr(2,good)), sas_ddr(2,good),'r-')

D = den2plot(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:));
figure; scatter(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),6,log10(D)); colormap(comp_map_w_jet);

figure; plot(mfr.vdata.direct_diffuse_ratio_filter2, sas_ddr(4,:),'.'); legend('filter 2')

good1 = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter1, sas_ddr(2,:),2,6);
good2 = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter2, sas_ddr(4,:),2,6);
good3 = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter3, sas_ddr(5,:),2,6);
good4 = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter4, sas_ddr(6,:),2,6);
good5 = rpoly_bisect_mad(mfr.vdata.direct_diffuse_ratio_filter5, sas_ddr(7,:),2,4.5);

figure; plot(...
   mfr.vdata.direct_diffuse_ratio_filter5(good5), sas_ddr(7,good5),'.',...
   mfr.vdata.direct_diffuse_ratio_filter4(good4), sas_ddr(6,good4),'.',...
   mfr.vdata.direct_diffuse_ratio_filter3(good3), sas_ddr(5,good3),'.',...
   mfr.vdata.direct_diffuse_ratio_filter2(good2), sas_ddr(4,good2),'.',...
      mfr.vdata.direct_diffuse_ratio_filter1(good1), sas_ddr(2,good1),'.'); 
legend('filter 5','filter 4','filter 3','filter 2','filter 1')
xlabel('MFRSR DDR'); ylabel('SASHe DDR');
title('HOU MFRSR and SASHE DDR Analysis');
figure; plot(...
   mfr.vdata.direct_diffuse_ratio_filter5(good5), sas_ddr(7,good5)./mfr.vdata.direct_diffuse_ratio_filter5(good5),'.',...
   mfr.vdata.direct_diffuse_ratio_filter4(good4), sas_ddr(6,good4)./mfr.vdata.direct_diffuse_ratio_filter4(good4),'.',...
   mfr.vdata.direct_diffuse_ratio_filter3(good3), sas_ddr(5,good3)./mfr.vdata.direct_diffuse_ratio_filter3(good3),'.',...
   mfr.vdata.direct_diffuse_ratio_filter2(good2), sas_ddr(4,good2)./mfr.vdata.direct_diffuse_ratio_filter2(good2),'.',...
      mfr.vdata.direct_diffuse_ratio_filter1(good1), sas_ddr(2,good1)./mfr.vdata.direct_diffuse_ratio_filter1(good1),'.'); 
legend('filter 5','filter 4','filter 3','filter 2','filter 1');
logy

figure; plot(...
   mfr.vdata.direct_diffuse_ratio_filter5(good5), mfr.vdata.direct_diffuse_ratio_filter5(good5)./sas_ddr(7,good5),'.',...
   mfr.vdata.direct_diffuse_ratio_filter4(good4), mfr.vdata.direct_diffuse_ratio_filter4(good4)./sas_ddr(6,good4),'.',...
   mfr.vdata.direct_diffuse_ratio_filter3(good3), mfr.vdata.direct_diffuse_ratio_filter3(good3)./sas_ddr(5,good3),'.',...
   mfr.vdata.direct_diffuse_ratio_filter2(good2), mfr.vdata.direct_diffuse_ratio_filter2(good2)./sas_ddr(4,good2),'.',...
      mfr.vdata.direct_diffuse_ratio_filter1(good1), mfr.vdata.direct_diffuse_ratio_filter1(good1)./sas_ddr(2,good1),'.'); 
legend('filter 5','filter 4','filter 3','filter 2','filter 1');
ylabel('DDR corr factor');
xlabel('Raw DDR')
title({'HOU MFRSR and SASHE DDR Correction Factor';'Multiply SASHe DDR by correction factor'});
logy
liny

X = [mfr.vdata.direct_diffuse_ratio_filter5(good5),mfr.vdata.direct_diffuse_ratio_filter4(good4),...
   mfr.vdata.direct_diffuse_ratio_filter3(good3),mfr.vdata.direct_diffuse_ratio_filter2(good2),...
   mfr.vdata.direct_diffuse_ratio_filter1(good1)];
Y = [mfr.vdata.direct_diffuse_ratio_filter5(good5)./sas_ddr(7,good5), ...
   mfr.vdata.direct_diffuse_ratio_filter4(good4)./sas_ddr(6,good4), ...
   mfr.vdata.direct_diffuse_ratio_filter3(good3)./sas_ddr(5,good3), ...
   mfr.vdata.direct_diffuse_ratio_filter2(good2)./sas_ddr(4,good2), ...
   mfr.vdata.direct_diffuse_ratio_filter1(good1)./sas_ddr(2,good1)];
figure; plot(X,Y,'.')

D_XY = den2plot(X,Y);
figure; scatter(X,Y,6,log10(D_XY)); colormap(comp_map_w_jet);

P_XY = polyfit(X,Y,1);
hold('on'); plot([min(X),max(X)], polyval(P_XY,[min(X),max(X)]), 'k--'); 

for UB = 1:30
   LB = UB - 1;
   BB = X>=LB & X<UB+1;
   X_(UB) = (LB + UB)./2;
   Y_(UB) = mean(Y(BB));
end
[gd,P_] = rpoly_mad(X_, Y_, 2,4);
figure; plot(X_, Y_, 'ro',X_, polyval(P_, X_), 'k--')

hou_ddr_corr = [X_', polyval(P_, X_)'];
hou_ddr_corr(1,:) = [0,1];
save('D:\aodfit_be\hou\hou_ddr_corr_fit.mat','hou_ddr_corr')
figure; plot(X_, Y_, 'ro',hou_ddr_corr(:,1),hou_ddr_corr(:,2), 'k--');
function plot_ddr(X,Y,x_str, y_str, site_str, nm_str, pname);
      t_str = ['Direct Normal to Diffuse Ratio ',nm_str];
      % Evaluate from here...
      if size(X,1)==size(Y,2); Y = Y'; end
      bad = X<=0 | Y<=0; X(bad) =[]; Y(bad) = [];
      D = den2plot(X,Y);
      figure; scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
      xlabel(x_str); ylabel(y_str); title({site_str; t_str})
      xl = xlim; yl = ylim; xlim([floor(min([xl, yl])),round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
      hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
      [good, P_bar] = rbifit(X,Y,3,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off')
      [gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
      gt.Units = 'Normalized'; gt.Position = round(gt.Position.*10)./10;
      zoom('on');
      menu('Zoom as desired then click OK','OK')
      xl = xlim; yl = ylim; xlim([min([xl, yl]),round(50.*min([xl(2),yl(2)]))./50]);ylim(xlim); axis('square');
      
      if isavar('pname')&&isadir(pname)
         tla = [strtok(site_str), ' ']; xtok = [strtok(x_str), ' ']; ytok = [strtok(y_str), ' ']; nm = strrep(nm_str,' ','');
         saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_DDR.png'],' ','_'));
         saveas(gcf,strrep([pname, filesep,tla, xtok,ytok,nm,'_DDR.fig'],' ','_'));
      end
return
