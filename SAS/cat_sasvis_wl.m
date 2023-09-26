function sas = cat_sasvis_wl;
% cat_filt_sasaod
% outputs only vis wl values from MFRSR and Cimel>=380 

sas_files = getfullname('*sashe*aod*.cdf');
sas = anc_load(sas_files{1});
wl_i = interp1(sas.vdata.wavelength, [1:length(sas.vdata.wavelength)],[380, 415,440,500,615,675,870],'nearest');
sas = anc_sift(sas, wl_i,sas.ncdef.dims.wavelength);

for m = 2:length(sas_files)
   sas_ = anc_load(sas_files{m});
   sas_ = anc_sift(sas_, wl_i,sas.ncdef.dims.wavelength);
   sas = anc_cat(sas, sas_);
   disp(['file: ',num2str(length(sas_files)-m)])
end

miss = any(sas.vdata.aerosol_optical_depth<=0);
sas = anc_sift(sas,~miss);

qc = max(anc_qc_impacts(sas.vdata.qc_aerosol_optical_depth, sas.vatts.qc_aerosol_optical_depth));
sas = anc_sift(sas,qc<2);
% save(['D:\aodfit_be\pvc\pvcsashevisaodM1.c1.filt.mat'],'-struct','sas');
% save(['D:\aodfit_be\hou\housashevisaodM1.c1.filt.mat'],'-struct','sas');
end