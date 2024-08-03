function twst = Ze_to_twst(Zev, Zen, MT)
% twst = Ze_to_twst(Zev, Zen)
% The idea is to open an empty twst file as a template.
% Simplest might be to populate the time field and then interpolate Zev and 
% to match the TWST A and B wavelength grids since this shouldn't require 
% opening the twst nc file in REDEF.
while ~isavar('MT')||isempty(MT)||~isafile(MT)
   MT = getfullname('*TWST*.nc','twst_nc4','Select TWST file to use as template');
end
if (iscell(MT)&&length(MT)==1)&&isafile(MT{1}) 
   MT = MT{1};
end
if ~isavar('Zev')
   Zev = rd_SAS_dualtint_raw(getfullname('*vis_1s*','Ze_in')); 
   Zen = rd_SAS_dualtint_raw(getfullname('*nir_1s*','Ze_in'));
end
if ~isavar('Zen')
   Zen = rd_SAS_raw(getfullname('*nir_1s*','Ze_in'));
end
[vinn, ninv] = nearest(Zev.time, Zen.time);

if ischar(MT)&&isafile(MT)
   [pname, fname, ext] = fileparts(MT);
   pname = strrep([pname, filesep],[filesep filesep], filesep);
   fname = [fname ext];

   ncid = netcdf.open([pname, fname],'WRITE');
   if ncid>0
      twst.pname = pname;
      twst.fname = fname;
   else
      error('Error opening netcdf file.')
      return
   end
   Grp = netcdf.inqGrps(ncid);
   if isavar('GrpName'); clear GrpName; end
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
   netcdf.reDef(ncid)
   netcdf.putVar(sky_id, netcdf.inqVarID(sky_id,'time'),0, numel(vinn),serial2epoch(Zev.time(vinn)));
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