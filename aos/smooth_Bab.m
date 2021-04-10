function [Bab, dV_ss, dL_ss] = smooth_Bab(time, sample_flow, Tr,ss, spot_area);
% [Bab, sample_flow, dV_ss, dL_ss] = smooth_Bab(time, flow, ss, spot_area);
% Apply box-car filter with full-width "ss" seconds to flow and filter transmittance
% Requires time [days], sample_flow [lpm], Tr [unitless filter transmittance]
% smoothing window ss [seconds] and spot_area [mm^2] are optional

% optional "spot_area" is in units of mm^2, def 17,81

if ~exist('spot_area','var')||isempty(spot_area)
   spot_area = 17.81;
end
dt = ss./(24*60*60); % factor of 2 to go from half-width to full-width
dV_ss = zeros(size(sample_flow));
abs_ss = zeros(size(sample_flow));
for tt = (ss):length(sample_flow)-1
   dt_ = time> time(tt)-dt & time <= time(tt);
   st = sum(dt_);
   % Compute volume of air drawn through filter over each window   
   dV_ss(tt) = trapz(time(dt_)*24*60, sample_flow(dt_))';
   % Compute absorbance as log of ratio of transmittances   
   abs_ss(tt) = log(Tr(tt-st+1)./Tr(tt));
end
%Compute "length" of air, that is volume/spot_size_area
% Convert from mm to meters
dL_ss = 1000.*dV_ss./spot_area;
% Compute absorption coefficients, aka absorbance per unit length
% Convert from 1/m to 1/Mm
Bab = 1e6.*abs_ss./dL_ss;
Bab = interp1(time, Bab, time +(ss/2)./(24*60*60), 'nearest','extrap');
% Shift x-axis to account for width of smoothing window
%    s1 = -0.5./(24*60*60);
return
