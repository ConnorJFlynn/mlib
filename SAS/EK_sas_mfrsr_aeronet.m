function EK_sas_mfrsr_aeronet
% EK = getpath([],'EK_path', 'Set path for Evgueni SAS/MFRSR/Aeronet mat files');
% anet_aod_v2_2 = read_cimel_aod(getfullname('*ARM_Highlands_MA.lev*','anet_aod'));
% save([EK,'anet_aod_v2_2.mat'],'-struct','anet_aod_v2_2')
% anet_aod_v3_1p5 = read_cimel_aod_v3(getfullname('*ARM_Highlands_MA.lev*','anet_aod_v3'));
% save([EK,'anet_aod_v3_1p5.mat'],'-struct','anet_aod_v3_1p5');
% mfr_list  =getfullname('pvc*.*','pvc_mfrsr','Select MFRSR AOD files');
% 
% mfr = anc_load(mfr_list{1});
% QA = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1, mfr.vatts.qc_aerosol_optical_depth_filter1);
% QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2, mfr.vatts.qc_aerosol_optical_depth_filter2));
% QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3, mfr.vatts.qc_aerosol_optical_depth_filter3));
% QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4, mfr.vatts.qc_aerosol_optical_depth_filter4));
% QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5, mfr.vatts.qc_aerosol_optical_depth_filter5));
% 
% mfr_nobad = anc_sift(mfr, QA==0|QA==1);
% mfr_good = anc_sift(mfr, QA==0);
% 
% for m = 2:length(mfr_list)
%     disp(['Loading ',mfr_list{m}]);
%     
%     mfr = anc_load(mfr_list{m});
%     QA = anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter1, mfr.vatts.qc_aerosol_optical_depth_filter1);
%     QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter2, mfr.vatts.qc_aerosol_optical_depth_filter2));
%     QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter3, mfr.vatts.qc_aerosol_optical_depth_filter3));
%     QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter4, mfr.vatts.qc_aerosol_optical_depth_filter4));
%     QA = max(QA, anc_qc_impacts(mfr.vdata.qc_aerosol_optical_depth_filter5, mfr.vatts.qc_aerosol_optical_depth_filter5));
%     
%     mfr_nobad = anc_cat(mfr_nobad, anc_sift(mfr, QA==0|QA==1));
%     mfr_good = anc_cat(mfr_good,anc_sift(mfr, QA==0));
% end
% 
% save([EK,'mfr_nobad.mat'],'-struct','mfr_nobad');
% save([EK,'mfr_good.mat'],'-struct','mfr_good');
% 
% plot(anet_aod_v2_2.time, anet_aod_v2_2.AOT_500,'go', mfr_nobad.time, mfr_nobad.vdata.aerosol_optical_depth_filter2,'k.'); dynamicDateTicks
% 
% 
% sas_list  =getfullname('pvcsashe*.*','pvc_sas','Select SAS AOD files');
% sas = anc_load(sas_list{1});
% wls = sort([380,414,440,500,615,672, 869,1020]);
% wl_ii = interp1(sas.vdata.wavelength, [1:length(sas.vdata.wavelength)],wls,'nearest');
% 
% sas_ = anc_sift(sas, wl_ii, sas.ncdef.dims.wavelength)
% sas_qa = anc_qc_impacts(sas_.vdata.qc_aerosol_optical_depth, sas_.vatts.qc_aerosol_optical_depth);
% sas_qa = max(sas_qa(4:7,:));
% 
% sas_nobad = anc_sift(sas_, sas_qa==0|sas_qa==1);
% sas_good = anc_sift(sas_, sas_qa==0);
% 
% for s = 2:length(sas_list)
%     disp(['Loading ',num2str(length(sas_list)-s), ': ',sas_list{s}]);
%     sas = anc_load(sas_list{s});
%     sas_ = anc_sift(sas, wl_ii, sas.ncdef.dims.wavelength)
%     sas_qa = anc_qc_impacts(sas_.vdata.qc_aerosol_optical_depth, sas_.vatts.qc_aerosol_optical_depth);
%     sas_qa = max(sas_qa(4:7,:));
%     sas_nobad = anc_cat(sas_nobad, anc_sift(sas_, sas_qa==0|sas_qa==1));
%     sas_good = anc_cat(sas_good,anc_sift(sas_, sas_qa==0));
%     
% end
% 
% nneg = ~any(sas_good.vdata.aerosol_optical_depth<=0); 
% sas_good = anc_sift(sas_good,nneg);
% nneg = ~any(sas_nobad.vdata.aerosol_optical_depth<=0); 
% sas_nobad = anc_sift(sas_nobad,nneg);
% save([EK,'sas_nobad.mat'],'-struct','sas_nobad');
% save([EK,'sas_good.mat'],'-struct','sas_good');

EK = getpath([],'EK_path', 'Set path for Evgueni SAS/MFRSR/Aeronet mat files');

sas_good = load([EK,'sas_good.mat']);
sas_nobad = load([EK,'sas_nobad.mat']);
mfr_good = load([EK,'mfr_good.mat']);
mfr_nobad = load([EK,'mfr_nobad.mat']);
anet_aod_v2_2 = load([EK,'anet_aod_v2_2.mat']);


figure; these = plot(sas_good.time, sas_good.vdata.aerosol_optical_depth,'.'); dynamicDateTicks; recolor(these, wls,[400,1000]); title('SASHe AODs')
sas_ax = gca;

figure; those = plot(mfr_nobad.time, [mfr_nobad.vdata.aerosol_optical_depth_filter1;mfr_nobad.vdata.aerosol_optical_depth_filter2;...
 mfr_nobad.vdata.aerosol_optical_depth_filter3 ;mfr_nobad.vdata.aerosol_optical_depth_filter4; ...
 mfr_nobad.vdata.aerosol_optical_depth_filter5],'.'); 
dynamicDateTicks; recolor(those,[414,500,615,673,870],[400,1000]);
mfr_ax = gca;

figure; thats = plot(anet_aod_v2_2.time, [anet_aod_v2_2.AOT_440, anet_aod_v2_2.AOT_500, ...
    anet_aod_v2_2.AOT_675, anet_aod_v2_2.AOT_870, anet_aod_v2_2.AOT_1020 ],'.'); 
dynamicDateTicks; recolor(thats, [440,500,675,870,1020],[400,1000]); title('Aeronet AOD V2, level 2'); 
anet_ax = gca;
linkaxes([sas_ax, mfr_ax, anet_ax], 'xy')

[ainb, bina] = nearest(anet_aod_v2_2.time, sas_nobad.time);
[ainc, cina] = nearest(anet_aod_v2_2.time, sas_good.time);

figure; plot(sas_nobad.time, sas_nobad.vdata.aerosol_optical_depth(4,:), 'go', ...
    anet_aod_v2_2.time, anet_aod_v2_2.AOT_500, 'ko',...
    mfr_nobad.time, mfr_nobad.vdata.aerosol_optical_depth_filter2,'gx')
dynamicDateTicks; xlabel('Date'); ylabel('AOD');
title('Aerosol Optical Depth 500 nm');
legend('SASHe','Aeronet lev 2','MFRSR')


figure; these = plot(sas_good.time(cina), sas_good.vdata.aerosol_optical_depth(:,cina),'x'); dynamicDateTicks; recolor(these, wls,[400,1000]); title('SASHe AODs');
legend(sprintf('%3.0f nm',sas_wls(1)),sprintf('%3.0f nm',sas_wls(2)),sprintf('%3.0f nm',sas_wls(3)),sprintf('%3.0f nm',sas_wls(4)),...
    sprintf('%3.0f nm',sas_wls(5)),sprintf('%3.0f nm',sas_wls(6)),sprintf('%3.0f nm',sas_wls(7)),sprintf('%3.0f nm',sas_wls(8)))
sas_ax2 = gca;

figure; thats = plot(anet_aod_v2_2.time(ainc), [anet_aod_v2_2.AOT_440(ainc), anet_aod_v2_2.AOT_500(ainc), ...
    anet_aod_v2_2.AOT_675(ainc), anet_aod_v2_2.AOT_870(ainc), anet_aod_v2_2.AOT_1020(ainc) ],'.'); 
dynamicDateTicks; recolor(thats, [440,500,675,870,1020],[400,1000]); title('Aeronet AOD V2, level 2'); 
anet_ax2 = gca;
linkaxes([sas_ax2, anet_ax2], 'xy')

% figure; plot(anet_aod_v2_2.time(ainc), anet_aod_v2_2.AOT_500(ainc), 'go', sas_good.time, sas_good.vdata.aerosol_optical_depth(4,:), 'k.');
figure; plot( sas_good.time, sas_good.vdata.aerosol_optical_depth(4,:), 'k.',anet_aod_v2_2.time(ainc), anet_aod_v2_2.AOT_500(ainc), 'go'); dynamicDateTicks;
legend('Aeronet v2 lev2','SASHe (good)');
sas_wls = sas_good.vdata.wavelength;

xl = xlim;
xl_ = anet_aod_v2_2.time(ainc)>=xl(1) & anet_aod_v2_2.time(ainc)<=xl(2);
plots_ppt

% 380 nm
x = anet_aod_v2_2.AOT_380(ainc(xl_)); y = sas_good.vdata.aerosol_optical_depth(1,cina(xl_))';
bias = mean(x-y);
maxd = 1.1.*max(max(x), max(y));
[P,S] = polyfit(x, y,1);
[P_,S_] = polyfit(y, x,1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
statsr = fit_stat(x, y, P_bar,S);
figure; plot(x, y,'o', [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['slope = ',sprintf('%1.4f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['N pts= ', num2str(statsr.N)],...
   };
xlabel('Aeronet AOD'); ylabel('SASHe AOD'); title('AOD 380 nm'); 
gt = gtext(txt); set(gt,'backgroundColor','w');


% 440 nm
x = anet_aod_v2_2.AOT_440(ainc(xl_)); y = sas_good.vdata.aerosol_optical_depth(3,cina(xl_))';
bias = mean(x-y);
maxd = 1.1.*max(max(x), max(y));
[P,S] = polyfit(x, y,1);
[P_,S_] = polyfit(y, x,1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
statsr = fit_stat(x, y, P_bar,S);
figure; plot(x, y,'o', [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['slope = ',sprintf('%1.4f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['N pts= ', num2str(statsr.N)],...
   };
xlabel('Aeronet AOD'); ylabel('SASHe AOD'); title('AOD 440 nm'); 
gt = gtext(txt); set(gt,'backgroundColor','w');


% 500 nm
maxl = max(max(anet_aod_v2_2.AOT_500(ainc(xl_))), max(sas_good.vdata.aerosol_optical_depth(4,cina(xl_))));
x = anet_aod_v2_2.AOT_500(ainc(xl_)); y = sas_good.vdata.aerosol_optical_depth(4,cina(xl_))';
bias = mean(x-y);
maxd = 1.1.*max(max(x), max(y));
[P,S] = polyfit(x, y,1);
[P_,S_] = polyfit(y, x,1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
statsr = fit_stat(x, y, P_bar,S);
figure; plot(x, y,'o', [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['slope = ',sprintf('%1.4f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['N pts= ', num2str(statsr.N)],...
   };
xlabel('Aeronet AOD'); ylabel('SASHe AOD'); title('AOD 500 nm'); 
gt = gtext(txt); set(gt,'backgroundColor','w'); 

% 675 nm
maxl = max(max(anet_aod_v2_2.AOT_675(ainc(xl_))), max(sas_good.vdata.aerosol_optical_depth(6,cina(xl_))));
x = anet_aod_v2_2.AOT_675(ainc(xl_)); y = sas_good.vdata.aerosol_optical_depth(6,cina(xl_))';
bias = mean(x-y);
maxd = 1.1.*max(max(x), max(y));
[P,S] = polyfit(x, y,1);
[P_,S_] = polyfit(y, x,1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
statsr = fit_stat(x, y, P_bar,S);
figure; plot(x, y,'o', [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['slope = ',sprintf('%1.4f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['N pts= ', num2str(statsr.N)],...
   };
xlabel('Aeronet AOD'); ylabel('SASHe AOD'); 
gt = gtext(txt); set(gt,'backgroundColor','w'); 
title('AOD 675 nm'); 

% 870 nm
maxl = max(max(anet_aod_v2_2.AOT_870(ainc(xl_))), max(sas_good.vdata.aerosol_optical_depth(7,cina(xl_))));
x = anet_aod_v2_2.AOT_870(ainc(xl_)); y = sas_good.vdata.aerosol_optical_depth(7,cina(xl_))';
bias = mean(x-y);
maxd = 1.1.*max(max(x), max(y));
[P,S] = polyfit(x, y,1);
[P_,S_] = polyfit(y, x,1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
statsr = fit_stat(x, y, P_bar,S);
figure; plot(x, y,'o', [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['slope = ',sprintf('%1.4f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['N pts= ', num2str(statsr.N)],...
   };
xlabel('Aeronet AOD'); ylabel('SASHe AOD'); 
gt = gtext(txt); set(gt,'backgroundColor','w'); 
title('AOD 870 nm'); 

% 1020 nm
maxl = max(max(anet_aod_v2_2.AOT_1020(ainc(xl_))), max(sas_good.vdata.aerosol_optical_depth(8,cina(xl_))));
x = anet_aod_v2_2.AOT_1020(ainc(xl_)); y = sas_good.vdata.aerosol_optical_depth(8,cina(xl_))';
bias = mean(x-y);
maxd = 1.1.*max(max(x), max(y));
[P,S] = polyfit(x, y,1);
[P_,S_] = polyfit(y, x,1);
P_bar(1) = (P(1) + 1./P_(1))./2;P_bar(2) = (P(2) - P_(2))./2;
statsr = fit_stat(x, y, P_bar,S);
figure; plot(x, y,'o', [0,maxd],[0,maxd],'k--', [0,maxd],polyval(P_bar,[0,maxd]),'r-');axis('square'); axis(1.1*[0,maxd,0,maxd]);
txt = {['slope = ',sprintf('%1.4f',P_bar(1))], ...
    ['bias (y-x) =  ',sprintf('%1.1g',bias)], ...
    ['N pts= ', num2str(statsr.N)],...
   };
xlabel('Aeronet AOD'); ylabel('SASHe AOD'); 
gt = gtext(txt); set(gt,'backgroundColor','w');
title('AOD 1020 nm'); 

return