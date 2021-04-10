function [P_flow, flows ] = tap_aaf_flow_ref;
% This function encapsulates measurements of the TAP AAF serial displayed flow and a TSI 4100 connected in series.
% We'll reference the flows reported by AAF PSAP, PNNL PSAP, and AAF TAP to
% this single flow meter.  While not absolutely calibrated it should remove
% relative calibration differences, especially since they were all operated
% at the same fixed nominal flow rate of 1 LPM.  

% I also recorded front panel values but these do not appear to correspond
% to the values reported in the serial stream and are to fewer digits of
% decimal precision
%[ front panel, serial packet, TSI 4100]
flows = [...
0.99 1.023 1.01
0.7 0.726 0.725
0.76 0.777 0.774
0.8 0.817 0.808
0.85 0.871 0.862
0.9 0.912 0.895
0.95 0.977 0.957
1.0 1.018 0.999
1.05 1.073 1.05
1.1 1.13 1.105
1.15 1.176 1.153
1.2 1.225 1.202
1.2 1.225 1.202
1.25 1.277 1.255
1.3 1.33 1.310
1.2 1.238 1.213
1.1 1.135 1.109
0.99 1.023 0.998
0.9 0.934 0.913
0.8 0.829 0.816
0.7 0.714 0.708
1.25 1.290 1.262
1.2 1.240 1.216
1.15 1.177 1.152
1.11 1.143 1.116
1.05 1.081 1.053
1.00 1.037 1.01
0.95 0.981 0.957
0.84 0.864 0.849
];

P_flow_lin = polyfit(flows(:,1), flows(:,2), 1);
% P_flow_quad = polyfit(flows(:,1), flows(:,2), 3);
lims = [0.6, 1.5];
figure; plot(flows(:,1), flows(:,2), 'o', lims, polyval(P_flow_lin,lims), 'k-');  
P_flow = P_flow_lin; 
end

