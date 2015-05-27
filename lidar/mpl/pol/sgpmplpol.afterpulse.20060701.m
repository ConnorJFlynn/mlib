% Computing polarized afterpulse at SGP using low-cloud data from
% 2006-07-01 after CHAPS/CLASIC

cop_ap_raw = mean(polavg.cop(:,ap_time),2);
crs_ap_raw = mean(polavg.crs(:,ap_time),2);
%%
% We'll gsmooth and replace the lowest portion with polynomial fit from the km above.
no_low = polavg.range>.2;
full = numel(polavg.range(no_low));
bin_size = polavg.range(10)-polavg.range(9);
scale_factor = 60;
W = bin_size .* (linspace(2,scale_factor,full));
cop_ap_gs(no_low) = gsmooth(polavg.range(no_low), cop_ap_raw(no_low),W);
crs_ap_gs(no_low) = gsmooth(polavg.range(no_low), crs_ap_raw(no_low),W);

%%

r.ap_fit = polavg.range>.2 & polavg.range<.5;
log_r = log10(polavg.range(r.ap_fit));
log_cop_ap = log10(cop_ap_gs(r.ap_fit))';
log_crs_ap = log10(crs_ap_gs(r.ap_fit))';

%%
figure; plot(log_r, log_cop_ap, 'r.',log_r, log_crs_ap, 'b.')
%%
[P_cop] = polyfit(log_r,log_cop_ap,1);
[P_crs] = polyfit(log_r,log_crs_ap,1);

cop_ap_low = 10.^ polyval(P_cop,log10(polavg.range(~no_low)));
crs_ap_low = 10.^ polyval(P_crs,log10(polavg.range(~no_low)));
cop_ap(no_low) = cop_ap_gs(no_low); cop_ap(~no_low) = cop_ap_low;
crs_ap(no_low) = crs_ap_gs(no_low); crs_ap(~no_low) = crs_ap_low;
lt0 = polavg.range<=0;
cop_ap(lt0) = NaN;
crs_ap(lt0) = NaN;
% lt0 = cop_ap<=0;
% cop_ap(lt0) = NaN;
% lt0 = crs_ap<=0;
% crs_ap(lt0) = NaN;
save sgpmpl.copap.20060701.mat cop_ap
save sgpmpl.crsap.20060701.mat crs_ap
%%



