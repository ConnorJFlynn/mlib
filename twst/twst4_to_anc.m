function twst = twst4_to_anc(in_file)
if ~isavar('in_file')||~isafile(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST file(s)');
   if isstruct(in_file)&&~empty(in_file)&&isafile(in_file{1})
      in_file = in_file{1};
   end

   ncid = netcdf.open(in_file);
          Grp = netcdf.inqGrps(ncid); 
          % Grp(1) level 0 data
          netcdf.inqGrpName(Grp(1))
          lv0_id = Grp(1);
          lev0_grps = netcdf.inqGrps(Grp(1))
          netcdf.inqGrpName(lev0_grps(1)) ; % sky
          sky_id =lev0_grps(1);
[lv0_ndims,lv0_nvars,lv0_ngatts,lv0_unlimdimid] = netcdf.inq(lv0_id)
twst.wl_B = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_nir')));
twst.wl_A = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_vis')));
twst.zenrad_B = netcdf.getVar(sky_id,1);
twst.zenrad_A = netcdf.getVar(sky_id,2);
twst.epoch = netcdf.getVar(sky_id,0);
twst.time = epoch2serial(twst.epoch);

figure; plot(twst.wl_A, twst.zenrad_A(:,1000),'-', twst.wl_B, twst.zenrad_B(:,1000),'-'); logy;

[sky_ndims,sky_nvars,sky_ngatts,sky_unlimdimid] = netcdf.inq(sky_id)
netcdf.inqUnlimDims(Grp(1))

   [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
   Generates an error. Try using HD5 to read this file










end