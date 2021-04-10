function [Bab, Tr_ss, dV_ss, dL_ss] = smooth_Tr_i_Bab(time, sample_flow, Tr,ss, spot_area)
% [Bab, Tr_ss, sample_flow, dV_ss, dL_ss] = smooth_Tr_i_Bab(time, flow, Tr,ss, spot_area);
% Apply smoothing filter of width "ss" to flow and filter transmittance
% Requires time [days], sample_flow [lpm], Tr [unitless filter transmittance]
% smoothing window ss [seconds] and spot_area [mm^2] are optional

% optional "spot_area" is in units of mm^2, def 17,81

if ~exist('spot_area','var')||isempty(spot_area)
   spot_area = 17.81;
end
dt = ss./(24*60*60);
% The following logic is intended to determine the interval between packets
% Older PSAP had 4 second interval between hex packets.  New PSAP is 1 s
dtime = diff(time).*24.*60.*60; dtime = dtime(dtime>.5); dtime = round(min(dtime));
ss = max([1,round(ss./dtime)]);
% sample_flow = sliding_polyfit(time, flow, dt);
% Tr_ss = sliding_polyfit(time,Tr,dt);
non = NaN(size(Tr));Tr_ss = non;dTr = non;
non = isnan(Tr); 
Tr_ss(~non) = smooth(Tr(~non),ss); 
Tr_ss(non) = interp1(time(~non),Tr_ss(~non),time(non),'linear');
non = isnan(Tr_ss); 
Tr_ss(non) = interp1(time(~non),Tr_ss(~non),time(non),'nearest','extrap');
dV_ss = zeros(size(sample_flow));
% abs_ss = zeros(size(sample_flow));
for tt = (ss):length(sample_flow)-1
   % Compute volume of air drawn through filter over each window
   dV_ss(tt) = trapz(time(tt-ss+1:tt+1)*24*60, sample_flow(tt-ss+1:tt+1))';
   % Compute absorbance as difference in log of smoothed transmittances
   % Same as log of ratio of smoothed transmittances
   dTr(tt) = Tr_ss(tt-ss+1)./Tr_ss(tt+1); %This a differential, smoothed transmitance   
end
abs_ss = log(dTr);
% Shift x-axis to account for width of smoothing window
%    s1 = dt./2;
dV_ss = interp1(time, dV_ss, time + dt./2, 'linear');
abs_ss = interp1(time, abs_ss, time + dt./2, 'linear');
%Compute "length" of air, that is volume/spot_size_area
% Convert from mm to meters
dL_ss = 1000.*dV_ss./spot_area;
% Compute absorption coefficients, aka absorbance per unit length
% Convert from 1/m to 1/Mm
Bab = 1e6.*abs_ss./dL_ss;

return
