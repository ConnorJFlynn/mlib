function  write_TZR_nc(pname, inst, lat, lon, in_time, sza, wavelength_vis, wavelength_nir, vis, nir)

dstr = datestr(mean(in_time),'yyyymmdd');
fname = [inst,'.',dstr,'.nc'];
ncid = netcdf.create([pname, filesep,fname],'CLOBBER');
nirDimId  = netcdf.defDim(ncid,'wavelength_nir',length(wavelength_nir));
visDimId  = netcdf.defDim(ncid,'wavelength_vis',length(wavelength_vis));
timeDimId = netcdf.defDim(ncid,'time',netcdf.getConstant('UNLIMITED'));

time_varid = netcdf.defVar(ncid,'time','NC_DOUBLE',timeDimId);
   netcdf.putAtt(ncid,time_varid,'units','seconds since 1970-01-01 00:00');

lat_varid = netcdf.defVar(ncid,'lat','NC_DOUBLE',[]);
   netcdf.putAtt(ncid,lat_varid,'long_name','latitude');
   netcdf.putAtt(ncid,lat_varid,'units','degrees_north');

lon_varid = netcdf.defVar(ncid,'lon','NC_DOUBLE',[]);
   netcdf.putAtt(ncid,lon_varid,'long_name','longitude');
   netcdf.putAtt(ncid,lon_varid,'units','degrees_east');

wlnir_varid = netcdf.defVar(ncid,'wavelength_nir','NC_FLOAT',nirDimId);
   netcdf.putAtt(ncid,wlnir_varid,'long_name','nir wavelength');
   netcdf.putAtt(ncid,wlnir_varid,'units','nm');

wlvis_varid = netcdf.defVar(ncid,'wavelength_vis','NC_FLOAT',visDimId);
   netcdf.putAtt(ncid,wlvis_varid,'long_name','vis wavelength');
   netcdf.putAtt(ncid,wlvis_varid,'units','nm');

sza_varid = netcdf.defVar(ncid,'sza','NC_FLOAT',timeDimId);
   netcdf.putAtt(ncid,sza_varid,'long_name','solar zenith angle');
   netcdf.putAtt(ncid,sza_varid,'units','degrees');

nir_varid = netcdf.defVar(ncid,'nir','NC_FLOAT',[nirDimId,timeDimId]);
   netcdf.putAtt(ncid,nir_varid,'long_name','nir radiance');
   netcdf.putAtt(ncid,nir_varid,'units','W m-2 nm-1 sr-1');

vis_varid = netcdf.defVar(ncid,'vis','NC_FLOAT',[visDimId,timeDimId]);
   netcdf.putAtt(ncid,vis_varid,'long_name','vis radiance');
   netcdf.putAtt(ncid,vis_varid,'units','W m-2 nm-1 sr-1');

netcdf.endDef(ncid,20000,4,0,4);
                       
netcdf.putVar(ncid,lat_varid,lat);
netcdf.putVar(ncid,lon_varid,lon);
netcdf.putVar(ncid,wlnir_varid,0,length(wavelength_nir),wavelength_nir);
netcdf.putVar(ncid,wlvis_varid,0,length(wavelength_vis),wavelength_vis);
netcdf.putVar(ncid,time_varid,0,length(in_time), serial2epoch(in_time));
netcdf.putVar(ncid,sza_varid,0,length(in_time), sza);
netcdf.putVar(ncid,nir_varid,[0,0],[length(wavelength_nir),length(in_time)], single(nir'));
netcdf.putVar(ncid,vis_varid,[0,0],[length(wavelength_vis),length(in_time)], single(vis'));

netcdf.close(ncid);

end