function SAS_combine_He_Ze_from_specs
vis_u34 = SAS_compare_bare_He_Ze;
vis_u36 = SAS_compare_bare_He_Ze;
vis_u37 = SAS_compare_bare_He_Ze;
nir_u46 = SAS_compare_bare_He_Ze;

close('all');
%%
figure; plot(vis_u34.bare.nm, vis_u34.He_T, '-',...
   vis_u36.bare.nm, vis_u36.He_T, '-',...
   vis_u37.bare.nm, vis_u37.He_T, '-',...
   nir_u46.bare.nm, nir_u46.He_T, '-');
title('Comparing Hemisp T for different spectrometers')
ylabel('transmittance');
xlabel('nm')
legend('Unit 34','Unit 36','Unit 37','Unit 46');
%%

figure; plot(vis_u34.bare.nm, vis_u34.Ze_T, '-',...
   vis_u36.bare.nm, vis_u36.Ze_T, '-',...
   vis_u37.bare.nm, vis_u37.Ze_T, '-',...
   nir_u46.bare.nm, nir_u46.Ze_T, '-');
title('Comparing Zenith T for different spectrometers')
ylabel('transmittance');
xlabel('nm')
legend('Unit 34','Unit 36','Unit 37','Unit 46');
%%

figure; plot(vis_u34.bare.nm, vis_u34.He_by_Ze, '-',...
   vis_u36.bare.nm, vis_u36.He_by_Ze, '-',...
   vis_u37.bare.nm, vis_u37.He_by_Ze, '-',...
   nir_u46.bare.nm, nir_u46.He_by_Ze, '-');
title('Comparing Hemisp to Zenith ratio for different spectrometers')
ylabel('Hemisp/Zenith');
xlabel('nm')
legend('Unit 34','Unit 36','Unit 37','Unit 46');
%%
