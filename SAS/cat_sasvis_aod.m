function sas = cat_sasvis_aod;
% cat_filt_sasaod
% outputs only vis wl values from MFRSR and Cimel>=380 
% Modified on 2024-05-18 to output 1019 nm value

sas_files = getfullname(['*sashe*aod*.cdf;*sashe*aod*.nc']);
sas = anc_load(sas_files{1});
wl_i = interp1(sas.vdata.wavelength, [1:length(sas.vdata.wavelength)],[380, 415,440,500,615,675,870, 1020],'nearest');
sas = anc_sift(sas, wl_i,sas.ncdef.dims.wavelength);
qc = max(anc_qc_impacts(sas.vdata.qc_aerosol_optical_depth, sas.vatts.qc_aerosol_optical_depth));
sas = anc_sift(sas,qc<2);
for m = 2:length(sas_files)
   sas_ = anc_load(sas_files{m});
   sas_ = anc_sift(sas_, wl_i,sas.ncdef.dims.wavelength);
   qc = max(anc_qc_impacts(sas_.vdata.qc_aerosol_optical_depth, sas_.vatts.qc_aerosol_optical_depth));
   sas_ = anc_sift(sas_,qc<2);
   sas = anc_cat(sas, sas_);
   disp(['file: ',num2str(length(sas_files)-m)])
end

miss = any(sas.vdata.aerosol_optical_depth<=0);
sas = anc_sift(sas,~miss);

% qc = max(anc_qc_impacts(sas.vdata.qc_aerosol_optical_depth, sas.vatts.qc_aerosol_optical_depth));
% sas = anc_sift(sas,qc<2);
outfile = [fileparts(sas.fname),'.aod_filt2.',datestr(sas.time(1),'yyyymmdd_'), datestr(sas.time(end),'yyyymmdd'),'.mat'];
save(outfile,'-struct','sas');
end