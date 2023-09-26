function sas = cat_sasvis_ddr;
% Concatenates and filters SASVIS files to exclude irradiance < 0 and ddr values that
% exceed Rayleigh limits. The result is saved in a mat file for later use in
% SASHe_DDR_cor_v3 to derive DDR correction factors
% outputs only vis wl values from MFRSR and Cimel>=380 

sas_files = getfullname('*sashe*aod*.cdf');
sas = anc_load(sas_files{1});
wl_i = interp1(sas.vdata.wavelength, [1:length(sas.vdata.wavelength)],[380, 415,440,500,615,675,870],'nearest');
sas = anc_sift(sas, wl_i,sas.ncdef.dims.wavelength);
ddr = sas.vdata.direct_normal_transmittance./sas.vdata.diffuse_transmittance;
Tr_ray1 = exp(-.3313.*sas.vdata.airmass); Ray_DDR_filt1 = 2.*Tr_ray1./(1-Tr_ray1);
% figure; plot(mfr.time(keep), Ray_DDR_filt1(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter1(keep),'x'); dynamicDateTicks
Tr_ray2 = exp(-.1426.*sas.vdata.airmass); Ray_DDR_filt2 = 2.*Tr_ray2./(1-Tr_ray2);
% figure; plot(mfr.time(keep), Ray_DDR_filt2(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter2(keep),'x'); dynamicDateTicks
Tr_ray3 = exp(-0.0619.*sas.vdata.airmass); Ray_DDR_filt3 = 2.*Tr_ray3./(1-Tr_ray3);
% figure; plot(mfr.time(keep), Ray_DDR_filt3(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter3(keep),'x'); dynamicDateTicks
Tr_ray4 = exp(-0.0433.*sas.vdata.airmass); Ray_DDR_filt4 = 2.*Tr_ray4./(1-Tr_ray4);
% figure; plot(mfr.time(keep), Ray_DDR_filt4(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter4(keep),'x'); dynamicDateTicks
Tr_ray5 = exp(-0.0153.*sas.vdata.airmass); Ray_DDR_filt5 = 2.*Tr_ray5./(1-Tr_ray5);
% figure; plot(mfr.time(keep), Ray_DDR_filt5(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter5(keep),'x'); dynamicDateTicks

keep = sas.vdata.airmass>=1 & sas.vdata.airmass<=2;
keep = keep& all(sas.vdata.direct_normal_transmittance>0) & all(sas.vdata.diffuse_transmittance>0);
keep = keep & ddr(2,:)>0 & ddr(2,:)< 2.*Ray_DDR_filt1;
keep = keep & ddr(4,:)>0 & ddr(4,:)< 2.*Ray_DDR_filt2;
keep = keep & ddr(5,:)>0 & ddr(5,:)< Ray_DDR_filt3;
keep = keep & ddr(6,:)>0 & ddr(6,:)< Ray_DDR_filt4;
keep = keep & ddr(7,:)>0 & ddr(7,:)< 0.5.*Ray_DDR_filt5;
sas = anc_sift(sas,keep);
for m = 2:length(sas_files)
   sas_ = anc_load(sas_files{m});
   sas_ = anc_sift(sas_, wl_i,sas.ncdef.dims.wavelength);
   ddr = sas_.vdata.direct_normal_transmittance./sas_.vdata.diffuse_transmittance;
   Tr_ray1 = exp(-.3313.*sas_.vdata.airmass); Ray_DDR_filt1 = 2.*Tr_ray1./(1-Tr_ray1);
   % figure; plot(mfr.time(keep), Ray_DDR_filt1(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter1(keep),'x'); dynamicDateTicks
   Tr_ray2 = exp(-.1426.*sas_.vdata.airmass); Ray_DDR_filt2 = 2.*Tr_ray2./(1-Tr_ray2);
   % figure; plot(mfr.time(keep), Ray_DDR_filt2(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter2(keep),'x'); dynamicDateTicks
   Tr_ray3 = exp(-0.0619.*sas_.vdata.airmass); Ray_DDR_filt3 = 2.*Tr_ray3./(1-Tr_ray3);
   % figure; plot(mfr.time(keep), Ray_DDR_filt3(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter3(keep),'x'); dynamicDateTicks
   Tr_ray4 = exp(-0.0433.*sas_.vdata.airmass); Ray_DDR_filt4 = 2.*Tr_ray4./(1-Tr_ray4);
   % figure; plot(mfr.time(keep), Ray_DDR_filt4(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter4(keep),'x'); dynamicDateTicks
   Tr_ray5 = exp(-0.0153.*sas_.vdata.airmass); Ray_DDR_filt5 = 2.*Tr_ray5./(1-Tr_ray5);
   % figure; plot(mfr.time(keep), Ray_DDR_filt5(keep),'.', mfr.time(keep), mfr.vdata.direct_diffuse_ratio_filter5(keep),'x'); dynamicDateTicks

   keep = sas_.vdata.airmass>=1 & sas_.vdata.airmass<=2;
   keep = keep& all(sas_.vdata.direct_normal_transmittance>0) & all(sas_.vdata.diffuse_transmittance>0);
   keep = keep & ddr(2,:)>0 & ddr(2,:)< 2.*Ray_DDR_filt1;
   keep = keep & ddr(4,:)>0 & ddr(4,:)< 2.*Ray_DDR_filt2;
   keep = keep & ddr(5,:)>0 & ddr(5,:)< Ray_DDR_filt3;
   keep = keep & ddr(6,:)>0 & ddr(6,:)< Ray_DDR_filt4;
   keep = keep & ddr(7,:)>0 & ddr(7,:)< 0.5.*Ray_DDR_filt5;
   sas_ = anc_sift(sas_,keep);
   sas = anc_cat(sas, sas_);
   disp(['file: ',num2str(length(sas_files)-m)])
end

ddr = sas.vdata.direct_normal_transmittance./sas.vdata.diffuse_transmittance;
figure; plot(sas.time, ddr([2,4:7],:), '.'); dynamicDateTicks

outfile = [fileparts(sas.fname),'.ddr_filt.',datestr(sas.time(1),'yyyymmdd_'), datestr(sas.time(end),'yyyymmdd'),'.mat'];
save(outfile,'-struct','sas');
% 