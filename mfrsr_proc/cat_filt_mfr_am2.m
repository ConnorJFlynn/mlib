function mfr_ = cat_filt_mfr_am2;
% cat_filt_mfraod
% concatenates and filters MFRSR file (aod or b1) to restrict AM<2, and to exclude
% ddr exceeding Rayleigh limits.  The result is saved to mat file for later use in
% SASHe_DDR_ver_3 to infer DDR correction factors.

mfr_files = getfullname(['*mfrsr*.cdf;*mfrsr*.nc']);
mfr = anc_load(mfr_files{1});

Tr_ray1 = exp(-.3313.*mfr.vdata.airmass);
Ray_DDR_filt1 = 2.*Tr_ray1./(1-Tr_ray1);
% figure; plot(mfr.time(keep), Ray_DDR_filt1(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter1(keep),'x'); dynamicDateTicks

Tr_ray2 = exp(-.1426.*mfr.vdata.airmass);
Ray_DDR_filt2 = 2.*Tr_ray2./(1-Tr_ray2);
% figure; plot(mfr.time(keep), Ray_DDR_filt2(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter2(keep),'x'); dynamicDateTicks

Tr_ray3 = exp(-0.0619.*mfr.vdata.airmass);
Ray_DDR_filt3 = 2.*Tr_ray3./(1-Tr_ray3);
% figure; plot(mfr.time(keep), Ray_DDR_filt3(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter3(keep),'x'); dynamicDateTicks
% mfr.vdata.Rayleigh_optical_depth_filter7

Tr_ray4 = exp(-0.0433.*mfr.vdata.airmass);
Ray_DDR_filt4 = 2.*Tr_ray4./(1-Tr_ray4);
% figure; plot(mfr.time(keep), Ray_DDR_filt4(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter4(keep),'x'); dynamicDateTicks

Tr_ray5 = exp(-0.0153.*mfr.vdata.airmass);
Ray_DDR_filt5 = 2.*Tr_ray5./(1-Tr_ray5);
% figure; plot(mfr.time(keep), Ray_DDR_filt5(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter5(keep),'x'); dynamicDateTicks

Tr_ray7 = exp(-0.0012.*mfr.vdata.airmass);
Ray_DDR_filt7 = 2.*Tr_ray7./(1-Tr_ray7);
% figure; plot(mfr.time(keep), Ray_DDR_filt7(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter7(keep),'x'); dynamicDateTicks


keep = mfr.vdata.airmass>=1 & mfr.vdata.airmass<=2;
keep = keep & mfr.vdata.direct_normal_narrowband_filter1>0 & mfr.vdata.diffuse_hemisp_narrowband_filter1>0;
keep = keep & mfr.vdata.direct_diffuse_ratio_filter1 >0 & mfr.vdata.direct_diffuse_ratio_filter1 < 2.*Ray_DDR_filt1;
keep = keep & mfr.vdata.direct_normal_narrowband_filter2>0 & mfr.vdata.diffuse_hemisp_narrowband_filter2>0;
keep = keep & mfr.vdata.direct_diffuse_ratio_filter2 >0& mfr.vdata.direct_diffuse_ratio_filter2 < 2.*Ray_DDR_filt2;
keep = keep & mfr.vdata.direct_normal_narrowband_filter3>0 & mfr.vdata.diffuse_hemisp_narrowband_filter3>0;
keep = keep & mfr.vdata.direct_diffuse_ratio_filter3 >0 & mfr.vdata.direct_diffuse_ratio_filter3 < Ray_DDR_filt3;
keep = keep & mfr.vdata.direct_normal_narrowband_filter4>0 & mfr.vdata.diffuse_hemisp_narrowband_filter4>0;
keep = keep & mfr.vdata.direct_diffuse_ratio_filter4 >0& mfr.vdata.direct_diffuse_ratio_filter4 < Ray_DDR_filt4;
keep = keep & mfr.vdata.direct_normal_narrowband_filter5>0 & mfr.vdata.diffuse_hemisp_narrowband_filter5>0;
keep = keep & mfr.vdata.direct_diffuse_ratio_filter5 >0 & mfr.vdata.direct_diffuse_ratio_filter5 < 0.5.*Ray_DDR_filt5;
if isfield(mfr.vdata,'direct_diffuse_ration_filter7')
   keep = keep & mfr.vdata.direct_normal_narrowband_filter7>0 & mfr.vdata.diffuse_hemisp_narrowband_filter7>0;
   keep = keep & mfr.vdata.direct_diffuse_ratio_filter7 >0 & mfr.vdata.direct_diffuse_ratio_filter7 < 0.05.*Ray_DDR_filt7;

end
sum(keep);

mfr = anc_sift(mfr, keep);
mfr_ = mfr;

for m = 2:length(mfr_files)
   mfr = anc_load(mfr_files{m});
   Tr_ray1 = exp(-.3313.*mfr.vdata.airmass);
   Ray_DDR_filt1 = 2.*Tr_ray1./(1-Tr_ray1);
   % figure; plot(mfr.time(keep), Ray_DDR_filt1(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter1(keep),'x'); dynamicDateTicks

   Tr_ray2 = exp(-.1426.*mfr.vdata.airmass);
   Ray_DDR_filt2 = 2.*Tr_ray2./(1-Tr_ray2);
   % figure; plot(mfr.time(keep), Ray_DDR_filt2(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter2(keep),'x'); dynamicDateTicks

   Tr_ray3 = exp(-0.0619.*mfr.vdata.airmass);
   Ray_DDR_filt3 = 2.*Tr_ray3./(1-Tr_ray3);
   % figure; plot(mfr.time(keep), Ray_DDR_filt3(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter3(keep),'x'); dynamicDateTicks
   % mfr.vdata.Rayleigh_optical_depth_filter7

   Tr_ray4 = exp(-0.0433.*mfr.vdata.airmass);
   Ray_DDR_filt4 = 2.*Tr_ray4./(1-Tr_ray4);
   % figure; plot(mfr.time(keep), Ray_DDR_filt4(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter4(keep),'x'); dynamicDateTicks

   Tr_ray5 = exp(-0.0153.*mfr.vdata.airmass);
   Ray_DDR_filt5 = 2.*Tr_ray5./(1-Tr_ray5);
   % figure; plot(mfr.time(keep), Ray_DDR_filt5(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter5(keep),'x'); dynamicDateTicks

   Tr_ray7 = exp(-0.0012.*mfr.vdata.airmass);
   Ray_DDR_filt7 = 2.*Tr_ray7./(1-Tr_ray7);
   % figure; plot(mfr.time(keep), Ray_DDR_filt7(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter7(keep),'x'); dynamicDateTicks


   keep = mfr.vdata.airmass>=1 & mfr.vdata.airmass<=2;
   keep = keep & mfr.vdata.direct_normal_narrowband_filter1>0 & mfr.vdata.diffuse_hemisp_narrowband_filter1>0;
   keep = keep & mfr.vdata.direct_diffuse_ratio_filter1 >0 & mfr.vdata.direct_diffuse_ratio_filter1 < 2.*Ray_DDR_filt1;
   keep = keep & mfr.vdata.direct_normal_narrowband_filter2>0 & mfr.vdata.diffuse_hemisp_narrowband_filter2>0;
   keep = keep & mfr.vdata.direct_diffuse_ratio_filter2 >0& mfr.vdata.direct_diffuse_ratio_filter2 < 2.*Ray_DDR_filt2;
   keep = keep & mfr.vdata.direct_normal_narrowband_filter3>0 & mfr.vdata.diffuse_hemisp_narrowband_filter3>0;
   keep = keep & mfr.vdata.direct_diffuse_ratio_filter3 >0 & mfr.vdata.direct_diffuse_ratio_filter3 < Ray_DDR_filt3;
   keep = keep & mfr.vdata.direct_normal_narrowband_filter4>0 & mfr.vdata.diffuse_hemisp_narrowband_filter4>0;
   keep = keep & mfr.vdata.direct_diffuse_ratio_filter4 >0& mfr.vdata.direct_diffuse_ratio_filter4 < Ray_DDR_filt4;
   keep = keep & mfr.vdata.direct_normal_narrowband_filter5>0 & mfr.vdata.diffuse_hemisp_narrowband_filter5>0;
   keep = keep & mfr.vdata.direct_diffuse_ratio_filter5 >0 & mfr.vdata.direct_diffuse_ratio_filter5 < 0.5.*Ray_DDR_filt5;
   if isfield(mfr.vdata,'direct_diffuse_ratio_filter7')
      keep = keep & mfr.vdata.direct_normal_narrowband_filter7>0 & mfr.vdata.diffuse_hemisp_narrowband_filter7>0;
      keep = keep & mfr.vdata.direct_diffuse_ratio_filter7 >0 & mfr.vdata.direct_diffuse_ratio_filter7 < 0.05.*Ray_DDR_filt7;
   end
   if sum(keep)>0
      mfr = anc_sift(mfr, keep);
      mfr_ = anc_cat(mfr_, mfr);
      disp(length(mfr_.time))
   end
   disp(['file: ',num2str(length(mfr_files)-m)])
end
disp(length(mfr_.time))
figure; plot(mfr_.time, [mfr_.vdata.direct_diffuse_ratio_filter1;mfr_.vdata.direct_diffuse_ratio_filter2;...
   mfr_.vdata.direct_diffuse_ratio_filter3;mfr_.vdata.direct_diffuse_ratio_filter4;...
   mfr_.vdata.direct_diffuse_ratio_filter5],'.');legend('415','500','615','675','870'); dynamicDateTicks;
if isfield(mfr_.vdata,'direct_diffuse_ratio_filter7');
   hold('on');
   plot(mfr_.time, mfr_.vdata.direct_diffuse_ratio_filter7,'k.');
   legend('415','500','615','675','870','1625');
   hold('off')
end
outfile = [fileparts(mfr_.fname),'.ddr_filt.',datestr(mfr_.time(1),'yyyymmdd_'), datestr(mfr_.time(end),'yyyymmdd'),'.mat'];
save(outfile,'-struct','mfr_');