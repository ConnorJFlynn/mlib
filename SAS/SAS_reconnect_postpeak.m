function ava = SAS_reconnect_postpeak(ins)


ins = SAS_read_ava;
figure; plot([1:230],ins.Sum,'o')
title('Variability on connect/reconnect after peaking collimator throughput')
xlabel('record number')
ylabel('sum of spectra (no dark subtraction)')

% We see a disturbing/unexplained discontinuous trend in the magnitude of
% the sum.  Not sure if this is due to spectrometer, integration sphere, or
% fiber position.  But if this trend is removed from data we see detectable
% groups with variation between groups on the order of 0.1%