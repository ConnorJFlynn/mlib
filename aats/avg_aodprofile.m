function [aod_mean,aod_err_mean,aod_std,zkm_mean,GPS_Alt_mean,Press_Alt_mean,press_mean,lat_mean,long_mean,dectime_mean,gamma_mean,alpha_mean,a0_mean]= ...
  avg_aodprofile(aod_in,aod_err_in,zkm_in,GPS_Alt_in,Press_Alt_in,press_in,dectime_in,lat_in,long_in,gamma_in,alpha_in,a0_in,zbot,ztop,deltaz);


nlayer=(ztop-zbot)/deltaz;
zlow=[zbot:deltaz:ztop-deltaz];
zhigh=[zbot+deltaz:deltaz:ztop];

for iz = 1:nlayer,
   jzuse = find(zkm_in>=zlow(iz) & zkm_in<=zhigh(iz));
   aod_mean(:,iz) = mean(aod_in(:,jzuse),2);
   aod_err_mean(:,iz) = mean(aod_err_in(:,jzuse),2);
   aod_std(:,iz) = std(aod_in(:,jzuse),0,2);
   zkm_mean(iz) = mean(zkm_in(jzuse));
   dectime_mean(iz)=mean(dectime_in(jzuse));
   lat_mean(iz) = mean(lat_in(jzuse));
   long_mean(iz) = mean(long_in(jzuse));
   GPS_Alt_mean(iz) = mean(GPS_Alt_in(jzuse));
   Press_Alt_mean(iz) = mean (Press_Alt_in(jzuse));
   press_mean(iz) = mean (press_in(jzuse));
   gamma_mean(iz) = mean (gamma_in(jzuse));
   alpha_mean(iz) = mean (alpha_in(jzuse));
   a0_mean(iz)    = mean (a0_in(jzuse));
end

   %remove bins with no data
   ilayer=~isnan(aod_mean(1,:));
   aod_mean=aod_mean(:,ilayer);
   aod_err_mean=aod_err_mean(:,ilayer);
   aod_std = aod_std(:,ilayer);
   zkm_mean= zkm_mean(ilayer);
   dectime_mean=dectime_mean(ilayer);
   lat_mean= lat_mean(ilayer);
   long_mean= long_mean(ilayer);
   GPS_Alt_mean=GPS_Alt_mean(ilayer);
   Press_Alt_mean=Press_Alt_mean(ilayer);
   press_mean=press_mean(ilayer);
   gamma_mean=gamma_mean(ilayer);
   alpha_mean=alpha_mean(ilayer);
   a0_mean=a0_mean(ilayer);
 
return
