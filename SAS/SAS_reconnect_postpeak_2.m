function ava = SAS_reconnect_postpeak_2(ins)
% This for data collected March 26 2010
%%


ins = SAS_read_Albert_csv;
%%
figure; plot([1:220],ins.Sum,'o')
title('Variability on connect/reconnect after peaking collimator throughput')
xlabel('record number')
ylabel('sum of spectra (no dark subtraction)')

% The file in folder 20100326postPeakedCollInFreezerStablized_FCDisconnect
% is data with the FC connector disconnected.

% The file in folder 20100326postPeakedCollInFreezerStablized is data with
% the collimator disconnected.

% We see interesting and unexpected drift in the FC disconnect, apparently
% physical relaxation effects.
%
% Nonetheless, we see group-to-group variability on the order of 0.2%
% That is an acceptable level of repeatability.

