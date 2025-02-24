function [Bap] = Bap_ss(time, sample_flow, Tr,ss, spot_area);
% [Bap] = Bap_ss(time, flow, ss, spot_area);
% Apply Sedlacek and Springston 2007 box-car filter with full-width "ss" seconds to filter transmittance 
% Requires time [days], sample_flow [lpm], Tr [unitless filter transmittance]
% smoothing window ss [seconds] and spot_area [mm^2] are optional

% optional "spot_area" is in units of mm^2, def 17.81 for PSAP
% Modified 2020/01/31 to accept N-dimensioned Tr for aethalometer
% Modified again ~06/06/2023 to vectorize trapz.  May have broken N-dim Tr above, but
% worth the price if so.  Test this!

%2024-12-25, CJF: add "unique" before interp1


if ~exist('spot_area','var')||isempty(spot_area)
   spot_area = 17.81; %mm^2 % Default for PSAP
end
% PSAP and CLAP == 17.81 mm2
% TAP = 30.66 mm2 by manual
% MA = 3 mm diam = 0.3 cm diam == Area = 7.0686 mm^2
if spot_area <1e-4 % probaby in m^2 
    spot_area = spot_area * 1e6;
elseif spot_area < 1 % probably in cm^2
    spot_area = spot_area * 1e2;
end

tim = [time(1):(1./(24.*60.*60)):time(end)]'; % create tim in 1-second intervals
sflow = interp1(time, sample_flow,tim,'linear');
% sflow(isnan(sflow)) =interp1(time(~isnan(sample_flow)), sample_flow(~isnan(sample_flow)), tim(isnan(sflow)),'nearest','extrap');
sTr = interp1(time, Tr, tim, 'linear'); 
if any(size(Tr)==1)
   sTr(isnan(sTr)) = interp1(time(~isnan(Tr)), Tr(~isnan(Tr)), tim(isnan(sTr)),'nearest','extrap');
else
   nansTr = any(isnan(sTr),2);
   nanTr = any(isnan(Tr),2); 
   % sTr(nansTr,:) = interp1(time(~nanTr), Tr(~nanTr,:), tim(nansTr),'nearest','extrap');
end
% build a 2D version of flow to vectorize trapz below, huge speed increase
ii = [1:length(tim)-ss]'; jj = [ss+1:length(tim)]';
for tt = length(ii):-1:1
   flows(tt,:) = sflow(ii(tt):jj(tt));
end
dV = trapz(tim(1:ss+1)*24*60,flows,2);
if any(size(sTr)==1)
   abs_s = real(log(sTr(ii)./sTr(jj))); % Need to check this line for n-dim Tr for Aeth
else
   abs_s = real(log(sTr(ii,:)./sTr(jj,:))); % Need to check this line for n-dim Tr for Aeth
end

dL_s = 1000.*dV./spot_area;
Bap = 1e6.*abs_s./(dL_s*ones(1,size(abs_s,2)));
Bap = interp1(tim((1+ceil(ss./2)):(end-floor(ss./2))), Bap, time,'linear');

return
