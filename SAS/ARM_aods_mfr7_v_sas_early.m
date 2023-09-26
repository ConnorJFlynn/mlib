% Current situation with HOU comparisons:
% There seemed to be a notable difference in AOD agrreement between 
% MFR and SAS about some date.  
% ARM-processed sas aod look _decent_ AFTER doys(500) (whenever that is)
% Was this an accident to call it "early"?  Did I accidentally select LATE?
% Regardless, there is a distinct difference between the two periods.
% This may be related to banding issues that could be improved using the MFR 
% direct/diffuse approach.  
% What I'll attempt to do today is apply fix_sas_ddr to the ARM processed AOD files
% To do so, I'll read in the sas_filtered mat file and a corresponding data set for
% MFR and run fix_sas_ddr.  Then what?

cim = rd_anetaod_v3;
mfr = load('D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.filtered.mat');
sas = load('D:\aodfit_be\hou\housasvisaodfilt.mat');

mfr = load('D:\aodfit_be\pvc\pvcmfrsraodM1.c1.filt.mat');
sas = load('D:\aodfit_be\pvc\pvcsashevisaodM1.c1.filt.mat');

sas = anc_sift(sas, ~any(sas.vdata.aerosol_optical_depth<=0));

[cinm, minc] = nearest(cim.time, mfr.time);
[cins, sinc] = nearest(cim.time, sas.time);
[mins, sinm] = nearest(mfr.time, sas.time);
% Plot sas vs cim and mfrsr to see if there are periods we should exclude as below
figure; scatter(sas.vdata.aerosol_optical_depth(4,sinc), cim.AOD_500nm_AOD(cins),6,serial2doys(sas.time(sinc)));



ij = find(serial2doys(sas.time(sinc))>300 & serial2doys(sas.time(sinc))<600);
cins = cins(ij); sinc = sinc(ij);
[mins, sinm] = nearest(mfr.time, sas.time);
ij = find(serial2doys(sas.time(sinm))>300 & serial2doys(sas.time(sinm))<600);
mins = mins(ij); sinm = sinm(ij);



X = cim.AOD_500nm_AOD(cinm);
Y = mfr.vdata.aerosol_optical_depth_filter2(minc);
x_str = 'Cimel AOD'; y_str = 'MFRSR AOD'; t_str = 'Aerosol Optical Depth 500 nm';

X = cim.AOD_500nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(4,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 500 nm';

X = mfr.vdata.aerosol_optical_depth_filter2(mins);
Y = sas.vdata.aerosol_optical_depth(4,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 500 nm';

X = cim.AOD_675nm_AOD(cinm);
Y = mfr.vdata.aerosol_optical_depth_filter4(minc);
x_str = 'Cimel AOD'; y_str = 'MFRSR AOD'; t_str = 'Aerosol Optical Depth 675 nm';

X = cim.AOD_675nm_AOD(cins);
Y = sas.vdata.aerosol_optical_depth(6,sinc);
x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 675 nm';

X = mfr.vdata.aerosol_optical_depth_filter4(mins);
Y = sas.vdata.aerosol_optical_depth(6,sinm);
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 673 nm';

X = cim.AOD_870nm_AOD(cinm);
Y = mfr.vdata.aerosol_optical_depth_filter5(minc);
x_str = 'Cimel AOD'; y_str = 'MFRSR AOD'; t_str = 'Aerosol Optical Depth 870 nm';

% X = cim.AOD_870nm_AOD(cins);
% Y = sas.vdata.aerosol_optical_depth(7,sinc);
% x_str = 'Cimel AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 870 nm';

% X = mfr.vdata.aerosol_optical_depth_filter5(mins);
% Y = sas.vdata.aerosol_optical_depth(7,sinm);
% x_str = 'MFRSR AOD'; y_str = 'SASHe AOD'; t_str = 'Aerosol Optical Depth 870 nm';


% Evaluate from here...
if size(X,1)==size(Y,2); Y = Y'; end
bad = X<=0 | Y<=0; X(bad) =[]; Y(bad) = [];
D = den2plot(X,Y);
figure; scatter(X, Y,6,log10(D)); colormap(comp_map_w_jet);
xlabel(x_str); ylabel(y_str); title(t_str)
 xl = xlim; yl = ylim; xlim([0,round(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')

[good, P_bar] = rbifit(X,Y,3,0); hold('on');  plot(xl,polyval(P_bar,xl),'b-', 'linewidth',3); hold('off')

[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
gt.Units = 'Normalized'; gt.Position = round(gt.Position.*10)./10;

% ... to here

sas = load(['D:\aodfit_be\pvc\pvcsashevisaodM1.c1.filt.mat']);


early_M = find(serial2doys(mfr.time)<500); early_S = find(serial2doys(sas.time)<500);
[mins, sinm] = nearest(mfr.time(early_M), sas.time(early_S));
early_M = early_M(mins), early_S = early_S(sinm);


% 500 nm
figure; scatter(cim.AOD_500nm_AOD(cinm), mfr.vdata.aerosol_optical_depth_filter2(minc),6,serial2doys(cim.time(cinm)));
xlabel('cim'); ylabel('mfr'); title('500 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
figure; scatter(cim.AOD_500nm_AOD(cins), sas.vdata.aerosol_optical_depth(4,sinc),6,serial2doys(cim.time(cins)));
xlabel('cim'); ylabel('sas');  title('500 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
figure; scatter(mfr.vdata.aerosol_optical_depth_filter2(mins), sas.vdata.aerosol_optical_depth(4,sinm),6,serial2doys(mfr.time(mins)));
xlabel('mfr'); ylabel('sas');  title('500 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')

% 675 nm
figure; scatter(cim.AOD_675nm_AOD(cinm), mfr.vdata.aerosol_optical_depth_filter4(minc),6,serial2doys(cim.time(cinm)));
xlabel('cim'); ylabel('mfr'); title('675 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
figure; scatter(cim.AOD_675nm_AOD(cins), sas.vdata.aerosol_optical_depth(6,sinc),6,serial2doys(cim.time(cins)));
xlabel('cim'); ylabel('sas');  title('675 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
figure; scatter(mfr.vdata.aerosol_optical_depth_filter4(mins), sas.vdata.aerosol_optical_depth(6,sinm),6,serial2doys(mfr.time(mins)));
xlabel('mfr'); ylabel('sas');  title('675 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')


% 870 nm
figure; scatter(cim.AOD_870nm_AOD(cinm), mfr.vdata.aerosol_optical_depth_filter5(minc),6,serial2doys(cim.time(cinm)));
xlabel('cim'); ylabel('mfr'); title('870 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
figure; scatter(cim.AOD_870nm_AOD(cins), sas.vdata.aerosol_optical_depth(5,sinc),6,serial2doys(cim.time(cins)));
xlabel('cim'); ylabel('sas');  title('870 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')
figure; scatter(mfr.vdata.aerosol_optical_depth_filter4(mins), sas.vdata.aerosol_optical_depth(4,sinm),6,serial2doys(mfr.time(mins)));
xlabel('mfr'); ylabel('sas');  title('870 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')


figure; scatter(mfr.vdata.aerosol_optical_depth_filter2(mins(ij)), sas.vdata.aerosol_optical_depth(4,sinm(ij)),6,serial2doys(mfr.time(mins(ij))));
xlabel('mfr'); ylabel('sas');  title('500 nm')
 xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')

early_M = find(serial2doys(mfr.time)<500); early_S = find(serial2doys(sas.time)<500);
[mins, sinm] = nearest(mfr.time(early_M), sas.time(early_S));
early_M = early_M(mins), early_S = early_S(sinm);
 




sas.vdata.wavelength
D_415 = den2plot(mfr.vdata.aerosol_optical_depth_filter1(early_M), sas.vdata.aerosol_optical_depth(2,early_S));
figure; scatter(mfr.vdata.aerosol_optical_depth_filter1(early_M), sas.vdata.aerosol_optical_depth(2,early_S),4,log10(D_415)); colormap(comp_map_w_jet);
[good_415,P_415] = rbifit(mfr.vdata.aerosol_optical_depth_filter1(early_M), sas.vdata.aerosol_optical_depth(2,early_S),3);
[gt,txt, stats] = txt_stat(mfr.vdata.aerosol_optical_depth_filter1(early_M(good_415)), sas.vdata.aerosol_optical_depth(2,early_S(good_415)),P_415); 
set(gt,'color','b');
hold('on'); 
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square');
hold('on'); xl = xlim; li = plot(xl, xl, 'k:','linewidth',4); hold('off')

% Now try SAS vs MFRSR
xiny = early_M; yinx = early_S;
title_str_top = 'HOU M1 MFRSR7nch vs SASHe'; title_str_bot = 'AOD at 500 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
X = mfr.vdata.aerosol_optical_depth_filter2(xiny); 
Y = sas.vdata.aerosol_optical_depth(4,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
% figure; scatter(X, Y,4,floor(mfr.time(xiny)),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

xiny = early_M; yinx = early_S;
title_str_top = 'HOU M1 MFRSR7nch vs SASHe'; title_str_bot = 'AOD at 615 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
X = mfr.vdata.aerosol_optical_depth_filter3(xiny); 
Y = sas.vdata.aerosol_optical_depth(5,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
% figure; scatter(X, Y,4,floor(mfr.time(xiny)),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

xiny = early_M; yinx = early_S;
title_str_top = 'HOU M1 MFRSR7nch vs SASHe'; title_str_bot = 'AOD at 675 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
X = mfr.vdata.aerosol_optical_depth_filter4(xiny); 
Y = sas.vdata.aerosol_optical_depth(6,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
% figure; scatter(X, Y,4,floor(mfr.time(xiny)),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')

xiny = early_M; yinx = early_S;
title_str_top = 'HOU M1 MFRSR7nch vs SASHe'; title_str_bot = 'AOD at 870 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
X = mfr.vdata.aerosol_optical_depth_filter5(xiny); 
Y = sas.vdata.aerosol_optical_depth(7,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
% figure; scatter(X, Y,4,floor(mfr.time(xiny)),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')


