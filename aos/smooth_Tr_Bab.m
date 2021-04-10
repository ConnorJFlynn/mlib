function [Bab, Tr_ss, dV_ss, dL_ss] = smooth_Tr_Bab(time, sample_flow, Tr,ss, spot_area);
% [Bab, Tr_ss, sample_flow, dV_ss, dL_ss] = smooth_Tr_Bab(time, flow, Tr,ss, spot_area);
% Apply smoothing filter of half-width "ss" to flow and filter transmittance
% Requires time [days], sample_flow [lpm], Tr [unitless filter transmittance]
% smoothing window ss [seconds] and spot_area [mm^2] are optional

% optional "spot_area" is in units of mm^2, def 17,81

if ~exist('spot_area','var')||isempty(spot_area)
   spot_area = 17.81;
end

% dt = 4.*ss./(24*60*60); % Not sure why I had a factor of 4 in here.  Probably because original PSAP records are mod4
dt = 2.*ss./(24*60*60); % factor of two to go from half-width to full-width
% sample_flow = sliding_polyfit(time, flow, dt);   
Tr_ss = sliding_polyfit(time,Tr,dt);

   dV_ss = zeros(size(sample_flow));
   abs_ss = zeros(size(sample_flow));      
   for tt = (ss):length(sample_flow)-1
      % Compute volume of air drawn through filter over each window
      dV_ss(tt) = trapz(time(tt-ss+1:tt+1)*24*60, sample_flow(tt-ss+1:tt+1))';
      % Compute absorbance as difference in log of smoothed transmittances
      % Same as log of ratio of smoothed transmittances
      abs_ss(tt) = log(Tr_ss(tt-ss+1)./Tr_ss(tt+1));
   end
   %Compute "length" of air, that is volume/spot_size_area 
   % Convert from mm to meters
   dL_ss = 1000.*dV_ss./spot_area;
   % Compute absorption coefficients, aka absorbance per unit length
   % Convert from 1/m to 1/Mm
   Bab = 1e6.*abs_ss./dL_ss;  

   Bab_ = interp1(time, Bab, time +(ss/2)./(24*60*60), 'nearest','extrap');
   % Shift x-axis to account for width of smoothing window
%    s1 = -0.5./(24*60*60);   

return
