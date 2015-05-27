function ssfr = sift_ssfr(ssfr,inds)
ssfr.time = ssfr.time(inds);
ssfr.vdata.hours = ssfr.vdata.hours(inds);
ssfr.vdata.spectra = ssfr.vdata.spectra(:,inds);
ssfr.vdata.lon = ssfr.vdata.lon(inds);
ssfr.vdata.lat = ssfr.vdata.lat(inds);
return