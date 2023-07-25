function twst = twst4_to_struct(in_file)
if ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST file(s)');
end
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
[lv0_ndims,lv0_nvars,lv0_ngatts,lv0_unlimdimid] = netcdf.inq(lv0_id);
twst.wl_B = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_nir')));
twst.wl_A = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_vis')));
twst.zenrad_B = netcdf.getVar(sky_id,5);
twst.zenrad_A = netcdf.getVar(sky_id,1);
twst.epoch = netcdf.getVar(sky_id,0)';
twst.time = epoch2serial(twst.epoch);

% figure; plot(twst.wl_A, twst.zenrad_A(:,floor(length(twst.time)./2)),'-', twst.wl_B, twst.zenrad_B(:,floor(length(twst.time)./2)),'-'); logy;

end