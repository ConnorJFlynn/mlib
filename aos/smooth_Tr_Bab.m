function [Bab, Tr_ss] = smooth_Tr_Bab(time, flow, Tr,ss);
% [Bab, Tr_s] = smooth_Tr_Bab(time, flow, Tr,ss);
% Apply box-car filter of width "ss" to flow and filter transmittance
   sample_flow = smooth(flow,ss);
   Tr_ss = smooth(Tr,ss);
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
   dL_ss = 1000.*dV_ss./17.5;
   % Compute absorption coefficients, aka absorbance per length
   % Convert from 1/m to 1/Mm
   Bab = 1e6.*abs_ss./dL_ss;  
   s1 = -0.5./(24*60*60);
   
Bab = interp1(time+s1.*ss, Bab,time, 'nearest')'; 
Tr_ss = interp1(time+s1.*ss, Tr_ss,time, 'nearest')'; 

% s1 = -0.5./(24*60*60);
% Bab_5s_ = interp1((psapr_00.time+s1.*5), Bab_5s,psapr_00.time, 'pchip'); 
% Bab_10s_ = interp1((psapr_00.time+s1.*10), Bab_10s,psapr_00.time,'pchip');
% Bab_15s_ = interp1((psapr_00.time+s1.*15), Bab_15s,psapr_00.time,'pchip');
% Bab_30s_ = interp1((psapr_00.time+s1.*30), Bab_30s,psapr_00.time,'pchip');
% Bab_45s_ = interp1((psapr_00.time+s1.*45), Bab_45s,psapr_00.time,'pchip');
% Bab_60s_ = interp1((psapr_00.time+s1.*60), Bab_60s,psapr_00.time,'pchip');

return
