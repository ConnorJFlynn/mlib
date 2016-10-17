function [P_flow, flows ] = psap_aaf_flow_ref;
% This function encapsulates measurements of the PSAP AAF front-panel flow and a TSI 4100 connected in series.
% We'll reference the flows reported by AAF PSAP, PNNL PSAP, and AAF TAP to
% this single flow meter.  While not absolutely calibrated it should remove
% relative calibration differences, especially since they were all operated
% at the same fixed nominal flow rate of 1 LPM.  
% This validity of this approach depends on whether the PSAP front panel
% values are equivalent to what is reported in the PSAP serial datastream.
% I have visually verified that this is indeed the case.

flows = [...
    1.047 1.3
    .726 0.93
    0.863 1.11
    1.081 1.36
    1.114, 1.4
    1.319 1.62
    1.443, 1.76
    1.505, 1.827
    1.400 1.7
    1.285, 1.58
    1.154 1.44
    1.084 1.36
    0.944, 1.2
    0.836, 1.08
    0.705, 0.90
    0.607, 0.78
    1.026, 1.3 ];

P_flow_lin = polyfit(flows(:,1), flows(:,2), 1);
% P_flow_quad = polyfit(flows(:,1), flows(:,2), 3);
lims = [0.5, 2];
figure; plot(flows(:,1), flows(:,2), 'o', lims, polyval(P_flow_lin,lims), 'k-');  
P_flow = P_flow_lin; 
end

