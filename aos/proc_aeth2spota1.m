function aeth = proc_aeth_2spot


% Aetheometer mass absorption cross-sections
% These aren't final form.
% Ultimately would want to quantitatively assess:
%    A) The explicit benefit of different duration box-car smoothing on
%    PSAP and on AE33.  Looks likely that Allan variance will limit benefit
%    of longer averaging of AE33 to fairly short durations.
%    B)Quantitative bi-square regression of PSAP vs AE33, both uncorrected
%    C)Quantitative bi-square regression of PSAP vs AE33, both corrected
%    for filter loading, multiple scattering
%    D) Consistent method to assess statistical noise.  Maybe need to
%    request a test with filtered air?

spec_attn.AE31.nm = [370,470,520,590,660,880,950];
spec_attn.AE31.sigma = [39.5, 31.1, 28.1, 24.8, 22.2, 16.6, 15.4];
spec_attn.AE31.P = polyfit(log(spec_attn.AE31.nm./1000), log(spec_attn.AE31.sigma), 1);P.AE31 = spec_attn.AE31.P;

spec_attn.EC.nm = [370,470,520,590,660,880,950];
spec_attn.EC.sigma = [30,23.6,21.3,18.8, 16.8, 12.6, 11.7];
spec_attn.EC.P = polyfit(log(spec_attn.EC.nm./1000), log(spec_attn.EC.sigma), 1);P.EC = spec_attn.EC.P ;

%From Aeth33 manual

spec_attn.AE33.nm = [370,470,520,590,660,880,950];
spec_attn.AE33.sigma = [18.47, 14.54, 13.14, 11.58, 10.35, 7.77, 7.19];
spec_attn.AE33.P = polyfit(log(spec_attn.AE33.nm./1000), log(spec_attn.AE33.sigma), 1);P.AE33 = spec_attn.AE33.P;

% 
% 
figure; 
plot(spec_attn.AE31.nm, spec_attn.AE31.sigma, 'bo-', ...
   spec_attn.EC.nm, spec_attn.EC.sigma, 'ro-', ...
   spec_attn.AE33.nm, spec_attn.AE33.sigma, 'ko-');
lg = legend('AE 31','EC','AE 33');set(lg,'interp','none');
xlabel('wavelength [nm]');
ylabel('sigma')
logx; logy;

% The function "anc_bundle_files" reads one or more ARM netcdf files and 
% concatenates or 'bundles' them together into a single structure
% psap3w = ARM_display_beta;
aeth = anc_bundle_files(getfullname('anxaosae*.nc','aeth')); % aeth = ARM_display_beta;
ae_data = aeth.vdata;
ae_data.time = aeth.time;
ae_meta.vars = aeth.vatts;
ae_meta.global = aeth.gatts;

% Make figure, prompt user to zoom into region for normalization. 
figure_(7) ; plot(aeth.time, ae_data.reference_intensity(2,:),'-'); dynamicDateTicks;
menu('Zoom into a period of time over which to normalize the signals...','OK, done'); xl = xlim;

xl_ = aeth.time>=xl(1) & aeth.time<=xl(2);
ref = ae_data.reference_intensity; ref(ref<0) = NaN; mean_ref = meannonan(ref(:,xl_)')';
figure_(7); these = plot(ae_data.time, ref(2,:)./(mean_ref(2)*ones(size(aeth.time))), '-'); 
% recolor(these,ae_data.wavelength(2));
dynamicDateTicks; axs(1) = gca; title('Reference'); 

samp2 = aeth.vdata.sample_intensity_spot_2; samp2(samp2<0|isnan(ref)) = NaN; mean_samp2 = meannonan(samp2(:,xl_)')';
figure_(8); these = plot(aeth.time, samp2(2,:)./(mean_samp2(2)*ones(size(aeth.time))), '-'); 
% recolor(these,aeth.vdata.wavelength);
dynamicDateTicks; axs(2) = gca; title('Intensity Spot 2'); 

samp1 = aeth.vdata.sample_intensity_spot_1; samp1(samp1<0|isnan(ref)) = NaN; mean_samp1 = meannonan(samp1(:,xl_)')';

figure_(9); these = plot(aeth.time, samp1(2,:)./(mean_samp1(2)*ones(size(aeth.time))), '-'); 
% recolor(these,aeth.vdata.wavelength);
dynamicDateTicks; axs(3) = gca; title('Intensity Spot 1'); 


linkaxes(axs,'x');
% linkexes(axs,'xy');

% According to manual, define ATN0 when bit 1 = 0 and bit 2 = 1
ii = find( ~bitget(aeth.vdata.instrument_status,1) & bitget(aeth.vdata.instrument_status,2));

tr_1 = aeth.vdata.sample_intensity_spot_1./aeth.vdata.reference_intensity; 
tr_2 = aeth.vdata.sample_intensity_spot_2./aeth.vdata.reference_intensity; 
Tr_1 = tr_1; Tr_2 = tr_2;
for aa = ii
    Tr_1(:,aa:end) = tr_1(:,aa:end)./(tr_1(:,aa)*ones(size(aeth.time(aa:end))));
    Tr_2(:,aa:end) = tr_2(:,aa:end)./(tr_2(:,aa)*ones(size(aeth.time(aa:end))));
end

figure_; these = plot(aeth.time,Tr_1(2,:), '-'); title('Tr spot 1'); dynamicDateTicks;
axs(4) = gca; % ylim([-.1, 1.1]);
recolor(these,[aeth.vdata.wavelength ; aeth.vdata.wavelength]); colorbar;
xl = xlim;


figure; plot(aeth.time, ae_data.power_supply_temperature,'-'); dynamicDateTicks
legend('power supply temperature');
xlim(xl);

% ARM_display_beta;
 % According to Gunnar, we have tape 8050 with an assumed Zeta 0.025
% % Also according MaGee according to Gunnar, AE33 spot size is 10 mm diam
spot_area = pi .* 5.^2;
% The function "smooth_Bab" applies a 60-second box-car smoother to the transmittance
% and integrates the sample flow over the same temporal window to produce
% raw absorption coefficients Bab_raw and also reports the integrated
% volume and effective length for the supplied spot_are. 
% Note that the 60-second smoother is a sliding window so the data is still
% provided at 1-second intervals
% Also, "smooth_Bab" was modified to accept a multi-dimensional Tr which
% saves some processing time by not needing to re-integrate the same sample
% flow for each supplied Tr.

disp('Be patient, the integral and smoother take a little while');

tic
[Bab_1_raw_1m, dV1_ss, dL1_ss] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,60, spot_area);toc
tic
[Bab_1_raw_3m] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,180, spot_area);toc
[Bab_1_raw_2m] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,120, spot_area);toc
[Bab_1_raw_30s] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_1, Tr_1,30, spot_area);toc

figure; plot(aeth.time, Bab_1_raw_30s(2,:), '.',aeth.time, Bab_1_raw_1m(2,:), 'x',...
    aeth.time, Bab_1_raw_2m(2,:),'o',aeth.time, Bab_1_raw_3m(2,:),'*'); 
dynamicDateTicks;zoom('on');
legend('Ba AE33 30s','Ba AE33 1m','Ba AE33 2m','Ba AA33 3m')

[Bab_2_raw_1m, dV2_ss, dL2_ss] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_2, Tr_2,60, spot_area);toc
[Bab_2_raw_5m] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_2, Tr_2,300, spot_area);toc
[Bab_2_raw_10s] = smooth_Bab(aeth.time, aeth.vdata.sample_flow_rate_spot_2, Tr_2,10, spot_area);toc


Wein_C = 1.57; % Weingartner multiple scattering correction parameter C
Wein_C = 1.39; % C consistent with lab testing at TROPOS in Leipzig.
% Wein_C = 1.77; % Weingartner multiple scattering correction parameter C

% Despite the suggestion from Gunnar that we use zeta 0.025
 % a zeta_leak factor of 0.05 below seems to better reproduce the
 % Aethalometer reported values. 
 % The statement above _may_ have been true before, but not as of May 13, 2020
 % The zeta factor of 0.025
 % results in a strong match between McGee reported BC values (smoothed to
 % 60s) and my 1m comparable value computed from raw intensities with
 % Wein_C = 1.39 and zeta correction applied. (line 152 below)

zeta_leak = 0.05; zeta_leak = 0.025;
Bab_1_1m= Bab_1_raw_1m./(Wein_C.*(1-zeta_leak)); Bab_2_1m = Bab_2_raw_1m./(Wein_C.*(1-zeta_leak));

figure; plot(aeth.time, Bab_1_raw_1m(2,:), '-x', psap1s.time, psap1s.vdata.Ba_B_raw,'kx-'); dynamicDateTicks
%The values for B2_raw and B1_raw are from the raw file reported by AE33
B2_raw = aeth.vdata.equivalent_black_carbon_spot_2_uncorrected;
B1_raw = aeth.vdata.equivalent_black_carbon_spot_1_uncorrected;

% The values for B1 and B2 below are computed from the raw intensities in
% the file but have been averaged as per smooth_Bab
% units.  Bab is in 1/Mm.  sigma is m2/g but BC is in ng/m^3
B1 = 1e3.*Bab_1_1m ./ (spec_attn.AE33.sigma' * ones([1,length(aeth.time)]));
B2 = 1e3.*Bab_2_1m ./(spec_attn.AE33.sigma' * ones([1,length(aeth.time)]));

v = axis;
figure; plot(aeth.time, B1(2,:), 'x',smooth(aeth.time,60), smooth(B1_raw(2,:),60),'o'); dynamicDateTicks; zoom('on');
legend('mine BC','McGee BC');
axis(v)
% What follows is the unsuccessful attempt to reproduce the loading factor
% K.  I'm pretty sure I've derived it correctly but the definition below
% fails to reproduce the raw values reported in the AE33 ASCII stream.
% Seems like there is some black magic going on, possibly the weighting
% described in Drinovec (doi:10.5194/amt-8-1965-2015) 
ATN1 = -100.*(log(Tr_1));
ATN2 = -100.*(log(Tr_2));
K = (B1-B2)./(B1.*ATN2-B2.*ATN1);

%The following values are "downsampled" to a 60-second grid.
aeth_1m.time = downsample(aeth.time,60);
aeth_1m.B1_raw = downsample(B1_raw',60)';
aeth_1m.B2_raw = downsample(B2_raw',60)';
aeth_1m.B1_cjf = downsample(B1',60)';
aeth_1m.B2_cjf = downsample(B2',60)';
aeth_1m.K_raw = downsample(aeth.vdata.loading_correction_factor',60)';
aeth_1m.ATN1 = interp1(aeth.time, ATN1',aeth_1m.time,'nearest')';
aeth_1m.ATN2 = interp1(aeth.time, ATN2',aeth_1m.time,'nearest')';
aeth_1m.K = (aeth_1m.B1_cjf-aeth_1m.B2_cjf)./(aeth_1m.B1_cjf.*aeth_1m.ATN2-aeth_1m.B2_cjf.*aeth_1m.ATN1);
aeth_1m.K = downsample(K',60)';
aeth_1m.Ba_1 = downsample(Bab_1',60)';
aeth_1m.Ba_2 = downsample(Bab_2',60)';

%The following samples are "downsampled" to a 5-minute grid
aeth_5m.time = downsample(aeth.time,300);
aeth_5m.B1_raw = downsample(B1_raw',300)';
aeth_5m.B2_raw = downsample(B2_raw',300)';
aeth_5m.B1_cjf = downsample(B1',300)';
aeth_5m.B2_cjf = downsample(B2',300)';
aeth_5m.K_raw = downsample(aeth.vdata.loading_correction_factor',300)';
aeth_5m.ATN1 = interp1(aeth.time, ATN1',aeth_5m.time,'nearest')';
aeth_5m.ATN2 = interp1(aeth.time, ATN2',aeth_5m.time,'nearest')';
aeth_5m.K = (aeth_5m.B1_cjf-aeth_5m.B2_cjf)./(aeth_5m.B1_cjf.*aeth_5m.ATN2-aeth_5m.B2_cjf.*aeth_5m.ATN1);
aeth_5m.K = downsample(K',300)';
aeth_5m.Ba_1 = downsample(Bab_1',300)';
aeth_5m.Ba_2 = downsample(Bab_2',300)';

%Compare the 5-minute averages of my computed BC values (which used a
%60-degree sliding window in Transmittance) with a straight 5-minute
%average of the raw AE33 reported BC which were computed from 1-s data
figure; plot(aeth_5m.time, aeth_5m.B1_cjf([2,3,5],:)./aeth_5m.B1_raw([2,3,5],:),'.'); 
dynamicDateTicks;  title('BC1 mine / MaGee');ylim([0.5,1.3]);

% Same as above but for the canonical wavelegth #6
figure; plot(aeth_5m.time, aeth_5m.B1_cjf([6],:),'o',aeth_5m.time, aeth_5m.B1_raw([6],:),'x'); 
dynamicDateTicks;  legend('BC1 mine','BC1 MaGee')

% Plot the loading factor reported in the AE33 file and my unsuccessful attempt to
% reproduce it.
figure; these = plot(aeth.time, aeth.vdata.loading_correction_factor,'.'); recolor(these,aeth.vdata.wavelength);
figure; these = plot(aeth.time, K, '-'); recolor(these, aeth.vdata.wavelength); 
linkexes

% Same as above  but for 5m averages.
figure; plot(aeth_5m.time, aeth_5m.K(1:4,:), '.', aeth_5m.time, aeth_5m.K_raw([1 3],:),'k.')
% ,aeth_1m.time, aeth_1m.B1_cjf([2,3,5],:),'o'); 
dynamicDateTicks;  


return