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
% netcdf.inqGrpName(Grp(2));
lv0_id = Grp(1); % level_0
lv1_id = Grp(2); % level_1 
cod_id = netcdf.inqVarID(lv1_id,'cod');
twst.cod = netcdf.getVar(lv1_id,cod_id)';
netcdf.inqVarID(lv0_id,'wavelength_vis');
lev0_grps = netcdf.inqGrps(Grp(1));
netcdf.inqGrpName(lev0_grps(2)) ; % sky
sky_id =lev0_grps(2); 
dark_id = lev0_grps(1);
cal_id = Grp(6);
cal_grps =netcdf.inqGrps(cal_id);
rad_cal_id = cal_grps(2);
rad_cal_grps = netcdf.inqVarID(rad_cal_id,'vis');
[lv0_ndims,lv0_nvars,lv0_ngatts,lv0_unlimdimid] = netcdf.inq(lv0_id);
twst.wl_B = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_nir')));
twst.wl_A = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_vis')));
twst.zenrad_B = netcdf.getVar(sky_id,netcdf.inqVarID(sky_id,'nir')); 
twst.zenrad_A = netcdf.getVar(sky_id,netcdf.inqVarID(sky_id,'vis'));
twst.cal_A = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'vis'));
twst.dark_A = netcdf.getVar(dark_id,netcdf.inqVarID(dark_id,'vis'));
twst.cal_B = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'nir'));
twst.dark_B = netcdf.getVar(dark_id,netcdf.inqVarID(dark_id,'nir'));
twst.tint_A_s = double(netcdf.getAtt(lv0_id,0,'integration_t_us'))./1e6;
twst.tint_B_s = double(netcdf.getAtt(lv0_id,1,'integration_t_us'))./1e6;

% calibration/radiance_cal/vis
twst.epoch = netcdf.getVar(sky_id,netcdf.inqVarID(sky_id,'time'))';
twst.time = epoch2serial(twst.epoch);

twst.dark_epoch = netcdf.getVar(dark_id,netcdf.inqVarID(dark_id,'time'))';
twst.dark_time = epoch2serial(twst.dark_epoch);
dt_i = floor(interp1(twst.dark_epoch, [1:length(twst.dark_epoch)],twst.epoch,'linear','extrap'));
darks_A = twst.dark_A(:,dt_i);
darks_B = twst.dark_B(:,dt_i);
twst.raw_A = twst.zenrad_A ./ (twst.cal_A*ones([1,size(twst.zenrad_A,2)])) .* twst.tint_A_s + darks_A;
twst.raw_B = twst.zenrad_B ./ (twst.cal_B*ones([1,size(twst.zenrad_B,2)])) .* twst.tint_B_s + darks_B;


% figure; plot(twst.wl_A, twst.zenrad_A(:,floor(length(twst.time)./2)),'-', twst.wl_B, twst.zenrad_B(:,floor(length(twst.time)./2)),'-'); logy;

end