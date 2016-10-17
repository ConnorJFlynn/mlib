function [Bab, Tr_ss, dV_ss, dL_ss] = smooth_Tr_Bab(time, sample_flow, Tr,ss, spot_area);
% [Bab, Tr_ss, sample_flow, dV_ss, dL_ss] = smooth_Tr_Bab(time, flow, Tr,ss, spot_area);
% Apply box-car filter of width "ss" to flow and filter transmittance
% Expects all fields to be on a regular time grid.
% optional "spot_area" is in units of mm^2, approx 17.5
% Now uses Yohei's boxxfilt which excludes NaNs
if ~exist('spot_area','var')||isempty(spot_area)
   spot_area = 17.81;
end

% [yf, sn] = boxxfilt(x, y, xbl)
%    tic; sample_flow = smooth(flow,ss); toc
%    sample_flow = boxxfilt(time, flow, 4.*ss./(24*60*60));
dt = ss./(24*60*60);
% sample_flow = sliding_polyfit(time, flow, dt);   
Tr_ss = sliding_polyfit(time,Tr,dt);
% for i = length(time):-1:1
%     ii_ = abs(time - time(i))<= dt;
%     if sum(ii_)>3
%       [P,~, mu] = polyfit(time(ii_),Tr(ii_), 2);
%       good_fit(i) = true;
%       Tr_ss(i) = polyval(P,time(i),[],mu);
%     elseif sum(ii_)>1
%       [P,~, mu] = polyfit(time(ii_),Tr(ii_), 1);
%       good_fit(i) = true;
%       Tr_ss(i) = polyval(P,time(i),[],mu);
%     else
%         good_fit(i) = false;
%     end
%     if mod(i,1000)==0
%         disp(i)
%     end
% end
   
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

   % Shift x-axis to account for width of smoothing window
%    s1 = -0.5./(24*60*60);   

%    Bab = interp1(time+s1.*ss, Bab,time, 'linear','extrap')'; 
% Tr_ss = interp1(time+s1.*ss, Tr_ss,time, 'linear','extrap')'; 

% s1 = -0.5./(24*60*60);
% Bab_5s_ = interp1((psapr_00.time+s1.*5), Bab_5s,psapr_00.time, 'pchip'); 


return
