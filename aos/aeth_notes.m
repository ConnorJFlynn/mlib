% Aetheometer mass absorption cross-sections


spec_attn.Magee.nm = [370,470,520,590,660,880,950];
spec_attn.Magee.sigma = [39.5, 31.1, 28.1, 24.8, 22.2, 16.6, 15.4];
spec_attn.Magee.P = polyfit(log(spec_attn.Magee.nm./1000), log(spec_attn.Magee.sigma), 1);P.Magee = spec_attn.Magee.P;

spec_attn.EC.nm = [370,470,520,590,660,880,950];
spec_attn.EC.sigma = [30,23.6,21.3,18.8, 16.8, 12.6, 11.7];
spec_attn.EC.P = polyfit(log(spec_attn.EC.nm./1000), log(spec_attn.EC.sigma), 1);P.EC = spec_attn.EC.P ;

%From Aeth33 manual

spec_attn.Aeth33.nm = [370,470,520,590,660,880,950];
spec_attn.Aeth33.sigma = [18.47, 14.54, 13.14, 11.58, 10.35, 7.77, 7.19];
spec_attn.Aeth33.P = polyfit(log(spec_attn.Aeth33.nm./1000), log(spec_attn.Aeth33.sigma), 1);P.Ae33 = spec_attn.Aeth33.P;
P


figure; 
plot(spec_attn.Magee.nm/1000, spec_attn.Magee.sigma, 'bo-', ...
   spec_attn.EC.nm/1000, spec_attn.EC.sigma, 'ro-', ...
   spec_attn.Aeth33.nm/1000, spec_attn.Aeth33.sigma, 'ko-');
legend('Magee BC','EC','Ae_33')
aeth = ARM_nc_display;


%this shows that optical attenuation is a good sign of spot change
figure; plot(serial2doys(aeth.time), aeth.vdata.optical_attenuation(3,:),'x')

%this computes transmittance from the raw quantities (but normalized to the
% max value found after the spot change (that's the 1./0.5313)
figure; plot(serial2doys(aeth.time), (1./.5313)*(aeth.vdata.sample_intensity(3,:)-aeth.vdata.sample_dark(3,:))./(aeth.vdata.reference_intensity(3,:)-aeth.vdata.reference_dark(3,:)),'o')
Tr = (1./.5313)*(aeth.vdata.sample_intensity(3,:)-aeth.vdata.sample_dark(3,:))./(aeth.vdata.reference_intensity(3,:)-aeth.vdata.reference_dark(3,:));
% 
OD = -100.*log(Tr);

figure; plot(serial2doys(aeth.time), OD,'r*')
% This matches the plot of OD from the file, so we understand how to derive
% it ourselves and our transmittance must be OK too.   