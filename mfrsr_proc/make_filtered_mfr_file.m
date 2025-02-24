function mfr = make_filtered_mfr_mat;
mfr_files = getfullname('*mfrsr*aod*.nc');
mfr_ = anc_load(mfr_files{1});
[~, mfr_] = anc_sift(mfr_, mfr_.time<mfr_.time(1));
for m = 2:length(mfr_files)
   mfr = anc_load(mfr_files{m});
   keep = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1, mfr.vatts.qc_aerosol_optical_depth_filter1)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2, mfr.vatts.qc_aerosol_optical_depth_filter2)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3, mfr.vatts.qc_aerosol_optical_depth_filter3)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4, mfr.vatts.qc_aerosol_optical_depth_filter4)==0;
   keep = keep & anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5, mfr.vatts.qc_aerosol_optical_depth_filter5)==0;
   keep = keep & mfr.vdata.aerosol_optical_depth_filter5>0 & mfr.vdata.aerosol_optical_depth_filter1<2;
   keep = keep & mfr.vdata.airmass>=1 & mfr.vdata.airmass<=6;
   if sum(keep)>0
   mfr = anc_sift(mfr, keep);
   mfr_ = anc_cat(mfr_, mfr);
   disp(length(mfr_.time))
   end
   disp(['file: ',num2str(length(mfr_files)-m)])
end

% save(['D:\aodfit_be\hou\houmfrsr7nchaod1michM1.c1.filtered2.mat'],'-struct','mfr_')
end

function blah 
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 500nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
title({title_str_top; title_str_bot});
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
xlabel(x_str); ylabel(y_str);
title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 675 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(5,xiny); Y = mfr.aod(4,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);

title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 870 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(6,xiny); Y = mfr.aod(5,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
outp = ['D:\aodfit_be\hou\'];

title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 870 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(6,xiny); Y = mfr.aod(5,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
title_str_top = 'Aeronet vs ARM MFRSR7nch'; title_str_bot = 'AOD at 1.6 micron'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, mfr.time);
X = anet.aod(8,xiny); Y = mfr.aod(6,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
% adjust zoom if desired
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
sas = dbeams.sashemfr;
% Now try SAS vs Aeronet
title_str_top = 'Aeronet vs ARM SASHe'; title_str_bot = 'AOD at 500 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, sas.time);
X = anet.aod(4,xiny); Y = sas.aod(2,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
title_str_top = 'Aeronet vs ARM SASHe'; title_str_bot = 'AOD at 675 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, sas.time);
X = anet.aod(5,xiny); Y = sas.aod(4,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats

title_str_top = 'Aeronet vs ARM SASHe'; title_str_bot = 'AOD at 675 nm'; 
x_str = 'Aeronet AOD'; y_str = 'MFRSR AOD';
[xiny, yinx] = nearest(anet.time, sas.time);
X = anet.aod(5,xiny); Y = sas.aod(4,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
title_str_top = 'ARM MFR vs ARM SASHe'; title_str_bot = 'AOD at 415 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
[xiny, yinx] = nearest(mfr.time, sas.time);
X = mfr.aod(1,xiny); Y = sas.aod(1,yinx);

D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); 
colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
title_str_top = 'ARM MFR vs ARM SASHe'; title_str_bot = 'AOD at 500 nm'; 
x_str = 'MFRSR AOD'; y_str = 'SASHe AOD';
[xiny, yinx] = nearest(mfr.time, sas.time);
X = mfr.aod(2,xiny); Y = sas.aod(2,yinx);
D = den2plot(X, Y);
[good,P_bar] = rbifit(X, Y,3,0);
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
title({title_str_top; title_str_bot});
xlabel(x_str); ylabel(y_str);
figure; scatter(X, Y,4,floor(mfr.time(xiny)),'filled');
figure; scatter(X, Y,4,log10(D),'filled'); colormap(comp_map_w_jet);
cv = caxis; caxis([0.31,cv(2)]);
xl = xlim; yl = ylim; xlim([0,floor(10.*min([xl(2),yl(2)]))./10]);ylim(xlim); axis('square')
hold('on'); plot(ylim, ylim, 'k--',ylim, polyval(P_bar,ylim),'b-'); hold('off')
[gt,txt, stats] = txt_stat(X(good), Y(good),P_bar); set(gt,'color','b');
Select figure to add stats
end