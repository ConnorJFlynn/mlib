function sas = cat_sasnir_aod;
% cat_sasnir_wl
% outputs only nir wl values from MFRSR and Cimel 

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

miss = any(sas.vdata.aerosol_optical_depth<=0);
sas = anc_sift(sas,~miss);

qc = max(anc_qc_impacts(sas.vdata.qc_aerosol_optical_depth(5:6,:), sas.vatts.qc_aerosol_optical_depth));
sas = anc_sift(sas,qc<2); % remove times when ANY were "bad" or "missing"

outfile = [fileparts(sas.fname),'.aod_filt.',datestr(sas.time(1),'yyyymmdd_'), datestr(sas.time(end),'yyyymmdd'),'.mat'];
save(outfile,'-struct','sas')

% save(['D:\aodfit_be\pvc\pvcsasheniraodM1.c1.filt.mat'],'-struct','sas');
% save(['D:\aodfit_be\hou\housasheniraodM1.c1.filt.mat'],'-struct','sas');
end