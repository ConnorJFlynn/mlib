function twst = twst4_to_struct(in_file)
% twst = twst4_to_struct(in_file)
if ~isavar('in_file')||isempty(in_file)
   in_file = getfullname('*TWST*.nc','twst_nc4','Select instrument-level TWST file(s)');
end

if iscell(in_file)&&~isempty(in_file)&&isafile(in_file{1})
   if ~isempty(in_file(2:end))
      twst = cat_twst(twst4_to_struct(in_file{1}),twst4_to_struct(in_file(2:end)));
   end
end
if (iscell(in_file)&&length(in_file)==1)&&isafile(in_file{1}) 
   in_file = in_file{1};
end
if ischar(in_file)&&isafile(in_file)
   [pname, fname, ext] = fileparts(in_file);
   pname = strrep([pname, filesep],[filesep filesep], filesep);
   fname = [fname ext];

   ncid = netcdf.open([pname, fname]);
   if ncid>0
      twst.pname = pname;
      twst.fname = fname;
   else
      error('Error opening netcdf file.')
      return
   end
   Grp = netcdf.inqGrps(ncid);clear GrpName;
   for g=length(Grp):-1:1
      GrpName(g) = {netcdf.inqGrpName(Grp(g))};
   end

   % Grp(1) level 0 data
   % netcdf.inqGrpName(Grp(2));
   lv0_id = Grp(foundstr(GrpName,'level_0')); % level_0
   lv1_id = Grp(foundstr(GrpName,'level_1')); % level_1
   cal_id = Grp(foundstr(GrpName,'calibration'));
   cod_id = netcdf.inqVarID(lv1_id,'cod');
   twst.cod = netcdf.getVar(lv1_id,cod_id)';
   netcdf.inqVarID(lv0_id,'wavelength_vis');
   lev0_grps = netcdf.inqGrps(Grp(1));clear GrpName;
   for g = length(lev0_grps):-1:1
      lev0_Name(g) = {netcdf.inqGrpName(lev0_grps(g))};
   end

   sky_id =lev0_grps(foundstr(lev0_Name,'sky'));
   dark_id = lev0_grps(foundstr(lev0_Name,'dark'));


   Grp = netcdf.inqGrps(cal_id); clear GrpName;
   for g=length(Grp):-1:1
      GrpName(g) = {netcdf.inqGrpName(Grp(g))};
   end

   src_id = Grp(foundstr(GrpName,'source'));
   twst.wl_src = netcdf.getVar(src_id,netcdf.inqVarID(src_id,'wavelength'));
   twst.rad_src = 1000.*netcdf.getVar(src_id,netcdf.inqVarID(src_id,'spectral_radiance_cal'));
   twst.photodiode_current = netcdf.getVar(src_id,netcdf.inqVarID(src_id,'photodiode_current'));
   twst.lamp_time = netcdf.getVar(src_id,netcdf.inqVarID(src_id,'lamp_time'));

   twst.rad_src_units = 'mW/m^2/nm/sr';
   rad_cal_id = Grp(foundstr(GrpName,'radiance_cal'));
   % rad_cal_grps = netcdf.inqVarID(rad_cal_id,'vis');
   [lv0_ndims,lv0_nvars,lv0_ngatts,lv0_unlimdimid] = netcdf.inq(lv0_id);
   twst.wl_B = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_nir')));
   twst.wl_A = (netcdf.getVar(lv0_id,netcdf.inqVarID(lv0_id,'wavelength_vis')));
   twst.zenrad_B = netcdf.getVar(sky_id,netcdf.inqVarID(sky_id,'nir'));
   twst.zenrad_A = netcdf.getVar(sky_id,netcdf.inqVarID(sky_id,'vis'));
   twst.cal_A = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'vis'));
   twst.tint_A = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'vis_tint'));
   twst.navg_A = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'vis_navg'));
   twst.dark_A = netcdf.getVar(dark_id,netcdf.inqVarID(dark_id,'vis'));
   twst.cal_B = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'nir'));
   twst.tint_B = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'nir_tint'));
   twst.navg_B = netcdf.getVar(rad_cal_id,netcdf.inqVarID(rad_cal_id,'nir_navg'));
   twst.dark_B = netcdf.getVar(dark_id,netcdf.inqVarID(dark_id,'nir'));
   twst.tint_A_s = double(netcdf.getAtt(lv0_id,0,'integration_t_us'))./1e6;
   twst.tint_B_s = double(netcdf.getAtt(lv0_id,1,'integration_t_us'))./1e6;

   % calibration/radiance_cal/vis
   twst.epoch = netcdf.getVar(sky_id,netcdf.inqVarID(sky_id,'time'))';
   twst.time = epoch2serial(twst.epoch);

   twst.dark_epoch = netcdf.getVar(dark_id,netcdf.inqVarID(dark_id,'time'))';
   netcdf.close(ncid)
   twst.dark_time = epoch2serial(twst.dark_epoch);
   if isfield(twst,'dark_epoch') && ~isempty(twst.dark_epoch)
      if length(twst.dark_epoch)==1
         dt_i = 1;
      else
         dt_i = floor(interp1(twst.dark_epoch, [1:length(twst.dark_epoch)],twst.epoch,'linear','extrap'));
         dt_i(dt_i<1) = 1; dt_i(dt_i>length(twst.dark_time)) = length(twst.dark_time);
      end
      darks_A = twst.dark_A(:,dt_i);
      darks_B = twst.dark_B(:,dt_i);
   end
   twst.rate_A = twst.zenrad_A ./ (twst.cal_A*ones([1,size(twst.zenrad_A,2)]));
   twst.rate_B = twst.zenrad_B ./ (twst.cal_B*ones([1,size(twst.zenrad_B,2)]));
   twst.sig_A = twst.rate_A .* twst.tint_A_s;
   twst.sig_B = twst.rate_B .* twst.tint_B_s;
   twst.raw_A = twst.sig_A + darks_A;
   twst.raw_B = twst.sig_B + darks_B;
   % figure; plot(twst.wl_A, twst.zenrad_A(:,floor(length(twst.time)./2)),'-', twst.wl_B, twst.zenrad_B(:,floor(length(twst.time)./2)),'-'); logy;
end
end

function twst_ = cat_twst(twst, twst_)
tmp = [twst_.time,twst.time];
[twst_.time,ind] = unique(tmp);
ntimes = length(twst.time);
twst = rmfield(twst,'time');
flds = fieldnames(twst);
for f = 1:length(flds)
   fld = flds{f};
   dimid = find(size(twst.(fld))==ntimes);
   if dimid==1
      tmp = [twst_.(fld);twst.(fld)];
      if size(twst.(fld),2)==1
         twst_.(fld) = tmp(ind);
      else
         twst_.(fld) = tmp(ind,:);
      end
      twst_.(fld) = [];
   elseif dimid==2
      tmp = [twst_.(fld),twst.(fld)];
      if size(twst.(fld),1)==1
         twst_.(fld) = tmp(ind);
      else
         twst_.(fld) = tmp(:,ind);
      end
   end
end

end