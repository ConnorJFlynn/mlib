plots_ppt
sasvis = sashe; clear sashe
% use time trace of 500 nm to select period where AOD was fairly stable and
% the mean value is meaningful.

nm_500 = interp1(sasvis.vdata.wavelength, [1:length(sasvis.vdata.wavelength)],500,'nearest');

tl = xl; tl_ = xl_;
no_miss = sasvis.vdata.aerosol_optical_depth(nm_500,:)>0;
tl = xlim; tl_ = serial2doys(sasvis.time)>=tl(1)& serial2doys(sasvis.time)<=tl(2);

wl_vis = sasvis.vdata.wavelength;

good_vis = sasvis.vdata.qc_smoothed_Io_values==0;
sub_vis = sasvis.vdata.wavelength<970;
bad_vis = ~good_vis|~sub_vis;

xl_vis = xlim;
bad_vis = bad_vis | (wl_vis>=xl_vis(1)&wl_vis<=xl_vis(2));

figure; plot(sasvis.vdata.wavelength(sub_wl), mean(sasvis.vdata.aerosol_optical_depth(sub_wl,tl_ & no_miss),2), 'r.',sasvis.vdata.wavelength(good_wl&sub_wl& ~bad_vis), mean(sasvis.vdata.aerosol_optical_depth(good_wl&sub_wl& ~bad_vis,xl_ & no_miss),2), 'b*');logy



good_nir_wl = sasnir.vdata.qc_smoothed_Io_values==0;
sub_nir = sasnir.vdata.wavelength>=970;

bad_nir_gas = ~good_nir_wl | ~sub_nir;
xl_nir = xlim;
bad_nir_gas = bad_nir_gas | (sasnir.vdata.wavelength>=xl_nir(1)&sasnir.vdata.wavelength<=xl_nir(2));

xl_m_ = false(size(bad_nir_gas));
xl_maybe = xlim;
xl_m_ = xl_m_ 


figure; plot(sasnir.vdata.wavelength(sub_nir), mean(sasnir.vdata.aerosol_optical_depth(sub_nir,tl_ & no_miss),2), 'r.',...
    sasnir.vdata.wavelength(~bad_nir_gas), mean(sasnir.vdata.aerosol_optical_depth(~bad_nir_gas,tl_ & no_miss),2), 'c*')

% Color A-band and uncorrected gas contributions "yellow".  Can be, but
% aren't yet corrected.