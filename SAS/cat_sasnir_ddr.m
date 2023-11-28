function sas = cat_sasnir_ddr;
% cat_sasnir_wl
% outputs only nir wl values from MFRSR and Cimel 
% 
% sas_files = getfullname('*sashe*aod*.nc');
% sas = anc_load(sas_files{1});

sas_files = getfullname('*sashe*aod*.nc');
sas = anc_load(sas_files{1});
wavelen = [1020 1040 1225 1280 1625 1640];
wl_i = interp1(sas.vdata.wavelength, [1:length(sas.vdata.wavelength)],wavelen,'nearest');
sas = anc_sift(sas, wl_i,sas.ncdef.dims.wavelength);
for m = 2:length(sas_files)
   sas_ = anc_load(sas_files{m});
   sas_ = anc_sift(sas_, wl_i,sas.ncdef.dims.wavelength);
   sas = anc_cat(sas, sas_);
   disp(['file: ',num2str(length(sas_files)-m)])
end
% 
% sas = anc_bundle_files;
% wavelen = [1020 1040 1225 1280 1625 1640];
% wl_i = interp1(sas.vdata.wavelength, [1:length(sas.vdata.wavelength)],wavelen,'nearest');
% sas = anc_sift(sas, wl_i,sas.ncdef.dims.wavelength);
ddr = sas.vdata.direct_normal_transmittance./sas.vdata.diffuse_transmittance;
RayOD = rayleigh(wavelen./1000,2);
Tr_ray = exp(-RayOD'*sas.vdata.airmass); 
Ray_DDR_filt = 2.*Tr_ray./(1-Tr_ray);

keep = sas.vdata.airmass>=1 & sas.vdata.airmass<=2;
keep = keep& all(sas.vdata.direct_normal_transmittance>0) & all(sas.vdata.diffuse_transmittance>0);
keep = keep & ddr(1,:)>0 & ddr(1,:)< .5.*Ray_DDR_filt(1,:);
keep = keep & ddr(2,:)>0 & ddr(2,:)< .5.*Ray_DDR_filt(2,:);
keep = keep & ddr(3,:)>0 & ddr(3,:)< .5.*Ray_DDR_filt(3,:);
keep = keep & ddr(4,:)>0 & ddr(4,:)< .5.*Ray_DDR_filt(4,:);
keep = keep & ddr(5,:)>0 & ddr(5,:)< .5.*Ray_DDR_filt(5,:);
keep = keep & ddr(6,:)>0 & ddr(6,:)< .5.*Ray_DDR_filt(6,:);
sas = anc_sift(sas,keep);

% save(['D:\aodfit_be\pvc\pvcsasheniraodM1.c1.filt.mat'],'-struct','sas');
% save(['D:\aodfit_be\hou\housasheniraodM1.c1.filt.mat'],'-struct','sas');
% save(['D:\epc\epcsasheniraodM1.c1.ddr_filt.Feb10_14.mat'],'-struct','sas')
outfile = [fileparts(sas.fname),'.ddr_filt.',datestr(sas.time(1),'yyyymmdd_'), datestr(sas.time(end),'yyyymmdd'),'.mat'];
save(outfile,'-struct','sas')

end