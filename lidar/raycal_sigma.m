function [vert,ap] = raycal_sigma(ap,vert);
if ~exist('ap','var')
   disp('Select an afterpulse measurement.');
   ap = rd_Sigma;
end
if ~exist('vert','var')
   disp('Select a vertical MPL measurement.');
   vert = rd_Sigma;
end

% compute mean of cop and dep ap
 ap.cop = mean(ap.rawcts(:,ap.hk.polV1<3)')';
 ap.dep = mean(ap.rawcts(:,ap.hk.polV1>3)')';

% load the MPL vert file
%%

r2 = vert.range .* vert.range .*(vert.range>0);

r.bg = find((vert.range > 40) &(vert.range<=55));
r.lte_30 = find((vert.range>0)&(vert.range<=30));
vert.cop_nap = vert.rawcts(:,vert.hk.polV1<3)-(ap.cop*ones(size(vert.time(vert.hk.polV1<3))));
vert.cop_nap = vert.cop_nap - ones(size(vert.range))*mean(vert.cop_nap(r.bg,:));
vert.cop_nap = mean(vert.cop_nap')';
vert.cop_nap = vert.cop_nap .* r2;
%%

%figure; semilogy(vert.range, r2.*mean(vert.prof(:,vert.hk.polV1<3)')', 'r', vert.range, r2.*vert.cop_nap, 'g')
%%
%figure; semilogy(vert.range, vert.cop_nap, 'g')
sonde = ancload;
[attn_prof,tau, altitude, temperature, pressure] = sonde_std_atm_ray_atten(sonde,vert.range(r.lte_30));
r.cal = find((vert.range>=22)&(vert.range<=27));
cal = mean(attn_prof(r.cal))/(mean(vert.cop_nap(r.cal)));
figure; semilogy(vert.range(r.lte_30), cal*(vert.cop_nap(r.lte_30)),'g', vert.range(r.lte_30), attn_prof, 'r');
title(['Vertical profile for MPL',num2str(vert.statics.unitSN), ' on ',datestr(vert.time(1),'yyyy-mm-dd HH:MM UTC')]) 
xlabel('range (km)');
ylabel('attenuated backscatter');
legend('vertical', 'Rayleigh');
vert.cal = cal;
vert.attn_prof = attn_prof;

%%
% compute mean of cop-ap and dep-ap
% Apply range squared correction
% compute attn_prof from sonde
% compute cal between 