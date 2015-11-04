
% test PSAP raw signals and transmittances
maopsapr = anc_bundle_subsample;
figure; 
ax(1) = subplot(3,1,1); 
plot(maopsapr.time, maopsapr.vdata.blue_reference_sum,'.');dynamicDateTicks; legend('ref')
title('mao psapr')
ax(2) = subplot(3,1,2);  
plot(maopsapr.time, maopsapr.vdata.blue_signal_sum,'k.');dynamicDateTicks; legend('sig')
ax(3) = subplot(3,1,3);  
plot(maopsapr.time, maopsapr.vdata.blue_signal_sum./maopsapr.vdata.blue_reference_sum,'r.');dynamicDateTicks; legend('sig/ref')
linkaxes(ax,'x');


tmppsapr = anc_bundle_subsample;
figure; 
ax(1) = subplot(3,1,1); 
plot(tmppsapr.time, tmppsapr.vdata.blue_reference_sum,'.');dynamicDateTicks; legend('ref')
title('tmp psapr')
ax(2) = subplot(3,1,2);  
plot(tmppsapr.time, tmppsapr.vdata.blue_signal_sum,'k.');dynamicDateTicks; legend('sig')
ax(3) = subplot(3,1,3);  
plot(tmppsapr.time, tmppsapr.vdata.blue_signal_sum./tmppsapr.vdata.blue_reference_sum,'r.');dynamicDateTicks; legend('sig/ref')
linkaxes(ax,'x');

enapsapr = anc_bundle_subsample;
figure; 
ax(1) = subplot(3,1,1); 
plot(enapsapr.time, enapsapr.vdata.blue_reference_sum,'.');dynamicDateTicks; legend('ref')
title('ena psapr')
ax(2) = subplot(3,1,2);  
plot(enapsapr.time, enapsapr.vdata.blue_signal_sum,'k.');dynamicDateTicks; legend('sig')
ax(3) = subplot(3,1,3);  
plot(enapsapr.time, enapsapr.vdata.blue_signal_sum./enapsapr.vdata.blue_reference_sum,'r.');dynamicDateTicks; legend('sig/ref')
linkaxes(ax,'x');


acxpsapr = anc_bundle_subsample;
figure; 
ax(1) = subplot(3,1,1); 
plot(acxpsapr.time, acxpsapr.vdata.blue_reference_sum,'.');dynamicDateTicks; legend('ref')
title('axc psapr')
ax(2) = subplot(3,1,2);  
plot(acxpsapr.time, acxpsapr.vdata.blue_signal_sum,'k.');dynamicDateTicks; legend('sig')
ax(3) = subplot(3,1,3);  
plot(acxpsapr.time, acxpsapr.vdata.blue_signal_sum./acxpsapr.vdata.blue_reference_sum,'r.');dynamicDateTicks; legend('sig/ref')
linkaxes(ax,'x');

magpsapr = anc_bundle_subsample;
figure; 
ax(1) = subplot(3,1,1); 
plot(magpsapr.time, magpsapr.vdata.blue_reference_sum,'.');dynamicDateTicks; legend('ref')
title('mag psapr')
ax(2) = subplot(3,1,2);  
plot(magpsapr.time, magpsapr.vdata.blue_signal_sum,'k.');dynamicDateTicks; legend('sig')
ax(3) = subplot(3,1,3);  
plot(magpsapr.time, magpsapr.vdata.blue_signal_sum./magpsapr.vdata.blue_reference_sum,'r.');dynamicDateTicks; legend('sig/ref')
linkaxes(ax,'x');