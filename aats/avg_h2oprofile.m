function [h2o_mean,h2o_err_mean,h2o_std,zkm_mean,dectime_mean,h2o_dens_is_mean,GPS_Alt_mean,Press_Alt_mean,press_mean,lat_mean,long_mean]= ...
      avg_h2oprofile(h2o,h2o_err,zkm,dectime,zbot,ztop,deltaz,h2o_dens_is,GPS_Alt,Press_Alt,press,lat,long);

nlayer=(ztop-zbot)/deltaz;
zlow=[zbot:deltaz:ztop-deltaz];
zhigh=[zbot+deltaz:deltaz:ztop];

for iz = 1:nlayer,
    jzuse = find(zkm>=zlow(iz) & zkm<=zhigh(iz));
    h2o_mean(iz) = mean(h2o(jzuse));
    h2o_err_mean(iz) = mean(h2o_err(jzuse));
    h2o_std(iz) = std(h2o(jzuse));
    zkm_mean(iz) = mean(zkm(jzuse));
    dectime_mean(iz)=mean(dectime(jzuse));
    h2o_dens_is_mean(iz)=mean(h2o_dens_is(jzuse));
    lat_mean(iz) = mean(lat(jzuse));
    long_mean(iz) = mean(long(jzuse));
    GPS_Alt_mean(iz) = mean(GPS_Alt(jzuse));
    Press_Alt_mean(iz) = mean (Press_Alt(jzuse));
    press_mean(iz) = mean (press(jzuse));
end

%remove bins with no data
ilayer=~isnan(h2o_mean);
h2o_mean=h2o_mean(ilayer);
h2o_err_mean=h2o_err_mean(ilayer);
h2o_std = h2o_std(ilayer);
zkm_mean= zkm_mean(ilayer);
dectime_mean=dectime_mean(ilayer);
h2o_dens_is_mean=h2o_dens_is_mean(ilayer); 
lat_mean= lat_mean(ilayer);
long_mean= long_mean(ilayer);
GPS_Alt_mean=GPS_Alt_mean(ilayer);
Press_Alt_mean=Press_Alt_mean(ilayer);
press_mean=press_mean(ilayer);

return
