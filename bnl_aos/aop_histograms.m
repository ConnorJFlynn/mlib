function aop_histograms
epc = anc_bundle_files;
figure; plot(epc.time, [epc.vdata.Ba_B_combined_10um;epc.vdata.Ba_B_combined_1um],'b.',...
   epc.time, [epc.vdata.Ba_R_combined_10um;epc.vdata.Ba_R_combined_1um],'r.'); dynamicDateTicks; logy;
yl = ylim;
liny; ylim([0,40]);
title(['EPC']);
X = [epc.vdata.Ba_B_combined_10um;epc.vdata.Ba_B_combined_1um];
figure; histogram(X(X>0),'normalization','pdf')
title('EPC')


hou = anc_bundle_files;
figure; plot(hou.time, [hou.vdata.Ba_B_combined_10um;hou.vdata.Ba_B_combined_1um],'b.',...
   hou.time, [hou.vdata.Ba_R_combined_10um;hou.vdata.Ba_R_combined_1um],'r.'); dynamicDateTicks; logy;
yl = ylim;
liny; ylim([0,40]);
title(['HOU']);
X = [hou.vdata.Ba_B_combined_10um;hou.vdata.Ba_B_combined_1um];
figure; histogram(X(X>0),'normalization','pdf')
title('HOU')



asi = anc_bundle_files;
figure; plot(asi.time, [asi.vdata.Ba_B_combined_10um;asi.vdata.Ba_B_combined_1um],'b.',...
   asi.time, [asi.vdata.Ba_R_combined_10um;asi.vdata.Ba_R_combined_1um],'r.'); dynamicDateTicks; logy;
yl = ylim;
liny; ylim([0,40]);
title(['ASI']);
X = [asi.vdata.Ba_B_combined_10um;asi.vdata.Ba_B_combined_1um];
figure; histogram(X(X>0),'normalization','pdf')
title('ASI')

ena = anc_bundle_files;
figure; plot(ena.time, [ena.vdata.Ba_B_combined_10um;ena.vdata.Ba_B_combined_1um],'b.',...
   ena.time, [ena.vdata.Ba_R_combined_10um;ena.vdata.Ba_R_combined_1um],'r.'); dynamicDateTicks; logy;
yl = ylim;
liny; ylim([0,40]);
title(['ENA']);
X = [ena.vdata.Ba_B_combined_10um;ena.vdata.Ba_B_combined_1um];
figure; histogram(X(X>0),'normalization','pdf')
title('ENA')


sgp = anc_bundle_files;
figure; plot(sgp.time, [sgp.vdata.Ba_B_combined_10um;sgp.vdata.Ba_B_combined_1um],'b.',...
   sgp.time, [sgp.vdata.Ba_R_combined_10um;sgp.vdata.Ba_R_combined_1um],'r.'); dynamicDateTicks; logy;
yl = ylim;
liny; ylim([0,40]);
title(['SGP']);
X = [sgp.vdata.Ba_B_combined_10um;sgp.vdata.Ba_B_combined_1um];
figure; 
histogram(X(X>0),'normalization','pdf')
title('SGP')

return