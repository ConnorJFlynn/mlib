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



figure; 
plot(spec_attn.Magee.nm, spec_attn.Magee.sigma, 'bo-', ...
   spec_attn.EC.nm, spec_attn.EC.sigma, 'ro-', ...
   spec_attn.Aeth33.nm, spec_attn.Aeth33.sigma, 'ko-');
lg = legend('Magee BC','EC','Ae_33');set(lg,'interp','none');
xlabel('wavelength [nm]');
ylabel('sigma')
logx; logy;

aeth = anc_bundle_files(getfullname('coraosae*.nc','aeth'));



figure_(7); these = plot(aeth.time, aeth.vdata.reference_intensity, '-'); recolor(these,aeth.vdata.wavelength);
dynamicDateTicks; axs(1) = gca; title('Reference'); 

figure_(8); these = plot(aeth.time, aeth.vdata.sample_intensity_spot_2, '-'); recolor(these,aeth.vdata.wavelength);
dynamicDateTicks; axs(2) = gca; title('Spot 2'); 

figure_(9); these = plot(aeth.time, aeth.vdata.sample_intensity_spot_1, '-'); recolor(these,aeth.vdata.wavelength);
dynamicDateTicks; axs(3) = gca; title('Spot 1'); 

linkaxes(axs,'xy')

% According to manual, define ATN0 when bit 1 = 0 and bit 2 = 1
ii = find( ~bitget(aeth.vdata.instrument_status,1) & bitget(aeth.vdata.instrument_status,2));

tr_1 = aeth.vdata.sample_intensity_spot_1./aeth.vdata.reference_intensity; 
tr_2 = aeth.vdata.sample_intensity_spot_2./aeth.vdata.reference_intensity; 
Tr_1 = tr_1; Tr_2 = tr_2;
for aa = 1:length(ii)
    Tr_1(:,ii(aa):end) = tr_1(:,ii(aa):end)./(tr_1(:,ii(aa))*ones(size(aeth.time(ii(aa):end))));
    Tr_2(:,ii(aa):end) = tr_2(:,ii(aa):end)./(tr_2(:,ii(aa))*ones(size(aeth.time(ii(aa):end))));
end

figure_; these = plot(aeth.time,Tr_1, ':',aeth.time,Tr_2, '-'); title('Tr spot 1 and 2'); dynamicDateTicks;
axs(4) = gca; ylim([-.1, 1.1]);
recolor(these,[aeth.vdata.wavelength ; aeth.vdata.wavelength])
ATN1 = -100.*(log(Tr_1));
ATN2 = -100.*(log(Tr_2));
B2 = aeth.vdata.equivalent_black_carbon_spot_2_uncorrected;
B1 = aeth.vdata.equivalent_black_carbon_spot_1_uncorrected;
K = (B1-B2)./(B1.*ATN2-B2.*ATN1);
figure; these = plot(aeth.time, aeth.vdata.loading_correction_factor,'.'); recolor(these,aeth.vdata.wavelength);
figure; these = plot(aeth.time, K, '-'); recolor(these, aeth.vdata.wavelength); 
linkexes
figure; plot(aeth.time, ATN1, 'o',aeth.time, ATN2,'x');dynamicDateTicks

figure; plot(aeth.time, B2, 'o',aeth.time, B1,'x'); dynamicDateTicks; 
%this shows that optical attenuation is a good sign of spot change
figure; plot(aeth.time, aeth.vdata.sample_intensity_spot_1, '-'); title('spot 1'); dynamicDateTicks
figure; plot(aeth.time, aeth.vdata.sample_intensity_spot_2,'-');title('spot_2');dynamicDateTicks
figure; plot(aeth.time, aeth.vdata.reference_intensity,'-'); title('reference');dynamicDateTicks
linkexes;

figure; plot((aeth.time), aeth.vdata.optical_attenuation_1(3,:),'x',(aeth.time), aeth.vdata.optical_attenuation_2(3,:),'o'); dynamicDateTicks
xl = xlim;
xl_ = aeth.time>xl(1)&aeth.time<xl(2);
figure; these = plot(aeth.time(xl_), aeth.vdata.optical_attenuation_1(:,xl_), '-',aeth.time(xl_), aeth.vdata.optical_attenuation_2(:,xl_), '-'); recolor(these,aeth.vdata.wavelength); colorbar
figure; those = plot(aeth.vdata.wavelength, aeth.vdata.optical_attenuation_2(:,xl_(1:100:end))','-'); recolor(those, serial2hs(aeth.time(xl_(1:100:end)))); colorbar

%this computes transmittance from the raw quantities (but normalized to the
% max value found after the spot change (that's the 1./0.5313)
figure; plot(serial2doys(aeth.time), (1./.5313)*(aeth.vdata.sample_intensity(3,:)-aeth.vdata.sample_dark(3,:))./(aeth.vdata.reference_intensity(3,:)-aeth.vdata.reference_dark(3,:)),'o')
Tr = (aeth.vdata.sample_intensity-aeth.vdata.sample_dark)./(aeth.vdata.reference_intensity-aeth.vdata.reference_dark);
figure; plot(aeth.time, Tr(3,:), 'x'); dynamicDateTicks

starts = find(Tr(3,2:end)-Tr(3,1:(end-1))> .2)+1;
To = Tr;
To(:,[starts(end):size(Tr,2)]) = Tr(:,starts(end))*ones([1,size(Tr,2)-starts(end)+1]);
for s = length(starts)-1:-1:1
To(:,[starts(s):starts(s+1)]) = Tr(:,starts(s))*ones([1,length([starts(s):starts(s+1)])]);
end
% 
figure; that = plot(aeth.time, (Tr./To)', '-'); dynamicDateTicks; recolor(that,aeth.vdata.wavelength);
figure; plot(aeth.time, Tr./To,'o-')

for wl = length(aeth.vdata.wavelength):-1:1
[Bab(wl,:), Tr_ss, dV_ss, dL_ss] = smooth_Tr_Bab(aeth.time, aeth.vdata.sample_flow_rate,Tr(wl,:)./To(wl,:),60);
disp(['Done with wl=',num2str(wl)])
end
disp('Done!')
Bab(Bab<=0) = NaN;
figure; that = plot(aeth.time, Bab, '-'); recolor(that,aeth.vdata.wavelength);colorbar; dynamicDateTicks

figure; plot((aeth.vdata.wavelength), (Bab(:,xl_)), '-');
X = X + 1;AAE(X,:) = ang_exp(Bab(X,xl_),Bab(X+1,xl_),aeth.vdata.wavelength(X),aeth.vdata.wavelength(X+1)) ;

AAE(7,:) = ang_exp(Bab(1,xl_),Bab(end,xl_),aeth.vdata.wavelength(1),aeth.vdata.wavelength(end)) ;

figure; wls = plot(aeth.time(xl_), AAE(7,:), '-'); recolor(wls, aeth.vdata.wavelength); colorbar; dynamicDateTicks
% This matches the plot of OD from the file, so we understand how to derive
% it ourselves and our transmittance must be OK too.   