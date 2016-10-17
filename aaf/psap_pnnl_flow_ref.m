function [P_flow, flows ] = psap_pnnl_flow_ref;
% This function encapsulates measurements of the PSAP AAF front-panel flow and a TSI 4100 connected in series.
% We'll reference the flows reported by AAF PSAP, PNNL PSAP, and AAF TAP to
% this single flow meter.  While not absolutely calibrated it should remove
% relative calibration differences, especially since they were all operated
% at the same fixed nominal flow rate of 1 LPM.  
% This validity of this approach depends on whether the PSAP front panel
% values are equivalent to what is reported in the PSAP serial datastream.
% I have visually verified that this is indeed the case.

flows = [...
1.035 1.06
0.803 0.807
0.681 0.669
0.51 0.48
0.572 0.542
0.670 0.655
0.829 0.827
0.971 0.972
1.079 1.09
1.156 1.117
1.272 1.301
1.158 1.172
1.262 1.288
1.45 1.482
1.54 1.58
1.473 1.506
1.402 1.437
1.33 1.36
1.251 1.278
1.205 1.224
1.144 1.162
0.956 0.96
0.862 0.86
0.787 0.779
0.728 0.715
0.503 0.467
0.623 0.598
0.733 0.715
0.956 0.952
1.016 1.017
];

P_flow_lin = polyfit(flows(:,1), flows(:,2), 1);
% P_flow_quad = polyfit(flows(:,1), flows(:,2), 3);
lims = [0.5, 2];
figure; plot(flows(:,1), flows(:,2), 'o', lims, polyval(P_flow_lin,lims), 'k-');  
P_flow = P_flow_lin; 
end

